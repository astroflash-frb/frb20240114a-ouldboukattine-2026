#!/usr/bin/env python3
"""
Check that source Source name in .ctrl and .vix files match
to ensure SFXC will apply coherent dedispersion correctly.

Usage:
    python check_vix_ctrl.py -key "p470*"
    python check_vix_ctrl.py -key "p55*"

Notes:
- $SOURCE in the .vix is assumed to be enclosed between lines of asterisks (*------).
- The .vix file is always considered correct; .ctrl files are compared against it.
- Prints ✅ OK or ❌ MISMATCH with (helpful) details.
"""

import os
import json
import re
import argparse
import glob
from fnmatch import fnmatch

# Default base directory
BASE_DIR = "/data1/omar/sfxc/frb240114a"

# Regex: extract block between *---- and next *---- that contains "$SOURCE;"
SOURCE_SECTION_RE = re.compile(
    r"\*[-]+\n\s*\$SOURCE;([\s\S]*?)\*[-]+", re.MULTILINE
)
# Extract each defined source within the block
SOURCE_DEF_RE = re.compile(r"def\s+([A-Za-z0-9_\+\-]+);")


# ------------------------------------------------
#                 HELPER FUNCTIONS
# ------------------------------------------------

def extract_source_from_vix(vix_path):
    """Return list of defined sources in a .vix file (only from $SOURCE block)."""
    try:
        with open(vix_path, "r") as f:
            text = f.read()
    except Exception as e:
        print(f"⚠️ Could not read VIX file {vix_path}: {e}")
        return []

    match = SOURCE_SECTION_RE.search(text)
    if not match:
        return []

    block = match.group(1)
    return SOURCE_DEF_RE.findall(block)


def extract_source_from_ctrl(ctrl_path):
    """Return the pulsar/source name from .ctrl JSON."""
    try:
        with open(ctrl_path, "r") as f:
            data = json.load(f)
    except Exception as e:
        print(f"⚠️ Could not read CTRL file {ctrl_path}: {e}")
        return None

    pulsars = data.get("pulsars", {})
    if not pulsars:
        return None
    return list(pulsars.keys())[0]


def check_folder(folder):
    """Compare .ctrl and .vix source names in a given folder."""
    ctrl_files = [f for f in os.listdir(folder) if f.endswith(".ctrl")]
    vix_files = [f for f in os.listdir(folder) if f.endswith(".vix")]
    if not ctrl_files or not vix_files:
        return None

    ctrl_path = os.path.join(folder, ctrl_files[0])
    vix_path = os.path.join(folder, vix_files[0])

    ctrl_source = extract_source_from_ctrl(ctrl_path)
    vix_sources = extract_source_from_vix(vix_path)

    return ctrl_path, vix_path, ctrl_source, vix_sources


def print_result(ok, folder, ctrl_source, vix_sources, vix_path):
    """Pretty-print match or mismatch."""
    if ok:
        print(f"✅ OK in {folder}: {ctrl_source}")
    else:
        print(f"\n❌ MISMATCH in {folder}")
        print(f"   CTRL source : {ctrl_source}")
        if vix_sources:
            print(f"   VIX sources : {', '.join(vix_sources)}")
        else:
            print("   VIX sources : [none found in $SOURCE block]")
        print(f"   vix file    : {vix_path}")

        # Suggest similar VIX source (prefix match)
        suggestion = None
        for s in vix_sources:
            if ctrl_source and s[:3] == ctrl_source[:3]:
                suggestion = s
                break
        if suggestion:
            print(f"   💡 Suggestion: maybe you meant '{suggestion}'?")
        else:
            print("   ⚠️ No similar source found in VIX file.")


# ------------------------------------------------
#                      MAIN
# ------------------------------------------------

def main(base_dir, key_pattern=None):
    mismatches = []
    checked = 0

    subdirs = sorted([d for d in glob.glob(os.path.join(base_dir, "*")) if os.path.isdir(d)])
    if key_pattern:
        subdirs = [d for d in subdirs if fnmatch(os.path.basename(d), key_pattern)]

    if not subdirs:
        print(f"No matching folders found for pattern '{key_pattern}' in {base_dir}")
        return

    for folder in subdirs:
        result = check_folder(folder)
        if not result:
            continue
        checked += 1
        ctrl_path, vix_path, ctrl_source, vix_sources = result

        ok = ctrl_source in vix_sources
        print_result(ok, folder, ctrl_source, vix_sources, vix_path)

        if not ok:
            mismatches.append(folder)

    # --- summary ---
    print("\nSummary:")
    print(f"Checked {checked} folders")
    print(f"Mismatches: {len(mismatches)}")
    if mismatches:
        for m in mismatches:
            print(f" - {m}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Check .ctrl vs .vix source name consistency")
    parser.add_argument("-key", default="*", help="Glob-style key pattern (e.g. p470*, p55*)")
    parser.add_argument("--base-dir", default=BASE_DIR, help="Base directory to scan")
    args = parser.parse_args()
    main(args.base_dir, args.key)

