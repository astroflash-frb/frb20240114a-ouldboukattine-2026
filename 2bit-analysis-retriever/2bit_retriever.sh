#!/bin/bash

# === CONFIG ===
MANIFEST_DIR="/home/omar/git/r147-single-dish-analysis/2bit-retriever/manifests"
DEST="tapearchive:/home/oboukattine/astroflash/archive/sleipnir/obs_downsamp/"
SOURCE_BASE="/data1/omar/2bit_r147_data"
LOG_DIR="$MANIFEST_DIR/transfer_logs"
BATCH_SIZE=20  # Number of files per batch
mkdir -p "$LOG_DIR"

MASTER_LOG="$LOG_DIR/master_transfer.log"
touch "$MASTER_LOG"

# Loop over each manifest
for mf in "$MANIFEST_DIR"/*manifest_*.txt; do
    echo "=== Processing manifest: $mf ===" | tee -a "$MASTER_LOG"

    # Split manifest into batches of BATCH_SIZE lines
    split_prefix="$LOG_DIR/batch_$(basename "$mf" .txt)_"
    split -l "$BATCH_SIZE" -d --additional-suffix=.txt "$mf" "$split_prefix"

    # Loop over batch files
    for batch_file in "$LOG_DIR"/batch_*.txt; do
        batch_base=$(basename "$batch_file" .txt)
        LOG_FILE="$LOG_DIR/${batch_base}_transfer.log"

        # Skip already transferred batches
        if [ -f "$LOG_FILE" ]; then
            echo "Skipping already transferred batch: $batch_file" | tee -a "$MASTER_LOG"
            continue
        fi

        # Transfer batch
        echo "Transferring batch: $batch_file" | tee -a "$MASTER_LOG"
        rsync -av -R --progress --files-from="$batch_file" "$DEST" "$SOURCE_BASE" | tee "$LOG_FILE" >> "$MASTER_LOG"

        echo "Batch $batch_file completed. Log: $LOG_FILE" | tee -a "$MASTER_LOG"
    done
done

echo "All transfers completed. Master log: $MASTER_LOG"
