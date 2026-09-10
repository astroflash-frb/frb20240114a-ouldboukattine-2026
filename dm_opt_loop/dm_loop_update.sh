#!/bin/bash
set -e
    
while read -r timestamp folder_name obscode scan time_res freq_res dm_start dm_end dm_step telescope
do
    # Skip comments or empty lines
    [[ "$timestamp" =~ ^#.*$ || -z "$timestamp" ]] && continue

    obscode_scan="${obscode}_${scan}"

    # Ensure output folder exists
    folderoutput="/data1/omar/sfxc/frb240114a/${folder_name}/dm_opt/"
    if [ ! -d "$folderoutput" ]; then
        echo "Output folder does not exist, creating: $folderoutput"
        mkdir -p "$folderoutput"
    fi

    # Create DM array per burst
    arr=( $(seq $dm_start $dm_step $dm_end) )

    echo "=== Running burst: $obscode_scan ==="
    echo "DM range: $dm_start → $dm_end (step $dm_step)"

    for i in "${arr[@]}"; do

        #Define some files, could be optimized somehow
        #Change these variabeles
        gitfolder="/home/omar/git/r147-single-dish-analysis/dm_opt_loop/${obscode_scan}/"
        CTRLFILE="${gitfolder}${obscode_scan}_${time_res}.ctrl"
        VIXFILE="${gitfolder}${obscode}.vix"
        
        #replace the comma with a dot, store in variable
        DMVALDOT=${i/,/.}
        #echo $DMVALDOT
        
        #find (before the c\) and replace the DM in the polyco file
        folderpolyco="/data1/omar/sfxc/frb240114a/"
        POLYCO="${folderpolyco}frb240114a_loop.polyco"
        echo $POLYCO
        
        # Set FRB key depending on telescope -- although I am pretty sure that this does not matter
        if [[ "$telescope" == "Tr" ]]; then
            FRB_KEY="R240121"
        else
            FRB_KEY="R240114_D"
        fi
        sed -i "/03-May-21/ c\\$FRB_KEY   03-May-21    191325.00      59337.80   $DMVALDOT 0.000  0.000" "$POLYCO"
        #sed -i "/$FRB_KEY/ c\\$FRB_KEY   03-May-21    191325.00      59337.80   $DMVALDOT 0.000  0.000" "$POLYCO"

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
        CORNAMEOUT="${CORNAME}_${telescope}"
        #CORNAMEOUT="${CORNAME}_Wb"
        #echo $CORNAMEOUT

        #The output filterbank name with formatting
        FILNAME="${CORNAMEOUT/./_}.fil"
        #echo $FILNAME

        #Running cor2filterbank
        folderoutput="/data1/omar/sfxc/frb240114a/${folder_name}/dm_opt/"
        if [[ "$obscode" == "p47030" ]]; then
            #If PBAND then skip the top IF since there is no signal there
            COR2="cor2filterbank.py -s $telescope -p I -i 0:6 $VIXFILE $folderoutput$CORNAMEOUT $folderoutput$FILNAME"
        else
            COR2="cor2filterbank.py -s $telescope -p I $VIXFILE $folderoutput$CORNAMEOUT $folderoutput$FILNAME"
        fi
        
        #COR2="cor2filterbank.py -s Wb -p I $VIXFILE $folderoutput$CORNAMEOUT $folderoutput$FILNAME"
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
    
done < dm_loop_config.txt

RMCOMCHEX="rm *dynamic_channel* chex*"
echo $RMCOMCHEX
${RMCOMCHEX}
