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
# @date 2021-06-07
# @author Andrea Bellandi   <andrea.bellandi@desy.de>
# @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# Contains common utilities for internal use
# --------------------------------------------------------------------------- #

namespace eval ::fwfwk::utils {
  # -----------------------------------------------------------------------------
  ## parseArgValue
  # check if $option is present in argsLine. If found, the successive element
  # is set in a variable name $value
  # return $argsLine without $option
  proc parseArgValue { argsLine option value } {
    set optionIndex [lsearch $argsLine $option]
    if {$optionIndex > -1} {
      set tempName [lindex $argsLine [expr {$optionIndex + 1}]]
      if {0 != [string length $tempName]} {
        upvar $value valueBind
        set valueBind $tempName
        return [lreplace $argsLine $optionIndex [expr {$optionIndex + 1}]]
      } else {
        return [lreplace $argsLine $optionIndex $optionIndex ]
      }
    }
    return $argsLine
  }

  # -----------------------------------------------------------------------------
  ## parseArgFlag
  # check if $option is present in argsLine. If found, the $value is set to 1
  # 0 otherwise
  # return $argsLine without $option
  proc parseArgFlag { argsLine option flag } {
    upvar $flag valueBind
    set optionIndex [lsearch $argsLine $option]
    if {$optionIndex > -1} {
        set valueBind 1
        return [lreplace $argsLine $optionIndex $optionIndex ]
    }

    set valueBind 0
    return $argsLine
  }

  # ==============================================================================
  ## cleanDir
  # Clean the files inside a directory additional arguments are not deleted
  # ------------------------------------------------------------------------------
  proc cleanDir { path {KeptFiles ""} } {
    #puts "-------------------------------------------------\n"
    ::fwfwk::printInfo "Cleaning $path"
    #puts "-------------------------------------------------\n"
    if {[file exists $path]} {
      set curDir [pwd]
      cd $path
      set fileslist [glob -nocomplain -directory . -tails *]

      foreach KeptFile $KeptFiles {
        puts "  Keeping $KeptFile"
        regsub -all $KeptFile $fileslist "" fileslist
      }
      foreach file $fileslist {
        #puts "INFO: Deleting $file \n"
        file delete -force $file
      }
      cd $curDir
    }
  }

}

proc ::fwfwk::utils::findFiles { baseDir pattern } {
  set dirs [ glob -nocomplain -types d [ file join $baseDir * ] ]
  set files {}
  foreach dir $dirs {
    set curFile [concat [findFiles $dir $pattern ] ]
    if { $curFile != "" } {
      lappend files $curFile
    }
  }
  set curFile [glob -nocomplain -types f [ file join $baseDir $pattern]]
  if { $curFile != "" } {
    lappend files $curFile
  }
  return $files
}

#	Implementation of grep based on Tcler's Wiki.
# return list of matched lines
proc ::fwfwk::utils::grepFiles {pattern filenames} {
  set result [list]
  foreach filename $filenames {
    set file [open $filename r]
    set lnum 0
    while {[gets $file line] >= 0} {
      incr lnum
      if {[regexp -- $pattern $line]} {
        lappend result "${line}"
      }
    }
    close $file
  }
  return $result
}

## list all namespaces
proc ::fwfwk::utils::listns {{parentns ::}} {
  set result [list]
  foreach ns [namespace children $parentns] {
    eval lappend result [::fwfwk::utils::listns $ns]
    lappend result $ns
  }
  return $result
}

# check if docker image with given name/ID exists
proc ::fwfwk::utils::existsDockerName {dockerName} {
  set cmdToRun \
    [list \
       docker inspect --type=image --format=""  \
       $dockerName
      ]
  if { [catch { eval exec $cmdToRun } resulttext] } {
    return 0
  } else {
    return 1
  }
}

# include color grep to print color regexp to console
namespace eval ::fwfwk::utils::cgrep {
  sourceFwkFile cgrep.tcl
}

proc ::fwfwk::utils::cgrep {lines args} {
  ::fwfwk::utils::cgrep::main $lines $args
}

proc ::fwfwk::utils::cprint {message argv} {
  global colorTerminal
  if {$colorTerminal == 0 } {
    puts $message
  } else {
    set args [::fwfwk::utils::cgrep::process_args $argv]
    puts [::fwfwk::utils::cgrep::render_line $message \
            [::fwfwk::utils::cgrep::resequence \
               [::fwfwk::utils::cgrep::get_matches $message $args]]]
  }
}

# gues source type based on source file extention
proc ::fwfwk::utils::getSrcType {filePath} {
  set ext [file extension $filePath]
  return [string range $ext 1 end]
}
