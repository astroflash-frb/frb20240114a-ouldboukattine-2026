#!/usr/bin/env python3
"""
SFXC .ctrl file generator for single-telescope P-band bursts
(based on generate_ctrl_files.py, but adapted for *_pband filenames)

Differences vs original script:
- Accepts filenames ending in *_seconds_pband
- Removes Torun USB/LSB fix logic
- Script name: generate_ctrl_files_pband.py
- Placeholder section for small .ctrl tweaks needed for P-band

Example filename:
    p47030_wb_no0021_60386.37677811_plus-minus_30.0_seconds_pband
"""

import os
import json
import re
from datetime import datetime, timedelta
from glob import glob
import subprocess
import argparse
import shutil

# ---------------- CONFIGURATION ----------------
BASE_DIR = "/data1/omar/sfxc/frb240114a"
DM_CONFIG_FILE = "/home/omar/git/r147-single-dish-analysis/DM_config.json"
CHANNELS = [f"CH{c:02d}" for c in range(1, 17)]
DURATION_SECONDS = 3.0
LOGFILE = os.path.join(BASE_DIR, "ctrl_generation_pband.log")
SCHEDULE_DIR = "/home/omar/git/schedules"

STATION_CASE = {"wb": "Wb", "tr": "Tr", "o8": "O8"}

STATIONS_DIRS = {
    "wb": "/scratch1/baseband_extractions/r147/westerbork"
}

# Accept *_seconds_pband
# Accept *_seconds_pband
FILENAME_RE = re.compile(
    r"^(.+?)_([a-z0-9]+)_no(\d+)_([\d.]+)_plus-minus_([\d.]+)_seconds_pband$",
    re.IGNORECASE,
)

# ---------------- UTILITY FUNCTIONS ----------------

def log_message(message):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOGFILE, "a") as f:
        f.write(f"[{ts}] {message}\\n")
    print(message)


def mjd_to_datetime(mjd):
    mjd_epoch = datetime(1858, 11, 17)
    return mjd_epoch + timedelta(days=mjd)


def format_sfxc_time(dt):
    year = dt.year
    doy = dt.timetuple().tm_yday
    return f"{year}y{doy:03d}d{dt.hour:02d}h{dt.minute:02d}m{dt.second:02d}s"


def parse_filename(basename):
    m = FILENAME_RE.match(basename)
    if not m:
        return None

    exper, station_token, scan_str, mjd_str, dur_str = m.groups()
    station_token = station_token.lower()
    station = STATION_CASE.get(station_token, station_token.upper())

    return {
        "exper": exper,
        "station_token": station_token,
        "station": station,
        "scan": int(scan_str),
        "mjd": float(mjd_str),
        "orig_dur": float(dur_str),
    }


