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
-- @date 2018-10-25
-- @author Radoslaw Rybaniec
-- @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
-- @brief
-- I2C Subsystem for DS8VM1
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

entity i2c_subsys is
generic (
  G_CLK_FREQ    : integer := 78_000_000;
  G_I2C_CLK_FREQ: integer := 100_000; -- Clock Frequency for the i2c bus
  G_NEGATED_CS  : std_logic_vector(15 downto 0) := x"0008"
);
port (
  pi_clock : in std_logic;
  pi_reset : in std_logic;

  -- Attenuators
  pi_att_val    : in  std_logic_vector(5 downto 0) := (others => '0');  -- value for selected att.
  pi_att_sel    : in  std_logic_vector(8 downto 0) := (others => '0');  -- bit select of att. channel(s)
  pi_att_start  : in  std_logic                    := '0';  -- 1 for one pi_clock cycle to execute transfer to att.
  po_att_busy   : out std_logic; -- Att done status register 0 when transaction executed, and ready for new strobe

  ---------------------------------------------------------------------------
  -- DAC AD5624
  ---------------------------------------------------------------------------
  -- write is scheduled only when dacx_str=1 and dac_status(x)=0
  pi_daca_data     : in  std_logic_vector(15 downto 0) := (others => '0');  -- dac a
  pi_daca_str      : in  std_logic                     := '0';              -- dac a strobe
  pi_dacb_data     : in  std_logic_vector(15 downto 0) := (others => '0');  -- dac b
  pi_dacb_str      : in  std_logic                     := '0';              -- dac b strobe
  po_dac_busy      : out std_logic_vector(1 downto 0);                         -- dac a dac b busy flag

  ---------------------------------------------------------------------------
  -- ADC ltc2493
  ---------------------------------------------------------------------------
  -- readed data avaiable on adc_x_data port
  -- '1' on adc_x_str for one pi_clock cycle to request readout od channel x
  po_adc_a_data : out std_logic_vector(24 downto 0) := (others => '0');  -- adc a data
  pi_adc_a_str  : in  std_logic                     := '0';              -- adc a strobe
  po_adc_b_data : out std_logic_vector(24 downto 0) := (others => '0');  -- adc b
  pi_adc_b_str  : in  std_logic                     := '0';              -- adc b strobe
  -- conv done status register
  -- 0 when channel convertion is done and x_data register have value
  -- adc_status[0]=1 when adc a read in progress
  -- adc_status[1]=1 when adc b read in progress
  -- adc_status[2]=1 when adc c read in progress (not in use)
  -- adc_status[3]=1 when adc d read in progress (not in use)
  po_adc_busy : out std_logic_vector(3 downto 0);
  -- adc configuration register
  -- 3:  im    (1 - measure temperature)
  -- 21: fa fb (00 - both 50/60hz rejection; 01 - 50hz; 10 - 60hz)
  -- 0:  spd   (1 - disable auto calibration, 2xsps)
  -- 0000: external input, 50/60 rejection with auto calibration
  pi_adc_conf   : in  std_logic_vector(3 downto 0)  := "0000";

  ---------------------------------------------------------------------------
  -- on-board temperature sensors (LTC2493)
  ---------------------------------------------------------------------------
  po_temp_a_data : out std_logic_vector(24 downto 0) := (others => '0');  -- i2c address: 2ch (differential)
  pi_temp_a_str  : in  std_logic                     := '0';              -- temp a strobe
  po_temp_b_data : out std_logic_vector(24 downto 0) := (others => '0');  -- i2c address: 2ch (differential)
  pi_temp_b_str  : in  std_logic                     := '0';              -- temp b strobe
  -- 0000: external input, 50/60 rejection with auto calibration
  pi_temp_conf   : in  std_logic_vector(3 downto 0)  := "0000"; -- ltc2493 configuration

  ---------------------------------------------------------------------------
  -- temperature sensor max6626
  ---------------------------------------------------------------------------
  po_temp_c_data : out std_logic_vector(11 downto 0) := (others => '0');  -- i2c address: 48h
  pi_temp_c_str  : in  std_logic                     := '0';              -- temp c strobe
  po_temp_d_data : out std_logic_vector(11 downto 0) := (others => '0');  -- i2c address: 49h
  pi_temp_d_str  : in  std_logic                     := '0';              -- temp d strobe
  po_temp_e_data : out std_logic_vector(11 downto 0) := (others => '0');  -- i2c address: 4ah
  pi_temp_e_str  : in  std_logic                     := '0';              -- temp e strobe
  po_temp_f_data : out std_logic_vector(11 downto 0) := (others => '0');  -- i2c address: 4bh
  pi_temp_f_str  : in  std_logic                     := '0';              -- temp f strobe

  ---------------------------------------------------------------------------
  -- PLL lmk04906
  ---------------------------------------------------------------------------
  -- data to be written to pll should be put on pll_data port
  -- '1' on pll_str for one pi_clock cycle to request write
  pi_pll_data   : in  std_logic_vector(31 downto 0) := (others => '0');  -- pll data
  pi_pll_str    : in  std_logic                     := '0';              -- pll strobe
  po_pll_busy   : out std_logic;                                         -- pll busy flag

  ---------------------------------------------------------------------------
  -- IO expander
  ---------------------------------------------------------------------------
  pi_expander_0_out_str  : in std_logic;
  pi_expander_0_out_data : in std_logic_vector(7 downto 0);
  pi_expander_1_in_str   : in std_logic;
  po_expander_1_in_data  : out std_logic_vector(7 downto 0);
  po_expander_1_in_done  : out std_logic;

  ---------------------------------------------------------------------------
  -- I2C interface
  ---------------------------------------------------------------------------
  pi_sdi : in  std_logic; -- data input
  po_sdo : out std_logic; -- data output
  po_sdt : out std_logic; -- data direction
  pi_sci : in  std_logic; -- clock input
  po_sco : out std_logic; -- clock output
  po_sct : out std_logic  -- clock direction
);
end entity i2c_subsys;

