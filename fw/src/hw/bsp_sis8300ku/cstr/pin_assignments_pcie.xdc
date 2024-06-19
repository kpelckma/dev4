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
# --! @file   sis8300ku_pcie.xdc
# --! @brief  PCIe Constraints
# --! @author Cagil Gumus
# --! @created 2021-01-13
# -------------------------------------------------------------------------------
# --! @description: Pin assignments for PCIe
# -------------------------------------------------------------------------------

#-----------------------------------------------------------------
# Pins Assignments

# PCIe Reset
# Bank 65 voltage = 2.5V
set_property PACKAGE_PIN N23 [get_ports pi_pcie_rst_n]

set_property PACKAGE_PIN P5 [get_ports pi_pcie_clk_n]
set_property PACKAGE_PIN P6 [get_ports pi_pcie_clk_p]

set_property IOSTANDARD LVCMOS25 [get_ports pi_pcie_rst_n]
set_property PULLUP true [get_ports pi_pcie_rst_n]


