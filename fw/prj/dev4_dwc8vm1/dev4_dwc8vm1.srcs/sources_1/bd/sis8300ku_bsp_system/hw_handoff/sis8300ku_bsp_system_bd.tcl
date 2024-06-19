
################################################################
# This is a generated script based on design: sis8300ku_bsp_system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source sis8300ku_bsp_system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcku040-ffva1156-1-c
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name sis8300ku_bsp_system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}


##################################################################
# DATA FILE TCL PROCs
##################################################################

proc write_ddr4_file_sis8300ku_bsp_system_ddr4_0_0 { str_filepath } {

   file mkdir [ file dirname "$str_filepath" ]
   set data_file [open $str_filepath  w+]

   puts $data_file {Part type,Part name,Rank,StackHeight,CA Mirror,Data mask,Address width,Row width,Column width,Bank width,Bank group width,CS width,CKE width,ODT width,CK width,Memory speed grade,Memory density,Component density,Memory device width,Memory component width,Data bits per strobe,IO Voltages,Data widths,Min period,Max period,tCKE,tFAW,tFAW_dlr,tMRD,tRAS,tRCD,tREFI,tRFC,tRFC_dlr,tRP,tRRD_S,tRRD_L,tRRD_dlr,tRTP,tWR,tWTR_S,tWTR_L,tXPR,tZQCS,tZQINIT,tCCD_3ds,cas latency,cas write latency,burst length}
   puts $data_file {Components,H5AN4G6NAFR,1,1,0,1,17,15,10,2,1,1,1,1,1,UHX,4Gb,4Gb,16,16,8,1.2V,"8,16,24,32,40,48,56,64,72,80",833,1600,5000 ps,30000 ps,0,8 tck,35000 ps,13750 ps,7800000 ps,260000 ps,0,13750 ps,5300 ps,6400 ps,0,7500 ps,15000 ps,2500 ps,7500 ps,270 ns,128 tck,1024 tck,0,11,11,8}

   close $data_file
}
# End of write_ddr4_file_sis8300ku_bsp_system_ddr4_0_0()



