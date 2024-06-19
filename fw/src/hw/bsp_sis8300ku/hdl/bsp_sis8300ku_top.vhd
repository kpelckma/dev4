------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2021-12-21
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Most Top File of the Project
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_axi.all;
use desy.common_types.all;
use desy.common_to_desyrdl.all;
use desy.common_bsp_ifs.all;

library unisim;
use unisim.vcomponents.all;

-- configuration
use work.pkg_bsp_config.all;

-- interfaces
use work.pkg_sis8300ku_payload.all;

library desyrdl;
use desyrdl.pkg_sis8300ku_bsp_logic.all;

entity bsp_sis8300ku_top is
  port (
    -- Clocks ---------------------------
    -- 125Mhz Crystal
    pi_125_clk_p : in std_logic;
    pi_125_clk_n : in std_logic;

    pi_pcie_clk_p : in std_logic;
    pi_pcie_clk_n : in std_logic;

    ----------------------------------------------------------
    --PCIe (x4 lanes)
    pi_pcie_rst_n : in std_logic;
    pi_pcie_rx_p  : in std_logic_vector(3 downto 0);
    pi_pcie_rx_n  : in std_logic_vector(3 downto 0);
    po_pcie_tx_p  : out std_logic_vector(3 downto 0);
    po_pcie_tx_n  : out std_logic_vector(3 downto 0);

    ----------------------------------------------------------
    -- DDR4 memory interface
    po_ddr4_adr       : out   std_logic_vector(16 downto 0);
    po_ddr4_ba        : out   std_logic_vector(1 downto 0);
    po_ddr4_cke       : out   std_logic_vector(0 downto 0);
    po_ddr4_cs_n      : out   std_logic_vector(0 downto 0);
    pio_ddr4_dm_dbi_n : inout std_logic_vector(7 downto 0);
    pio_ddr4_dq       : inout std_logic_vector(63 downto 0);
    pio_ddr4_dqs_c    : inout std_logic_vector(7 downto 0);
    pio_ddr4_dqs_t    : inout std_logic_vector(7 downto 0);
    po_ddr4_odt       : out   std_logic_vector(0 downto 0);
    po_ddr4_bg        : out   std_logic_vector(0 downto 0);
    po_ddr4_rst_n     : out   std_logic;
    po_ddr4_act_n     : out   std_logic;
    po_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    po_ddr4_ck_t      : out   std_logic_vector(0 downto 0);

    -- MLVDS (Port 17,18,19,20) ---------------------------------------------------
    pi_mlvds    : in  std_logic_vector(7 downto 0);
    po_mlvds    : out std_logic_vector(7 downto 0);
    po_mlvds_oe : out std_logic_vector(7 downto 0); -- TXEN (Enable Transmission)

    ----------------------------------------------------------
    -- ADC
    po_adc_cs_b   : out std_logic_vector(4 downto 0);
    pio_adc_sdio  : inout std_logic;
    po_adc_sclk   : out std_logic;
    po_adc_oe_n   : out std_logic;
    po_adc_pdwn   : out std_logic;
    pi_adc_dco_p  : in std_logic_vector(4 downto 0);
    pi_adc_dco_n  : in std_logic_vector(4 downto 0);
    pi_adc_or_p   : in std_logic_vector(4 downto 0);
    pi_adc_or_n   : in std_logic_vector(4 downto 0);
    pi_adc_data_p : in t_16b_slv_vector(4 downto 0);
    pi_adc_data_n : in t_16b_slv_vector(4 downto 0);

    ----------------------------------------------------------
    -- DAC
    po_dac_pd      : out std_logic;
    po_dac_torb    : out std_logic;
    po_dac_clk_p   : out std_logic;
    po_dac_clk_n   : out std_logic;
    po_dac_seliq_p : out std_logic;
    po_dac_seliq_n : out std_logic;
    po_dac_data_p  : out std_logic_vector(15 downto 0);
    po_dac_data_n  : out std_logic_vector(15 downto 0);

    ----------------------------------------------------------
    -- Clock after the PLL
    pi_ad9510_0_clk05_p : in std_logic;
    pi_ad9510_0_clk05_n : in std_logic;
    pi_ad9510_1_clk69_p : in std_logic;
    pi_ad9510_1_clk69_n : in std_logic;

    -- Clock going to DAC (Monitoring)
    pi_dac_clk_fb_p : in std_logic;
    pi_dac_clk_fb_n : in std_logic;

    -- Clock Muxes
    po_mux_a_sel   : out std_logic_vector(1 downto 0);
    po_mux_b_sel   : out std_logic_vector(1 downto 0);
    po_mux_c_sel   : out std_logic_vector(1 downto 0);
    po_mux_d_sel   : out std_logic_vector(1 downto 0);
    po_mux_e_sel   : out std_logic_vector(1 downto 0);
    po_mux_dac_sel : out std_logic_vector(1 downto 0);

    -- Two AD9510 PLL present in SIS8300-KU
    po_ad9510_cs_b     : out   std_logic_vector(1 downto 0); -- Chip Select
    po_ad9510_sclk     : out   std_logic; -- Both PLL gets this
    pio_ad9510_sdio    : inout std_logic; -- Both PLL gets this
    po_ad9510_function : out   std_logic; -- Both PLL gets this

    ----------------------------------------------------------
    -- Front Panel (RJ45) data input/outputs
    po_fp_data_p : out std_logic_vector(2 downto 0);
    po_fp_data_n : out std_logic_vector(2 downto 0);
    pi_fp_data_p : in std_logic_vector(2 downto 0);
    pi_fp_data_n : in std_logic_vector(2 downto 0);

    ----------------------------------------------------------
    -- Zone3 Connections
    pio_rtm_io_p : inout std_logic_vector(11 downto 0);
    pio_rtm_io_n : inout std_logic_vector(11 downto 0);

    po_rtm_interlock       : out std_logic_vector(1 downto 0);
    po_rtm_interlock_ena_n : out std_logic;

    ----------------------------------------------------------
    -- LED
    po_led_serial_data  : out std_logic
  );
