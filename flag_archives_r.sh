#!/bin/bash

#####################
#
# This script takes the flag files 
# into the git repo and applies them to the scaled, SPC'ed, and SFXC archives with 'paz'.
#
# For stockert we automatically make a zap file with 0 and 168; if that is not enough I used paz to zap the channels manually and add them to the flag file
#
# Once all the flags are applied, we can start to compute fluences, S/N, widths, TOAs...
#
# Command for stockert list
# ls *ds.ar | sort -t '/' -k 4 | cut -d '.' -f 1 | cut -c 8- |sed -e 's;^;#"stocke st ;' | sed '$!s/$/" \\/'
# First prep, then flag
####################


pwait() {
    while [ $(jobs -p | wc -l) -ge $1 ]; do
	sleep 0.33
    done
}
njobs=16

outbasedir=/data1/omar/
flagrundir=/home/omar/git/r147-single-dish-analysis/flags/

runs=( \
# exp dish scan flag
## Westerbork L-band
#"pcn254 wb 12" \
#"p47018 wb 24" \
#"p47019 wb 21" \
#"p47019 wb 33" \
#"p47019 wb 36" \
#"p47019 wb 37" \
#"p47020 wb 19" \
#"p47020 wb 25" \
#"p47021 wb 11" \
#"p47021-2 wb 13" \
#"p47021 wb 13" \
#"p47021 wb 04" \
#"p47021 wb 06" \
#"p47021 wb 08" \
#"p47021 wb 09" \
#"p47031 wb 20" \
#"p47031 wb 36" \
#"p55084 wb 34" \
#"p55092 wb 32" \
#"p55097 wb 41" \
#"p55158 wb 47" \
#"p55173 wb 40" \
#"p55179 wb 40" \
#"p55179 wb 44" \
#"p55179 wb 47" \
#"p55179 wb 51" \
#"p55179-2 wb 51" \
#"p55179 wb 54" \
#"p55182 wb 55" \
#p55183 wb 50" \
#p55186 wb 08" \
#"p55195 wb 29" \
#"p55197 wb 42" \
#"p55293 wb 11" \
#"p55299 wb 125" \
#"p47085 wb 11" \
#"p47057 wb 36" \
#"p47065 wb 33" \
#"p47066 wb 16" \

# P-band
#"p47030 wb 21" \
#"pcn242 wb 23" \

##TORUN
#"rn1l10 tr 11" \
#"rn1l10 tr 13" \
#"rn1l10 tr 15" \
#"rn1l10 tr 16" \
#"rn1l10 tr 22" \
#5
#"rn1l10 tr 23" \
#"rn1l10 tr 07" \
#"rn1l11 tr 13" \
#"rn1l11 tr 14" \
#"rn1l11-2 tr 14 L" \
#10
#"rn1l11 tr 17 L" \
#"rn1l11 tr 23 L" \
#"rn1l12 tr 04 L" \
#"rn1l13 tr 20 L" \
#"rn1l33 tr 10 L" \
#15
#"rn1l40 tr 17 L" \
#"rn1l58 tr 23 L" \
#"rn1l59 tr 16 L" \
#"rn1l62 tr 14 L" \
#"rn1l64 tr 15 L" \
#20
#"rn1l64 tr 04 L" \
#"rn1l65 tr 10 L" \
#"rn1l65 tr 14 L" \
#"rn1l65 tr 01 L" \
#"rn1l65 tr 06 L" \
#25
#"rn1l66 tr 11 L" \
#"rn1l67 tr 14 L" \
#"rn1l70 tr 07 L" \
#"rn1l81 tr 16 L" \
#"rn1l81 tr 21 L" \
#30
#"rn1l82 tr 20 L" \
#"rn1l83 tr 07 L" \
#"rn1l84 tr 14 L" \
#"rn1l84 tr 15 L" \
#"rn1l87 tr 05 L" \
#35
#"rn1l89 tr 02 L" \
#"rn1l90 tr 22 L" \
#37

##ONSALA
#"p47024 o8 24" \
#"p47024 o8 26" \
#"p47024 o8 32" \
#"p47024-2 o8 32" \
#"p47024 o8 34" \
#5
#"p47024-2 o8 34" \
#"p47024 o8 35" \
#"p47024 o8 03" \
#"p47024 o8 38" \
#"p47024 o8 08" \
#10
#"p47025 o8 11" \
#"p47025 o8 13" \
#"p47025 o8 14" \
#"p47025 o8 16" \
#"p47025 o8 22" \
#15
#"p47025 o8 24" \
#"p47025 o8 02" \
#"p47025 o8 26" \
#"p47025-2 o8 26" \
#"p47025 o8 27" \
#20
#"p47025 o8 29" \
#"p47025 o8 30" \
#"p47025 o8 34" \
#"p47025 o8 36" \
#"p47025 o8 42" \
#25
#"p47025 o8 04" \
#"p47025 o8 05" \
#"p47025 o8 08" \
#"p47025 o8 09" \
#"p47026 o8 13" \
#30
#"p47026 o8 16" \
#"p47026 o8 19" \
#"p47026 o8 21" \
#"p47026 o8 28" \
#"p47026 o8 40" \
#35
#"p47026 o8 04" \
#"p47026 o8 05" \
#"p47026 o8 06" \
#"p47027 o8 10" \
#"p47027 o8 18" \
#40
#"p47028 o8 24" \
#"p47030 o8 23" \
#"p47030 o8 31" \
#"p47030 o8 39" \
#"p47038 o8 43" \
#45
#"p47064 o8 38" \
#"p47068 o8 29" \
#"p49035 o8 27" \
#48


# Stockert
#"stocke st 60357_3437816" \
#"stocke st 60357_4385230" \
#"stocke st 60361_5475088" \
#"stocke st 60366_3461485" \
#"stocke st 60369_3359967" \
#"stocke st 60371_2798981" \
#"stocke st 60372_5113801" \
#"stocke st 60373_4876754" \
#"stocke st 60373_5456450" \
#"stocke st 60374_3189053" \
#"stocke st 60375_2980335" \
#"stocke st 60375_3037769" \
#"stocke st 60375_4292868" \
#"stocke st 60375_4311251" \
#"stocke st 60375_4726520" \
#"stocke st 60376_3217991" \
#"stocke st 60376_3316630" \
#"stocke st 60377_2533142" \
#"stocke st 60377_3150949" \
#"stocke st 60377_3732605" \
#"stocke st 60377_4371665" \
#"stocke st 60377_4588314" \
#"stocke st 60377_6264129" \
#"stocke st 60378_2170109" \
#"stocke st 60378_3133708" \
#"stocke st 60378_4604753" \
#"stocke st 60379_2275323" \
#"stocke st 60379_2555746" \
#"stocke st 60379_2602165" \
#"stocke st 60379_2695980" \
#"stocke st 60379_3517707" \
#"stocke st 60379_4008061" \
#"stocke st 60379_5397914" \
#"stocke st 60380_2760984" \
#"stocke st 60380_3969765" \
#"stocke st 60380_3998840" \
#"stocke st 60380_4319492" \
#"stocke st 60380_4447753" \
#"stocke st 60380_4521409" \
#"stocke st 60380_5269620" \
#"stocke st 60380_5962205" \
#"stocke st 60381_1949711" \
#"stocke st 60381_2067454" \
#"stocke st 60381_2191585" \
#"stocke st 60381_3044108" \
#"stocke st 60381_4497249" \
#"stocke st 60381_4719812" \
#"stocke st 60382_4597962" \
#"stocke st 60382_5860243" \
#"stocke st 60383_2684445" \
#"stocke st 60383_3537691" \
#"stocke st 60384_4111808" \
#"stocke st 60386_4857456" \
#"stocke st 60387_3671739" \
#"stocke st 60388_4505749" \
#"stocke st 60390_2765210" \
#"stocke st 60390_4257662" \
#"stocke st 60391_5690699" \
#"stocke st 60392_5928489" \
#"stocke st 60393_5544964" \
#"stocke st 60394_3474146" \
#"stocke st 60394_5868739" \
#"stocke st 60396_2482285" \
#"stocke st 60424_4337451" \
#"stocke st 60425_4424318" \
#"stocke st 60431_4377754" \
#"stocke st 60433_2247390" \
#"stocke st 60458_0742204" \
#"stocke st 60803_2202071" \

##2 bit upsampled bursts
#"p47018 wb 17" \
#"p47019 wb 18" \
#"p47020 wb 16" \
#"p47021 wb 7" \
#"p47021 wb 11" \
#"p47022 wb 18" \
#"p47022 wb 22" \
#"p47023 wb 15" \
#"p47023 wb 21" \
#"p47069 wb 7" \
#"p47091 wb 18" \
#"p55020 wb 37" \
#"p55182 wb 32" \
#"p55195 wb 44" \
#"p55289 wb 90" \
#"p55290 wb 87" \
#"p55291 wb 41" \
#"p55298 wb 73" \
#"p55300 wb 66" \
#"p55300-2 wb 66" \
#"p55192 wb 44" \
)

