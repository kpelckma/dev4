# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# $Header$
# -------------------------------------------------------------------------------
#! @file   sis8300ku_dac_timing.xdc
#! @brief  constraint file for timing-related stuff for DACs on SIS8300 KU
#! $Date: 2015-05-30 21:01:05 +0200 (Sat, 30 May 2015) $
# -------------------------------------------------------------------------------

## collect all ports clocked on a single DCO
set DAC_PORTS [list [get_ports {po_dac_data_p[*]}] [get_ports {po_dac_data_n[*]}] [get_ports po_dac_seliq_p] [get_ports po_dac_seliq_n]]

## MAX5878 parameters
# setup is negative, the data can change after the clock edge, see:
# Maxim APP 4053: Setup and Hold Times for High-Speed Digital-to-Analog Converters (DACs) Demystified
set MAX5878_tSETUP  -1.2
set MAX5878_tHOLD   -2.0

# Output delays
set_output_delay -clock DAC_CLK -max $MAX5878_tSETUP -add_delay [get_ports $DAC_PORTS]
set_output_delay -clock DAC_CLK -min $MAX5878_tHOLD  -add_delay [get_ports $DAC_PORTS]

# Exceptions

## ODDR is used to send SDR signals
# These constraints are not working for some reason.
#set_false_path -fall_from [get_clocks -of_objects [get_pins ins_bsp/blk_clock.ins_mmcm_app/INST_MMCM_ADV/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == CLK_DIV0_CLK05}] -rise_to [get_clocks DAC_CLK]
#set_false_path -rise_from [get_clocks -of_objects [get_pins ins_bsp/blk_clock.ins_mmcm_app/INST_MMCM_ADV/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == CLK_DIV0_CLK05}] -fall_to [get_clocks DAC_CLK]

set_false_path -to [get_pins ins_sis8300ku_bsp_logic_top/blk_dac.ins_dac/reset_200_q_reg/D]

## clock crossing with synchronizers into DAC_CLK domain
set_false_path -to [get_pins ins_sis8300ku_bsp_logic_top/blk_dac.ins_dac/idelay_str_q_reg/D]
set_false_path -to [get_pins ins_sis8300ku_bsp_logic_top/blk_dac.ins_dac/idelay_str_q_reg/D]

## clock crossing for IDELAY counters (relatively static signal, through syncrhonizer)
set_false_path -to [get_pins {ins_sis8300ku_bsp_logic_top/blk_dac.ins_dac/idelay_inc_q_reg/D}]