end bsp_sis8300ku_top;

architecture arch of bsp_sis8300ku_top is

  signal payload_i  : t_payload_i; 
  signal payload_o  : t_payload_o;
    
  signal pcie_sys_clk    : std_logic;
  signal pcie_sys_clk_gt : std_logic;
  signal pcie_link_up    : std_logic;

  signal axi4_aclk : std_logic; -- Main AXI4 Clock for BSP Section
  signal axi4_areset_n : std_logic; -- Main AXI4 Lite Reset for BSP Section
  signal app_clk : std_logic; -- Application Clock that will be used in AXI4.Lite Application Section

  signal axi4l_bsp_m2s : t_axi4l_reg_m2s;
  signal axi4l_bsp_s2m : t_axi4l_reg_s2m;

  signal ddr_awaddr : std_logic_vector(31 downto 0);

  signal s_reg_i : t_sis8300ku_bsp_logic_m2s;
  signal s_reg_o : t_sis8300ku_bsp_logic_s2m;

  signal ddr_calib_done : std_logic;
  signal sys_125_clk : std_logic;
  
  signal pcie_irq_req_proc : std_logic_vector(C_PCIE_IRQ_CNT-1 downto 0); -- Processed IRQ Req (BSP Clk Domain)
  signal pcie_irq_ack      : std_logic_vector(C_PCIE_IRQ_CNT-1 downto 0); -- IRQ Acknowledgement Coming from xDMA

