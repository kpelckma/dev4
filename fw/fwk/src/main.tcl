## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2019-2023 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2023-01-26
# @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
# @author Seyed Nima Omidsajedi <nima.sajedi@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# Main Tcl script for the firmware framework. Starting point.
# --------------------------------------------------------------------------- #

namespace eval ::fwfwk {}

global executionFolder
global colorTerminal
global hls_Headers
global Exit
set Exit 0
set colorTerminal 0

# -----------------------------------------------------------------------------
# main
proc ::fwfwk::main {args} {

  global colorTerminal
  global hls_Headers
  global scriptFolder
  global executionFolder
  global Exit

  # set lang to be used
  set ::env(LANG) "en_US.UTF-8"
  set ::env(LANGUAGE) "en_US.UTF-8"
  set ::env(LC_ALL) "en_US.UTF-8"

  set dispScriptFile [file normalize [info script]]
  set scriptFolder [file dirname $dispScriptFile]
  set executionFolder [pwd]

  set ::fwfwk::GuiMode 0;       # default no gui
  set ::fwfwk::ModuleOwnLib 0;  # default Modules in common default libraries

  # if rexecuting, Path already exist:
  if {[info exists ::fwfwk::ProjectPath] } {
    cd $::fwfwk::ProjectPath/fwk/src
  } else {
    # go to script location
    # puts "root: [file tail $dispScriptFile]"
    if { [file tail $dispScriptFile] == "vsim"} {
      set args [lrange [lindex $args end] 2 end]
      proc ::fwfwk::exit {{arg}} { if { $arg != "" } {quit -code $arg} else {quit}}
      cd fwk/src
    } else {
      cd $scriptFolder
    }

    # set absolute path of the current project
    set ::fwfwk::ProjectPath [file normalize "../../"]
    set ::fwfwk::Path ${::fwfwk::ProjectPath}/fwk/src
  }
  # create tool type variable if does not exist
  if {![info exists ::fwfwk::ToolType] } {set ::fwfwk::ToolType "" }

  # -----------------------------------------------------------------------------
  # load libraries
  # load dict library for Tcl version 8.4 (e.g. Xilinx ISE)
  set TclVersion [info patchlevel]
  set match [regexp {(\d+)\.(\d+).(\d+)} $TclVersion totalmach TclMajor TclMinor TclPatch]
  if { "$TclMajor.$TclMinor" == "8.4" } {
    sourceFwkFile $::fwfwk::Path/dict.tcl
  }

  # sourceFwkFile main framework
  sourceFwkFile fwfwk.tcl

  # sourceFwkFile fwfwk utils library
  sourceFwkFile fwfwk_utils.tcl

  # sourceFwkFile fwfwk address library
  sourceFwkFile fwfwk_addr.tcl

  # sourceFwkFile fwfwk doc library
  sourceFwkFile fwfwk_doc.tcl

  # sourceFwkFile xps specific utils library
  sourceFwkFile fwfwk_utils_xps.tcl

  # default variables settings
  set taskoption ""
  set addressType ""
  set toolType ""
  set Exit 0
  set configFile "../../cfg/default.cfg"

  # get noexit option arg
  set args [::fwfwk::utils::parseArgValue $args "--colorterm" colorTerminal]

  ::fwfwk::printc {-fg blue -style bright} "\n--------------------------------------------------------------------------------"
  ::fwfwk::printc {-fg blue -style bright} "-- running firmware framework main tcl script                 & MSK DESY &    --"
  ::fwfwk::printc {-fg blue -style bright} "--------------------------------------------------------------------------------\n"

  # ::fwfwk::printCBM "\n--------------------------------------------------------------------------------"
  # ::fwfwk::printCBM "-- running firmware framework main tcl script                 & MSK DESY &    --"
  # ::fwfwk::printCBM "--------------------------------------------------------------------------------\n"

  ::fwfwk::printInfo "Absolute path of the firmware framework project:\n\[::fwfwk::ProjectPath\] ${::fwfwk::ProjectPath}"

  #puts "Arguments:"
  ::fwfwk::printInfo "main.tcl \[args\]: $args"

  if { [llength $args] == 0 } {
    return
  }

  # get noexit option arg
  set args [::fwfwk::utils::parseArgFlag $args "--exit" Exit]
  set ::fwfwk::ExitMode $Exit

  # get project config file arg
  set args [::fwfwk::utils::parseArgValue $args "-c" configFile]

  # get tool
  set args [::fwfwk::utils::parseArgValue $args "-t" toolType]

  ::fwfwk::loadProjectInfo $configFile

  if { $toolType != $::fwfwk::ToolType && $toolType != "" } {
    ::fwfwk::printWarning "overwriting default tool type with $toolType\n"
    set ::fwfwk::ToolType $toolType }

  # sourceFwkFile the tool backend
  ::fwfwk::printInfo "Sourcing  fwfwk_${::fwfwk::ToolType}.tcl"
  if { [file exists ${::fwfwk::Path}/fwfwk_${::fwfwk::ToolType}.tcl] } {
    namespace eval ::fwfwk::tool {
      # indicates whether the tool has tool-specific procedures
      variable SetPrjProperties 1
      sourceFwkFile ${::fwfwk::Path}/fwfwk_${::fwfwk::ToolType}.tcl
      namespace export createProject buildProject cleanProject
      namespace export genAddIP exportOut addSources
    }
  } else {
    ::fwfwk::printWarning "no tool fwfwk_${::fwfwk::ToolType}.tcl backend found.\n"
  }

  # sourceFwkFile optional libraries if proper variables set
  # OSVVM
  if { [info exists ::env(FWK_OSVVM_PATH)] } {
    if { ! [file exists $::env(FWK_OSVVM_PATH)]} {
      ::fwfwk::printWarning "FWK_OSVVM_PATH: $::env(FWK_OSVVM_PATH) path does not exists";
    } else {
      set ::fwfwk::OsvvmPath $::env(FWK_OSVVM_PATH)
      ::fwfwk::printInfo "Sourcing OSVVM scripts from ::env(FWK_OSVVM_PATH): $::fwfwk::OsvvmPath"
      namespace eval ::osvvmfwk {
        sourceFwkFile $::env(FWK_OSVVM_PATH)/Scripts/StartUp.tcl
      }
    }
  }

  # create out folder if does not exist
  ::fwfwk::createOutDir

  # --------------------------------------------
  set runResult [eval ::fwfwk::run $args]
  # --------------------------------------------

  # exit tool
  if { $Exit == 1 } {
    puts "Exiting tool..."
    if { [file tail $dispScriptFile] == "vsim"} {quit -sim}; # when vsim quit simulation first
    cd $executionFolder
    exit $runResult
  }

}

