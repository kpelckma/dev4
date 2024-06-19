## -------------------------------------------------------------------------- #
#           ____  _____________  __                                           #
#          / __ \/ ____/ ___/\ \/ /                 _   _   _                 #
#         / / / / __/  \__ \  \  /                 / \ / \ / \                #
#        / /_/ / /___ ___/ /  / /               = ( M | S | K )=              #
#       /_____/_____//____/  /_/                   \_/ \_/ \_/                #
#                                                                             #
# --------------------------------------------------------------------------- #
# @copyright Copyright 2022 DESY
# SPDX-License-Identifier: Apache-2.0
# --------------------------------------------------------------------------- #
# @date 2022-07-05
# @author Andrea Bellandi andrea.bellandi@desy.de
# --------------------------------------------------------------------------- #
# @brief#
# Part of DESY FPGA Firmware Framework (fwk)
# contains procedures for Xilinx XPS creation and build
# --------------------------------------------------------------------------- #

# ==============================================================================
proc testProject {} {
}

# ==============================================================================
proc cleanProject {} {
  # delete existing project files if existing
  set curFile "${::fwfwk::PrjBuildPath}"
  if { [ file exists $curFile ] } {
    file delete -force $curFile
  }
}

# ==============================================================================
proc createProject {} {
  variable HwFile
  variable MemFile
  variable BitFile
  variable HeaderDirectories ""
  variable AppguruFlags

  if {![info exists ::fwfwk::CFlags]} {
    namespace eval ::fwfwk {
      variable CFlags ""
    }
  }

  if {![info exists ::fwfwk::AccessChannel]} {
    namespace eval ::fwfwk {
      variable AccessChannel "C8"
    }
  }


  if {[info exists ::fwfwk::AppguruFlags]} {
    set AppguruFlags $::fwfwk::AppguruFlags
  } else {
    set AppguruFlags [list]
  }

  ::fwfwk::printInfo "Create Project from fwfwk_appguru.tcl, createProject proc"
  ::fwfwk::printInfo "Create Make project"

  variable verStringSub "\$\{VerString\} $::fwfwk::VerString"

  set HwFile  [glob [string map $verStringSub $::fwfwk::HwFile]]
  set BitFile [glob [string map $verStringSub $::fwfwk::BitFile]]
  set MemFile [glob [string map $verStringSub $::fwfwk::MemFile]]

  puts "----------------------------------------------------"
  ::fwfwk::printInfo "Project path : ${::fwfwk::WorkspacePath}"
  ::fwfwk::printInfo "Platform name  : ${::fwfwk::PlatformName}"
  ::fwfwk::printInfo "HW file: $HwFile"
  ::fwfwk::printInfo "Mem file: $MemFile"
  ::fwfwk::printInfo "Bit file: $BitFile"
  puts "----------------------------------------------------"

  # --------------------------------------------------------
  # creating the BSP support

  ::fwfwk::utils::xps::generateCpuSwBsp $HwFile $::fwfwk::WorkspacePath $AppguruFlags

}


# ==============================================================================
proc openProject {} {}

# ==============================================================================
proc closeProject {} {}

# ==============================================================================
proc saveProject {} {

  variable HeaderDirectories

  puts "----------------------------------------------------"
  ::fwfwk::printInfo "Saving project information"
  puts "----------------------------------------------------"

  ::fwfwk::printInfo "HeaderDirectories: $HeaderDirectories"

  variable HeaderDirectories
  variable ElfName $::fwfwk::ReleaseName.elf
  variable ElfPath
  set ElfPath [file join $::fwfwk::WorkspacePath $ElfName]

  if {![file exists $::fwfwk::addr::ArtifactsPath/h]} {
    file mkdir $::fwfwk::addr::ArtifactsPath/h
  }

  lappend HeaderDirectories -I$::fwfwk::addr::ArtifactsPath/h

  set fp [open [file join $::fwfwk::WorkspacePath compile.sh] "w"]
  puts $fp "#!/usr/bin/env sh"
  puts $fp "make EXEC=$::fwfwk::ReleaseName.elf CFLAGS=\"$HeaderDirectories $::fwfwk::CFlags -DACCESS_CHANNEL_$::fwfwk::AccessChannel\""
  close $fp

}

# ==============================================================================
proc addSources {args srcList} {

  variable CSrcs [list]
  variable HeaderDirectories

  foreach src $srcList {
    if {[llength $src] >= 2} {
      set path [lindex $src 0]
      set type [lindex $src 1]
      if { $type == "includes"} {
        lappend HeaderDirectories "-I[file normalize $path]"
        ::fwfwk::printInfo "Includes dir added: [file normalize $path]"
      } elseif { $type == "sources" } {
        set CSrcs [concat $CSrcs [glob -nocomplain -directory $path *.c]]
        set CSrcs [concat $CSrcs [glob -nocomplain -directory $path *.S]]
        set CSrcs [concat $CSrcs [glob -nocomplain -directory $path *.s]]
        ::fwfwk::printInfo "Source dir added: $path"
      } else {
        ::fwfwk::printError "type $type not recognized"
        ::fwfwk::exit -1
      }
    } else {
      lappend CSrcs $src
    }
  }

  foreach csrc $CSrcs {
    file delete -force [file join $::fwfwk::WorkspacePath [file tail $csrc]]
    file link -symbolic [file join $::fwfwk::WorkspacePath [file tail $csrc]] $csrc
  }
}

# ==============================================================================
proc buildProject {args} {

  variable ElfName $::fwfwk::ReleaseName.elf
  variable ElfPath
  set ElfPath [file join $::fwfwk::WorkspacePath $ElfName]

  puts "----------------------------------------------------"
  ::fwfwk::printInfo "Compiling $::fwfwk::ReleaseName.elf"
  puts "----------------------------------------------------"

  set CurDir [pwd]

  cd $::fwfwk::WorkspacePath

  exec 2>stderr_compile bash compile.sh

  cd $CurDir
}

# ==============================================================================
proc exportOut {} {

  variable ElfPath
  variable BitFile
  variable MemFile

  set CurDir [pwd]
  cd ..

  variable verStringSub "\$\{VerString\} $::fwfwk::VerString"
  set MemFile [glob [string map $verStringSub $::fwfwk::MemFile]]
  set BitFile [glob [string map $verStringSub $::fwfwk::BitFile]]

  ::fwfwk::releaseFile $ElfPath

  puts "----------------------------------------------------"
  ::fwfwk::printInfo "Generating ${::fwfwk::ReleaseName}.bit"
  puts "----------------------------------------------------"

  set ReleasedBit [file join ${::fwfwk::ReleasePath} ${::fwfwk::ReleaseName}.bit]
  set stderr_data2mem $::fwfwk::PrjBuildPath/stderr_data2mem
  exec 2>$stderr_data2mem data2mem -bm $MemFile -bt $BitFile -bd $ElfPath -o b $ReleasedBit

  cd $CurDir
}