begin

  -- Top to app signals assignments
  payload_i.mlvds <= pi_mlvds;
  po_mlvds        <= payload_o.mlvds;
  po_mlvds_oe     <= payload_o.mlvds_oe;

  po_rtm_interlock <= payload_o.interlock;
  po_rtm_interlock_ena_n <= payload_o.interlock_ena_n;
  
 ins_payload : entity work.sis8300ku_payload
  port map (
    -- BSP -> Application
    pi_payload  => payload_i,
    -- Application -> BSP
    po_payload  => payload_o,
    -- Top <-> Application
    pio_payload.rtm_io_p => pio_rtm_io_p,
    pio_payload.rtm_io_n => pio_rtm_io_n
  );

  -- ============================================================================
  -- AXI.4 related
  -- ============================================================================ 
  s_reg_i <= f_common_to_desyrdl(axi4l_bsp_m2s);
  axi4l_bsp_s2m <= f_common_to_desyrdl(s_reg_o);

  -- Starting Address for the DDR AXI4 interface starts from 0x8000_0000
  -- Doing this trick to make sure Application doesn't care about this offset
  ddr_awaddr(30 downto 0) <= payload_o.s_axi4_daq.awaddr(30 downto 0);
  ddr_awaddr(31) <= '1';

  ins_pcie_ibufds_gte3  : IBUFDS_GTE3
  generic map (REFCLK_HROW_CK_SEL => "00")
  port map (o => pcie_sys_clk_gt, odiv2 => pcie_sys_clk, i => pi_pcie_clk_p, ib => pi_pcie_clk_n, ceb => '0');

  ins_sysclk_buf : ibufds generic map(ibuf_low_pwr => false) port map (o => sys_125_clk, i => pi_125_clk_p, ib => pi_125_clk_n);

  ins_sis8300ku_bsp_system_wrapper: entity work.sis8300ku_bsp_system_wrapper
  port map (

    pi_pcie_areset_n   => pi_pcie_rst_n,
    pi_pcie_sys_clk    => pcie_sys_clk,
    pi_pcie_sys_clk_gt => pcie_sys_clk_gt,
    
    po_pcie_link_up => pcie_link_up,

    p_pcie_mgt_rxn => pi_pcie_rx_n,
    p_pcie_mgt_rxp => pi_pcie_rx_p,
    p_pcie_mgt_txn => po_pcie_tx_n,
    p_pcie_mgt_txp => po_pcie_tx_p,

    -- DDR4 memory interface
    pi_ddr4_sys_clk => sys_125_clk,
    p_ddr4_act_n   => po_ddr4_act_n,
    p_ddr4_adr     => po_ddr4_adr,
    p_ddr4_ba      => po_ddr4_ba,
    p_ddr4_bg      => po_ddr4_bg,
    p_ddr4_ck_c    => po_ddr4_ck_c,
    p_ddr4_ck_t    => po_ddr4_ck_t,
    p_ddr4_cke     => po_ddr4_cke,
    p_ddr4_cs_n    => po_ddr4_cs_n,
    p_ddr4_dm_n    => pio_ddr4_dm_dbi_n,
    p_ddr4_dq      => pio_ddr4_dq,
    p_ddr4_dqs_c   => pio_ddr4_dqs_c,
    p_ddr4_dqs_t   => pio_ddr4_dqs_t,
    p_ddr4_odt     => po_ddr4_odt,
    p_ddr4_reset_n => po_ddr4_rst_n,

    -- MIG Calibration Done
    po_ddr_calib_done => ddr_calib_done,

    po_pcie_irq_ack    => pcie_irq_ack,
    pi_pcie_irq_req    => pcie_irq_req_proc, -- Processed IRQ Req going to xDMA 

    -- Bus interfaces
    po_m_axi4_aclk      => axi4_aclk,
    po_m_axi4_areset_n  => axi4_areset_n,
    pi_m_axi4l_app_aclk => app_clk,

    po_s_axi4_ddr_aclk        => payload_i.s_axi4_daq_aclk,
    po_s_axi4_ddr_areset_n(0) => payload_i.s_axi4_daq_areset_n,

    -- AXI4.Lite Manager Interface for BSP
    p_m_axi4l_bsp_awaddr      => axi4l_bsp_m2s.awaddr(22 downto 0),
    p_m_axi4l_bsp_awprot      => axi4l_bsp_m2s.awprot,
    p_m_axi4l_bsp_awvalid     => axi4l_bsp_m2s.awvalid,
    p_m_axi4l_bsp_wdata       => axi4l_bsp_m2s.wdata,
    p_m_axi4l_bsp_wstrb       => axi4l_bsp_m2s.wstrb,
    p_m_axi4l_bsp_wvalid      => axi4l_bsp_m2s.wvalid,
    p_m_axi4l_bsp_bready      => axi4l_bsp_m2s.bready,
    p_m_axi4l_bsp_araddr      => axi4l_bsp_m2s.araddr(22 downto 0),
    p_m_axi4l_bsp_arprot      => axi4l_bsp_m2s.arprot,
    p_m_axi4l_bsp_arvalid     => axi4l_bsp_m2s.arvalid,
    p_m_axi4l_bsp_rready      => axi4l_bsp_m2s.rready,
    p_m_axi4l_bsp_awready     => axi4l_bsp_s2m.awready,
    p_m_axi4l_bsp_wready      => axi4l_bsp_s2m.wready,
    p_m_axi4l_bsp_bresp       => axi4l_bsp_s2m.bresp,
    p_m_axi4l_bsp_bvalid      => axi4l_bsp_s2m.bvalid,
    p_m_axi4l_bsp_arready     => axi4l_bsp_s2m.arready,
    p_m_axi4l_bsp_rdata       => axi4l_bsp_s2m.rdata,
    p_m_axi4l_bsp_rresp       => axi4l_bsp_s2m.rresp,
    p_m_axi4l_bsp_rvalid      => axi4l_bsp_s2m.rvalid,

    -- AXI4.Lite Manager Interface for Application
    p_m_axi4l_app_awaddr      => payload_i.m_axi4l_reg.awaddr(22 downto 0),
    p_m_axi4l_app_awprot      => payload_i.m_axi4l_reg.awprot,
    p_m_axi4l_app_awvalid     => payload_i.m_axi4l_reg.awvalid,
    p_m_axi4l_app_wdata       => payload_i.m_axi4l_reg.wdata,
    p_m_axi4l_app_wstrb       => payload_i.m_axi4l_reg.wstrb,
    p_m_axi4l_app_wvalid      => payload_i.m_axi4l_reg.wvalid,
    p_m_axi4l_app_bready      => payload_i.m_axi4l_reg.bready,
    p_m_axi4l_app_araddr      => payload_i.m_axi4l_reg.araddr(22 downto 0),
    p_m_axi4l_app_arprot      => payload_i.m_axi4l_reg.arprot,
    p_m_axi4l_app_arvalid     => payload_i.m_axi4l_reg.arvalid,
    p_m_axi4l_app_rready      => payload_i.m_axi4l_reg.rready,
    p_m_axi4l_app_awready     => payload_o.m_axi4l_reg.awready,
    p_m_axi4l_app_wready      => payload_o.m_axi4l_reg.wready,
    p_m_axi4l_app_bresp       => payload_o.m_axi4l_reg.bresp,
    p_m_axi4l_app_bvalid      => payload_o.m_axi4l_reg.bvalid,
    p_m_axi4l_app_arready     => payload_o.m_axi4l_reg.arready,
    p_m_axi4l_app_rdata       => payload_o.m_axi4l_reg.rdata,
    p_m_axi4l_app_rresp       => payload_o.m_axi4l_reg.rresp,
    p_m_axi4l_app_rvalid      => payload_o.m_axi4l_reg.rvalid,

    -- AXI4 Full Subordinate Interface for DDR Access (DAQ)
    p_s_axi4_ddr_awid      => payload_o.s_axi4_daq.awid(3 downto 0),
    p_s_axi4_ddr_arid      => payload_o.s_axi4_daq.arid(3 downto 0),
    p_s_axi4_ddr_araddr    => payload_o.s_axi4_daq.araddr,
    p_s_axi4_ddr_arburst   => payload_o.s_axi4_daq.arburst,
    p_s_axi4_ddr_arcache   => payload_o.s_axi4_daq.arcache,
    p_s_axi4_ddr_arlen     => payload_o.s_axi4_daq.arlen,
    p_s_axi4_ddr_arlock(0) => payload_o.s_axi4_daq.arlock,
    p_s_axi4_ddr_arprot    => payload_o.s_axi4_daq.arprot,
    p_s_axi4_ddr_arqos     => payload_o.s_axi4_daq.arqos,
    p_s_axi4_ddr_arready   => payload_i.s_axi4_daq.arready,
    p_s_axi4_ddr_arsize    => payload_o.s_axi4_daq.arsize,
    p_s_axi4_ddr_arvalid   => payload_o.s_axi4_daq.arvalid,
    p_s_axi4_ddr_awaddr    => ddr_awaddr,
    p_s_axi4_ddr_awburst   => payload_o.s_axi4_daq.awburst,
    p_s_axi4_ddr_awcache   => payload_o.s_axi4_daq.awcache,
    p_s_axi4_ddr_awlen     => payload_o.s_axi4_daq.awlen,
    p_s_axi4_ddr_awlock(0) => payload_o.s_axi4_daq.awlock,
    p_s_axi4_ddr_awprot    => payload_o.s_axi4_daq.awprot,
    p_s_axi4_ddr_awqos     => payload_o.s_axi4_daq.awqos,
    p_s_axi4_ddr_awready   => payload_i.s_axi4_daq.awready,
    p_s_axi4_ddr_awsize    => payload_o.s_axi4_daq.awsize,
    p_s_axi4_ddr_awvalid   => payload_o.s_axi4_daq.awvalid,
    p_s_axi4_ddr_bready    => payload_o.s_axi4_daq.bready,
    p_s_axi4_ddr_bresp     => payload_i.s_axi4_daq.bresp,
    p_s_axi4_ddr_bvalid    => payload_i.s_axi4_daq.bvalid,
    p_s_axi4_ddr_rdata     => payload_i.s_axi4_daq.rdata(255 downto 0), -- Must match DAQ Data Width!
    p_s_axi4_ddr_rlast     => payload_i.s_axi4_daq.rlast,
    p_s_axi4_ddr_rready    => payload_o.s_axi4_daq.rready,
    p_s_axi4_ddr_rresp     => payload_i.s_axi4_daq.rresp,
    p_s_axi4_ddr_rvalid    => payload_i.s_axi4_daq.rvalid,
    p_s_axi4_ddr_wdata     => payload_o.s_axi4_daq.wdata(255 downto 0), -- Must match DAQ Data Width!
    p_s_axi4_ddr_wlast     => payload_o.s_axi4_daq.wlast,
    p_s_axi4_ddr_wready    => payload_i.s_axi4_daq.wready,
    p_s_axi4_ddr_wstrb     => (others => '1'),
    p_s_axi4_ddr_wvalid    => payload_o.s_axi4_daq.wvalid
  );

  ins_sis8300ku_bsp_logic_top: entity work.sis8300ku_bsp_logic_top
  port map (
    pi_125_clk => sys_125_clk,
    po_app_clk => app_clk,

    --- Register interface
    pi_s_reg_clk => axi4_aclk,
    pi_s_reg_rst => not axi4_areset_n, -- Not used inside. TODO.
    pi_s_reg => s_reg_i,
    po_s_reg => s_reg_o,

    pi_ad9510_0_clk05_p => pi_ad9510_0_clk05_p,
    pi_ad9510_0_clk05_n => pi_ad9510_0_clk05_n,
    pi_ad9510_1_clk69_p => pi_ad9510_1_clk69_p,
    pi_ad9510_1_clk69_n => pi_ad9510_1_clk69_n,

    -- Monitoring the Clock used by DAC
    pi_dac_clk_fb_p => pi_dac_clk_fb_p,
    pi_dac_clk_fb_n => pi_dac_clk_fb_n,

    -- Clock Muxes
    po_mux_a_sel   => po_mux_a_sel,
    po_mux_b_sel   => po_mux_b_sel,
    po_mux_c_sel   => po_mux_c_sel,
    po_mux_d_sel   => po_mux_d_sel,
    po_mux_e_sel   => po_mux_e_sel,
    po_mux_dac_sel => po_mux_dac_sel,

    -- Two AD9510 PLL present in SIS8300-KU
    po_ad9510_cs_b     => po_ad9510_cs_b,
    po_ad9510_sclk     => po_ad9510_sclk,
    pio_ad9510_sdio    => pio_ad9510_sdio,
    po_ad9510_function => po_ad9510_function,

    -- ADC
    po_adc_cs_b   => po_adc_cs_b,
    pio_adc_sdio  => pio_adc_sdio,
    po_adc_sclk   => po_adc_sclk,
    po_adc_oe_n   => po_adc_oe_n,
    po_adc_pdwn   => po_adc_pdwn,
    pi_adc_dco_p  => pi_adc_dco_p,
    pi_adc_dco_n  => pi_adc_dco_n,
    pi_adc_or_p   => pi_adc_or_p,
    pi_adc_or_n   => pi_adc_or_n,
    pi_adc_data_p => pi_adc_data_p,
    pi_adc_data_n => pi_adc_data_n,

    -- DAC
    po_dac_pd      => po_dac_pd,
    po_dac_torb    => po_dac_torb,
    po_dac_clk_p   => po_dac_clk_p,
    po_dac_clk_n   => po_dac_clk_n,
    po_dac_seliq_p => po_dac_seliq_p,
    po_dac_seliq_n => po_dac_seliq_n,
    po_dac_data_p  => po_dac_data_p,
    po_dac_data_n  => po_dac_data_n,
    
    -- Misc
    po_led_serial_data => po_led_serial_data,
    pi_ddr_calib_done  => ddr_calib_done,
    pi_pcie_link_up    => pcie_link_up,
    
    -- PCIe Interrupt Handling
    pi_pcie_irq_ack      => pcie_irq_ack,
    po_pcie_irq_req_proc => pcie_irq_req_proc,

    -- FrontPanel IO (RJ45 Connector)
    po_fp_data_p => po_fp_data_p,
    po_fp_data_n => po_fp_data_n,
    pi_fp_data_p => pi_fp_data_p,
    pi_fp_data_n => pi_fp_data_n,

    -- Payload/Application Interface
    pi_payload_o => payload_o,
    po_payload_i => payload_i
  );

end arch;
 