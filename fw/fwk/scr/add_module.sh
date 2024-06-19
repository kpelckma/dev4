#!/bin/bash


SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

if [ $# -lt 2 ]; then
    echo "Script helps to add source module with all the dependencies"
    echo "Illegal number of parameters, provide module path as argument"
    echo "> add_module.sh <GitRepo> <ModulePath> <branch*optional>"
    exit
fi

GitRepo=$1
ModulePath=$2

echo "# Adding git submodule..."
if [ $# -lt 3 ]; then
    git submodule add $GitRepo $ModulePath
    git submodule update --init
else
    git submodule add $GitRepo $ModulePath
    git submodule update --init
fi

${SCRIPTPATH}/add_module_dep.sh $ModulePath/dependencies
