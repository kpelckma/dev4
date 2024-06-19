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
# Contains procedures for Xilinx ISE project creation and build
# --------------------------------------------------------------------------- #

# ==============================================================================
proc testProject {} {
}

# ==============================================================================
proc cleanProject {} {
  # delete existing project files if existing
  set ProjExt [ list ise xise gise ]
  foreach ext $ProjExt {
    set curFile "${::fwfwk::PrjBuildName}.$ext"
    if { [ file exists $curFile ] } {
      file delete -force $curFile
    }
  }

}

# ==============================================================================
proc createProject {} {
  set version [getToolVersion]
  if {[set result [catch {eval project new $::fwfwk::PrjBuildName} resulttext]]} {
    puts "\n--------------------------------"
    ::fwfwk::utils::cprint $resulttext {"ERROR" -fg red -style bright}
    ::fwfwk::printError "Project creation failed with Xilinx ISE ver: $version."
    puts "Probably no Xilinx ISE in the path or wrong xtclsh used (run: which xtclsh)."
    ::fwfwk::exit -2
  }
  openProject
}

# ==============================================================================
proc saveProject {} {
  project save
}

# ==============================================================================
proc closeProject {} {
  project close
}

# ==============================================================================
proc openProject {} {

  set Prj ${::fwfwk::PrjBuildName}.xise
  if { ! [ file exists $Prj ] } {
    ## project file isn't there, rebuild it.
    puts "\n--------------------------------"
    ::fwfwk::printError "ERROR: ! Project ${::fwfwk::PrjBuildName} not found. Use create command to recreate it."
    ::fwfwk::exit -1
  }
  project open $Prj
}

# ==============================================================================
proc addSources {args srcList} {

  # default library work
  set libraryArg ""

  # get file list
  # get file libraries list
  set srcFiles {}
  set libList  {}
  foreach srcFile $srcList  {
    lappend srcFiles [lindex $srcFile 0]
    lappend libList  [lindex $srcFile 2]
  }

  foreach library $libList {
    if { "" != $library } {
      if {[catch { lib_vhdl get $library name } resulttext ]} {
        ::fwfwk::printInfo "Creating library: $library"
        lib_vhdl new $library
      }
    }
  }

  # parse the library argument
  set args [::fwfwk::utils::parseArgValue $args "-lib" libraryArg]

  if { "" != $libraryArg } {
    if {[catch { lib_vhdl get $libraryArg name } resulttext ]} {
      ::fwfwk::printInfo "Creating library: $libraryArg"
      lib_vhdl new $libraryArg
    }
  }

  foreach srcItem $srcList {
    set srcPath [lindex $srcItem 0]
    set srcLib  [lindex $srcItem 2]
    set largs {} ; #            # reset args
    set ext [file extension $srcPath]
    if { $ext == ".vhd" } {
      if { $srcLib != "" } {
        lappend largs -lib_vhdl
        lappend largs $srcLib
      } elseif { $libraryArg != "" } {
        lappend largs -lib_vhdl
        lappend largs $libraryArg
      }
    }
    if {[set result [catch {eval xfile add $srcPath $largs} resulttext]]} {
      puts "\n--------------------------------"
      ::fwfwk::utils::cprint $resulttext {"ERROR" -fg red -style bright}
      ::fwfwk::printError "xfile failed"
      ::fwfwk::exit -2
    }

  }
}


# ==============================================================================
proc buildProject {args} {

  # ------------------------------------------------------------------
  # compilation
  set task "Generate Programming File"
  puts "# Running '$task'"

  set result [ process run "$task" ]
  # check process status (and result)
  set tskstatus [ process get $task status ]
  puts "Task '$task' Status: $tskstatus , result: $result"
  # if { ( ( $status != "up_to_date" ) && } -- problem with multiple project on the same source
  if { $tskstatus == "errors" || \
      $tskstatus == "never_run" || \
      ! $result  } {
    puts "# ERROR: $::fwfwk::PrjBuildName $task run failed, check run output for details.\n"
    ::fwfwk::exit -1
  }
  # ERROR check. check if other process were successful in case generate is out of date ?
  if { $tskstatus == "out_of_date" } {
    set tskstatus [ process get "Synthesize" status ]
    if { $tskstatus == "errors" } {
      ::fwfwk::printError "$::fwfwk::PrjBuildName $task run failed because of XST process, check output for details. !\n"
      ::fwfwk::exit -1 }
    set tskstatus [ process get "Translate" status ]
    if { $tskstatus == "errors" } {
      ::fwfwk::printError "$::fwfwk::PrjBuildName $task run failed because of Translate process, check output for details. !\n"
      ::fwfwk::exit -1 }
    set tskstatus [ process get "Map" status ]
    if { $tskstatus == "errors" } {
      ::fwfwk::printError "$::fwfwk::PrjBuildName $task run failed because of Map process, check output for details. !\n"
      ::fwfwk::exit -1 }
    set tskstatus [ process get "Place & Route" status ]
    if { $tskstatus == "errors" } {
      ::fwfwk::printError "$::fwfwk::PrjBuildName $task run failed because of Place & Route process, check output for details. !\n"
      ::fwfwk::exit -1 }
  }
  # ------------------------------------------------------------------
  variable Top [ project get top ]
}

