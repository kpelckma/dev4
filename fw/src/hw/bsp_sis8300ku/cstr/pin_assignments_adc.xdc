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
#! @file   sis8300ku_adc.xdc
#! @brief  constraint file for ADCs on SIS8300 KU
#! $Date: 2015-05-30 21:01:05 +0200 (Sat, 30 May 2015) $
# -------------------------------------------------------------------------------
# SPI interface on ADCs
set_property PACKAGE_PIN V23 [get_ports {po_adc_cs_b[0]}]
set_property PACKAGE_PIN V22 [get_ports {po_adc_cs_b[1]}]
set_property PACKAGE_PIN W21 [get_ports {po_adc_cs_b[2]}]
set_property PACKAGE_PIN V21 [get_ports {po_adc_cs_b[3]}]
set_property PACKAGE_PIN AC26 [get_ports {po_adc_cs_b[4]}]
set_property PACKAGE_PIN AB24 [get_ports pio_adc_sdio]
set_property PACKAGE_PIN AC24 [get_ports po_adc_sclk]

# ADC output enable and power-down
set_property PACKAGE_PIN AC23 [get_ports po_adc_oe_n]
set_property PACKAGE_PIN Y21 [get_ports po_adc_pdwn]

# ADC clock outputs
set_property PACKAGE_PIN Y23 [get_ports {pi_adc_dco_p[0]}]
set_property PACKAGE_PIN AA23 [get_ports {pi_adc_dco_n[0]}]
set_property PACKAGE_PIN M25 [get_ports {pi_adc_dco_p[1]}]
set_property PACKAGE_PIN M26 [get_ports {pi_adc_dco_n[1]}]
set_property PACKAGE_PIN E22 [get_ports {pi_adc_dco_p[2]}]
set_property PACKAGE_PIN E23 [get_ports {pi_adc_dco_n[2]}]
set_property PACKAGE_PIN F18 [get_ports {pi_adc_dco_p[3]}]
set_property PACKAGE_PIN F17 [get_ports {pi_adc_dco_n[3]}]
set_property PACKAGE_PIN H12 [get_ports {pi_adc_dco_p[4]}]
set_property PACKAGE_PIN G12 [get_ports {pi_adc_dco_n[4]}]

# ADC over-range
set_property PACKAGE_PIN AA24 [get_ports {pi_adc_or_p[0]}]
set_property PACKAGE_PIN AA25 [get_ports {pi_adc_or_n[0]}]
set_property PACKAGE_PIN N24 [get_ports {pi_adc_or_p[1]}]
set_property PACKAGE_PIN M24 [get_ports {pi_adc_or_n[1]}]
set_property PACKAGE_PIN E25 [get_ports {pi_adc_or_p[2]}]
set_property PACKAGE_PIN D25 [get_ports {pi_adc_or_n[2]}]
set_property PACKAGE_PIN G17 [get_ports {pi_adc_or_p[3]}]
set_property PACKAGE_PIN G16 [get_ports {pi_adc_or_n[3]}]
set_property PACKAGE_PIN E16 [get_ports {pi_adc_or_p[4]}]
set_property PACKAGE_PIN D16 [get_ports {pi_adc_or_n[4]}]

