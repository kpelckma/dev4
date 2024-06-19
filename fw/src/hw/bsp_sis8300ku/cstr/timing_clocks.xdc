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
#! @file   timing_clocks.xdc
#! @brief  constraint file for clocks and clock related chips on SIS8300 KU
#! $Date: 2015-05-30 21:01:05 +0200 (Sat, 30 May 2015) $
# -------------------------------------------------------------------------------

# Main BSP Clock (On-board Crystal)
create_clock -period 8.000 -name 125MHZ_SYS_CLK [get_ports pi_125_clk_p]
create_clock -period 10.000 -name PCIE_REF_CLK [get_ports pi_pcie_clk_p]

# Renaming generated clocks from various IPs (For better readability/codability)
create_generated_clock -name APP_CLK        [get_pins "ins_sis8300ku_bsp_logic_top/blk_clock.ins_mmcm_app/inst_mmcm_adv/CLKOUT0"] -master_clock CLK_DIV0_CLK05
create_generated_clock -name APP_2X_CLK     [get_pins "ins_sis8300ku_bsp_logic_top/blk_clock.ins_mmcm_app/inst_mmcm_adv/CLKOUT1"] -master_clock CLK_DIV0_CLK05
create_generated_clock -name DAC_CLK -divide_by 1 -source [get_pins ins_sis8300ku_bsp_logic_top/blk_dac.ins_dac/i_oddre1_clk/OQ] [get_ports po_dac_clk_p]

# set asynchronous groups
set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks PCIE_REF_CLK]   \
    -group [get_clocks -include_generated_clocks 125MHZ_SYS_CLK] \
    -group [get_clocks -include_generated_clocks CLK_DIV0_CLK05] \
    -group {DAC_CLK}
    
    
# MMCM can produce App Clock from 2 different inputs. Here we are telling the tool to only consider the 
# input which is coming from the FPGA pin. Normal operation of the FPGA should be done using that pin.
# Basically relaxing the tool to avoid clutter on the clock reports and avoid unnecessary timing analysis.
set_case_analysis 1 [get_pins -hier inst_mmcm_adv/CLKINSEL]

# See why we add the below lines: AR# 63103
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
