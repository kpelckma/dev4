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

array set SourcesArray {}
variable SourcesArray
variable LibList {}

# ==============================================================================
proc cleanProject {} {
  if { [file exists ${::fwfwk::ProjectPath}/vhdl_ls.toml] } {
    file delete -force ${::fwfwk::ProjectPath}/vhdl_ls.toml
  }
}

# ==============================================================================
proc createProject {} {

  # set to include all OSVVM libs
  if {[info exists ::fwfwk::OsvvmPath] } {
    set ::fwfwk::lib::osvvm::IncludeModule {osvvm Common DpRam UART Axi4 Axi4Lite Axi4Stream}
  }

}

# ==============================================================================
proc closeProject {} {}

# ==============================================================================
proc saveProject {} {
  variable SourcesArray
  set rustTomlFile [open ${::fwfwk::ProjectPath}/vhdl_ls.toml w]
  
  puts $rustTomlFile "\[libraries\]"

  addToolLibraries

  foreach { lib sourcess } [ array get SourcesArray ] {
    puts $rustTomlFile "${lib}.files = \["

    foreach src $sourcess {
      puts $rustTomlFile "\'$src\',"
    }
    puts $rustTomlFile "\]"
  }
  close $rustTomlFile
  puts "-- created vhdl_ls.toml file in project root"
}

# ==============================================================================
# add tool libraries based on availability in the environment paths
proc addToolLibraries {} {
  variable SourcesArray
  set path ''

  # Xilinx ISE
  if { [info exists ::env(XILINX)] } {
    set path "$::env(XILINX)/vhdl/src"
    if { [file exists $path]} {
      lappend SourcesArray(unisim) $path/unisims/unisim_VCOMP.vhd
      lappend SourcesArray(unisim) $path/unisims/unisim_VPKG.vhd
      lappend SourcesArray(unimacro) $path/unimacro/unimacro_VCOMP.vhd
    }
  }

  # Xilinx Vivado
  if { [info exists ::env(XILINX_VIVADO)] } {
    set path "$::env(XILINX_VIVADO)/data/vhdl/src"
    if { [file exists $path]} {
      lappend SourcesArray(unisim) $path/unisims/unisim_VCOMP.vhd
      lappend SourcesArray(unisim) $path/unisims/unisim_VPKG.vhd
      lappend SourcesArray(unimacro) $path/unimacro/unimacro_VCOMP.vhd
    }
  }


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
      if { $srcLib != ""} {   # use file library
        lappend SourcesArray($srcLib) $srcFile
      } elseif { $library != ""} { # -lib if no file provided
        lappend SourcesArray($library) $srcFile
      } else { # use default tool library
        lappend SourcesArray($defLibrary) $srcFile
      }
    }
  }

}

# ==============================================================================
# dummy
proc addGenIPs { args sources} {}