architecture rtl of i2c_subsys is

  -- Number of I2C Devices on the bus
  constant C_I2C_DEV_CNT : natural := 11;

  signal i2c_req        : std_logic_vector(C_I2C_DEV_CNT-1 downto 0);
  signal i2c_grant      : std_logic_vector(C_I2C_DEV_CNT-1 downto 0);
  signal i2c_str        : std_logic_vector(C_I2C_DEV_CNT-1 downto 0);
  signal i2c_wr         : std_logic_vector(C_I2C_DEV_CNT-1 downto 0);
  signal i2c_data_width : t_2b_slv_vector(C_I2C_DEV_CNT-1 downto 0);
  signal i2c_wdata      : t_32b_slv_vector(C_I2C_DEV_CNT-1 downto 0);
  signal i2c_addr       : t_8b_slv_vector(C_I2C_DEV_CNT-1 downto 0);
  signal i2c_rdata      : std_logic_vector(31 downto 0);
  signal i2c_rdata_rdy  : std_logic_vector(C_I2C_DEV_CNT-1 downto 0);
  signal i2c_done       : std_logic_vector(C_I2C_DEV_CNT-1 downto 0);

  signal i2c_sdi        : std_logic;
  signal i2c_sdo        : std_logic;
  signal i2c_sdt        : std_logic;
  signal i2c_sci        : std_logic;
  signal i2c_sco        : std_logic;
  signal i2c_sct        : std_logic;

  signal temp_c_data    : std_logic_vector(15 downto 0);
  signal temp_d_data    : std_logic_vector(15 downto 0);
  signal temp_e_data    : std_logic_vector(15 downto 0);
  signal temp_f_data    : std_logic_vector(15 downto 0);
  
  signal dac_busy       : std_logic_vector(3 downto 0);

