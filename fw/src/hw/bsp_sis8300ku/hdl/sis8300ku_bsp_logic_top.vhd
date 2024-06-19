------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
-- @copyright Copyright 2021 DESY
-- SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
-- @date 2021-12-21
-- @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
-- @brief
-- Entity which carries logic which is outside of the Block Diagram of the BSP 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Payload interface
use work.pkg_sis8300ku_payload.all;
use work.pkg_bsp_config.all;

library desyrdl;
use desyrdl.pkg_sis8300ku_bsp_logic.all;

library desy;
use desy.common_axi.all;
use desy.common_types.all;
use desy.common_to_desyrdl.all;

library unisim;
use unisim.vcomponents.all;

entity sis8300ku_bsp_logic_top is
  port(
    pi_125_clk : in std_logic;
    po_app_clk : out std_logic;

    pi_s_reg     : in  t_sis8300ku_bsp_logic_m2s;
    po_s_reg     : out t_sis8300ku_bsp_logic_s2m;
    pi_s_reg_clk : in std_logic;
    pi_s_reg_rst : in std_logic;

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

    -- Two AD9510 PLL present in SIS8300KU
    po_ad9510_cs_b     : out   std_logic_vector(1 downto 0); -- Chip Select
    po_ad9510_sclk     : out   std_logic; -- Both PLL gets this
    pio_ad9510_sdio    : inout std_logic; -- Both PLL gets this
    po_ad9510_function : out   std_logic; -- Both PLL gets this

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
    
    -- DAC
    po_dac_pd      : out std_logic;
    po_dac_torb    : out std_logic;
    po_dac_clk_p   : out std_logic;
    po_dac_clk_n   : out std_logic;
    po_dac_seliq_p : out std_logic;
    po_dac_seliq_n : out std_logic;
    po_dac_data_p  : out std_logic_vector(15 downto 0);
    po_dac_data_n  : out std_logic_vector(15 downto 0);

    -- Misc
    -- DDR Calibration Done from MIG
    pi_ddr_calib_done : in std_logic;
    pi_pcie_link_up   : in std_logic;

    -- LED
    po_led_serial_data : out std_logic;

    -- Front Panel (RJ45) data input/outputs
    po_fp_data_p : out std_logic_vector(2 downto 0);
    po_fp_data_n : out std_logic_vector(2 downto 0);
    pi_fp_data_p : in std_logic_vector(2 downto 0);
    pi_fp_data_n : in std_logic_vector(2 downto 0);
    
    -- IRQ
    pi_pcie_irq_ack      : in  std_logic_vector(C_PCIE_IRQ_CNT-1 downto 0); -- Acknowledgement coming from xDMA. (pi_s_reg_clk clk domain)
    po_pcie_irq_req_proc : out std_logic_vector(C_PCIE_IRQ_CNT-1 downto 0); -- Processed IRQ Req going to xDMA. (pi_s_reg_clk clk domain)

    -- BSP Application interface
    po_payload_i : out t_payload_i;
    pi_payload_o : in  t_payload_o
  );
end entity sis8300ku_bsp_logic_top;

architecture rtl of sis8300ku_bsp_logic_top is
    
  constant C_SYS_CLK_FREQ : natural := 125_000_000; -- Frequency of the on-board crystal (fixed)
  
  signal addrmap_i : t_addrmap_sis8300ku_bsp_logic_in;
  signal addrmap_o : t_addrmap_sis8300ku_bsp_logic_out;

  signal bsp_clk              : std_logic; -- main board clock
  signal sys_200_clk          : std_logic; -- 200 MHz clock for iodelays
  signal app_clk_from_sys_clk : std_logic; -- App clock produced from 125 mhz sys clk
  signal app_clk              : std_logic; -- Clock that application receives
  signal app_x2_clk           : std_logic; -- 2xClock that application receives
  signal app_x3_clk           : std_logic; -- 3xClock that application receives
  signal sys_125_clk          : std_logic;
  signal dac_fb_clk           : std_logic; -- Clock which DAC receives (monitoring)
  signal ad9510_clk05         : std_logic; -- This is after BUFG.
  signal ad9510_clk69         : std_logic; -- This is after BUFG.
  signal app_clk_source_sel   : std_logic;
  signal ext_clk_error        : std_logic_vector(0 downto 0);
  signal clock_freq           : t_32b_slv_vector(7 downto 0);

  signal bsp_arst : std_logic;
  signal bsp_rst  : std_logic;
  signal app_rst  : std_logic;
  signal user_rst : std_logic; -- from a register manipulated by PCIe

  signal mmcm_locked     : std_logic; -- MMCM for BSP clocks locked
  signal mmcm_app_locked : std_logic; -- MMCM for APP clocks locked
  
  signal pcie_irq_ack_cnt : t_32b_slv_vector(C_PCIE_IRQ_CNT-1 downto 0);