# ADC data
set_property PACKAGE_PIN L22 [get_ports {pi_adc_data_p[0][0]}]
set_property PACKAGE_PIN K23 [get_ports {pi_adc_data_n[0][0]}]
set_property PACKAGE_PIN P24 [get_ports {pi_adc_data_p[0][1]}]
set_property PACKAGE_PIN P25 [get_ports {pi_adc_data_n[0][1]}]
set_property PACKAGE_PIN J24 [get_ports {pi_adc_data_p[0][2]}]
set_property PACKAGE_PIN J25 [get_ports {pi_adc_data_n[0][2]}]
set_property PACKAGE_PIN G25 [get_ports {pi_adc_data_p[0][3]}]
set_property PACKAGE_PIN G26 [get_ports {pi_adc_data_n[0][3]}]
set_property PACKAGE_PIN L25 [get_ports {pi_adc_data_p[0][4]}]
set_property PACKAGE_PIN K25 [get_ports {pi_adc_data_n[0][4]}]
set_property PACKAGE_PIN T24 [get_ports {pi_adc_data_p[0][5]}]
set_property PACKAGE_PIN T25 [get_ports {pi_adc_data_n[0][5]}]
set_property PACKAGE_PIN P26 [get_ports {pi_adc_data_p[0][6]}]
set_property PACKAGE_PIN N26 [get_ports {pi_adc_data_n[0][6]}]
set_property PACKAGE_PIN L23 [get_ports {pi_adc_data_p[0][7]}]
set_property PACKAGE_PIN L24 [get_ports {pi_adc_data_n[0][7]}]
set_property PACKAGE_PIN T27 [get_ports {pi_adc_data_p[0][8]}]
set_property PACKAGE_PIN R27 [get_ports {pi_adc_data_n[0][8]}]
set_property PACKAGE_PIN M27 [get_ports {pi_adc_data_p[0][9]}]
set_property PACKAGE_PIN L27 [get_ports {pi_adc_data_n[0][9]}]
set_property PACKAGE_PIN R25 [get_ports {pi_adc_data_p[0][10]}]
set_property PACKAGE_PIN R26 [get_ports {pi_adc_data_n[0][10]}]
set_property PACKAGE_PIN U24 [get_ports {pi_adc_data_p[0][11]}]
set_property PACKAGE_PIN U25 [get_ports {pi_adc_data_n[0][11]}]
set_property PACKAGE_PIN AB25 [get_ports {pi_adc_data_p[0][12]}]
set_property PACKAGE_PIN AB26 [get_ports {pi_adc_data_n[0][12]}]
set_property PACKAGE_PIN U21 [get_ports {pi_adc_data_p[0][13]}]
set_property PACKAGE_PIN U22 [get_ports {pi_adc_data_n[0][13]}]
set_property PACKAGE_PIN T22 [get_ports {pi_adc_data_p[0][14]}]
set_property PACKAGE_PIN T23 [get_ports {pi_adc_data_n[0][14]}]
set_property PACKAGE_PIN V26 [get_ports {pi_adc_data_p[0][15]}]
set_property PACKAGE_PIN W26 [get_ports {pi_adc_data_n[0][15]}]
set_property PACKAGE_PIN D28 [get_ports {pi_adc_data_p[1][0]}]
set_property PACKAGE_PIN C28 [get_ports {pi_adc_data_n[1][0]}]
set_property PACKAGE_PIN B29 [get_ports {pi_adc_data_p[1][1]}]
set_property PACKAGE_PIN A29 [get_ports {pi_adc_data_n[1][1]}]
set_property PACKAGE_PIN E28 [get_ports {pi_adc_data_p[1][2]}]
set_property PACKAGE_PIN D29 [get_ports {pi_adc_data_n[1][2]}]
set_property PACKAGE_PIN A27 [get_ports {pi_adc_data_p[1][3]}]
set_property PACKAGE_PIN A28 [get_ports {pi_adc_data_n[1][3]}]
set_property PACKAGE_PIN E26 [get_ports {pi_adc_data_p[1][4]}]
set_property PACKAGE_PIN D26 [get_ports {pi_adc_data_n[1][4]}]
set_property PACKAGE_PIN R21 [get_ports {pi_adc_data_p[1][5]}]
set_property PACKAGE_PIN R22 [get_ports {pi_adc_data_n[1][5]}]
set_property PACKAGE_PIN P20 [get_ports {pi_adc_data_p[1][6]}]
set_property PACKAGE_PIN P21 [get_ports {pi_adc_data_n[1][6]}]
set_property PACKAGE_PIN M20 [get_ports {pi_adc_data_p[1][7]}]
set_property PACKAGE_PIN L20 [get_ports {pi_adc_data_n[1][7]}]
set_property PACKAGE_PIN K20 [get_ports {pi_adc_data_p[1][8]}]
set_property PACKAGE_PIN K21 [get_ports {pi_adc_data_n[1][8]}]
set_property PACKAGE_PIN N21 [get_ports {pi_adc_data_p[1][9]}]
set_property PACKAGE_PIN M21 [get_ports {pi_adc_data_n[1][9]}]
set_property PACKAGE_PIN R23 [get_ports {pi_adc_data_p[1][10]}]
set_property PACKAGE_PIN P23 [get_ports {pi_adc_data_n[1][10]}]
set_property PACKAGE_PIN H27 [get_ports {pi_adc_data_p[1][11]}]
set_property PACKAGE_PIN G27 [get_ports {pi_adc_data_n[1][11]}]
set_property PACKAGE_PIN J23 [get_ports {pi_adc_data_p[1][12]}]
set_property PACKAGE_PIN H24 [get_ports {pi_adc_data_n[1][12]}]
set_property PACKAGE_PIN J26 [get_ports {pi_adc_data_p[1][13]}]
set_property PACKAGE_PIN H26 [get_ports {pi_adc_data_n[1][13]}]
set_property PACKAGE_PIN N22 [get_ports {pi_adc_data_p[1][14]}]
set_property PACKAGE_PIN M22 [get_ports {pi_adc_data_n[1][14]}]
set_property PACKAGE_PIN K26 [get_ports {pi_adc_data_p[1][15]}]
set_property PACKAGE_PIN K27 [get_ports {pi_adc_data_n[1][15]}]
set_property PACKAGE_PIN G20 [get_ports {pi_adc_data_p[2][0]}]
set_property PACKAGE_PIN F20 [get_ports {pi_adc_data_n[2][0]}]
set_property PACKAGE_PIN B20 [get_ports {pi_adc_data_p[2][1]}]
set_property PACKAGE_PIN A20 [get_ports {pi_adc_data_n[2][1]}]
set_property PACKAGE_PIN E20 [get_ports {pi_adc_data_p[2][2]}]
set_property PACKAGE_PIN E21 [get_ports {pi_adc_data_n[2][2]}]
set_property PACKAGE_PIN D20 [get_ports {pi_adc_data_p[2][3]}]
set_property PACKAGE_PIN D21 [get_ports {pi_adc_data_n[2][3]}]
set_property PACKAGE_PIN H21 [get_ports {pi_adc_data_p[2][4]}]
set_property PACKAGE_PIN G21 [get_ports {pi_adc_data_n[2][4]}]
set_property PACKAGE_PIN G24 [get_ports {pi_adc_data_p[2][5]}]
set_property PACKAGE_PIN F25 [get_ports {pi_adc_data_n[2][5]}]
set_property PACKAGE_PIN B21 [get_ports {pi_adc_data_p[2][6]}]
set_property PACKAGE_PIN B22 [get_ports {pi_adc_data_n[2][6]}]
set_property PACKAGE_PIN C21 [get_ports {pi_adc_data_p[2][7]}]
set_property PACKAGE_PIN C22 [get_ports {pi_adc_data_n[2][7]}]
set_property PACKAGE_PIN G22 [get_ports {pi_adc_data_p[2][8]}]
set_property PACKAGE_PIN F22 [get_ports {pi_adc_data_n[2][8]}]
set_property PACKAGE_PIN D24 [get_ports {pi_adc_data_p[2][9]}]
set_property PACKAGE_PIN C24 [get_ports {pi_adc_data_n[2][9]}]
set_property PACKAGE_PIN F23 [get_ports {pi_adc_data_p[2][10]}]
set_property PACKAGE_PIN F24 [get_ports {pi_adc_data_n[2][10]}]
set_property PACKAGE_PIN B25 [get_ports {pi_adc_data_p[2][11]}]
set_property PACKAGE_PIN A25 [get_ports {pi_adc_data_n[2][11]}]
set_property PACKAGE_PIN F27 [get_ports {pi_adc_data_p[2][12]}]
set_property PACKAGE_PIN E27 [get_ports {pi_adc_data_n[2][12]}]
set_property PACKAGE_PIN B24 [get_ports {pi_adc_data_p[2][13]}]
set_property PACKAGE_PIN A24 [get_ports {pi_adc_data_n[2][13]}]
set_property PACKAGE_PIN C26 [get_ports {pi_adc_data_p[2][14]}]
set_property PACKAGE_PIN B26 [get_ports {pi_adc_data_n[2][14]}]
set_property PACKAGE_PIN C27 [get_ports {pi_adc_data_p[2][15]}]
set_property PACKAGE_PIN B27 [get_ports {pi_adc_data_n[2][15]}]
set_property PACKAGE_PIN L15 [get_ports {pi_adc_data_p[3][0]}]
set_property PACKAGE_PIN K15 [get_ports {pi_adc_data_n[3][0]}]
set_property PACKAGE_PIN L19 [get_ports {pi_adc_data_p[3][1]}]
set_property PACKAGE_PIN L18 [get_ports {pi_adc_data_n[3][1]}]
set_property PACKAGE_PIN B15 [get_ports {pi_adc_data_p[3][2]}]
set_property PACKAGE_PIN A15 [get_ports {pi_adc_data_n[3][2]}]
set_property PACKAGE_PIN E18 [get_ports {pi_adc_data_p[3][3]}]
set_property PACKAGE_PIN E17 [get_ports {pi_adc_data_n[3][3]}]
set_property PACKAGE_PIN J19 [get_ports {pi_adc_data_p[3][4]}]
set_property PACKAGE_PIN J18 [get_ports {pi_adc_data_n[3][4]}]
set_property PACKAGE_PIN J15 [get_ports {pi_adc_data_p[3][5]}]
set_property PACKAGE_PIN J14 [get_ports {pi_adc_data_n[3][5]}]
set_property PACKAGE_PIN H17 [get_ports {pi_adc_data_p[3][6]}]
set_property PACKAGE_PIN H16 [get_ports {pi_adc_data_n[3][6]}]
set_property PACKAGE_PIN G19 [get_ports {pi_adc_data_p[3][7]}]
set_property PACKAGE_PIN F19 [get_ports {pi_adc_data_n[3][7]}]
set_property PACKAGE_PIN B17 [get_ports {pi_adc_data_p[3][8]}]
set_property PACKAGE_PIN B16 [get_ports {pi_adc_data_n[3][8]}]
set_property PACKAGE_PIN D19 [get_ports {pi_adc_data_p[3][9]}]
set_property PACKAGE_PIN D18 [get_ports {pi_adc_data_n[3][9]}]
set_property PACKAGE_PIN G15 [get_ports {pi_adc_data_p[3][10]}]
set_property PACKAGE_PIN G14 [get_ports {pi_adc_data_n[3][10]}]
set_property PACKAGE_PIN K18 [get_ports {pi_adc_data_p[3][11]}]
set_property PACKAGE_PIN K17 [get_ports {pi_adc_data_n[3][11]}]
set_property PACKAGE_PIN C19 [get_ports {pi_adc_data_p[3][12]}]
set_property PACKAGE_PIN B19 [get_ports {pi_adc_data_n[3][12]}]
set_property PACKAGE_PIN C18 [get_ports {pi_adc_data_p[3][13]}]
set_property PACKAGE_PIN C17 [get_ports {pi_adc_data_n[3][13]}]
set_property PACKAGE_PIN H19 [get_ports {pi_adc_data_p[3][14]}]
set_property PACKAGE_PIN H18 [get_ports {pi_adc_data_n[3][14]}]
set_property PACKAGE_PIN A19 [get_ports {pi_adc_data_p[3][15]}]
set_property PACKAGE_PIN A18 [get_ports {pi_adc_data_n[3][15]}]
set_property PACKAGE_PIN B9 [get_ports {pi_adc_data_p[4][0]}]
set_property PACKAGE_PIN A9 [get_ports {pi_adc_data_n[4][0]}]
set_property PACKAGE_PIN E10 [get_ports {pi_adc_data_p[4][1]}]
set_property PACKAGE_PIN D10 [get_ports {pi_adc_data_n[4][1]}]
set_property PACKAGE_PIN G10 [get_ports {pi_adc_data_p[4][2]}]
set_property PACKAGE_PIN F10 [get_ports {pi_adc_data_n[4][2]}]
set_property PACKAGE_PIN K10 [get_ports {pi_adc_data_p[4][3]}]
set_property PACKAGE_PIN J10 [get_ports {pi_adc_data_n[4][3]}]
set_property PACKAGE_PIN C11 [get_ports {pi_adc_data_p[4][4]}]
set_property PACKAGE_PIN B11 [get_ports {pi_adc_data_n[4][4]}]
set_property PACKAGE_PIN E11 [get_ports {pi_adc_data_p[4][5]}]
set_property PACKAGE_PIN D11 [get_ports {pi_adc_data_n[4][5]}]
set_property PACKAGE_PIN K11 [get_ports {pi_adc_data_p[4][6]}]
set_property PACKAGE_PIN J11 [get_ports {pi_adc_data_n[4][6]}]
set_property PACKAGE_PIN A13 [get_ports {pi_adc_data_p[4][7]}]
set_property PACKAGE_PIN A12 [get_ports {pi_adc_data_n[4][7]}]
set_property PACKAGE_PIN L13 [get_ports {pi_adc_data_p[4][8]}]
set_property PACKAGE_PIN K13 [get_ports {pi_adc_data_n[4][8]}]
set_property PACKAGE_PIN L12 [get_ports {pi_adc_data_p[4][9]}]
set_property PACKAGE_PIN K12 [get_ports {pi_adc_data_n[4][9]}]
set_property PACKAGE_PIN F13 [get_ports {pi_adc_data_p[4][10]}]
set_property PACKAGE_PIN E13 [get_ports {pi_adc_data_n[4][10]}]
set_property PACKAGE_PIN D14 [get_ports {pi_adc_data_p[4][11]}]
set_property PACKAGE_PIN C14 [get_ports {pi_adc_data_n[4][11]}]
set_property PACKAGE_PIN F15 [get_ports {pi_adc_data_p[4][12]}]
set_property PACKAGE_PIN F14 [get_ports {pi_adc_data_n[4][12]}]
set_property PACKAGE_PIN E15 [get_ports {pi_adc_data_p[4][13]}]
set_property PACKAGE_PIN D15 [get_ports {pi_adc_data_n[4][13]}]
set_property PACKAGE_PIN K16 [get_ports {pi_adc_data_p[4][14]}]
set_property PACKAGE_PIN J16 [get_ports {pi_adc_data_n[4][14]}]
set_property PACKAGE_PIN B14 [get_ports {pi_adc_data_p[4][15]}]
set_property PACKAGE_PIN A14 [get_ports {pi_adc_data_n[4][15]}]





