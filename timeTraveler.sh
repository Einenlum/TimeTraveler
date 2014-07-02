#!/bin/bash

# TimeTraveler Script
# This script gets all the mp3 of a directory and creates a copy of them with a different tempo in a subdirectory.
# The script must be called without arguments in the wanted directory.
# For now the script only works with mp3. It needs that packages libsox-fmt-mp3 and sox are installed (sudo apt-get install libsox-fmt-mp3 sox).


##### VARIABLES TO EDIT #######

# Name of the subdirectory which will receive the modified mp3 files
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
packageList=('sox' 'libsox-fmt-mp3') # Array with required dependencies
usageExamples="\nExamples of correct use:\n\nThis line will reduce by 10% the tempo of all mp3 files in the current directory:\n\t./timeTraveler.sh 0.9\n\nThis line will increase by 40% the tempo of all mp3 files in ~/Podcasts:\n\t./timeTraveler.sh 1.40 ~/Podcasts\n"

## Welcome

echo -e "\n" # Space insertion
echo -e "$TEAL" "===== TimeTraveler ===== $DEFAULT\n"

## Check the tempoValue given in parameter
shopt -s extglob
if [[ -z $1 ]]
then
    echo -e "You must give the tempo change value as first parameter.\n1.3 will increase the tempo by 30%, 0.3 will reduce it by 70%."
    echo -e $usageExamples
    exit 1
else
    if [[ $1 = @(*[0-9]*|!([+-]|)) && $1 = ?([0-9])?(.*([0-9])) ]]
    then
        tempoValue=$1
    else
        echo "The tempo change value must be a real positive number and not a string."
        echo -e $usageExamples
        exit 1
    fi
fi

## Dependencies check

echo -e "The script checks if the required dependencies are installed.\n"

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
        echo -e "$RED" "Several required packages are not installed. TimeTraveler can't run correctly without them." "$DEFAULT"
    else # If only one package is not installed
        echo -e "$RED" "A required packaged is not installed. TimeTraveler can't run correctly without it." "$DEFAULT"
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

    ## Checking parameter
    if [[ -z $2 ]] ## If parameter is empty
    then
        workingDirectory=`pwd`
        echo -e "No directory was given in parameter. The script is going to analyze the current directory.\n"
    else
        str=$2
        i=$((${#str}-1))
        if [[ ${str:$i:1} == "/" ]] ## If the parameter ends by "/"
        then
            workingDirectory=${str%/} ## we remove the "/"
        else
            workingDirectory=$2
        fi
        echo -e "The script is going to analyze the working directory given in parameter.\n"
    fi

    sleep 1.5

    if [ -d $workingDirectory -a -r $workingDirectory ]    # Does the working directory exist and is readable?
    then
        echo -e "$GREEN" "The working directory $workingDirectory does exist and is readable." "$DEFAULT"

        outputDirectory=$workingDirectory/$outputName

        if [ -d $outputDirectory ]    # Does the directory exist?
        then
            echo -e "$GREEN" "The output directory $outputDirectory does exist." "$DEFAULT"
        else
            echo -e "$YELLOW" "The output directory $outputDirectory does not exist. It is going to be created." "$DEFAULT"
            mkdir $outputDirectory
        fi

        
        if [ -r $outputDirectory ] && [ -w $outputDirectory ] # Is the directory writable?
        then
            echo -e "$GREEN" "The output directory $outputDirectory is readable and writable.\n" "$DEFAULT"
            sleep 1.5

            ## List of the files in the current directory
            counter=0
            shopt -s nullglob
            for file in $workingDirectory/*.mp3    # For every mp3 file in the directory
            do
                if [[ -f $file ]]    # And if it's not a directory
                then
                    filename=$(basename "$file")
                    treatment="Treatment of the file called $PINK$filename$DEFAULT:"
                    outputName=${filename%.mp3}   # Removing the mp3 output of the file. (For the explanation: http://stackoverflow.com/questions/125281/how-do-i-remove-the-file-suffix-and-path-portion-from-a-path-string-in-bash)
                    outputName+=$outputExtension # Adding the extension that was put on the top of the script
                    outputName+=".mp3"    # Adding the mp3 extension
                    fileoutput="$outputDirectory/$outputName"   # Final address of the mp3 output file



                    if [[ ! -f $fileoutput ]] 
                    then # If the file does not exist
                        echo -e "$treatment$YELLOW The file is going to be TimeTraveled$DEFAULT"
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
                echo -e "$BLUE" "All files are already TimeTraveled." "$DEFAULT"
                echo -e "\n"
            else
                echo -e "\n"
                echo -e "$BLUE" "All files have been TimeTravalled." "$DEFAULT"
                echo -e "\n"
            fi

        else # If the output directory can't be written or read
            echo -e "$RED" "The $outputDirectory directory can't be read or written." "$DEFAULT"
        fi

    else
        echo -e "$YELLOW" "The working directory $workingDirectory does not exist or is not readable.\n End of the script." "$DEFAULT"
    fi

else # If the user doesn't want to use the script anymore
    echo -e "$BLUE" "Please install the required packages." "$DEFAULT"
fi
