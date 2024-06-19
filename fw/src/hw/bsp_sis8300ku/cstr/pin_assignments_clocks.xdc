# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# -- Copyright (c) 2021 DESY
# -------------------------------------------------------------------------------
# --! @file   pin_assignments_clocks.vhd
# --! @brief  Pin Assignments for the clocks
# --! @author Cagil Gumus
# --! @created 2021-01-13
# -------------------------------------------------------------------------------
# --! @description:
# -------------------------------------------------------------------------------

# System Clocks
set_property PACKAGE_PIN AJ18 [get_ports pi_125_clk_p]
set_property PACKAGE_PIN AK18 [get_ports pi_125_clk_n]

#-----------------------------------------------------------------
# Clock Multiplexer
set_property PACKAGE_PIN AK12 [get_ports {po_mux_a_sel[0]}]
set_property PACKAGE_PIN AL13 [get_ports {po_mux_a_sel[1]}]
set_property PACKAGE_PIN AM12 [get_ports {po_mux_b_sel[0]}]
set_property PACKAGE_PIN AL12 [get_ports {po_mux_b_sel[1]}]
set_property PACKAGE_PIN AH11 [get_ports {po_mux_c_sel[0]}]
set_property PACKAGE_PIN AH13 [get_ports {po_mux_c_sel[1]}]
set_property PACKAGE_PIN AJ13 [get_ports {po_mux_d_sel[0]}]
set_property PACKAGE_PIN AK13 [get_ports {po_mux_d_sel[1]}]
set_property PACKAGE_PIN AD11 [get_ports {po_mux_e_sel[0]}]
set_property PACKAGE_PIN AE13 [get_ports {po_mux_e_sel[1]}]
set_property PACKAGE_PIN AF13 [get_ports {po_mux_dac_sel[0]}]
set_property PACKAGE_PIN AE12 [get_ports {po_mux_dac_sel[1]}]

#-----------------------------------------------------------------
# clock divider (SPI interface)
set_property PACKAGE_PIN AN11 [get_ports po_ad9510_sclk]
set_property PACKAGE_PIN AP13 [get_ports pio_ad9510_sdio]
set_property PACKAGE_PIN AL8 [get_ports {po_ad9510_cs_b[0]}]
set_property PACKAGE_PIN AJ8 [get_ports {po_ad9510_cs_b[1]}]
set_property PACKAGE_PIN AN12 [get_ports po_ad9510_function]


# not used in our design
#  set_property PACKAGE_PIN AN13 [get_ports CLK_DIV_SPI_DO]
#  set_property IOSTANDARD LVCMOS25 [get_ports CLK_DIV_SPI_DO]
#  set_property PACKAGE_PIN C29 [get_ports {P_I_DIV_STATUS[0]}]
#  set_property PACKAGE_PIN H22 [get_ports {P_I_DIV_STATUS[1]}]
#  set_property IOSTANDARD LVCMOS18 [get_ports {P_I_DIV_STATUS[0]}]
#  set_property IOSTANDARD LVCMOS18 [get_ports {P_I_DIV_STATUS[1]}]

#-----------------------------------------------------------------
# ADC clock
set_property PACKAGE_PIN W25 [get_ports pi_ad9510_0_clk05_p]
set_property PACKAGE_PIN Y25 [get_ports pi_ad9510_0_clk05_n]

set_property PACKAGE_PIN W23 [get_ports pi_ad9510_1_clk69_p]
set_property PACKAGE_PIN W24 [get_ports pi_ad9510_1_clk69_n]

set_property PACKAGE_PIN AD30 [get_ports pi_dac_clk_fb_p]
set_property PACKAGE_PIN AD31 [get_ports pi_dac_clk_fb_n]

set_property IOSTANDARD DIFF_SSTL12 [get_ports pi_125_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports pi_125_clk_n]

set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_e_sel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_e_sel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_a_sel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_a_sel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_b_sel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_b_sel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_c_sel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_c_sel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_d_sel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_d_sel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_dac_sel[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mux_dac_sel[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports po_ad9510_sclk]
set_property IOSTANDARD LVCMOS25 [get_ports pio_ad9510_sdio]
set_property IOSTANDARD LVCMOS25 [get_ports {po_ad9510_cs_b[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_ad9510_cs_b[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports po_ad9510_function]
set_property IOSTANDARD LVDS [get_ports pi_ad9510_0_clk05_p]
set_property IOSTANDARD LVDS [get_ports pi_ad9510_1_clk69_p]
set_property IOSTANDARD LVDS [get_ports pi_dac_clk_fb_p]
set_property DIFF_TERM_ADV TERM_100 [get_ports pi_ad9510_0_clk05_p]
set_property DIFF_TERM_ADV TERM_100 [get_ports pi_ad9510_1_clk69_p]

