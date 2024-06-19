
# ##############################################################################
# IP config
# ==============================================================================
set xdma_0_gen3_config \
  [list ""];               # to be set and tested
  # [list \
  #    CONFIG.mode_selection {Advanced} \
  #    CONFIG.pcie_blk_locn {X1Y1} \
  #    CONFIG.pl_link_cap_max_link_width {X4} \
  #    CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
  #    CONFIG.axi_data_width {256_bit} \
  #    CONFIG.axisten_freq {125} \
  #    CONFIG.pciebar2axibar_axil_master {0xA0000000} \
  #    CONFIG.axilite_master_en {true} \
  #    CONFIG.axilite_master_size {16} \
  #    CONFIG.pf0_msi_cap_multimsgcap {8_vectors} \
  #    CONFIG.xdma_num_usr_irq {8} \
  #    CONFIG.en_gt_selection {true} \
  #    CONFIG.select_quad {GTH_Quad_228} \
  #    CONFIG.plltype {QPLL1} \
  #    CONFIG.xdma_sts_ports {false} \
  #    CONFIG.pf0_msix_cap_table_bir {BAR_1} \
  #    CONFIG.pf0_msix_cap_pba_bir {BAR_1} \
  #    CONFIG.cfg_mgmt_if {false} \
  #    CONFIG.pf0_device_id {9034} \
  #    CONFIG.PF2_DEVICE_ID_mqdma {9034} \
  #    CONFIG.PF3_DEVICE_ID_mqdma {9034} \
  #    CONFIG.dma_reset_source_sel {Phy_Ready} \
  #    CONFIG.enable_pcie_debug {False}]

set xdma_0_gen2_config \
  [list \
   CONFIG.PF0_DEVICE_ID_mqdma {9024} \
   CONFIG.PF2_DEVICE_ID_mqdma {9024} \
   CONFIG.PF3_DEVICE_ID_mqdma {9024} \
   CONFIG.axi_data_width {128_bit} \
   CONFIG.axilite_master_en {true} \
   CONFIG.axilite_master_size {16} \
   CONFIG.axisten_freq {125} \
   CONFIG.dedicate_perst {false} \
   CONFIG.drp_clk_sel {Internal} \
   CONFIG.en_gt_selection {true} \
   CONFIG.enable_auto_rxeq {False} \
   CONFIG.enable_ibert {false} \
   CONFIG.enable_jtag_dbg {false} \
   CONFIG.mode_selection {Advanced} \
   CONFIG.pcie_blk_locn {X0Y1} \
   CONFIG.pf0_device_id {8024} \
   CONFIG.pf0_link_status_slot_clock_config {true} \
   CONFIG.pf0_msix_cap_pba_bir {BAR_1} \
   CONFIG.pf0_msix_cap_table_bir {BAR_1} \
   CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
   CONFIG.pl_link_cap_max_link_width {X4} \
   CONFIG.plltype {QPLL1} \
   CONFIG.ref_clk_freq {100_MHz} \
   CONFIG.select_quad {GTH_Quad_227} \
   CONFIG.xdma_axi_intf_mm {AXI_Memory_Mapped} \
   CONFIG.xdma_axilite_slave {false} \
   CONFIG.xdma_num_usr_irq {16} \
   CONFIG.xdma_sts_ports {false} \
  ]

# # select GEN configuration
# if { $bspPcieIrqCnt != 16 } {
# error {"Wrong Configuration. Not Supported PCIe IRQ Config $bspPcieIrqCnt 100} 
# }


# select GEN configuration
if { $bspPcieGen == 2 } {
  set xdma_0_config $xdma_0_gen2_config
} else {
  set xdma_0_config $xdma_0_gen3_config
}

set axi_interconnect_reg_config \
  [list \
     CONFIG.NUM_SI {2}  \
     CONFIG.NUM_MI {2} \
     CONFIG.NUM_CLKS {2}
     ]

set axi_interconnect_dma_config \
  [list \
     CONFIG.NUM_SI {1} \
     CONFIG.NUM_MI {2}]



# ##############################################################################
# ==============================================================================

# Create cell and set as current instance
current_bd_instance /
current_bd_instance [create_bd_cell -type hier "pcie"]

# create IPS
create_bd_cell -type ip -vln xilinx.com:ip:xdma        "xdma_0"
create_bd_cell -type ip -vln xilinx.com:ip:smartconnect "axi_interconnect_reg"
create_bd_cell -type ip -vln xilinx.com:ip:smartconnect "axi_interconnect_dma"


# configure IPS
set_property -dict $xdma_0_config        [get_bd_cells "xdma_0"]

