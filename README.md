Time Traveler
=============

Time Traveler is a bash script designed to change the tempo of mp3 files (changing the speed without changeng the pitch) in batch mode.

When processing a directory it looks for mp3 files in it. If it finds some, it creates a *TempoFiles* subdirectory and puts in it the copy of the mp3 files with changed tempo.

Needed Configuration
--------------------

The script was tested on Ubuntu but should work on pretty much every GNU/Linux distribution.

On Ubuntu it has two dependencies:

* sox
* libsox-fmt-mp3

Usage
-----
The script must be set executable with

    chmod +x timeTraveler.sh
    
Then it can be used in the current directory or it can process another directory given as parameter.

### Syntax

    ./timeTraveler.sh tempoFactor [directory]
    
The tempoFactor must be a real positive number.

####Examples

This line will reduce by 10% the tempo of all mp3 files in the current directory:

    ./timeTraveler.sh 0.9
    
This line will increase by 40% the tempo of all mp3 files in *~/Podcasts*:

    ./timeTraveler.sh 1.40 ~/Podcasts
