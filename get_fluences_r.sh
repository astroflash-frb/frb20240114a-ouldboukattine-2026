#!/bin/bash
set -e

##########################
#
# Once we have created all the ar-files (SFXC, scaled, SPC'ed), this
# script is wrapper around .python/ACF_archive.py which lets you compute
# the ACF, the widths, the S/N, the fluences for all burst components. All
# data are stored in a pandas data frame and saved as .csv 
#
# Stockert command: ls *ds.ar | sort -t '/' -k 4 | cut -d '.' -f 1 | cut -c 8- |sed -e 's;^;#"stocke st ;' | sed '$!s/$/ ${sefd_st} B999-st" \\/'
##########################

sefd_wb_p=2100
sefd_wb=420
sefd_o8=310
sefd_tr=250
sefd_st=385

# 2025-03-26: First run of all bursts (without flagging of subband edges)

runs=( \
# exp dish scan sefd ID
##Westerbork
#"pcn254 wb 12 L 527.7 ${sefd_wb} B02-wb D" \
#"p47018 wb 24 L 527.7 ${sefd_wb} B09-wb D" \
#"p47019 wb 21 L 527.7 ${sefd_wb} B11-wb D" \
#"p47019 wb 33 L 527.7 ${sefd_wb} B12-wb D" \
#"p47019 wb 36 L 527.7 ${sefd_wb} B13-wb D" \
#5
#"p47019 wb 37 L 527.7 ${sefd_wb} B14-wb D" \
#"p47020 wb 19 L 527.7 ${sefd_wb} B18-wb D" \
#"p47020 wb 25 L 527.7 ${sefd_wb} B19-wb D" \
#"p47021 wb 11 L 527.7 ${sefd_wb} B30-wb D" \
#"p47021-2 wb 13 L 527.7 ${sefd_wb} B33-wb D" \
#10
#"p47021 wb 13 L 527.7 ${sefd_wb} B32-wb D" \
#"p47021 wb 04 L 527.7 ${sefd_wb} B25-wb D" \
#"p47021 wb 06 L 527.7 ${sefd_wb} B26-wb D" \
#"p47021 wb 08 L 527.7 ${sefd_wb} B28-wb D" \
#"p47021 wb 09 L 527.7 ${sefd_wb} B29-wb D" \
#15
#"p47031 wb 20 L 527.7 ${sefd_wb} B110-wb D" \
#"p47031 wb 36 L 527.7 ${sefd_wb} B112-wb D" \
#"p55084 wb 34 L 527.7 ${sefd_wb} B135-wb D" \
#"p55092 wb 32 L 527.7 ${sefd_wb} B136-wb D" \
#"p55097 wb 41 L 528.4 ${sefd_wb} B137-wb D" \
#20
#"p55158 wb 47 L 527.7 ${sefd_wb} B139-wb D" \
#"p55173 wb 40 L 527.7 ${sefd_wb} B140-wb D" \
#"p55179 wb 40 L 527.7 ${sefd_wb} B142-wb D" \
#"p55179 wb 44 L 527.7 ${sefd_wb} B143-wb D" \
#"p55179 wb 47 L 527.7 ${sefd_wb} B144-wb D" \
#25
#"p55179 wb 51 L 527.7 ${sefd_wb} B145-wb D" \
#"p55179-2 wb 51 L 527.7 ${sefd_wb} B146-wb D" \
#"p55179 wb 54 L 527.7 ${sefd_wb} B147-wb D" \
#"p55182 wb 55 L 527.7 ${sefd_wb} B151-wb D" \
#"p55183 wb 50 L 527.7 ${sefd_wb} B156-wb D" \
#30
#"p55186 wb 08 L 527.7 ${sefd_wb} B158-wb D" \
#"p55195 wb 29 L 527.7 ${sefd_wb} B160-wb D" \
#"p55197 wb 42 L 527.7 ${sefd_wb} B163-wb D" \
#"p55293 wb 11 L 527.7 ${sefd_wb} B173-wb D" \
#"p55299 wb 125 L 527.7 ${sefd_wb} B177-wb D manually changed the 0" \ 
#35
#"p47085 wb 11 L 527.7 ${sefd_wb} B130-wb D" \
#"p47057 wb 36 L 527.7 ${sefd_wb} B123-wb D" \
#"p47065 wb 33 L 527.7 ${sefd_wb} B126-wb D" \
#"p47066 wb 16 L 527.7 ${sefd_wb} B127-wb D" \
#39 - V1.0 done on Jan29


##ONSALA
#"p47024 o8 24 L 527.7 ${sefd_o8} B63-o8 D" \
#"p47024 o8 26 L 527.7 ${sefd_o8} B65-o8 D" \
#"p47024 o8 32 L 527.7 ${sefd_o8} B67-o8 D" \
#"p47024-2 o8 32 L 527.7 ${sefd_o8} B68-o8 D" \
#"p47024 o8 34 L 527.7 ${sefd_o8} B70-o8 D" \
#5
#"p47024-2 o8 34 L 527.7 ${sefd_o8} B71-o8 D" \
#"p47024 o8 35 L 527.7 ${sefd_o8} B72-o8 D" \
#"p47024 o8 03 L 527.7 ${sefd_o8} B56-o8 D" \
#"p47024 o8 38 L 527.7 ${sefd_o8} B73-o8 REDO" \
#"p47024 o8 08 L 527.7 ${sefd_o8} B57-o8 D" \
#10
#"p47025 o8 11 L 527.7 ${sefd_o8} B79-o8 D" \
#"p47025 o8 13 L 527.7 ${sefd_o8} B80-o8 D" \
#"p47025 o8 14 L 527.7 ${sefd_o8} B81-o8 TO FAINT - DM OFF - skipped" \
#"p47025 o8 16 L 527.7 ${sefd_o8} B82-o8 D" \
#"p47025 o8 22 L 527.7 ${sefd_o8} B83-o8 D" \
#15
#"p47025 o8 24 L 527.7 ${sefd_o8} B84-o8 D" \
#"p47025 o8 02 L 527.7 ${sefd_o8} B74-o8 D" \
#"p47025 o8 26 L 527.7 ${sefd_o8} B85-o8 D" \
#"p47025-2 o8 26 L 527.7 ${sefd_o8} B86-o8 D" \
#"p47025 o8 27 L 527.7 ${sefd_o8} B87-o8 D" \
#20
#"p47025 o8 29 L 527.7 ${sefd_o8} B88-o8 D" \
#"p47025 o8 30 L 527.7 ${sefd_o8} B89-o8 D" \
#"p47025 o8 34 L 527.7 ${sefd_o8} B90-o8 D" \
#"p47025 o8 36 L 527.7 ${sefd_o8} B91-o8 D" \
#"p47025 o8 42 L 527.7 ${sefd_o8} B92-o8 D" \
#25
#"p47025 o8 04 L 527.7 ${sefd_o8} B75-o8 D" \
#"p47025 o8 05 L 527.7 ${sefd_o8} B76-o8 D" \
#"p47025 o8 08 L 527.7 ${sefd_o8} B77-o8 D" \
#"p47025 o8 09 L 527.7 ${sefd_o8} B78-o8 D" \
#"p47026 o8 13 L 527.7 ${sefd_o8} B96-o8 D" \
#30
#"p47026 o8 16 L 527.7 ${sefd_o8} B97-o8 D" \
#"p47026 o8 19 L 527.7 ${sefd_o8} B98-o8 D" \
#"p47026 o8 21 L 527.7 ${sefd_o8} B99-o8 D" \
#"p47026 o8 28 L 527.7 ${sefd_o8} B100-o8 D" \
#"p47026 o8 40 L 527.7 ${sefd_o8} B101-o8 D" \
#35
#"p47026 o8 04 L 527.7 ${sefd_o8} B93-o8 D" \
#"p47026 o8 05 L 527.7 ${sefd_o8} B94-o8 D" \
#"p47026 o8 06 L 527.7 ${sefd_o8} B95-o8 D" \
#"p47027 o8 10 L 527.7 ${sefd_o8} B102-o8 D" \
#"p47027 o8 18 L 527.7 ${sefd_o8} B103-o8 D" \
#40
#"p47028 o8 24 L 527.7 ${sefd_o8} B104-o8 D" \
#"p47030 o8 23 L 527.7 ${sefd_o8} B106-o8 D" \
#"p47030 o8 31 L 527.7 ${sefd_o8} B107-o8 D" \
#"p47030 o8 39 L 527.7 ${sefd_o8} B108-o8 D" \
#"p47038 o8 43 L 527.7 ${sefd_o8} B120-o8 D" \
#45
#"p47064 o8 38 L 527.7 ${sefd_o8} B125-o8 no spc" \
#"p47068 o8 29 L 527.7 ${sefd_o8} B128-o8 D" \
#"p49035 o8 27 L 527.7 ${sefd_o8} B162-o8 D" \
#48

##TORUN
#"rn1l10 tr 11 L 527.7 ${sefd_tr} B60-tr D" \
#"rn1l10 tr 13 L 527.7 ${sefd_tr} B61-tr D" \
#"rn1l10 tr 15 L 527.7 ${sefd_tr} B64-tr D" \
#"rn1l10 tr 16 L 527.7 ${sefd_tr} B65-tr D" \
#"rn1l10 tr 22 L 527.7 ${sefd_tr} B66-tr D" \
#5
#"rn1l10 tr 23 L 527.7 ${sefd_tr} B68-tr D" \
#"rn1l10 tr 07 L 527.7 ${sefd_tr} B58-tr D" \
#"rn1l11 tr 13 L 527.7 ${sefd_tr} B85-tr D" \
#"rn1l11 tr 14 L 527.7 ${sefd_tr} B86-tr TO FAINT-skipped" \
#"rn1l11-2 tr 14 L 527.7 ${sefd_tr} B87-tr D" \
#10
#"rn1l11 tr 17 L 527.7 ${sefd_tr} B88-tr TO FAIT-skipped" \
#"rn1l11 tr 23 L 527.7 ${sefd_tr} B90-tr D" \
#"rn1l12 tr 04 L 527.7 ${sefd_tr} B110-tr D 256 mhz" \
#"rn1l13 tr 20 L 527.7 ${sefd_tr} B122-tr D 256 mhz" \
#"rn1l33 tr 10 L 527.7 ${sefd_tr} B134-tr D" \
#15
#"rn1l40 tr 17 L 527.7 ${sefd_tr} B137-tr D" \
#"rn1l58 tr 23 L 527.7 ${sefd_tr} B138-tr D" \
#"rn1l59 tr 16 L 527.7 ${sefd_tr} B139-tr D" \
#"rn1l62 tr 14 L 527.7 ${sefd_tr} B141-tr D" \
#"rn1l64 tr 15 L 527.7 ${sefd_tr} B149-tr D" \
#20
#"rn1l64 tr 04 L 527.7 ${sefd_tr} B148-tr D" \
#"rn1l65 tr 10 L 527.7 ${sefd_tr} B154-tr D" \
#"rn1l65 tr 14 L 527.7 ${sefd_tr} B155-tr D" \
#"rn1l65 tr 01 L 527.7 ${sefd_tr} B152-tr D" \
#"rn1l65 tr 06 L 527.7 ${sefd_tr} B153-tr D" \
#25
#"rn1l66 tr 11 L 527.7 ${sefd_tr} B157-tr D" \
#"rn1l67 tr 14 L 527.7 ${sefd_tr} B158-tr D" \
#"rn1l70 tr 07 L 527.7 ${sefd_tr} B163-tr D" \
#"rn1l81 tr 16 L 527.7 ${sefd_tr} B164-tr D" \
#"rn1l81 tr 21 L 527.7 ${sefd_tr} B165-tr D" \
#30
#"rn1l82 tr 20 L 527.7 ${sefd_tr} B166-tr D" \
#"rn1l83 tr 07 L 527.7 ${sefd_tr} B167-tr D" \
#"rn1l84 tr 14 L 527.7 ${sefd_tr} B168-tr D" \
#"rn1l84 tr 15 L 527.7 ${sefd_tr} B169-tr D" \
#"rn1l87 tr 05 L 527.7 ${sefd_tr} B174-tr D" \
#35
#"rn1l89 tr 02 L 527.7 ${sefd_tr} B176-tr D" \
#"rn1l90 tr 22 L 527.7 ${sefd_tr} B180-tr D" \
#37

# Pband - DONE on Jan 26
#"pcn242 wb 23 P 527.7 ${sefd_wb_p} B01-wb D" \
#"p47030 wb 21 P 527.7 ${sefd_wb_p} B105-wb" \

# Stockert burst
#"stocke st 60357_3437816 L 527.7 ${sefd_st} B03-st D" \
#"stocke st 60357_4385230 L 527.7 ${sefd_st} B04-st D-zapped" \
#"stocke st 60361_5475088 L 527.7 ${sefd_st} B05-st D" \
#"stocke st 60366_3461485 L 527.7 ${sefd_st} B06-st D" \
#"stocke st 60369_3359967 L 527.7 ${sefd_st} B08-st D" \
#"stocke st 60371_2798981 L 527.7 ${sefd_st} B15-st D" \
#"stocke st 60372_5113801 L 527.7 ${sefd_st} B16-st D" \
#"stocke st 60373_4876754 L 527.7 ${sefd_st} B20-st D" \
#"stocke st 60373_5456450 L 527.7 ${sefd_st} B21-st D" \
#"stocke st 60374_3189053 L 527.7 ${sefd_st} B22-st D" \
###10
#"stocke st 60375_2980335 L 527.7 ${sefd_st} B23-st D" \
#"stocke st 60375_3037769 L 527.7 ${sefd_st} B24-st D" \
#"stocke st 60375_4292868 L 527.7 ${sefd_st} B30-st D" \
#"stocke st 60375_4311251 L 527.7 ${sefd_st} B31-st D" \
#"stocke st 60375_4726520 L 527.7 ${sefd_st} B34-st D-zapped" \
#"stocke st 60376_3217991 L 527.7 ${sefd_st} B35-st D" \
#"stocke st 60376_3316630 L 527.7 ${sefd_st} B36-st D" \
#"stocke st 60377_2533142 L 527.7 ${sefd_st} B37-st D-zapped" \
#"stocke st 60377_3150949 L 527.7 ${sefd_st} B38-st D" \
#"stocke st 60377_3732605 L 527.7 ${sefd_st} B39-st D" \
###20
#"stocke st 60377_4371665 L 527.7 ${sefd_st} B40-st D" \
#"stocke st 60377_4588314 L 527.7 ${sefd_st} B41-st D" \
#"stocke st 60377_6264129 L 527.7 ${sefd_st} B42-st D" \
#"stocke st 60378_2170109 L 527.7 ${sefd_st} B43-st D-zapped" \
#"stocke st 60378_3133708 L 527.7 ${sefd_st} B44-st D" \
#"stocke st 60378_4604753 L 527.7 ${sefd_st} B45-st D-zapped" \
#"stocke st 60379_2275323 L 527.7 ${sefd_st} B56-st D-zapped" \
#"stocke st 60379_2555746 L 527.7 ${sefd_st} B49-st D-zapped" \
#"stocke st 60379_2602165 L 527.7 ${sefd_st} B50-st D-zapped" \
#"stocke st 60379_2695980 L 527.7 ${sefd_st} B51-st D-zapped" \
#"stocke st 60379_3517707 L 527.7 ${sefd_st} B53-st D" \
#"stocke st 60379_4008061 L 527.7 ${sefd_st} B54-st D" \
#"stocke st 60379_5397914 L 527.7 ${sefd_st} B55-st D" \
#"stocke st 60380_2760984 L 527.7 ${sefd_st} B57-st D" \
#"stocke st 60380_3969765 L 527.7 ${sefd_st} B58-st D" \
#"stocke st 60380_3998840 L 527.7 ${sefd_st} B59-st D-zapped" \
#"stocke st 60380_4319492 L 527.7 ${sefd_st} B60-st D" \
#"stocke st 60380_4447753 L 527.7 ${sefd_st} B61-st D" \
#"stocke st 60380_4521409 L 527.7 ${sefd_st} B62-st D" \
#"stocke st 60380_5269620 L 527.7 ${sefd_st} B66-st D" \
#"stocke st 60380_5962205 L 527.7 ${sefd_st} B73-st D" \
#"stocke st 60381_1949711 L 527.7 ${sefd_st} B74-st D-zapped" \
#"stocke st 60381_2067454 L 527.7 ${sefd_st} B75-st D" \
#"stocke st 60381_2191585 L 527.7 ${sefd_st} B76-st D-zapped" \
#"stocke st 60381_3044108 L 527.7 ${sefd_st} B80-st D" \
#"stocke st 60381_4497249 L 527.7 ${sefd_st} B87-st D" \
#"stocke st 60381_4719812 L 527.7 ${sefd_st} B88-st D" \
#"stocke st 60382_4597962 L 527.7 ${sefd_st} B100-st D" \
#"stocke st 60382_5860243 L 527.7 ${sefd_st} B101-st D" \
#"stocke st 60383_2684445 L 527.7 ${sefd_st} B102-st D-zapped" \
#"stocke st 60383_3537691 L 527.7 ${sefd_st} B103-st D" \
#"stocke st 60384_4111808 L 527.7 ${sefd_st} B104-st D" \
#"stocke st 60386_4857456 L 527.7 ${sefd_st} B107-st D-zapped-omit-to-much-RFI" \
#"stocke st 60387_3671739 L 527.7 ${sefd_st} B109-st D" \
#"stocke st 60388_4505749 L 527.7 ${sefd_st} B113-st D" \
#"stocke st 60390_2765210 L 527.7 ${sefd_st} B114-st D" \
#"stocke st 60390_4257662 L 527.7 ${sefd_st} B115-st D" \
#"stocke st 60391_5690699 L 527.7 ${sefd_st} B116-st D" \
#"stocke st 60392_5928489 L 527.7 ${sefd_st} B117-st D" \
#"stocke st 60393_5544964 L 527.7 ${sefd_st} B118-st D" \
#"stocke st 60394_3474146 L 527.7 ${sefd_st} B119-st D-zapped" \
#"stocke st 60394_5868739 L 527.7 ${sefd_st} B120-st D" \
#"stocke st 60396_2482285 L 527.7 ${sefd_st} B121-st D" \
#"stocke st 60424_4337451 L 527.7 ${sefd_st} B123-st D-zapped" \
#"stocke st 60425_4424318 L 527.7 ${sefd_st} B124-st D-zapped" \
#"stocke st 60431_4377754 L 527.7 ${sefd_st} B125-st D" \
#"stocke st 60433_2247390 L 527.7 ${sefd_st} B127-st D" \
#"stocke st 60458_0742204 L 527.7 ${sefd_st} B131-st D" \
#"stocke st 60803_2202071 L 527.7 ${sefd_st} B167-st D" \

#2 bit upsampled bursts
#"p47018 wb 17 L 527.7 ${sefd_wb} B07-wb D" \
#"p47019 wb 18 L 527.7 ${sefd_wb} B10-wb D" \
#"p47020 wb 16 L 527.7 ${sefd_wb} B17-wb D" \
#"p47021 wb 7 L 527.7 ${sefd_wb} B27-wb D" \
#"p47021 wb 11 L 527.7 ${sefd_wb} B31-wb D" \
##5
#"p47022 wb 18 L 527.7 ${sefd_wb} B46-wb D" \
#"p47022 wb 22 L 527.7 ${sefd_wb} B47-wb D" \
#"p47023 wb 15 L 527.7 ${sefd_wb} B48-wb to faint" \
#"p47023 wb 21 L 527.7 ${sefd_wb} B52-wb D" \
#"p47069 wb 7 L 527.7 ${sefd_wb} B129-wb D" \
##10
#"p47091 wb 18 L 527.7 ${sefd_wb} B132-wb D" \
#"p55020 wb 37 L 527.7 ${sefd_wb} B133-wb D" \
#"p55192 wb 44 L 527.7 ${sefd_wb} B159-wb D" \
#"p55195 wb 44 L 527.7 ${sefd_wb} B161-wb D" \
##15
#"p55289 wb 90 L 527.7 ${sefd_wb} B170-wb D" \
#"p55290 wb 87 L 527.7 ${sefd_wb} B171-wb D" \
#"p55291 wb 41 L 527.7 ${sefd_wb} B172-wb D" \
#"p55298 wb 73 L 527.7 ${sefd_wb} B175-wb D" \
#"p55300 wb 66 L 527.7 ${sefd_wb} B178-wb D" \
#"p55300-2 wb 66 L 527.7 ${sefd_wb} B179-wb D" \
##21
)