for run in "${runs[@]}";do
    IFS=" " read -r -a info <<< "${run}"
    exp="${info[0]}"
    dish="${info[1]}"
    scan="${info[2]}"
    band="${info[3]}"
    arbase=${exp}_${dish}_no00${scan}
    flagfile=${arbase}.sh
    echo ${flagfile}

    TWO_BIT_MODUS=false 
    if [ "$TWO_BIT_MODUS" = true ]; then
        echo "2 BIT MODUS ACTIVATED"
        arbase=${exp}_${dish}_no00${scan}_2bit
    fi
    
    #The name of stockert burst will be the MJD of detection
    if [[ ${dish} == 'st' ]];then
        arbase=${exp}_${scan}
    fi

    expbasedir=${outbasedir}/${exp}
    if [ "$dish" = "st" ] && ! [ -e ${flagrundir}/${flagfile} ]; then
        # this is for Stockert only.
        echo -e '#!/bin/bash\npaz -e pazi -z "0 167" $1' > ${flagrundir}/${flagfile}
        echo "created ${expbasedir}/${flagfile} containing"
        cat ${flagrundir}/${flagfile}
    fi

    if [ "$dish" != "st" ] && ! [ -e ${flagrundir}/${flagfile} ]; then
        #standard flag - ez
        echo "MAKING FLAG"
        #echo -e '#!/bin/bash\npaz -e pazi -z "0" $1' > ${flagrundir}/${flagfile}
        
        #Lband - 256 channels, 
        echo -e '#!/bin/bash\npaz -e pazi -z "0 31 32 63 64 95 96 127 128 159 160 191 192 223 224 255" $1' > ${flagrundir}/${flagfile}
        
        #Pband - 2048 channels, missing the top IF
        #echo -e '#!/bin/bash\npaz -e pazi -z "0,1,254,255,256,257,510,511,512,513,766,767,768,769,1022,1023,1024,1025,1278,1279,1280,1281,1534,1535,1536,1537,1790,1791" $1' > ${flagrundir}/${flagfile}
        echo "created ${expbasedir}/${flagfile} containing"
        cat ${flagrundir}/${flagfile}
    fi

    chmod u+x ${flagrundir}/${flagfile}
    sfxc_file=${expbasedir}/sfxc/${arbase}.ds.ar
    scale_file=${expbasedir}/scale_spc/${arbase}_allIFs.vdif_pol2.fil.scale.ds.ar
    spc_file=${expbasedir}/scale_spc/${arbase}_allIFs.vdif_pol2.fil.scale.spc.ds.ar
    #fs="${scale_file} ${spc_file}"
    fs="${sfxc_file} ${scale_file} ${spc_file}"
    for f in ${fs}; do
        if ! [ -e ${f} ];then
            echo "${f} doesn't exist. Moving on..."
            continue
        fi
        cmd="${flagrundir}/${flagfile} ${f}"
        echo "running ${cmd}"
        eval ${cmd}
    done
