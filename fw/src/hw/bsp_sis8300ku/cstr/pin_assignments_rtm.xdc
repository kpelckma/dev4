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
#! @file   sis8300ku_rtm.xdc
#! @brief  constraint file for LOCs and similar on SIS8300 KU
#! $Date$
# -------------------------------------------------------------------------------

###################################################
##		RTM
###################################################
# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AP11 [get_ports po_rtm_interlock_ena_n]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AP9 [get_ports {po_rtm_interlock[0]}]

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AP10 [get_ports {po_rtm_interlock[1]}]

###################################################
## Start RTM 8900 Data - IO-Standards
set_property PACKAGE_PIN B10 [get_ports {pio_rtm_io_p[0]}]
set_property PACKAGE_PIN A10 [get_ports {pio_rtm_io_n[0]}]
set_property PACKAGE_PIN G9 [get_ports {pio_rtm_io_p[1]}]
set_property PACKAGE_PIN F9 [get_ports {pio_rtm_io_n[1]}]
set_property PACKAGE_PIN D8 [get_ports {pio_rtm_io_p[2]}]
set_property PACKAGE_PIN C8 [get_ports {pio_rtm_io_n[2]}]
set_property PACKAGE_PIN L8 [get_ports {pio_rtm_io_p[3]}]
set_property PACKAGE_PIN K8 [get_ports {pio_rtm_io_n[3]}]
set_property PACKAGE_PIN C12 [get_ports {pio_rtm_io_p[4]}]
set_property PACKAGE_PIN B12 [get_ports {pio_rtm_io_n[4]}]
set_property PACKAGE_PIN H11 [get_ports {pio_rtm_io_p[5]}]
set_property PACKAGE_PIN G11 [get_ports {pio_rtm_io_n[5]}]
set_property PACKAGE_PIN D13 [get_ports {pio_rtm_io_p[6]}]
set_property PACKAGE_PIN C13 [get_ports {pio_rtm_io_n[6]}]
set_property PACKAGE_PIN J13 [get_ports {pio_rtm_io_p[7]}]
set_property PACKAGE_PIN H13 [get_ports {pio_rtm_io_n[7]}]
set_property PACKAGE_PIN J9 [get_ports {pio_rtm_io_p[8]}]
set_property PACKAGE_PIN H9 [get_ports {pio_rtm_io_n[8]}]
set_property PACKAGE_PIN J8 [get_ports {pio_rtm_io_p[9]}]
set_property PACKAGE_PIN H8 [get_ports {pio_rtm_io_n[9]}]
set_property PACKAGE_PIN F8 [get_ports {pio_rtm_io_p[10]}]
set_property PACKAGE_PIN E8 [get_ports {pio_rtm_io_n[10]}]
set_property PACKAGE_PIN D9 [get_ports {pio_rtm_io_p[11]}]
set_property PACKAGE_PIN C9 [get_ports {pio_rtm_io_n[11]}]

set_property IOSTANDARD LVCMOS25 [get_ports po_rtm_interlock_ena_n]
set_property IOSTANDARD LVCMOS25 [get_ports {po_rtm_interlock[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {po_rtm_interlock[1]}]


