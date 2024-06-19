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
# @date 2023-1-26
# @author Seyed Nima Omidsajedi  <nima.sajedi@desy.de>
# --------------------------------------------------------------------------- #
# @brief
# Part of DESY FPGA Firmware Framework (fwk)
# Supplementary Tcl script for laoding Vitis HLS tool in the firmware framework.
# --------------------------------------------------------------------------- #
#!/usr/bin/env tclsh

set cfgFile [file join $::env(PWD) cfg/$::env(cfg).cfg]
source ./fwk/src/main.tcl

# main function
set commonArgs "-c ${cfgFile} -t vitis_hls --colorterm $::env(COLORTERM) --exit"

switch $env(hls_target) {
  "vitis_hls"   {
    eval ::fwfwk::main init create $commonArgs
  }
  "vitis_hls_sim" {
    eval ::fwfwk::main init simulate $commonArgs
  }
  "vitis_hls_build" {
    eval ::fwfwk::main init build $commonArgs
  }
  "vitis_hls_synth" {
    eval ::fwfwk::main init synth $commonArgs
  }
  "vitis_hls_gui" {
    eval ::fwfwk::main init gui $commonArgs
  }
  default  {
    puts "Unrecognized command"
    return -1
  }
}
