#!/bin/bash

# Ould-Boukattine (2025/2026)
# Ould-Boukattine (2025)
# Kirsten & Ould-Boukattine (2023) 
# Script takes the cut out filterbank files as provided by Wolfgang and converts them to archive files with the burst in the middle

# The time sampling of Stockert: 218.45333 us, we create the archive file to be 4098 bins
# This will yield an archive file with lenght: 0.894783488 seconds 
# 0.4 sec either side of the burst and the sweep is ~0.27 sec

# The script also checks if the final time resoltuon is a factor of 2, if this is not the case (i.e. 7.999us-bins) for example
# Then this can be solved by changing the start_time of the archive file (by 0,01), it's behavior I suspect has to do with rounding of start time

# dont forget the extra space at the end of the line, before the \, otherwise it won't run
# middle = location of the burst in the sfxc filterbank, assumed that the burst is at the 0.5 seconds mark
# cepoch = shift to left in seconds

# logs
# 

runs=( \
# middle cepoch_s filterbank
#"1.0 0.31 snip60357.3437816.fbspi.fil D" \
#"1.0 0.49 snip60357.4385230.fbspi.fil D-pazi" \
#"1.0 0.78 snip60361.5475088.fbspi.fil D" \
#"1.0 0.85 snip60366.3461485.fbspi.fil D" \
#"1.0 0.65 snip60369.3359967.fbspi.fil D" \
#"1.0 0.18 snip60371.2798981.fbspi.fil D" \
#"1.0 0.62 snip60372.5113801.fbspi.fil D" \
#"1.0 0.40 snip60373.4876754.fbspi.fil D" \
#"1.0 0.88 snip60373.5456450.fbspi.fil D" \
#"1.0 0.64 snip60374.3189053.fbspi.fil D" \
###10
#"1.0 0.02 snip60375.2980335.fbspi.fil D" \
#"1.0 0.54 snip60375.3037769.fbspi.fil D" \
#"1.0 0.72 snip60375.4292868.fbspi.fil D" \
#"1.0 0.28 snip60375.4311251.fbspi.fil D-pazi" \
#"1.4 0.12 snip60375.4726520.fbspi.fil D-pazi" \
#"1.0 0.45 snip60376.3217991.fbspi.fil D" \
#"1.0 0.85 snip60376.3316630.fbspi.fil D" \
#"1.0 0.23 snip60377.2533142.fbspi.fil D-pazi" \
#"1.0 0.74 snip60377.3150949.fbspi.fil D" \
#"1.0 0.25 snip60377.3732605.fbspi.fil D-pazi" \
###20
#"1.0 0.00 snip60377.4371665.fbspi.fil D" \
#"1.0 0.00 snip60377.4588314.fbspi.fil D" \
#"1.0 0.50 snip60377.6264129.fbspi.fil D-pazi-weak" \
#"1.0 0.48 snip60378.2170109.fbspi.fil D" \
#"1.0 0.00 snip60378.3133708.fbspi.fil D" \
#"1.0 0.32 snip60378.4604753.fbspi.fil D-pazi" \
#"1.0 0.73 snip60379.2275323.fbspi.fil D-StrongRFI" \
#"1.0 0.80 snip60379.2555746.fbspi.fil D" \
#"1.0 0.10 snip60379.2602165.fbspi.fil D-pazi" \
#"1.0 0.25 snip60379.2695980.fbspi.fil D" \
###30
#"1.0 0.50 snip60379.3517707.fbspi.fil D" \
#"1.0 0.40 snip60379.4008061.fbspi.fil D" \
#"1.0 0.70 snip60379.5397914.fbspi.fil D" \
#"1.0 0.30 snip60380.2760984.fbspi.fil D" \
#"1.0 0.25 snip60380.3969765.fbspi.fil D" \
#"1.0 0.05 snip60380.3998840.fbspi.fil D-pazi" \
#"1.0 0.20 snip60380.4319492.fbspi.fil D-bright" \
#"1.0 0.65 snip60380.4447753.fbspi.fil D" \
#"1.0 0.85 snip60380.4521409.fbspi.fil D-bright" \
#"1.0 0.57 snip60380.5269620.fbspi.fil D-pazi" \
###40
#"1.0 0.20 snip60380.5962205.fbspi.fil D-RFI on the right" \
#"1.0 0.35 snip60381.1949711.fbspi.fil D-pazi" \
#"1.0 0.28 snip60381.2067454.fbspi.fil D" \
#"1.0 0.80 snip60381.2191585.fbspi.fil D-pazi" \
#"1.0 0.75 snip60381.3044108.fbspi.fil D" \
#"1.0 0.29 snip60381.4497249.fbspi.fil D" \
#"1.0 0.35 snip60381.4719812.fbspi.fil D" \
#"1.0 0.43 snip60382.4597962.fbspi.fil D" \
#"1.0 0.00 snip60382.5860243.fbspi.fil D-pazi" \
#"1.0 0.25 snip60383.2684445.fbspi.fil D-pazi" \
###50
#"1.0 0.20 snip60383.3537691.fbspi.fil D-pazi" \
#"1.5 0.50 snip60384.4111808.fbspi.fil D-starttime" \
#"1.0 0.75 snip60386.4857456.fbspi.fil D-pazi-strongRFI" \
#"1.0 0.23 snip60387.3671739.fbspi.fil D" \
#"1.0 0.10 snip60388.4505749.fbspi.fil D" \
#"1.0 0.77 snip60390.2765210.fbspi.fil D" \
#"1.0 0.83 snip60390.4257662.fbspi.fil D" \
#"1.0 0.85 snip60391.5690699.fbspi.fil D" \
#"1.0 0.65 snip60392.5928489.fbspi.fil D" \
#"1.0 0.10 snip60393.5544964.fbspi.fil D" \
###60
#"1.0 0.00 snip60394.3474146.fbspi.fil D-pazi" \
#"1.0 0.10 snip60394.5868739.fbspi.fil D" \
#"1.0 0.87 snip60396.2482285.fbspi.fil D" \
#"1.0 0.19 snip60424.4337451.fbspi.fil D-pazi" \
#"1.0 0.60 snip60425.4424318.fbspi.fil D-pazi" \
#"0.72 0.05 snip60431.4377754.fbspi.fil D-starttime" \
#"1.0 0.65 snip60433.2247390.fbspi.fil D" \
#"1.0 0.40 snip60458.0742204.fbspi.fil D" \
#"1.0 0.63 snip60803.2202071.fbspi.fil D" \
###69
)