# ==============================================================================
proc exportOut {} {
  variable Top

  if {[info exists ::fwfwk::HwFile]} {
    ::releaseFile $::fwfwk::HwFile
  }

  ::fwfwk::releaseFile $::fwfwk::PrjBuildPath/${Top}.bit
  puts "-------------------------------------------------"
  ::fwfwk::printInfo "BIT file: $Top.bit moved to $::fwfwk::ReleasePath/$::fwfwk::ReleaseName.bit\n"
}


# ==============================================================================
#!
proc addGenIPs { args sources} {}

# ==============================================================================
#! function add .ngc ipcore file,if not exist it is trying to regenerate xco ipcore
proc genAddIP { IpPath } {

  set IpPath [file normalize $IpPath]
  set ipCoreName [file rootname [file tail $IpPath]]
  set ipCoreFile [file tail $IpPath]
  set ipCorePath $::fwfwk::PrjBuildPath/ipcores

  if {[file exists "$ipCorePath/${ipCoreName}/${ipCoreName}.ngc"] } {
    ::fwfwk::printInfo "adding IP core ${ipCoreName} generated netlist\n $ipCorePath/${ipCoreName}/${ipCoreName}.ngc"
    xfile add "${ipCorePath}/${ipCoreName}/${ipCoreName}.ngc"

  } else {
    puts "\n ! Regenerating core: $ipCoreName !\n"
    set CurrDir [pwd]
    #create IP folder if does not exist
    if {![file exists $ipCorePath ]} {file mkdir $ipCorePath}
    if {![file exists ${ipCorePath}/${ipCoreName} ]} { file mkdir ${ipCorePath}/${ipCoreName}}
    cd ${ipCorePath}/${ipCoreName}
    file copy -force $IpPath ${ipCorePath}/${ipCoreName}/${ipCoreFile}

    set device [ project get device ]
    set speed [ project get speed ]
    set package [ project get package ]
    set lang [ project get "Preferred Language" ]
    sourceFwkFile [ findRtfPath "data/projnav/scripts/dpm_cgUtils.tcl" ]
    set result [ run_cg_regen ${ipCoreName} "${device}${speed}${package}" $lang CURRENT ]
    cd $CurrDir

    xfile add "${ipCorePath}/${ipCoreName}/${ipCoreName}.ngc"
    ::fwfwk::printInfo "regeneration of $ipCoreName  is done !\n"

  }
}

# ==============================================================================
#! returns path for xilinx tools based on envarionment variable
proc findRtfPath { relativePath } {
   set xilenv ""
   if { [info exists ::env(XILINX) ] } {
      if { [info exists ::env(MYXILINX)] } {
         set xilenv [join [list $::env(MYXILINX) $::env(XILINX)] $::xilinx::path_sep ]
      } else {
         set xilenv $::env(XILINX)
      }
   }
   foreach path [ split $xilenv $::xilinx::path_sep ] {
      set fullPath [ file join $path $relativePath ]
      if { [ file exists $fullPath ] } {
         return $fullPath
      }
   }
   return ""
}

# ==============================================================================
proc genReport {} {

  # change directory to the current project build
  cd $::fwfwk::PrjBuildPath

  openProject
  variable Top [ project get top ]
  regsub -all {/} $Top "" Top
  project close
  set rc [catch {exec xreport $Top &} msg]

  return rc
}

# ==============================================================================

proc getToolVersion {} {
  set pathVar [file split $::env(PATH)]
  set idx [lsearch $pathVar ISE]
  set VersionFromPath [lindex $pathVar [expr $idx-2]]
  return $VersionFromPath
}
