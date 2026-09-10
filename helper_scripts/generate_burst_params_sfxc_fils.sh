#!/usr/bin/env bash

# -------------------------------
# Generate burst_params_sfxc.txt
# -------------------------------

BASE_DIR="/data1/omar/sfxc/frb240114a"
MIDDLE_JSON="/home/omar/git/r147-single-dish-analysis/helper_scripts/burst_times.json"
OUTFILE="burst_params_sfxc.txt"

# Reset output file
> "$OUTFILE"

echo "# exp    dish scan band DM       direc                       middle cepoch filterbank" >> "$OUTFILE"
echo "# Band = L always" >> "$OUTFILE"

# Temporary file to store bursts for sorting
TMPFILE=$(mktemp)

# Counters
count_bursts=0
count_skipped=0
skipped_dirs=()

# -------------------------------
# Loop over subdirectories
# -------------------------------
for dir in "$BASE_DIR"/*/; do
    dir=${dir%/}  # remove trailing slash

    # Pick only .fil files with 64us / 125KHz
    selected_fil=$(find "$dir" -maxdepth 1 -type f -name "*_64us_125KHz_*.fil" | head -n1)
    
    if [[ -z "$selected_fil" ]]; then
        echo "WARNING: No 64us/125KHz .fil found in directory $dir" >&2
        skipped_dirs+=("$dir")
        count_skipped=$((count_skipped+1))
        continue
    fi

    base=$(basename "$selected_fil")
    direc=$(basename "$dir")
    exp=$(echo "$direc" | cut -d'_' -f1)
    scan=$(echo "$direc" | cut -d'_' -f2)
    dish=$(echo "$direc" | cut -d'_' -f3)
    band="L"

    # --- DM formatting ---
    dm_raw=$(echo "$base" | sed -E 's/.*_DM([0-9]+)\.cor.*/\1/')
    int_part=${dm_raw:0:3}
    frac_part=${dm_raw:3}
    dm="${int_part}.${frac_part}"

    # --- middle from JSON ---
    middle_raw=$(jq -r --arg key "$direc" '.[$key].peak' "$MIDDLE_JSON")
    [[ "$middle_raw" == "null" ]] && middle_raw=0
    middle=$(printf "%.2g" "$middle_raw")

    # --- initial CEPOCH ---
    cepoch_s="0.0"

    # Prepare formatted line (no quotes, no backslash)
    line=$(printf "%-8s %-4s %-4s %-2s %-7s %-25s %-6s %-5s %s" \
        "$exp" "$dish" "$scan" "$band" "$dm" "$direc" "$middle" "$cepoch_s" "$base")

    # Store in TMPFILE with dish for sorting
    echo "$dish|$line" >> "$TMPFILE"
    count_bursts=$((count_bursts+1))
done

# -------------------------------
# Sort by telescope: wb → o8 → tr
# -------------------------------
awk -F"|" '{
    if ($1=="wb") key=0
    else if ($1=="o8") key=1
    else if ($1=="tr") key=2
    else key=9
    print key "|" $2
}' "$TMPFILE" | sort -t"|" -k1,1n | cut -d"|" -f2 > "${TMPFILE}_sorted"

# -------------------------------
# Write final output, commented with #, keep separator every 10 bursts with cumulative count
# -------------------------------
count=0
while IFS= read -r line; do
    count=$((count+1))
    echo "# $line" >> "$OUTFILE"
    if (( count % 10 == 0 )); then
        echo "################# $count" >> "$OUTFILE"
    fi
done < "${TMPFILE}_sorted"

# Clean up temp files
rm "$TMPFILE" "${TMPFILE}_sorted"

# -------------------------------
# Summary
# -------------------------------
echo ""
echo "Summary:"
echo "Total bursts processed: $count_bursts"
echo "Total bursts skipped (no 64us/125KHz .fil): $count_skipped"

if [[ ${#skipped_dirs[@]} -gt 0 ]]; then
    echo "Skipped directories:"
    for d in "${skipped_dirs[@]}"; do
        echo "  $d"
    done
fi

echo "Generated $OUTFILE with bursts sorted by telescope, 2-digit middle, commented lines, and numbered separators every 10 bursts."