##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: pcie
proc create_hier_cell_pcie { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_pcie() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_dma_ddr

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 p_m_axi4l_app

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 p_m_axi4l_bsp

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 p_pcie_mgt


  # Create pins
  create_bd_pin -dir I -type clk pi_m_axi4l_app_aclk
  create_bd_pin -dir I -type rst pi_pcie_areset_n
  create_bd_pin -dir I -from 15 -to 0 pi_pcie_irq_req
  create_bd_pin -dir I -type clk pi_pcie_sys_clk
  create_bd_pin -dir I -type clk pi_pcie_sys_clk_gt
  create_bd_pin -dir O -type clk po_m_axi4_aclk
  create_bd_pin -dir O -type rst po_m_axi4_areset_n
  create_bd_pin -dir O -from 15 -to 0 po_pcie_irq_ack
  create_bd_pin -dir O po_pcie_link_up

  # Create instance: axi_interconnect_dma, and set properties
  set axi_interconnect_dma [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_interconnect_dma ]
  set_property -dict [ list \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {1} \
 ] $axi_interconnect_dma

  # Create instance: axi_interconnect_reg, and set properties
  set axi_interconnect_reg [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_interconnect_reg ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {2} \
 ] $axi_interconnect_reg

  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [ list \
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
 ] $xdma_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins p_pcie_mgt] [get_bd_intf_pins xdma_0/pcie_mgt]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins p_m_axi4l_bsp] [get_bd_intf_pins axi_interconnect_reg/M00_AXI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins p_m_axi4l_app] [get_bd_intf_pins axi_interconnect_reg/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_dma_M00_AXI [get_bd_intf_pins axi_interconnect_dma/M00_AXI] [get_bd_intf_pins axi_interconnect_reg/S01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_dma_M01_AXI [get_bd_intf_pins m_axi_dma_ddr] [get_bd_intf_pins axi_interconnect_dma/M01_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI [get_bd_intf_pins axi_interconnect_dma/S00_AXI] [get_bd_intf_pins xdma_0/M_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins axi_interconnect_reg/S00_AXI] [get_bd_intf_pins xdma_0/M_AXI_LITE]

  # Create port connections
  connect_bd_net -net pi_m_axi4l_app_aclk_1 [get_bd_pins pi_m_axi4l_app_aclk] [get_bd_pins axi_interconnect_reg/aclk1]
  connect_bd_net -net pi_pcie_areset_n_1 [get_bd_pins pi_pcie_areset_n] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net pi_pcie_irq_req_1 [get_bd_pins pi_pcie_irq_req] [get_bd_pins xdma_0/usr_irq_req]
  connect_bd_net -net pi_pcie_sys_clk_1 [get_bd_pins pi_pcie_sys_clk] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net pi_pcie_sys_clk_gt_1 [get_bd_pins pi_pcie_sys_clk_gt] [get_bd_pins xdma_0/sys_clk_gt]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins po_m_axi4_aclk] [get_bd_pins axi_interconnect_dma/aclk] [get_bd_pins axi_interconnect_reg/aclk] [get_bd_pins xdma_0/axi_aclk]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins po_m_axi4_areset_n] [get_bd_pins axi_interconnect_dma/aresetn] [get_bd_pins axi_interconnect_reg/aresetn] [get_bd_pins xdma_0/axi_aresetn]
  connect_bd_net -net xdma_0_user_lnk_up [get_bd_pins po_pcie_link_up] [get_bd_pins xdma_0/user_lnk_up]
  connect_bd_net -net xdma_0_usr_irq_ack [get_bd_pins po_pcie_irq_ack] [get_bd_pins xdma_0/usr_irq_ack]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: ddr
proc create_hier_cell_ddr { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_ddr() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 p_ddr4

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 p_s_axi4_ddr

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_pcie_dma

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_ps


  # Create pins
  create_bd_pin -dir I -type clk pi_ddr4_sys_clk
  create_bd_pin -dir I -type clk pi_s_axi4_pcie_aclk
  create_bd_pin -dir O po_ddr_calib_done
  create_bd_pin -dir O -type clk po_s_axi4_ddr_aclk
  create_bd_pin -dir O -from 0 -to 0 -type rst po_s_axi4_ddr_areset_n

  # Create instance: axi_interconnect_ddr, and set properties
  set axi_interconnect_ddr [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_interconnect_ddr ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
 ] $axi_interconnect_ddr

  # Create instance: ddr4_0, and set properties
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]

   # Generate the DDR4 Custom Parts File
   set str_ddr4_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $ddr4_0 ] ] ]
   set str_ddr4_file_name custom_parts_ddr4.csv
   set str_ddr4_file_path ${str_ddr4_folder}/${str_ddr4_file_name}

   write_ddr4_file_sis8300ku_bsp_system_ddr4_0_0 $str_ddr4_file_path

  set_property -dict [ list \
   CONFIG.C0.BANK_GROUP_WIDTH {1} \
   CONFIG.C0.DDR4_AxiAddressWidth {31} \
   CONFIG.C0.DDR4_AxiDataWidth {256} \
   CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5} \
   CONFIG.C0.DDR4_CasLatency {11} \
   CONFIG.C0.DDR4_CasWriteLatency {11} \
   CONFIG.C0.DDR4_CustomParts {custom_parts_ddr4.csv} \
   CONFIG.C0.DDR4_DataWidth {64} \
   CONFIG.C0.DDR4_InputClockPeriod {8000} \
   CONFIG.C0.DDR4_MemoryPart {H5AN4G6NAFR} \
   CONFIG.C0.DDR4_Specify_MandD {false} \
   CONFIG.C0.DDR4_TimePeriod {1250} \
   CONFIG.C0.DDR4_isCustom {true} \
   CONFIG.System_Clock {No_Buffer} \
 ] $ddr4_0

  # Create instance: sys_reset_0, and set properties
  set sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_reset_0 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins p_ddr4] [get_bd_intf_pins ddr4_0/C0_DDR4]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins p_s_axi4_ddr] [get_bd_intf_pins axi_interconnect_ddr/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_ddr_M00_AXI [get_bd_intf_pins axi_interconnect_ddr/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net s_axi_pcie_dma_1 [get_bd_intf_pins s_axi_pcie_dma] [get_bd_intf_pins axi_interconnect_ddr/S01_AXI]

  # Create port connections
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk [get_bd_pins po_s_axi4_ddr_aclk] [get_bd_pins axi_interconnect_ddr/aclk] [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins sys_reset_0/slowest_sync_clk]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk_sync_rst [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins sys_reset_0/ext_reset_in]
  connect_bd_net -net ddr4_0_c0_init_calib_complete [get_bd_pins po_ddr_calib_done] [get_bd_pins ddr4_0/c0_init_calib_complete]
  connect_bd_net -net pi_ddr4_sys_clk_1 [get_bd_pins pi_ddr4_sys_clk] [get_bd_pins ddr4_0/c0_sys_clk_i]
  connect_bd_net -net pi_s_axi4_pcie_aclk_1 [get_bd_pins pi_s_axi4_pcie_aclk] [get_bd_pins axi_interconnect_ddr/aclk1]
  connect_bd_net -net sys_reset_0_interconnect_aresetn [get_bd_pins po_s_axi4_ddr_areset_n] [get_bd_pins axi_interconnect_ddr/aresetn] [get_bd_pins sys_reset_0/interconnect_aresetn]
  connect_bd_net -net sys_reset_0_peripheral_aresetn [get_bd_pins ddr4_0/c0_ddr4_aresetn] [get_bd_pins sys_reset_0/peripheral_aresetn]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins ddr4_0/sys_rst] [get_bd_pins xlconstant_0/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set p_ddr4 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 p_ddr4 ]

  set p_m_axi4l_app [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 p_m_axi4l_app ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {23} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $p_m_axi4l_app

  set p_m_axi4l_bsp [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 p_m_axi4l_bsp ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {23} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $p_m_axi4l_bsp

  set p_pcie_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 p_pcie_mgt ]

  set p_s_axi4_ddr [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 p_s_axi4_ddr ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {4} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $p_s_axi4_ddr


  # Create ports
  set pi_ddr4_sys_clk [ create_bd_port -dir I -type clk -freq_hz 125000000 pi_ddr4_sys_clk ]
  set pi_m_axi4l_app_aclk [ create_bd_port -dir I -type clk -freq_hz 125000000 pi_m_axi4l_app_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {p_m_axi4l_app} \
 ] $pi_m_axi4l_app_aclk
  set pi_pcie_areset_n [ create_bd_port -dir I -type rst pi_pcie_areset_n ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pi_pcie_areset_n
  set pi_pcie_irq_req [ create_bd_port -dir I -from 15 -to 0 -type intr pi_pcie_irq_req ]
  set_property -dict [ list \
   CONFIG.PortWidth {16} \
   CONFIG.SENSITIVITY {EDGE_RISING} \
 ] $pi_pcie_irq_req
  set pi_pcie_sys_clk [ create_bd_port -dir I -type clk pi_pcie_sys_clk ]
  set pi_pcie_sys_clk_gt [ create_bd_port -dir I -type clk pi_pcie_sys_clk_gt ]
  set po_ddr_calib_done [ create_bd_port -dir O po_ddr_calib_done ]
  set po_m_axi4_aclk [ create_bd_port -dir O -type clk po_m_axi4_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {p_m_axi4l_bsp} \
 ] $po_m_axi4_aclk
  set po_m_axi4_areset_n [ create_bd_port -dir O -type rst po_m_axi4_areset_n ]
  set po_pcie_irq_ack [ create_bd_port -dir O -from 15 -to 0 po_pcie_irq_ack ]
  set po_pcie_link_up [ create_bd_port -dir O po_pcie_link_up ]
  set po_s_axi4_ddr_aclk [ create_bd_port -dir O -type clk po_s_axi4_ddr_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {p_s_axi4_ddr} \
   CONFIG.ASSOCIATED_RESET {po_s_axi4_ddr_areset_n} \
 ] $po_s_axi4_ddr_aclk
  set po_s_axi4_ddr_areset_n [ create_bd_port -dir O -from 0 -to 0 -type rst po_s_axi4_ddr_areset_n ]

  # Create instance: ddr
  create_hier_cell_ddr [current_bd_instance .] ddr

  # Create instance: pcie
  create_hier_cell_pcie [current_bd_instance .] pcie

  # Create interface connections
  connect_bd_intf_net -intf_net ddr_p_ddr4 [get_bd_intf_ports p_ddr4] [get_bd_intf_pins ddr/p_ddr4]
  connect_bd_intf_net -intf_net p_s_axi4_ddr_1 [get_bd_intf_ports p_s_axi4_ddr] [get_bd_intf_pins ddr/p_s_axi4_ddr]
  connect_bd_intf_net -intf_net pcie_m_axi_dma_ddr [get_bd_intf_pins ddr/s_axi_pcie_dma] [get_bd_intf_pins pcie/m_axi_dma_ddr]
  connect_bd_intf_net -intf_net pcie_p_m_axi4l_app [get_bd_intf_ports p_m_axi4l_app] [get_bd_intf_pins pcie/p_m_axi4l_app]
  connect_bd_intf_net -intf_net pcie_p_m_axi4l_bsp [get_bd_intf_ports p_m_axi4l_bsp] [get_bd_intf_pins pcie/p_m_axi4l_bsp]
  connect_bd_intf_net -intf_net pcie_p_pcie_mgt [get_bd_intf_ports p_pcie_mgt] [get_bd_intf_pins pcie/p_pcie_mgt]

  # Create port connections
  connect_bd_net -net ddr_po_ddr_calib_done [get_bd_ports po_ddr_calib_done] [get_bd_pins ddr/po_ddr_calib_done]
  connect_bd_net -net ddr_po_s_axi4_ddr_aclk [get_bd_ports po_s_axi4_ddr_aclk] [get_bd_pins ddr/po_s_axi4_ddr_aclk]
  connect_bd_net -net ddr_po_s_axi4_ddr_areset_n [get_bd_ports po_s_axi4_ddr_areset_n] [get_bd_pins ddr/po_s_axi4_ddr_areset_n]
  connect_bd_net -net pcie_po_m_axi4_aclk [get_bd_ports po_m_axi4_aclk] [get_bd_pins ddr/pi_s_axi4_pcie_aclk] [get_bd_pins pcie/po_m_axi4_aclk]
  connect_bd_net -net pcie_po_m_axi4_areset_n [get_bd_ports po_m_axi4_areset_n] [get_bd_pins pcie/po_m_axi4_areset_n]
  connect_bd_net -net pcie_po_pcie_irq_ack [get_bd_ports po_pcie_irq_ack] [get_bd_pins pcie/po_pcie_irq_ack]
  connect_bd_net -net pcie_po_pcie_link_up [get_bd_ports po_pcie_link_up] [get_bd_pins pcie/po_pcie_link_up]
  connect_bd_net -net pi_ddr4_sys_clk_1 [get_bd_ports pi_ddr4_sys_clk] [get_bd_pins ddr/pi_ddr4_sys_clk]
  connect_bd_net -net pi_m_axi4l_app_aclk_1 [get_bd_ports pi_m_axi4l_app_aclk] [get_bd_pins pcie/pi_m_axi4l_app_aclk]
  connect_bd_net -net pi_pcie_areset_n_1 [get_bd_ports pi_pcie_areset_n] [get_bd_pins pcie/pi_pcie_areset_n]
  connect_bd_net -net pi_pcie_irq_req_1 [get_bd_ports pi_pcie_irq_req] [get_bd_pins pcie/pi_pcie_irq_req]
  connect_bd_net -net pi_pcie_sys_clk_1 [get_bd_ports pi_pcie_sys_clk] [get_bd_pins pcie/pi_pcie_sys_clk]
  connect_bd_net -net pi_pcie_sys_clk_gt_1 [get_bd_ports pi_pcie_sys_clk_gt] [get_bd_pins pcie/pi_pcie_sys_clk_gt]

  # Create address segments
  assign_bd_address -offset 0x80000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces pcie/xdma_0/M_AXI] [get_bd_addr_segs ddr/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force
  assign_bd_address -offset 0x00800000 -range 0x00800000 -target_address_space [get_bd_addr_spaces pcie/xdma_0/M_AXI] [get_bd_addr_segs p_m_axi4l_app/Reg] -force
  assign_bd_address -offset 0x00800000 -range 0x00800000 -target_address_space [get_bd_addr_spaces pcie/xdma_0/M_AXI_LITE] [get_bd_addr_segs p_m_axi4l_app/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00400000 -target_address_space [get_bd_addr_spaces pcie/xdma_0/M_AXI] [get_bd_addr_segs p_m_axi4l_bsp/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00400000 -target_address_space [get_bd_addr_spaces pcie/xdma_0/M_AXI_LITE] [get_bd_addr_segs p_m_axi4l_bsp/Reg] -force
  assign_bd_address -offset 0x80000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces p_s_axi4_ddr] [get_bd_addr_segs ddr/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


