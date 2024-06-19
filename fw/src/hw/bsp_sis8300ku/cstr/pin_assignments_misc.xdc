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
#! @file   sis8300ku_misc.xdc
#! @brief  constraint miscellaneous components on SIS8300 KU
#! $Date: 2015-05-30 21:01:05 +0200 (Sat, 30 May 2015) $
# -------------------------------------------------------------------------------

# LED serial data
set_property PACKAGE_PIN AM11 [get_ports po_led_serial_data]

###################################################
##	MLVDS Bus (Buffer - single ended - FPGA)
###################################################
# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AE11 [get_ports {po_mlvds[0]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AF12 [get_ports {po_mlvds[1]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AF8 [get_ports {po_mlvds[2]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AH12 [get_ports {po_mlvds[3]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AG12 [get_ports {po_mlvds[4]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AJ9 [get_ports {po_mlvds[5]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AH9 [get_ports {po_mlvds[6]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AK8 [get_ports {po_mlvds[7]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AJ11 [get_ports {pi_mlvds[0]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AK10 [get_ports {pi_mlvds[1]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AK11 [get_ports {pi_mlvds[2]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AL10 [get_ports {pi_mlvds[3]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AL9 [get_ports {pi_mlvds[4]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AM10 [get_ports {pi_mlvds[5]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AM9 [get_ports {pi_mlvds[6]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AN9 [get_ports {pi_mlvds[7]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AD9 [get_ports {po_mlvds_oe[0]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AD10 [get_ports {po_mlvds_oe[1]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AE8 [get_ports {po_mlvds_oe[2]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AD8 [get_ports {po_mlvds_oe[3]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AJ10 [get_ports {po_mlvds_oe[4]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AH8 [get_ports {po_mlvds_oe[5]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AN8 [get_ports {po_mlvds_oe[6]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AP8 [get_ports {po_mlvds_oe[7]}]

###################################################
##		RJ45 Data Out (old Harlink)
###################################################
# Bank 47 voltage = 1.8V

# Bank 47 voltage = 1.8V
set_property PACKAGE_PIN W28 [get_ports {po_fp_data_p[0]}]
set_property PACKAGE_PIN Y28 [get_ports {po_fp_data_n[0]}]

# Bank 47  voltage = 1.8V

# Bank 47 voltage = 1.8V
set_property PACKAGE_PIN AD25 [get_ports {po_fp_data_p[1]}]
set_property PACKAGE_PIN AD26 [get_ports {po_fp_data_n[1]}]

# Bank 47 voltage = 1.8V

# Bank 47 voltage = 1.8V
set_property PACKAGE_PIN U26 [get_ports {po_fp_data_p[2]}]
set_property PACKAGE_PIN U27 [get_ports {po_fp_data_n[2]}]

###################################################
##		Misc Ports
###################################################

# Bank 47 voltage = 1.8V
# Bank 48 voltage = 1.8V

set_property PACKAGE_PIN V29 [get_ports {pi_fp_data_p[0]}]
set_property PACKAGE_PIN W29 [get_ports {pi_fp_data_n[0]}]

set_property PACKAGE_PIN AA27 [get_ports {pi_fp_data_p[1]}]
set_property PACKAGE_PIN AB27 [get_ports {pi_fp_data_n[1]}]

set_property PACKAGE_PIN V27 [get_ports {pi_fp_data_p[2]}]
set_property PACKAGE_PIN V28 [get_ports {pi_fp_data_n[2]}]

#
# addon: RJ45 in not working?
#
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_fp_data_p[0]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_fp_data_n[0]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_fp_data_p[1]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_fp_data_n[1]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_fp_data_p[2]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {pi_fp_data_n[2]}]
#
#
#

set_property IOSTANDARD LVCMOS25 [get_ports po_led_serial_data]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pi_mlvds[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pi_mlvds[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pi_mlvds[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pi_mlvds[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pi_mlvds[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pi_mlvds[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pi_mlvds[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pi_mlvds[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds_oe[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds_oe[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds_oe[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds_oe[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds_oe[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds_oe[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds_oe[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_mlvds_oe[7]}]
set_property IOSTANDARD LVDS [get_ports {po_fp_data_n[0]}]
set_property IOSTANDARD LVDS [get_ports {po_fp_data_p[0]}]
set_property IOSTANDARD LVDS [get_ports {po_fp_data_n[1]}]
set_property IOSTANDARD LVDS [get_ports {po_fp_data_p[1]}]
set_property IOSTANDARD LVDS [get_ports {po_fp_data_n[2]}]
set_property IOSTANDARD LVDS [get_ports {po_fp_data_p[2]}]
set_property IOSTANDARD LVDS [get_ports {pi_fp_data_n[0]}]
set_property IOSTANDARD LVDS [get_ports {pi_fp_data_p[0]}]
set_property IOSTANDARD LVDS [get_ports {pi_fp_data_n[1]}]
set_property IOSTANDARD LVDS [get_ports {pi_fp_data_p[1]}]
set_property IOSTANDARD LVDS [get_ports {pi_fp_data_n[2]}]
set_property IOSTANDARD LVDS [get_ports {pi_fp_data_p[2]}]


