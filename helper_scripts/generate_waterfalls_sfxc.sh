#!/bin/bash
#
# Run waterfaller.py on all burst .fil files for a given telescope filter
# Usage:
#   ./run_waterfallers.sh [filter]
# Example:
#   ./run_waterfallers.sh wb
#   ./run_waterfallers.sh tr
#   ./run_waterfallers.sh o8
#   ./run_waterfallers.sh         # runs on all folders
#

# --- Configuration ---
BASE_DIR="/data1/omar/sfxc/frb240114a"

# Optional filter, e.g. wb / tr / o8
FILTER="${1:-*}"  # default: no filter (runs on all)

# Construct search pattern
PATTERN="${BASE_DIR}/*${FILTER}*/"

echo "=== Running waterfaller for pattern: ${PATTERN} ==="
echo "=== Base directory: ${BASE_DIR} ==="
echo

# Loop over matching folders
for d in $PATTERN; do
    # Skip if not a directory
    [ -d "$d" ] || continue

    fil=$(find "$d" -maxdepth 1 -type f -name "*.fil" | head -n 1)
    if [ -z "$fil" ]; then
        echo "⚠️  No .fil file found in $d"
        continue
    fi

    outname="${d%/}/${d##*/}_waterfall.png"

    # Skip if already processed
    if [ -f "$outname" ]; then
        echo "✅ Already processed ${d##*/}"
        continue
    fi

    echo "🎨 Running waterfaller on $fil → $outname"
    waterfaller.py --show-ts --show-start-isot \
        -T 0.2 -t 2.2 --full_info \
        --colour-map=viridis --downsamp=4 -s 256 \
        -o "$outname" "$fil"

    echo
done

echo "✅ Done!"

