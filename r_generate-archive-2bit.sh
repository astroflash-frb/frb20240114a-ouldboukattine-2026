#!/bin/bash

# Ould-Boukattine (2026)
# Ould-Boukattine (2025)
# Kirsten & Ould-Boukattine (2023) 

# Script takes 2bit upsampled filterbanks and converts them to archive files
# This script is 95%based on the r_generate-archive script, which uses SFXC created filterbank as base

# The script also checks if the final time resoltuon is a factor of 2, if this is not the case (7.999us-bins) for example
# Then this can be solved by changing the start_time of the archive file (by 0,01), it's behavior I suspect has to do with rounding of start time

# dont forget the extra space at the end of the line, before the \, otherwise it won't run
# middle = location of the burst in the sfxc filterbank, used prepdata to see the location (plots in evernote)
# cepoch = shift to left in seconds

runs=( \
# exp   dish scan band DM direc middle cepoch_s filterbank
#"p55020 wb 37 L 527.7 p55020_37 1.0 0.00 p55020_wb_no0037_IFall_vdif_pol2_8bit_snippet.fil" \
# 2bit upscaled L-band -- MAKE SURE TO CHANGE THE BASEDIR
#"p47018 wb 17 L 527.7 p47018_17 5.0 1.29 p47018_wb_no0017_IFall_vdif_pol2_8bit_10sec_600s_snippet.fil D" \
#"p47019 wb 18 L 527.7 p47019_18 5.0 0.80 p47019_wb_no0018_IFall_vdif_pol2_8bit_10sec_857s_snippet.fil D" \
#"p47020 wb 16 L 527.7 p47020_16 5.0 1.00 p47020_wb_no0016_IFall_vdif_pol2_8bit_10sec_128s_snippet.fil D" \
#"p47021 wb 7  L 527.7 p47021_7  5.0 1.35 p47021_wb_no0007_IFall_vdif_pol2_8bit_10sec_133s_snippet.fil D" \
#"p47021 wb 11 L 527.7 p47021_11 5.0 1.05 p47021_wb_no0011_IFall_vdif_pol2_8bit_10sec_486s_snippet.fil D" \
#####5
#"p47022 wb 18 L 527.7 p47022_18 5.0 1.40 p47022_wb_no0018_IFall_vdif_pol2_8bit_10sec_659s_snippet.fil D" \
#"p47022 wb 22 L 527.7 p47022_22 5.0 1.90 p47022_wb_no0022_IFall_vdif_pol2_8bit_10sec_753s_snippet.fil D" \
#"p47023 wb 15 L 527.7 p47023_15 5.0 0.00 p47023_wb_no0015_IFall_vdif_pol2_8bit_10sec_551s_snippet.fil D" \
#"p47023 wb 21 L 527.7 p47023_21 5.0 0.27 p47023_wb_no0021_IFall_vdif_pol2_8bit_10sec_216s_snippet.fil D" \
#"p47069 wb 7  L 527.7 p47069_7  5.0 0.67 p47069_wb_no0007_IFall_vdif_pol2_8bit_10sec_294s_snippet.fil D" \
#####10
#"p47091 wb 18 L 527.7 p47091_18 5.0 0.45 p47091_wb_no0018_IFall_vdif_pol2_8bit_10sec_858s_snippet.fil D" \
#"p55020 wb 37 L 527.7 p55020_37 5.0 1.24 p55020_wb_no0037_IFall_vdif_pol2_8bit_10sec_501s_snippet.fil D" \
#"p55182 wb 32 L 527.7 p55182_32 5.0 1.45 p55182_wb_no0032_IFall_vdif_pol2_8bit_10sec_195s_snippet.fil D" \
#"p55195 wb 44 L 527.7 p55195_44 5.0 1.95 p55195_wb_no0044_IFall_vdif_pol2_8bit_10sec_447s_snippet.fil D" \
#"p55289 wb 90 L 527.7 p55289_90 5.0 0.75 p55289_wb_no0090_IFall_vdif_pol2_8bit_10sec_261s_snippet.fil D" \
#####15
#"p55290 wb 87 L 527.7 p55290_87 5.0 1.10 p55290_wb_no0087_IFall_vdif_pol2_8bit_10sec_551s_snippet.fil D" \
#"p55291 wb 41 L 527.7 p55291_41 5.0 0.90 p55291_wb_no0041_IFall_vdif_pol2_8bit_10sec_357s_snippet.fil D" \
#"p55298 wb 73 L 527.7 p55298_73 4.41 0.80 p55298_wb_no0073_IFall_vdif_pol2_8bit_10sec_413s_snippet.fil D" \
#"p55300 wb 66 L 527.7 p55300_66 5.0 1.57 p55300_wb_no0066_IFall_vdif_pol2_8bit_10sec_250s_snippet.fil D" \
#"p55300 wb 66 L 527.7 p55300_66 5.0 0.50 p55300-2_wb_no0066_IFall_vdif_pol2_8bit_10sec_502s_snippet.fil D" \
#####20
#"p55192 wb 44 L 527.7 p55192_44 5.0 0.50 p55192_wb_no0044_IFall_vdif_pol2_8bit_10sec_417s_snippet.fil" \
#####21

)

