# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# -- $Header: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/branch/DAQ_timestamps/modules/MISC/DAQ/tb/vivado/tb_daq_to_axi_vivado_do.tcl 3109 2019-06-18 17:40:19Z dursun $
# -------------------------------------------------------------------------------
# --! @file    tb_axi4_buf_sch_vivado_do.tcl
# --! @brief   Vivado tcl script to run testbench simulation
# --! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --! @company DESY
# --! @created 2019-03-13
# --! @changed $Date: 2019-06-18 19:40:19 +0200 (Di, 18 Jun 2019) $
# --! $Revision: 3109 $
# -------------------------------------------------------------------------------
# -- Copyright (c) 2019 DESY
# -------------------------------------------------------------------------------

## ------------------------------------------------------------------------------
## compile
## ------------------------------------------------------------------------------

# create empty list
set designLibrary {}

# fill lists
lappend designLibrary ../../../../../libraries/axi/PKG_AXI.vhd
lappend designLibrary ../../../../../libraries/math/math_basic.vhd

lappend designLibrary ../../../../../libraries/mem/fifo/PKG_FIFO.vhd
lappend designLibrary ../../../../../libraries/mem/fifo/ENT_FIFO_XPM.vhd
lappend designLibrary ../../../../../libraries/mem/fifo/ENT_FIFO_DUALCLOCK_MACRO.vhd
lappend designLibrary ../../../../../libraries/mem/fifo/ENT_FIFO_VIRTEX.vhd
lappend designLibrary ../../../../../libraries/mem/fifo/ENT_FIFO_OUTPUT.vhd
lappend designLibrary ../../../../../libraries/mem/fifo/ENT_FIFO_INPUT.vhd
lappend designLibrary ../../../../../libraries/mem/fifo/ENT_FIFO_GENERIC.vhd
lappend designLibrary ../../../../../libraries/mem/fifo/ENT_FIFO_DPRAM.vhd
lappend designLibrary ../../../../../libraries/mem/fifo/ENT_FIFO.vhd

lappend designLibrary ../../hdl/daq_to_axi.vhd
lappend designLibrary ../../hdl/burst_generator.vhd
lappend designLibrary ../TB_burst_generator.vhd

set topLevel TB_burst_generator

# VIVADO project and start simulation
create_project [string tolower $topLevel] -force

add_files $designLibrary

set_property top $topLevel [get_filesets sim_1]
set_property -name xelab.more_options -value {-debug all} -objects [get_filesets sim_1]
set_property runtime {0} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
add_wave /$topLevel/*

