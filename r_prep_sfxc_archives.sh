#!/bin/bash

###################
# These dataproducts are used in the determination of the burst properties. 
# Note: the other script (prep_filterbanks) are used for the ToA
# !! First prep, then flag
#
# Before runnning this script you need to:
# - Create the archive files using archive generate files
# - Optional: Create the flag files and store them in flags -> but you can base the flag on the spc/scale version, since we will apply the same flag to all 3 files
#
# This script takes the archive-files as generated from the
# coherently dedispersed SFXC-filterbanks and performs the
# following steps:
# - downsample in time to 64 us
# - downsample in freq to 62.5 kHz
# - generate Stokes I
# This time frequency resolution is chosen, since to be identical to the SPC/SCALE versions
#
# for 2bit bursts, there is an extension on the name in the downsampled (ds) archives files, -2bit
# This is controlled with a boolean expression in the code
#
# Command used to generate the SFXC ar list
# ls *.ar | sort | awk -F'[_]' '{station=tolower($(NF-1)); print "#\"" $1, station, $2, "L", $0, "\" \\"}'
#
# Command used to generate Westerbork list (made with chatgpt)
# ls *.ar | sort -t '/' -k 4 | awk -F'[_]' '{print "#\"" $1, "wb", $2, "L", $1"_"$2, $0 "\" \\"}'
#
# Command used to generate stockert list
# ls *.ar | sort -t '/' -k 4 | sed -e 's;^;#"stocke st 01 L 01 ;' | sed '$!s/$/" \\/'
###################

sfxc_dir=/data1/omar/sfxc/frb240114a/fil_to_archives
sfxc_dir_st=/data1/omar/sfxc/frb240114a/fil_to_archives_stockert
sfxc_dir_2bit=/data1/omar/sfxc/frb240114a/fil_to_archives_2bit
outbasedir=/data1/omar/

