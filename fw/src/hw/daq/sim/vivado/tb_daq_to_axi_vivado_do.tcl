# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# -- $Header: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/modules/MISC/DAQ/tb/vivado/tb_daq_to_axi_vivado_do.tcl 3685 2020-04-03 19:55:27Z mkoray $
# -------------------------------------------------------------------------------
# --! @file    tb_axi4_buf_sch_vivado_do.tcl
# --! @brief   Vivado tcl script to run testbench simulation
# --! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
# --! @company DESY
# --! @created 2019-03-13
# --! @changed $Date: 2020-04-03 21:55:27 +0200 (Fr, 03 Apr 2020) $
# --! $Revision: 3685 $
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
lappend designLibrary ../TB_daq_to_axi.vhd

set topLevel TB_daq_to_axi

# VIVADO project and start simulation
create_project [string tolower $topLevel] -force

add_files $designLibrary

set_property top $topLevel [get_filesets sim_1]
set_property -name xelab.more_options -value {-debug all} -objects [get_filesets sim_1]
set_property runtime {0} [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
add_wave /$topLevel/*