done

#pazi command:
#When creating the archives files I had to zap channels otherwise the bursts were not visible. First I let this script create the .sh files, then added these channels to that file to zap the bad channels
# p11739_wb_no0018.ds.pazi paz -z "521 522 523 524 525 526 527 528 529 530 531 532 533 534 535 536 537 538 539 540 541 542 543 544 545 546 547 548 549 550 551 552 553 554 555 556 557 558 559 560 561 562 563 564 565 566 567 568 569 570 571 572 573 574 575 576 577 578 579 580 581 582 583 584 585 586 587 588 589 590 591 894 895 896 897" -e pazi p11739_wb_no0018.ds.pazi
#paz -z "886 887 888 889 497 498 415 416" -e pazi p11748_wb_no0020_allIFs.vdif_pol2.fil.scale.ds.ar
#513 514 515 516 517 518 519 520 521 522 41 42 43 44" -e pazi p11739_wb_no0018_allIFs.vdif_pol2.fil.scale.ds.pazi

######
#paz -z "122 123 124 97 98 99 117 118" -e pazi stocke_60357_4385230.ds.ar
#paz -z "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23" -e pazi stocke_60375_4726520.ds.ar
#paz -z "128 129 124 125 119 116 115 112 113 105 120 126 127 70 71 72 73 74 58 59 60 137 162 98" -e pazi stocke_60377_2533142.ds.ar
#paz -z "140 141 142 131 132 94 95 153 154 155 133" -e pazi stocke_60378_2170109.ds.ar
#paz -z "163 164 165 166 167 160 161 162" -e pazi stocke_60378_4604753.ds.ar
#paz -z "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 141" -e pazi stocke_60379_2275323.ds.ar
#paz -z "148" -e pazi stocke_60379_2555746.ds.ar
#paz -z "155 136 137 129 130 127 128 126 122 119 120 118 156 70 71 72 73 74 125 154 133 134" -e pazi stocke_60379_2602165.ds.ar
#paz -z "132 133 125 126 117 118 116 108 109 110 95 96 97 131 134 130" -e pazi stocke_60379_2695980.ds.ar
#paz -z "153 154 155 163 156 157 164 162" -e pazi stocke_60380_3998840.ds.ar
#paz -z "164 165 166 167" -e pazi stocke_60380_4521409.ds.ar
#paz -z "136 137 125 126 127 128 112 113 123 124 98 99 95 96 129 130 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 0 116 108 122 119" -e pazi stocke_60380_5269620.ds.ar
#paz -z "123 124 122 97 98 99 100 141" -e pazi stocke_60381_2191585.ds.ar
#paz -z "154 155 156 157 158 153" -e pazi stocke_60382_5860243.ds.ar
#paz -z "149 150 155 136 137 103 102 99 100 101 146 147 148 154 124" -e pazi stocke_60383_3537691.ds.ar
#
#
#

