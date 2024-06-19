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
-- @date 2021-10-03
-- @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
-- @brief
-- ADC Component handling for SIS8300KU Board
-- The ADCs should be configured in LVDS mode: "Output mode" register (at
-- address 0x14) should be set to 0x40.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all ;

library unisim;
use unisim.vcomponents.all;

library desy;
use desy.common_types.all;
use desy.common_numarray.all;

entity ad9628 is
generic (
  G_MAX_DELAY    : natural := 32;  -- max delay
  G_USE_DCO      : natural := 0 ;
  G_USE_FIFO     : natural := 0 ;  -- FIFO implementation
  G_DELAY_VALUE  : t_natural_vector(4 downto 0) := (0 => 30, 1 => 50, 2 => 80, 3 => 80, 4 => 80)  -- default delays, 0-511
);
port (
  pi_clock     : in std_logic;   -- interface clock
  pi_reset     : in std_logic;
  pi_200_clk   : in std_logic;   -- clock for calibration of delay elements

  -- ADC data out
  po_adc_data : out t_16b_slv_vector(9 downto 0);
  po_adc_or   : out std_logic_vector(9 downto 0);
  po_adc_vld  : out std_logic_vector(9 downto 0);
  pi_adc_rdy  : in  std_logic_vector(9 downto 0);

  ------------------------------------------------------------
  -- Delays for FIFO implementation
  pi_adc_fifo_reset : in std_logic_vector(9 downto 0) := "0000000000";
  pi_adc_fifo_delay : in t_8b_slv_vector(9 downto 0) := (others => (others => '0'));

  -- Delays for noFIFO implementaion
  pi_adc_delay : in t_8b_slv_vector(9 downto 0) := (others => (others => '0'));
    -- revert phase of the clk for inputs only for noFIFO implementation
  pi_revert_phase : in std_logic_vector(4 downto 0) := "11000";

  -- IDELAY - tap delays for input elements
  pi_idelay_clk : in std_logic;
  pi_idelay_inc : in std_logic := '0';
  pi_idelay_sel : in std_logic_vector(4 downto 0) := (others => '0');
  pi_idelay_str : in std_logic := '0';
  po_idelay_cnt : out t_9b_slv_vector(4 downto 0);  -- current IDELAY settings

  ------------------------------------------------------------
  -- ADC interface
  pi_adc_dco_p  : in std_logic_vector(4 downto 0);
  pi_adc_dco_n  : in std_logic_vector(4 downto 0);
  pi_adc_or_p   : in std_logic_vector(4 downto 0);
  pi_adc_or_n   : in std_logic_vector(4 downto 0);
  pi_adc_data_p : in t_16b_slv_vector(4 downto 0);
  pi_adc_data_n : in t_16b_slv_vector(4 downto 0)
);
end ad9628;

architecture ARC_MIXED of ad9628 is

  -- ADC clocks
  signal adc_clk     : std_logic_vector(4 downto 0);
  signal adc_dco_buf : std_logic_vector(4 downto 0);

  -- ADC over-range
  signal adc_or_buf : std_logic_vector(4 downto 0);
  signal adc_or_dly : std_logic_vector(4 downto 0);
  signal adc_or_ddr : std_logic_vector(9 downto 0);

  -- ADC data (DDR)
  signal adc_data_buf : t_16b_slv_vector(4 downto 0);
  signal adc_data_dly : t_16b_slv_vector(4 downto 0);
  signal adc_data_ddr : t_16b_slv_vector(9 downto 0);

  -- ADC data registered
  signal adc_data : t_16b_slv_vector(9 downto 0);
  signal adc_or   : std_logic_vector(9 downto 0);

  -- IDELAY ctrl
  signal reset_200_q, reset_200_qq : std_logic;

  -- attributes
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of reset_200_q   : signal is "TRUE";
  attribute ASYNC_REG of reset_200_qq  : signal is "TRUE";

  attribute IODELAY_GROUP : string;
  attribute IODELAY_GROUP of ins_idelayctrl : label is "IDLYCTRL_ADC";

