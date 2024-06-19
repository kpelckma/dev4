# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# -- $Header: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/modules/MISC/DAQ/tb/vivado/tb_daq_top_vivado_do.tcl 4300 2020-12-07 17:04:04Z lbutkows $
# -------------------------------------------------------------------------------
# --! @file    tb_axi4_buf_sch_vivado_do.tcl
# --! @brief   Vivado tcl script to run testbench simulation
# --! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --! @company DESY
# --! @created 2019-03-13
# --! @changed $Date: 2020-12-07 18:04:04 +0100 (Mo, 07 Dez 2020) $
# --! $Revision: 4300 $
# -------------------------------------------------------------------------------
# -- Copyright (c) 2019 DESY
# -------------------------------------------------------------------------------

## ------------------------------------------------------------------------------
## compile
## ------------------------------------------------------------------------------

set fwPath [file normalize "../../../../../"]
source ../../tcl/module.tcl

# create empty list
set designLibrary {}
set testLibrary {}

# fill lists
# add only for simulation additional files to be compiled before design

set designLibrary [concat $designLibrary $module_misc_daq_src_hdl    ]
set testLibrary   [concat $testLibrary $module_misc_daq_src_tb    ]


set topLevel daq_top_tb

# VIVADO project and start simulation
if {[catch {current_project} result ]} {
  create_project [string tolower $topLevel] -force
} else {
  puts "$result is already open"
}

add_files $designLibrary
add_files $testLibrary

set_property top $topLevel [get_filesets sim_1]
set_property -name xelab.more_options -value {-debug all} -objects [get_filesets sim_1]
set_property runtime {0} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral

add_wave /$topLevel/*

