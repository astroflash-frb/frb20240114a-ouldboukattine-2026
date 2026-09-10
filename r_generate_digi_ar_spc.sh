#!/bin/bash
#
#########
# Ould-Boukattine 2024/2025/2026
# Kirsten & Ould-Boukattine 2023

# This script assumes that the VDIF files were already split
# into individual subbands and live somewhere on disk. This can be done using the base2fil script.
# It performs the following steps:
# - using 'digifil', it will create Stokes I filterbank files for each subband
# - using 'dspsr', it will create archives files, attempting to have the pulse in the middle
# - each ar-file (one per subband) will first be scaled -- there can't be smearing left in a channel for scaling to work
# - the scaled ar-files with then be corrected using psrchive's SPC alogorithm
# - the scaled ar-files will be co-added to have the full band in one archive
# - the first scaled and then SPC'ed ar-files will be co-added to have the full band in one archive
# - a diff-archive of the scaled and the SPC'ed file will be generated
# - diagnostic plots of the scaled, SPC'ed, diff'ed archives are generated

# - SPC does not work on zapped archives, so need to do this work with RFI left in the file

# we create archives on a per subband level, then scale them, spc them, psradd them.
# need to have NPOL 2 in hdr files for vdif-devel dspsr to work.
#########

bw64=64000000
bw128=128000000
bw256=256000000
bw512=512000000

subbw8=8000000
subbw16=16000000
subbw32=32000000

pwait() {
    while [ $(jobs -p | wc -l) -ge $1 ]; do
	sleep 0.33
    done
}
njobs=16

#expcounters=( 0 ) # this is zero based!

# You cant place a space after the \ at the eol
#runs=( \
# exp - dish -scan - bw - subbandbw - cepoch_s -scaling factor for spc - index
#"p55092 wb 32 527.7 ${bw128} ${subbw16} 0.0 0.50 0" \
#"p55097 wb 41 527.7 ${bw128} ${subbw16} 0.0 0.40 0" \
#"p47027 o8 10 527.7 ${bw128} ${subbw16} 0.0 0.50 0" \
#"rn1l70 tr 07 527.7 ${bw128} ${subbw16} 0.0 0.50 0" \
#)

# 4.15e6 * 527.7 * (1207^-2 - (1207+0.015625)^-2) = 0.039 ms = 39 us
# We need to create 64 us with 15.625 KHz channels in order for SPC to work
# Remember, we can' have any smearing in the channels, otherwise SPC will not work
# This chosen frequency is also at Nyquist.

# The sweep at this DM is ~275 ms over the entire band (DM 527.7)
# We need to therefore make sure that we sample the entire burst

# What one can do is after applying the SPC algortithm is downsample in frequency, 
# that is what the pam commands are for. Then we go back to the 125 KHz. 

# TODO implement different time- and freq- options for bursts, BUT needs to be the same for SFXC, apples to apples

######FREQ resolutions
#freq_resolution=976.562 
#freq_resolution=1953.125
#freq_resolution=3906.25 #PBAND
#freq_resolution=7812.5
freq_resolution=15625.0 #LBAND
#freq_resolution=31250.0  
#freq_resolution=62500.0  
#freq_resolution=31250.0  

#######TIME RESOLUTIONS
time_res=0.000064 #LBAND
#time_res=0.000128
#time_res=0.000256 
#time_res=0.000512
#time_res=0.001024 
#time_res=0.002048 #PBAND

#Downsample commands at the end of the script
pam_tscrunch=2 #to get it to 128 us
pam_fscrunch=32 #To get it to 500 KHz, the same as most of the SFXC created filterbanks
#pam_fscrunch=8 #PBAND
#pam_tscrunch=1 #PBAND - to get it to 128 us
    
basedir=/data1/omar/
vdif_base=/scratch0/omar/
dir_in_outdir=scale_spc/

#Latest installs of dspsr and digifil on Sleipnir (March-2025)
dspsr=/home/oper/software/installs/dspsr-psrchive-latest/bin/dspsr
digifil=/home/oper/software/installs/dspsr-psrchive-latest/bin/digifil
pam=/home/oper/software/installs/dspsr-psrchive-latest/bin/pam

# -------------------------------
# Loop over bursts in the file
# -------------------------------

BURST_FILE="burst_params_spc.txt"