basedir=/data1/omar/
dbdir=/home/omar/git/r147-single-dish-analysis/databases/

#Scrunch is done per burst, depending on visibilty of the burst. 
# for O8, Wb, Tr
Tscrunch=8
Fscrunch=1

#Distance to the source is not known at the time of analysis
distance=616  # Mpc - (z = 0.130287) - from Snelders 2025

srcs=( "sfxc" "scale" "spc" )    # used as tag in the data frame to designate source of the info
compare_to=( " " " " "--compare_to scale" )

ACF_archive=./python/ACF_archive.py
ACF_archive_params="--newfit --distance ${distance} --show_acf_plots"

for run in "${runs[@]}";do
    IFS=" " read -r -a info <<< "${run}"
    exp="${info[0]}"
    dish="${info[1]}"
    scan="${info[2]}"
    band="${info[3]}"
    DM_dspsr="${info[4]}"
    sefd="${info[5]}"
    id="${info[6]}"

    arbase=${exp}_${dish}_no00${scan}

    TWO_BIT_MODUS=false 
    if [ "$TWO_BIT_MODUS" = true ]; then
        echo "2 BIT MODUS ACTIVATED"
        arbase=${exp}_${dish}_no00${scan}_2bit
    fi
    
    #Setting DM
    DM_sfxc=527.7
    if [[ ${exp} == 'p55097' ]];then
        DM_sfxc=528.8
    fi
    
    db="${dbdir}/2bit_westerbork_bursts_r147.csv"  # 2bit bursts - DONE - 21Jan
    #db="${dbdir}/stockert_bursts_r147.csv" # Stockert bursts - DONE
    #db="${dbdir}/westerbork_pband.csv" # Pband Done - 26-Jan
    #db="${dbdir}/hyperflash_westerbork_L.csv" # TBD
    #db="${dbdir}/hyperflash_onsala_L.csv" # TBD
    #db="${dbdir}/hyperflash_torun_L.csv" # TBD
    
    echo "Setting dspsr DM to $DM_dspsr"
    
    dms=( ${DM_sfxc} ${DM_dspsr} ${DM_dspsr} )

    #The name of stockert burst will be the MJD of detection
    if [[ ${dish} == 'st' ]];then
        arbase=${exp}_${scan}
    fi

    expbasedir=${basedir}/${exp}
    sfxc_file=${expbasedir}/sfxc/${arbase}.ds.pazi
    scale_file=${expbasedir}/scale_spc/${arbase}_allIFs.vdif_pol2.fil.scale.ds.pazi
    spc_file=${expbasedir}/scale_spc/${arbase}_allIFs.vdif_pol2.fil.scale.spc.ds.pazi
    fs="${sfxc_file} ${scale_file} ${spc_file}"
    fscrunch=${Fscrunch}
    tscrunch=${Tscrunch}
    cnt=0

    for f in ${fs}; do
        if ! [ -e ${f} ];then
            echo "${f} doesn't exist. Moving on..."
            let cnt=${cnt}+1
            continue
        fi
        #db="${dbs[${cnt}]}"
        dm="${dms[${cnt}]}"
        src="${srcs[${cnt}]}"
        comp_to="${compare_to[${cnt}]}"
        if [[ ${dish} == 'st' ]];then
            dm=${DM_dspsr}
            #fscrunch=1
            #tscrunch=1
        fi
        cmd="python3 ${ACF_archive} ${ACF_archive_params} --id ${id} --fscrunch ${fscrunch} --tscrunch ${tscrunch} -d ${dm} --db ${db} --src ${src} -S ${sefd} ${comp_to} ${f}"

        echo "running ${cmd}"
        eval ${cmd}
        let cnt=${cnt}+1
    done
done
