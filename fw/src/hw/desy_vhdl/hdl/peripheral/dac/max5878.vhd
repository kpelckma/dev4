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
-- @date 2019-05-20
-- @author Jan Marjanovic <jan.marjanovic@desy.de>
-- @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
-- @brief
-- Interface to MAX 5878, based on similar module from SIS8300L
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library desy;
use desy.common_numarray.all;

-------------------------------------------------------------------------------
-- @brief Interface of DAC module
entity max5878 is
  generic (
    G_ODELAY_DATA_DELAY : t_natural_vector(0 to 15) := (others => 0);
    G_ODELAY_SEL_DELAY : natural := 0;
    G_ODELAY_CLK_DELAY : natural := 0
  );
  port (
    pi_200_clk : in std_logic;
    pi_dac_2x_clk   : in  std_logic;-- DAC clk, should be 2 x clk for P_I_DAC_DATA_x
    pi_reset   : in std_logic;
    
    pi_dac_data_rdy : in  std_logic; -- input data ready far latching data in register
    pi_dac_data_i   : in  std_logic_vector(15 downto 0);  -- DAC data for I out
    pi_dac_data_q   : in  std_logic_vector(15 downto 0);  -- DAC data for Q out

    -- differential clock out for DAC
    po_dac_clk_p   : out std_logic;
    po_dac_clk_n   : out std_logic;

    -- differential out for DAC out select
    po_dac_seliq_p : out std_logic;
    po_dac_seliq_n : out std_logic;

    -- differential DAC data out
    po_dac_data_p  : out std_logic_vector(15 downto 0);
    po_dac_data_n  : out std_logic_vector(15 downto 0);

    pi_idelay_clk : in std_logic;
    pi_idelay_inc : in std_logic;
    pi_idelay_str : in std_logic; -- a pulse wide 2 or more pi_dac_2x_clk is required
    po_idelay_cnt : out std_logic_vector(8 downto 0)
  );
end max5878;

-------------------------------------------------------------------------------
-- @brief Architecture of DAC module
-- @details implements all IO buffers layer, generate sleect signal
-- sned data in DDR mode uing ODDR primitive

architecture arch of max5878 is
  attribute IODELAY_GROUP                        : string;
  attribute IODELAY_GROUP of I_IDELAYCTRL        : label is "IDLYCTRL_8300KU_DAC";
  attribute IODELAY_GROUP of I_ODELAYE3_SEL      : label is "IDLYCTRL_8300KU_DAC";
  attribute IODELAY_GROUP of I_ODELAYE3_CLK      : label is "IDLYCTRL_8300KU_DAC";

  attribute ASYNC_REG : string;

  -- IDELAY reset
  signal reset_200_q, reset_200_qq : std_logic;
  attribute ASYNC_REG of reset_200_q : signal is "TRUE";
  attribute ASYNC_REG of reset_200_qq : signal is "TRUE";

  -- edge detection on pi_idelay_str, asserts idelay_ce for 1 clk cycle
  signal idelay_ce : std_logic;
  signal idelay_str_q, idelay_str_qq, idelay_str_qqq : std_logic;
  attribute ASYNC_REG of idelay_str_q : signal is "TRUE";
  attribute ASYNC_REG of idelay_str_qq : signal is "TRUE";
  attribute ASYNC_REG of idelay_str_qqq : signal is "TRUE";

  -- sync for INC (it is assumed that INC is set several clk cycles before strobe)
  signal idelay_inc_q, idelay_inc_qq : std_logic;
  attribute ASYNC_REG of idelay_inc_q : signal is "TRUE";
  attribute ASYNC_REG of idelay_inc_qq : signal is "TRUE";

  -- DATA
  signal data_i : std_logic_vector(15 downto 0);
  signal data_q : std_logic_vector(15 downto 0);

  signal dac_data_pre_dly : std_logic_vector(15 downto 0);
  signal dac_sel_pro_dly : std_logic;

  signal dac_data_after_dly : std_logic_vector(15 downto 0);
  signal dac_sel_after_dly : std_logic;

  -- clock (output)
  signal dac_clk2x_after_dly : std_logic;
  signal dac_clk2x_after_oddr: std_logic;

  -- clock out sync (to pi_idelay_clk domain)
  signal idelay_cnt : std_logic_vector(8 downto 0);
  signal idelay_cnt_q, idelay_cnt_qq : std_logic_vector(8 downto 0);
  attribute ASYNC_REG of idelay_cnt_q : signal is "TRUE";
  attribute ASYNC_REG of idelay_cnt_qq : signal is "TRUE";

  -- DAC channel selector
  signal sel : std_logic;
  signal dac_data_selected : std_logic_vector(15 downto 0);

