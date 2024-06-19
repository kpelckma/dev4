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
# @date 2021-03-17
# @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# Contains procedures for rust_hdl tool
# --------------------------------------------------------------------------- #


# do not execute tool dependent stages (setPrjProperties setProperties)
variable SetPrjProperties 0

# array set SourcesArray {}
# variable SourcesArray
# variable LibList {}

# ==============================================================================
proc cleanProject {} {
  # if { [file exists ${::fwfwk::ProjectPath}/vhdl_ls.toml] } {
  #   file delete -force ${::fwfwk::ProjectPath}/vhdl_ls.toml
  # }
}

# ==============================================================================
proc createProject {} {
  variable SourcesArray
  array set SourcesArray {}
  set SourcesArray(0,LibIdx) 0

  addToolLibraries

}

# ==============================================================================
proc closeProject {} {}

# ==============================================================================
proc saveProject {} {

  # ghdl uses Tcl just to crate cmake file sim is run using make
  # no tcl in sum process, all set sim commands should be here
  ::fwfwk::setSim

  variable SourcesArray

  # sort array and create sorted list
  foreach {key value} [array get SourcesArray] {
    set curId  [lindex [split $key ,] 0]
    set curKey [lindex [split $key ,] 1]
    lappend la [list $curId $curKey $value]
  }
  set las [lsort -integer -index 0 $la]

  set depLibs {}

  set CMakeListFile [open ${::fwfwk::PrjBuildPath}/CMakeLists.txt w]

  puts $CMakeListFile "cmake_minimum_required(VERSION 3.3)"
  # Set the project name
  puts $CMakeListFile "project (${::fwfwk::PrjBuildName} NONE)"
  puts $CMakeListFile "enable_testing()"

  set ghdlLibDirOpt ""
  if { [info exists ::env(FWK_GHDL_LIBS)] } {
    set ghdlLibs [split $::env(FWK_GHDL_LIBS) ":"]
    foreach lib $ghdlLibs {
      set ghdlLibDirOpt "$ghdlLibDirOpt -P$lib"
    }
  }

  set ghdlFlags ""
  if { [info exists ::env(FWK_GHDL_FLAGS)] } {
    set ghdlFlags $::env(FWK_GHDL_FLAGS)
  }

  foreach element $las {
    set curId    [lindex $element 0]
    set lib      [lindex $element 1]
    set sourcess [lindex $element 2]
    if {$curId == 0} { continue }
    set varName "VHDL_SRC_[string toupper $lib]"
    foreach src $sourcess {
      puts $CMakeListFile "list (APPEND \"$varName\" \"$src\")"
      puts $CMakeListFile "message(\"-- Adding VHDL Source @${lib}: $src\")"
    }
    puts $CMakeListFile "add_custom_target(library_$lib ALL)"
    puts $CMakeListFile "add_custom_command(TARGET library_$lib COMMAND ghdl -i --std=08 -fsynopsys $ghdlFlags $ghdlLibDirOpt --work=${lib} --workdir=${::fwfwk::PrjBuildPath} \$\{$varName\})"
    lappend depLibs "library_$lib"
  }
  set idx 0
  foreach test $::fwfwk::src::SimTop {
    if { [llength $::fwfwk::src::SimTime] == 1} {
      set simStopTime "--stop-time=$::fwfwk::src::SimTime"
    } elseif { [llength $::fwfwk::src::SimTime] >= 1} {
      set simStopTime "--stop-time=[lindex $::fwfwk::src::SimTime $idx]"; incr idx
    } else {
      set simStopTime ""
    }

    puts $CMakeListFile "add_custom_target($test ALL COMMAND ghdl -m --std=08 -fsynopsys $ghdlFlags $ghdlLibDirOpt --workdir=${::fwfwk::PrjBuildPath} $test DEPENDS $depLibs)"
    puts $CMakeListFile "add_test(NAME $test COMMAND ghdl -r --workdir=${::fwfwk::PrjBuildPath} $test $simStopTime --assert-level=error --wave=${test}.ghw --vcd=${test}.vcd)"
  }

  puts $CMakeListFile "add_custom_target(elab DEPENDS $::fwfwk::src::SimTop)"

  puts $CMakeListFile "add_custom_target(${::fwfwk::src::Top}_synth COMMAND ghdl -m --std=08 -fsynopsys $ghdlFlags $ghdlLibDirOpt --workdir=${::fwfwk::PrjBuildPath} $::fwfwk::src::Top DEPENDS $depLibs)"
  puts $CMakeListFile "add_custom_target(synth COMMAND \
                       ghdl --synth --std=08 -fsynopsys $ghdlLibDirOpt $ghdlFlags --workdir=${::fwfwk::PrjBuildPath} $::fwfwk::src::Top > ${::fwfwk::src::Top}_synth.vhd \
                       DEPENDS ${::fwfwk::src::Top}_synth $depLibs)"

  close $CMakeListFile
  puts "-- created CMakeList.txt file in project build $::fwfwk::PrjBuildPath"


}