set_property -dict $axi_interconnect_reg_config [get_bd_cells "axi_interconnect_reg"]
set_property -dict $axi_interconnect_dma_config [get_bd_cells "axi_interconnect_dma"]

# ==============================================================================
# create TOP interfaces/ports

create_bd_port -dir I -type clk -freq_hz $BspConfig(C_APP_FREQ) pi_m_axi4l_app_aclk

create_bd_port -dir I -type clk "pi_pcie_sys_clk"
create_bd_port -dir I -type clk "pi_pcie_sys_clk_gt"
create_bd_port -dir I -type rst "pi_pcie_areset_n"
set_property -dict [ list CONFIG.POLARITY {ACTIVE_LOW} ] [get_bd_ports "/pi_pcie_areset_n"]

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 "p_pcie_mgt"

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 "p_m_axi4l_bsp"
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 "p_m_axi4l_app"

create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 "m_axi_dma_ddr"

create_bd_port -dir O -type clk "po_m_axi4_aclk"
create_bd_port -dir O -type rst "po_m_axi4_areset_n"
create_bd_port -dir O po_pcie_link_up
create_bd_port -dir O -from 7 -to 0 "po_pcie_irq_ack"
create_bd_port -dir I -from 15 -to 0 -type intr pi_pcie_irq_req

set_property CONFIG.SENSITIVITY EDGE_RISING [get_bd_ports "/pi_pcie_irq_req"]


# ==============================================================================
# create TOP connections
connect_bd_intf_net [get_bd_intf_ports "/p_pcie_mgt"]     [get_bd_intf_pins "xdma_0/pcie_mgt"]
connect_bd_net      [get_bd_ports "/pi_pcie_areset_n"]    [get_bd_pins "xdma_0/sys_rst_n"]
connect_bd_net      [get_bd_ports "/po_m_axi4_aclk"]      [get_bd_pins "xdma_0/axi_aclk"]
connect_bd_net      [get_bd_ports "/po_m_axi4_areset_n"]  [get_bd_pins "xdma_0/axi_aresetn"]
connect_bd_net      [get_bd_ports "/po_pcie_irq_ack"]     [get_bd_pins "xdma_0/usr_irq_ack"]
connect_bd_net      [get_bd_ports "/po_pcie_link_up"]     [get_bd_pins "xdma_0/user_lnk_up"]
connect_bd_net      [get_bd_pins  "/pi_pcie_irq_req"]     [get_bd_pins "xdma_0/usr_irq_req"]



# create cell to cell connections
connect_bd_net [get_bd_ports "/pi_pcie_sys_clk"]      [get_bd_pins "xdma_0/sys_clk"]
connect_bd_net [get_bd_ports "/pi_pcie_sys_clk_gt"]   [get_bd_pins "xdma_0/sys_clk_gt"]
connect_bd_net [get_bd_pins  "xdma_0/axi_aclk"]       [get_bd_pins "axi_interconnect_dma/aclk"]
connect_bd_net [get_bd_pins  "xdma_0/axi_aresetn"]    [get_bd_pins "axi_interconnect_dma/aresetn"]
connect_bd_net [get_bd_pins  "xdma_0/axi_aclk"]       [get_bd_pins "axi_interconnect_reg/aclk"]
connect_bd_net [get_bd_pins  "xdma_0/axi_aresetn"]    [get_bd_pins "axi_interconnect_reg/aresetn"]

connect_bd_net [get_bd_ports /pi_m_axi4l_app_aclk]    [get_bd_pins axi_interconnect_reg/aclk1]

# Interconnects
# XDMA interconnect to registers
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_reg/S00_AXI"] [get_bd_intf_pins "xdma_0/M_AXI_LITE"]
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_reg/S01_AXI"] [get_bd_intf_pins "axi_interconnect_dma/M00_AXI"]
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_reg/M00_AXI"] [get_bd_intf_ports "/p_m_axi4l_bsp"]
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_reg/M01_AXI"] [get_bd_intf_ports "/p_m_axi4l_app"]

# XDMA interconnect to DMA
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_dma/S00_AXI"] [get_bd_intf_pins "xdma_0/M_AXI"]
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_dma/M00_AXI"] [get_bd_intf_pins "axi_interconnect_reg/S01_AXI"]
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_dma/M01_AXI"] [get_bd_intf_pins "m_axi_dma_ddr"]

# Bus Clk Association
set_property CONFIG.ASSOCIATED_BUSIF {p_m_axi4l_app} [get_bd_ports /pi_m_axi4l_app_aclk]
set_property CONFIG.ASSOCIATED_BUSIF {p_m_axi4l_bsp} [get_bd_ports /po_m_axi4_aclk]