#Create directory for the archive files
basedir=/data1/omar/sfxc/frb240114a
archive_dir=/fil_to_archives_stockert

fil_dir=/scratch1/baseband_extractions/r147/stockert

# Path to zap list file (contains full paz commands)
zap_file_list="/home/omar/git/r147-single-dish-analysis/zap_channels_stockert.txt"

outdir_archive=${basedir}/${archive_dir}
if ! [ -d ${outdir_archive} ];then
    mkdir -p ${outdir_archive}
fi

#Define constants
dm=527.7
#218.453333333333
time_res=0.000218453 #time_resolution of the stockert recording
lenght_archive=0.894783488 #fixed, 4096 bins, see above
#lenght_archive=0.447391744 #fixed, 2048 bins, see above

#calculate the number of bins based on the lenght and time_res
nbins=`echo "${lenght_archive}/${time_res}" | bc -l | cut -d '.' -f1`

for run in "${runs[@]}";do

    #Read the run line using the read function
    read -r -a info <<< "${run}"
    middle_b="${info[0]}"
    cepoch_s="${info[1]}"
    filterbank="${info[2]}"

    #Start time of the archive file
    start_b=`echo "${middle_b} - ${lenght_archive}/2" | bc -l`

    #From documentation of CEPOCH
    #To specify a different epoch (e.g. the middle of the observation) use the EPOCH key with value specified as MJD.
    #So we convert from seconds to MJD to define the shift to left.
    #In order for CEPOCH to work you need a 0. infront of the number, so using sed we add a 0, see link below
    cepoch_mjd=`echo "(( ${cepoch_s} / ( 24 * 3600 ) ))" | bc -l | sed -e 's/^-\./-0./' -e 's/^\./0./'`

    echo "${exp} ${dish} ${scan} ${direc} ${cepoch_mjd} ${filterbank}"

    filterbank_in_dir=${fil_dir}/${filterbank}
    archive_out_nm=${outdir_archive}/${filterbank/./_}
    echo $archive_out_nm

    #runnig dspsr to create an archive file
    #need to set machine as fake, otherwise we get an error regarding the processing machine pulsar2000 having to long a lenght
    dspsr_cmd="dspsr -set machine=fake -D ${dm} -c ${lenght_archive} -T ${lenght_archive} -S ${start_b} -b ${nbins} -cepoch ${cepoch_mjd} -O ${archive_out_nm} ${filterbank_in_dir}"
    echo $dspsr_cmd
    ${dspsr_cmd}

    #Name of the archive file with extension
    archive_out_nm_ar=${archive_out_nm}.ar

    #In case the RFI is so bad and you need to zap channels in order to see them in the diagnostic plot
    #First use the Pazi tool to figure our the channels, add them here below between "" and the script will zap them and the diagnostic plot will be updated accordinly.
    # Look up zap command matching this archive
    archive_name=$(basename ${archive_out_nm_ar})
    zap_line=$(grep "$archive_name" "$zap_file_list" || true)

    if [ -n "$zap_line" ]; then
        echo "Applying zap from zap_channels_stockert.txt for ${archive_name}:"
        echo "$zap_line"

        # Replace filename in zap command with the actual path
        zap_line=$(echo "$zap_line" | sed "s|${archive_name}|${archive_out_nm_ar}|")

        # Run the zap command
        eval "$zap_line"

        archive_out_nm_ar=${archive_out_nm}.pazi
    else
        echo "No zap command found for ${archive_name}, skipping zapping."
    fi

    #A check to see if the the amount of bins and output time is correct
    pars=`psredit -q -Q -c nbin,length,npol,nchan,bw ${archive_out_nm_ar}`
    IFS=" " read -r -a params <<< "${pars}"
    nbin="${params[0]}"
    length="${params[1]}"  # comes in seconds
    npol="${params[2]}"
    nchan="${params[3]}"
    bw="${params[4]}" # in MHz, -ve

    # bash cannot handle floats, so convert bw to an integer in Hz
    bw=`echo "${bw}*1000000" | bc | cut -d '.' -f1`
    if [[ ${bw} -lt 0 ]]; then
        bw=`echo ${bw}*-1 | bc`
    fi
    # convert length to microseconds
    length=`echo "${length}*1000000" | bc`
    time_res=`echo "${length}/${nbin}" | bc`
    freq_res=`echo "${bw}/${nchan}" | bc`
    echo "length=${length}, nbin=${nbin}, npol=${npol}"
    echo "nchan=${nchan}, bw=${bw}"
    echo "time_res=${time_res}, freq_res=${freq_res}"

    if [[ $((${time_res} % 2)) != 0 ]]; then
        echo "ALERT ALERT ALERT LOOK AT THE START TIME, current time res is: $time_res"
        continue
    fi
     
    #Downsample factor for diagnostic plots
    time_down=8
    freq_down=2
    
    freq_res_khz=`echo "${freq_res}/1000" | bc` #convert to khz

    #Generate the new time- and freq resoltuon
    plt_time_res=`echo "$time_res*$time_down" | bc` #us
    plt_freq_res=`echo "$freq_res_khz*$freq_down" | bc` #khz
    echo "Making a diagnostic plot with time_res=${plt_time_res} us and freq_res=${plt_freq_res} hz"

    psrplot -pfreq+ -c x:unit=s -D /CPS -jpDT -j 'F x'"${freq_down}" -j 'B x'"${time_down}" ${archive_out_nm_ar}

    #${parameter//pattern/string}
    #Replace the old time and freq-res with the new in the archive string
    #Only search for time_res+us, otherwise you will also replace numbers in the scan
    new_name_t=`echo "${archive_out_nm_ar/${time_res}"us"/${plt_time_res}"us"}"`
    new_name_tf=`echo "${new_name_t/${freq_res_khz}"KHz"/${plt_freq_res}"KHz"}"`
    #echo "${new_name_tf}"
    mv pgplot.ps ${new_name_tf}.ar.ps

