--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
--Date        : Wed Sep 20 08:47:41 2023
--Host        : workstation running 64-bit unknown
--Command     : generate_target sis8300ku_bsp_system_wrapper.bd
--Design      : sis8300ku_bsp_system_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity sis8300ku_bsp_system_wrapper is
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
end sis8300ku_bsp_system_wrapper;

architecture STRUCTURE of sis8300ku_bsp_system_wrapper is
  component sis8300ku_bsp_system is
  port (
    pi_m_axi4l_app_aclk : in STD_LOGIC;
    pi_pcie_sys_clk : in STD_LOGIC;
    pi_pcie_sys_clk_gt : in STD_LOGIC;
    pi_pcie_areset_n : in STD_LOGIC;
    po_m_axi4_aclk : out STD_LOGIC;
    po_m_axi4_areset_n : out STD_LOGIC;
    po_pcie_link_up : out STD_LOGIC;
    po_pcie_irq_ack : out STD_LOGIC_VECTOR ( 15 downto 0 );
    pi_pcie_irq_req : in STD_LOGIC_VECTOR ( 15 downto 0 );
    p_pcie_mgt_rxn : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_pcie_mgt_rxp : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_pcie_mgt_txn : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_pcie_mgt_txp : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_m_axi4l_bsp_awaddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_bsp_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_bsp_awvalid : out STD_LOGIC;
    p_m_axi4l_bsp_awready : in STD_LOGIC;
    p_m_axi4l_bsp_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_bsp_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_m_axi4l_bsp_wvalid : out STD_LOGIC;
    p_m_axi4l_bsp_wready : in STD_LOGIC;
    p_m_axi4l_bsp_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_bsp_bvalid : in STD_LOGIC;
    p_m_axi4l_bsp_bready : out STD_LOGIC;
    p_m_axi4l_bsp_araddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_bsp_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_bsp_arvalid : out STD_LOGIC;
    p_m_axi4l_bsp_arready : in STD_LOGIC;
    p_m_axi4l_bsp_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_bsp_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_bsp_rvalid : in STD_LOGIC;
    p_m_axi4l_bsp_rready : out STD_LOGIC;
    p_m_axi4l_app_awaddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_app_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_app_awvalid : out STD_LOGIC;
    p_m_axi4l_app_awready : in STD_LOGIC;
    p_m_axi4l_app_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_app_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_m_axi4l_app_wvalid : out STD_LOGIC;
    p_m_axi4l_app_wready : in STD_LOGIC;
    p_m_axi4l_app_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_app_bvalid : in STD_LOGIC;
    p_m_axi4l_app_bready : out STD_LOGIC;
    p_m_axi4l_app_araddr : out STD_LOGIC_VECTOR ( 22 downto 0 );
    p_m_axi4l_app_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    p_m_axi4l_app_arvalid : out STD_LOGIC;
    p_m_axi4l_app_arready : in STD_LOGIC;
    p_m_axi4l_app_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_m_axi4l_app_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_m_axi4l_app_rvalid : in STD_LOGIC;
    p_m_axi4l_app_rready : out STD_LOGIC;
    pi_ddr4_sys_clk : in STD_LOGIC;
    po_s_axi4_ddr_aclk : out STD_LOGIC;
    po_s_axi4_ddr_areset_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    po_ddr_calib_done : out STD_LOGIC;
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
    p_s_axi4_ddr_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_s_axi4_ddr_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    p_s_axi4_ddr_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    p_s_axi4_ddr_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_awvalid : in STD_LOGIC;
    p_s_axi4_ddr_awready : out STD_LOGIC;
    p_s_axi4_ddr_wdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    p_s_axi4_ddr_wstrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_s_axi4_ddr_wlast : in STD_LOGIC;
    p_s_axi4_ddr_wvalid : in STD_LOGIC;
    p_s_axi4_ddr_wready : out STD_LOGIC;
    p_s_axi4_ddr_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_bvalid : out STD_LOGIC;
    p_s_axi4_ddr_bready : in STD_LOGIC;
    p_s_axi4_ddr_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    p_s_axi4_ddr_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    p_s_axi4_ddr_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
    p_s_axi4_ddr_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    p_s_axi4_ddr_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_arvalid : in STD_LOGIC;
    p_s_axi4_ddr_arready : out STD_LOGIC;
    p_s_axi4_ddr_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    p_s_axi4_ddr_rdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    p_s_axi4_ddr_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    p_s_axi4_ddr_rlast : out STD_LOGIC;
    p_s_axi4_ddr_rvalid : out STD_LOGIC;
    p_s_axi4_ddr_rready : in STD_LOGIC
  );
  end component sis8300ku_bsp_system;
