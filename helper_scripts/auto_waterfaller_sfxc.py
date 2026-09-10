#!/usr/bin/env python3

import numpy as np
from pathlib import Path
import json
import subprocess
from tqdm import tqdm
import argparse
import your
import frb_functions

# --- Argument parser ---
parser = argparse.ArgumentParser(description="Automatically run waterfaller.py on bursts")
parser.add_argument("--force", action="store_true", help="Force rerun of all PNGs, even if they exist")
parser.add_argument("--telescope", type=str, default="*wb*", help="Telescope filter (e.g., '*wb*', '*tr*', '*o8*', or '*')")
parser.add_argument("--keyword", type=str, default=None, help="Filter bursts by keyword in folder name")
parser.add_argument("--twindow", type=float, default=0.2, help="Default duration of waterfall window in seconds for new bursts")
parser.add_argument("--downsamp", type=int, default=8, help="Downsampling factor for time and frequency")
args = parser.parse_args()

force_rerun = args.force
telescope_filter = args.telescope
keyword_filter = args.keyword
t_window_default = args.twindow
downsamp = args.downsamp

# --- Configuration ---
base_dir = Path("/data1/omar/sfxc/frb240114a")
output_json = Path("/home/omar/git/r147-single-dish-analysis/helper_scripts/burst_times.json")

# Plotting options
colour_map = "viridis"
s_size = 256
show_ts = True
show_start_isot = True

# --- Find burst folders ---
burst_folders = sorted([f for f in base_dir.glob(telescope_filter) if f.is_dir()])

# Apply optional keyword filter
if keyword_filter:
    burst_folders = [f for f in burst_folders if keyword_filter in f.name]

if not burst_folders:
    print("⚠️ No burst folders found with the given telescope filter and keyword.")
    exit()

# --- Load or create JSON ---
if output_json.exists():
    with open(output_json, "r") as f:
        burst_times = json.load(f)
    print(f"✅ Loaded existing JSON with {len(burst_times)} bursts.")
else:
    burst_times = {}
    print("⚠️ JSON does not exist. Will compute peaks and create it.")

# --- Loop over bursts ---
for folder in tqdm(burst_folders, desc="Processing bursts"):

    burst_name = folder.name
    fil_files = list(folder.glob("*.fil"))
    if not fil_files:
        print(f"⚠️ No .fil file in {burst_name}, skipping.")
        continue
    fil = fil_files[0]

    outname = folder / f"{burst_name}_waterfall.png"
    #if outname.exists() and not force_rerun:
    #    print(f"✅ Already processed {burst_name}, skipping PNG generation.")
    #    continue

    # --- Compute peak if not in JSON ---
    if burst_name not in burst_times:
        burst = your.Your(str(fil))
        header_dict = frb_functions.your_header_to_dict(burst)
        tsamp_orig = header_dict["tsamp"]
        nbins = header_dict["nspectra"]
        fsamp = abs(header_dict["foff"])

        # Load raw data
        stokes_i = frb_functions.get_data(burst, nstart=0, nsamp=nbins, npoln=1)

        # Downsample for peak detection only
        stokes_i_down = frb_functions.downsample(stokes_i, freqf=downsamp, timef=downsamp)
        tsamp_down = tsamp_orig * downsamp

        # Compute profile
        prof = np.mean(stokes_i_down, axis=0)

        # Find peak index in downsampled profile
        peak_idx_down = np.argmax(prof)

        # Convert peak index back to original file time
        peak_time_orig = peak_idx_down * tsamp_down

        burst_times[burst_name] = {"peak": peak_time_orig, "T": t_window_default}

        # Save JSON after each new burst
        with open(output_json, "w") as f:
            json.dump(burst_times, f, indent=2)
        print(f"📄 Added {burst_name} to JSON (peak at {peak_time_orig:.3f}s).")

    # --- Get peak and T from JSON ---
    peak = burst_times[burst_name]["peak"]
    t_window = burst_times[burst_name]["T"]

    # Compute start dynamically so peak is centered
    t_start = max(0, peak - t_window / 2)

    # --- Run waterfaller.py ---
    cmd = ["waterfaller.py"]
    if show_ts:
        cmd.append("--show-ts")
    if show_start_isot:
        cmd.append("--show-start-isot")
    cmd += [
        "-T", f"{t_start}",           # start time of plot (seconds into observation)
        "-t", f"{t_window}",          # duration of plot (seconds)
        "--full_info",
        "--colour-map", colour_map,
        "--downsamp", str(downsamp),
        "-s", str(s_size),
        "-o", str(outname),
        str(fil)
    ]
    print(f"🎨 Running {burst_name}: peak={peak:.3f}s → {outname.name}")
    subprocess.run(cmd)

print(f"✅ Done! Burst info saved to {output_json}")

