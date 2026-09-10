#!/bin/bash

#define some variables
#p55097_41 - THE STROOP
arr=( $(seq 527.5 0.01 529.5) )
timestamp="1.078912"
folder_name="p55097_41_wb_60586.95300"
obscode="p55097"
obscode_scan="${obscode}_41"
time_res="8us"
freq_res="500KHz"
    
for i in "${arr[@]}";do

    #Define some files, could be optimized somehow
    #Change these variabeles
    gitfolder="/home/omar/git/r147-single-dish-analysis/dm_opt_loop/${obscode_scan}/"
    CTRLFILE="${gitfolder}${obscode_scan}_${time_res}.ctrl"
    VIXFILE="${gitfolder}${obscode}.vix"
    
    #replace the comma with a dot, store in variable
    #echo $DMVALDOT
    DMVALDOT=${i/,/.}
    
    #find (before the c\) and replace the DM in the polyco file
    folderpolyco="/data1/omar/sfxc/frb240114a/"
    POLYCO="${folderpolyco}frb240114a_loop.polyco"
    sed -i '/R240114_D/ c\R240114_D   03-May-21    191325.00      59337.80   '$DMVALDOT' 0.000  0.000' "$POLYCO"

    DMVALSPACE=${i/./}
    #echo $DMVALSPACE

    #find and replace the cor name filename of the core file
    CORNAME="${obscode_scan}_${time_res}_${freq_res}_StokesI_DM$DMVALSPACE.cor"
    #echo $CORNAME

    #CORNAMECTRL="file:///dev/shm//$CORNAME"
    CORNAMECTRL="file:///data1/omar/sfxc/frb240114a/${folder_name}/dm_opt/$CORNAME"
    #echo $CORNAMECTRL
    sed -i '/output/ c\    "output_file": "'$CORNAMECTRL'",' "$CTRLFILE"

    #running the SFXC command
    SFXC="mpirun -np 38 --use-hwthread-cpus sfxc $CTRLFILE $VIXFILE"
    echo $SFXC
    #Excecute command
    ${SFXC}

    #Add _wb to the corname, to fit the output of sfxc. need to do a trick to get _wb appended. So use + and then replace with _
    CORNAMEOUT="${CORNAME}_Wb"
    #echo $CORNAMEOUT

    #The output filterbank name with formatting
    FILNAME="${CORNAMEOUT/./_}.fil"
    #echo $FILNAME

    #Running cor2filterbank
    folderoutput="/data1/omar/sfxc/frb240114a/${folder_name}/dm_opt/"
    COR2="cor2filterbank.py -s Wb -p I $VIXFILE $folderoutput$CORNAMEOUT $folderoutput$FILNAME"
    echo $COR2
    ${COR2}

    #Calling the python script
    PYTCOM="python standard_profile_loop.py -f $folderoutput$FILNAME -dm $DMVALDOT -t $timestamp"
    echo $PYTCOM
    ${PYTCOM}

    #Removing the .cor and the .fil file
    RMCOM="rm $folderoutput$FILNAME $folderoutput$CORNAMEOUT"
    echo $RMCOM
    ${RMCOM}
    
done

RMCOMCHEX="rm *dynamic_channel* chex*"
echo $RMCOMCHEX
${RMCOMCHEX}