begin

  --================================================================================================
  -- shared infrastructure
  reset_200_q  <= pi_reset when rising_edge(pi_200_clk);
  reset_200_qq <= reset_200_q when rising_edge(pi_200_clk);

  i_idelayctrl : idelayctrl
  generic map (
    SIM_DEVICE => "ULTRASCALE"
  )
   port map (
    rdy    => open,
    refclk => pi_200_clk,
    rst    => reset_200_qq
  );

  -- IDELAY strobe synchronization into DAC_CLK domain
  idelay_str_q <= pi_idelay_str when rising_edge(pi_dac_2x_clk);
  idelay_str_qq <= idelay_str_q when rising_edge(pi_dac_2x_clk);
  idelay_str_qqq <= idelay_str_qq when rising_edge(pi_dac_2x_clk);
  idelay_ce <= '1' when (idelay_str_qq = '0' and idelay_str_qqq = '1') else '0';

  -- IDELAY inc synchronization into DAC_CLK domain
  idelay_inc_q <= pi_idelay_inc when rising_edge(pi_dac_2x_clk);
  idelay_inc_qq <= idelay_inc_q when rising_edge(pi_dac_2x_clk);

  --================================================================================================
  -- input registers
  PROC_IN_REGS : process(pi_dac_2x_clk)
  begin
    if rising_edge(pi_dac_2x_clk) then
      if pi_dac_data_rdy = '1' then
        data_i <= pi_dac_data_i;
        data_q <= pi_dac_data_q;
      end if;
    end if;
  end process;

  --================================================================================================
  -- output mux
  proc_sel: process (pi_dac_2x_clk)
  begin
    if rising_edge(pi_dac_2x_clk) then
      sel <= not sel;
    end if;
  end process;

  dac_data_selected <= data_i when sel = '0' else data_q;

  --================================================================================================
  -- output mux
  gen_dac_oddr : for i in data_i'range generate
    attribute IODELAY_GROUP of i_oddre1_data : label is "IDLYCTRL_8300KU_DAC";
  begin
    i_oddre1_data : oddre1
    generic map (
      IS_C_INVERTED => '0',
      IS_D1_INVERTED => '0',
      IS_D2_INVERTED => '0',
      SRVAL => '0'
    )
    port map (
      q => dac_data_pre_dly(i),
      c => pi_dac_2x_clk,
      d1 => dac_data_selected(i),
      d2 => dac_data_selected(i),
      sr => '0'
    );
  end generate;

  i_oddre1_sel : oddre1
  generic map (
    IS_C_INVERTED => '0',
    IS_D1_INVERTED => '0',
    IS_D2_INVERTED => '0',
    SRVAL => '0'
  )
  port map (
    q => dac_sel_pro_dly,
    c => pi_dac_2x_clk,
    d1 => sel,
    d2 => sel,
    sr => '0'
  );

  i_oddre1_clk : oddre1
  generic map (
    IS_C_INVERTED => '1',
    IS_D1_INVERTED => '0',
    IS_D2_INVERTED => '0',
    SRVAL => '0'
  )
  port map (
    q => dac_clk2x_after_oddr,
    c => pi_dac_2x_clk,
    d1 => '1',
    d2 => '0',
    sr => '0'
  );
  --================================================================================================
  -- output delay
  gen_dac_odelay : for i in data_i'range generate
    attribute IODELAY_GROUP of I_ODELAYE3_DATA : label is "IDLYCTRL_8300KU_DAC";
  begin
    i_odelaye3_data : odelaye3
    generic map (
      CASCADE => "NONE",
      DELAY_FORMAT => "COUNT",
      DELAY_TYPE => "VARIABLE",
      DELAY_VALUE => G_ODELAY_DATA_DELAY(I),
      IS_CLK_INVERTED => '0',
      IS_RST_INVERTED => '0',
      REFCLK_FREQUENCY => 200.0,
      SIM_DEVICE => "ULTRASCALE",
      UPDATE_MODE => "ASYNC"
    )
    port map (
      casc_out => open,
      cntvalueout => open, -- only 1 counter status is provided for the entire "bank"
      dataout => dac_data_after_dly(i),
      casc_in => '0',
      casc_return => '0',
      ce => idelay_ce,
      clk => pi_dac_2x_clk,
      cntvaluein => (others => '0'),
      en_vtc => '0',
      inc => idelay_inc_qq,
      load => '0',
      odatain => dac_data_pre_dly(i),
      rst => '0'
    );
  end generate;

  i_odelaye3_sel : odelaye3
  generic map (
    CASCADE => "NONE",
    DELAY_FORMAT => "COUNT",
    DELAY_TYPE => "VARIABLE",
    DELAY_VALUE => G_ODELAY_SEL_DELAY,
    IS_CLK_INVERTED => '0',
    IS_RST_INVERTED => '0',
    REFCLK_FREQUENCY => 200.0,
    SIM_DEVICE => "ULTRASCALE",
    UPDATE_MODE => "ASYNC"
  )
  port map (
    casc_out => open,
    cntvalueout => idelay_cnt,
    dataout => dac_sel_after_dly,
    casc_in => '0',
    casc_return => '0',
    ce => idelay_ce,
    clk => pi_dac_2x_clk,
    cntvaluein => (others => '0'),
    en_vtc => '0',
    inc => idelay_inc_qq,
    load => '0',
    odatain => dac_sel_pro_dly,
    rst => '0'
  );

  i_odelaye3_clk : odelaye3
  generic map (
    CASCADE => "NONE",
    DELAY_FORMAT => "COUNT",
    DELAY_TYPE => "FIXED",
    DELAY_VALUE => G_ODELAY_CLK_DELAY,
    IS_CLK_INVERTED => '0',
    IS_RST_INVERTED => '0',
    REFCLK_FREQUENCY => 200.0,
    SIM_DEVICE => "ULTRASCALE",
    UPDATE_MODE => "ASYNC"
  )
  port map (
    casc_out => open,
    cntvalueout => open,
    dataout => dac_clk2x_after_dly,
    casc_in => '0',
    casc_return => '0',
    ce => '0',
    clk => '0',
    cntvaluein => (others => '0'),
    en_vtc => '0',
    inc => '0',
    load => '0',
    odatain => dac_clk2x_after_oddr,
    rst => '0'
  );

  --================================================================================================
  -- IDELAY counter syncrhonization (to AXI domain)
  idelay_cnt_q <= idelay_cnt when rising_edge(pi_idelay_clk);
  idelay_cnt_qq <= idelay_cnt_q when rising_edge(pi_idelay_clk);
  po_idelay_cnt <= idelay_cnt_qq;

  --================================================================================================
  -- output buffers
  GEN_DAC_BUF : for I in data_i'range generate
    ins_dac_buf : obufds_lvds_25 port map (i => dac_data_after_dly(i), o => po_dac_data_p(i), ob => po_dac_data_n(i));
  end generate;

  ins_sel_obuf : obufds_lvds_25 port map(i => dac_sel_after_dly, o => po_dac_seliq_p, ob => po_dac_seliq_n);
  ins_clk_obuf : obufds_lvds_25 port map(i => dac_clk2x_after_dly, o => po_dac_clk_p, ob => po_dac_clk_n);

end arch;
