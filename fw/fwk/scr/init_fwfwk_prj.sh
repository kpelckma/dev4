#!/bin/bash


# create template folder structure, and default files
mkdir cfg
mkdir doc
mkdir src
mkdir prj
mkdir tcl

if [ ! -f "doc/main.adoc" ]; then
    echo "= Documentation" > doc/main.adoc
fi

# Makefile
if [ ! -f "Makefile" ]; then
    echo "include fwk/Makefile" > Makefile
fi

if [ ! -f "cfg/default.cfg" ]; then
    # default project configuration with the main variables listed
    echo "# project default configuration" > cfg/default.cfg
    echo "ProjectName=$1" >> cfg/default.cfg
    echo "ProjectConf=default" >> cfg/default.cfg
    echo "ProjectTcl=tcl/project.tcl" >> cfg/default.cfg
    echo "AddrType=" >> cfg/default.cfg
    echo "ToolType=" >> cfg/default.cfg
fi

# default project tcl
if [ ! -f "tcl/project.tcl" ]; then
    cp fwk/tpl/tpl_project.tcl tcl/project.tcl
fi

# default gitignore
if [ ! -f ".gitignore" ]; then
    echo "prj" >> .gitignore
    echo "out" >> .gitignore
    echo "*.log" >> .gitignore
    echo ".*" >> .gitignore
    echo ".Xil" >> .gitignore
    echo "!.gitignore" >> .gitignore

fi


echo "------------------------------------------------------------"
echo "Initialized firmware framework project with basic structure."
echo "Set default configuration variables in cfg/default.cfg"
echo "and add module sources in tcl/project.tcl"
echo "------------------------------------------------------------"