# ==============================================================================
# add tool libraries based on availability in the environment paths
proc addToolLibraries {} {
  variable SourcesArray
  set path ''

  # Xilinx ISE
  # if { [info exists ::env(XILINX)] } {
  #   set path "$::env(XILINX)/vhdl/src"
  #   if { [file exists $path]} {
  #     set idx [findLibIndex unisim]
  #     lappend SourcesArray($idx,unisim) $path/unisims/unisim_VCOMP.vhd
  #     lappend SourcesArray($idx,unisim) $path/unisims/unisim_VPKG.vhd
  #     set idx [findLibIndex unimacro]
  #     lappend SourcesArray($idx,unimacro) $path/unimacro/unimacro_VCOMP.vhd
  #   }
  # }

  # # Xilinx Vivado
  # if { [info exists ::env(XILINX_VIVADO)] } {
  #   set path "$::env(XILINX_VIVADO)/data/vhdl/src"
  #   if { [file exists $path]} {
  #     set idx [findLibIndex unisim]
  #     lappend SourcesArray($idx,unisim) $path/unisims/unisim_VCOMP.vhd
  #     lappend SourcesArray($idx,unisim) $path/unisims/unisim_VPKG.vhd
  #     set idx [findLibIndex unimacro]
  #     lappend SourcesArray($idx,unimacro) $path/unimacro/unimacro_VCOMP.vhd
  #   }
  # }

  # if { [file exists $path]} {
  #   puts "Found $path"
  #   foreach library [glob -directory $path -tails -types d *] {
  #     #puts $library
  #     set files [concat [glob -directory ${path}/${library} -nocomplain -types f *.vhd]]
  #     foreach libFile $files { 
  #       lappend SourcesArray($library) $libFile
  #     }
  #   }
  # }
}

# ==============================================================================
proc addSources {args srcList} {
  variable SourcesArray

  # default library work
  set defLibrary work

  # parse the library argument
  set library ""
  set args [::fwfwk::utils::parseArgValue $args "-lib" library]

  foreach src $srcList {
    # Currently Rust HDL supports VHDL only
    set srcFile [lindex $src 0]
    set srcLib  [lindex $src 2]
    set ext [file extension $srcFile]
    if { $ext == ".vhd" } {
      if { $srcLib != ""} { # use file library
        set idx [findLibIndex $srcLib]
        lappend SourcesArray($idx,$srcLib) $srcFile
      } elseif { $library != ""} { # -lib arg default library
          set idx [findLibIndex $library]
          lappend SourcesArray($idx,$library) $srcFile
      } else { # use default tool library
        set idx [findLibIndex $defLibrary]
        lappend SourcesArray($idx,$defLibrary) $srcFile
      }
    }
  }

}

proc findLibIndex {library} {
  variable SourcesArray
  foreach {key value} [array get SourcesArray] {
    set curId  [lindex [split $key ,] 0]
    set curKey [lindex [split $key ,] 1]
    if {$curKey == $library} {
      return $curId
    }
  }
  # if not found, add index based on current lib cnt
  incr SourcesArray(0,LibIdx)
  return $SourcesArray(0,LibIdx)
}
# ==============================================================================
proc simProject {} {

}


# ==============================================================================
# dummy
proc addGenIPs { args sources} {}