# -----------------------------------------------------------------------------
proc ::fwfwk::run { args } {

  variable taskOption {}
  variable addressType {}
  variable docType {}

  # get addrestype option args
  set args [::fwfwk::utils::parseArgValue $args "-a" addressType]

  # get doc type
  set args [::fwfwk::utils::parseArgValue $args "-dt" docType]

  # get task option arg
  set args [::fwfwk::utils::parseArgValue $args "-o" taskOption]

  ::fwfwk::getVersion ::fwfwk
  ::fwfwk::printProjectInfo
  ::fwfwk::listSubmodules

  set ::fwfwk::ReleasePath  [file join $::fwfwk::ProjectPath out $::fwfwk::PrjBuildName]
  set ::fwfwk::ReleaseName  ${::fwfwk::PrjBuildName}_${::fwfwk::VerString}

  foreach task $args {
    switch $task {
      "info"   {
        # default prints just initial
      }
      "init" {
        if { [namespace exists ::fwfwk::src] } { namespace delete ::fwfwk::src }
        if { [namespace exists ::fwfwk::lib] } { namespace delete ::fwfwk::lib }
        ::fwfwk::printCBM "\n== INIT =="
        if { [info exists ::fwfwk::OsvvmPath]} {
          ::fwfwk::addSrcModule ::fwfwk::lib osvvm ./lib_osvvm.tcl
        } else {                # evaluate and create empty namespace
          namespace eval ::fwfwk::lib {}
        }
        ::fwfwk::addSrcModule ::fwfwk src $::fwfwk::ProjectTcl
        ::fwfwk::genSrcTree
      }
      "addr"   {
        ::fwfwk::printCBM "\n== ADDRESS SPACE =="
        ::fwfwk::addr::main $addressType
      }
      "doc"   {
        ::fwfwk::printCBM "\n== DOCUMENTATION =="
        ::fwfwk::doc::main $docType
      }
      "create"    { ::fwfwk::createProject }
      "build"     { ::fwfwk::buildProject }
      "simulate"  { ::fwfwk::simulateProject }
      "synth"     { ::fwfwk::synthProject }
      "clean"     { ::fwfwk::cleanProject }
      "test"      { ::fwfwk::testProject }
      "gui"       { ::fwfwk::guiProject }
      default  {
        ::fwfwk::printError "Unrecognized command: $task"
        return -1
      }
    }
  }
  return 0
}

# rerun main init with all
proc ::fwfwk::reinit {} {
  set currPath [pwd]
  cd $::fwfwk::ProjectPath
  if { [catch { eval ::fwfwk::main $::argv } resulttext] } {}
  cd $currPath
}

# wrap source procedure to add tool specific switches
proc sourceFwkFile { sourceFile } {
  if { $::fwfwk::GuiMode && ($::fwfwk::ToolType == "vivado" || $::fwfwk::ToolType == "planahead" )} {
    set script "source -notrace $sourceFile"
    uplevel $script
  } else {
    set script "source $sourceFile"
    uplevel $script
  }
}

proc ::fwfwk::exit { exitCode } {
  if { $::fwfwk::ExitMode == 1 } {
    ::exit $exitCode
  } else {
    ::fwfwk::printError "Exit code $exitCode"
  }
}

if { [info script] == $::argv0 } {
  # -----------------------------------------------------------------------------
  if { [catch { eval ::fwfwk::main $::argv } resulttext] } {
    puts "\n !! Project script failed: \n"
    set einfo $::errorInfo
    set ecode $::errorCode
    puts "\[ERROR CODE\]: $ecode"
    puts "\[ERROR INFO\]:\n $einfo"
    ::fwfwk::printError "Failed. Check ERROR INFO for details."
    if { $Exit == 1 } {
      puts "Exiting tool..."
      ::fwfwk::exit -10
    }
  }

}

