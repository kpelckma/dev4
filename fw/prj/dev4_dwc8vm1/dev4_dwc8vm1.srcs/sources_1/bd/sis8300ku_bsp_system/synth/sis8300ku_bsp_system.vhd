--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
--Date        : Wed Sep 20 09:18:34 2023
--Host        : workstation running 64-bit unknown
--Command     : generate_target sis8300ku_bsp_system.bd
--Design      : sis8300ku_bsp_system
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ddr_imp_QC2Z9C is
  port (
    p_ddr4_act_n : out STD_LOGIC;
    p_ddr4_adr : out STD_LOGIC_VECTOR ( 16 downto 0 );
    p_ddr4_ba : out STD_LOGIC_VECTOR ( 1 downto 0 );
    p_ddr4_bg : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_ck_c : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_ck_t : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_dm_n : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    p_ddr4_dq : inout STD_LOGIC_VECTOR ( 63 downto 0 );
    p_ddr4_dqs_c : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    p_ddr4_dqs_t : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    p_ddr4_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_reset_n : out STD_LOGIC;
    p_s_axi4_ddr_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_s_axi4_ddr_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    p_s_axi4_ddr_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    p_s_axi4_ddr_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_arready : out STD_LOGIC;
    p_s_axi4_ddr_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_arvalid : in STD_LOGIC;
    p_s_axi4_ddr_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_s_axi4_ddr_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    p_s_axi4_ddr_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    p_s_axi4_ddr_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_awready : out STD_LOGIC;
    p_s_axi4_ddr_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_awvalid : in STD_LOGIC;
    p_s_axi4_ddr_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_bready : in STD_LOGIC;
    p_s_axi4_ddr_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_bvalid : out STD_LOGIC;
    p_s_axi4_ddr_rdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    p_s_axi4_ddr_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_rlast : out STD_LOGIC;
    p_s_axi4_ddr_rready : in STD_LOGIC;
    p_s_axi4_ddr_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_rvalid : out STD_LOGIC;
    p_s_axi4_ddr_wdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    p_s_axi4_ddr_wlast : in STD_LOGIC;
    p_s_axi4_ddr_wready : out STD_LOGIC;
    p_s_axi4_ddr_wstrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_s_axi4_ddr_wvalid : in STD_LOGIC;
    pi_ddr4_sys_clk : in STD_LOGIC;
    pi_s_axi4_pcie_aclk : in STD_LOGIC;
    po_ddr_calib_done : out STD_LOGIC;
    po_s_axi4_ddr_aclk : out STD_LOGIC;
    po_s_axi4_ddr_areset_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_pcie_dma_araddr : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axi_pcie_dma_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_pcie_dma_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_pcie_dma_arid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_pcie_dma_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_pcie_dma_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_pcie_dma_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_pcie_dma_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_pcie_dma_arready : out STD_LOGIC;
    s_axi_pcie_dma_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_pcie_dma_aruser : in STD_LOGIC_VECTOR ( 113 downto 0 );
    s_axi_pcie_dma_arvalid : in STD_LOGIC;
    s_axi_pcie_dma_awaddr : in STD_LOGIC_VECTOR ( 63 downto 0 );
    s_axi_pcie_dma_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_pcie_dma_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_pcie_dma_awid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_pcie_dma_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_pcie_dma_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_pcie_dma_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_pcie_dma_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_pcie_dma_awready : out STD_LOGIC;
    s_axi_pcie_dma_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_pcie_dma_awuser : in STD_LOGIC_VECTOR ( 113 downto 0 );
    s_axi_pcie_dma_awvalid : in STD_LOGIC;
    s_axi_pcie_dma_bid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_pcie_dma_bready : in STD_LOGIC;
    s_axi_pcie_dma_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_pcie_dma_buser : out STD_LOGIC_VECTOR ( 113 downto 0 );
    s_axi_pcie_dma_bvalid : out STD_LOGIC;
    s_axi_pcie_dma_rdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    s_axi_pcie_dma_rid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_pcie_dma_rlast : out STD_LOGIC;
    s_axi_pcie_dma_rready : in STD_LOGIC;
    s_axi_pcie_dma_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_pcie_dma_ruser : out STD_LOGIC_VECTOR ( 13 downto 0 );
    s_axi_pcie_dma_rvalid : out STD_LOGIC;
    s_axi_pcie_dma_wdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    s_axi_pcie_dma_wlast : in STD_LOGIC;
    s_axi_pcie_dma_wready : out STD_LOGIC;
    s_axi_pcie_dma_wstrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_pcie_dma_wuser : in STD_LOGIC_VECTOR ( 13 downto 0 );
    s_axi_pcie_dma_wvalid : in STD_LOGIC
  );
end ddr_imp_QC2Z9C;

