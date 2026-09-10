#!/bin/bash
set -e

##############
#
# This is a wrapper around ./python/get_MJD.py which
# combines the info from the ar-files and the pandas data
# frames to fit the bursts in the SFXC/Stockert-filterbanks with
# Guassians to determine the TOAs. For SFXC-filterbanks these
# are geocentric TOAs, while for Stockert they are topocentric at Stockert.
#
# First use prep_sfxc_filterbank to prepare the symlinks for the filterbank files
# The archive files are needed to copy the masks from the archive onto the filterbank files
#############

## References frequencies
#Middle of top subband for EVN dishes and SFXC filterbanks 
#Pband (setup P - 356-4 MHz) - SFXC 
ref_freq_wb_p=352

#Wb L-band (setup L18 - 1335-8 MHz) - SFXC 
ref_freq_wb_1g=1327

#O8 L-band (setup L18 - 1488-8 MHz) - SFXC 
ref_freq_o8_1g=1480

#TR L-band (setup L15-old - 1478-8) - SFXC - from rn1l10 until rn1l12 - only in the beginning
ref_freq_tr_1g=1470

#TR L-band 256 MHZ (setup L5-2 - 1546-16) - SFXC - only 2 bursts
ref_freq_tr_2g=1530

#TR L-band (setup L15 - 1508-8) - SFXC - from rn1l33 onwards
ref_freq_tr_1g_new=1500
 
#Wb L-band 2bit - digifil - middle of the top channel - none will make sure it the High channel in the header
ref_freq_wb_1g_2bit='none'

#St L-band (script will read the header file of the filterbank and take the Highchannel as ref freq)
#ref_freq_st_1g='none'

fscrunch=1
tscrunch=16

