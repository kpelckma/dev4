
set currPath [file dirname [file normalize [info script]]]

# ==============================================================================
# create BD design
set BspBdName "sis8300ku_bsp_system"

if { [catch { create_bd_design "${BspBdName}" } ] } {
  puts "WARNING: BD exist, recreating"
  remove_files [get_files "${BspBdName}.bd"]
  create_bd_design ${BspBdName}
}

# ==============================================================================
# create cells
source ${currPath}/bd_pcie_cell.tcl
source ${currPath}/bd_ddr4_cell.tcl

# ==============================================================================
# connections between cells
current_bd_instance /

connect_bd_intf_net  [get_bd_intf_pins  "pcie/m_axi_dma_ddr"]   [get_bd_intf_pins  "ddr/s_axi_pcie_dma"]
connect_bd_net       [get_bd_pins       "pcie/po_m_axi4_aclk"]  [get_bd_pins       "ddr/pi_s_axi4_pcie_aclk"]
# ==============================================================================
# assign cell addresses

#  PCIe AXI_LITE: access BSP/APP registers
assign_bd_address -offset 0x00000000 -range 4M -target_address_space [get_bd_addr_spaces "pcie/xdma_0/M_AXI_LITE"] [get_bd_addr_segs "p_m_axi4l_bsp/Reg"] -force
assign_bd_address -offset 0x00800000 -range 8M -target_address_space [get_bd_addr_spaces "pcie/xdma_0/M_AXI_LITE"] [get_bd_addr_segs "p_m_axi4l_app/Reg"] -force

# PCIe DMA: access BSP/APP
assign_bd_address -offset 0x00000000 -range 4M -target_address_space [get_bd_addr_spaces "pcie/xdma_0/M_AXI"]  [get_bd_addr_segs "p_m_axi4l_bsp/Reg"] -force
assign_bd_address -offset 0x00800000 -range 8M -target_address_space [get_bd_addr_spaces "pcie/xdma_0/M_AXI"]  [get_bd_addr_segs "p_m_axi4l_app/Reg"] -force

# PCIe DMA: access PL DDR
assign_bd_address -offset 0x80000000 -range 2G -target_address_space [get_bd_addr_spaces "pcie/xdma_0/M_AXI"]  [get_bd_addr_segs "ddr/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK"] -force

# APP: access PL DDR
assign_bd_address -offset 0x80000000 -range 2G -target_address_space [get_bd_addr_spaces "p_s_axi4_ddr"] [get_bd_addr_segs "ddr/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK"] -force

set_property -dict [list CONFIG.PROTOCOL {AXI4LITE}] [get_bd_intf_ports "/p_m_axi4l_app"]
set_property -dict [list CONFIG.PROTOCOL {AXI4LITE}] [get_bd_intf_ports "/p_m_axi4l_bsp"]

set_property -dict [list CONFIG.ADDR_WIDTH {23} ]    [get_bd_intf_ports "/p_m_axi4l_app"]
set_property -dict [list CONFIG.ADDR_WIDTH {23} ]    [get_bd_intf_ports "/p_m_axi4l_bsp"]

# ==============================================================================
# finalize
regenerate_bd_layout
save_bd_design
validate_bd_design;             # validate after save so it can be opened in GUI

# ==============================================================================
# make wrapper and add to design
make_wrapper -files [get_files ${BspBdName}.bd] -top -import