architecture STRUCTURE of ddr_imp_QC2Z9C is
  component sis8300ku_bsp_system_axi_interconnect_ddr_0 is
  port (
    aclk : in STD_LOGIC;
    aclk1 : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    S00_AXI_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awvalid : in STD_LOGIC;
    S00_AXI_awready : out STD_LOGIC;
    S00_AXI_wdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    S00_AXI_wstrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_wlast : in STD_LOGIC;
    S00_AXI_wvalid : in STD_LOGIC;
    S00_AXI_wready : out STD_LOGIC;
    S00_AXI_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_bvalid : out STD_LOGIC;
    S00_AXI_bready : in STD_LOGIC;
    S00_AXI_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arvalid : in STD_LOGIC;
    S00_AXI_arready : out STD_LOGIC;
    S00_AXI_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_rdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    S00_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_rlast : out STD_LOGIC;
    S00_AXI_rvalid : out STD_LOGIC;
    S00_AXI_rready : in STD_LOGIC;
    S01_AXI_awid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_awaddr : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S01_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S01_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_awuser : in STD_LOGIC_VECTOR ( 113 downto 0 );
    S01_AXI_awvalid : in STD_LOGIC;
    S01_AXI_awready : out STD_LOGIC;
    S01_AXI_wdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    S01_AXI_wstrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S01_AXI_wlast : in STD_LOGIC;
    S01_AXI_wuser : in STD_LOGIC_VECTOR ( 13 downto 0 );
    S01_AXI_wvalid : in STD_LOGIC;
    S01_AXI_wready : out STD_LOGIC;
    S01_AXI_bid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_buser : out STD_LOGIC_VECTOR ( 113 downto 0 );
    S01_AXI_bvalid : out STD_LOGIC;
    S01_AXI_bready : in STD_LOGIC;
    S01_AXI_arid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_araddr : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S01_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S01_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_aruser : in STD_LOGIC_VECTOR ( 113 downto 0 );
    S01_AXI_arvalid : in STD_LOGIC;
    S01_AXI_arready : out STD_LOGIC;
    S01_AXI_rid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_rdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    S01_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_rlast : out STD_LOGIC;
    S01_AXI_ruser : out STD_LOGIC_VECTOR ( 13 downto 0 );
    S01_AXI_rvalid : out STD_LOGIC;
    S01_AXI_rready : in STD_LOGIC;
    M00_AXI_awaddr : out STD_LOGIC_VECTOR ( 30 downto 0 );
    M00_AXI_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_awvalid : out STD_LOGIC;
    M00_AXI_awready : in STD_LOGIC;
    M00_AXI_wdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    M00_AXI_wstrb : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_wlast : out STD_LOGIC;
    M00_AXI_wvalid : out STD_LOGIC;
    M00_AXI_wready : in STD_LOGIC;
    M00_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_bvalid : in STD_LOGIC;
    M00_AXI_bready : out STD_LOGIC;
    M00_AXI_araddr : out STD_LOGIC_VECTOR ( 30 downto 0 );
    M00_AXI_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_arvalid : out STD_LOGIC;
    M00_AXI_arready : in STD_LOGIC;
    M00_AXI_rdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    M00_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_rlast : in STD_LOGIC;
    M00_AXI_rvalid : in STD_LOGIC;
    M00_AXI_rready : out STD_LOGIC
  );
  end component sis8300ku_bsp_system_axi_interconnect_ddr_0;
  component sis8300ku_bsp_system_sys_reset_0_0 is
  port (
    slowest_sync_clk : in STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    aux_reset_in : in STD_LOGIC;
    mb_debug_sys_rst : in STD_LOGIC;
    dcm_locked : in STD_LOGIC;
    mb_reset : out STD_LOGIC;
    bus_struct_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    interconnect_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component sis8300ku_bsp_system_sys_reset_0_0;
  component sis8300ku_bsp_system_ddr4_0_0 is
  port (
    c0_init_calib_complete : out STD_LOGIC;
    dbg_clk : out STD_LOGIC;
    c0_sys_clk_i : in STD_LOGIC;
    dbg_bus : out STD_LOGIC_VECTOR ( 511 downto 0 );
    c0_ddr4_adr : out STD_LOGIC_VECTOR ( 16 downto 0 );
    c0_ddr4_ba : out STD_LOGIC_VECTOR ( 1 downto 0 );
    c0_ddr4_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_dm_dbi_n : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_ddr4_dq : inout STD_LOGIC_VECTOR ( 63 downto 0 );
    c0_ddr4_dqs_c : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_ddr4_dqs_t : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_ddr4_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_bg : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_reset_n : out STD_LOGIC;
    c0_ddr4_act_n : out STD_LOGIC;
    c0_ddr4_ck_c : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_ck_t : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_ui_clk : out STD_LOGIC;
    c0_ddr4_ui_clk_sync_rst : out STD_LOGIC;
    c0_ddr4_aresetn : in STD_LOGIC;
    c0_ddr4_s_axi_awid : in STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_s_axi_awaddr : in STD_LOGIC_VECTOR ( 30 downto 0 );
    c0_ddr4_s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_ddr4_s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c0_ddr4_s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    c0_ddr4_s_axi_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_ddr4_s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c0_ddr4_s_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_ddr4_s_axi_awvalid : in STD_LOGIC;
    c0_ddr4_s_axi_awready : out STD_LOGIC;
    c0_ddr4_s_axi_wdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    c0_ddr4_s_axi_wstrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    c0_ddr4_s_axi_wlast : in STD_LOGIC;
    c0_ddr4_s_axi_wvalid : in STD_LOGIC;
    c0_ddr4_s_axi_wready : out STD_LOGIC;
    c0_ddr4_s_axi_bready : in STD_LOGIC;
    c0_ddr4_s_axi_bid : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    c0_ddr4_s_axi_bvalid : out STD_LOGIC;
    c0_ddr4_s_axi_arid : in STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_s_axi_araddr : in STD_LOGIC_VECTOR ( 30 downto 0 );
    c0_ddr4_s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    c0_ddr4_s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c0_ddr4_s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    c0_ddr4_s_axi_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_ddr4_s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    c0_ddr4_s_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    c0_ddr4_s_axi_arvalid : in STD_LOGIC;
    c0_ddr4_s_axi_arready : out STD_LOGIC;
    c0_ddr4_s_axi_rready : in STD_LOGIC;
    c0_ddr4_s_axi_rlast : out STD_LOGIC;
    c0_ddr4_s_axi_rvalid : out STD_LOGIC;
    c0_ddr4_s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    c0_ddr4_s_axi_rid : out STD_LOGIC_VECTOR ( 0 to 0 );
    c0_ddr4_s_axi_rdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    sys_rst : in STD_LOGIC
  );
  end component sis8300ku_bsp_system_ddr4_0_0;
  component sis8300ku_bsp_system_xlconstant_0_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component sis8300ku_bsp_system_xlconstant_0_0;
  signal Conn1_ACT_N : STD_LOGIC;
  signal Conn1_ADR : STD_LOGIC_VECTOR ( 16 downto 0 );
  signal Conn1_BA : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Conn1_BG : STD_LOGIC_VECTOR ( 0 to 0 );
  signal Conn1_CKE : STD_LOGIC_VECTOR ( 0 to 0 );
  signal Conn1_CK_C : STD_LOGIC_VECTOR ( 0 to 0 );
  signal Conn1_CK_T : STD_LOGIC_VECTOR ( 0 to 0 );
  signal Conn1_CS_N : STD_LOGIC_VECTOR ( 0 to 0 );
  signal Conn1_DM_N : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn1_DQ : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal Conn1_DQS_C : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn1_DQS_T : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn1_ODT : STD_LOGIC_VECTOR ( 0 to 0 );
  signal Conn1_RESET_N : STD_LOGIC;
  signal Conn2_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn2_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Conn2_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_ARID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn2_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal Conn2_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Conn2_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_ARREADY : STD_LOGIC;
  signal Conn2_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Conn2_ARVALID : STD_LOGIC;
  signal Conn2_AWADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn2_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Conn2_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_AWID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal Conn2_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal Conn2_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Conn2_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_AWREADY : STD_LOGIC;
  signal Conn2_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Conn2_AWVALID : STD_LOGIC;
  signal Conn2_BID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_BREADY : STD_LOGIC;
  signal Conn2_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Conn2_BVALID : STD_LOGIC;
  signal Conn2_RDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal Conn2_RID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_RLAST : STD_LOGIC;
  signal Conn2_RREADY : STD_LOGIC;
  signal Conn2_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Conn2_RVALID : STD_LOGIC;
  signal Conn2_WDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal Conn2_WLAST : STD_LOGIC;
  signal Conn2_WREADY : STD_LOGIC;
  signal Conn2_WSTRB : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn2_WVALID : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_ARADDR : STD_LOGIC_VECTOR ( 30 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axi_interconnect_ddr_M00_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_ARREADY : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_ARVALID : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_AWADDR : STD_LOGIC_VECTOR ( 30 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axi_interconnect_ddr_M00_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_AWREADY : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_AWVALID : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_BREADY : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_BVALID : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_RDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_RLAST : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_RREADY : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_RVALID : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_WDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_WLAST : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_WREADY : STD_LOGIC;
  signal axi_interconnect_ddr_M00_AXI_WSTRB : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_interconnect_ddr_M00_AXI_WVALID : STD_LOGIC;
  signal ddr4_0_c0_ddr4_ui_clk : STD_LOGIC;
  signal ddr4_0_c0_ddr4_ui_clk_sync_rst : STD_LOGIC;
  signal ddr4_0_c0_init_calib_complete : STD_LOGIC;
  signal pi_ddr4_sys_clk_1 : STD_LOGIC;
  signal pi_s_axi4_pcie_aclk_1 : STD_LOGIC;
  signal s_axi_pcie_dma_1_ARADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal s_axi_pcie_dma_1_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s_axi_pcie_dma_1_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s_axi_pcie_dma_1_ARID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s_axi_pcie_dma_1_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s_axi_pcie_dma_1_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal s_axi_pcie_dma_1_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal s_axi_pcie_dma_1_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s_axi_pcie_dma_1_ARREADY : STD_LOGIC;
  signal s_axi_pcie_dma_1_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal s_axi_pcie_dma_1_ARUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal s_axi_pcie_dma_1_ARVALID : STD_LOGIC;
  signal s_axi_pcie_dma_1_AWADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal s_axi_pcie_dma_1_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s_axi_pcie_dma_1_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s_axi_pcie_dma_1_AWID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s_axi_pcie_dma_1_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal s_axi_pcie_dma_1_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal s_axi_pcie_dma_1_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal s_axi_pcie_dma_1_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal s_axi_pcie_dma_1_AWREADY : STD_LOGIC;
  signal s_axi_pcie_dma_1_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal s_axi_pcie_dma_1_AWUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal s_axi_pcie_dma_1_AWVALID : STD_LOGIC;
  signal s_axi_pcie_dma_1_BID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s_axi_pcie_dma_1_BREADY : STD_LOGIC;
  signal s_axi_pcie_dma_1_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s_axi_pcie_dma_1_BUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal s_axi_pcie_dma_1_BVALID : STD_LOGIC;
  signal s_axi_pcie_dma_1_RDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal s_axi_pcie_dma_1_RID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s_axi_pcie_dma_1_RLAST : STD_LOGIC;
  signal s_axi_pcie_dma_1_RREADY : STD_LOGIC;
  signal s_axi_pcie_dma_1_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal s_axi_pcie_dma_1_RUSER : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal s_axi_pcie_dma_1_RVALID : STD_LOGIC;
  signal s_axi_pcie_dma_1_WDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal s_axi_pcie_dma_1_WLAST : STD_LOGIC;
  signal s_axi_pcie_dma_1_WREADY : STD_LOGIC;
  signal s_axi_pcie_dma_1_WSTRB : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axi_pcie_dma_1_WUSER : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal s_axi_pcie_dma_1_WVALID : STD_LOGIC;
  signal sys_reset_0_interconnect_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal sys_reset_0_peripheral_aresetn : STD_LOGIC_VECTOR ( 0 to 0 );
  signal xlconstant_0_dout : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_ddr4_0_dbg_clk_UNCONNECTED : STD_LOGIC;
  signal NLW_ddr4_0_c0_ddr4_s_axi_bid_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_ddr4_0_c0_ddr4_s_axi_rid_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_ddr4_0_dbg_bus_UNCONNECTED : STD_LOGIC_VECTOR ( 511 downto 0 );
  signal NLW_sys_reset_0_mb_reset_UNCONNECTED : STD_LOGIC;
  signal NLW_sys_reset_0_bus_struct_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_sys_reset_0_peripheral_reset_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
begin
  Conn2_ARADDR(31 downto 0) <= p_s_axi4_ddr_araddr(31 downto 0);
  Conn2_ARBURST(1 downto 0) <= p_s_axi4_ddr_arburst(1 downto 0);
  Conn2_ARCACHE(3 downto 0) <= p_s_axi4_ddr_arcache(3 downto 0);
  Conn2_ARID(3 downto 0) <= p_s_axi4_ddr_arid(3 downto 0);
  Conn2_ARLEN(7 downto 0) <= p_s_axi4_ddr_arlen(7 downto 0);
  Conn2_ARLOCK(0) <= p_s_axi4_ddr_arlock(0);
  Conn2_ARPROT(2 downto 0) <= p_s_axi4_ddr_arprot(2 downto 0);
  Conn2_ARQOS(3 downto 0) <= p_s_axi4_ddr_arqos(3 downto 0);
  Conn2_ARSIZE(2 downto 0) <= p_s_axi4_ddr_arsize(2 downto 0);
  Conn2_ARVALID <= p_s_axi4_ddr_arvalid;
  Conn2_AWADDR(31 downto 0) <= p_s_axi4_ddr_awaddr(31 downto 0);
  Conn2_AWBURST(1 downto 0) <= p_s_axi4_ddr_awburst(1 downto 0);
  Conn2_AWCACHE(3 downto 0) <= p_s_axi4_ddr_awcache(3 downto 0);
  Conn2_AWID(3 downto 0) <= p_s_axi4_ddr_awid(3 downto 0);
  Conn2_AWLEN(7 downto 0) <= p_s_axi4_ddr_awlen(7 downto 0);
  Conn2_AWLOCK(0) <= p_s_axi4_ddr_awlock(0);
  Conn2_AWPROT(2 downto 0) <= p_s_axi4_ddr_awprot(2 downto 0);
  Conn2_AWQOS(3 downto 0) <= p_s_axi4_ddr_awqos(3 downto 0);
  Conn2_AWSIZE(2 downto 0) <= p_s_axi4_ddr_awsize(2 downto 0);
  Conn2_AWVALID <= p_s_axi4_ddr_awvalid;
  Conn2_BREADY <= p_s_axi4_ddr_bready;
  Conn2_RREADY <= p_s_axi4_ddr_rready;
  Conn2_WDATA(255 downto 0) <= p_s_axi4_ddr_wdata(255 downto 0);
  Conn2_WLAST <= p_s_axi4_ddr_wlast;
  Conn2_WSTRB(31 downto 0) <= p_s_axi4_ddr_wstrb(31 downto 0);
  Conn2_WVALID <= p_s_axi4_ddr_wvalid;
  p_ddr4_act_n <= Conn1_ACT_N;
  p_ddr4_adr(16 downto 0) <= Conn1_ADR(16 downto 0);
  p_ddr4_ba(1 downto 0) <= Conn1_BA(1 downto 0);
  p_ddr4_bg(0) <= Conn1_BG(0);
  p_ddr4_ck_c(0) <= Conn1_CK_C(0);
  p_ddr4_ck_t(0) <= Conn1_CK_T(0);
  p_ddr4_cke(0) <= Conn1_CKE(0);
  p_ddr4_cs_n(0) <= Conn1_CS_N(0);
  p_ddr4_odt(0) <= Conn1_ODT(0);
  p_ddr4_reset_n <= Conn1_RESET_N;
  p_s_axi4_ddr_arready <= Conn2_ARREADY;
  p_s_axi4_ddr_awready <= Conn2_AWREADY;
  p_s_axi4_ddr_bid(3 downto 0) <= Conn2_BID(3 downto 0);
  p_s_axi4_ddr_bresp(1 downto 0) <= Conn2_BRESP(1 downto 0);
  p_s_axi4_ddr_bvalid <= Conn2_BVALID;
  p_s_axi4_ddr_rdata(255 downto 0) <= Conn2_RDATA(255 downto 0);
  p_s_axi4_ddr_rid(3 downto 0) <= Conn2_RID(3 downto 0);
  p_s_axi4_ddr_rlast <= Conn2_RLAST;
  p_s_axi4_ddr_rresp(1 downto 0) <= Conn2_RRESP(1 downto 0);
  p_s_axi4_ddr_rvalid <= Conn2_RVALID;
  p_s_axi4_ddr_wready <= Conn2_WREADY;
  pi_ddr4_sys_clk_1 <= pi_ddr4_sys_clk;
  pi_s_axi4_pcie_aclk_1 <= pi_s_axi4_pcie_aclk;
  po_ddr_calib_done <= ddr4_0_c0_init_calib_complete;
  po_s_axi4_ddr_aclk <= ddr4_0_c0_ddr4_ui_clk;
  po_s_axi4_ddr_areset_n(0) <= sys_reset_0_interconnect_aresetn(0);
  s_axi_pcie_dma_1_ARADDR(63 downto 0) <= s_axi_pcie_dma_araddr(63 downto 0);
  s_axi_pcie_dma_1_ARBURST(1 downto 0) <= s_axi_pcie_dma_arburst(1 downto 0);
  s_axi_pcie_dma_1_ARCACHE(3 downto 0) <= s_axi_pcie_dma_arcache(3 downto 0);
  s_axi_pcie_dma_1_ARID(1 downto 0) <= s_axi_pcie_dma_arid(1 downto 0);
  s_axi_pcie_dma_1_ARLEN(7 downto 0) <= s_axi_pcie_dma_arlen(7 downto 0);
  s_axi_pcie_dma_1_ARLOCK(0) <= s_axi_pcie_dma_arlock(0);
  s_axi_pcie_dma_1_ARPROT(2 downto 0) <= s_axi_pcie_dma_arprot(2 downto 0);
  s_axi_pcie_dma_1_ARQOS(3 downto 0) <= s_axi_pcie_dma_arqos(3 downto 0);
  s_axi_pcie_dma_1_ARSIZE(2 downto 0) <= s_axi_pcie_dma_arsize(2 downto 0);
  s_axi_pcie_dma_1_ARUSER(113 downto 0) <= s_axi_pcie_dma_aruser(113 downto 0);
  s_axi_pcie_dma_1_ARVALID <= s_axi_pcie_dma_arvalid;
  s_axi_pcie_dma_1_AWADDR(63 downto 0) <= s_axi_pcie_dma_awaddr(63 downto 0);
  s_axi_pcie_dma_1_AWBURST(1 downto 0) <= s_axi_pcie_dma_awburst(1 downto 0);
  s_axi_pcie_dma_1_AWCACHE(3 downto 0) <= s_axi_pcie_dma_awcache(3 downto 0);
  s_axi_pcie_dma_1_AWID(1 downto 0) <= s_axi_pcie_dma_awid(1 downto 0);
  s_axi_pcie_dma_1_AWLEN(7 downto 0) <= s_axi_pcie_dma_awlen(7 downto 0);
  s_axi_pcie_dma_1_AWLOCK(0) <= s_axi_pcie_dma_awlock(0);
  s_axi_pcie_dma_1_AWPROT(2 downto 0) <= s_axi_pcie_dma_awprot(2 downto 0);
  s_axi_pcie_dma_1_AWQOS(3 downto 0) <= s_axi_pcie_dma_awqos(3 downto 0);
  s_axi_pcie_dma_1_AWSIZE(2 downto 0) <= s_axi_pcie_dma_awsize(2 downto 0);
  s_axi_pcie_dma_1_AWUSER(113 downto 0) <= s_axi_pcie_dma_awuser(113 downto 0);
  s_axi_pcie_dma_1_AWVALID <= s_axi_pcie_dma_awvalid;
  s_axi_pcie_dma_1_BREADY <= s_axi_pcie_dma_bready;
  s_axi_pcie_dma_1_RREADY <= s_axi_pcie_dma_rready;
  s_axi_pcie_dma_1_WDATA(255 downto 0) <= s_axi_pcie_dma_wdata(255 downto 0);
  s_axi_pcie_dma_1_WLAST <= s_axi_pcie_dma_wlast;
  s_axi_pcie_dma_1_WSTRB(31 downto 0) <= s_axi_pcie_dma_wstrb(31 downto 0);
  s_axi_pcie_dma_1_WUSER(13 downto 0) <= s_axi_pcie_dma_wuser(13 downto 0);
  s_axi_pcie_dma_1_WVALID <= s_axi_pcie_dma_wvalid;
  s_axi_pcie_dma_arready <= s_axi_pcie_dma_1_ARREADY;
  s_axi_pcie_dma_awready <= s_axi_pcie_dma_1_AWREADY;
  s_axi_pcie_dma_bid(1 downto 0) <= s_axi_pcie_dma_1_BID(1 downto 0);
  s_axi_pcie_dma_bresp(1 downto 0) <= s_axi_pcie_dma_1_BRESP(1 downto 0);
  s_axi_pcie_dma_buser(113 downto 0) <= s_axi_pcie_dma_1_BUSER(113 downto 0);
  s_axi_pcie_dma_bvalid <= s_axi_pcie_dma_1_BVALID;
  s_axi_pcie_dma_rdata(255 downto 0) <= s_axi_pcie_dma_1_RDATA(255 downto 0);
  s_axi_pcie_dma_rid(1 downto 0) <= s_axi_pcie_dma_1_RID(1 downto 0);
  s_axi_pcie_dma_rlast <= s_axi_pcie_dma_1_RLAST;
  s_axi_pcie_dma_rresp(1 downto 0) <= s_axi_pcie_dma_1_RRESP(1 downto 0);
  s_axi_pcie_dma_ruser(13 downto 0) <= s_axi_pcie_dma_1_RUSER(13 downto 0);
  s_axi_pcie_dma_rvalid <= s_axi_pcie_dma_1_RVALID;
  s_axi_pcie_dma_wready <= s_axi_pcie_dma_1_WREADY;
axi_interconnect_ddr: component sis8300ku_bsp_system_axi_interconnect_ddr_0
     port map (
      M00_AXI_araddr(30 downto 0) => axi_interconnect_ddr_M00_AXI_ARADDR(30 downto 0),
      M00_AXI_arburst(1 downto 0) => axi_interconnect_ddr_M00_AXI_ARBURST(1 downto 0),
      M00_AXI_arcache(3 downto 0) => axi_interconnect_ddr_M00_AXI_ARCACHE(3 downto 0),
      M00_AXI_arlen(7 downto 0) => axi_interconnect_ddr_M00_AXI_ARLEN(7 downto 0),
      M00_AXI_arlock(0) => axi_interconnect_ddr_M00_AXI_ARLOCK(0),
      M00_AXI_arprot(2 downto 0) => axi_interconnect_ddr_M00_AXI_ARPROT(2 downto 0),
      M00_AXI_arqos(3 downto 0) => axi_interconnect_ddr_M00_AXI_ARQOS(3 downto 0),
      M00_AXI_arready => axi_interconnect_ddr_M00_AXI_ARREADY,
      M00_AXI_arsize(2 downto 0) => axi_interconnect_ddr_M00_AXI_ARSIZE(2 downto 0),
      M00_AXI_arvalid => axi_interconnect_ddr_M00_AXI_ARVALID,
      M00_AXI_awaddr(30 downto 0) => axi_interconnect_ddr_M00_AXI_AWADDR(30 downto 0),
      M00_AXI_awburst(1 downto 0) => axi_interconnect_ddr_M00_AXI_AWBURST(1 downto 0),
      M00_AXI_awcache(3 downto 0) => axi_interconnect_ddr_M00_AXI_AWCACHE(3 downto 0),
      M00_AXI_awlen(7 downto 0) => axi_interconnect_ddr_M00_AXI_AWLEN(7 downto 0),
      M00_AXI_awlock(0) => axi_interconnect_ddr_M00_AXI_AWLOCK(0),
      M00_AXI_awprot(2 downto 0) => axi_interconnect_ddr_M00_AXI_AWPROT(2 downto 0),
      M00_AXI_awqos(3 downto 0) => axi_interconnect_ddr_M00_AXI_AWQOS(3 downto 0),
      M00_AXI_awready => axi_interconnect_ddr_M00_AXI_AWREADY,
      M00_AXI_awsize(2 downto 0) => axi_interconnect_ddr_M00_AXI_AWSIZE(2 downto 0),
      M00_AXI_awvalid => axi_interconnect_ddr_M00_AXI_AWVALID,
      M00_AXI_bready => axi_interconnect_ddr_M00_AXI_BREADY,
      M00_AXI_bresp(1 downto 0) => axi_interconnect_ddr_M00_AXI_BRESP(1 downto 0),
      M00_AXI_bvalid => axi_interconnect_ddr_M00_AXI_BVALID,
      M00_AXI_rdata(255 downto 0) => axi_interconnect_ddr_M00_AXI_RDATA(255 downto 0),
      M00_AXI_rlast => axi_interconnect_ddr_M00_AXI_RLAST,
      M00_AXI_rready => axi_interconnect_ddr_M00_AXI_RREADY,
      M00_AXI_rresp(1 downto 0) => axi_interconnect_ddr_M00_AXI_RRESP(1 downto 0),
      M00_AXI_rvalid => axi_interconnect_ddr_M00_AXI_RVALID,
      M00_AXI_wdata(255 downto 0) => axi_interconnect_ddr_M00_AXI_WDATA(255 downto 0),
      M00_AXI_wlast => axi_interconnect_ddr_M00_AXI_WLAST,
      M00_AXI_wready => axi_interconnect_ddr_M00_AXI_WREADY,
      M00_AXI_wstrb(31 downto 0) => axi_interconnect_ddr_M00_AXI_WSTRB(31 downto 0),
      M00_AXI_wvalid => axi_interconnect_ddr_M00_AXI_WVALID,
      S00_AXI_araddr(31 downto 0) => Conn2_ARADDR(31 downto 0),
      S00_AXI_arburst(1 downto 0) => Conn2_ARBURST(1 downto 0),
      S00_AXI_arcache(3 downto 0) => Conn2_ARCACHE(3 downto 0),
      S00_AXI_arid(3 downto 0) => Conn2_ARID(3 downto 0),
      S00_AXI_arlen(7 downto 0) => Conn2_ARLEN(7 downto 0),
      S00_AXI_arlock(0) => Conn2_ARLOCK(0),
      S00_AXI_arprot(2 downto 0) => Conn2_ARPROT(2 downto 0),
      S00_AXI_arqos(3 downto 0) => Conn2_ARQOS(3 downto 0),
      S00_AXI_arready => Conn2_ARREADY,
      S00_AXI_arsize(2 downto 0) => Conn2_ARSIZE(2 downto 0),
      S00_AXI_arvalid => Conn2_ARVALID,
      S00_AXI_awaddr(31 downto 0) => Conn2_AWADDR(31 downto 0),
      S00_AXI_awburst(1 downto 0) => Conn2_AWBURST(1 downto 0),
      S00_AXI_awcache(3 downto 0) => Conn2_AWCACHE(3 downto 0),
      S00_AXI_awid(3 downto 0) => Conn2_AWID(3 downto 0),
      S00_AXI_awlen(7 downto 0) => Conn2_AWLEN(7 downto 0),
      S00_AXI_awlock(0) => Conn2_AWLOCK(0),
      S00_AXI_awprot(2 downto 0) => Conn2_AWPROT(2 downto 0),
      S00_AXI_awqos(3 downto 0) => Conn2_AWQOS(3 downto 0),
      S00_AXI_awready => Conn2_AWREADY,
      S00_AXI_awsize(2 downto 0) => Conn2_AWSIZE(2 downto 0),
      S00_AXI_awvalid => Conn2_AWVALID,
      S00_AXI_bid(3 downto 0) => Conn2_BID(3 downto 0),
      S00_AXI_bready => Conn2_BREADY,
      S00_AXI_bresp(1 downto 0) => Conn2_BRESP(1 downto 0),
      S00_AXI_bvalid => Conn2_BVALID,
      S00_AXI_rdata(255 downto 0) => Conn2_RDATA(255 downto 0),
      S00_AXI_rid(3 downto 0) => Conn2_RID(3 downto 0),
      S00_AXI_rlast => Conn2_RLAST,
      S00_AXI_rready => Conn2_RREADY,
      S00_AXI_rresp(1 downto 0) => Conn2_RRESP(1 downto 0),
      S00_AXI_rvalid => Conn2_RVALID,
      S00_AXI_wdata(255 downto 0) => Conn2_WDATA(255 downto 0),
      S00_AXI_wlast => Conn2_WLAST,
      S00_AXI_wready => Conn2_WREADY,
      S00_AXI_wstrb(31 downto 0) => Conn2_WSTRB(31 downto 0),
      S00_AXI_wvalid => Conn2_WVALID,
      S01_AXI_araddr(63 downto 0) => s_axi_pcie_dma_1_ARADDR(63 downto 0),
      S01_AXI_arburst(1 downto 0) => s_axi_pcie_dma_1_ARBURST(1 downto 0),
      S01_AXI_arcache(3 downto 0) => s_axi_pcie_dma_1_ARCACHE(3 downto 0),
      S01_AXI_arid(1 downto 0) => s_axi_pcie_dma_1_ARID(1 downto 0),
      S01_AXI_arlen(7 downto 0) => s_axi_pcie_dma_1_ARLEN(7 downto 0),
      S01_AXI_arlock(0) => s_axi_pcie_dma_1_ARLOCK(0),
      S01_AXI_arprot(2 downto 0) => s_axi_pcie_dma_1_ARPROT(2 downto 0),
      S01_AXI_arqos(3 downto 0) => s_axi_pcie_dma_1_ARQOS(3 downto 0),
      S01_AXI_arready => s_axi_pcie_dma_1_ARREADY,
      S01_AXI_arsize(2 downto 0) => s_axi_pcie_dma_1_ARSIZE(2 downto 0),
      S01_AXI_aruser(113 downto 0) => s_axi_pcie_dma_1_ARUSER(113 downto 0),
      S01_AXI_arvalid => s_axi_pcie_dma_1_ARVALID,
      S01_AXI_awaddr(63 downto 0) => s_axi_pcie_dma_1_AWADDR(63 downto 0),
      S01_AXI_awburst(1 downto 0) => s_axi_pcie_dma_1_AWBURST(1 downto 0),
      S01_AXI_awcache(3 downto 0) => s_axi_pcie_dma_1_AWCACHE(3 downto 0),
      S01_AXI_awid(1 downto 0) => s_axi_pcie_dma_1_AWID(1 downto 0),
      S01_AXI_awlen(7 downto 0) => s_axi_pcie_dma_1_AWLEN(7 downto 0),
      S01_AXI_awlock(0) => s_axi_pcie_dma_1_AWLOCK(0),
      S01_AXI_awprot(2 downto 0) => s_axi_pcie_dma_1_AWPROT(2 downto 0),
      S01_AXI_awqos(3 downto 0) => s_axi_pcie_dma_1_AWQOS(3 downto 0),
      S01_AXI_awready => s_axi_pcie_dma_1_AWREADY,
      S01_AXI_awsize(2 downto 0) => s_axi_pcie_dma_1_AWSIZE(2 downto 0),
      S01_AXI_awuser(113 downto 0) => s_axi_pcie_dma_1_AWUSER(113 downto 0),
      S01_AXI_awvalid => s_axi_pcie_dma_1_AWVALID,
      S01_AXI_bid(1 downto 0) => s_axi_pcie_dma_1_BID(1 downto 0),
      S01_AXI_bready => s_axi_pcie_dma_1_BREADY,
      S01_AXI_bresp(1 downto 0) => s_axi_pcie_dma_1_BRESP(1 downto 0),
      S01_AXI_buser(113 downto 0) => s_axi_pcie_dma_1_BUSER(113 downto 0),
      S01_AXI_bvalid => s_axi_pcie_dma_1_BVALID,
      S01_AXI_rdata(255 downto 0) => s_axi_pcie_dma_1_RDATA(255 downto 0),
      S01_AXI_rid(1 downto 0) => s_axi_pcie_dma_1_RID(1 downto 0),
      S01_AXI_rlast => s_axi_pcie_dma_1_RLAST,
      S01_AXI_rready => s_axi_pcie_dma_1_RREADY,
      S01_AXI_rresp(1 downto 0) => s_axi_pcie_dma_1_RRESP(1 downto 0),
      S01_AXI_ruser(13 downto 0) => s_axi_pcie_dma_1_RUSER(13 downto 0),
      S01_AXI_rvalid => s_axi_pcie_dma_1_RVALID,
      S01_AXI_wdata(255 downto 0) => s_axi_pcie_dma_1_WDATA(255 downto 0),
      S01_AXI_wlast => s_axi_pcie_dma_1_WLAST,
      S01_AXI_wready => s_axi_pcie_dma_1_WREADY,
      S01_AXI_wstrb(31 downto 0) => s_axi_pcie_dma_1_WSTRB(31 downto 0),
      S01_AXI_wuser(13 downto 0) => s_axi_pcie_dma_1_WUSER(13 downto 0),
      S01_AXI_wvalid => s_axi_pcie_dma_1_WVALID,
      aclk => ddr4_0_c0_ddr4_ui_clk,
      aclk1 => pi_s_axi4_pcie_aclk_1,
      aresetn => sys_reset_0_interconnect_aresetn(0)
    );
ddr4_0: component sis8300ku_bsp_system_ddr4_0_0
     port map (
      c0_ddr4_act_n => Conn1_ACT_N,
      c0_ddr4_adr(16 downto 0) => Conn1_ADR(16 downto 0),
      c0_ddr4_aresetn => sys_reset_0_peripheral_aresetn(0),
      c0_ddr4_ba(1 downto 0) => Conn1_BA(1 downto 0),
      c0_ddr4_bg(0) => Conn1_BG(0),
      c0_ddr4_ck_c(0) => Conn1_CK_C(0),
      c0_ddr4_ck_t(0) => Conn1_CK_T(0),
      c0_ddr4_cke(0) => Conn1_CKE(0),
      c0_ddr4_cs_n(0) => Conn1_CS_N(0),
      c0_ddr4_dm_dbi_n(7 downto 0) => p_ddr4_dm_n(7 downto 0),
      c0_ddr4_dq(63 downto 0) => p_ddr4_dq(63 downto 0),
      c0_ddr4_dqs_c(7 downto 0) => p_ddr4_dqs_c(7 downto 0),
      c0_ddr4_dqs_t(7 downto 0) => p_ddr4_dqs_t(7 downto 0),
      c0_ddr4_odt(0) => Conn1_ODT(0),
      c0_ddr4_reset_n => Conn1_RESET_N,
      c0_ddr4_s_axi_araddr(30 downto 0) => axi_interconnect_ddr_M00_AXI_ARADDR(30 downto 0),
      c0_ddr4_s_axi_arburst(1 downto 0) => axi_interconnect_ddr_M00_AXI_ARBURST(1 downto 0),
      c0_ddr4_s_axi_arcache(3 downto 0) => axi_interconnect_ddr_M00_AXI_ARCACHE(3 downto 0),
      c0_ddr4_s_axi_arid(0) => '0',
      c0_ddr4_s_axi_arlen(7 downto 0) => axi_interconnect_ddr_M00_AXI_ARLEN(7 downto 0),
      c0_ddr4_s_axi_arlock(0) => axi_interconnect_ddr_M00_AXI_ARLOCK(0),
      c0_ddr4_s_axi_arprot(2 downto 0) => axi_interconnect_ddr_M00_AXI_ARPROT(2 downto 0),
      c0_ddr4_s_axi_arqos(3 downto 0) => axi_interconnect_ddr_M00_AXI_ARQOS(3 downto 0),
      c0_ddr4_s_axi_arready => axi_interconnect_ddr_M00_AXI_ARREADY,
      c0_ddr4_s_axi_arsize(2 downto 0) => axi_interconnect_ddr_M00_AXI_ARSIZE(2 downto 0),
      c0_ddr4_s_axi_arvalid => axi_interconnect_ddr_M00_AXI_ARVALID,
      c0_ddr4_s_axi_awaddr(30 downto 0) => axi_interconnect_ddr_M00_AXI_AWADDR(30 downto 0),
      c0_ddr4_s_axi_awburst(1 downto 0) => axi_interconnect_ddr_M00_AXI_AWBURST(1 downto 0),
      c0_ddr4_s_axi_awcache(3 downto 0) => axi_interconnect_ddr_M00_AXI_AWCACHE(3 downto 0),
      c0_ddr4_s_axi_awid(0) => '0',
      c0_ddr4_s_axi_awlen(7 downto 0) => axi_interconnect_ddr_M00_AXI_AWLEN(7 downto 0),
      c0_ddr4_s_axi_awlock(0) => axi_interconnect_ddr_M00_AXI_AWLOCK(0),
      c0_ddr4_s_axi_awprot(2 downto 0) => axi_interconnect_ddr_M00_AXI_AWPROT(2 downto 0),
      c0_ddr4_s_axi_awqos(3 downto 0) => axi_interconnect_ddr_M00_AXI_AWQOS(3 downto 0),
      c0_ddr4_s_axi_awready => axi_interconnect_ddr_M00_AXI_AWREADY,
      c0_ddr4_s_axi_awsize(2 downto 0) => axi_interconnect_ddr_M00_AXI_AWSIZE(2 downto 0),
      c0_ddr4_s_axi_awvalid => axi_interconnect_ddr_M00_AXI_AWVALID,
      c0_ddr4_s_axi_bid(0) => NLW_ddr4_0_c0_ddr4_s_axi_bid_UNCONNECTED(0),
      c0_ddr4_s_axi_bready => axi_interconnect_ddr_M00_AXI_BREADY,
      c0_ddr4_s_axi_bresp(1 downto 0) => axi_interconnect_ddr_M00_AXI_BRESP(1 downto 0),
      c0_ddr4_s_axi_bvalid => axi_interconnect_ddr_M00_AXI_BVALID,
      c0_ddr4_s_axi_rdata(255 downto 0) => axi_interconnect_ddr_M00_AXI_RDATA(255 downto 0),
      c0_ddr4_s_axi_rid(0) => NLW_ddr4_0_c0_ddr4_s_axi_rid_UNCONNECTED(0),
      c0_ddr4_s_axi_rlast => axi_interconnect_ddr_M00_AXI_RLAST,
      c0_ddr4_s_axi_rready => axi_interconnect_ddr_M00_AXI_RREADY,
      c0_ddr4_s_axi_rresp(1 downto 0) => axi_interconnect_ddr_M00_AXI_RRESP(1 downto 0),
      c0_ddr4_s_axi_rvalid => axi_interconnect_ddr_M00_AXI_RVALID,
      c0_ddr4_s_axi_wdata(255 downto 0) => axi_interconnect_ddr_M00_AXI_WDATA(255 downto 0),
      c0_ddr4_s_axi_wlast => axi_interconnect_ddr_M00_AXI_WLAST,
      c0_ddr4_s_axi_wready => axi_interconnect_ddr_M00_AXI_WREADY,
      c0_ddr4_s_axi_wstrb(31 downto 0) => axi_interconnect_ddr_M00_AXI_WSTRB(31 downto 0),
      c0_ddr4_s_axi_wvalid => axi_interconnect_ddr_M00_AXI_WVALID,
      c0_ddr4_ui_clk => ddr4_0_c0_ddr4_ui_clk,
      c0_ddr4_ui_clk_sync_rst => ddr4_0_c0_ddr4_ui_clk_sync_rst,
      c0_init_calib_complete => ddr4_0_c0_init_calib_complete,
      c0_sys_clk_i => pi_ddr4_sys_clk_1,
      dbg_bus(511 downto 0) => NLW_ddr4_0_dbg_bus_UNCONNECTED(511 downto 0),
      dbg_clk => NLW_ddr4_0_dbg_clk_UNCONNECTED,
      sys_rst => xlconstant_0_dout(0)
    );
sys_reset_0: component sis8300ku_bsp_system_sys_reset_0_0
     port map (
      aux_reset_in => '1',
      bus_struct_reset(0) => NLW_sys_reset_0_bus_struct_reset_UNCONNECTED(0),
      dcm_locked => '1',
      ext_reset_in => ddr4_0_c0_ddr4_ui_clk_sync_rst,
      interconnect_aresetn(0) => sys_reset_0_interconnect_aresetn(0),
      mb_debug_sys_rst => '0',
      mb_reset => NLW_sys_reset_0_mb_reset_UNCONNECTED,
      peripheral_aresetn(0) => sys_reset_0_peripheral_aresetn(0),
      peripheral_reset(0) => NLW_sys_reset_0_peripheral_reset_UNCONNECTED(0),
      slowest_sync_clk => ddr4_0_c0_ddr4_ui_clk
    );
xlconstant_0: component sis8300ku_bsp_system_xlconstant_0_0
     port map (
      dout(0) => xlconstant_0_dout(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity pcie_imp_P1MTX3 is
  port (
    m_axi_dma_ddr_araddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_dma_ddr_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_dma_ddr_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_dma_ddr_arid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_dma_ddr_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_dma_ddr_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axi_dma_ddr_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_dma_ddr_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_dma_ddr_arready : in STD_LOGIC;
    m_axi_dma_ddr_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_dma_ddr_aruser : out STD_LOGIC_VECTOR ( 113 downto 0 );
    m_axi_dma_ddr_arvalid : out STD_LOGIC;
    m_axi_dma_ddr_awaddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_dma_ddr_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_dma_ddr_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_dma_ddr_awid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_dma_ddr_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_dma_ddr_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    m_axi_dma_ddr_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_dma_ddr_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_dma_ddr_awready : in STD_LOGIC;
    m_axi_dma_ddr_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_dma_ddr_awuser : out STD_LOGIC_VECTOR ( 113 downto 0 );
    m_axi_dma_ddr_awvalid : out STD_LOGIC;
    m_axi_dma_ddr_bid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_dma_ddr_bready : out STD_LOGIC;
    m_axi_dma_ddr_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_dma_ddr_buser : in STD_LOGIC_VECTOR ( 113 downto 0 );
    m_axi_dma_ddr_bvalid : in STD_LOGIC;
    m_axi_dma_ddr_rdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    m_axi_dma_ddr_rid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_dma_ddr_rlast : in STD_LOGIC;
    m_axi_dma_ddr_rready : out STD_LOGIC;
    m_axi_dma_ddr_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_dma_ddr_ruser : in STD_LOGIC_VECTOR ( 13 downto 0 );
    m_axi_dma_ddr_rvalid : in STD_LOGIC;
    m_axi_dma_ddr_wdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    m_axi_dma_ddr_wlast : out STD_LOGIC;
    m_axi_dma_ddr_wready : in STD_LOGIC;
    m_axi_dma_ddr_wstrb : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_dma_ddr_wuser : out STD_LOGIC_VECTOR ( 13 downto 0 );
    m_axi_dma_ddr_wvalid : out STD_LOGIC;
    p_m_axi4l_app_araddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_app_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_app_arready : in STD_LOGIC;
    p_m_axi4l_app_arvalid : out STD_LOGIC;
    p_m_axi4l_app_awaddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_app_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_app_awready : in STD_LOGIC;
    p_m_axi4l_app_awvalid : out STD_LOGIC;
    p_m_axi4l_app_bready : out STD_LOGIC;
    p_m_axi4l_app_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_app_bvalid : in STD_LOGIC;
    p_m_axi4l_app_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_app_rready : out STD_LOGIC;
    p_m_axi4l_app_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_app_rvalid : in STD_LOGIC;
    p_m_axi4l_app_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_app_wready : in STD_LOGIC;
    p_m_axi4l_app_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_m_axi4l_app_wvalid : out STD_LOGIC;
    p_m_axi4l_bsp_araddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_bsp_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_bsp_arready : in STD_LOGIC;
    p_m_axi4l_bsp_arvalid : out STD_LOGIC;
    p_m_axi4l_bsp_awaddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_bsp_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_bsp_awready : in STD_LOGIC;
    p_m_axi4l_bsp_awvalid : out STD_LOGIC;
    p_m_axi4l_bsp_bready : out STD_LOGIC;
    p_m_axi4l_bsp_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_bsp_bvalid : in STD_LOGIC;
    p_m_axi4l_bsp_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_bsp_rready : out STD_LOGIC;
    p_m_axi4l_bsp_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_bsp_rvalid : in STD_LOGIC;
    p_m_axi4l_bsp_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_bsp_wready : in STD_LOGIC;
    p_m_axi4l_bsp_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_m_axi4l_bsp_wvalid : out STD_LOGIC;
    p_pcie_mgt_rxn : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_pcie_mgt_rxp : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_pcie_mgt_txn : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_pcie_mgt_txp : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pi_m_axi4l_app_aclk : in STD_LOGIC;
    pi_pcie_areset_n : in STD_LOGIC;
    pi_pcie_irq_req : in STD_LOGIC_VECTOR ( 15 downto 0 );
    pi_pcie_sys_clk : in STD_LOGIC;
    pi_pcie_sys_clk_gt : in STD_LOGIC;
    po_m_axi4_aclk : out STD_LOGIC;
    po_m_axi4_areset_n : out STD_LOGIC;
    po_pcie_irq_ack : out STD_LOGIC_VECTOR ( 15 downto 0 );
    po_pcie_link_up : out STD_LOGIC
  );
end pcie_imp_P1MTX3;

architecture STRUCTURE of pcie_imp_P1MTX3 is
  component sis8300ku_bsp_system_xdma_0_0 is
  port (
    sys_clk : in STD_LOGIC;
    sys_clk_gt : in STD_LOGIC;
    sys_rst_n : in STD_LOGIC;
    user_lnk_up : out STD_LOGIC;
    pci_exp_txp : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pci_exp_txn : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pci_exp_rxp : in STD_LOGIC_VECTOR ( 3 downto 0 );
    pci_exp_rxn : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi_aclk : out STD_LOGIC;
    axi_aresetn : out STD_LOGIC;
    usr_irq_req : in STD_LOGIC_VECTOR ( 15 downto 0 );
    usr_irq_ack : out STD_LOGIC_VECTOR ( 15 downto 0 );
    msi_enable : out STD_LOGIC;
    msi_vector_width : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awready : in STD_LOGIC;
    m_axi_wready : in STD_LOGIC;
    m_axi_bid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_bvalid : in STD_LOGIC;
    m_axi_arready : in STD_LOGIC;
    m_axi_rid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_rdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_rlast : in STD_LOGIC;
    m_axi_rvalid : in STD_LOGIC;
    m_axi_awid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_awaddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_awvalid : out STD_LOGIC;
    m_axi_awlock : out STD_LOGIC;
    m_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_wdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m_axi_wstrb : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axi_wlast : out STD_LOGIC;
    m_axi_wvalid : out STD_LOGIC;
    m_axi_bready : out STD_LOGIC;
    m_axi_arid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_araddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    m_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_arvalid : out STD_LOGIC;
    m_axi_arlock : out STD_LOGIC;
    m_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_rready : out STD_LOGIC;
    m_axil_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axil_awvalid : out STD_LOGIC;
    m_axil_awready : in STD_LOGIC;
    m_axil_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axil_wvalid : out STD_LOGIC;
    m_axil_wready : in STD_LOGIC;
    m_axil_bvalid : in STD_LOGIC;
    m_axil_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axil_bready : out STD_LOGIC;
    m_axil_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axil_arvalid : out STD_LOGIC;
    m_axil_arready : in STD_LOGIC;
    m_axil_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axil_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axil_rvalid : in STD_LOGIC;
    m_axil_rready : out STD_LOGIC;
    cfg_mgmt_addr : in STD_LOGIC_VECTOR ( 18 downto 0 );
    cfg_mgmt_write : in STD_LOGIC;
    cfg_mgmt_write_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_mgmt_byte_enable : in STD_LOGIC_VECTOR ( 3 downto 0 );
    cfg_mgmt_read : in STD_LOGIC;
    cfg_mgmt_read_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cfg_mgmt_read_write_done : out STD_LOGIC;
    cfg_mgmt_type1_cfg_reg_access : in STD_LOGIC;
    int_qpll1lock_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    int_qpll1outrefclk_out : out STD_LOGIC_VECTOR ( 0 to 0 );
    int_qpll1outclk_out : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component sis8300ku_bsp_system_xdma_0_0;
  component sis8300ku_bsp_system_axi_interconnect_reg_0 is
  port (
    aclk : in STD_LOGIC;
    aclk1 : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    S00_AXI_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awvalid : in STD_LOGIC;
    S00_AXI_awready : out STD_LOGIC;
    S00_AXI_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_wvalid : in STD_LOGIC;
    S00_AXI_wready : out STD_LOGIC;
    S00_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_bvalid : out STD_LOGIC;
    S00_AXI_bready : in STD_LOGIC;
    S00_AXI_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arvalid : in STD_LOGIC;
    S00_AXI_arready : out STD_LOGIC;
    S00_AXI_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_rvalid : out STD_LOGIC;
    S00_AXI_rready : in STD_LOGIC;
    S01_AXI_awid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_awaddr : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S01_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S01_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_awuser : in STD_LOGIC_VECTOR ( 113 downto 0 );
    S01_AXI_awvalid : in STD_LOGIC;
    S01_AXI_awready : out STD_LOGIC;
    S01_AXI_wdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    S01_AXI_wstrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S01_AXI_wlast : in STD_LOGIC;
    S01_AXI_wuser : in STD_LOGIC_VECTOR ( 13 downto 0 );
    S01_AXI_wvalid : in STD_LOGIC;
    S01_AXI_wready : out STD_LOGIC;
    S01_AXI_bid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_bvalid : out STD_LOGIC;
    S01_AXI_bready : in STD_LOGIC;
    S01_AXI_arid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_araddr : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S01_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S01_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S01_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_aruser : in STD_LOGIC_VECTOR ( 113 downto 0 );
    S01_AXI_arvalid : in STD_LOGIC;
    S01_AXI_arready : out STD_LOGIC;
    S01_AXI_rid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_rdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    S01_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_rlast : out STD_LOGIC;
    S01_AXI_ruser : out STD_LOGIC_VECTOR ( 13 downto 0 );
    S01_AXI_rvalid : out STD_LOGIC;
    S01_AXI_rready : in STD_LOGIC;
    M00_AXI_awaddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    M00_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_awvalid : out STD_LOGIC;
    M00_AXI_awready : in STD_LOGIC;
    M00_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_wvalid : out STD_LOGIC;
    M00_AXI_wready : in STD_LOGIC;
    M00_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_bvalid : in STD_LOGIC;
    M00_AXI_bready : out STD_LOGIC;
    M00_AXI_araddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    M00_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_arvalid : out STD_LOGIC;
    M00_AXI_arready : in STD_LOGIC;
    M00_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_rvalid : in STD_LOGIC;
    M00_AXI_rready : out STD_LOGIC;
    M01_AXI_awaddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    M01_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_awvalid : out STD_LOGIC;
    M01_AXI_awready : in STD_LOGIC;
    M01_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M01_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_wvalid : out STD_LOGIC;
    M01_AXI_wready : in STD_LOGIC;
    M01_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_bvalid : in STD_LOGIC;
    M01_AXI_bready : out STD_LOGIC;
    M01_AXI_araddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    M01_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_arvalid : out STD_LOGIC;
    M01_AXI_arready : in STD_LOGIC;
    M01_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M01_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_rvalid : in STD_LOGIC;
    M01_AXI_rready : out STD_LOGIC
  );
  end component sis8300ku_bsp_system_axi_interconnect_reg_0;
  component sis8300ku_bsp_system_axi_interconnect_dma_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    S00_AXI_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awaddr : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S00_AXI_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_awvalid : in STD_LOGIC;
    S00_AXI_awready : out STD_LOGIC;
    S00_AXI_wdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    S00_AXI_wstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S00_AXI_wlast : in STD_LOGIC;
    S00_AXI_wvalid : in STD_LOGIC;
    S00_AXI_wready : out STD_LOGIC;
    S00_AXI_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_bvalid : out STD_LOGIC;
    S00_AXI_bready : in STD_LOGIC;
    S00_AXI_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_araddr : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S00_AXI_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    S00_AXI_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_arvalid : in STD_LOGIC;
    S00_AXI_arready : out STD_LOGIC;
    S00_AXI_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_rdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    S00_AXI_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_rlast : out STD_LOGIC;
    S00_AXI_rvalid : out STD_LOGIC;
    S00_AXI_rready : in STD_LOGIC;
    M00_AXI_awid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_awaddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M00_AXI_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_awuser : out STD_LOGIC_VECTOR ( 113 downto 0 );
    M00_AXI_awvalid : out STD_LOGIC;
    M00_AXI_awready : in STD_LOGIC;
    M00_AXI_wdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    M00_AXI_wstrb : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_wlast : out STD_LOGIC;
    M00_AXI_wuser : out STD_LOGIC_VECTOR ( 13 downto 0 );
    M00_AXI_wvalid : out STD_LOGIC;
    M00_AXI_wready : in STD_LOGIC;
    M00_AXI_bid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_bvalid : in STD_LOGIC;
    M00_AXI_bready : out STD_LOGIC;
    M00_AXI_arid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_araddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M00_AXI_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M00_AXI_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_aruser : out STD_LOGIC_VECTOR ( 113 downto 0 );
    M00_AXI_arvalid : out STD_LOGIC;
    M00_AXI_arready : in STD_LOGIC;
    M00_AXI_rid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_rdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    M00_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_rlast : in STD_LOGIC;
    M00_AXI_ruser : in STD_LOGIC_VECTOR ( 13 downto 0 );
    M00_AXI_rvalid : in STD_LOGIC;
    M00_AXI_rready : out STD_LOGIC;
    M01_AXI_awid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_awaddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M01_AXI_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M01_AXI_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M01_AXI_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_awuser : out STD_LOGIC_VECTOR ( 113 downto 0 );
    M01_AXI_awvalid : out STD_LOGIC;
    M01_AXI_awready : in STD_LOGIC;
    M01_AXI_wdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    M01_AXI_wstrb : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M01_AXI_wlast : out STD_LOGIC;
    M01_AXI_wuser : out STD_LOGIC_VECTOR ( 13 downto 0 );
    M01_AXI_wvalid : out STD_LOGIC;
    M01_AXI_wready : in STD_LOGIC;
    M01_AXI_bid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_buser : in STD_LOGIC_VECTOR ( 113 downto 0 );
    M01_AXI_bvalid : in STD_LOGIC;
    M01_AXI_bready : out STD_LOGIC;
    M01_AXI_arid : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_araddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M01_AXI_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M01_AXI_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    M01_AXI_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M01_AXI_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M01_AXI_aruser : out STD_LOGIC_VECTOR ( 113 downto 0 );
    M01_AXI_arvalid : out STD_LOGIC;
    M01_AXI_arready : in STD_LOGIC;
    M01_AXI_rid : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_rdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    M01_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M01_AXI_rlast : in STD_LOGIC;
    M01_AXI_ruser : in STD_LOGIC_VECTOR ( 13 downto 0 );
    M01_AXI_rvalid : in STD_LOGIC;
    M01_AXI_rready : out STD_LOGIC
  );
  end component sis8300ku_bsp_system_axi_interconnect_dma_0;
  signal Conn1_rxn : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn1_rxp : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn1_txn : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn1_txp : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_ARADDR : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal Conn2_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Conn2_ARREADY : STD_LOGIC;
  signal Conn2_ARVALID : STD_LOGIC;
  signal Conn2_AWADDR : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal Conn2_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Conn2_AWREADY : STD_LOGIC;
  signal Conn2_AWVALID : STD_LOGIC;
  signal Conn2_BREADY : STD_LOGIC;
  signal Conn2_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Conn2_BVALID : STD_LOGIC;
  signal Conn2_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn2_RREADY : STD_LOGIC;
  signal Conn2_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Conn2_RVALID : STD_LOGIC;
  signal Conn2_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn2_WREADY : STD_LOGIC;
  signal Conn2_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn2_WVALID : STD_LOGIC;
  signal Conn3_ARADDR : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal Conn3_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Conn3_ARREADY : STD_LOGIC;
  signal Conn3_ARVALID : STD_LOGIC;
  signal Conn3_AWADDR : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal Conn3_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal Conn3_AWREADY : STD_LOGIC;
  signal Conn3_AWVALID : STD_LOGIC;
  signal Conn3_BREADY : STD_LOGIC;
  signal Conn3_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Conn3_BVALID : STD_LOGIC;
  signal Conn3_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn3_RREADY : STD_LOGIC;
  signal Conn3_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Conn3_RVALID : STD_LOGIC;
  signal Conn3_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn3_WREADY : STD_LOGIC;
  signal Conn3_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal Conn3_WVALID : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_ARADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axi_interconnect_dma_M00_AXI_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M00_AXI_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_dma_M00_AXI_ARID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M00_AXI_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axi_interconnect_dma_M00_AXI_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axi_interconnect_dma_M00_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_dma_M00_AXI_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_dma_M00_AXI_ARREADY : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_dma_M00_AXI_ARUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal axi_interconnect_dma_M00_AXI_ARVALID : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_AWADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axi_interconnect_dma_M00_AXI_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M00_AXI_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_dma_M00_AXI_AWID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M00_AXI_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axi_interconnect_dma_M00_AXI_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axi_interconnect_dma_M00_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_dma_M00_AXI_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_dma_M00_AXI_AWREADY : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_dma_M00_AXI_AWUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal axi_interconnect_dma_M00_AXI_AWVALID : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_BID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M00_AXI_BREADY : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M00_AXI_BVALID : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_RDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal axi_interconnect_dma_M00_AXI_RID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M00_AXI_RLAST : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_RREADY : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M00_AXI_RUSER : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal axi_interconnect_dma_M00_AXI_RVALID : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_WDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal axi_interconnect_dma_M00_AXI_WLAST : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_WREADY : STD_LOGIC;
  signal axi_interconnect_dma_M00_AXI_WSTRB : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_interconnect_dma_M00_AXI_WUSER : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal axi_interconnect_dma_M00_AXI_WVALID : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_ARADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axi_interconnect_dma_M01_AXI_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M01_AXI_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_dma_M01_AXI_ARID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M01_AXI_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axi_interconnect_dma_M01_AXI_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axi_interconnect_dma_M01_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_dma_M01_AXI_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_dma_M01_AXI_ARREADY : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_dma_M01_AXI_ARUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal axi_interconnect_dma_M01_AXI_ARVALID : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_AWADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal axi_interconnect_dma_M01_AXI_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M01_AXI_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_dma_M01_AXI_AWID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M01_AXI_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal axi_interconnect_dma_M01_AXI_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal axi_interconnect_dma_M01_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_dma_M01_AXI_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_interconnect_dma_M01_AXI_AWREADY : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal axi_interconnect_dma_M01_AXI_AWUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal axi_interconnect_dma_M01_AXI_AWVALID : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_BID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M01_AXI_BREADY : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M01_AXI_BUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal axi_interconnect_dma_M01_AXI_BVALID : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_RDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal axi_interconnect_dma_M01_AXI_RID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M01_AXI_RLAST : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_RREADY : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal axi_interconnect_dma_M01_AXI_RUSER : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal axi_interconnect_dma_M01_AXI_RVALID : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_WDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal axi_interconnect_dma_M01_AXI_WLAST : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_WREADY : STD_LOGIC;
  signal axi_interconnect_dma_M01_AXI_WSTRB : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_interconnect_dma_M01_AXI_WUSER : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal axi_interconnect_dma_M01_AXI_WVALID : STD_LOGIC;
  signal pi_m_axi4l_app_aclk_1 : STD_LOGIC;
  signal pi_pcie_areset_n_1 : STD_LOGIC;
  signal pi_pcie_irq_req_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal pi_pcie_sys_clk_1 : STD_LOGIC;
  signal pi_pcie_sys_clk_gt_1 : STD_LOGIC;
  signal xdma_0_M_AXI_ARADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal xdma_0_M_AXI_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_ARID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal xdma_0_M_AXI_ARLOCK : STD_LOGIC;
  signal xdma_0_M_AXI_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_ARREADY : STD_LOGIC;
  signal xdma_0_M_AXI_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_ARVALID : STD_LOGIC;
  signal xdma_0_M_AXI_AWADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal xdma_0_M_AXI_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_AWID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal xdma_0_M_AXI_AWLOCK : STD_LOGIC;
  signal xdma_0_M_AXI_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_AWREADY : STD_LOGIC;
  signal xdma_0_M_AXI_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_AWVALID : STD_LOGIC;
  signal xdma_0_M_AXI_BID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_BREADY : STD_LOGIC;
  signal xdma_0_M_AXI_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_BVALID : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal xdma_0_M_AXI_LITE_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_LITE_ARREADY : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_ARVALID : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_AWADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal xdma_0_M_AXI_LITE_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal xdma_0_M_AXI_LITE_AWREADY : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_AWVALID : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_BREADY : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_LITE_BVALID : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal xdma_0_M_AXI_LITE_RREADY : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_LITE_RVALID : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal xdma_0_M_AXI_LITE_WREADY : STD_LOGIC;
  signal xdma_0_M_AXI_LITE_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_LITE_WVALID : STD_LOGIC;
  signal xdma_0_M_AXI_RDATA : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal xdma_0_M_AXI_RID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal xdma_0_M_AXI_RLAST : STD_LOGIC;
  signal xdma_0_M_AXI_RREADY : STD_LOGIC;
  signal xdma_0_M_AXI_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xdma_0_M_AXI_RVALID : STD_LOGIC;
  signal xdma_0_M_AXI_WDATA : STD_LOGIC_VECTOR ( 127 downto 0 );
  signal xdma_0_M_AXI_WLAST : STD_LOGIC;
  signal xdma_0_M_AXI_WREADY : STD_LOGIC;
  signal xdma_0_M_AXI_WSTRB : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal xdma_0_M_AXI_WVALID : STD_LOGIC;
  signal xdma_0_axi_aclk : STD_LOGIC;
  signal xdma_0_axi_aresetn : STD_LOGIC;
  signal xdma_0_user_lnk_up : STD_LOGIC;
  signal xdma_0_usr_irq_ack : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal NLW_xdma_0_cfg_mgmt_read_write_done_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_msi_enable_UNCONNECTED : STD_LOGIC;
  signal NLW_xdma_0_cfg_mgmt_read_data_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_xdma_0_int_qpll1lock_out_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_xdma_0_int_qpll1outclk_out_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_xdma_0_int_qpll1outrefclk_out_UNCONNECTED : STD_LOGIC_VECTOR ( 0 to 0 );
  signal NLW_xdma_0_msi_vector_width_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
begin
  Conn1_rxn(3 downto 0) <= p_pcie_mgt_rxn(3 downto 0);
  Conn1_rxp(3 downto 0) <= p_pcie_mgt_rxp(3 downto 0);
  Conn2_ARREADY <= p_m_axi4l_bsp_arready;
  Conn2_AWREADY <= p_m_axi4l_bsp_awready;
  Conn2_BRESP(1 downto 0) <= p_m_axi4l_bsp_bresp(1 downto 0);
  Conn2_BVALID <= p_m_axi4l_bsp_bvalid;
  Conn2_RDATA(31 downto 0) <= p_m_axi4l_bsp_rdata(31 downto 0);
  Conn2_RRESP(1 downto 0) <= p_m_axi4l_bsp_rresp(1 downto 0);
  Conn2_RVALID <= p_m_axi4l_bsp_rvalid;
  Conn2_WREADY <= p_m_axi4l_bsp_wready;
  Conn3_ARREADY <= p_m_axi4l_app_arready;
  Conn3_AWREADY <= p_m_axi4l_app_awready;
  Conn3_BRESP(1 downto 0) <= p_m_axi4l_app_bresp(1 downto 0);
  Conn3_BVALID <= p_m_axi4l_app_bvalid;
  Conn3_RDATA(31 downto 0) <= p_m_axi4l_app_rdata(31 downto 0);
  Conn3_RRESP(1 downto 0) <= p_m_axi4l_app_rresp(1 downto 0);
  Conn3_RVALID <= p_m_axi4l_app_rvalid;
  Conn3_WREADY <= p_m_axi4l_app_wready;
  axi_interconnect_dma_M01_AXI_ARREADY <= m_axi_dma_ddr_arready;
  axi_interconnect_dma_M01_AXI_AWREADY <= m_axi_dma_ddr_awready;
  axi_interconnect_dma_M01_AXI_BID(1 downto 0) <= m_axi_dma_ddr_bid(1 downto 0);
  axi_interconnect_dma_M01_AXI_BRESP(1 downto 0) <= m_axi_dma_ddr_bresp(1 downto 0);
  axi_interconnect_dma_M01_AXI_BUSER(113 downto 0) <= m_axi_dma_ddr_buser(113 downto 0);
  axi_interconnect_dma_M01_AXI_BVALID <= m_axi_dma_ddr_bvalid;
  axi_interconnect_dma_M01_AXI_RDATA(255 downto 0) <= m_axi_dma_ddr_rdata(255 downto 0);
  axi_interconnect_dma_M01_AXI_RID(1 downto 0) <= m_axi_dma_ddr_rid(1 downto 0);
  axi_interconnect_dma_M01_AXI_RLAST <= m_axi_dma_ddr_rlast;
  axi_interconnect_dma_M01_AXI_RRESP(1 downto 0) <= m_axi_dma_ddr_rresp(1 downto 0);
  axi_interconnect_dma_M01_AXI_RUSER(13 downto 0) <= m_axi_dma_ddr_ruser(13 downto 0);
  axi_interconnect_dma_M01_AXI_RVALID <= m_axi_dma_ddr_rvalid;
  axi_interconnect_dma_M01_AXI_WREADY <= m_axi_dma_ddr_wready;
  m_axi_dma_ddr_araddr(63 downto 0) <= axi_interconnect_dma_M01_AXI_ARADDR(63 downto 0);
  m_axi_dma_ddr_arburst(1 downto 0) <= axi_interconnect_dma_M01_AXI_ARBURST(1 downto 0);
  m_axi_dma_ddr_arcache(3 downto 0) <= axi_interconnect_dma_M01_AXI_ARCACHE(3 downto 0);
  m_axi_dma_ddr_arid(1 downto 0) <= axi_interconnect_dma_M01_AXI_ARID(1 downto 0);
  m_axi_dma_ddr_arlen(7 downto 0) <= axi_interconnect_dma_M01_AXI_ARLEN(7 downto 0);
  m_axi_dma_ddr_arlock(0) <= axi_interconnect_dma_M01_AXI_ARLOCK(0);
  m_axi_dma_ddr_arprot(2 downto 0) <= axi_interconnect_dma_M01_AXI_ARPROT(2 downto 0);
  m_axi_dma_ddr_arqos(3 downto 0) <= axi_interconnect_dma_M01_AXI_ARQOS(3 downto 0);
  m_axi_dma_ddr_arsize(2 downto 0) <= axi_interconnect_dma_M01_AXI_ARSIZE(2 downto 0);
  m_axi_dma_ddr_aruser(113 downto 0) <= axi_interconnect_dma_M01_AXI_ARUSER(113 downto 0);
  m_axi_dma_ddr_arvalid <= axi_interconnect_dma_M01_AXI_ARVALID;
  m_axi_dma_ddr_awaddr(63 downto 0) <= axi_interconnect_dma_M01_AXI_AWADDR(63 downto 0);
  m_axi_dma_ddr_awburst(1 downto 0) <= axi_interconnect_dma_M01_AXI_AWBURST(1 downto 0);
  m_axi_dma_ddr_awcache(3 downto 0) <= axi_interconnect_dma_M01_AXI_AWCACHE(3 downto 0);
  m_axi_dma_ddr_awid(1 downto 0) <= axi_interconnect_dma_M01_AXI_AWID(1 downto 0);
  m_axi_dma_ddr_awlen(7 downto 0) <= axi_interconnect_dma_M01_AXI_AWLEN(7 downto 0);
  m_axi_dma_ddr_awlock(0) <= axi_interconnect_dma_M01_AXI_AWLOCK(0);
  m_axi_dma_ddr_awprot(2 downto 0) <= axi_interconnect_dma_M01_AXI_AWPROT(2 downto 0);
  m_axi_dma_ddr_awqos(3 downto 0) <= axi_interconnect_dma_M01_AXI_AWQOS(3 downto 0);
  m_axi_dma_ddr_awsize(2 downto 0) <= axi_interconnect_dma_M01_AXI_AWSIZE(2 downto 0);
  m_axi_dma_ddr_awuser(113 downto 0) <= axi_interconnect_dma_M01_AXI_AWUSER(113 downto 0);
  m_axi_dma_ddr_awvalid <= axi_interconnect_dma_M01_AXI_AWVALID;
  m_axi_dma_ddr_bready <= axi_interconnect_dma_M01_AXI_BREADY;
  m_axi_dma_ddr_rready <= axi_interconnect_dma_M01_AXI_RREADY;
  m_axi_dma_ddr_wdata(255 downto 0) <= axi_interconnect_dma_M01_AXI_WDATA(255 downto 0);
  m_axi_dma_ddr_wlast <= axi_interconnect_dma_M01_AXI_WLAST;
  m_axi_dma_ddr_wstrb(31 downto 0) <= axi_interconnect_dma_M01_AXI_WSTRB(31 downto 0);
  m_axi_dma_ddr_wuser(13 downto 0) <= axi_interconnect_dma_M01_AXI_WUSER(13 downto 0);
  m_axi_dma_ddr_wvalid <= axi_interconnect_dma_M01_AXI_WVALID;
  p_m_axi4l_app_araddr(22 downto 0) <= Conn3_ARADDR(22 downto 0);
  p_m_axi4l_app_arprot(2 downto 0) <= Conn3_ARPROT(2 downto 0);
  p_m_axi4l_app_arvalid <= Conn3_ARVALID;
  p_m_axi4l_app_awaddr(22 downto 0) <= Conn3_AWADDR(22 downto 0);
  p_m_axi4l_app_awprot(2 downto 0) <= Conn3_AWPROT(2 downto 0);
  p_m_axi4l_app_awvalid <= Conn3_AWVALID;
  p_m_axi4l_app_bready <= Conn3_BREADY;
  p_m_axi4l_app_rready <= Conn3_RREADY;
  p_m_axi4l_app_wdata(31 downto 0) <= Conn3_WDATA(31 downto 0);
  p_m_axi4l_app_wstrb(3 downto 0) <= Conn3_WSTRB(3 downto 0);
  p_m_axi4l_app_wvalid <= Conn3_WVALID;
  p_m_axi4l_bsp_araddr(22 downto 0) <= Conn2_ARADDR(22 downto 0);
  p_m_axi4l_bsp_arprot(2 downto 0) <= Conn2_ARPROT(2 downto 0);
  p_m_axi4l_bsp_arvalid <= Conn2_ARVALID;
  p_m_axi4l_bsp_awaddr(22 downto 0) <= Conn2_AWADDR(22 downto 0);
  p_m_axi4l_bsp_awprot(2 downto 0) <= Conn2_AWPROT(2 downto 0);
  p_m_axi4l_bsp_awvalid <= Conn2_AWVALID;
  p_m_axi4l_bsp_bready <= Conn2_BREADY;
  p_m_axi4l_bsp_rready <= Conn2_RREADY;
  p_m_axi4l_bsp_wdata(31 downto 0) <= Conn2_WDATA(31 downto 0);
  p_m_axi4l_bsp_wstrb(3 downto 0) <= Conn2_WSTRB(3 downto 0);
  p_m_axi4l_bsp_wvalid <= Conn2_WVALID;
  p_pcie_mgt_txn(3 downto 0) <= Conn1_txn(3 downto 0);
  p_pcie_mgt_txp(3 downto 0) <= Conn1_txp(3 downto 0);
  pi_m_axi4l_app_aclk_1 <= pi_m_axi4l_app_aclk;
  pi_pcie_areset_n_1 <= pi_pcie_areset_n;
  pi_pcie_irq_req_1(15 downto 0) <= pi_pcie_irq_req(15 downto 0);
  pi_pcie_sys_clk_1 <= pi_pcie_sys_clk;
  pi_pcie_sys_clk_gt_1 <= pi_pcie_sys_clk_gt;
  po_m_axi4_aclk <= xdma_0_axi_aclk;
  po_m_axi4_areset_n <= xdma_0_axi_aresetn;
  po_pcie_irq_ack(15 downto 0) <= xdma_0_usr_irq_ack(15 downto 0);
  po_pcie_link_up <= xdma_0_user_lnk_up;
axi_interconnect_dma: component sis8300ku_bsp_system_axi_interconnect_dma_0
     port map (
      M00_AXI_araddr(63 downto 0) => axi_interconnect_dma_M00_AXI_ARADDR(63 downto 0),
      M00_AXI_arburst(1 downto 0) => axi_interconnect_dma_M00_AXI_ARBURST(1 downto 0),
      M00_AXI_arcache(3 downto 0) => axi_interconnect_dma_M00_AXI_ARCACHE(3 downto 0),
      M00_AXI_arid(1 downto 0) => axi_interconnect_dma_M00_AXI_ARID(1 downto 0),
      M00_AXI_arlen(7 downto 0) => axi_interconnect_dma_M00_AXI_ARLEN(7 downto 0),
      M00_AXI_arlock(0) => axi_interconnect_dma_M00_AXI_ARLOCK(0),
      M00_AXI_arprot(2 downto 0) => axi_interconnect_dma_M00_AXI_ARPROT(2 downto 0),
      M00_AXI_arqos(3 downto 0) => axi_interconnect_dma_M00_AXI_ARQOS(3 downto 0),
      M00_AXI_arready => axi_interconnect_dma_M00_AXI_ARREADY,
      M00_AXI_arsize(2 downto 0) => axi_interconnect_dma_M00_AXI_ARSIZE(2 downto 0),
      M00_AXI_aruser(113 downto 0) => axi_interconnect_dma_M00_AXI_ARUSER(113 downto 0),
      M00_AXI_arvalid => axi_interconnect_dma_M00_AXI_ARVALID,
      M00_AXI_awaddr(63 downto 0) => axi_interconnect_dma_M00_AXI_AWADDR(63 downto 0),
      M00_AXI_awburst(1 downto 0) => axi_interconnect_dma_M00_AXI_AWBURST(1 downto 0),
      M00_AXI_awcache(3 downto 0) => axi_interconnect_dma_M00_AXI_AWCACHE(3 downto 0),
      M00_AXI_awid(1 downto 0) => axi_interconnect_dma_M00_AXI_AWID(1 downto 0),
      M00_AXI_awlen(7 downto 0) => axi_interconnect_dma_M00_AXI_AWLEN(7 downto 0),
      M00_AXI_awlock(0) => axi_interconnect_dma_M00_AXI_AWLOCK(0),
      M00_AXI_awprot(2 downto 0) => axi_interconnect_dma_M00_AXI_AWPROT(2 downto 0),
      M00_AXI_awqos(3 downto 0) => axi_interconnect_dma_M00_AXI_AWQOS(3 downto 0),
      M00_AXI_awready => axi_interconnect_dma_M00_AXI_AWREADY,
      M00_AXI_awsize(2 downto 0) => axi_interconnect_dma_M00_AXI_AWSIZE(2 downto 0),
      M00_AXI_awuser(113 downto 0) => axi_interconnect_dma_M00_AXI_AWUSER(113 downto 0),
      M00_AXI_awvalid => axi_interconnect_dma_M00_AXI_AWVALID,
      M00_AXI_bid(1 downto 0) => axi_interconnect_dma_M00_AXI_BID(1 downto 0),
      M00_AXI_bready => axi_interconnect_dma_M00_AXI_BREADY,
      M00_AXI_bresp(1 downto 0) => axi_interconnect_dma_M00_AXI_BRESP(1 downto 0),
      M00_AXI_bvalid => axi_interconnect_dma_M00_AXI_BVALID,
      M00_AXI_rdata(255 downto 0) => axi_interconnect_dma_M00_AXI_RDATA(255 downto 0),
      M00_AXI_rid(1 downto 0) => axi_interconnect_dma_M00_AXI_RID(1 downto 0),
      M00_AXI_rlast => axi_interconnect_dma_M00_AXI_RLAST,
      M00_AXI_rready => axi_interconnect_dma_M00_AXI_RREADY,
      M00_AXI_rresp(1 downto 0) => axi_interconnect_dma_M00_AXI_RRESP(1 downto 0),
      M00_AXI_ruser(13 downto 0) => axi_interconnect_dma_M00_AXI_RUSER(13 downto 0),
      M00_AXI_rvalid => axi_interconnect_dma_M00_AXI_RVALID,
      M00_AXI_wdata(255 downto 0) => axi_interconnect_dma_M00_AXI_WDATA(255 downto 0),
      M00_AXI_wlast => axi_interconnect_dma_M00_AXI_WLAST,
      M00_AXI_wready => axi_interconnect_dma_M00_AXI_WREADY,
      M00_AXI_wstrb(31 downto 0) => axi_interconnect_dma_M00_AXI_WSTRB(31 downto 0),
      M00_AXI_wuser(13 downto 0) => axi_interconnect_dma_M00_AXI_WUSER(13 downto 0),
      M00_AXI_wvalid => axi_interconnect_dma_M00_AXI_WVALID,
      M01_AXI_araddr(63 downto 0) => axi_interconnect_dma_M01_AXI_ARADDR(63 downto 0),
      M01_AXI_arburst(1 downto 0) => axi_interconnect_dma_M01_AXI_ARBURST(1 downto 0),
      M01_AXI_arcache(3 downto 0) => axi_interconnect_dma_M01_AXI_ARCACHE(3 downto 0),
      M01_AXI_arid(1 downto 0) => axi_interconnect_dma_M01_AXI_ARID(1 downto 0),
      M01_AXI_arlen(7 downto 0) => axi_interconnect_dma_M01_AXI_ARLEN(7 downto 0),
      M01_AXI_arlock(0) => axi_interconnect_dma_M01_AXI_ARLOCK(0),
      M01_AXI_arprot(2 downto 0) => axi_interconnect_dma_M01_AXI_ARPROT(2 downto 0),
      M01_AXI_arqos(3 downto 0) => axi_interconnect_dma_M01_AXI_ARQOS(3 downto 0),
      M01_AXI_arready => axi_interconnect_dma_M01_AXI_ARREADY,
      M01_AXI_arsize(2 downto 0) => axi_interconnect_dma_M01_AXI_ARSIZE(2 downto 0),
      M01_AXI_aruser(113 downto 0) => axi_interconnect_dma_M01_AXI_ARUSER(113 downto 0),
      M01_AXI_arvalid => axi_interconnect_dma_M01_AXI_ARVALID,
      M01_AXI_awaddr(63 downto 0) => axi_interconnect_dma_M01_AXI_AWADDR(63 downto 0),
      M01_AXI_awburst(1 downto 0) => axi_interconnect_dma_M01_AXI_AWBURST(1 downto 0),
      M01_AXI_awcache(3 downto 0) => axi_interconnect_dma_M01_AXI_AWCACHE(3 downto 0),
      M01_AXI_awid(1 downto 0) => axi_interconnect_dma_M01_AXI_AWID(1 downto 0),
      M01_AXI_awlen(7 downto 0) => axi_interconnect_dma_M01_AXI_AWLEN(7 downto 0),
      M01_AXI_awlock(0) => axi_interconnect_dma_M01_AXI_AWLOCK(0),
      M01_AXI_awprot(2 downto 0) => axi_interconnect_dma_M01_AXI_AWPROT(2 downto 0),
      M01_AXI_awqos(3 downto 0) => axi_interconnect_dma_M01_AXI_AWQOS(3 downto 0),
      M01_AXI_awready => axi_interconnect_dma_M01_AXI_AWREADY,
      M01_AXI_awsize(2 downto 0) => axi_interconnect_dma_M01_AXI_AWSIZE(2 downto 0),
      M01_AXI_awuser(113 downto 0) => axi_interconnect_dma_M01_AXI_AWUSER(113 downto 0),
      M01_AXI_awvalid => axi_interconnect_dma_M01_AXI_AWVALID,
      M01_AXI_bid(1 downto 0) => axi_interconnect_dma_M01_AXI_BID(1 downto 0),
      M01_AXI_bready => axi_interconnect_dma_M01_AXI_BREADY,
      M01_AXI_bresp(1 downto 0) => axi_interconnect_dma_M01_AXI_BRESP(1 downto 0),
      M01_AXI_buser(113 downto 0) => axi_interconnect_dma_M01_AXI_BUSER(113 downto 0),
      M01_AXI_bvalid => axi_interconnect_dma_M01_AXI_BVALID,
      M01_AXI_rdata(255 downto 0) => axi_interconnect_dma_M01_AXI_RDATA(255 downto 0),
      M01_AXI_rid(1 downto 0) => axi_interconnect_dma_M01_AXI_RID(1 downto 0),
      M01_AXI_rlast => axi_interconnect_dma_M01_AXI_RLAST,
      M01_AXI_rready => axi_interconnect_dma_M01_AXI_RREADY,
      M01_AXI_rresp(1 downto 0) => axi_interconnect_dma_M01_AXI_RRESP(1 downto 0),
      M01_AXI_ruser(13 downto 0) => axi_interconnect_dma_M01_AXI_RUSER(13 downto 0),
      M01_AXI_rvalid => axi_interconnect_dma_M01_AXI_RVALID,
      M01_AXI_wdata(255 downto 0) => axi_interconnect_dma_M01_AXI_WDATA(255 downto 0),
      M01_AXI_wlast => axi_interconnect_dma_M01_AXI_WLAST,
      M01_AXI_wready => axi_interconnect_dma_M01_AXI_WREADY,
      M01_AXI_wstrb(31 downto 0) => axi_interconnect_dma_M01_AXI_WSTRB(31 downto 0),
      M01_AXI_wuser(13 downto 0) => axi_interconnect_dma_M01_AXI_WUSER(13 downto 0),
      M01_AXI_wvalid => axi_interconnect_dma_M01_AXI_WVALID,
      S00_AXI_araddr(63 downto 0) => xdma_0_M_AXI_ARADDR(63 downto 0),
      S00_AXI_arburst(1 downto 0) => xdma_0_M_AXI_ARBURST(1 downto 0),
      S00_AXI_arcache(3 downto 0) => xdma_0_M_AXI_ARCACHE(3 downto 0),
      S00_AXI_arid(3 downto 0) => xdma_0_M_AXI_ARID(3 downto 0),
      S00_AXI_arlen(7 downto 0) => xdma_0_M_AXI_ARLEN(7 downto 0),
      S00_AXI_arlock(0) => xdma_0_M_AXI_ARLOCK,
      S00_AXI_arprot(2 downto 0) => xdma_0_M_AXI_ARPROT(2 downto 0),
      S00_AXI_arqos(3 downto 0) => B"0000",
      S00_AXI_arready => xdma_0_M_AXI_ARREADY,
      S00_AXI_arsize(2 downto 0) => xdma_0_M_AXI_ARSIZE(2 downto 0),
      S00_AXI_arvalid => xdma_0_M_AXI_ARVALID,
      S00_AXI_awaddr(63 downto 0) => xdma_0_M_AXI_AWADDR(63 downto 0),
      S00_AXI_awburst(1 downto 0) => xdma_0_M_AXI_AWBURST(1 downto 0),
      S00_AXI_awcache(3 downto 0) => xdma_0_M_AXI_AWCACHE(3 downto 0),
      S00_AXI_awid(3 downto 0) => xdma_0_M_AXI_AWID(3 downto 0),
      S00_AXI_awlen(7 downto 0) => xdma_0_M_AXI_AWLEN(7 downto 0),
      S00_AXI_awlock(0) => xdma_0_M_AXI_AWLOCK,
      S00_AXI_awprot(2 downto 0) => xdma_0_M_AXI_AWPROT(2 downto 0),
      S00_AXI_awqos(3 downto 0) => B"0000",
      S00_AXI_awready => xdma_0_M_AXI_AWREADY,
      S00_AXI_awsize(2 downto 0) => xdma_0_M_AXI_AWSIZE(2 downto 0),
      S00_AXI_awvalid => xdma_0_M_AXI_AWVALID,
      S00_AXI_bid(3 downto 0) => xdma_0_M_AXI_BID(3 downto 0),
      S00_AXI_bready => xdma_0_M_AXI_BREADY,
      S00_AXI_bresp(1 downto 0) => xdma_0_M_AXI_BRESP(1 downto 0),
      S00_AXI_bvalid => xdma_0_M_AXI_BVALID,
      S00_AXI_rdata(127 downto 0) => xdma_0_M_AXI_RDATA(127 downto 0),
      S00_AXI_rid(3 downto 0) => xdma_0_M_AXI_RID(3 downto 0),
      S00_AXI_rlast => xdma_0_M_AXI_RLAST,
      S00_AXI_rready => xdma_0_M_AXI_RREADY,
      S00_AXI_rresp(1 downto 0) => xdma_0_M_AXI_RRESP(1 downto 0),
      S00_AXI_rvalid => xdma_0_M_AXI_RVALID,
      S00_AXI_wdata(127 downto 0) => xdma_0_M_AXI_WDATA(127 downto 0),
      S00_AXI_wlast => xdma_0_M_AXI_WLAST,
      S00_AXI_wready => xdma_0_M_AXI_WREADY,
      S00_AXI_wstrb(15 downto 0) => xdma_0_M_AXI_WSTRB(15 downto 0),
      S00_AXI_wvalid => xdma_0_M_AXI_WVALID,
      aclk => xdma_0_axi_aclk,
      aresetn => xdma_0_axi_aresetn
    );
axi_interconnect_reg: component sis8300ku_bsp_system_axi_interconnect_reg_0
     port map (
      M00_AXI_araddr(22 downto 0) => Conn2_ARADDR(22 downto 0),
      M00_AXI_arprot(2 downto 0) => Conn2_ARPROT(2 downto 0),
      M00_AXI_arready => Conn2_ARREADY,
      M00_AXI_arvalid => Conn2_ARVALID,
      M00_AXI_awaddr(22 downto 0) => Conn2_AWADDR(22 downto 0),
      M00_AXI_awprot(2 downto 0) => Conn2_AWPROT(2 downto 0),
      M00_AXI_awready => Conn2_AWREADY,
      M00_AXI_awvalid => Conn2_AWVALID,
      M00_AXI_bready => Conn2_BREADY,
      M00_AXI_bresp(1 downto 0) => Conn2_BRESP(1 downto 0),
      M00_AXI_bvalid => Conn2_BVALID,
      M00_AXI_rdata(31 downto 0) => Conn2_RDATA(31 downto 0),
      M00_AXI_rready => Conn2_RREADY,
      M00_AXI_rresp(1 downto 0) => Conn2_RRESP(1 downto 0),
      M00_AXI_rvalid => Conn2_RVALID,
      M00_AXI_wdata(31 downto 0) => Conn2_WDATA(31 downto 0),
      M00_AXI_wready => Conn2_WREADY,
      M00_AXI_wstrb(3 downto 0) => Conn2_WSTRB(3 downto 0),
      M00_AXI_wvalid => Conn2_WVALID,
      M01_AXI_araddr(22 downto 0) => Conn3_ARADDR(22 downto 0),
      M01_AXI_arprot(2 downto 0) => Conn3_ARPROT(2 downto 0),
      M01_AXI_arready => Conn3_ARREADY,
      M01_AXI_arvalid => Conn3_ARVALID,
      M01_AXI_awaddr(22 downto 0) => Conn3_AWADDR(22 downto 0),
      M01_AXI_awprot(2 downto 0) => Conn3_AWPROT(2 downto 0),
      M01_AXI_awready => Conn3_AWREADY,
      M01_AXI_awvalid => Conn3_AWVALID,
      M01_AXI_bready => Conn3_BREADY,
      M01_AXI_bresp(1 downto 0) => Conn3_BRESP(1 downto 0),
      M01_AXI_bvalid => Conn3_BVALID,
      M01_AXI_rdata(31 downto 0) => Conn3_RDATA(31 downto 0),
      M01_AXI_rready => Conn3_RREADY,
      M01_AXI_rresp(1 downto 0) => Conn3_RRESP(1 downto 0),
      M01_AXI_rvalid => Conn3_RVALID,
      M01_AXI_wdata(31 downto 0) => Conn3_WDATA(31 downto 0),
      M01_AXI_wready => Conn3_WREADY,
      M01_AXI_wstrb(3 downto 0) => Conn3_WSTRB(3 downto 0),
      M01_AXI_wvalid => Conn3_WVALID,
      S00_AXI_araddr(31 downto 0) => xdma_0_M_AXI_LITE_ARADDR(31 downto 0),
      S00_AXI_arprot(2 downto 0) => xdma_0_M_AXI_LITE_ARPROT(2 downto 0),
      S00_AXI_arready => xdma_0_M_AXI_LITE_ARREADY,
      S00_AXI_arvalid => xdma_0_M_AXI_LITE_ARVALID,
      S00_AXI_awaddr(31 downto 0) => xdma_0_M_AXI_LITE_AWADDR(31 downto 0),
      S00_AXI_awprot(2 downto 0) => xdma_0_M_AXI_LITE_AWPROT(2 downto 0),
      S00_AXI_awready => xdma_0_M_AXI_LITE_AWREADY,
      S00_AXI_awvalid => xdma_0_M_AXI_LITE_AWVALID,
      S00_AXI_bready => xdma_0_M_AXI_LITE_BREADY,
      S00_AXI_bresp(1 downto 0) => xdma_0_M_AXI_LITE_BRESP(1 downto 0),
      S00_AXI_bvalid => xdma_0_M_AXI_LITE_BVALID,
      S00_AXI_rdata(31 downto 0) => xdma_0_M_AXI_LITE_RDATA(31 downto 0),
      S00_AXI_rready => xdma_0_M_AXI_LITE_RREADY,
      S00_AXI_rresp(1 downto 0) => xdma_0_M_AXI_LITE_RRESP(1 downto 0),
      S00_AXI_rvalid => xdma_0_M_AXI_LITE_RVALID,
      S00_AXI_wdata(31 downto 0) => xdma_0_M_AXI_LITE_WDATA(31 downto 0),
      S00_AXI_wready => xdma_0_M_AXI_LITE_WREADY,
      S00_AXI_wstrb(3 downto 0) => xdma_0_M_AXI_LITE_WSTRB(3 downto 0),
      S00_AXI_wvalid => xdma_0_M_AXI_LITE_WVALID,
      S01_AXI_araddr(63 downto 0) => axi_interconnect_dma_M00_AXI_ARADDR(63 downto 0),
      S01_AXI_arburst(1 downto 0) => axi_interconnect_dma_M00_AXI_ARBURST(1 downto 0),
      S01_AXI_arcache(3 downto 0) => axi_interconnect_dma_M00_AXI_ARCACHE(3 downto 0),
      S01_AXI_arid(1 downto 0) => axi_interconnect_dma_M00_AXI_ARID(1 downto 0),
      S01_AXI_arlen(7 downto 0) => axi_interconnect_dma_M00_AXI_ARLEN(7 downto 0),
      S01_AXI_arlock(0) => axi_interconnect_dma_M00_AXI_ARLOCK(0),
      S01_AXI_arprot(2 downto 0) => axi_interconnect_dma_M00_AXI_ARPROT(2 downto 0),
      S01_AXI_arqos(3 downto 0) => axi_interconnect_dma_M00_AXI_ARQOS(3 downto 0),
      S01_AXI_arready => axi_interconnect_dma_M00_AXI_ARREADY,
      S01_AXI_arsize(2 downto 0) => axi_interconnect_dma_M00_AXI_ARSIZE(2 downto 0),
      S01_AXI_aruser(113 downto 0) => axi_interconnect_dma_M00_AXI_ARUSER(113 downto 0),
      S01_AXI_arvalid => axi_interconnect_dma_M00_AXI_ARVALID,
      S01_AXI_awaddr(63 downto 0) => axi_interconnect_dma_M00_AXI_AWADDR(63 downto 0),
      S01_AXI_awburst(1 downto 0) => axi_interconnect_dma_M00_AXI_AWBURST(1 downto 0),
      S01_AXI_awcache(3 downto 0) => axi_interconnect_dma_M00_AXI_AWCACHE(3 downto 0),
      S01_AXI_awid(1 downto 0) => axi_interconnect_dma_M00_AXI_AWID(1 downto 0),
      S01_AXI_awlen(7 downto 0) => axi_interconnect_dma_M00_AXI_AWLEN(7 downto 0),
      S01_AXI_awlock(0) => axi_interconnect_dma_M00_AXI_AWLOCK(0),
      S01_AXI_awprot(2 downto 0) => axi_interconnect_dma_M00_AXI_AWPROT(2 downto 0),
      S01_AXI_awqos(3 downto 0) => axi_interconnect_dma_M00_AXI_AWQOS(3 downto 0),
      S01_AXI_awready => axi_interconnect_dma_M00_AXI_AWREADY,
      S01_AXI_awsize(2 downto 0) => axi_interconnect_dma_M00_AXI_AWSIZE(2 downto 0),
      S01_AXI_awuser(113 downto 0) => axi_interconnect_dma_M00_AXI_AWUSER(113 downto 0),
      S01_AXI_awvalid => axi_interconnect_dma_M00_AXI_AWVALID,
      S01_AXI_bid(1 downto 0) => axi_interconnect_dma_M00_AXI_BID(1 downto 0),
      S01_AXI_bready => axi_interconnect_dma_M00_AXI_BREADY,
      S01_AXI_bresp(1 downto 0) => axi_interconnect_dma_M00_AXI_BRESP(1 downto 0),
      S01_AXI_bvalid => axi_interconnect_dma_M00_AXI_BVALID,
      S01_AXI_rdata(255 downto 0) => axi_interconnect_dma_M00_AXI_RDATA(255 downto 0),
      S01_AXI_rid(1 downto 0) => axi_interconnect_dma_M00_AXI_RID(1 downto 0),
      S01_AXI_rlast => axi_interconnect_dma_M00_AXI_RLAST,
      S01_AXI_rready => axi_interconnect_dma_M00_AXI_RREADY,
      S01_AXI_rresp(1 downto 0) => axi_interconnect_dma_M00_AXI_RRESP(1 downto 0),
      S01_AXI_ruser(13 downto 0) => axi_interconnect_dma_M00_AXI_RUSER(13 downto 0),
      S01_AXI_rvalid => axi_interconnect_dma_M00_AXI_RVALID,
      S01_AXI_wdata(255 downto 0) => axi_interconnect_dma_M00_AXI_WDATA(255 downto 0),
      S01_AXI_wlast => axi_interconnect_dma_M00_AXI_WLAST,
      S01_AXI_wready => axi_interconnect_dma_M00_AXI_WREADY,
      S01_AXI_wstrb(31 downto 0) => axi_interconnect_dma_M00_AXI_WSTRB(31 downto 0),
      S01_AXI_wuser(13 downto 0) => axi_interconnect_dma_M00_AXI_WUSER(13 downto 0),
      S01_AXI_wvalid => axi_interconnect_dma_M00_AXI_WVALID,
      aclk => xdma_0_axi_aclk,
      aclk1 => pi_m_axi4l_app_aclk_1,
      aresetn => xdma_0_axi_aresetn
    );
xdma_0: component sis8300ku_bsp_system_xdma_0_0
     port map (
      axi_aclk => xdma_0_axi_aclk,
      axi_aresetn => xdma_0_axi_aresetn,
      cfg_mgmt_addr(18 downto 0) => B"0000000000000000000",
      cfg_mgmt_byte_enable(3 downto 0) => B"0000",
      cfg_mgmt_read => '0',
      cfg_mgmt_read_data(31 downto 0) => NLW_xdma_0_cfg_mgmt_read_data_UNCONNECTED(31 downto 0),
      cfg_mgmt_read_write_done => NLW_xdma_0_cfg_mgmt_read_write_done_UNCONNECTED,
      cfg_mgmt_type1_cfg_reg_access => '0',
      cfg_mgmt_write => '0',
      cfg_mgmt_write_data(31 downto 0) => B"00000000000000000000000000000000",
      int_qpll1lock_out(0) => NLW_xdma_0_int_qpll1lock_out_UNCONNECTED(0),
      int_qpll1outclk_out(0) => NLW_xdma_0_int_qpll1outclk_out_UNCONNECTED(0),
      int_qpll1outrefclk_out(0) => NLW_xdma_0_int_qpll1outrefclk_out_UNCONNECTED(0),
      m_axi_araddr(63 downto 0) => xdma_0_M_AXI_ARADDR(63 downto 0),
      m_axi_arburst(1 downto 0) => xdma_0_M_AXI_ARBURST(1 downto 0),
      m_axi_arcache(3 downto 0) => xdma_0_M_AXI_ARCACHE(3 downto 0),
      m_axi_arid(3 downto 0) => xdma_0_M_AXI_ARID(3 downto 0),
      m_axi_arlen(7 downto 0) => xdma_0_M_AXI_ARLEN(7 downto 0),
      m_axi_arlock => xdma_0_M_AXI_ARLOCK,
      m_axi_arprot(2 downto 0) => xdma_0_M_AXI_ARPROT(2 downto 0),
      m_axi_arready => xdma_0_M_AXI_ARREADY,
      m_axi_arsize(2 downto 0) => xdma_0_M_AXI_ARSIZE(2 downto 0),
      m_axi_arvalid => xdma_0_M_AXI_ARVALID,
      m_axi_awaddr(63 downto 0) => xdma_0_M_AXI_AWADDR(63 downto 0),
      m_axi_awburst(1 downto 0) => xdma_0_M_AXI_AWBURST(1 downto 0),
      m_axi_awcache(3 downto 0) => xdma_0_M_AXI_AWCACHE(3 downto 0),
      m_axi_awid(3 downto 0) => xdma_0_M_AXI_AWID(3 downto 0),
      m_axi_awlen(7 downto 0) => xdma_0_M_AXI_AWLEN(7 downto 0),
      m_axi_awlock => xdma_0_M_AXI_AWLOCK,
      m_axi_awprot(2 downto 0) => xdma_0_M_AXI_AWPROT(2 downto 0),
      m_axi_awready => xdma_0_M_AXI_AWREADY,
      m_axi_awsize(2 downto 0) => xdma_0_M_AXI_AWSIZE(2 downto 0),
      m_axi_awvalid => xdma_0_M_AXI_AWVALID,
      m_axi_bid(3 downto 0) => xdma_0_M_AXI_BID(3 downto 0),
      m_axi_bready => xdma_0_M_AXI_BREADY,
      m_axi_bresp(1 downto 0) => xdma_0_M_AXI_BRESP(1 downto 0),
      m_axi_bvalid => xdma_0_M_AXI_BVALID,
      m_axi_rdata(127 downto 0) => xdma_0_M_AXI_RDATA(127 downto 0),
      m_axi_rid(3 downto 0) => xdma_0_M_AXI_RID(3 downto 0),
      m_axi_rlast => xdma_0_M_AXI_RLAST,
      m_axi_rready => xdma_0_M_AXI_RREADY,
      m_axi_rresp(1 downto 0) => xdma_0_M_AXI_RRESP(1 downto 0),
      m_axi_rvalid => xdma_0_M_AXI_RVALID,
      m_axi_wdata(127 downto 0) => xdma_0_M_AXI_WDATA(127 downto 0),
      m_axi_wlast => xdma_0_M_AXI_WLAST,
      m_axi_wready => xdma_0_M_AXI_WREADY,
      m_axi_wstrb(15 downto 0) => xdma_0_M_AXI_WSTRB(15 downto 0),
      m_axi_wvalid => xdma_0_M_AXI_WVALID,
      m_axil_araddr(31 downto 0) => xdma_0_M_AXI_LITE_ARADDR(31 downto 0),
      m_axil_arprot(2 downto 0) => xdma_0_M_AXI_LITE_ARPROT(2 downto 0),
      m_axil_arready => xdma_0_M_AXI_LITE_ARREADY,
      m_axil_arvalid => xdma_0_M_AXI_LITE_ARVALID,
      m_axil_awaddr(31 downto 0) => xdma_0_M_AXI_LITE_AWADDR(31 downto 0),
      m_axil_awprot(2 downto 0) => xdma_0_M_AXI_LITE_AWPROT(2 downto 0),
      m_axil_awready => xdma_0_M_AXI_LITE_AWREADY,
      m_axil_awvalid => xdma_0_M_AXI_LITE_AWVALID,
      m_axil_bready => xdma_0_M_AXI_LITE_BREADY,
      m_axil_bresp(1 downto 0) => xdma_0_M_AXI_LITE_BRESP(1 downto 0),
      m_axil_bvalid => xdma_0_M_AXI_LITE_BVALID,
      m_axil_rdata(31 downto 0) => xdma_0_M_AXI_LITE_RDATA(31 downto 0),
      m_axil_rready => xdma_0_M_AXI_LITE_RREADY,
      m_axil_rresp(1 downto 0) => xdma_0_M_AXI_LITE_RRESP(1 downto 0),
      m_axil_rvalid => xdma_0_M_AXI_LITE_RVALID,
      m_axil_wdata(31 downto 0) => xdma_0_M_AXI_LITE_WDATA(31 downto 0),
      m_axil_wready => xdma_0_M_AXI_LITE_WREADY,
      m_axil_wstrb(3 downto 0) => xdma_0_M_AXI_LITE_WSTRB(3 downto 0),
      m_axil_wvalid => xdma_0_M_AXI_LITE_WVALID,
      msi_enable => NLW_xdma_0_msi_enable_UNCONNECTED,
      msi_vector_width(2 downto 0) => NLW_xdma_0_msi_vector_width_UNCONNECTED(2 downto 0),
      pci_exp_rxn(3 downto 0) => Conn1_rxn(3 downto 0),
      pci_exp_rxp(3 downto 0) => Conn1_rxp(3 downto 0),
      pci_exp_txn(3 downto 0) => Conn1_txn(3 downto 0),
      pci_exp_txp(3 downto 0) => Conn1_txp(3 downto 0),
      sys_clk => pi_pcie_sys_clk_1,
      sys_clk_gt => pi_pcie_sys_clk_gt_1,
      sys_rst_n => pi_pcie_areset_n_1,
      user_lnk_up => xdma_0_user_lnk_up,
      usr_irq_ack(15 downto 0) => xdma_0_usr_irq_ack(15 downto 0),
      usr_irq_req(15 downto 0) => pi_pcie_irq_req_1(15 downto 0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity sis8300ku_bsp_system is
  port (
    p_ddr4_act_n : out STD_LOGIC;
    p_ddr4_adr : out STD_LOGIC_VECTOR ( 16 downto 0 );
    p_ddr4_ba : out STD_LOGIC_VECTOR ( 1 downto 0 );
    p_ddr4_bg : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_ck_c : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_ck_t : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_dm_n : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    p_ddr4_dq : inout STD_LOGIC_VECTOR ( 63 downto 0 );
    p_ddr4_dqs_c : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    p_ddr4_dqs_t : inout STD_LOGIC_VECTOR ( 7 downto 0 );
    p_ddr4_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    p_ddr4_reset_n : out STD_LOGIC;
    p_m_axi4l_app_araddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_app_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_app_arready : in STD_LOGIC;
    p_m_axi4l_app_arvalid : out STD_LOGIC;
    p_m_axi4l_app_awaddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_app_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_app_awready : in STD_LOGIC;
    p_m_axi4l_app_awvalid : out STD_LOGIC;
    p_m_axi4l_app_bready : out STD_LOGIC;
    p_m_axi4l_app_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_app_bvalid : in STD_LOGIC;
    p_m_axi4l_app_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_app_rready : out STD_LOGIC;
    p_m_axi4l_app_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_app_rvalid : in STD_LOGIC;
    p_m_axi4l_app_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_app_wready : in STD_LOGIC;
    p_m_axi4l_app_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_m_axi4l_app_wvalid : out STD_LOGIC;
    p_m_axi4l_bsp_araddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_bsp_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_bsp_arready : in STD_LOGIC;
    p_m_axi4l_bsp_arvalid : out STD_LOGIC;
    p_m_axi4l_bsp_awaddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_bsp_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_bsp_awready : in STD_LOGIC;
    p_m_axi4l_bsp_awvalid : out STD_LOGIC;
    p_m_axi4l_bsp_bready : out STD_LOGIC;
    p_m_axi4l_bsp_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_bsp_bvalid : in STD_LOGIC;
    p_m_axi4l_bsp_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_bsp_rready : out STD_LOGIC;
    p_m_axi4l_bsp_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_bsp_rvalid : in STD_LOGIC;
    p_m_axi4l_bsp_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_bsp_wready : in STD_LOGIC;
    p_m_axi4l_bsp_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_m_axi4l_bsp_wvalid : out STD_LOGIC;
    p_pcie_mgt_rxn : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_pcie_mgt_rxp : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_pcie_mgt_txn : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_pcie_mgt_txp : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_s_axi4_ddr_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    p_s_axi4_ddr_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    p_s_axi4_ddr_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_arready : out STD_LOGIC;
    p_s_axi4_ddr_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_arvalid : in STD_LOGIC;
    p_s_axi4_ddr_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_s_axi4_ddr_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    p_s_axi4_ddr_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    p_s_axi4_ddr_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_awready : out STD_LOGIC;
    p_s_axi4_ddr_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_awvalid : in STD_LOGIC;
    p_s_axi4_ddr_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_bready : in STD_LOGIC;
    p_s_axi4_ddr_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_bvalid : out STD_LOGIC;
    p_s_axi4_ddr_rdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    p_s_axi4_ddr_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_rlast : out STD_LOGIC;
    p_s_axi4_ddr_rready : in STD_LOGIC;
    p_s_axi4_ddr_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_rvalid : out STD_LOGIC;
    p_s_axi4_ddr_wdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    p_s_axi4_ddr_wlast : in STD_LOGIC;
    p_s_axi4_ddr_wready : out STD_LOGIC;
    p_s_axi4_ddr_wstrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_s_axi4_ddr_wvalid : in STD_LOGIC;
    pi_ddr4_sys_clk : in STD_LOGIC;
    pi_m_axi4l_app_aclk : in STD_LOGIC;
    pi_pcie_areset_n : in STD_LOGIC;
    pi_pcie_irq_req : in STD_LOGIC_VECTOR ( 15 downto 0 );
    pi_pcie_sys_clk : in STD_LOGIC;
    pi_pcie_sys_clk_gt : in STD_LOGIC;
    po_ddr_calib_done : out STD_LOGIC;
    po_m_axi4_aclk : out STD_LOGIC;
    po_m_axi4_areset_n : out STD_LOGIC;
    po_pcie_irq_ack : out STD_LOGIC_VECTOR ( 15 downto 0 );
    po_pcie_link_up : out STD_LOGIC;
    po_s_axi4_ddr_aclk : out STD_LOGIC;
    po_s_axi4_ddr_areset_n : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of sis8300ku_bsp_system : entity is "sis8300ku_bsp_system,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=sis8300ku_bsp_system,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=9,numReposBlks=7,numNonXlnxBlks=0,numHierBlks=2,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of sis8300ku_bsp_system : entity is "sis8300ku_bsp_system.hwdef";
end sis8300ku_bsp_system;

architecture STRUCTURE of sis8300ku_bsp_system is
  signal ddr_p_ddr4_ACT_N : STD_LOGIC;
  signal ddr_p_ddr4_ADR : STD_LOGIC_VECTOR ( 16 downto 0 );
  signal ddr_p_ddr4_BA : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal ddr_p_ddr4_BG : STD_LOGIC_VECTOR ( 0 to 0 );
  signal ddr_p_ddr4_CKE : STD_LOGIC_VECTOR ( 0 to 0 );
  signal ddr_p_ddr4_CK_C : STD_LOGIC_VECTOR ( 0 to 0 );
  signal ddr_p_ddr4_CK_T : STD_LOGIC_VECTOR ( 0 to 0 );
  signal ddr_p_ddr4_CS_N : STD_LOGIC_VECTOR ( 0 to 0 );
  signal ddr_p_ddr4_DM_N : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal ddr_p_ddr4_DQ : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal ddr_p_ddr4_DQS_C : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal ddr_p_ddr4_DQS_T : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal ddr_p_ddr4_ODT : STD_LOGIC_VECTOR ( 0 to 0 );
  signal ddr_p_ddr4_RESET_N : STD_LOGIC;
  signal ddr_po_ddr_calib_done : STD_LOGIC;
  signal ddr_po_s_axi4_ddr_aclk : STD_LOGIC;
  signal ddr_po_s_axi4_ddr_areset_n : STD_LOGIC_VECTOR ( 0 to 0 );
  signal p_s_axi4_ddr_1_ARADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal p_s_axi4_ddr_1_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal p_s_axi4_ddr_1_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal p_s_axi4_ddr_1_ARID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal p_s_axi4_ddr_1_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal p_s_axi4_ddr_1_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal p_s_axi4_ddr_1_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal p_s_axi4_ddr_1_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal p_s_axi4_ddr_1_ARREADY : STD_LOGIC;
  signal p_s_axi4_ddr_1_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal p_s_axi4_ddr_1_ARVALID : STD_LOGIC;
  signal p_s_axi4_ddr_1_AWADDR : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal p_s_axi4_ddr_1_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal p_s_axi4_ddr_1_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal p_s_axi4_ddr_1_AWID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal p_s_axi4_ddr_1_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal p_s_axi4_ddr_1_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal p_s_axi4_ddr_1_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal p_s_axi4_ddr_1_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal p_s_axi4_ddr_1_AWREADY : STD_LOGIC;
  signal p_s_axi4_ddr_1_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal p_s_axi4_ddr_1_AWVALID : STD_LOGIC;
  signal p_s_axi4_ddr_1_BID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal p_s_axi4_ddr_1_BREADY : STD_LOGIC;
  signal p_s_axi4_ddr_1_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal p_s_axi4_ddr_1_BVALID : STD_LOGIC;
  signal p_s_axi4_ddr_1_RDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal p_s_axi4_ddr_1_RID : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal p_s_axi4_ddr_1_RLAST : STD_LOGIC;
  signal p_s_axi4_ddr_1_RREADY : STD_LOGIC;
  signal p_s_axi4_ddr_1_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal p_s_axi4_ddr_1_RVALID : STD_LOGIC;
  signal p_s_axi4_ddr_1_WDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal p_s_axi4_ddr_1_WLAST : STD_LOGIC;
  signal p_s_axi4_ddr_1_WREADY : STD_LOGIC;
  signal p_s_axi4_ddr_1_WSTRB : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal p_s_axi4_ddr_1_WVALID : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_ARADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal pcie_m_axi_dma_ddr_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_m_axi_dma_ddr_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_m_axi_dma_ddr_ARID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_m_axi_dma_ddr_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal pcie_m_axi_dma_ddr_ARLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal pcie_m_axi_dma_ddr_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal pcie_m_axi_dma_ddr_ARQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_m_axi_dma_ddr_ARREADY : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal pcie_m_axi_dma_ddr_ARUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal pcie_m_axi_dma_ddr_ARVALID : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_AWADDR : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal pcie_m_axi_dma_ddr_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_m_axi_dma_ddr_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_m_axi_dma_ddr_AWID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_m_axi_dma_ddr_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal pcie_m_axi_dma_ddr_AWLOCK : STD_LOGIC_VECTOR ( 0 to 0 );
  signal pcie_m_axi_dma_ddr_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal pcie_m_axi_dma_ddr_AWQOS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_m_axi_dma_ddr_AWREADY : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal pcie_m_axi_dma_ddr_AWUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal pcie_m_axi_dma_ddr_AWVALID : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_BID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_m_axi_dma_ddr_BREADY : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_m_axi_dma_ddr_BUSER : STD_LOGIC_VECTOR ( 113 downto 0 );
  signal pcie_m_axi_dma_ddr_BVALID : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_RDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal pcie_m_axi_dma_ddr_RID : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_m_axi_dma_ddr_RLAST : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_RREADY : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_m_axi_dma_ddr_RUSER : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal pcie_m_axi_dma_ddr_RVALID : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_WDATA : STD_LOGIC_VECTOR ( 255 downto 0 );
  signal pcie_m_axi_dma_ddr_WLAST : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_WREADY : STD_LOGIC;
  signal pcie_m_axi_dma_ddr_WSTRB : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal pcie_m_axi_dma_ddr_WUSER : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal pcie_m_axi_dma_ddr_WVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_app_ARADDR : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal pcie_p_m_axi4l_app_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal pcie_p_m_axi4l_app_ARREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_app_ARVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_app_AWADDR : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal pcie_p_m_axi4l_app_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal pcie_p_m_axi4l_app_AWREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_app_AWVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_app_BREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_app_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_p_m_axi4l_app_BVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_app_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal pcie_p_m_axi4l_app_RREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_app_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_p_m_axi4l_app_RVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_app_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal pcie_p_m_axi4l_app_WREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_app_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_p_m_axi4l_app_WVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_ARADDR : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal pcie_p_m_axi4l_bsp_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal pcie_p_m_axi4l_bsp_ARREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_ARVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_AWADDR : STD_LOGIC_VECTOR ( 22 downto 0 );
  signal pcie_p_m_axi4l_bsp_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal pcie_p_m_axi4l_bsp_AWREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_AWVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_BREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_p_m_axi4l_bsp_BVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal pcie_p_m_axi4l_bsp_RREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal pcie_p_m_axi4l_bsp_RVALID : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal pcie_p_m_axi4l_bsp_WREADY : STD_LOGIC;
  signal pcie_p_m_axi4l_bsp_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_p_m_axi4l_bsp_WVALID : STD_LOGIC;
  signal pcie_p_pcie_mgt_rxn : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_p_pcie_mgt_rxp : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_p_pcie_mgt_txn : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_p_pcie_mgt_txp : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal pcie_po_m_axi4_aclk : STD_LOGIC;
  signal pcie_po_m_axi4_areset_n : STD_LOGIC;
  signal pcie_po_pcie_irq_ack : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal pcie_po_pcie_link_up : STD_LOGIC;
  signal pi_ddr4_sys_clk_1 : STD_LOGIC;
  signal pi_m_axi4l_app_aclk_1 : STD_LOGIC;
  signal pi_pcie_areset_n_1 : STD_LOGIC;
  signal pi_pcie_irq_req_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal pi_pcie_sys_clk_1 : STD_LOGIC;
  signal pi_pcie_sys_clk_gt_1 : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of p_ddr4_act_n : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 ACT_N";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of p_ddr4_act_n : signal is "XIL_INTERFACENAME p_ddr4, AXI_ARBITRATION_SCHEME RD_PRI_REG, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 11, CS_ENABLED true, CUSTOM_PARTS custom_parts_ddr4.csv, DATA_MASK_ENABLED DM_NO_DBI, DATA_WIDTH 64, MEMORY_PART H5AN4G6NAFR, MEMORY_TYPE Components, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250";
  attribute X_INTERFACE_INFO of p_ddr4_reset_n : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 RESET_N";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_arready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app ARREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_arvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app ARVALID";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_awready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app AWREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_awvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app AWVALID";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_bready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app BREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_bvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app BVALID";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_rready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app RREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_rvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app RVALID";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_wready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app WREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_wvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app WVALID";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_arready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp ARREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_arvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp ARVALID";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_awready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp AWREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_awvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp AWVALID";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_bready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp BREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_bvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp BVALID";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_rready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp RREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_rvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp RVALID";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_wready : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp WREADY";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_wvalid : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp WVALID";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arready : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARREADY";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arvalid : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARVALID";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awready : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWREADY";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awvalid : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWVALID";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_bready : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr BREADY";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_bvalid : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr BVALID";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_rlast : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr RLAST";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_rready : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr RREADY";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_rvalid : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr RVALID";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_wlast : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr WLAST";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_wready : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr WREADY";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_wvalid : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr WVALID";
  attribute X_INTERFACE_INFO of pi_ddr4_sys_clk : signal is "xilinx.com:signal:clock:1.0 CLK.PI_DDR4_SYS_CLK CLK";
  attribute X_INTERFACE_PARAMETER of pi_ddr4_sys_clk : signal is "XIL_INTERFACENAME CLK.PI_DDR4_SYS_CLK, CLK_DOMAIN sis8300ku_bsp_system_pi_ddr4_sys_clk, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of pi_m_axi4l_app_aclk : signal is "xilinx.com:signal:clock:1.0 CLK.PI_M_AXI4L_APP_ACLK CLK";
  attribute X_INTERFACE_PARAMETER of pi_m_axi4l_app_aclk : signal is "XIL_INTERFACENAME CLK.PI_M_AXI4L_APP_ACLK, ASSOCIATED_BUSIF p_m_axi4l_app, CLK_DOMAIN sis8300ku_bsp_system_pi_m_axi4l_app_aclk, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of pi_pcie_areset_n : signal is "xilinx.com:signal:reset:1.0 RST.PI_PCIE_ARESET_N RST";
  attribute X_INTERFACE_PARAMETER of pi_pcie_areset_n : signal is "XIL_INTERFACENAME RST.PI_PCIE_ARESET_N, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of pi_pcie_sys_clk : signal is "xilinx.com:signal:clock:1.0 CLK.PI_PCIE_SYS_CLK CLK";
  attribute X_INTERFACE_PARAMETER of pi_pcie_sys_clk : signal is "XIL_INTERFACENAME CLK.PI_PCIE_SYS_CLK, CLK_DOMAIN sis8300ku_bsp_system_pi_pcie_sys_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of pi_pcie_sys_clk_gt : signal is "xilinx.com:signal:clock:1.0 CLK.PI_PCIE_SYS_CLK_GT CLK";
  attribute X_INTERFACE_PARAMETER of pi_pcie_sys_clk_gt : signal is "XIL_INTERFACENAME CLK.PI_PCIE_SYS_CLK_GT, CLK_DOMAIN sis8300ku_bsp_system_pi_pcie_sys_clk_gt, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of po_m_axi4_aclk : signal is "xilinx.com:signal:clock:1.0 CLK.PO_M_AXI4_ACLK CLK";
  attribute X_INTERFACE_PARAMETER of po_m_axi4_aclk : signal is "XIL_INTERFACENAME CLK.PO_M_AXI4_ACLK, ASSOCIATED_BUSIF p_m_axi4l_bsp, CLK_DOMAIN sis8300ku_bsp_system_xdma_0_0_axi_aclk, FREQ_HZ 125000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of po_m_axi4_areset_n : signal is "xilinx.com:signal:reset:1.0 RST.PO_M_AXI4_ARESET_N RST";
  attribute X_INTERFACE_PARAMETER of po_m_axi4_areset_n : signal is "XIL_INTERFACENAME RST.PO_M_AXI4_ARESET_N, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of po_s_axi4_ddr_aclk : signal is "xilinx.com:signal:clock:1.0 CLK.PO_S_AXI4_DDR_ACLK CLK";
  attribute X_INTERFACE_PARAMETER of po_s_axi4_ddr_aclk : signal is "XIL_INTERFACENAME CLK.PO_S_AXI4_DDR_ACLK, ASSOCIATED_BUSIF p_s_axi4_ddr, ASSOCIATED_RESET po_s_axi4_ddr_areset_n, CLK_DOMAIN sis8300ku_bsp_system_ddr4_0_0_c0_ddr4_ui_clk, FREQ_HZ 200000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.00";
  attribute X_INTERFACE_INFO of p_ddr4_adr : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 ADR";
  attribute X_INTERFACE_INFO of p_ddr4_ba : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 BA";
  attribute X_INTERFACE_INFO of p_ddr4_bg : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 BG";
  attribute X_INTERFACE_INFO of p_ddr4_ck_c : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 CK_C";
  attribute X_INTERFACE_INFO of p_ddr4_ck_t : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 CK_T";
  attribute X_INTERFACE_INFO of p_ddr4_cke : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 CKE";
  attribute X_INTERFACE_INFO of p_ddr4_cs_n : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 CS_N";
  attribute X_INTERFACE_INFO of p_ddr4_dm_n : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 DM_N";
  attribute X_INTERFACE_INFO of p_ddr4_dq : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 DQ";
  attribute X_INTERFACE_INFO of p_ddr4_dqs_c : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 DQS_C";
  attribute X_INTERFACE_INFO of p_ddr4_dqs_t : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 DQS_T";
  attribute X_INTERFACE_INFO of p_ddr4_odt : signal is "xilinx.com:interface:ddr4:1.0 p_ddr4 ODT";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_araddr : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app ARADDR";
  attribute X_INTERFACE_PARAMETER of p_m_axi4l_app_araddr : signal is "XIL_INTERFACENAME p_m_axi4l_app, ADDR_WIDTH 23, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN sis8300ku_bsp_system_pi_m_axi4l_app_aclk, DATA_WIDTH 32, FREQ_HZ 125000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 32, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 16, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_arprot : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app ARPROT";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_awaddr : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app AWADDR";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_awprot : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app AWPROT";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_bresp : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app BRESP";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_rdata : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app RDATA";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_rresp : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app RRESP";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_wdata : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app WDATA";
  attribute X_INTERFACE_INFO of p_m_axi4l_app_wstrb : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_app WSTRB";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_araddr : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp ARADDR";
  attribute X_INTERFACE_PARAMETER of p_m_axi4l_bsp_araddr : signal is "XIL_INTERFACENAME p_m_axi4l_bsp, ADDR_WIDTH 23, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN sis8300ku_bsp_system_xdma_0_0_axi_aclk, DATA_WIDTH 32, FREQ_HZ 125000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 32, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 16, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_arprot : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp ARPROT";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_awaddr : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp AWADDR";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_awprot : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp AWPROT";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_bresp : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp BRESP";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_rdata : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp RDATA";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_rresp : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp RRESP";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_wdata : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp WDATA";
  attribute X_INTERFACE_INFO of p_m_axi4l_bsp_wstrb : signal is "xilinx.com:interface:aximm:1.0 p_m_axi4l_bsp WSTRB";
  attribute X_INTERFACE_INFO of p_pcie_mgt_rxn : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 p_pcie_mgt rxn";
  attribute X_INTERFACE_INFO of p_pcie_mgt_rxp : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 p_pcie_mgt rxp";
  attribute X_INTERFACE_INFO of p_pcie_mgt_txn : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 p_pcie_mgt txn";
  attribute X_INTERFACE_INFO of p_pcie_mgt_txp : signal is "xilinx.com:interface:pcie_7x_mgt:1.0 p_pcie_mgt txp";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_araddr : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARADDR";
  attribute X_INTERFACE_PARAMETER of p_s_axi4_ddr_araddr : signal is "XIL_INTERFACENAME p_s_axi4_ddr, ADDR_WIDTH 32, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN sis8300ku_bsp_system_ddr4_0_0_c0_ddr4_ui_clk, DATA_WIDTH 256, FREQ_HZ 200000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 4, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.00, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arburst : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARBURST";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arcache : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARCACHE";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arid : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARID";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arlen : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARLEN";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arlock : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARLOCK";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arprot : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARPROT";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arqos : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARQOS";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_arsize : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr ARSIZE";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awaddr : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWADDR";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awburst : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWBURST";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awcache : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWCACHE";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awid : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWID";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awlen : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWLEN";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awlock : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWLOCK";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awprot : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWPROT";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awqos : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWQOS";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_awsize : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr AWSIZE";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_bid : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr BID";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_bresp : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr BRESP";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_rdata : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr RDATA";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_rid : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr RID";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_rresp : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr RRESP";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_wdata : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr WDATA";
  attribute X_INTERFACE_INFO of p_s_axi4_ddr_wstrb : signal is "xilinx.com:interface:aximm:1.0 p_s_axi4_ddr WSTRB";
  attribute X_INTERFACE_INFO of pi_pcie_irq_req : signal is "xilinx.com:signal:interrupt:1.0 INTR.PI_PCIE_IRQ_REQ INTERRUPT";
  attribute X_INTERFACE_PARAMETER of pi_pcie_irq_req : signal is "XIL_INTERFACENAME INTR.PI_PCIE_IRQ_REQ, PortWidth 16, SENSITIVITY EDGE_RISING";
  attribute X_INTERFACE_INFO of po_s_axi4_ddr_areset_n : signal is "xilinx.com:signal:reset:1.0 RST.PO_S_AXI4_DDR_ARESET_N RST";
  attribute X_INTERFACE_PARAMETER of po_s_axi4_ddr_areset_n : signal is "XIL_INTERFACENAME RST.PO_S_AXI4_DDR_ARESET_N, INSERT_VIP 0, POLARITY ACTIVE_LOW";
begin
  p_ddr4_act_n <= ddr_p_ddr4_ACT_N;
  p_ddr4_adr(16 downto 0) <= ddr_p_ddr4_ADR(16 downto 0);
  p_ddr4_ba(1 downto 0) <= ddr_p_ddr4_BA(1 downto 0);
  p_ddr4_bg(0) <= ddr_p_ddr4_BG(0);
  p_ddr4_ck_c(0) <= ddr_p_ddr4_CK_C(0);
  p_ddr4_ck_t(0) <= ddr_p_ddr4_CK_T(0);
  p_ddr4_cke(0) <= ddr_p_ddr4_CKE(0);
  p_ddr4_cs_n(0) <= ddr_p_ddr4_CS_N(0);
  p_ddr4_odt(0) <= ddr_p_ddr4_ODT(0);
  p_ddr4_reset_n <= ddr_p_ddr4_RESET_N;
  p_m_axi4l_app_araddr(22 downto 0) <= pcie_p_m_axi4l_app_ARADDR(22 downto 0);
  p_m_axi4l_app_arprot(2 downto 0) <= pcie_p_m_axi4l_app_ARPROT(2 downto 0);
  p_m_axi4l_app_arvalid <= pcie_p_m_axi4l_app_ARVALID;
  p_m_axi4l_app_awaddr(22 downto 0) <= pcie_p_m_axi4l_app_AWADDR(22 downto 0);
  p_m_axi4l_app_awprot(2 downto 0) <= pcie_p_m_axi4l_app_AWPROT(2 downto 0);
  p_m_axi4l_app_awvalid <= pcie_p_m_axi4l_app_AWVALID;
  p_m_axi4l_app_bready <= pcie_p_m_axi4l_app_BREADY;
  p_m_axi4l_app_rready <= pcie_p_m_axi4l_app_RREADY;
  p_m_axi4l_app_wdata(31 downto 0) <= pcie_p_m_axi4l_app_WDATA(31 downto 0);
  p_m_axi4l_app_wstrb(3 downto 0) <= pcie_p_m_axi4l_app_WSTRB(3 downto 0);
  p_m_axi4l_app_wvalid <= pcie_p_m_axi4l_app_WVALID;
  p_m_axi4l_bsp_araddr(22 downto 0) <= pcie_p_m_axi4l_bsp_ARADDR(22 downto 0);
  p_m_axi4l_bsp_arprot(2 downto 0) <= pcie_p_m_axi4l_bsp_ARPROT(2 downto 0);
  p_m_axi4l_bsp_arvalid <= pcie_p_m_axi4l_bsp_ARVALID;
  p_m_axi4l_bsp_awaddr(22 downto 0) <= pcie_p_m_axi4l_bsp_AWADDR(22 downto 0);
  p_m_axi4l_bsp_awprot(2 downto 0) <= pcie_p_m_axi4l_bsp_AWPROT(2 downto 0);
  p_m_axi4l_bsp_awvalid <= pcie_p_m_axi4l_bsp_AWVALID;
  p_m_axi4l_bsp_bready <= pcie_p_m_axi4l_bsp_BREADY;
  p_m_axi4l_bsp_rready <= pcie_p_m_axi4l_bsp_RREADY;
  p_m_axi4l_bsp_wdata(31 downto 0) <= pcie_p_m_axi4l_bsp_WDATA(31 downto 0);
  p_m_axi4l_bsp_wstrb(3 downto 0) <= pcie_p_m_axi4l_bsp_WSTRB(3 downto 0);
  p_m_axi4l_bsp_wvalid <= pcie_p_m_axi4l_bsp_WVALID;
  p_pcie_mgt_txn(3 downto 0) <= pcie_p_pcie_mgt_txn(3 downto 0);
  p_pcie_mgt_txp(3 downto 0) <= pcie_p_pcie_mgt_txp(3 downto 0);
  p_s_axi4_ddr_1_ARADDR(31 downto 0) <= p_s_axi4_ddr_araddr(31 downto 0);
  p_s_axi4_ddr_1_ARBURST(1 downto 0) <= p_s_axi4_ddr_arburst(1 downto 0);
  p_s_axi4_ddr_1_ARCACHE(3 downto 0) <= p_s_axi4_ddr_arcache(3 downto 0);
  p_s_axi4_ddr_1_ARID(3 downto 0) <= p_s_axi4_ddr_arid(3 downto 0);
  p_s_axi4_ddr_1_ARLEN(7 downto 0) <= p_s_axi4_ddr_arlen(7 downto 0);
  p_s_axi4_ddr_1_ARLOCK(0) <= p_s_axi4_ddr_arlock(0);
  p_s_axi4_ddr_1_ARPROT(2 downto 0) <= p_s_axi4_ddr_arprot(2 downto 0);
  p_s_axi4_ddr_1_ARQOS(3 downto 0) <= p_s_axi4_ddr_arqos(3 downto 0);
  p_s_axi4_ddr_1_ARSIZE(2 downto 0) <= p_s_axi4_ddr_arsize(2 downto 0);
  p_s_axi4_ddr_1_ARVALID <= p_s_axi4_ddr_arvalid;
  p_s_axi4_ddr_1_AWADDR(31 downto 0) <= p_s_axi4_ddr_awaddr(31 downto 0);
  p_s_axi4_ddr_1_AWBURST(1 downto 0) <= p_s_axi4_ddr_awburst(1 downto 0);
  p_s_axi4_ddr_1_AWCACHE(3 downto 0) <= p_s_axi4_ddr_awcache(3 downto 0);
  p_s_axi4_ddr_1_AWID(3 downto 0) <= p_s_axi4_ddr_awid(3 downto 0);
  p_s_axi4_ddr_1_AWLEN(7 downto 0) <= p_s_axi4_ddr_awlen(7 downto 0);
  p_s_axi4_ddr_1_AWLOCK(0) <= p_s_axi4_ddr_awlock(0);
  p_s_axi4_ddr_1_AWPROT(2 downto 0) <= p_s_axi4_ddr_awprot(2 downto 0);
  p_s_axi4_ddr_1_AWQOS(3 downto 0) <= p_s_axi4_ddr_awqos(3 downto 0);
  p_s_axi4_ddr_1_AWSIZE(2 downto 0) <= p_s_axi4_ddr_awsize(2 downto 0);
  p_s_axi4_ddr_1_AWVALID <= p_s_axi4_ddr_awvalid;
  p_s_axi4_ddr_1_BREADY <= p_s_axi4_ddr_bready;
  p_s_axi4_ddr_1_RREADY <= p_s_axi4_ddr_rready;
  p_s_axi4_ddr_1_WDATA(255 downto 0) <= p_s_axi4_ddr_wdata(255 downto 0);
  p_s_axi4_ddr_1_WLAST <= p_s_axi4_ddr_wlast;
  p_s_axi4_ddr_1_WSTRB(31 downto 0) <= p_s_axi4_ddr_wstrb(31 downto 0);
  p_s_axi4_ddr_1_WVALID <= p_s_axi4_ddr_wvalid;
  p_s_axi4_ddr_arready <= p_s_axi4_ddr_1_ARREADY;
  p_s_axi4_ddr_awready <= p_s_axi4_ddr_1_AWREADY;
  p_s_axi4_ddr_bid(3 downto 0) <= p_s_axi4_ddr_1_BID(3 downto 0);
  p_s_axi4_ddr_bresp(1 downto 0) <= p_s_axi4_ddr_1_BRESP(1 downto 0);
  p_s_axi4_ddr_bvalid <= p_s_axi4_ddr_1_BVALID;
  p_s_axi4_ddr_rdata(255 downto 0) <= p_s_axi4_ddr_1_RDATA(255 downto 0);
  p_s_axi4_ddr_rid(3 downto 0) <= p_s_axi4_ddr_1_RID(3 downto 0);
  p_s_axi4_ddr_rlast <= p_s_axi4_ddr_1_RLAST;
  p_s_axi4_ddr_rresp(1 downto 0) <= p_s_axi4_ddr_1_RRESP(1 downto 0);
  p_s_axi4_ddr_rvalid <= p_s_axi4_ddr_1_RVALID;
  p_s_axi4_ddr_wready <= p_s_axi4_ddr_1_WREADY;
  pcie_p_m_axi4l_app_ARREADY <= p_m_axi4l_app_arready;
  pcie_p_m_axi4l_app_AWREADY <= p_m_axi4l_app_awready;
  pcie_p_m_axi4l_app_BRESP(1 downto 0) <= p_m_axi4l_app_bresp(1 downto 0);
  pcie_p_m_axi4l_app_BVALID <= p_m_axi4l_app_bvalid;
  pcie_p_m_axi4l_app_RDATA(31 downto 0) <= p_m_axi4l_app_rdata(31 downto 0);
  pcie_p_m_axi4l_app_RRESP(1 downto 0) <= p_m_axi4l_app_rresp(1 downto 0);
  pcie_p_m_axi4l_app_RVALID <= p_m_axi4l_app_rvalid;
  pcie_p_m_axi4l_app_WREADY <= p_m_axi4l_app_wready;
  pcie_p_m_axi4l_bsp_ARREADY <= p_m_axi4l_bsp_arready;
  pcie_p_m_axi4l_bsp_AWREADY <= p_m_axi4l_bsp_awready;
  pcie_p_m_axi4l_bsp_BRESP(1 downto 0) <= p_m_axi4l_bsp_bresp(1 downto 0);
  pcie_p_m_axi4l_bsp_BVALID <= p_m_axi4l_bsp_bvalid;
  pcie_p_m_axi4l_bsp_RDATA(31 downto 0) <= p_m_axi4l_bsp_rdata(31 downto 0);
  pcie_p_m_axi4l_bsp_RRESP(1 downto 0) <= p_m_axi4l_bsp_rresp(1 downto 0);
  pcie_p_m_axi4l_bsp_RVALID <= p_m_axi4l_bsp_rvalid;
  pcie_p_m_axi4l_bsp_WREADY <= p_m_axi4l_bsp_wready;
  pcie_p_pcie_mgt_rxn(3 downto 0) <= p_pcie_mgt_rxn(3 downto 0);
  pcie_p_pcie_mgt_rxp(3 downto 0) <= p_pcie_mgt_rxp(3 downto 0);
  pi_ddr4_sys_clk_1 <= pi_ddr4_sys_clk;
  pi_m_axi4l_app_aclk_1 <= pi_m_axi4l_app_aclk;
  pi_pcie_areset_n_1 <= pi_pcie_areset_n;
  pi_pcie_irq_req_1(15 downto 0) <= pi_pcie_irq_req(15 downto 0);
  pi_pcie_sys_clk_1 <= pi_pcie_sys_clk;
  pi_pcie_sys_clk_gt_1 <= pi_pcie_sys_clk_gt;
  po_ddr_calib_done <= ddr_po_ddr_calib_done;
  po_m_axi4_aclk <= pcie_po_m_axi4_aclk;
  po_m_axi4_areset_n <= pcie_po_m_axi4_areset_n;
  po_pcie_irq_ack(15 downto 0) <= pcie_po_pcie_irq_ack(15 downto 0);
  po_pcie_link_up <= pcie_po_pcie_link_up;
  po_s_axi4_ddr_aclk <= ddr_po_s_axi4_ddr_aclk;
  po_s_axi4_ddr_areset_n(0) <= ddr_po_s_axi4_ddr_areset_n(0);
ddr: entity work.ddr_imp_QC2Z9C
     port map (
      p_ddr4_act_n => ddr_p_ddr4_ACT_N,
      p_ddr4_adr(16 downto 0) => ddr_p_ddr4_ADR(16 downto 0),
      p_ddr4_ba(1 downto 0) => ddr_p_ddr4_BA(1 downto 0),
      p_ddr4_bg(0) => ddr_p_ddr4_BG(0),
      p_ddr4_ck_c(0) => ddr_p_ddr4_CK_C(0),
      p_ddr4_ck_t(0) => ddr_p_ddr4_CK_T(0),
      p_ddr4_cke(0) => ddr_p_ddr4_CKE(0),
      p_ddr4_cs_n(0) => ddr_p_ddr4_CS_N(0),
      p_ddr4_dm_n(7 downto 0) => p_ddr4_dm_n(7 downto 0),
      p_ddr4_dq(63 downto 0) => p_ddr4_dq(63 downto 0),
      p_ddr4_dqs_c(7 downto 0) => p_ddr4_dqs_c(7 downto 0),
      p_ddr4_dqs_t(7 downto 0) => p_ddr4_dqs_t(7 downto 0),
      p_ddr4_odt(0) => ddr_p_ddr4_ODT(0),
      p_ddr4_reset_n => ddr_p_ddr4_RESET_N,
      p_s_axi4_ddr_araddr(31 downto 0) => p_s_axi4_ddr_1_ARADDR(31 downto 0),
      p_s_axi4_ddr_arburst(1 downto 0) => p_s_axi4_ddr_1_ARBURST(1 downto 0),
      p_s_axi4_ddr_arcache(3 downto 0) => p_s_axi4_ddr_1_ARCACHE(3 downto 0),
      p_s_axi4_ddr_arid(3 downto 0) => p_s_axi4_ddr_1_ARID(3 downto 0),
      p_s_axi4_ddr_arlen(7 downto 0) => p_s_axi4_ddr_1_ARLEN(7 downto 0),
      p_s_axi4_ddr_arlock(0) => p_s_axi4_ddr_1_ARLOCK(0),
      p_s_axi4_ddr_arprot(2 downto 0) => p_s_axi4_ddr_1_ARPROT(2 downto 0),
      p_s_axi4_ddr_arqos(3 downto 0) => p_s_axi4_ddr_1_ARQOS(3 downto 0),
      p_s_axi4_ddr_arready => p_s_axi4_ddr_1_ARREADY,
      p_s_axi4_ddr_arsize(2 downto 0) => p_s_axi4_ddr_1_ARSIZE(2 downto 0),
      p_s_axi4_ddr_arvalid => p_s_axi4_ddr_1_ARVALID,
      p_s_axi4_ddr_awaddr(31 downto 0) => p_s_axi4_ddr_1_AWADDR(31 downto 0),
      p_s_axi4_ddr_awburst(1 downto 0) => p_s_axi4_ddr_1_AWBURST(1 downto 0),
      p_s_axi4_ddr_awcache(3 downto 0) => p_s_axi4_ddr_1_AWCACHE(3 downto 0),
      p_s_axi4_ddr_awid(3 downto 0) => p_s_axi4_ddr_1_AWID(3 downto 0),
      p_s_axi4_ddr_awlen(7 downto 0) => p_s_axi4_ddr_1_AWLEN(7 downto 0),
      p_s_axi4_ddr_awlock(0) => p_s_axi4_ddr_1_AWLOCK(0),
      p_s_axi4_ddr_awprot(2 downto 0) => p_s_axi4_ddr_1_AWPROT(2 downto 0),
      p_s_axi4_ddr_awqos(3 downto 0) => p_s_axi4_ddr_1_AWQOS(3 downto 0),
      p_s_axi4_ddr_awready => p_s_axi4_ddr_1_AWREADY,
      p_s_axi4_ddr_awsize(2 downto 0) => p_s_axi4_ddr_1_AWSIZE(2 downto 0),
      p_s_axi4_ddr_awvalid => p_s_axi4_ddr_1_AWVALID,
      p_s_axi4_ddr_bid(3 downto 0) => p_s_axi4_ddr_1_BID(3 downto 0),
      p_s_axi4_ddr_bready => p_s_axi4_ddr_1_BREADY,
      p_s_axi4_ddr_bresp(1 downto 0) => p_s_axi4_ddr_1_BRESP(1 downto 0),
      p_s_axi4_ddr_bvalid => p_s_axi4_ddr_1_BVALID,
      p_s_axi4_ddr_rdata(255 downto 0) => p_s_axi4_ddr_1_RDATA(255 downto 0),
      p_s_axi4_ddr_rid(3 downto 0) => p_s_axi4_ddr_1_RID(3 downto 0),
      p_s_axi4_ddr_rlast => p_s_axi4_ddr_1_RLAST,
      p_s_axi4_ddr_rready => p_s_axi4_ddr_1_RREADY,
      p_s_axi4_ddr_rresp(1 downto 0) => p_s_axi4_ddr_1_RRESP(1 downto 0),
      p_s_axi4_ddr_rvalid => p_s_axi4_ddr_1_RVALID,
      p_s_axi4_ddr_wdata(255 downto 0) => p_s_axi4_ddr_1_WDATA(255 downto 0),
      p_s_axi4_ddr_wlast => p_s_axi4_ddr_1_WLAST,
      p_s_axi4_ddr_wready => p_s_axi4_ddr_1_WREADY,
      p_s_axi4_ddr_wstrb(31 downto 0) => p_s_axi4_ddr_1_WSTRB(31 downto 0),
      p_s_axi4_ddr_wvalid => p_s_axi4_ddr_1_WVALID,
      pi_ddr4_sys_clk => pi_ddr4_sys_clk_1,
      pi_s_axi4_pcie_aclk => pcie_po_m_axi4_aclk,
      po_ddr_calib_done => ddr_po_ddr_calib_done,
      po_s_axi4_ddr_aclk => ddr_po_s_axi4_ddr_aclk,
      po_s_axi4_ddr_areset_n(0) => ddr_po_s_axi4_ddr_areset_n(0),
      s_axi_pcie_dma_araddr(63 downto 0) => pcie_m_axi_dma_ddr_ARADDR(63 downto 0),
      s_axi_pcie_dma_arburst(1 downto 0) => pcie_m_axi_dma_ddr_ARBURST(1 downto 0),
      s_axi_pcie_dma_arcache(3 downto 0) => pcie_m_axi_dma_ddr_ARCACHE(3 downto 0),
      s_axi_pcie_dma_arid(1 downto 0) => pcie_m_axi_dma_ddr_ARID(1 downto 0),
      s_axi_pcie_dma_arlen(7 downto 0) => pcie_m_axi_dma_ddr_ARLEN(7 downto 0),
      s_axi_pcie_dma_arlock(0) => pcie_m_axi_dma_ddr_ARLOCK(0),
      s_axi_pcie_dma_arprot(2 downto 0) => pcie_m_axi_dma_ddr_ARPROT(2 downto 0),
      s_axi_pcie_dma_arqos(3 downto 0) => pcie_m_axi_dma_ddr_ARQOS(3 downto 0),
      s_axi_pcie_dma_arready => pcie_m_axi_dma_ddr_ARREADY,
      s_axi_pcie_dma_arsize(2 downto 0) => pcie_m_axi_dma_ddr_ARSIZE(2 downto 0),
      s_axi_pcie_dma_aruser(113 downto 0) => pcie_m_axi_dma_ddr_ARUSER(113 downto 0),
      s_axi_pcie_dma_arvalid => pcie_m_axi_dma_ddr_ARVALID,
      s_axi_pcie_dma_awaddr(63 downto 0) => pcie_m_axi_dma_ddr_AWADDR(63 downto 0),
      s_axi_pcie_dma_awburst(1 downto 0) => pcie_m_axi_dma_ddr_AWBURST(1 downto 0),
      s_axi_pcie_dma_awcache(3 downto 0) => pcie_m_axi_dma_ddr_AWCACHE(3 downto 0),
      s_axi_pcie_dma_awid(1 downto 0) => pcie_m_axi_dma_ddr_AWID(1 downto 0),
      s_axi_pcie_dma_awlen(7 downto 0) => pcie_m_axi_dma_ddr_AWLEN(7 downto 0),
      s_axi_pcie_dma_awlock(0) => pcie_m_axi_dma_ddr_AWLOCK(0),
      s_axi_pcie_dma_awprot(2 downto 0) => pcie_m_axi_dma_ddr_AWPROT(2 downto 0),
      s_axi_pcie_dma_awqos(3 downto 0) => pcie_m_axi_dma_ddr_AWQOS(3 downto 0),
      s_axi_pcie_dma_awready => pcie_m_axi_dma_ddr_AWREADY,
      s_axi_pcie_dma_awsize(2 downto 0) => pcie_m_axi_dma_ddr_AWSIZE(2 downto 0),
      s_axi_pcie_dma_awuser(113 downto 0) => pcie_m_axi_dma_ddr_AWUSER(113 downto 0),
      s_axi_pcie_dma_awvalid => pcie_m_axi_dma_ddr_AWVALID,
      s_axi_pcie_dma_bid(1 downto 0) => pcie_m_axi_dma_ddr_BID(1 downto 0),
      s_axi_pcie_dma_bready => pcie_m_axi_dma_ddr_BREADY,
      s_axi_pcie_dma_bresp(1 downto 0) => pcie_m_axi_dma_ddr_BRESP(1 downto 0),
      s_axi_pcie_dma_buser(113 downto 0) => pcie_m_axi_dma_ddr_BUSER(113 downto 0),
      s_axi_pcie_dma_bvalid => pcie_m_axi_dma_ddr_BVALID,
      s_axi_pcie_dma_rdata(255 downto 0) => pcie_m_axi_dma_ddr_RDATA(255 downto 0),
      s_axi_pcie_dma_rid(1 downto 0) => pcie_m_axi_dma_ddr_RID(1 downto 0),
      s_axi_pcie_dma_rlast => pcie_m_axi_dma_ddr_RLAST,
      s_axi_pcie_dma_rready => pcie_m_axi_dma_ddr_RREADY,
      s_axi_pcie_dma_rresp(1 downto 0) => pcie_m_axi_dma_ddr_RRESP(1 downto 0),
      s_axi_pcie_dma_ruser(13 downto 0) => pcie_m_axi_dma_ddr_RUSER(13 downto 0),
      s_axi_pcie_dma_rvalid => pcie_m_axi_dma_ddr_RVALID,
      s_axi_pcie_dma_wdata(255 downto 0) => pcie_m_axi_dma_ddr_WDATA(255 downto 0),
      s_axi_pcie_dma_wlast => pcie_m_axi_dma_ddr_WLAST,
      s_axi_pcie_dma_wready => pcie_m_axi_dma_ddr_WREADY,
      s_axi_pcie_dma_wstrb(31 downto 0) => pcie_m_axi_dma_ddr_WSTRB(31 downto 0),
      s_axi_pcie_dma_wuser(13 downto 0) => pcie_m_axi_dma_ddr_WUSER(13 downto 0),
      s_axi_pcie_dma_wvalid => pcie_m_axi_dma_ddr_WVALID
    );
pcie: entity work.pcie_imp_P1MTX3
     port map (
      m_axi_dma_ddr_araddr(63 downto 0) => pcie_m_axi_dma_ddr_ARADDR(63 downto 0),
      m_axi_dma_ddr_arburst(1 downto 0) => pcie_m_axi_dma_ddr_ARBURST(1 downto 0),
      m_axi_dma_ddr_arcache(3 downto 0) => pcie_m_axi_dma_ddr_ARCACHE(3 downto 0),
      m_axi_dma_ddr_arid(1 downto 0) => pcie_m_axi_dma_ddr_ARID(1 downto 0),
      m_axi_dma_ddr_arlen(7 downto 0) => pcie_m_axi_dma_ddr_ARLEN(7 downto 0),
      m_axi_dma_ddr_arlock(0) => pcie_m_axi_dma_ddr_ARLOCK(0),
      m_axi_dma_ddr_arprot(2 downto 0) => pcie_m_axi_dma_ddr_ARPROT(2 downto 0),
      m_axi_dma_ddr_arqos(3 downto 0) => pcie_m_axi_dma_ddr_ARQOS(3 downto 0),
      m_axi_dma_ddr_arready => pcie_m_axi_dma_ddr_ARREADY,
      m_axi_dma_ddr_arsize(2 downto 0) => pcie_m_axi_dma_ddr_ARSIZE(2 downto 0),
      m_axi_dma_ddr_aruser(113 downto 0) => pcie_m_axi_dma_ddr_ARUSER(113 downto 0),
      m_axi_dma_ddr_arvalid => pcie_m_axi_dma_ddr_ARVALID,
      m_axi_dma_ddr_awaddr(63 downto 0) => pcie_m_axi_dma_ddr_AWADDR(63 downto 0),
      m_axi_dma_ddr_awburst(1 downto 0) => pcie_m_axi_dma_ddr_AWBURST(1 downto 0),
      m_axi_dma_ddr_awcache(3 downto 0) => pcie_m_axi_dma_ddr_AWCACHE(3 downto 0),
      m_axi_dma_ddr_awid(1 downto 0) => pcie_m_axi_dma_ddr_AWID(1 downto 0),
      m_axi_dma_ddr_awlen(7 downto 0) => pcie_m_axi_dma_ddr_AWLEN(7 downto 0),
      m_axi_dma_ddr_awlock(0) => pcie_m_axi_dma_ddr_AWLOCK(0),
      m_axi_dma_ddr_awprot(2 downto 0) => pcie_m_axi_dma_ddr_AWPROT(2 downto 0),
      m_axi_dma_ddr_awqos(3 downto 0) => pcie_m_axi_dma_ddr_AWQOS(3 downto 0),
      m_axi_dma_ddr_awready => pcie_m_axi_dma_ddr_AWREADY,
      m_axi_dma_ddr_awsize(2 downto 0) => pcie_m_axi_dma_ddr_AWSIZE(2 downto 0),
      m_axi_dma_ddr_awuser(113 downto 0) => pcie_m_axi_dma_ddr_AWUSER(113 downto 0),
      m_axi_dma_ddr_awvalid => pcie_m_axi_dma_ddr_AWVALID,
      m_axi_dma_ddr_bid(1 downto 0) => pcie_m_axi_dma_ddr_BID(1 downto 0),
      m_axi_dma_ddr_bready => pcie_m_axi_dma_ddr_BREADY,
      m_axi_dma_ddr_bresp(1 downto 0) => pcie_m_axi_dma_ddr_BRESP(1 downto 0),
      m_axi_dma_ddr_buser(113 downto 0) => pcie_m_axi_dma_ddr_BUSER(113 downto 0),
      m_axi_dma_ddr_bvalid => pcie_m_axi_dma_ddr_BVALID,
      m_axi_dma_ddr_rdata(255 downto 0) => pcie_m_axi_dma_ddr_RDATA(255 downto 0),
      m_axi_dma_ddr_rid(1 downto 0) => pcie_m_axi_dma_ddr_RID(1 downto 0),
      m_axi_dma_ddr_rlast => pcie_m_axi_dma_ddr_RLAST,
      m_axi_dma_ddr_rready => pcie_m_axi_dma_ddr_RREADY,
      m_axi_dma_ddr_rresp(1 downto 0) => pcie_m_axi_dma_ddr_RRESP(1 downto 0),
      m_axi_dma_ddr_ruser(13 downto 0) => pcie_m_axi_dma_ddr_RUSER(13 downto 0),
      m_axi_dma_ddr_rvalid => pcie_m_axi_dma_ddr_RVALID,
      m_axi_dma_ddr_wdata(255 downto 0) => pcie_m_axi_dma_ddr_WDATA(255 downto 0),
      m_axi_dma_ddr_wlast => pcie_m_axi_dma_ddr_WLAST,
      m_axi_dma_ddr_wready => pcie_m_axi_dma_ddr_WREADY,
      m_axi_dma_ddr_wstrb(31 downto 0) => pcie_m_axi_dma_ddr_WSTRB(31 downto 0),
      m_axi_dma_ddr_wuser(13 downto 0) => pcie_m_axi_dma_ddr_WUSER(13 downto 0),
      m_axi_dma_ddr_wvalid => pcie_m_axi_dma_ddr_WVALID,
      p_m_axi4l_app_araddr(22 downto 0) => pcie_p_m_axi4l_app_ARADDR(22 downto 0),
      p_m_axi4l_app_arprot(2 downto 0) => pcie_p_m_axi4l_app_ARPROT(2 downto 0),
      p_m_axi4l_app_arready => pcie_p_m_axi4l_app_ARREADY,
      p_m_axi4l_app_arvalid => pcie_p_m_axi4l_app_ARVALID,
      p_m_axi4l_app_awaddr(22 downto 0) => pcie_p_m_axi4l_app_AWADDR(22 downto 0),
      p_m_axi4l_app_awprot(2 downto 0) => pcie_p_m_axi4l_app_AWPROT(2 downto 0),
      p_m_axi4l_app_awready => pcie_p_m_axi4l_app_AWREADY,
      p_m_axi4l_app_awvalid => pcie_p_m_axi4l_app_AWVALID,
      p_m_axi4l_app_bready => pcie_p_m_axi4l_app_BREADY,
      p_m_axi4l_app_bresp(1 downto 0) => pcie_p_m_axi4l_app_BRESP(1 downto 0),
      p_m_axi4l_app_bvalid => pcie_p_m_axi4l_app_BVALID,
      p_m_axi4l_app_rdata(31 downto 0) => pcie_p_m_axi4l_app_RDATA(31 downto 0),
      p_m_axi4l_app_rready => pcie_p_m_axi4l_app_RREADY,
      p_m_axi4l_app_rresp(1 downto 0) => pcie_p_m_axi4l_app_RRESP(1 downto 0),
      p_m_axi4l_app_rvalid => pcie_p_m_axi4l_app_RVALID,
      p_m_axi4l_app_wdata(31 downto 0) => pcie_p_m_axi4l_app_WDATA(31 downto 0),
      p_m_axi4l_app_wready => pcie_p_m_axi4l_app_WREADY,
      p_m_axi4l_app_wstrb(3 downto 0) => pcie_p_m_axi4l_app_WSTRB(3 downto 0),
      p_m_axi4l_app_wvalid => pcie_p_m_axi4l_app_WVALID,
      p_m_axi4l_bsp_araddr(22 downto 0) => pcie_p_m_axi4l_bsp_ARADDR(22 downto 0),
      p_m_axi4l_bsp_arprot(2 downto 0) => pcie_p_m_axi4l_bsp_ARPROT(2 downto 0),
      p_m_axi4l_bsp_arready => pcie_p_m_axi4l_bsp_ARREADY,
      p_m_axi4l_bsp_arvalid => pcie_p_m_axi4l_bsp_ARVALID,
      p_m_axi4l_bsp_awaddr(22 downto 0) => pcie_p_m_axi4l_bsp_AWADDR(22 downto 0),
      p_m_axi4l_bsp_awprot(2 downto 0) => pcie_p_m_axi4l_bsp_AWPROT(2 downto 0),
      p_m_axi4l_bsp_awready => pcie_p_m_axi4l_bsp_AWREADY,
      p_m_axi4l_bsp_awvalid => pcie_p_m_axi4l_bsp_AWVALID,
      p_m_axi4l_bsp_bready => pcie_p_m_axi4l_bsp_BREADY,
      p_m_axi4l_bsp_bresp(1 downto 0) => pcie_p_m_axi4l_bsp_BRESP(1 downto 0),
      p_m_axi4l_bsp_bvalid => pcie_p_m_axi4l_bsp_BVALID,
      p_m_axi4l_bsp_rdata(31 downto 0) => pcie_p_m_axi4l_bsp_RDATA(31 downto 0),
      p_m_axi4l_bsp_rready => pcie_p_m_axi4l_bsp_RREADY,
      p_m_axi4l_bsp_rresp(1 downto 0) => pcie_p_m_axi4l_bsp_RRESP(1 downto 0),
      p_m_axi4l_bsp_rvalid => pcie_p_m_axi4l_bsp_RVALID,
      p_m_axi4l_bsp_wdata(31 downto 0) => pcie_p_m_axi4l_bsp_WDATA(31 downto 0),
      p_m_axi4l_bsp_wready => pcie_p_m_axi4l_bsp_WREADY,
      p_m_axi4l_bsp_wstrb(3 downto 0) => pcie_p_m_axi4l_bsp_WSTRB(3 downto 0),
      p_m_axi4l_bsp_wvalid => pcie_p_m_axi4l_bsp_WVALID,
      p_pcie_mgt_rxn(3 downto 0) => pcie_p_pcie_mgt_rxn(3 downto 0),
      p_pcie_mgt_rxp(3 downto 0) => pcie_p_pcie_mgt_rxp(3 downto 0),
      p_pcie_mgt_txn(3 downto 0) => pcie_p_pcie_mgt_txn(3 downto 0),
      p_pcie_mgt_txp(3 downto 0) => pcie_p_pcie_mgt_txp(3 downto 0),
      pi_m_axi4l_app_aclk => pi_m_axi4l_app_aclk_1,
      pi_pcie_areset_n => pi_pcie_areset_n_1,
      pi_pcie_irq_req(15 downto 0) => pi_pcie_irq_req_1(15 downto 0),
      pi_pcie_sys_clk => pi_pcie_sys_clk_1,
      pi_pcie_sys_clk_gt => pi_pcie_sys_clk_gt_1,
      po_m_axi4_aclk => pcie_po_m_axi4_aclk,
      po_m_axi4_areset_n => pcie_po_m_axi4_areset_n,
      po_pcie_irq_ack(15 downto 0) => pcie_po_pcie_irq_ack(15 downto 0),
      po_pcie_link_up => pcie_po_pcie_link_up
    );
end STRUCTURE;
