#!/bin/bash
set -e

###############
#
# This script takes the SFXC-generated, coherently dedispersed filterbanks
# and downsamples them to the same time and frequency resolution as what the
# digifil-generated filterbanks have. It then puts the files in the right
# directories.
#
# These filterbanks were used to determine the TOAs of the bursts.
#
# Generate St  command: ls *.fil | sort -t '/' -k 4 | sed -e 's;^;#"stocke st 01 01 ;' | sed '$!s/$/" \\/'
#
###############

#location of the filterbanks
sfxc_dir=/data1/omar/sfxc/frb240114a

outbasedir=/data1/omar/

runs=( \
# exp  dish scan dir filterbank 
# Torun bursts - ran on Feb24
#"rn1l10 tr L 11 rn1l10_11_tr_60380.43195 rn1l10_11_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l10 tr L 13 rn1l10_13_tr_60380.44477 rn1l10_13_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l10 tr L 15 rn1l10_15_tr_60380.46309 rn1l10_15_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l10 tr L 16 rn1l10_16_tr_60380.47045 rn1l10_16_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l10 tr L 22 rn1l10_22_tr_60380.52696 rn1l10_22_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
###5
#"rn1l10 tr L 23 rn1l10_23_tr_60380.52935 rn1l10_23_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l10 tr L 7 rn1l10_7_tr_60380.39698 rn1l10_7_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l11 tr L 13 rn1l11_13_tr_60381.44031 rn1l11_13_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l11 tr L 14 rn1l11_14_tr_60381.44569 rn1l11_14_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l11-2 tr L 14 rn1l11_14_tr_60381.44972 rn1l11_14_2_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
###10
#"rn1l11 tr L 17 rn1l11_17_tr_60381.47198 rn1l11_17_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l11 tr L 23 rn1l11_23_tr_60381.52857 rn1l11_23_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l12 tr L 4 rn1l12_4_tr_60387.36717 rn1l12_4_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l13 tr L 20 rn1l13_20_tr_60398.43767 rn1l13_20_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l33 tr L 10 rn1l33_10_tr_60563.95120 rn1l33_10_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
###15
#"rn1l40 tr L 17 rn1l40_17_tr_60586.95300 rn1l40_17_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l58 tr L 23 rn1l58_23_tr_60654.79400 rn1l58_23_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l59 tr L 16 rn1l59_16_tr_60658.72064 rn1l59_16_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l62 tr L 14 rn1l62_14_tr_60674.67263 rn1l62_14_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l64 tr L 15 rn1l64_15_tr_60681.66917 rn1l64_15_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
###20
#"rn1l64 tr L 4 rn1l64_4_tr_60681.57453 rn1l64_4_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l65 tr L 10 rn1l65_10_tr_60683.62494 rn1l65_10_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l65 tr L 14 rn1l65_14_tr_60683.65484 rn1l65_14_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l65 tr L 1 rn1l65_1_tr_60683.54646 rn1l65_1_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l65 tr L 6 rn1l65_6_tr_60683.58874 rn1l65_6_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
###25
#"rn1l66 tr L 11 rn1l66_11_tr_60684.61054 rn1l66_11_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l67 tr L 14 rn1l67_14_tr_60686.62064 rn1l67_14_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l70 tr L 7 rn1l70_7_tr_60698.53843 rn1l70_7_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l81 tr L 16 rn1l81_16_tr_60795.31636 rn1l81_16_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l81 tr L 21 rn1l81_21_tr_60795.36233 rn1l81_21_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
###30
#"rn1l82 tr L 20 rn1l82_20_tr_60798.35714 rn1l82_20_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l83 tr L 7 rn1l83_7_tr_60803.22021 rn1l83_7_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l84 tr L 14 rn1l84_14_tr_60805.28389 rn1l84_14_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l84 tr L 15 rn1l84_15_tr_60805.29069 rn1l84_15_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l87 tr L 5 rn1l87_5_tr_60812.20948 rn1l87_5_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
###35
#"rn1l89 tr L 2 rn1l89_2_tr_60816.17650 rn1l89_2_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \
#"rn1l90 tr L 22 rn1l90_22_tr_60819.33109 rn1l90_22_64us_125KHz_StokesI_DM5277.cor_Tr.fil" \

### Onsala bursts - - ran on Feb-23
#"p47024 o8 L 24 p47024_24_o8_60380.45214 p47024_24_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47024 o8 L 26 p47024_26_o8_60380.47045 p47024_26_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47024 o8 L 32 p47024_32_o8_60380.52696 p47024_32_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47024-2 o8 L 32 p47024_32_o8_60380.52935 p47024_32_2_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47024 o8 L 34 p47024_34_o8_60380.55016 p47024_34_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###5
#"p47024-2 o8 L 34 p47024_34_o8_60380.55492 p47024_34_2_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47024 o8 L 35 p47024_35_o8_60380.56328 p47024_35_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47024 o8 L 38 p47024_38_o8_60380.59622 p47024_38_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47024 o8 L 3 p47024_3_o8_60380.22753 p47024_3_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47024 o8 L 8 p47024_8_o8_60380.27610 p47024_8_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###10
#"p47025 o8 L 11 p47025_11_o8_60381.28667 p47025_11_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 13 p47025_13_o8_60381.30441 p47025_13_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 14 p47025_14_o8_60381.31663 p47025_14_64us_125KHz_StokesI_DM5277.cor_O8.fil DEEMED NOT REAL" \
#"p47025 o8 L 16 p47025_16_o8_60381.33594 p47025_16_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 22 p47025_22_o8_60381.40647 p47025_22_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###15
#"p47025 o8 L 24 p47025_24_o8_60381.41955 p47025_24_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 26 p47025_26_o8_60381.44031 p47025_26_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025-2 o8 L 26 p47025_26_o8_60381.44565 p47025_26_2_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 27 p47025_27_o8_60381.44972 p47025_27_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 29 p47025_29_o8_60381.47198 p47025_29_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###20
#"p47025 o8 L 2 p47025_2_o8_60381.19497 p47025_2_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 30 p47025_30_o8_60381.48761 p47025_30_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 34 p47025_34_o8_60381.52857 p47025_34_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 36 p47025_36_o8_60381.54555 p47025_36_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 42 p47025_42_o8_60381.61002 p47025_42_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###25
#"p47025 o8 L 4 p47025_4_o8_60381.20674 p47025_4_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 5 p47025_5_o8_60381.21916 p47025_5_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 8 p47025_8_o8_60381.25477 p47025_8_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47025 o8 L 9 p47025_9_o8_60381.26480 p47025_9_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47026 o8 L 13 p47026_13_o8_60382.30821 p47026_13_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###30
#"p47026 o8 L 16 p47026_16_o8_60382.33875 p47026_16_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47026 o8 L 19 p47026_19_o8_60382.36677 p47026_19_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47026 o8 L 21 p47026_21_o8_60382.38751 p47026_21_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47026 o8 L 28 p47026_28_o8_60382.45980 p47026_28_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47026 o8 L 40 p47026_40_o8_60382.58602 p47026_40_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###35
#"p47026 o8 L 4 p47026_4_o8_60382.21357 p47026_4_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47026 o8 L 5 p47026_5_o8_60382.21510 p47026_5_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47026 o8 L 6 p47026_6_o8_60382.22576 p47026_6_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47027 o8 L 10 p47027_10_o8_60383.26844 p47027_10_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47027 o8 L 18 p47027_18_o8_60383.35377 p47027_18_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###40
#"p47028 o8 L 24 p47028_24_o8_60384.41118 p47028_24_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47030 o8 L 23 p47030_23_o8_60386.39685 p47030_23_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47030 o8 L 31 p47030_31_o8_60386.48574 p47030_31_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47030 o8 L 39 p47030_39_o8_60386.56761 p47030_39_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47038 o8 L 43 p47038_43_o8_60394.58687 p47038_43_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###45
#"p47064 o8 L 38 p47064_38_o8_60431.43777 p47064_38_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p47068 o8 L 29 p47068_29_o8_60435.32807 p47068_29_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
#"p49035 o8 L 27 p49035_27_o8_60697.68941 p49035_27_64us_125KHz_StokesI_DM5277.cor_O8.fil" \
###48

### Westerbork L-band SFXC
#"p47018 wb L 24 p47018_24_wb_60369.37077 p47018_24_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47019 wb L 21 p47019_21_wb_60370.29406 p47019_21_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47019 wb L 33 p47019_33_wb_60370.42098 p47019_33_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47019 wb L 36 p47019_36_wb_60370.45202 p47019_36_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47019 wb L 37 p47019_37_wb_60370.45775 p47019_37_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
####5
#"p47020 wb L 19 p47020_19_wb_60373.28848 p47020_19_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47020 wb L 25 p47020_25_wb_60373.35687 p47020_25_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47021 wb L 11 p47021_11_wb_60375.42929 p47021_11_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47021 wb L 13 p47021_13_wb_60375.44850 p47021_13_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47021-2 wb L 13 p47021_13_wb_60375.45227 p47021_13_2_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
####10
#"p47021 wb L 4 p47021_4_wb_60375.35196 p47021_4_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47021 wb L 6 p47021_6_wb_60375.38288 p47021_6_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47021 wb L 8 p47021_8_wb_60375.40089 p47021_8_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47021 wb L 9 p47021_9_wb_60375.40484 p47021_9_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47031 wb L 20 p47031_20_wb_60387.36718 p47031_20_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
####15
#"p47031 wb L 36 p47031_36_wb_60387.53333 p47031_36_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47057 wb L 36 p47057_36_wb_60424.43375 p47057_36_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47065 wb L 33 p47065_33_wb_60432.38560 p47065_33_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47066 wb L 16 p47066_16_wb_60433.20360 p47066_16_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p47085 wb L 11 p47085_11_wb_60453.09210 p47085_11_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
####20
#"p55084 wb L 34 p55084_34_wb_60573.92099 p55084_34_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55092 wb L 32 p55092_32_wb_60581.87251 p55092_32_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55097 wb L 41 p55097_41_wb_60586.95300 p55097_41_64us_125KHz_StokesI_DM5284.cor_Wb.fil" \
#"p55158 wb L 47 p55158_47_wb_60658.72064 p55158_47_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55173 wb L 40 p55173_40_wb_60673.60990 p55173_40_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
####25
#"p55179 wb L 40 p55179_40_wb_60679.59050 p55179_40_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55179 wb L 44 p55179_44_wb_60679.63683 p55179_44_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55179 wb L 47 p55179_47_wb_60679.67225 p55179_47_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55179 wb L 51 p55179_51_wb_60679.71107 p55179_51_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55179-2 wb L 51 p55179_51_wb_60679.71465 p55179_51_2_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
####30
#"p55179 wb L 54 p55179_54_wb_60679.74590 p55179_54_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55182 wb L 55 p55182_55_wb_60682.74005 p55182_55_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55183 wb L 50 p55183_50_wb_60683.68580 p55183_50_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55186 wb L 8 p55186_8_wb_60686.62064 p55186_8_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55195 wb L 29 p55195_29_wb_60696.41322 p55195_29_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
####35
#"p55197 wb L 42 p55197_42_wb_60698.53843 p55197_42_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55293 wb L 11 p55293_11_wb_60809.31930 p55293_11_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"p55299 wb L 125 p55299_125_wb_60816.33178 p55299_125_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
#"pcn254 wb L 12 pcn254_12_wb_60355.64417 pcn254_12_64us_125KHz_StokesI_DM5277.cor_Wb.fil" \
####39
####Pband
#"p47030 wb P 21 p47030_21_wb_60386.37678 p47030_21_256us_32KHz_StokesI_DM5277.cor_Wb.fil" \
#"pcn242 wb P 23 pcn242_23_wb_60341.53821 pcn242_23_256us_32KHz_StokesI_DM5277.cor_Wb.fil" \

#Pband
#"p11714 wb P 35 p11714_35_p p11714_35_256us_31KHz_StokesI_DM2197_cor_Wb.fil" \
#"p11720 wb P 36 p11720_36_p p11720_36_256us_32KHz_StokesI_DM2197_cor_Wb.fil" \
#"p11721 wb P 46 p11721_46_p p11721_46_256us_32KHz_StokesI_DM2197_cor_Wb.fil" \

#Westerbork 2 bit - ran on Feb-19-2025
#"p47018 wb L 17 p47018_17 p47018_wb_no0017_IFall_vdif_pol2_8bit_10sec_600s_snippet.fil" \
#"p47019 wb L 18 p47019_18 p47019_wb_no0018_IFall_vdif_pol2_8bit_10sec_857s_snippet.fil" \
#"p47020 wb L 16 p47020_16 p47020_wb_no0016_IFall_vdif_pol2_8bit_10sec_128s_snippet.fil" \
#"p47021 wb L 07 p47021_7 p47021_wb_no0007_IFall_vdif_pol2_8bit_10sec_133s_snippet.fil" \
#"p47021 wb L 11 p47021_11 p47021_wb_no0011_IFall_vdif_pol2_8bit_10sec_486s_snippet.fil" \
#####5
#"p47022 wb L 18 p47022_18 p47022_wb_no0018_IFall_vdif_pol2_8bit_10sec_659s_snippet.fil" \
#"p47022 wb L 22 p47022_22 p47022_wb_no0022_IFall_vdif_pol2_8bit_10sec_753s_snippet.fil" \
#"p47023 wb L 15 p47023_15 p47023_wb_no0015_IFall_vdif_pol2_8bit_10sec_551s_snippet.fil" \
#"p47023 wb L 21 p47023_21 p47023_wb_no0021_IFall_vdif_pol2_8bit_10sec_216s_snippet.fil" \
#"p47069 wb L 07 p47069_7 p47069_wb_no0007_IFall_vdif_pol2_8bit_10sec_294s_snippet.fil" \
#####10
#"p47091 wb L 18 p47091_18 p47091_wb_no0018_IFall_vdif_pol2_8bit_10sec_858s_snippet.fil" \
#"p55020 wb L 37 p55020_37 p55020_wb_no0037_IFall_vdif_pol2_8bit_10sec_501s_snippet.fil" \
#"p55182 wb L 32 p55182_32 p55182_wb_no0032_IFall_vdif_pol2_8bit_10sec_195s_snippet.fil" \
#"p55195 wb L 44 p55195_44 p55195_wb_no0044_IFall_vdif_pol2_8bit_10sec_447s_snippet.fil" \
#"p55289 wb L 90 p55289_90 p55289_wb_no0090_IFall_vdif_pol2_8bit_10sec_261s_snippet.fil" \
#####15
#"p55290 wb L 87 p55290_87 p55290_wb_no0087_IFall_vdif_pol2_8bit_10sec_551s_snippet.fil" \
#"p55291 wb L 41 p55291_41 p55291_wb_no0041_IFall_vdif_pol2_8bit_10sec_357s_snippet.fil" \
#"p55298 wb L 73 p55298_73 p55298_wb_no0073_IFall_vdif_pol2_8bit_10sec_413s_snippet.fil" \
#"p55300 wb L 66 p55300_66 p55300_wb_no0066_IFall_vdif_pol2_8bit_10sec_250s_snippet.fil" \
#"p55300-2 wb L 66 p55300_66 p55300-2_wb_no0066_IFall_vdif_pol2_8bit_10sec_502s_snippet.fil" \
#####20
#"p55192 wb L 44 p55192_44 p55192_wb_no0044_IFall_vdif_pol2_8bit_10sec_417s_snippet.fil" \


#Stockert bursts - ran on Feb-12-2026
#"stocke st L 01 01 snip60357.3437816.fbspi.fil" \
#"stocke st L 01 01 snip60357.4385230.fbspi.fil" \
#"stocke st L 01 01 snip60361.5475088.fbspi.fil" \
#"stocke st L 01 01 snip60366.3461485.fbspi.fil" \
#"stocke st L 01 01 snip60369.3359967.fbspi.fil" \
#"stocke st L 01 01 snip60371.2798981.fbspi.fil" \
#"stocke st L 01 01 snip60372.5113801.fbspi.fil" \
#"stocke st L 01 01 snip60373.4876754.fbspi.fil" \
#"stocke st L 01 01 snip60373.5456450.fbspi.fil" \
#"stocke st L 01 01 snip60374.3189053.fbspi.fil" \
#"stocke st L 01 01 snip60375.2980335.fbspi.fil" \
#"stocke st L 01 01 snip60375.3037769.fbspi.fil" \
#"stocke st L 01 01 snip60375.4292868.fbspi.fil" \
#"stocke st L 01 01 snip60375.4311251.fbspi.fil" \
#"stocke st L 01 01 snip60375.4726520.fbspi.fil" \
#"stocke st L 01 01 snip60376.3217991.fbspi.fil" \
#"stocke st L 01 01 snip60376.3316630.fbspi.fil" \
#"stocke st L 01 01 snip60377.2533142.fbspi.fil" \
#"stocke st L 01 01 snip60377.3150949.fbspi.fil" \
#"stocke st L 01 01 snip60377.3732605.fbspi.fil" \
#"stocke st L 01 01 snip60377.4371665.fbspi.fil" \
#"stocke st L 01 01 snip60377.4588314.fbspi.fil" \
#"stocke st L 01 01 snip60377.6264129.fbspi.fil" \
#"stocke st L 01 01 snip60378.2170109.fbspi.fil" \
#"stocke st L 01 01 snip60378.3133708.fbspi.fil" \
#"stocke st L 01 01 snip60378.4604753.fbspi.fil" \
#"stocke st L 01 01 snip60379.2275323.fbspi.fil" \
#"stocke st L 01 01 snip60379.2555746.fbspi.fil" \
#"stocke st L 01 01 snip60379.2602165.fbspi.fil" \
#"stocke st L 01 01 snip60379.2695980.fbspi.fil" \
#"stocke st L 01 01 snip60379.3517707.fbspi.fil" \
#"stocke st L 01 01 snip60379.4008061.fbspi.fil" \
#"stocke st L 01 01 snip60379.5397914.fbspi.fil" \
#"stocke st L 01 01 snip60380.2760984.fbspi.fil" \
#"stocke st L 01 01 snip60380.3969765.fbspi.fil" \
#"stocke st L 01 01 snip60380.3998840.fbspi.fil" \
#"stocke st L 01 01 snip60380.4319492.fbspi.fil" \
#"stocke st L 01 01 snip60380.4447753.fbspi.fil" \
#"stocke st L 01 01 snip60380.4521409.fbspi.fil" \
#"stocke st L 01 01 snip60380.5269620.fbspi.fil" \
#"stocke st L 01 01 snip60380.5962205.fbspi.fil" \
#"stocke st L 01 01 snip60381.1949711.fbspi.fil" \
#"stocke st L 01 01 snip60381.2067454.fbspi.fil" \
#"stocke st L 01 01 snip60381.2191585.fbspi.fil" \
#"stocke st L 01 01 snip60381.3044108.fbspi.fil" \
#"stocke st L 01 01 snip60381.4497249.fbspi.fil" \
#"stocke st L 01 01 snip60381.4719812.fbspi.fil" \
#"stocke st L 01 01 snip60382.4597962.fbspi.fil" \
#"stocke st L 01 01 snip60382.5860243.fbspi.fil" \
#"stocke st L 01 01 snip60383.2684445.fbspi.fil" \
#"stocke st L 01 01 snip60383.3537691.fbspi.fil" \
#"stocke st L 01 01 snip60384.4111808.fbspi.fil" \
#"stocke st L 01 01 snip60386.4857456.fbspi.fil" \
#"stocke st L 01 01 snip60387.3671739.fbspi.fil" \
#"stocke st L 01 01 snip60388.4505749.fbspi.fil" \
#"stocke st L 01 01 snip60390.2765210.fbspi.fil" \
#"stocke st L 01 01 snip60390.4257662.fbspi.fil" \
#"stocke st L 01 01 snip60391.5690699.fbspi.fil" \
#"stocke st L 01 01 snip60392.5928489.fbspi.fil" \
#"stocke st L 01 01 snip60393.5544964.fbspi.fil" \
#"stocke st L 01 01 snip60394.3474146.fbspi.fil" \
#"stocke st L 01 01 snip60394.5868739.fbspi.fil" \
#"stocke st L 01 01 snip60396.2482285.fbspi.fil" \
#"stocke st L 01 01 snip60424.4337451.fbspi.fil" \
#"stocke st L 01 01 snip60425.4424318.fbspi.fil" \
#"stocke st L 01 01 snip60431.4377754.fbspi.fil" \
#"stocke st L 01 01 snip60433.2247390.fbspi.fil" \
#"stocke st L 01 01 snip60458.0742204.fbspi.fil" \
#"stocke st L 01 01 snip60803.2202071.fbspi.fil" \
)

