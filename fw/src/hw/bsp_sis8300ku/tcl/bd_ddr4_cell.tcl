
# ##############################################################################
# ==============================================================================

puts "\n# Generating DDR4 IP core..."

# Create cell and set as current instance
current_bd_instance /
current_bd_instance [create_bd_cell -type hier "ddr"]

# create IPs
create_bd_cell -type ip -vln xilinx.com:ip:smartconnect   "axi_interconnect_ddr"
create_bd_cell -type ip -vln xilinx.com:ip:proc_sys_reset "sys_reset_0"

set axi_interconnect_ddr_config \
  [list \
     CONFIG.NUM_SI {2} \
     CONFIG.NUM_MI {1} \
     CONFIG.NUM_CLKS {2}]

set_property -dict $axi_interconnect_ddr_config [get_bd_cells "axi_interconnect_ddr"]

# ==============================================================================
# DDR4 IP instantiation and Configuration
# ==============================================================================


proc write_ddr4_file_design_1_ddr4_0_0 { str_filepath } {

   file mkdir [ file dirname "$str_filepath" ]
   set data_file [open $str_filepath  w+]

   puts $data_file {Part type,Part name,Rank,StackHeight,CA Mirror,Data mask,Address width,Row width,Column width,Bank width,Bank group width,CS width,CKE width,ODT width,CK width,Memory speed grade,Memory density,Component density,Memory device width,Memory component width,Data bits per strobe,IO Voltages,Data widths,Min period,Max period,tCKE,tFAW,tFAW_dlr,tMRD,tRAS,tRCD,tREFI,tRFC,tRFC_dlr,tRP,tRRD_S,tRRD_L,tRRD_dlr,tRTP,tWR,tWTR_S,tWTR_L,tXPR,tZQCS,tZQINIT,tCCD_3ds,cas latency,cas write latency,burst length}
   puts $data_file {Components,H5AN4G6NAFR,1,1,0,1,17,15,10,2,1,1,1,1,1,UHX,4Gb,4Gb,16,16,8,1.2V,"8,16,24,32,40,48,56,64,72,80",833,1600,5000 ps,30000 ps,0,8 tck,35000 ps,13750 ps,7800000 ps,260000 ps,0,13750 ps,5300 ps,6400 ps,0,7500 ps,15000 ps,2500 ps,7500 ps,270 ns,128 tck,1024 tck,0,11,11,8}

   close $data_file
}

 # Create instance: ddr4_0, and set properties
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]

   # Generate the DDR4 Custom Parts File
   set str_ddr4_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $ddr4_0 ] ] ]
   set str_ddr4_file_name custom_parts_ddr4.csv
   set str_ddr4_file_path ${str_ddr4_folder}/${str_ddr4_file_name}

   write_ddr4_file_design_1_ddr4_0_0 $str_ddr4_file_path

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

# ==============================================================================


  # Create instance: xlconstant_0, and set properties                                                                                                                                                             
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0




# ==============================================================================
# create TOP interfaces/ports

# DDR single ended input clock no buffer
create_bd_port -dir I -type clk "pi_ddr4_sys_clk"
# create_bd_port -dir I -type clk "pi_ddr4_sys_clk_p"
# create_bd_port -dir I -type clk "pi_ddr4_sys_clk_n"
# create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 "p_ddr4_sys_clk"

create_bd_intf_port  -mode  Master  -vlnv  xilinx.com:interface:ddr4_rtl:1.0   "p_ddr4"
create_bd_intf_port  -mode  Slave   -vlnv  xilinx.com:interface:aximm_rtl:1.0  "p_s_axi4_ddr"

# cell interfaces/ports
create_bd_pin  -dir I -type clk "pi_s_axi4_pcie_aclk"
create_bd_pin  -dir O -type clk "po_s_axi4_ddr_aclk"
create_bd_port -dir O -type clk "po_s_axi4_ddr_aclk"
create_bd_port -dir O -type rst "po_s_axi4_ddr_areset_n"

create_bd_port -dir O po_ddr_calib_done

create_bd_intf_pin   -mode  Slave   -vlnv  xilinx.com:interface:aximm_rtl:1.0  "s_axi_pcie_dma"
create_bd_intf_pin   -mode  Slave   -vlnv  xilinx.com:interface:aximm_rtl:1.0  "s_axi_ps"

# properties for ports
set_property -dict \
  [ list \
      CONFIG.ASSOCIATED_BUSIF {p_s_axi4_ddr} \
      CONFIG.ASSOCIATED_RESET {po_s_axi4_ddr_areset_n} \
     ] [get_bd_ports "/po_s_axi4_ddr_aclk"]

set_property -dict \
  [ list \
      CONFIG.FREQ_HZ {125000000} \
     ] [get_bd_ports "/pi_ddr4_sys_clk"]

set_property -dict \
  [list \
     CONFIG.DATA_WIDTH {256} \
     CONFIG.HAS_REGION {0} \
     CONFIG.ID_WIDTH 4 \
    ] [get_bd_intf_ports "/p_s_axi4_ddr"]


# DDR
connect_bd_net      [get_bd_pins      "ddr4_0/c0_sys_clk_i"]    [get_bd_ports      "/pi_ddr4_sys_clk"]
connect_bd_intf_net [get_bd_intf_pins "ddr4_0/C0_DDR4"]         [get_bd_intf_ports "/p_ddr4"]
connect_bd_net      [get_bd_pins      "ddr4_0/c0_ddr4_ui_clk"]  [get_bd_pins       "po_s_axi4_ddr_aclk"]
connect_bd_net      [get_bd_pins      "ddr4_0/c0_init_calib_complete"] [get_bd_ports "/po_ddr_calib_done"]

# AXI
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_ddr/M00_AXI"] [get_bd_intf_pins  "ddr4_0/C0_DDR4_S_AXI"]
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_ddr/S00_AXI"] [get_bd_intf_ports "/p_s_axi4_ddr"]
connect_bd_intf_net [get_bd_intf_pins "axi_interconnect_ddr/S01_AXI"] [get_bd_intf_pins  "s_axi_pcie_dma"]

connect_bd_net  [get_bd_pins "axi_interconnect_ddr/aresetn"]  [get_bd_pins "sys_reset_0/interconnect_aresetn"]
connect_bd_net  [get_bd_pins "axi_interconnect_ddr/aclk"]     [get_bd_pins "ddr4_0/c0_ddr4_ui_clk"]
connect_bd_net  [get_bd_pins "axi_interconnect_ddr/aclk1"]    [get_bd_pins "pi_s_axi4_pcie_aclk"]

# RESET
connect_bd_net [get_bd_pins "sys_reset_0/slowest_sync_clk"]   [get_bd_pins "ddr4_0/c0_ddr4_ui_clk"]
connect_bd_net [get_bd_pins "sys_reset_0/ext_reset_in"]       [get_bd_pins "ddr4_0/c0_ddr4_ui_clk_sync_rst"]
connect_bd_net [get_bd_pins "sys_reset_0/peripheral_aresetn"] [get_bd_pins "ddr4_0/c0_ddr4_aresetn"]

connect_bd_net  [get_bd_pins  "sys_reset_0/interconnect_aresetn"] [get_bd_ports  "/po_s_axi4_ddr_areset_n"]
connect_bd_net  [get_bd_pins  "ddr4_0/c0_ddr4_ui_clk"]            [get_bd_ports  "/po_s_axi4_ddr_aclk"]
connect_bd_net -net xlconstant_0_dout [get_bd_pins ddr4_0/sys_rst] [get_bd_pins xlconstant_0/dout]

