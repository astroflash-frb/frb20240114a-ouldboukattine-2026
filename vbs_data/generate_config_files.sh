#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

echo "STARTING"

# --------------------------------------------------
# Paths (relative to repo root)
# --------------------------------------------------
VEX_SRC_DIR="/home/omar/git/schedules"
VEX_DST_DIR="./vex"
VBS_DIR="./vbs_data"
CONF_DIR="./confs"

VBS_BASE="/home/omar/git/r147-single-dish-analysis/vbs_data/"
# --------------------------------------------------
# Fixed create_config parameters
# --------------------------------------------------
NBITS=-32
NCHAN=512
NINT=20

# --------------------------------------------------
# Ensure output directories exist
# --------------------------------------------------
mkdir -p "${VEX_DST_DIR}"
mkdir -p "${CONF_DIR}"

# --------------------------------------------------
# Tracking
# --------------------------------------------------
declare -A scan_counter
declare -a skipped_missing_vex
declare -a skipped_pm_fail
declare -a processed_bursts

# --------------------------------------------------
# Step 1: Copy required .vex files
# --------------------------------------------------
echo "Copying .vex files..."
for expdir in "${VBS_DIR}"/*/; do    # note the trailing /
    exp=$(basename "${expdir}")
    vex_src="${VEX_SRC_DIR}/${exp}.vex"
    vex_dst="${VEX_DST_DIR}/${exp}.vex"

    if [[ -f "${vex_src}" ]]; then
        cp -u "${vex_src}" "${vex_dst}"
    else
        echo "WARNING: Missing vex file ${vex_src}"
    fi
done

# --------------------------------------------------
# Step 2: Loop over burst files and run create_config
# --------------------------------------------------
echo "Running create_config..."
for burstpath in "${VBS_DIR}"/*/*; do
    burst=$(basename "${burstpath}")
    exp=$(basename "$(dirname "${burstpath}")")

    # burst format: p47024_o8_no0032 or p47024_o8_no0032_02
    dish=$(echo "${burst}" | awk -F_ '{print $2}')
    scan_raw=$(echo "${burst}" | awk -F_ '{print $3}')

    # Extract scan number: no0032 → 32
    scan=$(echo "${scan_raw}" | sed -E 's/no0*//')

    # --------------------------------------------------
    # Source name (-s) logic
    # --------------------------------------------------
    case "${dish}" in
        wb|o8)
            source_name="R240114_D"
            ;;
        tr)
            source_name="R240121"
            ;;
        *)
            source_name="R240114_D"
            ;;
    esac

    vex_file="${VEX_DST_DIR}/${exp}.vex"

    if [[ ! -f "${vex_file}" ]]; then
        echo "Skipping ${burst}: missing ${vex_file}"
        skipped_missing_vex+=("${burst}")
        continue
    fi

    # --------------------------------------------------
    # Handle duplicate bursts in same scan
    # --------------------------------------------------
    key="${exp}_${dish}_scan${scan}"
    scan_counter["${key}"]=$(( ${scan_counter["${key}"]:-0} + 1 ))
    count=${scan_counter["${key}"]}

    if [[ "${count}" -eq 1 ]]; then
        conf_file="${CONF_DIR}/${exp}_${dish}_R147_scan${scan}.conf"
    else
        conf_file="${CONF_DIR}/${exp}_${dish}_R147_scan${scan}_${count}.conf"
    fi

    # --------------------------------------------------
    # Resolve symlink and extract plus-minus value
    # --------------------------------------------------
    target=$(readlink -f "${burstpath}")
    pm=$(echo "${target}" | sed -E 's/.*plus-minus_([0-9.]+)_seconds.*/\1/')

    if [[ -z "${pm}" ]]; then
        echo "WARNING: Could not extract plus-minus value for ${burst}"
        skipped_pm_fail+=("${burst}")
        continue
    fi

    # --------------------------------------------------
    # Default extraction: 5 seconds, centered
    # --------------------------------------------------
    lengths=5
    skip=$(awk -v x="${pm}" 'BEGIN { printf "%.1f", x - 2.5 }')

    # Special case: plus-minus 30 seconds → extract 25–35
    if awk "BEGIN {exit !(${pm} == 30)}"; then
        skip=25
        lengths=10
    fi

    echo "Processing ${burst}"
    echo "  experiment: ${exp}"
    echo "  dish:       ${dish}"
    echo "  source:     ${source_name}"
    echo "  scan:       ${scan}"
    echo "  instance:   ${count}"
    echo "  plus-minus: ${pm}"
    echo "  skip:       ${skip}"
    echo "  lengths:    ${lengths}"
    echo "  conf file:  ${conf_file}"

    # --------------------------------------------------
    # Run create_config
    # --------------------------------------------------
    create_config.py \
        -t "${dish}" \
        -s "${source_name}" \
        --keepVDIF \
        --keepBP \
        --nbit="${NBITS}" \
        -n "${NCHAN}" \
        -N "${NINT}" \
        -i "${vex_file}" \
        -S "${scan}" \
        -o "${conf_file}"

    # --------------------------------------------------
    # Patch config file
    # --------------------------------------------------
    sed -i -e "s/skips.*/skips=( ${skip} )/" "${conf_file}"
    sed -i -e "s/lengths.*/lengths=( ${lengths} )/" "${conf_file}"

    # --------------------------------------------------
    # Append vbsdir_base (only once)
    # --------------------------------------------------
    if ! grep -q "^vbsdir_base=" "${conf_file}"; then
        echo "vbsdir_base=${VBS_BASE}" >> "${conf_file}"
    fi

    # --------------------------------------------------
    # Track successful processing
    # --------------------------------------------------
    processed_bursts+=("${burst}")

done

# --------------------------------------------------
# Summary
# --------------------------------------------------
echo
echo "================ SUMMARY ================"
echo "Total bursts processed: ${#processed_bursts[@]}"
echo "Bursts skipped (missing vex): ${#skipped_missing_vex[@]}"
for b in "${skipped_missing_vex[@]}"; do echo "  - $b"; done
echo "Bursts skipped (plus-minus parse fail): ${#skipped_pm_fail[@]}"
for b in "${skipped_pm_fail[@]}"; do echo "  - $b"; done
echo "========================================"