begin

  i2c_sdi <= pi_sdi;
  po_sdo <= i2c_sdo;
  po_sdt <= i2c_sdt;
  i2c_sci <= pi_sci;
  po_sco <= i2c_sco;
  po_sct <= i2c_sct;
  
  po_dac_busy <= dac_busy(1 downto 0);

  -- DAC
  ins_ltc2607 : entity desy.ltc2607
  port map ( 
    pi_clock        => pi_clock,
    pi_reset        => pi_reset,

    po_req          => i2c_req(0),
    pi_grant        => i2c_grant(0),

    pi_data         => i2c_rdata,
    pi_done         => i2c_done(0),
    po_str          => i2c_str(0),
    po_wr           => i2c_wr(0),
    po_data         => i2c_wdata(0),
    po_data_width   => i2c_data_width(0),

    pi_daca_data    => pi_daca_data,
    pi_daca_str     => pi_daca_str,
    pi_dacb_data    => pi_dacb_data,
    pi_dacb_str     => pi_dacb_str,
    pi_dacab_data   => (others=>'0'),
    pi_dacab_str    => '0',
    pi_dac_raw_str  => '0',
    po_dac_strobed  => open,
    po_dac_busy     => dac_busy
  );
  i2c_addr(0) <= x"10";


  -- Attenuators
  ins_att : entity desy.hmc624_over_pca9535
  generic map(
    G_PCA9535_I2C_ADDR => x"20",
    G_MAX_CHANNELS => 9, -- 9 channels has attenuator (last channel is vm output)
    G_DEFAULT_VALUES => x"0000"
  )
  port map(
    pi_clock => pi_clock,
    pi_reset => pi_reset,

    -- arbiter interface
    po_req   => i2c_req(1),
    pi_grant => i2c_grant(1),

    -- i2c_controler interface
    po_i2c_str        => i2c_str(1),
    po_i2c_write_ena  => i2c_wr(1),
    po_i2c_data_width => i2c_data_width(1),
    po_i2c_data       => i2c_wdata(1),
    po_i2c_addr       => i2c_addr(1),
    pi_i2c_done       => i2c_done(1),

    -- attenuator params
    pi_att_val    => pi_att_val,
    pi_att_sel    => pi_att_sel,
    pi_att_start  => pi_att_start,
    po_att_status => po_att_busy
  );


  -- PLL
  ins_pll : entity desy.lmk04906_over_pca9535
  port map (
    pi_clock      => pi_clock,
    pi_reset      => pi_reset,
    po_req        => i2c_req(3),
    pi_grant      => i2c_grant(3),

    pi_data       => i2c_rdata,
    pi_done       => i2c_done(3),
    po_str        => i2c_str(3),
    po_wr         => i2c_wr(3),
    po_data       => i2c_wdata(3),
    po_data_width => i2c_data_width(3),
    po_addr       => i2c_addr(3)(6 downto 0),

    pi_pll_data    => pi_pll_data,
    pi_pll_str     => pi_pll_str,
    po_pll_busy    => po_pll_busy,
    pi_sci_sdi_fix => '0'
  );


  ins_expander_port_0 : entity desy.pca9535
  generic map(
    G_PORT_NB => 0)
  port map(
    pi_clock       => pi_clock,
    pi_reset       => pi_reset,
    -- GPIO interface
    pi_str         => pi_expander_0_out_str,
    pi_gpo         => pi_expander_0_out_data,
    po_gpo         => open,
    pi_gpo_dir     => (others => '0'),
    -- Arbiter interface
    po_req         => i2c_req(4),
    pi_grant       => i2c_grant(4),
    -- i2c_controler interface
    pi_data       => i2c_rdata,
    pi_dry        => i2c_rdata_rdy(4),
    pi_done       => i2c_done(4),
    po_str        => i2c_str(4),
    po_wr         => i2c_wr(4),
    po_data       => i2c_wdata(4),
    po_data_width => i2c_data_width(4)
  );
  i2c_addr(4) <= x"21" ;


  ins_expander_port_1 : entity desy.pca9535
  generic map(
    G_PORT_NB => 1)
  port map(
    pi_clock      => pi_clock,
    pi_reset      => pi_reset,
    -- gpio interface
    pi_str        => pi_expander_1_in_str,
    pi_gpo        => x"00",
    po_gpo        => po_expander_1_in_data ,
    pi_gpo_dir    => (others => '1') , -- 1 -> input 0-> output
    po_gpo_done   => po_expander_1_in_done ,
    -- arbiter interface
    po_req        => i2c_req(5),
    pi_grant      => i2c_grant(5),
    -- i2c_controler interface
    pi_data       => i2c_rdata,
    pi_dry        => i2c_rdata_rdy(5),
    pi_done       => i2c_done(5),
    po_str        => i2c_str(5),
    po_wr         => i2c_wr(5),
    po_data       => i2c_wdata(5),
    po_data_width => i2c_data_width(5)
  );
  i2c_addr(5) <= x"21" ;


  -- ADC
  ins_ltc2493_adc : entity desy.ltc2493
  generic map (
    G_ADDR => "0110100", --  -- i2c address 34h
    G_CLK_FREQ => G_CLK_FREQ
  )
  port map (
    pi_clock      => pi_clock,
    pi_reset      => pi_reset,
    po_req        => i2c_req(2),
    pi_grant      => i2c_grant(2),

    pi_data       => i2c_rdata,
    pi_done       => i2c_done(2),
    po_str        => i2c_str(2),
    po_wr         => i2c_wr(2),
    po_data       => i2c_wdata(2),
    po_data_width => i2c_data_width(2),
    po_addr       => i2c_addr(2)(6 downto 0),

    po_a_data     => po_adc_a_data, -- Reference Power Measurement
    pi_a_str      => pi_adc_a_str, 
    po_b_data     => po_adc_b_data, -- AD8363 on DS8VM1 (not managed by the FPGA) provides 
                                    -- temperature sensor output with an output voltage 
                                    -- scaling factor of approximately 5 mV/°C
    pi_b_str      => pi_adc_b_str,
    po_c_data     => open, -- line not used
    pi_c_str      => '0',  -- line not used
    po_d_data     => open, -- line not used
    pi_d_str      => '0',  -- line not used
    po_adc_status => po_adc_busy,
    pi_adc_conf   => pi_adc_conf
  );


  -- temperature sensor from thermistors
  -- uses differential mode of ltc2493
  ins_ltc2493_temp : entity desy.ltc2493
  generic map (
    G_ADDR => "0010110", -- i2c address 16h (ON SCHEMATICS ITS LABELED WRONG!)
    G_CLK_FREQ => G_CLK_FREQ,
    G_DISABLE_DIFF_MODE => '0'
  )
  port map (
    pi_clock      => pi_clock,
    pi_reset      => pi_reset,
    po_req        => i2c_req(6),
    pi_grant      => i2c_grant(6),

    pi_data       => i2c_rdata,
    pi_done       => i2c_done(6),
    po_str        => i2c_str(6),
    po_wr         => i2c_wr(6),
    po_data       => i2c_wdata(6),
    po_data_width => i2c_data_width(6),
    po_addr       => i2c_addr(6)(6 downto 0),

    po_a_data     => po_temp_a_data, -- (ch0-ch1)
    pi_a_str      => pi_temp_a_str,
    po_b_data     => open, -- (ch1-ch0) no need to use this line
    pi_b_str      => '0',
    po_c_data     => po_temp_b_data, -- (ch2-ch3)
    pi_c_str      => pi_temp_b_str,
    po_d_data     => open, -- (ch3-ch2) no need to use this line
    pi_d_str      => '0',
    po_adc_status => open,
    pi_adc_conf   => pi_temp_conf
  );


  -- temperature sensor -max6626-
  po_temp_c_data <= temp_c_data(15 downto 4); -- 4 lsb are zero
  ins_max6626_0: entity desy.max662x
  generic map(
  G_CLK_FREQ => G_CLK_FREQ
  )
  port map(
    pi_clock       => pi_clock,
    pi_reset       => pi_reset,
    pi_grant       => i2c_grant(7),
    po_req         => i2c_req(7),
    -- i2c ports
    pi_dry         => '0',
    pi_data        => i2c_rdata,
    pi_done        => i2c_done(7),
    po_str         => i2c_str(7),
    po_wr          => i2c_wr(7),
    po_data        => i2c_wdata(7),
    po_data_width  => i2c_data_width(7),

    -- pll register
    pi_temp_start  => pi_temp_c_str,
    po_temp_ready  => open,
    po_temp_data   => temp_c_data  
  );
  i2c_addr(7) <= x"48";


  -- temperature sensor -max6626-
  po_temp_d_data <= temp_d_data(15 downto 4); -- 4 LSB are zero
  ins_max6626_1: entity desy.max662x
  generic map(
  G_CLK_FREQ => G_CLK_FREQ)
  port map(
    pi_clock       => pi_clock,
    pi_reset       => pi_reset,
    pi_grant       => i2c_grant(8),
    po_req         => i2c_req(8),

    -- I2C ports
    pi_dry         => '0',
    pi_data        => i2c_rdata,
    pi_done        => i2c_done(8),
    po_str         => i2c_str(8),
    po_wr          => i2c_wr(8),
    po_data        => i2c_wdata(8),
    po_data_width  => i2c_data_width(8),

    -- PLL register
    pi_temp_start  => pi_temp_d_str,
    po_temp_ready  => open,
    po_temp_data   => temp_d_data  
  );
  i2c_addr(8) <= x"49" ;


  -- temperature sensor -max6626-
  po_temp_e_data <= temp_e_data(15 downto 4); -- 4 lsb are zero
  ins_max6626_2: entity desy.max662x
  generic map(
  G_CLK_FREQ => G_CLK_FREQ)
  port map(
    pi_clock         => pi_clock,
    pi_reset       => pi_reset,
    pi_grant       => i2c_grant(9),
    po_req         => i2c_req(9),

    -- I2C ports
    pi_dry         => '0',
    pi_data        => i2c_rdata,
    pi_done        => i2c_done(9),
    po_str         => i2c_str(9),
    po_wr          => i2c_wr(9),
    po_data        => i2c_wdata(9),
    po_data_width  => i2c_data_width(9),

    -- PLL register
    pi_temp_start  => pi_temp_e_str,
    po_temp_ready  => open,
    po_temp_data   => temp_e_data
  );
  i2c_addr(9) <= x"4a" ;


  -- temperature sensor -max6626-
  po_temp_f_data <= temp_f_data(15 downto 4); -- 4 lsb are zero
  ins_max6626_3: entity desy.max662x
  generic map(
  G_CLK_FREQ => G_CLK_FREQ)
  port map(
    pi_clock        => pi_clock,
    pi_reset        => pi_reset,
    pi_grant       => i2c_grant(10),
    po_req         => i2c_req(10),

    -- I2C ports
    pi_dry         => '0',
    pi_data        => i2c_rdata,
    pi_done        => i2c_done(10),
    po_str         => i2c_str(10),
    po_wr          => i2c_wr(10),
    po_data        => i2c_wdata(10),
    po_data_width  => i2c_data_width(10),

    -- PLL register
    pi_temp_start  => pi_temp_f_str,
    po_temp_ready  => open,
    po_temp_data   => temp_f_data
  );
  i2c_addr(10) <= x"4b";


  ins_i2c_cntr_arb: entity desy.i2c_control_arbiter
  generic map (
    G_PORTS_NUM   => C_I2C_DEV_CNT,
    G_I2C_CLK_DIV => G_CLK_FREQ / G_I2C_CLK_FREQ)
  port map (
    pi_clock      => pi_clock,
    pi_reset      => pi_reset,

    pi_i2c_req    => i2c_req,
    po_i2c_grant  => i2c_grant,

    pi_rep        => (others=>'0'),
    pi_str        => i2c_str,
    pi_wr         => i2c_wr,
    pi_data_width => i2c_data_width,
    pi_data       => i2c_wdata,
    pi_addr       => i2c_addr,
    po_data       => i2c_rdata,
    po_dry        => i2c_rdata_rdy,
    po_done       => i2c_done,

    pi_sdi        => i2c_sdi,
    po_sdo        => i2c_sdo,
    po_sdt        => i2c_sdt,
    pi_sci        => i2c_sci,
    po_sco        => i2c_sco,
    po_sct        => i2c_sct
  );

end architecture rtl;

