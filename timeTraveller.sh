#!/bin/bash

# TimeTraveller Script
# This script gets all the mp3 of a folder and creates a copy of them with a different tempo in a subfolder.
# The script must be called without arguments in the wanted folder.
# For now the script only works with mp3. It needs that packages libsox-fmt-mp3 and sox are installed (sudo apt-get install libsox-fmt-mp3 sox).


##### VARIABLES TO EDIT #######

# New tempo (1.35 means increasing the tempo of 35%, 0.8 means reducing it of 20%)
tempoValue=1.25
# Name of the subfolder which will receive the modified mp3 files
outputName="TempoFiles"
# Extension to add to new files after the treatment (facultative). Ex: file1.mp3 will have a modified copy called file1--tempo.mp3. Let it empty if you want to keep the same filename.
outputExtension="--tempo"

################################



## Declaration of useful colors for the display of the script
BLUE="\\033[1;34m"
GREEN="\\033[1;32m"
YELLOW="\\033[1;33m"
TEAL="\\033[1;36m"
RED="\\033[1;31m"
PINK="\\033[1;35m"
DEFAULT="\\033[0;39m"

## Declaration of useful variables
workingDirectory=`pwd`
outputFolder=$workingDirectory/$outputName
packageList=('sox' 'libsox-fmt-mp3') # Array with required dependencies



## Welcome

echo -e "\n" # Space insertion
echo -e "$TEAL" "===== TimeTraveller ===== $DEFAULT"
echo -e "This script only treats the mp3 files in the current folder.\n"
echo -e "The script checks if the required dependencies are installed.\n"


## Dependencies check

counterUninstalled=0 # We initialize a counter to keep in track the number of uninstalled packages
for package in "${packageList[@]}" # For every required package...
do
    if [[ -z `dpkg --get-selections | grep -w ^$package[^-]` ]] # Is it installed?
    then # If not...
        counterUninstalled+=1
        echo -e "$RED" "The $package package is not installed" "$DEFAULT"

    else # If yes...
        echo -e "$GREEN" "The $package package is installed" "$DEFAULT"
    fi
done # End of forloop (for every required package)

if [[ $counterUninstalled -gt 0 ]] # If one package is not installed
then
    if [[ $counterUninstalled -gt 1 ]] # If several packages are not installed
    then
        echo -e "$RED" "Several required packages are not installed. TimeTraveller can't run correctly without them." "$DEFAULT"
    else # If only one package is not installed
        echo -e "$RED" "A required packaged is not installed. TimeTraveller can't run correctly without it." "$DEFAULT"
    fi # end of the test "If one package at least is not installed"

    while [[ ${continueDespiteErrors,,} != y && ${continueDespiteErrors,,} != yes && ${continueDespiteErrors,,} != n && ${continueDespiteErrors,,} != no ]]
    do
        read -p "Do you want to continue the script anyway? [Y/N] : " continueDespiteErrors # Prompt
    done
fi


## Execution of the script

if [[ ${continueDespiteErrors,,} == 'y' ]] || [[ ${continueDespiteErrors,,} == 'yes' || $counterUninstalled -eq 0 ]] # If the user want to continue or if everything is correctly installed
then
    echo -e "\n"
    echo -e "The script is going to analyze the current folder.\n"

    sleep 1.5

    if [ -d $outputFolder ]    # Does the folder exist?
    then
        echo -e "$GREEN" "The output folder $outputFolder does exist." "$DEFAULT"
    else
        echo -e "$YELLOW" "The output folder $outputFolder does not exist. It is going to be created." "$DEFAULT"
        mkdir $outputFolder
    fi

    
    if [ -r $outputFolder ] && [ -w $outputFolder ] # Is the folder writable?
    then
        echo -e "$GREEN" "The output folder $outputFolder is readable and writable.\n" "$DEFAULT"
        sleep 1.5

        ## List of the files in the current folder
        counter=0
        shopt -s nullglob
        for file in *.mp3    # For every mp3 file in the folder
        do
            if [[ -f $file ]]    # And if it's not a folder
            then
                treatment="Treatment of the file called $PINK$file$DEFAULT:"
                outputName=${file%.mp3}   # Removing the mp3 output of the file. (For the explanation: http://stackoverflow.com/questions/125281/how-do-i-remove-the-file-suffix-and-path-portion-from-a-path-string-in-bash)
                outputName+=$outputExtension # Adding the extension that was put on the top of the script
                outputName+=".mp3"    # Adding the mp3 extension
                fileoutput="$outputFolder/$outputName"   # Final address of the mp3 output file



                if [[ ! -f $fileoutput ]] 
                then # If the file does not exist
                    echo -e "$treatment$YELLOW The file is going to be TimeTravelled$DEFAULT"
                    sleep 1
                    sox -S "$file" "$fileoutput" tempo $tempoValue   # We give to sox the result
                    counter+=1
                else # If it does exist
                    echo -e "$treatment$GREEN OK$DEFAULT"
                fi

            fi
        done

        if [ $counter -eq 0 ] # If no file needs to be treated
        then
            echo -e "\n"
            echo -e "$BLUE" "All files are already TimeTravelled." "$DEFAULT"
            echo -e "\n"
        else
            echo -e "\n"
            echo -e "$BLUE" "All files have been TimeTravalled." "$DEFAULT"
            echo -e "\n"
        fi

    else # If the output folder can't be written or read
        echo -e "$RED" "The $outputFolder folder can't be read or written." "$DEFAULT"
    fi

else # If the user doesn't want to use the script anymore
    echo -e "$BLUE" "Please install the required packages." "$DEFAULT"
fi
