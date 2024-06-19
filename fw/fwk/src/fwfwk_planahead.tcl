## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2021 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2021-12-06
# @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# Contains procedures for Xilinx PlanAhead project creation and build
# --------------------------------------------------------------------------- #

# ==============================================================================
proc testProject {} {
}

# ==============================================================================
proc cleanProject {} {
  # delete existing project files if existing
  set ProjExt [ list ppr data gen]
  foreach ext $ProjExt {
    set curFile "${::fwfwk::PrjBuildName}.$ext"
    if { [ file exists $curFile ] } {
      file delete -force $curFile
    }
  }

}

# ==============================================================================
proc createProject {} {
  create_project -force $::fwfwk::PrjBuildName
}

# ==============================================================================
proc openProject {} {

  set Prj ${::fwfwk::PrjBuildName}.ppr
  if { ! [ file exists $Prj ] } {
    ## project file isn't there, rebuild it.
    puts "\n--------------------------------"
    ::fwfwk::printError "Project ${::fwfwk::PrjBuildName} not found. Use create command to recreate it."
    ::fwfwk::exit -1
  }
  if {[set result [catch {open_project $Prj} resulttext]]} {
    ::fwfwk::printInfo "Project already opened."
  }
  update_compile_order -fileset [current_fileset]
}

# ==============================================================================
proc closeProject {} {
  close_project
}

# ==============================================================================
proc saveProject {} {}

# ==============================================================================
proc addSources {args srcList} {

  # default library work
  set library ""

  # parse the library argument
  set args [::fwfwk::utils::parseArgValue $args "-lib" library]

  # get file list
  set srcFiles {}
  foreach srcFile $srcList  {
    lappend srcFiles [lindex $srcFile 0]
  }

  # add files
  if { $args == "" } {
    if {[set result [catch {eval add_files $srcFiles} resulttext]]} {
      puts $::errorInfo
      puts "add_files $args $srcFiles"
      ::fwfwk::exit -2
    }
  } else {
    if {[set result [catch {eval add_files $args $srcFiles} resulttext]]} {
      puts $::errorInfo
      puts "add_files $args $srcFiles"
      ::fwfwk::exit -2
    }
  }

  # set files properties
  foreach srcItem $srcList  {
    set srcFile   [lindex $srcItem 0]
    set srcType   [lindex $srcItem 1]
    set srcLib    [lindex $srcItem 2]
    set usedIn    [lindex $srcItem 3]
    set procOrder [lindex $srcItem 4]
    # support upper and lower case in the list or different format
    switch -regexp [string tolower $srcType] {
      "vhdl|vhd" {
        set_property FILE_TYPE "VHDL" [get_files $srcFile]
        if { $srcLib != "" } { set_property LIBRARY $srcLib [get_files $srcFile]
        } elseif { $library != "" } { set_property LIBRARY $library [get_files $srcFile] }
        #if { $usedIn != "" } { set_property USED_IN $usedIn [get_files $srcFile] }
      }
      "verilog|v" {
        set_property FILE_TYPE "Verilog" [get_files $srcFile]
        if { $srcLib != "" } { set_property LIBRARY $srcLib [get_files $srcFile]
        } elseif { $library != "" } { set_property LIBRARY $library [get_files $srcFile] }
        #if { $usedIn != "" } { set_property USED_IN $usedIn [get_files $srcFile] }
      }
      "vhdl 2008" {             # 2008 not supported - VHDL
        set_property FILE_TYPE "VHDL" [get_files $srcFile]
        if { $srcLib != "" } { set_property LIBRARY $srcLib [get_files $srcFile]
        } elseif { $library != "" } { set_property LIBRARY $library [get_files $srcFile] }
        # if { $usedIn != "" } { set_property USED_IN $usedIn [get_files $srcFile] }
        puts "# WARNING: VHDL 2008 type not supported in PlanAhead"
      }
      "ucf" {
        set_property FILE_TYPE "UCF" [get_files $srcFile]
        if { $srcLib != "" }    { add_files -fileset $srcLib -norecurse [get_files $srcFile]}; # add file to constrains fileset
        # if { $usedIn != "" }    { set_property USED_IN          $usedIn    [get_files $srcFile] }
        # if { $procOrder != "" } { set_property PROCESSING_ORDER $procOrder [get_files $srcFile] }
      }
      default {
        #do nothing
      }
    }
  }


  # overwrite src lib definition with argument one
  if { "" != $library} {
    set_property library $library [get_files  $srcFiles]
  }
}

# ==============================================================================
proc buildProject {args} {
  # ------------------------------------------------------------------
  # compilation
  reset_run "impl_1"
  reset_run "synth_1"

  if {[catch { launch_runs synth_1 } resulttext ]} { puts $resulttext; ::fwfwk::exit -1 }
  wait_on_run synth_1

  if {[catch { launch_runs impl_1 } resulttext ]} {
    puts "Synth report:"
    set grepResult [::fwfwk::utils::grepFiles "ERROR:" [glob ${::fwfwk::PrjBuildPath}/${::fwfwk::PrjBuildName}.runs/synth_1/*.srp]]
    puts [::fwfwk::utils::cgrep $grepResult "ERROR" -fg red -style bright]

    puts "$resulttext"; ::fwfwk::exit -1 }
  if {[catch { wait_on_run impl_1 } resulttext ]} { ::fwfwk::exit -1 }

  catch { launch_runs impl_1 -to_step Bitgen }
  wait_on_run [current_run]

}


# ==============================================================================
#! export bit file to out folder
proc exportOut {} {

  set top [get_property TOP [current_fileset]]
  set dir [get_property DIRECTORY [current_run]]
  puts "Copy bit file to: $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}_${::fwfwk::VerString}.bit"
  if {[catch { file copy -force ${dir}/${top}.bit $::fwfwk::ProjectPath/out/${::fwfwk::PrjBuildName}/${::fwfwk::PrjBuildName}_${::fwfwk::VerString}.bit } resulttext ]} {
    puts "$resulttext";
    ::fwfwk::exit -1
  }
}

# ==============================================================================
#! function add .ngc ipcore file,if not exist it is trying to regenerate xco ipcore
proc genAddIP { IpPath } {

}

# ==============================================================================
# dummy
proc addGenIPs { args sources} {}

