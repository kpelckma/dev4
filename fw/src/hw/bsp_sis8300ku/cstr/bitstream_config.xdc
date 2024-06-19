# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# -- $Header: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/tools/%23prj-scripts/main.tcl 1953 2017-03-27 14:52:27Z binyang $
# -------------------------------------------------------------------------------
# @file   sis8300ku_config.xdc
# @brief  Device Properties of FPGA on SIS8300KU board
# @author Lukasz Butkowski
# $Date: 2017-03-27 10:52:27 -0400 (Mon, 27 Mar 2017) $
# $Revision: 1953 $
# $URL: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/tools/%23prj-scripts/main.tcl $
# -------------------------------------------------------------------------------

# SPI Flash Programming
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]