# exp dish scan sefd ID ref_freq DM
runs=( \
##TORUN - L-band
#"rn1l10 tr 11 coe B60-tr ${ref_freq_tr_1g} D" \
#"rn1l10 tr 13 coe B61-tr ${ref_freq_tr_1g} D" \
#"rn1l10 tr 15 coe B64-tr ${ref_freq_tr_1g} D" \
#"rn1l10 tr 16 coe B65-tr ${ref_freq_tr_1g} D" \
#"rn1l10 tr 22 coe B66-tr ${ref_freq_tr_1g} D" \
#5
#"rn1l10 tr 23 coe B68-tr ${ref_freq_tr_1g} D" \
#"rn1l10 tr 07 coe B58-tr ${ref_freq_tr_1g} D" \
#"rn1l11 tr 13 coe B85-tr ${ref_freq_tr_1g} D" \
#"rn1l11 tr 14 coe B86-tr ${ref_freq_tr_1g} TO FAINT-skipped" \
#"rn1l11-2 tr 14 coe B87-tr ${ref_freq_tr_1g} REDO" \
#10
#"rn1l11 tr 17 coe B88-tr ${ref_freq_tr_1g} TO FAINT-TOA was possible" \
#"rn1l11 tr 23 coe B90-tr ${ref_freq_tr_1g} D" \
#"rn1l12 tr 04 coe B110-tr ${ref_freq_tr_2g} 256 mhz D" \
#"rn1l13 tr 20 coe B122-tr ${ref_freq_tr_2g} 256 mhz D" \
#"rn1l33 tr 10 coe B134-tr ${ref_freq_tr_1g_new}" \
#15
#"rn1l40 tr 17 coe B137-tr ${ref_freq_tr_1g_new} D" \
#"rn1l58 tr 23 coe B138-tr ${ref_freq_tr_1g_new} D" \
#"rn1l59 tr 16 coe B139-tr ${ref_freq_tr_1g_new} D" \
#"rn1l62 tr 14 coe B141-tr ${ref_freq_tr_1g_new} D" \
#"rn1l64 tr 15 coe B149-tr ${ref_freq_tr_1g_new} D" \
#20
#"rn1l64 tr 04 coe B148-tr ${ref_freq_tr_1g_new} D" \
#"rn1l65 tr 10 coe B154-tr ${ref_freq_tr_1g_new} D" \
#"rn1l65 tr 14 coe B155-tr ${ref_freq_tr_1g_new} D" \
#"rn1l65 tr 01 coe B152-tr ${ref_freq_tr_1g_new} D" \
#"rn1l65 tr 06 coe B153-tr ${ref_freq_tr_1g_new} D" \
#25
#"rn1l66 tr 11 coe B157-tr ${ref_freq_tr_1g_new} D" \
#"rn1l67 tr 14 coe B158-tr ${ref_freq_tr_1g_new} D" \
#"rn1l70 tr 07 coe B163-tr ${ref_freq_tr_1g_new} D" \
#"rn1l81 tr 16 coe B164-tr ${ref_freq_tr_1g_new} D" \
#"rn1l81 tr 21 coe B165-tr ${ref_freq_tr_1g_new} D" \
#30
#"rn1l82 tr 20 coe B166-tr ${ref_freq_tr_1g_new} D" \
#"rn1l83 tr 07 coe B167-tr ${ref_freq_tr_1g_new} D" \
#"rn1l84 tr 14 coe B168-tr ${ref_freq_tr_1g_new} D" \
#"rn1l84 tr 15 coe B169-tr ${ref_freq_tr_1g_new} D" \
#"rn1l87 tr 05 coe B174-tr ${ref_freq_tr_1g_new} D" \
#35
#"rn1l89 tr 02 coe B176-tr ${ref_freq_tr_1g_new} D" \
#"rn1l90 tr 22 coe B180-tr ${ref_freq_tr_1g_new} D" \
#37

###Onsala L-band
#"p47024 o8 24 coe B63-o8 ${ref_freq_o8_1g} D" \
#"p47024 o8 26 coe B65-o8 ${ref_freq_o8_1g} D" \
#"p47024 o8 32 coe B67-o8 ${ref_freq_o8_1g} D" \
#"p47024-2 o8 32 coe B68-o8 ${ref_freq_o8_1g} D" \
#"p47024 o8 34 coe B70-o8 ${ref_freq_o8_1g} D" \
#5
#"p47024-2 o8 34 coe B71-o8 ${ref_freq_o8_1g} D" \
#"p47024 o8 35 coe B72-o8 ${ref_freq_o8_1g} D" \
#"p47024 o8 03 coe B56-o8 ${ref_freq_o8_1g} D" \
#"p47024 o8 38 coe B73-o8 ${ref_freq_o8_1g} D" \
#"p47024 o8 08 coe B57-o8 ${ref_freq_o8_1g} D" \
#10
#"p47025 o8 11 coe B79-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 13 coe B80-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 14 coe B81-o8 ${ref_freq_o8_1g} DEEMED NOT REAL" \
#"p47025 o8 16 coe B82-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 22 coe B83-o8 ${ref_freq_o8_1g} D" \
#15
#"p47025 o8 24 coe B84-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 02 coe B74-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 26 coe B85-o8 ${ref_freq_o8_1g} D" \
#"p47025-2 o8 26 coe B86-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 27 coe B87-o8 ${ref_freq_o8_1g} D" \
#20
#"p47025 o8 29 coe B88-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 30 coe B89-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 34 coe B90-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 36 coe B91-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 42 coe B92-o8 ${ref_freq_o8_1g} D" \
#25
#"p47025 o8 04 coe B75-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 05 coe B76-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 08 coe B77-o8 ${ref_freq_o8_1g} D" \
#"p47025 o8 09 coe B78-o8 ${ref_freq_o8_1g} D" \
#"p47026 o8 13 coe B96-o8 ${ref_freq_o8_1g} D" \
#30
#"p47026 o8 16 coe B97-o8 ${ref_freq_o8_1g} D" \
#"p47026 o8 19 coe B98-o8 ${ref_freq_o8_1g} D" \
#"p47026 o8 21 coe B99-o8 ${ref_freq_o8_1g} D" \
#"p47026 o8 28 coe B100-o8 ${ref_freq_o8_1g} D" \
#"p47026 o8 40 coe B101-o8 ${ref_freq_o8_1g} D" \
#35
#"p47026 o8 04 coe B93-o8 ${ref_freq_o8_1g} D" \
#"p47026 o8 05 coe B94-o8 ${ref_freq_o8_1g} D" \
#"p47026 o8 06 coe B95-o8 ${ref_freq_o8_1g} D" \
#"p47027 o8 10 coe B102-o8 ${ref_freq_o8_1g} D" \
#"p47027 o8 18 coe B103-o8 ${ref_freq_o8_1g} D" \
#40
#"p47028 o8 24 coe B104-o8 ${ref_freq_o8_1g} D" \
#"p47030 o8 23 coe B106-o8 ${ref_freq_o8_1g} D" \
#"p47030 o8 31 coe B107-o8 ${ref_freq_o8_1g} D" \
#"p47030 o8 39 coe B108-o8 ${ref_freq_o8_1g} D" \
#"p47038 o8 43 coe B120-o8 ${ref_freq_o8_1g} D" \
#45
#"p47064 o8 38 coe B125-o8 ${ref_freq_o8_1g} D" \
#"p47068 o8 29 coe B128-o8 ${ref_freq_o8_1g} D" \
#"p49035 o8 27 coe B162-o8 ${ref_freq_o8_1g} D" \
#48

##Westerbork P-band
#"p47030 wb 21 coe B105-wb ${ref_freq_wb_p} " \
#"pcn242 wb 23 coe B01-wb ${ref_freq_wb_p} " \

#EVN dishes L-band
##Westerbork
#"pcn254 wb 12 coe B02-wb ${ref_freq_wb_1g} D" \
#"p47018 wb 24 coe B09-wb ${ref_freq_wb_1g} D" \
#"p47019 wb 21 coe B11-wb ${ref_freq_wb_1g} D" \
#"p47019 wb 33 coe B12-wb ${ref_freq_wb_1g} D" \
#"p47019 wb 36 coe B13-wb ${ref_freq_wb_1g} D" \
#5
#"p47019 wb 37 coe B14-wb ${ref_freq_wb_1g} D" \
#"p47020 wb 19 coe B18-wb ${ref_freq_wb_1g} D" \
#"p47020 wb 25 coe B19-wb ${ref_freq_wb_1g} D" \
#"p47021 wb 11 coe B30-wb ${ref_freq_wb_1g} D" \
#"p47021-2 wb 13 coe B33-wb ${ref_freq_wb_1g} D" \
#10
#"p47021 wb 13 coe B32-wb ${ref_freq_wb_1g} D" \
#"p47021 wb 04 coe B25-wb ${ref_freq_wb_1g} D" \
#"p47021 wb 06 coe B26-wb ${ref_freq_wb_1g} D" \
#"p47021 wb 08 coe B28-wb ${ref_freq_wb_1g} D" \
#"p47021 wb 09 coe B29-wb ${ref_freq_wb_1g} D" \
#15
#"p47031 wb 20 coe B110-wb ${ref_freq_wb_1g} D" \
#"p47031 wb 36 coe B112-wb ${ref_freq_wb_1g} D" \
#"p55084 wb 34 coe B135-wb ${ref_freq_wb_1g} D" \
#"p55092 wb 32 coe B136-wb ${ref_freq_wb_1g} D" \
#"p55097 wb 41 coe B137-wb ${ref_freq_wb_1g} D" \
#20
#"p55158 wb 47 coe B139-wb ${ref_freq_wb_1g} D" \
#"p55173 wb 40 coe B140-wb ${ref_freq_wb_1g} D" \
#"p55179 wb 40 coe B142-wb ${ref_freq_wb_1g} D" \
#"p55179 wb 44 coe B143-wb ${ref_freq_wb_1g} D" \
#"p55179 wb 47 coe B144-wb ${ref_freq_wb_1g} D" \
#25
#"p55179 wb 51 coe B145-wb ${ref_freq_wb_1g} D" \
#"p55179-2 wb 51 coe B146-wb ${ref_freq_wb_1g} D" \
#"p55179 wb 54 coe B147-wb ${ref_freq_wb_1g} D" \
#"p55182 wb 55 coe B151-wb ${ref_freq_wb_1g} D" \
#"p55183 wb 50 coe B156-wb ${ref_freq_wb_1g} D" \
#30
#"p55186 wb 08 coe B158-wb ${ref_freq_wb_1g} D" \
#"p55195 wb 29 coe B160-wb ${ref_freq_wb_1g} D" \
#"p55197 wb 42 coe B163-wb ${ref_freq_wb_1g} D" \
#"p55293 wb 11 coe B173-wb ${ref_freq_wb_1g} D" \
#"p55299 wb 125 coe B177-wb ${ref_freq_wb_1g} D-changed manually some names" \
#35
#"p47085 wb 11 coe B130-wb ${ref_freq_wb_1g} D" \
#"p47057 wb 36 coe B123-wb ${ref_freq_wb_1g} D" \
#"p47065 wb 33 coe B126-wb ${ref_freq_wb_1g} D" \
#"p47066 wb 16 coe B127-wb ${ref_freq_wb_1g} D" \


# 2 bit bursts - Westerbork
#"p47018 wb 17 wb B07-wb ${ref_freq_wb_1g_2bit} D" \
#"p47019 wb 18 wb B10-wb ${ref_freq_wb_1g_2bit} D" \
#"p47020 wb 16 wb B17-wb ${ref_freq_wb_1g_2bit} D" \
#"p47021 wb 07 wb B27-wb ${ref_freq_wb_1g_2bit} D" \
#"p47021 wb 11 wb B31-wb ${ref_freq_wb_1g_2bit} D" \
#"p47022 wb 18 wb B46-wb ${ref_freq_wb_1g_2bit} D" \
#"p47022 wb 22 wb B47-wb ${ref_freq_wb_1g_2bit} D" \
#"p47023 wb 15 wb B48-wb ${ref_freq_wb_1g_2bit} to faint, only reporting on burst" \
#"p47023 wb 21 wb B52-wb ${ref_freq_wb_1g_2bit} D" \
#"p47069 wb 07 wb B129-wb ${ref_freq_wb_1g_2bit} D" \
###10
#"p47091 wb 18 wb B132-wb ${ref_freq_wb_1g_2bit} D" \
#"p55020 wb 37 wb B133-wb ${ref_freq_wb_1g_2bit} D" \
#"p55182 wb 32 wb B150-wb ${ref_freq_wb_1g_2bit} D" \
#"p55192 wb 44 wb B159-wb ${ref_freq_wb_1g_2bit} D" \
#"p55195 wb 44 wb B161-wb ${ref_freq_wb_1g_2bit} D" \
#"p55289 wb 90 wb B170-wb ${ref_freq_wb_1g_2bit} D" \
#"p55290 wb 87 wb B171-wb ${ref_freq_wb_1g_2bit} D" \
#"p55291 wb 41 wb B172-wb ${ref_freq_wb_1g_2bit} D" \
#"p55298 wb 73 wb B175-wb ${ref_freq_wb_1g_2bit} D" \
#"p55300 wb 66 wb B178-wb ${ref_freq_wb_1g_2bit} D" \
###20
#"p55300-2 wb 66 wb B179-wb ${ref_freq_wb_1g_2bit} D" \

# Stockert burst - finsished on Feb17-2026
#"stocke st 60357_3437816 st B03-st ${ref_freq_st_1g} D" \
#"stocke st 60357_4385230 st B04-st ${ref_freq_st_1g} D" \
#"stocke st 60361_5475088 st B05-st ${ref_freq_st_1g} D" \
#"stocke st 60366_3461485 st B06-st ${ref_freq_st_1g} D" \
#"stocke st 60369_3359967 st B08-st ${ref_freq_st_1g} D" \
#"stocke st 60371_2798981 st B15-st ${ref_freq_st_1g} D" \
#"stocke st 60372_5113801 st B16-st ${ref_freq_st_1g} D" \
#"stocke st 60373_4876754 st B20-st ${ref_freq_st_1g} D" \
#"stocke st 60373_5456450 st B21-st ${ref_freq_st_1g} D" \
#"stocke st 60374_3189053 st B22-st ${ref_freq_st_1g} D" \
###10
#"stocke st 60375_2980335 st B23-st ${ref_freq_st_1g} D" \
#"stocke st 60375_3037769 st B24-st ${ref_freq_st_1g} D" \
#"stocke st 60375_4292868 st B30-st ${ref_freq_st_1g} D" \
#"stocke st 60375_4311251 st B31-st ${ref_freq_st_1g} D" \
#"stocke st 60375_4726520 st B34-st ${ref_freq_st_1g} D" \
#"stocke st 60376_3217991 st B35-st ${ref_freq_st_1g} D" \
#"stocke st 60376_3316630 st B36-st ${ref_freq_st_1g} D" \
#"stocke st 60377_2533142 st B37-st ${ref_freq_st_1g} D" \
#"stocke st 60377_3150949 st B38-st ${ref_freq_st_1g} D" \
#"stocke st 60377_3732605 st B39-st ${ref_freq_st_1g} D" \
###20
#"stocke st 60377_4371665 st B40-st ${ref_freq_st_1g} D" \
#"stocke st 60377_4588314 st B41-st ${ref_freq_st_1g} D" \
#"stocke st 60377_6264129 st B42-st ${ref_freq_st_1g} D" \
#"stocke st 60378_2170109 st B43-st ${ref_freq_st_1g} D" \
#"stocke st 60378_3133708 st B44-st ${ref_freq_st_1g} D" \
#"stocke st 60378_4604753 st B45-st ${ref_freq_st_1g} D" \
#"stocke st 60379_2275323 st B56-st ${ref_freq_st_1g} D" \
#"stocke st 60379_2555746 st B49-st ${ref_freq_st_1g} D" \
#"stocke st 60379_2602165 st B50-st ${ref_freq_st_1g} D" \
#"stocke st 60379_2695980 st B51-st ${ref_freq_st_1g} D" \
###30
#"stocke st 60379_3517707 st B53-st ${ref_freq_st_1g} D" \
#"stocke st 60379_4008061 st B54-st ${ref_freq_st_1g} D" \
#"stocke st 60379_5397914 st B55-st ${ref_freq_st_1g} D" \
#"stocke st 60380_2760984 st B57-st ${ref_freq_st_1g} D" \
#"stocke st 60380_3969765 st B58-st ${ref_freq_st_1g} D" \
#"stocke st 60380_3998840 st B59-st ${ref_freq_st_1g} D" \
#"stocke st 60380_4319492 st B60-st ${ref_freq_st_1g} D" \
#"stocke st 60380_4447753 st B61-st ${ref_freq_st_1g} D" \
#"stocke st 60380_4521409 st B62-st ${ref_freq_st_1g} D" \
#"stocke st 60380_5269620 st B66-st ${ref_freq_st_1g} D" \
###40
#"stocke st 60380_5962205 st B73-st ${ref_freq_st_1g} D" \
#"stocke st 60381_1949711 st B74-st ${ref_freq_st_1g} D" \
#"stocke st 60381_2067454 st B75-st ${ref_freq_st_1g} D" \
#"stocke st 60381_2191585 st B76-st ${ref_freq_st_1g} D" \
#"stocke st 60381_3044108 st B80-st ${ref_freq_st_1g} D" \
#"stocke st 60381_4497249 st B87-st ${ref_freq_st_1g} D" \
#"stocke st 60381_4719812 st B88-st ${ref_freq_st_1g} D" \
#"stocke st 60382_4597962 st B100-st ${ref_freq_st_1g} D" \
#"stocke st 60382_5860243 st B101-st ${ref_freq_st_1g} D" \
#"stocke st 60383_2684445 st B102-st ${ref_freq_st_1g} D" \
###50
#"stocke st 60383_3537691 st B103-st ${ref_freq_st_1g} D" \
#"stocke st 60384_4111808 st B104-st ${ref_freq_st_1g} D" \
#"stocke st 60386_4857456 st B107-st ${ref_freq_st_1g} D" \
#"stocke st 60387_3671739 st B109-st ${ref_freq_st_1g} D" \
#"stocke st 60388_4505749 st B113-st ${ref_freq_st_1g} D" \
#"stocke st 60390_2765210 st B114-st ${ref_freq_st_1g} D" \
#"stocke st 60390_4257662 st B115-st ${ref_freq_st_1g} D" \
#"stocke st 60391_5690699 st B116-st ${ref_freq_st_1g} D" \
#"stocke st 60392_5928489 st B117-st ${ref_freq_st_1g} D" \
#"stocke st 60393_5544964 st B118-st ${ref_freq_st_1g} D" \
###60
#"stocke st 60394_3474146 st B119-st ${ref_freq_st_1g} D" \
#"stocke st 60394_5868739 st B120-st ${ref_freq_st_1g} D" \
#"stocke st 60396_2482285 st B121-st ${ref_freq_st_1g} D" \
#"stocke st 60424_4337451 st B123-st ${ref_freq_st_1g} D" \
#"stocke st 60425_4424318 st B124-st ${ref_freq_st_1g} D" \
#"stocke st 60431_4377754 st B125-st ${ref_freq_st_1g} D" \
#"stocke st 60433_2247390 st B127-st ${ref_freq_st_1g} D" \
#"stocke st 60458_0742204 st B131-st ${ref_freq_st_1g} D" \
#"stocke st 60803_2202071 st B167-st ${ref_freq_st_1g} D" \

#2 bit upsampled bursts
#Doing this manually probably
)

