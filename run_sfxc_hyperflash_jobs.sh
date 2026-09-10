#!/usr/bin/env bash
#
# run_sfxc_hyperflash_jobs.sh
#
# Run SFXC and convert correlator output to filterbank for matching HyperFlash burst folders (one job at a time)
# Commands and status are logged per folder
# Usage:
#   ./run_sfxc_hyperflash_jobs.sh -b /path/to/sfxc_folders <folder_glob_pattern> [-t telescope]
# Examples:
#   ./run_sfxc_hyperflash_jobs.sh -b /data1/omar/sfxc/frb240114a "p470*"
#   ./run_sfxc_hyperflash_jobs.sh -b /data1/omar/sfxc/frb240114a "p470*" -t wb
#   ./run_sfxc_hyperflash_jobs.sh -b /mnt/storage/sfxc_jobs "p47018_24_wb_60369.37077"

NP=38  # number of MPI processes
BASE_DIR=""  # SFXC folder base (to be provided)

# --- Print help and exit ---
print_help() {
    echo "Usage: $0 -b /path/to/sfxc_folders <folder_glob_pattern> [-t telescope]"
    echo ""
    echo "Options:"
    echo "  -b, --base        Base directory containing SFXC subfolders"
    echo "  -t, --telescope   Optional telescope filter (wb, tr, o8)"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -b /data1/omar/sfxc/frb240114a \"p470*\""
    echo "  $0 -b /data1/omar/sfxc/frb240114a \"p470*\" -t wb"
    echo "  $0 -b /mnt/storage/sfxc_jobs \"p47018_24_wb_60369.37077\""
}

# --- Parse options ---
TELESCOPE_FILTER=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--base)
            BASE_DIR="$2"
            shift 2
            ;;
        -t|--telescope)
            TELESCOPE_FILTER="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            PATTERN="$1"
            shift
            ;;
    esac
done

# --- Validate inputs ---
if [[ -z "$BASE_DIR" || -z "$PATTERN" ]]; then
    echo "Error: Base directory and folder pattern are required."
    print_help
    exit 1
fi

if [[ ! -d "$BASE_DIR" ]]; then
    echo "Error: Base directory does not exist: $BASE_DIR"
    exit 1
fi

# --- Find folders matching glob ---
FOLDERS=($BASE_DIR/$PATTERN)
TOTAL=${#FOLDERS[@]}
COUNT=0

# --- Process each folder ---
for DIR in "${FOLDERS[@]}"; do
    [[ ! -d "$DIR" ]] && continue  # skip non-folders
    BASENAME=$(basename "$DIR")

    # Apply telescope filter if set
    if [[ -n "$TELESCOPE_FILTER" ]]; then
        if [[ "$BASENAME" != *"_$TELESCOPE_FILTER"_* ]]; then
            continue
        fi
    fi

    COUNT=$((COUNT+1))

    # Log file per folder
    LOG_FILE="$DIR/${BASENAME}_sfxc_cor2filterbank.log"
    echo "---------------------------------------------" | tee -a "$LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing folder $BASENAME" | tee -a "$LOG_FILE"

    # Find ctrl and vix files
    CTRL_FILE=$(find "$DIR" -maxdepth 1 -name "*.ctrl" | head -n1)
    VIX_FILE=$(find "$DIR" -maxdepth 1 -name "*.vix" | head -n1)

    if [[ -z "$CTRL_FILE" || -z "$VIX_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Skipping $BASENAME: missing .ctrl or .vix file" | tee -a "$LOG_FILE"
        continue
    fi

    echo "CTRL_FILE: $CTRL_FILE" | tee -a "$LOG_FILE"
    echo "VIX_FILE: $VIX_FILE" | tee -a "$LOG_FILE"

    # --- Run SFXC ---
    SFXC_CMD=(mpirun -np "$NP" --use-hwthread-cpus sfxc "$CTRL_FILE" "$VIX_FILE")
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] COMMAND: ${SFXC_CMD[*]}" | tee -a "$LOG_FILE"
    if "${SFXC_CMD[@]}"; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SFXC finished SUCCESS" | tee -a "$LOG_FILE"

        # --- Prepare correlator output ---
        COR_FILE=$(jq -r '.output_file' "$CTRL_FILE" | sed 's|file://||')
        TELESCOPE=$(echo "$BASENAME" | cut -d'_' -f3)
        TELESCOPE_CAP="${TELESCOPE^}"          # capitalize first letter
        COR_FILE="${COR_FILE}_${TELESCOPE_CAP}"
        FIL_FILE="${COR_FILE}.fil"

        echo "COR_FILE: $COR_FILE" | tee -a "$LOG_FILE"
        echo "FIL_FILE: $FIL_FILE" | tee -a "$LOG_FILE"

        # --- Run cor2filterbank ---
        CF_CMD=(cor2filterbank.py -s "$TELESCOPE_CAP" -p I "$VIX_FILE" "$COR_FILE" "$FIL_FILE")
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] COMMAND: ${CF_CMD[*]}" | tee -a "$LOG_FILE"
        if "${CF_CMD[@]}"; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] cor2filterbank SUCCESS" | tee -a "$LOG_FILE"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: cor2filterbank FAILED" | tee -a "$LOG_FILE"
        fi

    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: SFXC FAILED" | tee -a "$LOG_FILE"
    fi

    echo "---------------------------------------------" | tee -a "$LOG_FILE"
done