for run in "${runs[@]}";do
    IFS=" " read -r -a info <<< "${run}"
    exp="${info[0]}"
    dish="${info[1]}"
    band="${info[2]}"
    scan="${info[3]}"
    dir="${info[4]}"
    sfxc_fil="${info[5]}"
    fulldir=${sfxc_dir}/${dir}
    if [[ "${sfxc_fil}" == *8bit* ]]; then
        fulldir=/scratch1/baseband_extractions/r147/wb-2bit
    fi
    if [[ ${dish} == 'st' ]];then
        fulldir=/scratch1/baseband_extractions/r147/stockert
    fi
    target=${fulldir}/${sfxc_fil}
    if ! [[ -e ${target} ]];then
        echo "cannot find ${target}"
    fi

    #Settings of output filterbanks
    if [[ "$band" = "L" ]]; then
    ##Lband
    #This setting also works for Stockert, since it won't actually downsample
        tres_out=64         # in microseconds
        fres_out=500000     # in Hz
    elif [[ "$band" = "P" ]]; then
        tres_out=512       # in microseconds
        fres_out=31250     # in Hz
    fi
    
    if [[ "${sfxc_fil}" == *8bit* ]]; then
        echo "2bit downsampling"
        tres_out=256         # in microseconds
        fres_out=500000     # in Hz
    fi

    #The name of stockert burst will be the MJD of detection
    if [[ ${dish} == 'st' ]];then
        #The name of stockert burst will be the MJD of detection
        #snip59867.5457019.fbspi.fil
        #snip59867_5457019.fbspi.fil -- replace the first dot
        sfxc_fil_d=${sfxc_fil/./_}

        #echo snip59949_8819706.fbspi.fil | cut -d '.' -f 1 | cut -c 5-
        #return 59949_8819706
        mjd_dir=`echo ${sfxc_fil_d} | cut -d '.' -f 1 | cut -c 5-`
        linkname=${exp}_${mjd_dir}.fil
    else
        printf -v scan_padded "%04d" "$scan"
        linkname=${exp}_${dish}_no${scan_padded}.fil
        #linkname=${exp}_${dish}_no00${scan}.fil
    fi
    
    if [[ "${sfxc_fil}" == *8bit* ]]; then
        printf -v scan_padded "%04d" "$scan"
        linkname=${exp}_${dish}_no${scan_padded}_2bit.fil
    fi

    linkdir=${outbasedir}/${exp}/sfxc/
    link=${linkdir}/${linkname}

    if [ -e ${link} ];then
        rm ${link}
    fi
    if ! [ -d ${linkdir} ];then
        mkdir -p ${linkdir}
    fi
    cmd="ln -s ${target} ${link}"
    echo "running ${cmd}"
    eval ${cmd}

    ##
    #pars=`header ${link} -tsamp -nifs -foff -nbits`
    #echo ${pars}
    #IFS=" " read -r -a params <<< "${pars}"
    tres_in=`header ${link} -tsamp`   # in microseconds
    npol=`header ${link} -nifs`    # 4 for full pol, we want Stokes I
    fres_in=`header ${link} -foff`
    nbits=`header ${link} -nbits`
    if [[ ${nbits} == '32' ]];then
        nbits='-32'
    fi
    ## bash cannot handle floats, so convert fres_in to an integer in Hz
    fres_in=`echo "${fres_in}*1000000" | bc | cut -d '.' -f1`
    if [[ ${fres_in} -lt 0 ]]; then
        fres_in=`echo ${fres_in}*-1 | bc`
    fi
    ## get the scrunching factors
    tscale=`echo "${tres_out}/${tres_in}" | bc`
    echo "${fres_out} -- ${fres_in}"
    fscale=`echo "${fres_out}/${fres_in}" | bc`
    echo "tres_in=${tres_in}, fres_in=${fres_in}"
    echo "tscale=${tscale}, fscale=${fscale}"
    cmd="digifil ${link} -o ${link%fil}ds.fil -I0 -b ${nbits} "
    if [[ ${tscale} -gt 1 ]]; then
        cmd=${cmd}"-t ${tscale} "
    fi
    if [[ ${fscale} -gt 1 ]]; then
        cmd=${cmd}"-f ${fscale} "
    fi
    if [[ ${npol} -gt 1 ]];then
        cmd=${cmd}"-d1 "
    fi
    echo "running ${cmd}"
    ##exit 1
    eval ${cmd}
done