def load_dm_config(config_path=DM_CONFIG_FILE):
    try:
        with open(config_path, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        log_message(f"DM configuration file not found: {config_path}")
        return {}


def create_polyco_file(outdir, dm_value, pulsar_key="R240114_D"):
    polyco_filename = os.path.join(outdir, f"{os.path.basename(outdir)}.polyco")
    content = f"""{pulsar_key}   03-May-21    191325.00      59337.80   {dm_value} 0.000  0.000
            0.000000    0.500000000000  COE  600    3  1350.00
 0.00000000000000000e+00  0.00000000000000000e+00  0.00000000000000000e+00
"""
    with open(polyco_filename, "w") as f:
        f.write(content)

    log_message(f"Created polyco with DM {dm_value}")
    return polyco_filename


def prepare_vex(exper, outdir):
    vex_file = os.path.join(SCHEDULE_DIR, f"{exper}.vex")
    if not os.path.isfile(vex_file):
        log_message(f"VEX not found: {vex_file}")
        return None

    dest_vex = os.path.join(outdir, f"{exper}.vex")
    shutil.copy2(vex_file, dest_vex)

    vix_file = os.path.join(outdir, f"{exper}.vix")
    cmd = ["prepare_vex.py", dest_vex, vix_file]

    try:
        subprocess.run(cmd, check=True)
        log_message(f"Prepared VIX: {vix_file}")
        return vix_file
    except Exception as e:
        log_message(f"VEX→VIX failed: {e}")
        return None

# ---------------- CTRL GENERATION ----------------

def make_ctrl(fullpath, dm_config):
    basename = os.path.basename(fullpath)
    parsed = parse_filename(basename)

    if not parsed:
        log_message(f"SKIPPED: {basename}")
        return None

    # -------- P-BAND CTRL TWEAKS LIVE HERE --------
    # Spectral / channelisation
    number_channels = 256
    fft_corr = 256
    fft_delay = 256

    # Time resolution
    integr_time = 4.096
    sub_integr_time = 256.0

    # Window around burst (total = 10 s)
    time_before = 2   # seconds before center
    time_after = 8    # seconds after center

    # Output naming reflects resolution
    TIME_LABEL = "256us"
    FREQ_LABEL = "32KHz"
    # ----------------------------------------------

    exper = parsed["exper"]
    station = parsed["station"]
    station_token = parsed["station_token"]
    scan = parsed["scan"]
    mjd = parsed["mjd"]

    dt_center = mjd_to_datetime(mjd)
    dt_start = dt_center - timedelta(seconds=time_before)
    dt_stop = dt_center + timedelta(seconds=time_after)

    start_str = format_sfxc_time(dt_start)
    stop_str = format_sfxc_time(dt_stop)

    pulsar_key = "R240114_D"

    mjd_folder = f"{mjd:.5f}"
    subdir = f"{exper}_{scan}_{station_token}_{mjd_folder}_pband"
    outdir = os.path.join(BASE_DIR, subdir)
    os.makedirs(outdir, exist_ok=True)

    dm = dm_config.get(subdir, 527.7)

    polyco = create_polyco_file(outdir, dm, pulsar_key)

    DM_TAG = f"DM{int(dm*10)}"
    output_cor = f"file://{outdir}/{exper}_{scan}_{TIME_LABEL}_{FREQ_LABEL}_StokesI_{DM_TAG}.cor"

    ctrl = {
        "number_channels": number_channels,
        "cross_polarize": False,
        "integr_time": integr_time,
        "sub_integr_time": sub_integr_time,
        "start": start_str,
        "stop": stop_str,
        "fft_size_correlation": fft_corr,
        "fft_size_delaycor": fft_delay,
        "output_file": output_cor,
        "filterbank": True,
        "pulsars": {
            pulsar_key: {
                "polyco_file": f"file://{polyco}",
                "coherent_dedispersion": True,
                "no_intra_channel_dedispersion": False,
            }
        },
        "pulsar_binning": False,
        "normalize": False,
        "window_function": "NONE",
        "data_sources": {station: [f"file://{fullpath}"]},
        "stations": [station],
        "channels": CHANNELS,
        "exper_name": exper,
        "delay_directory": f"file://{outdir}/",
        "message_level": 1,
        "file_parameters": {station: {"sources": [f"sleipnir://{fullpath}"]}},
    }

    ctrl_name = f"{exper}_{scan}_{station_token}.ctrl"
    ctrl_path = os.path.join(outdir, ctrl_name)

    with open(ctrl_path, "w") as f:
        json.dump(ctrl, f, indent=4)

    log_message(f"CREATED {ctrl_path} | DM={dm}")
    return ctrl_path

# ---------------- BULK ----------------

def generate_all_ctrls(keys="*", dm_config=None, prepare_vex_flag=False):
    if dm_config is None:
        dm_config = {}

    key_list = [k.strip() for k in keys.split(",")]

    files = []

    for st_token, dir_path in STATIONS_DIRS.items():
        log_message(f"Scanning {dir_path}")

        for key in key_list:
            pattern = os.path.join(
                dir_path,
                f"{key}_{st_token}_no*_plus-minus_*_seconds_pband",
            )
            files.extend(glob(pattern))

    log_message(f"Found {len(files)} files")

    created = []
    for f in sorted(files):
        ctrl = make_ctrl(f, dm_config)
        if ctrl:
            created.append(ctrl)
            if prepare_vex_flag:
                exper = os.path.basename(ctrl).split("_")[0]
                prepare_vex(exper, os.path.dirname(ctrl))

    log_message(f"Done. Created {len(created)} ctrl files")


# ---------------- MAIN ----------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--prepare-vex", action="store_true")
    parser.add_argument("-k", "--key", default="*")
    args = parser.parse_args()

    dm_config = load_dm_config()

    generate_all_ctrls(
        keys=args.key,
        dm_config=dm_config,
        prepare_vex_flag=args.prepare_vex,
    )