while IFS= read -r line; do
    # Skip commented lines
    [[ "$line" =~ ^# ]] && continue

    # Read the line into variables
    # Format: exp dish scan dm bw subbandbw cepoch_s scale
    # I added the flag (_) at the end to absorb the possibly D at the end of the line makring I processed it
    read -r exp dish scan dm bw subbandbw cepoch_s scale _ <<< "$line"
 
    # Expand variables from the file -- we need this to get the BW and subbandbw lined up
    bw=$(eval echo "$bw")
    subbandbw=$(eval echo "$subbandbw")
    echo "BW = $bw, subbandBW = $subbandbw, DM = $dm"
    
    #pre pad 4 digit with 0 25 -> 0025 125 -> 0125
    scan_fmt=$(printf "%04d" "$scan")
       
    nif=`echo "${bw}/${subbandbw}" | bc | cut -d '.' -f1`
    
    nif_used=${nif} 
    echo "time res: $time_res and freq res: $freq_resolution"

    length=2.097152
    #length=1.048576
    #length=4.194304 
    #length=0.524288
    
    #Lenght digifil filterbanks; account for the sweep while leaving guassian noise in the file
    digi_l=5.9

    #The .vdif frames on disk are 6 seconds long (L-band), we want the middle 2 seconds with the burst, so we Seek 1 second into the file.
    start_b=1.8

    #nif_used=7 #PBAND - skipping the top subband
    P_BAND_OPTION=false   # set to false to skip - done on 26jan
    if [ "$P_BAND_OPTION" = true ]; then
        echo "overriding to Pband"
        length=8.388608 #Pband
        digi_l=15.0 #Pband - p47030:13.0
        start_b=4.5 #Pband, the burst is 5sec into the VDIF file (p47030:2.6 - pcn242:4.5
        nif_used=7 #PBAND - skipping the top subband
        pam_fscrunch=8 #PBAND
        pam_tscrunch=1 #PBAND
    else
        echo "USING L_BAND OPTIONS"
    fi
            
    echo "Setting DM to $dm"

    echo "${exp} ${dish} ${band} ${scan_fmt} ${bw} ${subbandbw} ${cepoch} ${nif_used} ${dm}"
    nbins=`echo "${length}/${time_res}" | bc -l | cut -d '.' -f1`

    #cepoch is given in seconds above, here we convert to MJD and add a leading 0. 
    cepoch=`echo "(( ${cepoch_s} / ( 24 * 3600 ) ))" | bc -l | sed -e 's/^-\./-0./' -e 's/^\./0./'`

    #Define the outdir
    outdir=${basedir}/${exp}/${dir_in_outdir}

    #Make the outdir in case did not exist.
    if ! [ -d ${outdir} ];then
	    mkdir -p ${outdir}
    fi
    
    nchans=`echo "${subbandbw}/${freq_resolution}" | bc | cut -d '.' -f1`
    leakage_factor=`echo "${nchans}*4" | bc | cut -d '.' -f1`

    for IF in `seq 1 ${nif_used}`;do
	    hdr=${exp}_${dish}_no${scan_fmt}_IF${IF}.vdif_pol2.hdr

        #Remove .hdr 
	    ar=${outdir}/${hdr%.hdr}

        #Remove any filterbanks that were already there in the output folder (handy in case we rerun)
        rm ${ar}.fil

        #Digifil command
        ufactor=5000
        cmd="${digifil} -I0.0 -b8 -D0.0 -d1 -F${nchans}:${leakage_factor} -T ${digi_l} -U ${ufactor} -o ${ar}.fil ${vdif_base}/${exp}/${hdr} && "

        echo "ALERT ALERT ALERT THIS IS THE DM USED: $dm"
        cmd=${cmd}"${dspsr} -S ${start_b} -b ${nbins} -D ${dm} -c ${length} -T ${length} -U ${ufactor} -cepoch ${cepoch} ${ar}.fil -O ${ar}.fil && "
        cmd=${cmd}"./spc/scale_${scale}.sh -e scale.ar ${ar}.fil.ar && "
        cmd=${cmd}"./spc/spc.sh -e spc.ar ${ar}.fil.scale.ar && "
        cmd=${cmd}"${pam} -f ${pam_fscrunch} -b ${pam_tscrunch} -e ds.ar ${ar}.fil.scale.ar && "
        cmd=${cmd}"${pam} -f ${pam_fscrunch} -b ${pam_tscrunch} -e ds.ar ${ar}.fil.scale.spc.ar "
        echo "$cmd"
        eval ${cmd} &
        pwait ${njobs}
    done
    wait

    # add the subbands into one
    #Define the files
    ar_scale=${exp}_${dish}_no${scan_fmt}_allIFs.vdif_pol2.fil.scale.ar
    ar_spc=${exp}_${dish}_no${scan_fmt}_allIFs.vdif_pol2.fil.scale.spc.ar
    ar_scale_ds=${exp}_${dish}_no${scan_fmt}_allIFs.vdif_pol2.fil.scale.ds.ar
    ar_spc_ds=${exp}_${dish}_no${scan_fmt}_allIFs.vdif_pol2.fil.scale.spc.ds.ar

    #Using psradd we will stitch the IFs together 
    psradd -R -o ${outdir}/${ar_scale} ${outdir}/${exp}_${dish}_no${scan_fmt}_IF*.vdif_pol2.fil.scale.ar
    psradd -R -o ${outdir}/${ar_scale_ds} ${outdir}/${exp}_${dish}_no${scan_fmt}_IF*.vdif_pol2.fil.scale.ds.ar
    psradd -R -o ${outdir}/${ar_spc} ${outdir}/${exp}_${dish}_no${scan_fmt}_IF*.vdif_pol2.fil.scale.spc.ar
    psradd -R -o ${outdir}/${ar_spc_ds} ${outdir}/${exp}_${dish}_no${scan_fmt}_IF*.vdif_pol2.fil.scale.spc.ds.ar

    # Making an allIF filterbank file (optional)
    DO_MAKE_ALLIF_FILTERBANK=true   # set to false to skip
    #DO_MAKE_ALLIF_FILTERBANK=false   # set to false to skip
    #####################
    if [ "$DO_MAKE_ALLIF_FILTERBANK" = true ]; then
        echo "Making a allIFs filterbank"
        filterbanks_IFs=$(printf "%s\n" "${outdir}/${exp}_${dish}_no${scan_fmt}_IF"*.vdif_pol2.fil | sort -V -r)
        echo "Running command:"
        echo "splice $filterbanks_IFs > ${outdir}/${exp}_${dish}_no${scan_fmt}_allIFs.vdif_pol2.fil"
        splice $filterbanks_IFs > "${outdir}/${exp}_${dish}_no${scan_fmt}_allIFs.vdif_pol2.fil"
    else
        echo "Skipping creation of allIFs filterbank"
    fi
    
    # --- Check archive properties ---
    echo "Checking archive properties for ${ar_spc}"
    pars=$(psredit -q -Q -c nbin,length,npol,nchan,bw "${outdir}/${ar_spc}")
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
        echo "Burst: $ar_spc"
        echo "Current time_res = $time_res"
        echo "Check start time for dspsr!"
        echo "###########################################"
        echo ""
    fi
    
    #####################
    
    #Plot of the downsampled scaled_archived file
    psrplot -pfreq+ -c x:unit=s -D /CPS -jpDT -j 'F x4' -j 'B x32' ${outdir}/${ar_scale_ds}
    mv pgplot.ps ${outdir}/${ar_scale_ds}.ps

    #Plot of the downsampled spc_archive file
    psrplot -pfreq+ -c x:unit=s -D /CPS -jpDT -j 'F x4' -j 'B x32' ${outdir}/${ar_spc_ds}
    mv pgplot.ps ${outdir}/${ar_spc_ds}.ps

    #psrdiff is to find the difference in profile; see the impact of the spc algorithm
    #Specifically the downsampled archive files
    psrdiff ${outdir}/${ar_scale_ds} ${outdir}/${ar_spc_ds}
    mv psrdiff.out ${outdir}/${exp}_${dish}_no${scan_fmt}_scale_spc_diff_ds.ar
    psrplot -pD -c x:unit=s -D /CPS -jpFD ${outdir}/${exp}_${dish}_no${scan_fmt}_scale_spc_diff_ds.ar
    mv pgplot.ps ${outdir}/${exp}_${dish}_no${scan_fmt}_scale_spc_diff_ds.ar.ps

done < "$BURST_FILE"