set_property IOSTANDARD LVCMOS18 [get_ports {po_adc_cs_b[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {po_adc_cs_b[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {po_adc_cs_b[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {po_adc_cs_b[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {po_adc_cs_b[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports pio_adc_sdio]
set_property IOSTANDARD LVCMOS18 [get_ports po_adc_sclk]
set_property IOSTANDARD LVCMOS18 [get_ports po_adc_pdwn]
set_property IOSTANDARD LVCMOS18 [get_ports po_adc_oe_n]
set_property IOSTANDARD LVDS [get_ports {pi_adc_dco_p[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_dco_p[1]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_dco_p[2]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_dco_p[3]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_dco_p[4]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_dco_p[0]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_dco_p[1]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_dco_p[2]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_dco_p[3]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_dco_p[4]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_or_p[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_or_p[1]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_or_p[2]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_or_p[3]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_or_p[4]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_or_p[0]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_or_p[1]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_or_p[2]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_or_p[3]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_or_p[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][0]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][1]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][2]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][3]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][4]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][5]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][6]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][7]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][8]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][9]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[0][10]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[0][11]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[0][12]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[0][13]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[0][14]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[0][15]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[1][0]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[1][1]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[1][2]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[1][3]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[1][4]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][5]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][6]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][7]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][8]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][9]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][10]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][11]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][12]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][13]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][14]}]
set_property IOSTANDARD LVDS_25 [get_ports {pi_adc_data_p[1][15]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][0]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][1]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][2]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][3]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][4]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][5]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][6]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][7]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][8]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][9]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][10]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][11]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][12]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][13]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][14]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[2][15]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][0]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][1]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][2]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][3]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][4]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][5]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][6]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][7]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][8]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][9]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][10]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][11]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][12]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][13]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][14]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[3][15]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][0]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][1]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][2]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][3]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][4]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][5]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][6]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][7]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][8]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][9]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][10]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][11]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][12]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][13]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][14]}]
set_property IOSTANDARD LVDS [get_ports {pi_adc_data_p[4][15]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][0]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][1]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][2]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][3]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][4]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][5]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][6]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][7]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][8]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][9]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][10]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][11]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][12]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][13]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][14]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[0][15]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][0]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][1]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][2]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][3]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][4]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][5]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][6]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][7]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][8]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][9]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][10]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][11]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][12]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][13]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][14]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[1][15]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][0]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][1]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][2]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][3]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][4]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][5]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][6]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][7]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][8]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][9]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][10]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][11]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][12]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][13]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][14]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[2][15]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][0]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][1]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][2]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][3]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][4]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][5]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][6]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][7]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][8]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][9]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][10]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][11]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][12]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][13]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][14]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[3][15]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][0]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][1]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][2]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][3]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][4]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][5]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][6]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][7]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][8]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][9]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][10]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][11]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][12]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][13]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][14]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_adc_data_p[4][15]}]

