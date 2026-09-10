#!/usr/bin/env python3
"""
SFXC .ctrl file generator for single-telescope bursts with JSON-based per-burst DM.

Features:
- Automatically scans configured station directories
- Generates one .ctrl file per burst file
- Each burst gets a separate subdirectory based on its MJD
- Logs detailed per-burst info to ctrl_generation.log in BASE_DIR
- Uses default total duration 3 s (1 s before, 2 s after MJD)
- 64 µs / 125 kHz channelization
- Generates a polyco per burst using DM from JSON (fallback 527.7)
- Output .cor file reflects DM in filename
- Optional flag --prepare-vex to copy and convert corresponding .vex file to .vix
- Optional flag --torun-fix to fix USB/LSB mapping in Torun .vix files
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
LOGFILE = os.path.join(BASE_DIR, "ctrl_generation.log")
SCHEDULE_DIR = "/home/omar/git/schedules"

STATION_CASE = {"wb": "Wb", "tr": "Tr", "o8": "O8"}

# Correctly define STATIONS_DIRS
STATIONS_DIRS = {
    #"wb": "/scratch1/baseband_extractions/r147/test",
    "wb": "/scratch1/baseband_extractions/r147/westerbork",
    "tr": "/scratch1/baseband_extractions/r147/torun",
    #"o8": "/scratch1/baseband_extractions/r147/onsala"
}

FILENAME_RE = re.compile(
    r"^([a-z0-9]+)_([a-z0-9]+)_no(\d+)_([\d.]+)_plus-minus_([\d.]+)_seconds$",
    re.IGNORECASE
)

# ---------------- UTILITY FUNCTIONS ----------------

def log_message(message):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOGFILE, "a") as f:
        f.write(f"[{ts}] {message}\n")
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
        "orig_dur": float(dur_str)
    }

def load_dm_config(config_path=DM_CONFIG_FILE):
    try:
        with open(config_path, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        log_message(f"DM configuration file not found: {config_path}")
        return {}

def create_polyco_file(outdir, dm_value, pulsar_key="R240114_D"):
    """Create polyco file for burst with specified DM."""
    polyco_filename = os.path.join(outdir, f"{os.path.basename(outdir)}.polyco")
    content = f"""{pulsar_key}   03-May-21    191325.00      59337.80   {dm_value} 0.000  0.000
            0.000000    0.500000000000  COE  600    3  1350.00
 0.00000000000000000e+00  0.00000000000000000e+00  0.00000000000000000e+00