begin
sis8300ku_bsp_system_i: component sis8300ku_bsp_system
     port map (
      p_ddr4_act_n => p_ddr4_act_n,
      p_ddr4_adr(16 downto 0) => p_ddr4_adr(16 downto 0),
      p_ddr4_ba(1 downto 0) => p_ddr4_ba(1 downto 0),
      p_ddr4_bg(0) => p_ddr4_bg(0),
      p_ddr4_ck_c(0) => p_ddr4_ck_c(0),
      p_ddr4_ck_t(0) => p_ddr4_ck_t(0),
      p_ddr4_cke(0) => p_ddr4_cke(0),
      p_ddr4_cs_n(0) => p_ddr4_cs_n(0),
      p_ddr4_dm_n(7 downto 0) => p_ddr4_dm_n(7 downto 0),
      p_ddr4_dq(63 downto 0) => p_ddr4_dq(63 downto 0),
      p_ddr4_dqs_c(7 downto 0) => p_ddr4_dqs_c(7 downto 0),
      p_ddr4_dqs_t(7 downto 0) => p_ddr4_dqs_t(7 downto 0),
      p_ddr4_odt(0) => p_ddr4_odt(0),
      p_ddr4_reset_n => p_ddr4_reset_n,
      p_m_axi4l_app_araddr(22 downto 0) => p_m_axi4l_app_araddr(22 downto 0),
      p_m_axi4l_app_arprot(2 downto 0) => p_m_axi4l_app_arprot(2 downto 0),
      p_m_axi4l_app_arready => p_m_axi4l_app_arready,
      p_m_axi4l_app_arvalid => p_m_axi4l_app_arvalid,
      p_m_axi4l_app_awaddr(22 downto 0) => p_m_axi4l_app_awaddr(22 downto 0),
      p_m_axi4l_app_awprot(2 downto 0) => p_m_axi4l_app_awprot(2 downto 0),
      p_m_axi4l_app_awready => p_m_axi4l_app_awready,
      p_m_axi4l_app_awvalid => p_m_axi4l_app_awvalid,
      p_m_axi4l_app_bready => p_m_axi4l_app_bready,
      p_m_axi4l_app_bresp(1 downto 0) => p_m_axi4l_app_bresp(1 downto 0),
      p_m_axi4l_app_bvalid => p_m_axi4l_app_bvalid,
      p_m_axi4l_app_rdata(31 downto 0) => p_m_axi4l_app_rdata(31 downto 0),
      p_m_axi4l_app_rready => p_m_axi4l_app_rready,
      p_m_axi4l_app_rresp(1 downto 0) => p_m_axi4l_app_rresp(1 downto 0),
      p_m_axi4l_app_rvalid => p_m_axi4l_app_rvalid,
      p_m_axi4l_app_wdata(31 downto 0) => p_m_axi4l_app_wdata(31 downto 0),
      p_m_axi4l_app_wready => p_m_axi4l_app_wready,
      p_m_axi4l_app_wstrb(3 downto 0) => p_m_axi4l_app_wstrb(3 downto 0),
      p_m_axi4l_app_wvalid => p_m_axi4l_app_wvalid,
      p_m_axi4l_bsp_araddr(22 downto 0) => p_m_axi4l_bsp_araddr(22 downto 0),
      p_m_axi4l_bsp_arprot(2 downto 0) => p_m_axi4l_bsp_arprot(2 downto 0),
      p_m_axi4l_bsp_arready => p_m_axi4l_bsp_arready,
      p_m_axi4l_bsp_arvalid => p_m_axi4l_bsp_arvalid,
      p_m_axi4l_bsp_awaddr(22 downto 0) => p_m_axi4l_bsp_awaddr(22 downto 0),
      p_m_axi4l_bsp_awprot(2 downto 0) => p_m_axi4l_bsp_awprot(2 downto 0),
      p_m_axi4l_bsp_awready => p_m_axi4l_bsp_awready,
      p_m_axi4l_bsp_awvalid => p_m_axi4l_bsp_awvalid,
      p_m_axi4l_bsp_bready => p_m_axi4l_bsp_bready,
      p_m_axi4l_bsp_bresp(1 downto 0) => p_m_axi4l_bsp_bresp(1 downto 0),
      p_m_axi4l_bsp_bvalid => p_m_axi4l_bsp_bvalid,
      p_m_axi4l_bsp_rdata(31 downto 0) => p_m_axi4l_bsp_rdata(31 downto 0),
      p_m_axi4l_bsp_rready => p_m_axi4l_bsp_rready,
      p_m_axi4l_bsp_rresp(1 downto 0) => p_m_axi4l_bsp_rresp(1 downto 0),
      p_m_axi4l_bsp_rvalid => p_m_axi4l_bsp_rvalid,
      p_m_axi4l_bsp_wdata(31 downto 0) => p_m_axi4l_bsp_wdata(31 downto 0),
      p_m_axi4l_bsp_wready => p_m_axi4l_bsp_wready,
      p_m_axi4l_bsp_wstrb(3 downto 0) => p_m_axi4l_bsp_wstrb(3 downto 0),
      p_m_axi4l_bsp_wvalid => p_m_axi4l_bsp_wvalid,
      p_pcie_mgt_rxn(3 downto 0) => p_pcie_mgt_rxn(3 downto 0),
      p_pcie_mgt_rxp(3 downto 0) => p_pcie_mgt_rxp(3 downto 0),
      p_pcie_mgt_txn(3 downto 0) => p_pcie_mgt_txn(3 downto 0),
      p_pcie_mgt_txp(3 downto 0) => p_pcie_mgt_txp(3 downto 0),
      p_s_axi4_ddr_araddr(31 downto 0) => p_s_axi4_ddr_araddr(31 downto 0),
      p_s_axi4_ddr_arburst(1 downto 0) => p_s_axi4_ddr_arburst(1 downto 0),
      p_s_axi4_ddr_arcache(3 downto 0) => p_s_axi4_ddr_arcache(3 downto 0),
      p_s_axi4_ddr_arid(3 downto 0) => p_s_axi4_ddr_arid(3 downto 0),
      p_s_axi4_ddr_arlen(7 downto 0) => p_s_axi4_ddr_arlen(7 downto 0),
      p_s_axi4_ddr_arlock(0) => p_s_axi4_ddr_arlock(0),
      p_s_axi4_ddr_arprot(2 downto 0) => p_s_axi4_ddr_arprot(2 downto 0),
      p_s_axi4_ddr_arqos(3 downto 0) => p_s_axi4_ddr_arqos(3 downto 0),
      p_s_axi4_ddr_arready => p_s_axi4_ddr_arready,
      p_s_axi4_ddr_arsize(2 downto 0) => p_s_axi4_ddr_arsize(2 downto 0),
      p_s_axi4_ddr_arvalid => p_s_axi4_ddr_arvalid,
      p_s_axi4_ddr_awaddr(31 downto 0) => p_s_axi4_ddr_awaddr(31 downto 0),
      p_s_axi4_ddr_awburst(1 downto 0) => p_s_axi4_ddr_awburst(1 downto 0),
      p_s_axi4_ddr_awcache(3 downto 0) => p_s_axi4_ddr_awcache(3 downto 0),
      p_s_axi4_ddr_awid(3 downto 0) => p_s_axi4_ddr_awid(3 downto 0),
      p_s_axi4_ddr_awlen(7 downto 0) => p_s_axi4_ddr_awlen(7 downto 0),
      p_s_axi4_ddr_awlock(0) => p_s_axi4_ddr_awlock(0),
      p_s_axi4_ddr_awprot(2 downto 0) => p_s_axi4_ddr_awprot(2 downto 0),
      p_s_axi4_ddr_awqos(3 downto 0) => p_s_axi4_ddr_awqos(3 downto 0),
      p_s_axi4_ddr_awready => p_s_axi4_ddr_awready,
      p_s_axi4_ddr_awsize(2 downto 0) => p_s_axi4_ddr_awsize(2 downto 0),
      p_s_axi4_ddr_awvalid => p_s_axi4_ddr_awvalid,
      p_s_axi4_ddr_bid(3 downto 0) => p_s_axi4_ddr_bid(3 downto 0),
      p_s_axi4_ddr_bready => p_s_axi4_ddr_bready,
      p_s_axi4_ddr_bresp(1 downto 0) => p_s_axi4_ddr_bresp(1 downto 0),
      p_s_axi4_ddr_bvalid => p_s_axi4_ddr_bvalid,
      p_s_axi4_ddr_rdata(255 downto 0) => p_s_axi4_ddr_rdata(255 downto 0),
      p_s_axi4_ddr_rid(3 downto 0) => p_s_axi4_ddr_rid(3 downto 0),
      p_s_axi4_ddr_rlast => p_s_axi4_ddr_rlast,
      p_s_axi4_ddr_rready => p_s_axi4_ddr_rready,
      p_s_axi4_ddr_rresp(1 downto 0) => p_s_axi4_ddr_rresp(1 downto 0),
      p_s_axi4_ddr_rvalid => p_s_axi4_ddr_rvalid,
      p_s_axi4_ddr_wdata(255 downto 0) => p_s_axi4_ddr_wdata(255 downto 0),
      p_s_axi4_ddr_wlast => p_s_axi4_ddr_wlast,
      p_s_axi4_ddr_wready => p_s_axi4_ddr_wready,
      p_s_axi4_ddr_wstrb(31 downto 0) => p_s_axi4_ddr_wstrb(31 downto 0),
      p_s_axi4_ddr_wvalid => p_s_axi4_ddr_wvalid,
      pi_ddr4_sys_clk => pi_ddr4_sys_clk,
      pi_m_axi4l_app_aclk => pi_m_axi4l_app_aclk,
      pi_pcie_areset_n => pi_pcie_areset_n,
      pi_pcie_irq_req(15 downto 0) => pi_pcie_irq_req(15 downto 0),
      pi_pcie_sys_clk => pi_pcie_sys_clk,
      pi_pcie_sys_clk_gt => pi_pcie_sys_clk_gt,
      po_ddr_calib_done => po_ddr_calib_done,
      po_m_axi4_aclk => po_m_axi4_aclk,
      po_m_axi4_areset_n => po_m_axi4_areset_n,
      po_pcie_irq_ack(15 downto 0) => po_pcie_irq_ack(15 downto 0),
      po_pcie_link_up => po_pcie_link_up,
      po_s_axi4_ddr_aclk => po_s_axi4_ddr_aclk,
      po_s_axi4_ddr_areset_n(0) => po_s_axi4_ddr_areset_n(0)
    );
end STRUCTURE;