runs=( \
# exp dish scan sfxc
# L-band
#"p47018 wb 24 L p47018_24_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47019 wb 21 L p47019_21_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47019 wb 33 L p47019_33_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47019 wb 36 L p47019_36_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47019 wb 37 L p47019_37_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47020 wb 19 L p47020_19_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47020 wb 25 L p47020_25_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47021 wb 11 L p47021_11_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47021-2 wb 13 L p47021_13_2_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47021 wb 13 L p47021_13_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47021 wb 04 L p47021_4_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47021 wb 06 L p47021_6_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47021 wb 08 L p47021_8_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47021 wb 09 L p47021_9_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47024 o8 24 L p47024_24_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47024 o8 26 L p47024_26_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47024 o8 32 L p47024_32_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47024-2 o8 32 L p47024_32_2_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47024 o8 34 L p47024_34_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47024-2 o8 34 L p47024_34_2_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47024 o8 35 L p47024_35_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47024 o8 3 L p47024_3_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47024 o8 38 L p47024_38_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47024 o8 08 L p47024_8_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 11 L p47025_11_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 13 L p47025_13_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 14 L p47025_14_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 16 L p47025_16_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 22 L p47025_22_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 24 L p47025_24_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 02 L p47025_2_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 26 L p47025_26_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025-2 o8 26 L p47025_26_2_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 27 L p47025_27_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 29 L p47025_29_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 30 L p47025_30_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 34 L p47025_34_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 36 L p47025_36_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 42 L p47025_42_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 04 L p47025_4_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 05 L p47025_5_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 08 L p47025_8_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47025 o8 09 L p47025_9_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47026 o8 13 L p47026_13_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47026 o8 16 L p47026_16_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47026 o8 19 L p47026_19_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47026 o8 21 L p47026_21_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47026 o8 28 L p47026_28_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47026 o8 40 L p47026_40_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47026 o8 04 L p47026_4_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47026 o8 05 L p47026_5_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47026 o8 06 L p47026_6_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47027 o8 10 L p47027_10_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47027 o8 18 L p47027_18_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47028 o8 24 L p47028_24_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47030 wb 21 L p47030_21_256us_32KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47030 o8 23 L p47030_23_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47030 o8 31 L p47030_31_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47030 o8 39 L p47030_39_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47031 wb 20 L p47031_20_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47031 wb 36 L p47031_36_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47038 o8 43 L p47038_43_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47057 wb 36 L p47057_36_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47064 o8 38 L p47064_38_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47065 wb 33 L p47065_33_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47066 wb 16 L p47066_16_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p47068 o8 29 L p47068_29_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p47085 wb 11 L p47085_11_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p49035 o8 27 L p49035_27_64us_125KHz_StokesI_DM5277_cor_O8_fil.ar " \
#"p55084 wb 34 L p55084_34_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55092 wb 32 L p55092_32_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55097 wb 41 L p55097_41_64us_125KHz_StokesI_DM5284_cor_Wb_fil.ar " \
#"p55158 wb 47 L p55158_47_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55173 wb 40 L p55173_40_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55179 wb 40 L p55179_40_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55179 wb 44 L p55179_44_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55179 wb 47 L p55179_47_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55179 wb 51 L p55179_51_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55179-2 wb 51 L p55179_51_2_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55179 wb 54 L p55179_54_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55182 wb 55 L p55182_55_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55183 wb 50 L p55183_50_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55186 wb 08 L p55186_8_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55195 wb 29 L p55195_29_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55197 wb 42 L p55197_42_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55293 wb 11 L p55293_11_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"p55299 wb 125 L p55299_125_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"pcn242 wb 23 L pcn242_23_256us_32KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"pcn254 wb 12 L pcn254_12_64us_125KHz_StokesI_DM5277_cor_Wb_fil.ar " \
#"rn1l10 tr 11 L rn1l10_11_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l10 tr 13 L rn1l10_13_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l10 tr 15 L rn1l10_15_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l10 tr 16 L rn1l10_16_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l10 tr 22 L rn1l10_22_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l10 tr 23 L rn1l10_23_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l10 tr 07 L rn1l10_7_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l11 tr 13 L rn1l11_13_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l11 tr 14 L rn1l11_14_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l11-2 tr 14 L rn1l11_14_2_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l11 tr 17 L rn1l11_17_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l11 tr 23 L rn1l11_23_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l12 tr 04 L rn1l12_4_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l13 tr 20 L rn1l13_20_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l33 tr 10 L rn1l33_10_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l40 tr 17 L rn1l40_17_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l58 tr 23 L rn1l58_23_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l59 tr 16 L rn1l59_16_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l62 tr 14 L rn1l62_14_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l64 tr 15 L rn1l64_15_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l64 tr 04 L rn1l64_4_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l65 tr 10 L rn1l65_10_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l65 tr 14 L rn1l65_14_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l65 tr 01 L rn1l65_1_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l65 tr 06 L rn1l65_6_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l66 tr 11 L rn1l66_11_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l67 tr 14 L rn1l67_14_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l70 tr 07 L rn1l70_7_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l81 tr 16 L rn1l81_16_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l81 tr 21 L rn1l81_21_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l82 tr 20 L rn1l82_20_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l83 tr 07 L rn1l83_7_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l84 tr 14 L rn1l84_14_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l84 tr 15 L rn1l84_15_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l87 tr 05 L rn1l87_5_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l89 tr 02 L rn1l89_2_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \
#"rn1l90 tr 22 L rn1l90_22_64us_125KHz_StokesI_DM5277_cor_Tr_fil.ar " \


# P-band - prepped on Jan-26
#"p47030 wb 21 P p47030_21_256us_32KHz_StokesI_DM5277_cor_Wb_fil.ar" \
#"pcn242 wb 23 P pcn242_23_256us_32KHz_StokesI_DM5277_cor_Wb_fil.ar" \

#Stockert - # Run on Jan 21
#"stocke st 01 L snip60357_3437816.fbspi.fil.ar" \
#"stocke st 01 L snip60357_4385230.fbspi.fil.ar" \
#"stocke st 01 L snip60361_5475088.fbspi.fil.ar" \
#"stocke st 01 L snip60366_3461485.fbspi.fil.ar" \
#"stocke st 01 L snip60369_3359967.fbspi.fil.ar" \
#"stocke st 01 L snip60371_2798981.fbspi.fil.ar" \
#"stocke st 01 L snip60372_5113801.fbspi.fil.ar" \
#"stocke st 01 L snip60373_4876754.fbspi.fil.ar" \
#"stocke st 01 L snip60373_5456450.fbspi.fil.ar" \
#"stocke st 01 L snip60374_3189053.fbspi.fil.ar" \
#"stocke st 01 L snip60375_2980335.fbspi.fil.ar" \
#"stocke st 01 L snip60375_3037769.fbspi.fil.ar" \
#"stocke st 01 L snip60375_4292868.fbspi.fil.ar" \
#"stocke st 01 L snip60375_4311251.fbspi.fil.ar" \
#"stocke st 01 L snip60375_4726520.fbspi.fil.ar" \
#"stocke st 01 L snip60376_3217991.fbspi.fil.ar" \
#"stocke st 01 L snip60376_3316630.fbspi.fil.ar" \
#"stocke st 01 L snip60377_2533142.fbspi.fil.ar" \
#"stocke st 01 L snip60377_3150949.fbspi.fil.ar" \
#"stocke st 01 L snip60377_3732605.fbspi.fil.ar" \
#"stocke st 01 L snip60377_4371665.fbspi.fil.ar" \
#"stocke st 01 L snip60377_4588314.fbspi.fil.ar" \
#"stocke st 01 L snip60377_6264129.fbspi.fil.ar" \
#"stocke st 01 L snip60378_2170109.fbspi.fil.ar" \
#"stocke st 01 L snip60378_3133708.fbspi.fil.ar" \
#"stocke st 01 L snip60378_4604753.fbspi.fil.ar" \
#"stocke st 01 L snip60379_2275323.fbspi.fil.ar" \
#"stocke st 01 L snip60379_2555746.fbspi.fil.ar" \
#"stocke st 01 L snip60379_2602165.fbspi.fil.ar" \
#"stocke st 01 L snip60379_2695980.fbspi.fil.ar" \
#"stocke st 01 L snip60379_3517707.fbspi.fil.ar" \
#"stocke st 01 L snip60379_4008061.fbspi.fil.ar" \
#"stocke st 01 L snip60379_5397914.fbspi.fil.ar" \
#"stocke st 01 L snip60380_2760984.fbspi.fil.ar" \
#"stocke st 01 L snip60380_3969765.fbspi.fil.ar" \
#"stocke st 01 L snip60380_3998840.fbspi.fil.ar" \
#"stocke st 01 L snip60380_4319492.fbspi.fil.ar" \
#"stocke st 01 L snip60380_4447753.fbspi.fil.ar" \
#"stocke st 01 L snip60380_4521409.fbspi.fil.ar" \
#"stocke st 01 L snip60380_5269620.fbspi.fil.ar" \
#"stocke st 01 L snip60380_5962205.fbspi.fil.ar" \
#"stocke st 01 L snip60381_1949711.fbspi.fil.ar" \
#"stocke st 01 L snip60381_2067454.fbspi.fil.ar" \
#"stocke st 01 L snip60381_2191585.fbspi.fil.ar" \
#"stocke st 01 L snip60381_3044108.fbspi.fil.ar" \
#"stocke st 01 L snip60381_4497249.fbspi.fil.ar" \
#"stocke st 01 L snip60381_4719812.fbspi.fil.ar" \
#"stocke st 01 L snip60382_4597962.fbspi.fil.ar" \
#"stocke st 01 L snip60382_5860243.fbspi.fil.ar" \
#"stocke st 01 L snip60383_2684445.fbspi.fil.ar" \
#"stocke st 01 L snip60383_3537691.fbspi.fil.ar" \
#"stocke st 01 L snip60384_4111808.fbspi.fil.ar" \
#"stocke st 01 L snip60386_4857456.fbspi.fil.ar" \
#"stocke st 01 L snip60387_3671739.fbspi.fil.ar" \
#"stocke st 01 L snip60388_4505749.fbspi.fil.ar" \
#"stocke st 01 L snip60390_2765210.fbspi.fil.ar" \
#"stocke st 01 L snip60390_4257662.fbspi.fil.ar" \
#"stocke st 01 L snip60391_5690699.fbspi.fil.ar" \
#"stocke st 01 L snip60392_5928489.fbspi.fil.ar" \
#"stocke st 01 L snip60393_5544964.fbspi.fil.ar" \
#"stocke st 01 L snip60394_3474146.fbspi.fil.ar" \
#"stocke st 01 L snip60394_5868739.fbspi.fil.ar" \
#"stocke st 01 L snip60396_2482285.fbspi.fil.ar" \
#"stocke st 01 L snip60424_4337451.fbspi.fil.ar" \
#"stocke st 01 L snip60425_4424318.fbspi.fil.ar" \
#"stocke st 01 L snip60431_4377754.fbspi.fil.ar" \
#"stocke st 01 L snip60433_2247390.fbspi.fil.ar" \
#"stocke st 01 L snip60458_0742204.fbspi.fil.ar" \
#"stocke st 01 L snip60803_2202071.fbspi.fil.ar" \

#2bit - prepped on Jan 21 2026
#"p47018 wb 17 L p47018_wb_no0017_IFall_vdif_pol2_8bit_10sec_600s_snippet_fil.ar" \
#"p47019 wb 18 L p47019_wb_no0018_IFall_vdif_pol2_8bit_10sec_857s_snippet_fil.ar" \
#"p47020 wb 16 L p47020_wb_no0016_IFall_vdif_pol2_8bit_10sec_128s_snippet_fil.ar" \
#"p47021 wb 7 L p47021_wb_no0007_IFall_vdif_pol2_8bit_10sec_133s_snippet_fil.ar" \
#"p47021 wb 11 L p47021_wb_no0011_IFall_vdif_pol2_8bit_10sec_486s_snippet_fil.ar" \
#"p47022 wb 18 L p47022_wb_no0018_IFall_vdif_pol2_8bit_10sec_659s_snippet_fil.ar" \
#"p47022 wb 22 L p47022_wb_no0022_IFall_vdif_pol2_8bit_10sec_753s_snippet_fil.ar" \
#"p47023 wb 15 L p47023_wb_no0015_IFall_vdif_pol2_8bit_10sec_551s_snippet_fil.ar" \
#"p47023 wb 21 L p47023_wb_no0021_IFall_vdif_pol2_8bit_10sec_216s_snippet_fil.ar" \
#"p47069 wb 7 L p47069_wb_no0007_IFall_vdif_pol2_8bit_10sec_294s_snippet_fil.ar" \
#"p47091 wb 18 L p47091_wb_no0018_IFall_vdif_pol2_8bit_10sec_858s_snippet_fil.ar" \
#"p55020 wb 37 L p55020_wb_no0037_IFall_vdif_pol2_8bit_10sec_501s_snippet_fil.ar" \
#"p55182 wb 32 L p55182_wb_no0032_IFall_vdif_pol2_8bit_10sec_195s_snippet_fil.ar" \
#"p55195 wb 44 L p55195_wb_no0044_IFall_vdif_pol2_8bit_10sec_447s_snippet_fil.ar" \
#"p55289 wb 90 L p55289_wb_no0090_IFall_vdif_pol2_8bit_10sec_261s_snippet_fil.ar" \
#"p55290 wb 87 L p55290_wb_no0087_IFall_vdif_pol2_8bit_10sec_551s_snippet_fil.ar" \
#"p55291 wb 41 L p55291_wb_no0041_IFall_vdif_pol2_8bit_10sec_357s_snippet_fil.ar" \
#"p55298 wb 73 L p55298_wb_no0073_IFall_vdif_pol2_8bit_10sec_413s_snippet_fil.ar" \
#"p55300 wb 66 L p55300_wb_no0066_IFall_vdif_pol2_8bit_10sec_250s_snippet_fil.ar" \
#"p55300-2 wb 66 L p55300_wb_no0066_IFall_vdif_pol2_8bit_10sec_502s_snippet_fil.ar" \
#"p55192 wb 44 L p55192_wb_no0044_IFall_vdif_pol2_8bit_10sec_417s_snippet_fil.ar" \
)

