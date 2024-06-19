#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Script creates default structure of the source module."
    echo "Illegal number of parameters, provide module path as argument"
    echo "> init_module.sh ./src/moduleName"
    exit
fi

ModulePath=$1

echo "Intializing module location: $ModulePath"
read -p "Press enter to continue..."

if [ ! -d "$ModulePath" ]; then
    mkdir -p $ModulePath
fi

# create template folder structure, and default files
mkdir $ModulePath/doc
mkdir $ModulePath/hdl
mkdir $ModulePath/sim
mkdir $ModulePath/tcl

if [ ! -f "$ModulePath/doc/main.adoc" ]; then
    echo "= ${ModuleName} Documentation" > $ModulePath/doc/main.adoc
fi

if [ ! -f "$ModulePath/tcl/main.tcl" ]; then
    cp fwk/tpl/tpl_module.tcl $ModulePath/tcl/main.tcl
fi

# if [ ! -f "$ModulePath/README.adoc" ]; then
#     cp fwk/tpl/tpl_readme.adoc $ModulePath/README.adoc
#     touch $ModulePath/dependencies
# fi

# cd $ModulePath
# git init

echo "------------------------------------------------------------"
echo "Initialized sources module with basic structure."
echo "Set sources and properties in tcl/main.tcl"
echo "------------------------------------------------------------"