#Create directory for the archive files
basedir=/data1/omar/sfxc/frb240114a
archive_dir=/fil_to_archives_2bit

fil_dir=/scratch1/baseband_extractions/r147/wb-2bit

outdir_archive=${basedir}/${archive_dir}

if ! [ -d ${outdir_archive} ];then
    mkdir -p ${outdir_archive}
fi

for run in "${runs[@]}";do

    #Read the run line using the read function
    read -r -a info <<< "${run}"
    exp="${info[0]}"
    dish="${info[1]}"
    scan="${info[2]}"
    band="${info[3]}"
    dm="${info[4]}"
    direc="${info[5]}"
    middle_b="${info[6]}"
    cepoch_s="${info[7]}"
    filterbank="${info[8]}"

    lenght_archive=2.097152 #expected sweep is 274 ms or 0.274 seconds. 
    #Now there is enough noise and room for the sweep, the filterbanks are 10sec long
        
    #For the 2bit bursts, the time resolution is 256 us.
    time_res=0.000256
        
    #naming convention:
    #filterbank_in_dir=${basedir}/${direc}/${filterbank}
    filterbank_in_dir=${fil_dir}/${filterbank}
    archive_out_nm=${outdir_archive}/${filterbank/./_}
    echo $archive_out_nm

    #calculate the number of bins based on the lenght and time_res
    nbins=`echo "${lenght_archive}/${time_res}" | bc -l | cut -d '.' -f1`

    #Start time of the archive file
    start_b=`echo "${middle_b} - ${lenght_archive}/2" | bc -l`

    #From documentation of CEPOCH
    #To specify a different epoch (e.g. the middle of the observation) use the EPOCH key with value specified as MJD.
    #So we convert from seconds to MJD to define the shift to left.
    #In order for CEPOCH to work you need a 0. infront of the number, so using sed we add a 0, see link below
    cepoch_mjd=`echo "(( ${cepoch_s} / ( 24 * 3600 ) ))" | bc -l | sed -e 's/^-\./-0./' -e 's/^\./0./'`

    echo "${exp} ${dish} ${scan} ${band} ${direc} ${cepoch_mjd} ${filterbank} ${nbins}"

    #runnig dspsr to create an archive file
    dspsr_cmd="dspsr -c ${lenght_archive} -T ${lenght_archive} -S ${start_b} -b ${nbins} -D ${dm} -cepoch ${cepoch_mjd} -O ${archive_out_nm} ${filterbank_in_dir}"
    echo $dspsr_cmd
    ${dspsr_cmd}

    #Name of the archive file with extension
    archive_out_nm_ar=${archive_out_nm}.ar

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
        echo ""
        echo "###########################################"
        echo "!!! ALERT: Time resolution is not even !!!"
        echo "Burst: $filterbank"
        echo "Current time_res = $time_res"
        echo "Check start time for dspsr!"
        echo "###########################################"
        echo ""
    fi

    ##We remove this, because the sweep is still present in the data. 
    ##Add the DM value 
    #dspsr_cmd_dm="psredit -m -c dm=${dm} ${archive_out_nm_ar}"
    ##echo $dspsr_cmd_dm
    #${dspsr_cmd_dm}

    ##Add the fact that the burst is already straight, dmc=1
    #dspsr_cmd_dmc="psredit -m -c dmc=1 ${archive_out_nm_ar}"
    ##echo $dspsr_cmd_dmc
    #${dspsr_cmd_dmc}
     
    #Downsample factor for diagnostic plots
    time_down=8
    freq_down=4
    
    freq_res_khz=`echo "${freq_res}/1000" | bc` #convert to khz

    #Generate the new time- and freq resoltuon
    plt_time_res=`echo "$time_res*$time_down" | bc` #us
    plt_freq_res=`echo "$freq_res_khz*$freq_down" | bc` #khz
    echo "Making a diagnostic plot with time_res=${plt_time_res} us and freq_res=${plt_freq_res} hz"

    psrplot -pfreq+ -c x:unit=s -D /CPS -jpDT -j 'F x'"${freq_down}" -j 'B x'"${time_down}" ${archive_out_nm_ar}

    #${parameter//pattern/string}
    #Replace the old time and freq-res with the new in the archive string
    #Only search for time_res+us, otherwise you will also replace numbers in the scan
    # Insert time/freq before "_snippet"
    new_name_tf="${archive_out_nm_ar/_snippet/_${plt_time_res}us_${plt_freq_res}khz_snippet}"

    #new_name_t=`echo "${archive_out_nm_ar/${time_res}"us"/${plt_time_res}"us"}"`
    #new_name_tf=`echo "${new_name_t/${freq_res_khz}"KHz"/${plt_freq_res}"KHz"}"`
    echo "${new_name_tf}"
    mv pgplot.ps ${new_name_tf}.ps

done

#Regarding the sed expression
#https://stackoverflow.com/questions/8402181/how-do-i-get-bc1-to-print-the-leading-zero

#making into a ps plot
#psrplot -pfreq+ -c x:unit=s -D /CPS -jpDT -j 'F x4' -j 'B x8' ${outdir}/${ar_scale}
#mv pgplot.ps ${outdir}/${ar_scale}.ps



