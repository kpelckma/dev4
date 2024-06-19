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
#! @file   sis8300ku_dac.xdc
#! @brief  constraint file for DACs on SIS8300 KU
#! $Date: 2015-05-30 21:01:05 +0200 (Sat, 30 May 2015) $
# -------------------------------------------------------------------------------

# data pins
set_property PACKAGE_PIN AC34 [get_ports {po_dac_data_p[0]}]
set_property PACKAGE_PIN AD34 [get_ports {po_dac_data_n[0]}]
set_property PACKAGE_PIN AE33 [get_ports {po_dac_data_p[1]}]
set_property PACKAGE_PIN AF34 [get_ports {po_dac_data_n[1]}]
set_property PACKAGE_PIN AA34 [get_ports {po_dac_data_p[2]}]
set_property PACKAGE_PIN AB34 [get_ports {po_dac_data_n[2]}]
set_property PACKAGE_PIN AE28 [get_ports {po_dac_data_p[3]}]
set_property PACKAGE_PIN AF28 [get_ports {po_dac_data_n[3]}]
set_property PACKAGE_PIN AE32 [get_ports {po_dac_data_p[4]}]
set_property PACKAGE_PIN AF32 [get_ports {po_dac_data_n[4]}]
set_property PACKAGE_PIN AC33 [get_ports {po_dac_data_p[5]}]
set_property PACKAGE_PIN AD33 [get_ports {po_dac_data_n[5]}]
set_property PACKAGE_PIN AB30 [get_ports {po_dac_data_p[6]}]
set_property PACKAGE_PIN AB31 [get_ports {po_dac_data_n[6]}]
set_property PACKAGE_PIN Y31 [get_ports {po_dac_data_p[7]}]
set_property PACKAGE_PIN Y32 [get_ports {po_dac_data_n[7]}]
set_property PACKAGE_PIN AA32 [get_ports {po_dac_data_p[8]}]
set_property PACKAGE_PIN AB32 [get_ports {po_dac_data_n[8]}]
set_property PACKAGE_PIN V33 [get_ports {po_dac_data_p[9]}]
set_property PACKAGE_PIN W34 [get_ports {po_dac_data_n[9]}]
set_property PACKAGE_PIN W33 [get_ports {po_dac_data_p[10]}]
set_property PACKAGE_PIN Y33 [get_ports {po_dac_data_n[10]}]
set_property PACKAGE_PIN AC31 [get_ports {po_dac_data_p[11]}]
set_property PACKAGE_PIN AC32 [get_ports {po_dac_data_n[11]}]
set_property PACKAGE_PIN U34 [get_ports {po_dac_data_p[12]}]
set_property PACKAGE_PIN V34 [get_ports {po_dac_data_n[12]}]
set_property PACKAGE_PIN AA29 [get_ports {po_dac_data_p[13]}]
set_property PACKAGE_PIN AB29 [get_ports {po_dac_data_n[13]}]
set_property PACKAGE_PIN AD29 [get_ports {po_dac_data_p[14]}]
set_property PACKAGE_PIN AE30 [get_ports {po_dac_data_n[14]}]
set_property PACKAGE_PIN V31 [get_ports {po_dac_data_p[15]}]
set_property PACKAGE_PIN W31 [get_ports {po_dac_data_n[15]}]

# sel I/Q pins
set_property PACKAGE_PIN W30 [get_ports po_dac_seliq_p]

# clock to DAQ mux
set_property PACKAGE_PIN AC28 [get_ports po_dac_clk_p]
set_property PACKAGE_PIN AD28 [get_ports po_dac_clk_n]

# power down
set_property PACKAGE_PIN AG29 [get_ports po_dac_pd]

# output mode selector
set_property PACKAGE_PIN AF29 [get_ports po_dac_torb]

set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[0]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[0]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[1]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[1]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[2]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[2]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[3]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[3]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[4]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[4]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[5]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[5]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[6]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[6]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[7]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[7]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[8]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[8]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[9]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[9]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[10]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[10]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[11]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[11]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[12]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[12]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[13]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[13]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[14]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[14]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_p[15]}]
set_property IOSTANDARD LVDS [get_ports {po_dac_data_n[15]}]
set_property IOSTANDARD LVDS [get_ports po_dac_seliq_p]
set_property IOSTANDARD LVDS [get_ports po_dac_seliq_n]
set_property IOSTANDARD LVDS [get_ports po_dac_clk_p]
set_property IOSTANDARD LVDS [get_ports po_dac_clk_n]
set_property IOSTANDARD LVCMOS18 [get_ports po_dac_pd]
set_property IOSTANDARD LVCMOS18 [get_ports po_dac_torb]