done

#Regarding the sed expression
#https://stackoverflow.com/questions/8402181/how-do-i-get-bc1-to-print-the-leading-zero

#making into a ps plot
#psrplot -pfreq+ -c x:unit=s -D /CPS -jpDT -j 'F x4' -j 'B x8' ${outdir}/${ar_scale}
#mv pgplot.ps ${outdir}/${ar_scale}.ps

#Selecting all filterbanks for in this file
#ls *.fil | sort -t '/' -k 4 | sed -e 's;^;#"0.5 0.0 ;' | sed '$!s/$/" \\/'
#for fil in *.fil; do echo "#\"1.0 0.0 $fil\" \\";done

#pazi command:
#paz -z "122 123 124 97 98 99 117 118" -e pazi snip60357_4385230.fbspi.fil.ar
#paz -z "154 155 156" -e pazi snip60375_2980335.fbspi.fil.ar
#paz -z "94 95 125 126 132 133 116 106 105 162 163 164" -e pazi snip60375_4311251.fbspi.fil.ar
#paz -z "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16" -e pazi snip60375_4726520.fbspi.fil.ar
#paz -z "128 129 70 71 72 73 74 137 138 125 119 120 121 116 115 112 113 104 105 98 99 162 163 126" -e pazi snip60377_2533142.fbspi.fil.ar
#paz -z "131 132 133 123 127 135 136 111 112 109 110 94 95 96 108 136 137 133 134 125 126 112 113 114 102 103 116 121" -e pazi snip60377_3732605.fbspi.fil.ar
#paz -z "101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136" -e pazi snip60377_6264129.fbspi.fil.pazi
#paz -z "164 165 166 167 163" -e pazi snip60378_4604753.fbspi.fil.pazi
