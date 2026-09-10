#!/bin/bash

# -------------------------------
# Generate archive files from burst_params_sfxc.txt
# -------------------------------

BASEDIR="/data1/omar/sfxc/frb240114a"
ARCHIVE_DIR="/fil_to_archives"
BURST_FILE="burst_params_sfxc.txt"

OUTDIR_ARCHIVE=${BASEDIR}/${ARCHIVE_DIR}
mkdir -p "$OUTDIR_ARCHIVE"

# -------------------------------
# Loop over each line in the burst file
# -------------------------------
while IFS= read -r line; do
    # Skip lines starting with # (commented bursts)
    [[ "$line" =~ ^# ]] && continue

    # Read the line into variables
    # 'extra' captures optional D flag
    read -r exp dish scan band dm direc middle_b cepoch_s filterbank extra <<< "$line"

    # Optional: Only process bursts marked with D
    # [[ "$extra" != "D" ]] && continue

    echo "Processing burst: $filterbank"

    # --- Archive parameters ---
    #PBAND
    #lenght_archive=1.048576   # 2**16 * 8e-6
    #time_res=0.000256          # original time resolution
    
    #LBAND
    lenght_archive=0.524288   # 2**16 * 8e-6
    #time_res=0.000064          # original time resolution
    time_res=0.000512

    filterbank_in_dir=${BASEDIR}/${direc}/${filterbank}
    #filterbank_in_dir=${BASEDIR}/${filterbank}
    archive_out_nm=${OUTDIR_ARCHIVE}/${filterbank//./_}

    # Number of bins
    nbins=$(echo "${lenght_archive}/${time_res}" | bc -l | cut -d '.' -f1)
    # Start time
    start_b=$(echo "${middle_b} - ${lenght_archive}/2" | bc -l)
    # CEPOCH in MJD
    cepoch_mjd=$(echo "(( ${cepoch_s} / ( 24 * 3600 ) ))" | bc -l | sed -e 's/^-\./-0./' -e 's/^\./0./')

    # --- Run dspsr ---
    dspsr_cmd="dspsr -c ${lenght_archive} -T ${lenght_archive} -S ${start_b} -b ${nbins} -cepoch ${cepoch_mjd} -O ${archive_out_nm} ${filterbank_in_dir}"
    echo "$dspsr_cmd"
    $dspsr_cmd

    archive_out_nm_ar=${archive_out_nm}.ar

    # --- Check archive properties ---
    pars=$(psredit -q -Q -c nbin,length,npol,nchan,bw "${archive_out_nm_ar}")
    IFS=" " read -r nbin length npol nchan bw <<< "$pars"

    # Convert bandwidth to Hz
    bw=$(echo "$bw * 1000000" | bc | cut -d '.' -f1)
    [[ $bw -lt 0 ]] && bw=$(echo "$bw * -1" | bc)

    # Convert length to microseconds and calculate time/freq resolution
    length=$(echo "$length*1000000" | bc)
    time_res=$(echo "$length/$nbin" | bc)
    freq_res=$(echo "$bw/$nchan" | bc)

    echo "length=${length}, nbin=${nbin}, npol=${npol}"
    echo "nchan=${nchan}, bw=${bw}, time_res=${time_res}, freq_res=${freq_res}"
    
    if [[ $((${time_res} % 2)) != 0 ]]; then
        echo ""
        echo "###########################################"
        echo "!!! ALERT: Time resolution is not even !!!"
        echo "Burst: $filterbank"
        echo "Current time_res = $time_res"
        echo "Check start time for dspsr!"
        echo "###########################################"
        echo ""
    fi

    # --- Add DM and dmc flags ---
    psredit -m -c dm="${dm}" "${archive_out_nm_ar}"
    psredit -m -c dmc=1 "${archive_out_nm_ar}"

    # --- Diagnostic plots ---
    time_down=8
    freq_down=4
    freq_res_khz=$(echo "${freq_res}/1000" | bc)
    plt_time_res=$(echo "$time_res*$time_down" | bc)
    plt_freq_res=$(echo "$freq_res_khz*$freq_down" | bc)

    echo "Making diagnostic plot with time_res=${plt_time_res} us and freq_res=${plt_freq_res} kHz"
    psrplot -pfreq+ -c x:unit=s -D /CPS -jpDT -j "F x${freq_down}" -j "B x${time_down}" "${archive_out_nm_ar}"

    # Rename plot file
    new_name_t=${archive_out_nm_ar/${time_res}"us"/${plt_time_res}"us"}
    new_name_tf=${new_name_t/${freq_res_khz}"KHz"/${plt_freq_res}"KHz"}
    mv pgplot.ps "${new_name_tf}.ar.ps"

done < "$BURST_FILE"