begin

  ins_rdl: entity desyrdl.sis8300ku_bsp_logic
  port map (
    pi_clock => pi_s_reg_clk,
    pi_reset => '0',
    -- TOP subordinate memory mapped interface
    pi_s_top => pi_s_reg,
    po_s_top => po_s_reg,
    -- to logic interface
    pi_addrmap => addrmap_i,
    po_addrmap => addrmap_o
  );

  addrmap_i.DDR_CALIB_DONE.data.data(0) <= pi_ddr_calib_done;

  -- ============================================================================
  -- Resets
  -- ============================================================================
  blk_reset : block
    constant C_SYNC_STAGE : natural := 2;
    -- asynchronous assertion and synchronous(bsp_clk) deassertion
    signal areset   : std_logic_vector(C_SYNC_STAGE-1 downto 0) := (others => '1');
    -- synchronous(bsp_clk) assertion and deassertion
    signal sreset_0 : std_logic_vector(C_SYNC_STAGE-1 downto 0) := (others => '1');
    -- synchronous(bsp_clk) assertion and deassertion
    signal sreset_1 : std_logic_vector(C_SYNC_STAGE-1 downto 0) := (others => '1');
    -- synchronous(app_clk) assertion and deassertion
    signal sreset_2 : std_logic_vector(C_SYNC_STAGE-1 downto 0) := (others => '1');

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of areset   : signal is "TRUE";
    attribute ASYNC_REG of sreset_0 : signal is "TRUE";
    attribute ASYNC_REG of sreset_1 : signal is "TRUE";
    attribute ASYNC_REG of sreset_2 : signal is "TRUE";
  begin
    -- reset bridge
    prs_areset: process(bsp_clk, mmcm_locked)
    begin
      if mmcm_locked = '0' then
        areset <= (others => '1');
      elsif rising_edge(bsp_clk) then
        areset <= areset(C_SYNC_STAGE-2 downto 0) & '0';
      end if;
    end process prs_areset;

    -- reset synchronizers
    sreset_0 <= sreset_0(C_SYNC_STAGE-2 downto 0) & not(mmcm_locked) when rising_edge(bsp_clk);
    sreset_1 <= sreset_1(C_SYNC_STAGE-2 downto 0) & not(mmcm_app_locked) when rising_edge(bsp_clk);
    sreset_2 <= sreset_1(C_SYNC_STAGE-2 downto 0) & not(mmcm_app_locked) when rising_edge(app_clk);

    -- Main Reset Tree (all active high)
    bsp_arst <= areset(C_SYNC_STAGE-1);   -- to drive asynchronous resets with MMCM locked signal
    bsp_rst  <= sreset_0(C_SYNC_STAGE-1); -- drive sync reset on MMCM locked
    app_rst  <= sreset_2(C_SYNC_STAGE-1); -- application sync reset on MMCM locked
    user_rst <= not addrmap_o.RESET_N.data.data(0) when rising_edge(bsp_clk); -- user generated reset

    po_payload_i.app_domain_reset(0) <= app_rst;
    po_payload_i.bsp_domain_reset(0) <= user_rst or sreset_0(C_SYNC_STAGE-1) or sreset_1(C_SYNC_STAGE-1);

    -- Application AXI.4 Lite Bus Reset sync to Application Clock Domain
    po_payload_i.m_axi4l_reg_areset_n <= not app_rst;

  end block;
  
  -- ============================================================================
  -- Clocks
  -- ============================================================================
  blk_clock : block

    signal l_app_clk_source_sel : std_logic;

    signal l_phase_incdec_str : std_logic;
    signal l_phase_incdec : std_logic;

    signal l_ad9510_0_clk05 : std_logic;  -- output of First AD9510
    signal l_ad9510_1_clk69 : std_logic;  -- output of Second AD9510
    
    signal l_ad9510_sel   : std_logic_vector(1 downto 0);
    signal l_ad9510_sdout : std_logic;
    signal l_ad9510_read  : std_logic;
    signal l_ad9510_buf_t : std_logic;
    signal l_ad9510_cs_n : std_logic;
    signal l_ad9510_cs_b : std_logic_vector(1 downto 0);

    signal l_ad9510_busy : std_logic;
    
    signal l_ad9510_axi4l_m2s: t_axi4l_m2s;
    signal l_ad9510_axi4l_s2m: t_axi4l_s2m;

  begin
  
    bsp_clk <= pi_s_reg_clk; -- AXI4.Lite Bus Clock will be used as main clock for this entity
    po_payload_i.m_axi4l_reg_aclk <= app_clk;  -- App Clock is used for accessing App Registers over AXI.4L  
    po_app_clk <= app_clk; -- Routing the clock to the BD for AXI4.Lite CDC inside Block Design's SmartConnect
    
    -- Clocks that are going to application
    po_payload_i.bsp_domain_clock(0) <= bsp_clk;
    po_payload_i.bsp_domain_clock(1) <= sys_200_clk; -- This clock is not synced to bsp_clk TODO

    po_payload_i.app_domain_clock(0) <= app_clk;
    po_payload_i.app_domain_clock(1) <= app_x2_clk;
    po_payload_i.app_domain_clock(2) <= app_x3_clk;
    po_payload_i.app_domain_clock(3) <= '0';
    po_payload_i.app_domain_clock(4) <= '0';
    po_payload_i.app_domain_clock(5) <= '0';
    
    -- Accesing IBUS registers related to clocks
    po_mux_a_sel   <= addrmap_o.CLK_MUX(0).data.data;
    po_mux_b_sel   <= addrmap_o.CLK_MUX(1).data.data;
    po_mux_c_sel   <= addrmap_o.CLK_MUX(2).data.data;
    po_mux_d_sel   <= addrmap_o.CLK_MUX(3).data.data;
    po_mux_e_sel   <= addrmap_o.CLK_MUX(4).data.data;
    po_mux_dac_sel <= addrmap_o.CLK_MUX(5).data.data;

    app_clk_source_sel <= addrmap_o.CLK_SEL.data.data(0);

    -- Input Clock Buffers
    ins_ext_clk05_diff : ibufds port map (i => pi_ad9510_0_clk05_p, ib => pi_ad9510_0_clk05_n, o => l_ad9510_0_clk05);
    ins_ext_clk69_diff : ibufds port map (i => pi_ad9510_1_clk69_p, ib => pi_ad9510_1_clk69_n, o => l_ad9510_1_clk69);
    ins_bufg_ext_clk   : bufg   port map ( o => ad9510_clk05, i => l_ad9510_0_clk05);

    -- if external clock is wrong, prevent user to select external clock
    l_app_clk_source_sel <= app_clk_source_sel when ext_clk_error(0) = '0' else '0' ;
    
    ins_mmcm : entity work.bsp_mmcm_wrapper
    generic map(
      g_brd_clk_div   => 8, -- divider for bsp_clk = 125MHz*8/g_brd_clk_div
      g_app_clk_freq  => C_APP_FREQ
    )
    port map (
      pi_clk_125m  => pi_125_clk,
      pi_reset     => '0',
      po_200m_clk  => sys_200_clk,
      po_bsp_clk   => open, -- The real BSP Clock is coming from xDMA IP (user_clk derived from Fabric Clock)
      po_app_clk   => app_clk_from_sys_clk,
      po_locked    => mmcm_locked
    );

    ins_mmcm_app: entity work.app_mmcm_wrapper
    generic map (
      g_ext_freq => C_APP_FREQ)
    port map (
      pi_reset     => bsp_arst,
      pi_clock0    => ad9510_clk05,          -- output of ad9510 #1
      pi_clock1    => app_clk_from_sys_clk,  -- produced from sys clock
      pi_clock_sel => l_app_clk_source_sel,  -- 1 => p_i_clk0 gets selected   0 => p_i_clk1 gets selected (mmcm_adv feature)
      po_clock_1x  => app_clk,
      po_clock_2x  => app_x2_clk,
      po_clock_3x  => app_x3_clk,
      pi_psclk     => bsp_clk,
      pi_psen      => l_phase_incdec_str,
      pi_psincdec  => l_phase_incdec,
      po_locked    => mmcm_app_locked
    );

    -- if external clock is missing, switch to the internal clock automatically.
    ins_app_clk_ctrl : entity desy.app_clk_ctrl
    generic map(
      gen_ctrl_clk_freq => C_SYS_CLK_FREQ,
      gen_min_clk_freq  => (C_APP_FREQ - C_APP_FREQ_MAX_DIFF),
      gen_max_clk_freq  => (C_APP_FREQ + C_APP_FREQ_MAX_DIFF)
    )
    port map(
      pi_clock       => bsp_clk,
      pi_reset       => bsp_arst,
      pi_mmcm_locked => mmcm_app_locked,
      pi_clk_freq    => clock_freq(1),
      po_clk_error   => ext_clk_error(0),
      po_clk_sel     => open
    );

    addrmap_i.CLK_ERR.data.data <= ext_clk_error;

    -- AD9510
    pio_ad9510_sdio <= l_ad9510_sdout when (l_ad9510_buf_t = '0') else 'Z';

    -- IBUS registers
    l_ad9510_sel <= addrmap_o.SPI_DIV_SEL.data.data;
    po_ad9510_function <= not addrmap_o.CLK_RST.data.data(0);

    -- for backward compatibility write data to both dividers if spi_div_sel = 0
    l_ad9510_cs_b(0) <= l_ad9510_cs_n when (l_ad9510_sel = "01" or l_ad9510_sel = "00") else '1';
    l_ad9510_cs_b(1) <= l_ad9510_cs_n when (l_ad9510_sel = "10" or (l_ad9510_sel = "00" and l_ad9510_read = '0')) else '1';

    -- use same clock as the SPI interface to the chip
    process (bsp_clk)
    begin
      if rising_edge(bsp_clk) then
        if bsp_rst = '1' then
          po_ad9510_cs_b <= "11";
        else
          po_ad9510_cs_b <= l_ad9510_cs_b;
        end if;
      end if;
    end process;

    addrmap_i.SPI_DIV_BUSY.data.data(0) <= l_ad9510_busy;

    -- Converting from common_axi type to desyrdl axi type
    l_ad9510_axi4l_m2s <= f_common_to_desyrdl(addrmap_o.AREA_SPI_DIV);
    l_ad9510_axi4l_s2m <= f_common_to_desyrdl(addrmap_i.AREA_SPI_DIV);

    -- SPI interface to the AD9510 clock dividers
    ins_spi_ad9510 : entity desy.axi4_spi_3w
    generic map (
      g_clk_div    => 3, -- po_sclk = bsp_clk / [2*(g_clk_div +1)]
      g_bi_dir     => '1', -- SDIO bidirectional mode
      g_addr_width => 9
    )
    port map (
      pi_clock     => bsp_clk,
      pi_reset     => bsp_rst,
      pi_axi4l_m2s => l_ad9510_axi4l_m2s,
      po_axi4l_s2m => l_ad9510_axi4l_s2m,
      po_read      => l_ad9510_read,
      po_busy      => l_ad9510_busy,
      po_sclk      => po_ad9510_sclk,
      po_cs_n      => l_ad9510_cs_n,
      po_buf_t     => l_ad9510_buf_t,
      po_sdout     => l_ad9510_sdout,
      pi_sdin      => pio_ad9510_sdio
    );

    -- Clock Frequency Calculation
    ins_clk_status : entity desy.clock_freq 
    generic map (
      g_clock_freq  => C_SYS_CLK_FREQ,
      g_clock_count => 8
    )
    port map (
      pi_clock => bsp_clk,
      pi_reset => '0',
      po_clock_freq => clock_freq,

      pi_clock_vect(0) => bsp_clk,
      pi_clock_vect(1) => ad9510_clk05,
      pi_clock_vect(2) => ad9510_clk69,
      pi_clock_vect(3) => dac_fb_clk,
      pi_clock_vect(4) => '0',
      pi_clock_vect(5) => app_clk, -- TODO: Put LLL clock frequencies here in the future
      pi_clock_vect(6) => app_clk,
      pi_clock_vect(7) => app_clk 
    );
    
    g_freq : for i in 0 to 7 generate
        addrmap_i.CLK_FREQ(i).data.data <= clock_freq(i);
    end generate;

  end block;

  -- ============================================================================
  -- Interrupt CDC
  -- ============================================================================
  blk_irq : block
    signal pcie_irq_ena : std_logic_vector(C_PCIE_IRQ_CNT-1 downto 0);
    signal ack_timeout_cnt : t_32b_slv_vector(C_PCIE_IRQ_CNT-1 downto 0);
  begin
    gen_loop : for i in 0 to C_PCIE_IRQ_CNT-1 generate
      pcie_irq_ena(i) <= addrmap_o.PCIE_IRQ_ENA(i).data.data(0);
      addrmap_i.PCIE_IRQ_ACK_TIMEOUT(i).data.data <= ack_timeout_cnt(i);
    end generate;
    
    ins_irq_handler : entity desy.xdma_irq_handler
    generic map(
      G_IRQ_CNT => C_PCIE_IRQ_CNT,
      G_TIMEOUT_CNT => 125_000 -- Ack. arrival timeout in seconds = G_TIMEOUT_CNT/xDMA AXI Freq (125MHz). -> 1 us
    )
    port map(
      pi_user_clk            => app_clk,
      pi_user_irq_req        => pi_payload_o.pcie_irq_req,
      pi_xdma_clk            => bsp_clk,
      pi_xdma_irq_ack        => pi_pcie_irq_ack,
      pi_xdma_irq_ena        => pcie_irq_ena,
      po_xdma_irq_req        => po_pcie_irq_req_proc,
      po_irq_ack_timeout_cnt => ack_timeout_cnt
    );
  end block;

  -- ==========================================================================
  -- ADC
  -- ==========================================================================
  blk_adc : block
    -- when using dwc10 rtm, clocks clk05 and clk69 are shifted 90deg in phase but we use only one of them to read adc data
    constant C_REVERT_PHASE_DEFAULT : std_logic_vector(4 downto 0) := "11000";

    signal l_adc_buf_t : std_logic;
    signal l_adc_sdout : std_logic;
    signal l_adc_cs_n  : std_logic;
    signal l_adc_read  : std_logic;
    signal l_adc_sel   : std_logic_vector(2 downto 0);
    signal l_adc_cs_b  : std_logic_vector(4 downto 0);

    -- ADC IDELAY Controls and Status
    signal l_adc_idelay_inc    : std_logic;
    signal l_adc_idelay_sel    : std_logic_vector(7 downto 0);
    signal l_adc_idelay_str    : std_logic;
    signal l_adc_idelay_str_ii : std_logic;
    signal l_adc_idelay_str_q  : std_logic;
    signal l_adc_idelay_cnt    : t_9b_slv_vector(4 downto 0);
    signal l_spi_adc_busy      : std_logic;

    -- ADC control registers
    -- revert used to change phase of adc in case of external clock phase difference between clk05 and clk69
    signal l_adc_revert_phase    : std_logic_vector(4 downto 0) := C_REVERT_PHASE_DEFAULT;
    signal l_adc_revert_phase_q  : std_logic_vector(4 downto 0) := C_REVERT_PHASE_DEFAULT;
    signal l_adc_revert_phase_qq : std_logic_vector(4 downto 0) := C_REVERT_PHASE_DEFAULT;
    
    signal l_adc_axi4l_m2s: t_axi4l_m2s;
    signal l_adc_axi4l_s2m: t_axi4l_s2m;

  begin

    po_adc_pdwn <= '0'; -- ADCs always enabled!
    po_adc_oe_n <= not addrmap_o.ADC_ENA.data.data(0);
    pio_adc_sdio <= l_adc_sdout when (l_adc_buf_t = '0') else 'Z';

    gen_idelay_cnt_to_regs : for i in 4 downto 0 generate
      addrmap_i.ADC_IDELAY_CNT(i).data.data <= l_adc_idelay_cnt(i);
    end generate;

    l_adc_idelay_inc    <= '0';
    l_adc_idelay_sel    <= (others => '0');
    l_adc_idelay_str_ii <= '0';
    l_adc_idelay_str_q  <= l_adc_idelay_str_ii when rising_edge(bsp_clk);
    l_adc_idelay_str    <= '1' when l_adc_idelay_str_q = '1' and l_adc_idelay_str_ii = '0' else '0';
    
    l_adc_sel <= addrmap_o.SPI_ADC_SEL.data.data;

    -- for backward compatibility write data to all adc's if spi_adc_sel = 0
    l_adc_cs_b(0) <= l_adc_cs_n when (l_adc_sel = "001" or l_adc_sel = "000") else '1';
    l_adc_cs_b(1) <= l_adc_cs_n when (l_adc_sel = "010" or (l_adc_sel = "000" and l_adc_read = '0')) else '1';
    l_adc_cs_b(2) <= l_adc_cs_n when (l_adc_sel = "011" or (l_adc_sel = "000" and l_adc_read = '0')) else '1';
    l_adc_cs_b(3) <= l_adc_cs_n when (l_adc_sel = "100" or (l_adc_sel = "000" and l_adc_read = '0')) else '1';
    l_adc_cs_b(4) <= l_adc_cs_n when (l_adc_sel = "101" or (l_adc_sel = "000" and l_adc_read = '0')) else '1';

    process (bsp_clk)
    begin
      if rising_edge(bsp_clk) then
        if bsp_rst = '1' then
          po_adc_cs_b <= "11111";
        else
          po_adc_cs_b <= l_adc_cs_b;
        end if;
      end if;
    end process;

    -- sync to ADC clock domain
    process(app_clk)
    begin
      if rising_edge(app_clk) then
        l_adc_revert_phase_q  <= l_adc_revert_phase;
        l_adc_revert_phase_qq <= l_adc_revert_phase_q;
      end if;
    end process;
   
    process(bsp_clk)
    begin
      if rising_edge(bsp_clk) then
        if addrmap_o.ADC_REVERT_CLK.data.swmod = '1' then
          l_adc_revert_phase <= addrmap_o.ADC_REVERT_CLK.data.data;
        end if;
      end if;
    end process;

    addrmap_i.SPI_ADC_BUSY.data.data(0) <= l_spi_adc_busy;

    -- Converting from common_axi type to desyrdl axi type
    l_adc_axi4l_m2s  <= f_common_to_desyrdl(addrmap_o.AREA_SPI_ADC);
    l_adc_axi4l_s2m  <= f_common_to_desyrdl(addrmap_i.AREA_SPI_ADC);

    -- SPI interface to the AD9268 ADCs
    ins_spi_ad9268 : entity desy.axi4_spi_3w
    generic map (
      g_clk_div    => 3, -- po_sclk = pi_clock / [2*(g_clk_div +1)]
      g_bi_dir     => '1', -- SDIO bidirectional mode
      g_addr_width => 11
    )
    port map (
      pi_clock     => bsp_clk,
      pi_reset     => bsp_rst,
      pi_axi4l_m2s => l_adc_axi4l_m2s,
      po_axi4l_s2m => l_adc_axi4l_s2m,
      po_read      => l_adc_read,
      po_busy      => l_spi_adc_busy,
      po_sclk      => po_adc_sclk,
      po_cs_n      => l_adc_cs_n,
      po_buf_t     => l_adc_buf_t,
      po_sdout     => l_adc_sdout,
      pi_sdin      => pio_adc_sdio
    );

    ins_adc_ad9628: entity desy.ad9628
    generic map(
      G_MAX_DELAY => 32,
      G_USE_FIFO => C_ADC_USE_FIFO)
    port map(
      pi_reset    => app_rst,
      pi_200_clk  => sys_200_clk,
      pi_clock    => app_clk,

      po_adc_data   => po_payload_i.adc,
      po_adc_or     => po_payload_i.adc_ov,
      po_adc_vld    => open,
      pi_adc_rdy    => (others => '1'),

      -- TODO: FIFO implementation
      pi_adc_fifo_reset => (others => '0'),             
      pi_adc_fifo_delay => (others => (others => '0')),
      pi_adc_delay      => (others => (others => '0')),
      pi_revert_phase   => l_adc_revert_phase_qq,

      pi_idelay_clk  => bsp_clk,
      pi_idelay_inc  => l_adc_idelay_inc,
      pi_idelay_sel  => l_adc_idelay_sel(4 downto 0),
      pi_idelay_str  => l_adc_idelay_str,
      po_idelay_cnt  => l_adc_idelay_cnt,

      pi_adc_dco_p  => pi_adc_dco_p,
      pi_adc_dco_n  => pi_adc_dco_n,
      pi_adc_or_p   => pi_adc_or_p,
      pi_adc_or_n   => pi_adc_or_n,
      pi_adc_data_p => pi_adc_data_p,
      pi_adc_data_n => pi_adc_data_n
    );

  end block;

  -- ==========================================================================
  -- DAC
  -- ==========================================================================
  blk_dac : block
    signal l_dac_ena : std_logic := '1';
    signal l_dac_rst : std_logic;

    signal l_dac_idelay_inc    : std_logic;
    signal l_dac_idelay_str    : std_logic;
    signal l_dac_idelay_str_ii : std_logic;
    signal l_dac_idelay_str_q  : std_logic;
    signal l_dac_idelay_cnt  : t_9b_slv_vector(0 downto 0);

    signal sig_loc_clk_2x         : std_logic;
    signal sig_loc_clk_2x_bef_buf : std_logic;
    signal sig_loc_clk_1x         : std_logic;
    signal sig_loc_clk_1x_bef_buf : std_logic;
    signal sig_loc_clk_fb_in      : std_logic;
    signal sig_loc_clk_fb_out     : std_logic;

  begin

    ins_dac_clk_fb_buf : ibufds port map (i => pi_dac_clk_fb_p, ib => pi_dac_clk_fb_n, o => dac_fb_clk);

    l_dac_ena <= addrmap_o.DAC_ENA.data.data(0);

    po_dac_torb <= C_DAC_MODE;
    po_dac_pd <= not l_dac_ena;

    l_dac_rst <= bsp_rst or not l_dac_ena;

    l_dac_idelay_inc    <= addrmap_o.DAC_IDELAY_INC.data.data(0);
    l_dac_idelay_str_ii <= addrmap_o.DAC_IDELAY_INC.data.swmod;
    l_dac_idelay_str_q  <= l_dac_idelay_str_ii when rising_edge(bsp_clk);
    l_dac_idelay_str    <= '1' when l_dac_idelay_str_q = '1' and l_dac_idelay_str_ii = '0' else '0';

    addrmap_i.DAC_IDELAY_CNT.data.data <= l_dac_idelay_cnt(0);

    ins_dac : entity desy.max5878
    port map(
      pi_200_clk => sys_200_clk,
      pi_reset   => l_dac_rst,
      
      pi_dac_2x_clk => app_x2_clk,
      pi_dac_data_rdy => pi_payload_o.dac_data_rdy,

      pi_dac_data_i => pi_payload_o.dac_data_i,
      pi_dac_data_q => pi_payload_o.dac_data_q,

      po_dac_clk_p => po_dac_clk_p,
      po_dac_clk_n => po_dac_clk_n,

      po_dac_seliq_p => po_dac_seliq_p,
      po_dac_seliq_n => po_dac_seliq_n,

      po_dac_data_p => po_dac_data_p,
      po_dac_data_n => po_dac_data_n,

      pi_idelay_clk => bsp_clk,
      pi_idelay_inc => l_dac_idelay_inc,
      pi_idelay_str => l_dac_idelay_str,
      po_idelay_cnt => l_dac_idelay_cnt(0)
    );

  end block;

  -- ==========================================================================
  --  LED 
  -- ==========================================================================
  blk_led : block

    constant C_L_COUNTER_MAX : unsigned(31 downto 0) := to_unsigned(C_SYS_CLK_FREQ-1, 32);

    signal l_counter        : unsigned(31 downto 0);
    signal l_counter_done   : std_logic;
    signal l_led_data       : std_logic_vector(3 downto 0) := "1000";
    signal l_led_data2      : std_logic_vector(7 downto 0);
    signal l_pcie_link_up_q : std_logic;

  begin

    -- sn74lv8153pw two chips
    -- front panel leds address: 001, pcb leds: 000
    -- fp y0 - high left
    -- fp y1 - high right
    -- fp y2 - low left
    -- fp y3 - low right

    -- pi_data is duplicated: the sn74lv8153 has un-controllable and
    -- un-observable internal state which selects between high and low nibble.
    -- by sending the data twice we make sure that we write to leds.

    l_led_data2 <= l_led_data & l_led_data ;

    proc_cntr: process (bsp_clk)
    begin
      if rising_edge(bsp_clk) then
        if bsp_rst = '1' then
          l_counter <= to_unsigned(0, l_counter'length);
        elsif l_counter_done = '1' then
          l_counter <= to_unsigned(0, l_counter'length);
        else
          l_counter <= l_counter + 1;
        end if;
      end if;
    end process;

    l_counter_done <= '1' when l_counter = c_l_counter_max else '0';

    l_led_data(1) <= addrmap_o.BOOT_STATUS.data.data(0) when rising_edge(bsp_clk);
    
    l_pcie_link_up_q <= pi_pcie_link_up when rising_edge(bsp_clk); -- Single stage synchronizer to BSP clock domain

    proc_led: process (bsp_clk)
    begin
      if rising_edge(bsp_clk) then
        if l_counter_done = '1' then
          l_led_data(0) <= l_pcie_link_up_q;
          l_led_data(2) <= mmcm_app_locked;
          l_led_data(3) <= not l_led_data(3);
        end if;
      end if;
    end process;

    ins_sn74lv8153: entity desy.sn74lv8153
    generic map (
      G_DEV_ADDR     => "001",
      G_CLK_FREQ     => C_SYS_CLK_FREQ,
      G_BAUD_RATE    => 10_000, -- baud rate in hz (should be between 2 and 24 kbps)
      G_REFRESH_RATE => 50 -- refresh rate in hz
    )
    port map (
      pi_clock  => bsp_clk,
      pi_reset  => bsp_rst,
      pi_data   => l_led_data2,
      po_serial => po_led_serial_data
    );

  end block blk_led;

  --============================================================================
  -- front panel RJ45 connector buffers
  --============================================================================
  blk_fp_io : block
    signal l_fp_out : std_logic_vector(2 downto 0);
    signal l_fp_in  : std_logic_vector(2 downto 0);
    signal l_fp_out_user : std_logic_vector(2 downto 0);
  begin
    
    --l_fp_out_user <= addrmap_i.WORD_RJ45_OUT.data.data;
    l_fp_out_user <= "000";
    l_fp_out <= pi_payload_o.fp_data_out; -- or l_fp_out_user; -- User can override Application signals

    po_payload_i.fp_data_in <= l_fp_in; -- Giving it to the Application (!Care! It is not synced to App clock domain!)

    gen_buf_hrl : for i in 0 to 2 generate
      ins_fp_io_ibuf : ibufds_lvds_25 port map (i => pi_fp_data_p(i), ib => pi_fp_data_n(i), o => l_fp_in(i)); -- harlink signal coming from front panel 
      ins_fp_io_obuf : obufds_lvds_25 port map (o => po_fp_data_p(i), ob => po_fp_data_n(i), i => l_fp_out(i)); -- harlink signal coming out of front panel 
    end generate;

  end block;
  
  -- ==========================================================================
  -- FPGA Configuration Manager
  -- ==========================================================================
  ins_config_manager: entity work.fpga_config_manager_top
  generic map (
    g_arch           => "ULTRASCALE",
    g_icap_clk_div   => 2,
    g_ecc_enable     => 0
  )
  port map (
    pi_clock        => bsp_clk,
    pi_reset        => bsp_rst,

    pi_s_top        => addrmap_o.fcm,
    po_s_top        => addrmap_i.fcm,

    pi_jtag_tdo     => '0',
    po_jtag_tdi     => open,
    po_jtag_tms     => open,
    po_jtag_tck     => open,

    pi_spi_sdi      => '0',
    po_spi_sdo      => open,
    po_spi_cs_n     => open,
    po_spi_clk      => open,

    pi_ext_spi_enable => '0',
    pi_ext_spi_sdo    => '0',
    pi_ext_spi_cs_n   => '1',
    po_ext_spi_sdi    => open,
    pi_ext_spi_clk    => '0'
  );

end architecture rtl;