begin

  --================================================================================================
  -- shared infrastructure
  reset_200_q  <= pi_reset when rising_edge(pi_200_clk);
  reset_200_qq <= reset_200_q when rising_edge(pi_200_clk);

  ins_idelayctrl : idelayctrl
  generic map (
    SIM_DEVICE => "ULTRASCALE")
  port map (
    rdy    => open,
    refclk => pi_200_clk,
    rst    => reset_200_qq
  );


  --================================================================================================
  -- select ADC clocks, in FIFO mode always use DCO
  gen_clk_dco: if G_USE_DCO = 1 or G_USE_FIFO = 1  generate
    adc_clk <= adc_dco_buf;
  end generate;

  gen_clk: if G_USE_DCO = 0 and G_USE_FIFO = 0  generate
    adc_clk <= (others => pi_clock );
  end generate;


  --================================================================================================
  -- ADC input diff buffers
  gen_adc_buf: for i in pi_adc_data_p'range generate
    --------------------------------------------------
    -- ADC data
    gen_adc_buf_lane: for j in pi_adc_data_p(0)'range generate
      ins_ibufds : ibufds
      generic map (
        DQS_BIAS => "FALSE")
      port map (
        O  => adc_data_buf(i)(j),
        i  => pi_adc_data_p(i)(j),
        ib => pi_adc_data_n(i)(j)
      );
    end generate;
    --------------------------------------------------
    -- ADC over-range
    ins_ibufds_or : ibufds
    generic map (
      DQS_BIAS => "FALSE")
    port map (
      o  => adc_or_buf(i),
      i  => pi_adc_or_p(i),
      ib => pi_adc_or_n(i)
    );
  --------------------------------------------------
    -- ADC data clock output
    ins_ibufds_dco : ibufds
    generic map (
      DQS_BIAS => "FALSE")
    port map (
      o  => adc_dco_buf(i),
      i  => pi_adc_dco_p(i),
      ib => pi_adc_dco_n(i)
    );
  end generate;


  --================================================================================================
  -- IDELAYS all signals in one lane are shifted in-sync
  gen_adc_dly: for i in pi_adc_data_p'range generate
    attribute IODELAY_GROUP of ins_idelaye3_or: label is "IDLYCTRL_ADC";
    signal l_ce : std_logic;
  begin

    l_ce <= '1' when pi_idelay_sel(I) = '1' and pi_idelay_str = '1' else '0';

    GEN_ADC_DLY_LANE: for J in pi_adc_data_p(0)'range generate
      attribute IODELAY_GROUP of INS_IDELAYE3: label is "IDLYCTRL_ADC";
    begin

      ins_idelaye3 : idelaye3
      generic map (
        CASCADE          => "NONE",
        DELAY_FORMAT     => "COUNT",
        DELAY_SRC        => "IDATAIN",
        DELAY_TYPE       => "VARIABLE",
        DELAY_VALUE      => G_DELAY_VALUE(I),
        IS_CLK_INVERTED  => '0',
        IS_RST_INVERTED  => '0',
        REFCLK_FREQUENCY => 200.0,
        SIM_DEVICE       => "ULTRASCALE",
        UPDATE_MODE      => "ASYNC"
      )
      port map (
        casc_out         => open,
        cntvalueout      => open,
        dataout          => adc_data_dly(i)(j),
        casc_in          => '0',
        casc_return      => '0',
        ce               => l_ce,
        clk              => pi_idelay_clk,
        cntvaluein       => (others => '0'),
        datain           => '0',
        en_vtc           => '0',
        idatain          => adc_data_buf(i)(j),
        inc              => pi_idelay_inc,
        load             => '0',
        rst              => pi_reset
      );

    end generate gen_adc_dly_lane;

    -- ADC over voltage IODELAY
    ins_idelaye3_or : idelaye3
    generic map (
      CASCADE          => "NONE",
      DELAY_FORMAT     => "COUNT",
      DELAY_SRC        => "IDATAIN",
      DELAY_TYPE       => "VARIABLE",
      DELAY_VALUE      => G_DELAY_VALUE(I),
      IS_CLK_INVERTED  => '0',
      IS_RST_INVERTED  => '0',
      REFCLK_FREQUENCY => 200.0,
      SIM_DEVICE       => "ULTRASCALE",
      UPDATE_MODE      => "ASYNC"
    )
    port map (
      casc_out         => open,
      cntvalueout      => po_idelay_cnt(i),
      dataout          => adc_or_dly(i),
      casc_in          => '0',
      casc_return      => '0',
      ce               => l_ce,
      clk              => pi_idelay_clk,
      cntvaluein       => (others => '0'),
      datain           => '0',
      en_vtc           => '0',
      idatain          => adc_or_buf(i),
      inc              => pi_idelay_inc,
      load             => '0',
      rst              => pi_reset
    );


  end generate;

  --==============================================================================
  -- ADC IDDR
  gen_adc_ddr: for i in pi_adc_data_p'range generate

    gen_lane: for j in pi_adc_data_p(0)'range generate
    ins_iddr: iddre1
      generic map (
        DDR_CLK_EDGE => "SAME_EDGE_PIPELINED",
        IS_CB_INVERTED => '1',
        IS_C_INVERTED => '0'
      )
      port map (
        q1 => adc_data_ddr(2*i)(j),
        q2 => adc_data_ddr(2*i+1)(j),
        c  => adc_clk(i),
        cb => adc_clk(i),
        d  => adc_data_dly(i)(j),
        r  => '0'
      );
    end generate;

    ins_iddr_or : iddre1
    generic map (
      DDR_CLK_EDGE => "SAME_EDGE_PIPELINED",
      IS_CB_INVERTED => '1',
      IS_C_INVERTED => '0'
    )
    port map (
      q1 => adc_or_ddr(2*i),
      q2 => adc_or_ddr(2*i+1),
      c  => adc_clk(i),
      cb => adc_clk(i),
      d  => adc_or_dly(i),
      r  => '0'
    );

  end generate;

  --==============================================================================
  -- ADC register
  --==============================================================================
  gen_adc_reg: for i in pi_adc_data_p'range generate
    proc_adc_data: process (adc_clk(I))
    begin
      if rising_edge(adc_clk(I)) then
        adc_data(2*I)   <= adc_data_ddr(2*I);
        adc_data(2*I+1) <= adc_data_ddr(2*I+1);
        adc_or(2*I)     <= adc_or_ddr(2*I);
        adc_or(2*I+1)   <= adc_or_ddr(2*I+1);
      end if;
    end process;
  end generate gen_adc_reg;

  --==============================================================================
  -- in case no FIFO implement delays on shift registers
  --==============================================================================
  gen_no_fifo: if G_USE_FIFO = 0  generate
    -- delay for read data
    gen_delay: for i in pi_adc_data_p'range generate
      signal reg_adca_dly : t_16b_slv_vector(G_MAX_DELAY-1 downto 0):= ( others => ( others => '0' ) );
      signal reg_adcb_dly : t_16b_slv_vector(G_MAX_DELAY-1 downto 0):= ( others => ( others => '0' ) ) ;
      signal reg_adca_ov  : std_logic_vector(G_MAX_DELAY-1 downto 0):= ( others => '0' ) ;
      signal reg_adcb_ov  : std_logic_vector(G_MAX_DELAY-1 downto 0):= ( others => '0' ) ;
      signal reg_drya_dly : std_logic_vector(G_MAX_DELAY-1 downto 0):= ( others => '0' ) ;
      signal reg_dryb_dly : std_logic_vector(G_MAX_DELAY-1 downto 0):= ( others => '0' ) ;
    begin

      ------------------------------------------------------------
      -- shift register
      process (pi_clock) is
      begin
        if rising_edge(pi_clock) then
          if pi_revert_phase(I) = '1' then
            reg_adca_dly <= reg_adca_dly(G_MAX_DELAY-2 downto 0) & adc_data(2*I+0);
            reg_adcb_dly <= reg_adcb_dly(G_MAX_DELAY-2 downto 0) & adc_data(2*I+1);
            reg_adca_ov  <= reg_adca_ov(G_MAX_DELAY-2 downto 0) & adc_or(2*I+0);
            reg_adcb_ov  <= reg_adcb_ov(G_MAX_DELAY-2 downto 0) & adc_or(2*I+1);
          else
            reg_adca_dly <= reg_adca_dly(G_MAX_DELAY-2 downto 0) & adc_data(2*I+1);
            reg_adcb_dly <= reg_adcb_dly(G_MAX_DELAY-2 downto 0) & adc_data(2*I+0);
            reg_adca_ov  <= reg_adca_ov(G_MAX_DELAY-2 downto 0) & adc_or(2*I+1);
            reg_adcb_ov  <= reg_adcb_ov(G_MAX_DELAY-2 downto 0) & adc_or(2*I+0);
          end if;
        end if;
      end process;

      process (pi_clock) is
      begin
        if rising_edge(pi_clock) then
          if pi_reset = '1' then
            reg_drya_dly <= ( others => '0' ) ;
            reg_dryb_dly <= ( others => '0' ) ;
          else
            reg_drya_dly <= reg_drya_dly(G_MAX_DELAY-2 downto 0) & '1';
            reg_dryb_dly <= reg_dryb_dly(G_MAX_DELAY-2 downto 0) & '1';
          end if;
        end if;
      end process;

      ------------------------------------------------------------
      -- revert phase - it is equivalent to swap ADC channels
      -- multiplexer
      process (pi_clock) is
      begin
        if rising_edge(pi_clock) then
          if pi_adc_delay(2*I+0) = std_logic_vector(to_unsigned(0, 8)) then
            if pi_revert_phase(I) = '1' then
              po_adc_data(2*I+0)  <= adc_data(2*I+0);
              po_adc_or(2*I+0)    <= adc_or(2*I+0);
            else
              po_adc_data(2*I+0)  <= adc_data(2*I+1);
              po_adc_or(2*I+0)    <= adc_or(2*I+1);
            end if;
            po_adc_vld(2*I+0)   <= '1';
          else
            po_adc_data(2*I+0)  <= reg_adca_dly(to_integer(unsigned(pi_adc_delay(2*I+0))));
            po_adc_or(2*I+0)    <= reg_adca_ov(to_integer(unsigned(pi_adc_delay(2*I+0))));
            po_adc_vld(2*I+0) <= reg_drya_dly(to_integer(unsigned(pi_adc_delay(2*I+0))));
          end if;
        end if;
      end process;

      process (pi_clock) is
      begin
        if rising_edge(pi_clock) then
          if pi_adc_delay(2*I+1) = std_logic_vector(to_unsigned(0, 8)) then
            if pi_revert_phase(I) = '1' then
              po_adc_data(2*I+1)  <= adc_data(2*I+1);
              po_adc_or(2*I+1)    <= adc_or(2*I+1);
            else
              po_adc_data(2*I+1)  <= adc_data(2*I+0);
              po_adc_or(2*I+1)    <= adc_or(2*I+0);
            end if;
            po_adc_vld(2*I+1)   <= '1';
          else
            po_adc_data(2*I+1)  <= reg_adcb_dly(to_integer(unsigned(pi_adc_delay(2*I+1))));
            po_adc_or(2*I+1)    <= reg_adcb_ov(to_integer(unsigned(pi_adc_delay(2*I+1))));
            po_adc_vld(2*I+1) <= reg_dryb_dly(to_integer(unsigned(pi_adc_delay(2*I+1))));
          end if;
        end if;
      end process;
    end generate gen_delay;

  end generate gen_no_fifo;

  -- TODO: FIFO implementation

end architecture;
