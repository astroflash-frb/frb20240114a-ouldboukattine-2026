#!/usr/bin/env bash

# -------------------------------
# Generate burst_params_spc.txt
# -------------------------------

BASE_DIR="/data1/omar/sfxc/frb240114a"
OUTFILE="burst_params_spc.txt"

# Hardcoded values
DM="527.7"
BW="\${bw128}"       # keep as literal string for spc input
SUBBW="\${subbw16}"  # keep as literal string
CEPOCH="0.0"
SCALING="0.50"

# Reset output file
> "$OUTFILE"

echo "# exp - dish - scan - bw - subbandbw - cepoch_s - scaling factor for spc" >> "$OUTFILE"

# Temporary file to store bursts for sorting
TMPFILE=$(mktemp)

# Counters
count_bursts=0
skipped_dirs=()

# -------------------------------
# Loop over subdirectories
# -------------------------------
for dir in "$BASE_DIR"/*/; do
    dir=${dir%/}  # remove trailing slash

    direc=$(basename "$dir")
    exp=$(echo "$direc" | cut -d'_' -f1)
    scan=$(echo "$direc" | cut -d'_' -f2)
    dish=$(echo "$direc" | cut -d'_' -f3)

    # Prepare formatted line for spc
    line=$(printf "%-8s %-4s %-4s %-7s %-10s %-7s %-5s" \
        "$exp" "$dish" "$scan" "$DM" "$BW" "$SUBBW" "$CEPOCH $SCALING")

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
echo "Generated $OUTFILE with bursts sorted by telescope, commented lines, and numbered separators every 10 bursts."