for run in "${runs[@]}";do

    IFS=" " read -r -a info <<< "${run}"
    exp="${info[0]}"
    dish="${info[1]}"
    scan="${info[2]}"
    band="${info[3]}"
    echo "scan: $scan"
    sfxc_ar="${info[4]}"

    target=${sfxc_dir}/${sfxc_ar} #sfxc
    
    linkdir=${outbasedir}/${exp}/sfxc/
    linkname=${exp}_${dish}_no00${scan}.ar

    echo "${target}"
    if [[ "$band" = "L" ]]; then
        tres=64        # in microseconds
        #fres=500000     # in Hz for 2bit
        fres=62500     # in Hz
    elif [[ "$band" = "P" ]]; then
        tres=256       # in microseconds
        fres=31250     # in Hz
    fi

    TWO_BIT_MODUS=false #done on Jan 21 2026
    if [ "$TWO_BIT_MODUS" = true ]; then
        echo "2 BIT MODUS ACTIVATED"
        target=${sfxc_dir_2bit}/${sfxc_ar}  #2bit
        linkname=${exp}_${dish}_no00${scan}_2bit.ar
    fi
    
    #The name of stockert burst will be the MJD of detection
    if [[ ${dish} == 'st' ]];then
        #echo snip59949_8819706.fbspi.fil.ar | cut -d '.' -f 1 | cut -c 5-
        #return 59949_8819706
        #The name of stockert burst will be the MJD of detection
        mjd_dir=`echo ${sfxc_ar} | cut -d '.' -f 1 | cut -c 5-`
        linkname=${exp}_${mjd_dir}.ar
        
        #Change the location of the archives for stockert bursts
        target=${sfxc_dir_st}/${sfxc_ar}
    fi

    link=${linkdir}/${linkname}
    echo "${link}"
    if [ -e ${link} ];then
        rm ${link}
    fi
    if ! [ -d ${linkdir} ];then
	mkdir -p ${linkdir}
    fi
    ln -s ${target} ${link}
    # use $(( $var )) to remove white spaces around integers
    pars=`psredit -q -Q -c nbin,length,npol,nchan,bw ${link}`
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
    tscale=`echo "${tres}/${time_res}" | bc`
    fscale=`echo "${fres}/${freq_res}" | bc`
    echo "length=${length}, nbin=${nbin}, npol=${npol}"
    echo "nchan=${nchan}, bw=${bw}"
    echo "time_res=${time_res}, freq_res=${freq_res}"
    echo "tscale=${tscale}, fscale=${fscale}"
    cmd='pam -e ds.ar '
    if [[ ${tscale} -gt 1 ]]; then
        cmd=${cmd}"-b ${tscale} "
    fi
    if [[ ${fscale} -gt 1 ]]; then
        cmd=${cmd}"-f ${fscale} "
    fi
    if [[ ${npol} -gt 1 ]];then
        cmd=${cmd}"-p "
    fi
    cmd=${cmd}${link}
    echo "running ${cmd}"
    #exit 1
    eval ${cmd}
done