"""
    with open(polyco_filename, "w") as f:
        f.write(content)
    log_message(f"Created polyco for {os.path.basename(outdir)} with DM {dm_value}")
    return polyco_filename

def prepare_vex(exper, outdir):
    """Copy .vex from schedules folder to output folder and convert it to .vix."""
    vex_file = os.path.join(SCHEDULE_DIR, f"{exper}.vex")
    if not os.path.isfile(vex_file):
        log_message(f"VEX file not found for {exper}: {vex_file}")
        return None

    dest_vex_file = os.path.join(outdir, f"{exper}.vex")
    shutil.copy2(vex_file, dest_vex_file)
    log_message(f"Copied VEX to {dest_vex_file}")

    vix_file = os.path.join(outdir, f"{exper}.vix")
    cmd = ["prepare_vex.py", dest_vex_file, vix_file]
    try:
        subprocess.run(cmd, check=True)
        log_message(f"Converted VEX to VIX: {vix_file}")
        return vix_file
    except FileNotFoundError:
        log_message("ERROR: `prepare_vex.py` not found in PATH.")
        return None
    except subprocess.CalledProcessError as e:
        log_message(f"Failed to prepare VEX for {exper}: {e}")
        return None

def fix_tr_vix_append(vix_file_path):
    """Append corrected THREADS section for Torun .vix files, preserving the original THREADS name."""
    with open(vix_file_path, "r") as f:
        lines = f.readlines()

    new_lines = []
    in_threads = False
    threads_lines = []
    original_thread_name = None

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("def THREADS.") and ".Tr;" in stripped:
            in_threads = True
            threads_lines.append(line)
            original_thread_name = stripped.split()[1].rstrip(";")  # e.g., THREADS.TR_LBAND.Tr
        elif in_threads and stripped == "enddef;":
            threads_lines.append(line)
            commented = ["*" + l if not l.startswith("*") else l for l in threads_lines]
            date_str = datetime.now().strftime("%d_%m_%Y")
            new_lines.append(f"*Changed the USB/LSB when creating the .vix file on {date_str}\n")
            new_lines.extend(commented)

            # Append corrected section using original THREADS name
            new_lines.append(f"def {original_thread_name};\n")
            new_lines.append("    format = vdif :   : 2048;\n")
            new_lines.append("    thread = 0 : 1 : 1 : 2048 : 16 : 2 :   :   : 8000;\n")
            for ch_pair in ["CH03:0:8","CH04:0:12","CH01:0:0","CH02:0:4","CH07:0:9","CH08:0:13",
                            "CH05:0:1","CH06:0:5","CH11:0:10","CH12:0:14","CH09:0:2","CH10:0:6",
                            "CH15:0:11","CH16:0:15","CH13:0:3","CH14:0:7"]:
                ch, rest = ch_pair.split(":")[0], ch_pair.split(":")[1:]
                new_lines.append(f"    channel = {ch} : {' : '.join(rest)};\n")
            new_lines.append("enddef;\n")

            in_threads = False
            threads_lines = []
            original_thread_name = None
        elif in_threads:
            threads_lines.append(line)
        else:
            new_lines.append(line)

    with open(vix_file_path, "w") as f:
        f.writelines(new_lines)

# ---------------- CTRL GENERATION ----------------

def make_ctrl(fullpath, dm_config, duration_seconds=DURATION_SECONDS):
    basename = os.path.basename(fullpath)
    parsed = parse_filename(basename)
    if not parsed:
        log_message(f"SKIPPED: {fullpath} | Filename does not match pattern")
        return None

    exper = parsed["exper"]
    station = parsed["station"]
    station_token = parsed["station_token"].lower()
    scan = parsed["scan"]
    mjd = parsed["mjd"]

    dt_center = mjd_to_datetime(mjd)
    dt_start = dt_center - timedelta(seconds=1.0)
    dt_stop = dt_center + timedelta(seconds=2.0)
    start_str = format_sfxc_time(dt_start)
    stop_str = format_sfxc_time(dt_stop)

    if station_token in ["wb", "o8"]:
        pulsar_key = "R240114_D"
    elif station_token == "tr":
        pulsar_key = "R240121"
    else:
        pulsar_key = "R240114_D"

    mjd_folder = f"{mjd:.5f}"
    subdir = f"{exper}_{scan}_{station_token}_{mjd_folder}"
    outdir = os.path.join(BASE_DIR, subdir)
    os.makedirs(outdir, exist_ok=True)

    # Lookup DM
    dm = dm_config.get(subdir, 527.7)

    polyco_file = create_polyco_file(outdir, dm, pulsar_key)
    DM_TAG = f"DM{int(dm*10)}"
    output_cor = f"file://{outdir}/{exper}_{scan}_64us_125KHz_StokesI_{DM_TAG}.cor"

    delay_dir = f"file://{outdir}/"
    ctrl_filename = f"{exper}_{scan}_{station_token}.ctrl"
    ctrl_path = os.path.join(outdir, ctrl_filename)

    ctrl = {
        "number_channels": 128,
        "cross_polarize": False,
        "integr_time": 0.256,
        "sub_integr_time": 64.0,
        "start": start_str,
        "stop": stop_str,
        "fft_size_correlation": 128,
        "fft_size_delaycor": 128,
        "output_file": output_cor,
        "filterbank": True,
        "pulsars": {
            pulsar_key: {
                "polyco_file": f"file://{polyco_file}",
                "no_intra_channel_dedispersion": False,
                "coherent_dedispersion": True
            }
        },
        "pulsar_binning": False,
        "normalize": False,
        "window_function": "NONE",
        "data_sources": {station: [f"file://{fullpath}"]},
        "stations": [station],
        "channels": CHANNELS,
        "exper_name": exper,
        "delay_directory": delay_dir,
        "message_level": 1,
        "file_parameters": {station: {"sources": [f"sleipnir://{fullpath}"]}}
    }

    with open(ctrl_path, "w") as f:
        json.dump(ctrl, f, indent=4)

    log_message(f"CREATED: {ctrl_path} | Station: {station}, Scan: {scan}, DM: {dm}")
    return ctrl_path

# ---------------- BULK GENERATION ----------------

def generate_all_ctrls(keys="*", dm_config=None, prepare_vex_flag=False, torun_fix_flag=False):
    if dm_config is None:
        dm_config = {}

    if isinstance(keys, str):
        key_list = [k.strip() for k in keys.split(",")]
    else:
        key_list = keys

    filenames = []
    key_counts = {key: 0 for key in key_list}

    for st_token, dir_path in STATIONS_DIRS.items():
        log_message(f"Scanning directory for station {st_token}: {dir_path}")
        if not os.path.isdir(dir_path):
            log_message(f"WARNING: Directory not found: {dir_path}")
            continue

        station_files = []
        for key in key_list:
            pattern = os.path.join(dir_path, f"{key}_{st_token}_no*_plus-minus_*_seconds")
            matched_files = sorted(glob(pattern))
            key_counts[key] += len(matched_files)
            station_files.extend(matched_files)

        filenames.extend(sorted(set(station_files)))

    log_message(f"Total burst files found: {len(filenames)}")

    created_files = []
    for f in filenames:
        ctrl = make_ctrl(f, dm_config)
        if ctrl:
            created_files.append(ctrl)
            exper = os.path.basename(ctrl).split("_")[0]
            outdir = os.path.dirname(ctrl)

            if prepare_vex_flag:
                vix_file = prepare_vex(exper, outdir)
                if vix_file and torun_fix_flag:
                    fix_tr_vix_append(vix_file)

    log_message(f"Finished. Total .ctrl files created: {len(created_files)}")
    return created_files

# ---------------- MAIN ----------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate SFXC .ctrl files")
    parser.add_argument("--prepare-vex", action="store_true",
                        help="Copy and convert .vex to .vix for each burst folder")
    parser.add_argument("--torun-fix", action="store_true",
                        help="Fix USB/LSB mapping in Torun .vix files")
    parser.add_argument("-k", "--key", type=str, default="*",
                        help="Comma-separated filename patterns for bursts (e.g., p470*,m81*)")
    args = parser.parse_args()

    dm_config = load_dm_config()
    generate_all_ctrls(keys=args.key, dm_config=dm_config,
                       prepare_vex_flag=args.prepare_vex, torun_fix_flag=args.torun_fix)