basedir=/data1/omar/
dbdir=/home/omar/git/r147-single-dish-analysis/databases

get_MJD=./python/get_MJD.py

for run in "${runs[@]}";do
    IFS=" " read -r -a info <<< "${run}"
    exp="${info[0]}"
    dish="${info[1]}"
    scan="${info[2]}"
    loc="${info[3]}"
    id="${info[4]}"
    refFreq="${info[5]}"
    dm=527.7
    src='sfxc'
    src_dir='sfxc'
    freqref="--ref_freq ${refFreq}"
    if [[ ${refFreq} == 'none' ]];then
        freqref=''
    fi
    if [[ ${loc} == 'coe' ]];then
        dm=0.0
    fi

    #The name of stockert burst will be the MJD of detection
    if [[ ${dish} == 'st' ]];then
        arbase=${exp}_${scan}
    else
        arbase=${exp}_${dish}_no00${scan}
    fi

    expbasedir=${basedir}/${exp}
    arfile=${expbasedir}/${src_dir}/${arbase}.ds.pazi
    filfile=${expbasedir}/${src_dir}/${arbase}.ds.fil
    
    if [[ "$refFreq" = "$ref_freq_wb_1g_2bit" ]]; then
        arfile=${expbasedir}/${src_dir}/${arbase}_2bit.ds.pazi
        filfile=${expbasedir}/${src_dir}/${arbase}_2bit.ds.fil
    fi
    
    #rule for burst_time 2.0 and 0.5 seconds for P- and L-band
    if [[ "$refFreq" = "$ref_freq_wb_1g" ]]; then
        burst_time_s=1.0 
        db="${dbdir}/hyperflash_westerbork_L.csv"  # everything goes here for Lband 
    elif [[ "$refFreq" = "$ref_freq_wb_p" ]]; then
        burst_time_s=1.0 
        db="${dbdir}/westerbork_pband.csv" 
    elif [[ "$refFreq" = "$ref_freq_tr_1g" || \
            "$refFreq" = "$ref_freq_tr_1g_new" || \
            "$refFreq" = "$ref_freq_tr_2g" ]]; then
        burst_time_s=1.0 
        db="${dbdir}/hyperflash_torun_L.csv"
    elif [[ "$refFreq" = "$ref_freq_o8_1g" ]]; then
        burst_time_s=1.0 
        db="${dbdir}/hyperflash_onsala_L.csv" 
    elif [[ "$refFreq" = "$ref_freq_st_1g" ]]; then
        burst_time_s=1.5 
        db="${dbdir}/stockert_bursts_r147.csv"  # everything goes here for Lband - stockert
    elif [[ "$refFreq" = "$ref_freq_wb_1g_2bit" ]]; then
        burst_time_s=4.0
        db="${dbdir}/2bit_westerbork_bursts_r147.csv"  # everything goes here for Lband - stockert 
    else 
        burst_time_s=0.5
        #db="${dbdir}/hyperflash_mkt_burst_db.csv"  # everything goes here for Lband
    fi

    cmd="python3 ${get_MJD} -d ${dm} --db ${db} --src ${src} --arfile ${arfile} --fscrunch ${fscrunch} --tscrunch ${tscrunch} --burst_time ${burst_time_s} --ID ${id} ${freqref} --location ${loc} ${filfile} --show_dynspec"

    echo "running ${cmd}"
    eval ${cmd}
done
