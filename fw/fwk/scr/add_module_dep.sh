#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Script adds source module dependencies"
    echo "Illegal number of parameters, provide dependencies file path"
    echo "> add_module_dep.sh <dependencies_file>"
    exit
fi

DepFile=$1

# TODO:
# check if dependency already exist and check version,
# report eventual conflicts
echo "# Adding module dependencies..."
if [ -f "$DepFile" ]; then
    while IFS= read -r line; do
        readarray -d , -t stringarray <<< "$line"
        Path=${stringarray[0]}
        Repo=${stringarray[1]}
        Branch=${stringarray[2]}
        if [ $Branch == "" ]; then
            git submodule add $Repo $Path
        else
            git submodule add -b $Branch $Repo $Path
        fi
    done < $DepFile
    git submodule update --init
else
    echo "No $DepFile file found"
fi
