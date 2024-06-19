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
# Wrapper for OSVVM library
# --------------------------------------------------------------------------- #

proc init {} {
  # variable IncludeModule {osvvm Common DpRam UART Axi4 Axi4Lite Axi4Stream}
  variable IncludeModule {}

  variable VerString
  variable Path

  set Path $::fwfwk::OsvvmPath

  ::fwfwk::getVersion [namespace current]
  ::fwfwk::printInfo $VerString
}

proc setSources {} {

  variable Sources
  variable IncludeModule

  set Sources {}

  if {[lsearch $IncludeModule "osvvm"] >= 0}   {
    set path "$::fwfwk::OsvvmPath/osvvm/"
    set VHDLSrcs [glob -nocomplain -directory $path *.vhd]
    foreach src $VHDLSrcs {
      lappend Sources [list $src "VHDL 2008" "osvvm"]
    }
  }
  if {[lsearch $IncludeModule "Common"] >= 0}   {
    set path "$::fwfwk::OsvvmPath/Common/src/"
    set VHDLSrcs [glob -nocomplain -directory $path *.vhd]
    foreach src $VHDLSrcs {
      lappend Sources [list $src "VHDL 2008" "osvvm_common"]
    }
  }
  if {[lsearch $IncludeModule "DpRam"] >= 0}   {
    set path "$::fwfwk::OsvvmPath/DpRam/src/"
    set VHDLSrcs [glob -nocomplain -directory $path *.vhd]
    foreach src $VHDLSrcs {
      lappend Sources [list $src "VHDL 2008" "osvvm_dpram"]
    }
  }

  if {[lsearch $IncludeModule "UART"]  >= 0}   {
    set path "$::fwfwk::OsvvmPath/UART/src/"
    set VHDLSrcs [glob -nocomplain -directory $path *.vhd]
    foreach src $VHDLSrcs {
      lappend Sources [list $src "VHDL 2008" "osvvm_uart"]
    }
  }

  if {[lsearch $IncludeModule "Axi4*"]  >= 0}   {
    set path "$::fwfwk::OsvvmPath/AXI4/common/src"
    set VHDLSrcs [glob -nocomplain -directory $path *.vhd]
    foreach src $VHDLSrcs {
      lappend Sources [list $src "VHDL 2008" "osvvm_axi4"]
    }
  }

  if {[lsearch -exact $IncludeModule "Axi4"]  >= 0}   {
    set path "$::fwfwk::OsvvmPath/AXI4/Axi4/src"
    set VHDLSrcs [glob -nocomplain -directory $path *.vhd]
    foreach src $VHDLSrcs {
      lappend Sources [list $src "VHDL 2008" "osvvm_axi4"]
    }
  }
  if {[lsearch -exact $IncludeModule "Axi4Lite"]  >= 0}   {
    set path "$::fwfwk::OsvvmPath/AXI4/Axi4Lite/src"
    set VHDLSrcs [glob -nocomplain -directory $path *.vhd]
    foreach src $VHDLSrcs {
      lappend Sources [list $src "VHDL 2008" "osvvm_axi4"]
    }
  }
  if {[lsearch -exact $IncludeModule "Axi4Stream"]  >= 0}   {
    set path "$::fwfwk::OsvvmPath/AXI4/Axi4Stream/src"
    set VHDLSrcs [glob -nocomplain -directory $path *.vhd]
    foreach src $VHDLSrcs {
      lappend Sources [list $src "VHDL 2008" "osvvm_axi4"]
    }
  }

}


proc doOnCreate {} {

  variable Sources

  addSources "Sources"
}
