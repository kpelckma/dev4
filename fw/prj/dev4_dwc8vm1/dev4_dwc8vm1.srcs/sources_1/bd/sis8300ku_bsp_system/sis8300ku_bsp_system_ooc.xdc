################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name pi_m_axi4l_app_aclk -period 8 [get_ports pi_m_axi4l_app_aclk]
create_clock -name pi_pcie_sys_clk -period 10 [get_ports pi_pcie_sys_clk]
create_clock -name pi_pcie_sys_clk_gt -period 10 [get_ports pi_pcie_sys_clk_gt]
create_clock -name pi_ddr4_sys_clk -period 8 [get_ports pi_ddr4_sys_clk]

################################################################################