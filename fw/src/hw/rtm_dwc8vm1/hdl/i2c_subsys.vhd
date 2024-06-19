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
-- @author Lukasz Butkowski <lukasz.butkowski@desy.de>
-- @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
-- @brief
-- I2C Sub System for DWC8VM1 RTM Module
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

entity i2c_subsys is
generic (
  G_I2C_CLK_DIV : integer := 800; -- ! clock divider for i2c
  G_NEGATED_CS  : std_logic_vector(15 downto 0) := x"0008");
port (
  pi_reset : in std_logic;
  pi_clock : in std_logic;

  po_slow_clk : out std_logic;
  po_cs_data  : out  std_logic_vector (71 downto 0);

  ---------------------------------------------------------------------------
  -- attenuators
  ---------------------------------------------------------------------------
  -- attenuator params
  pi_att_val    : in  std_logic_vector(5 downto 0) := (others => '0'); -- value for selected att.
  pi_att_sel    : in  std_logic_vector(8 downto 0) := (others => '0'); -- bit select of att. channel(s)
  pi_att_start  : in  std_logic                    := '0'; -- start attenuator transaction
  -- att done status register
  -- 0 when transaction executed, and ready for new strobe
  po_att_status : out std_logic;

  ---------------------------------------------------------------------------
  -- dac ad5624
  ---------------------------------------------------------------------------
  -- data to be write to dac should be put on dacx port
  -- '1' on dacx_str for one pi_clock cycle to request write
  -- write is scheduled only when dacx_str=1 and dac_status(x)=0
  pi_daca_data    : in  std_logic_vector(11 downto 0) := (others => '0');  -- dac a
  pi_daca_str     : in  std_logic                     := '0';              -- dac a strobe
  pi_dacb_data    : in  std_logic_vector(11 downto 0) := (others => '0');  -- dac b
  pi_dacb_str     : in  std_logic                     := '0';              -- dac b strobe
  pi_dacab_data   : in  std_logic_vector(11 downto 0) := (others => '0');  -- dac all outputs
  pi_dacab_str    : in  std_logic                     := '0';              -- dac all strobe
  pi_dac_raw_data : in  std_logic_vector(23 downto 0) := (others => '0');  -- dac raw data interface
  pi_dac_raw_str  : in  std_logic                     := '0';              -- dac raw strobe
  po_dac_strobed  : out std_logic                     := '0';              -- notification of the first strobe
  -- dac done status register
  -- dac_status[0]=0 when dac a write finished
  -- dac_status[1]=0 when dac b write finished
  -- dac_status[2]=0 when dac a and b finished
  -- dac_status[3]=0 when dac raw request finished
  po_dac_status   : out std_logic_vector(3 downto 0);

  ---------------------------------------------------------------------------
  -- adc ltc2493
  ---------------------------------------------------------------------------
  -- readed data avaiable on adc_x_data port
  -- '1' on adc_x_str for one pi_clock cycle to request readout od channel x
  po_adc_a_data : out std_logic_vector(24 downto 0) := (others => '0');  -- adc a data
  pi_adc_a_str  : in  std_logic                     := '0';              -- adc a strobe
  po_adc_b_data : out std_logic_vector(24 downto 0) := (others => '0');  -- adc b
  pi_adc_b_str  : in  std_logic                     := '0';              -- adc b strobe
  po_adc_c_data : out std_logic_vector(24 downto 0) := (others => '0');  -- adc c
  pi_adc_c_str  : in  std_logic                     := '0';              -- adc c strobe
  po_adc_d_data : out std_logic_vector(24 downto 0) := (others => '0');  -- adc d
  pi_adc_d_str  : in  std_logic                     := '0';              -- adc d strobe
  -- conv done status register
  -- 0 when channel convertion is done and x_data register have value
  -- adc_status[0]=1 when adc a read in progress
  -- adc_status[1]=1 when adc b read in progress
  -- adc_status[2]=1 when adc c read in progress
  -- adc_status[3]=1 when adc d read in progress
  po_adc_status : out std_logic_vector(3 downto 0);
  -- adc configuration register
  -- 3:  im    (1 - measure temperature)
  -- 21: fa fb (00 - both 50/60hz rejection; 01 - 50hz; 10 - 60hz)
  -- 0:  spd   (1 - disable auto calibration, 2xsps)
  -- 0000: external input, 50/60 rejection with auto calibration
  pi_adc_conf   : in  std_logic_vector(3 downto 0)  := "0000";
  ---------------------------------------------------------------------------
  -- user bus additional humidity sensors
  ---------------------------------------------------------------------------
  pi_hyt271_trg  : in  std_logic := '0' ; -- trigger conversion
  po_hyt271_humi : out std_logic_vector(13 downto 0);  -- humidity value out
  po_hyt271_temp : out std_logic_vector(13 downto 0);  -- temperature value out
  po_hyt271_done : out std_logic;
  ---------------------------------------------------------------------------
  -- i2c interface
  ---------------------------------------------------------------------------
  pi_sdi : in  std_logic; -- data input
  po_sdo : out std_logic; -- data output
  po_sdt : out std_logic; -- data direction
  pi_sci : in  std_logic; -- clock input
  po_sco : out std_logic; -- clock output
  po_sct : out std_logic  -- clock direction
);
end entity i2c_subsys;

architecture beh of i2c_subsys is

  constant C_PORTS_NUM    : natural := 4;

  signal sig_i2c_req        : std_logic_vector(C_PORTS_NUM-1 downto 0);
  signal sig_i2c_grant      : std_logic_vector(C_PORTS_NUM-1 downto 0);
  signal sig_i2c_str        : std_logic_vector(C_PORTS_NUM-1 downto 0);
  signal sig_i2c_wr         : std_logic_vector(C_PORTS_NUM-1 downto 0);
  signal sig_i2c_data_width : t_2b_slv_vector(C_PORTS_NUM-1 downto 0);
  signal sig_i2c_wdata      : t_32b_slv_vector(C_PORTS_NUM-1 downto 0);
  signal sig_i2c_addr       : t_8b_slv_vector(C_PORTS_NUM-1 downto 0);
  signal sig_i2c_rdata      : std_logic_vector(31 downto 0);
  signal sig_i2c_rdata_dry  : std_logic_vector(C_PORTS_NUM-1 downto 0);
  signal sig_i2c_done       : std_logic_vector(C_PORTS_NUM-1 downto 0);

  signal sig_i2c_sdi : std_logic;
  signal sig_i2c_sdo : std_logic;
  signal sig_i2c_sdt : std_logic;
  signal sig_i2c_sci : std_logic;
  signal sig_i2c_sco : std_logic;
  signal sig_i2c_sct : std_logic;

begin

  sig_i2c_sdi <= pi_sdi;
  po_sdo      <= sig_i2c_sdo;
  po_sdt      <= sig_i2c_sdt;
  sig_i2c_sci <= pi_sci;
  po_sco      <= sig_i2c_sco;
  po_sct      <= sig_i2c_sct;

  -- DAC
  ins_i2c_ad5624 : entity desy.ad5624_over_pca9535
  port map (
    pi_clock        => pi_clock,
    pi_reset        => pi_reset,
    po_req          => sig_i2c_req(0),
    pi_grant        => sig_i2c_grant(0),

    pi_done         => sig_i2c_done(0),
    po_str          => sig_i2c_str(0),
    po_wr           => sig_i2c_wr(0),
    po_data         => sig_i2c_wdata(0),
    po_data_width   => sig_i2c_data_width(0),
    po_addr         => sig_i2c_addr(0)(6 downto 0),

    pi_daca_data    => pi_daca_data,
    pi_daca_str     => pi_daca_str,
    pi_dacb_data    => pi_dacb_data,
    pi_dacb_str     => pi_dacb_str,
    pi_dacab_data   => pi_dacab_data,
    pi_dacab_str    => pi_dacab_str,
    pi_dac_raw_data => pi_dac_raw_data,
    pi_dac_raw_str  => pi_dac_raw_str,
    po_dac_strobed  => po_dac_strobed,
    po_dac_status   => po_dac_status,
    pi_sci_sdi_fix  => '0'
  );

  -- Attenuators
  ins_i2c_att : entity desy.hmc624_over_pca9535
  generic map(
    G_PCA9535_I2C_ADDR => x"20",
    G_MAX_CHANNELS => 9, -- 9 CHANNELS HAS ATTENUATOR
    G_DEFAULT_VALUES => x"0800" -- HANDLE VCM_DAC_CS_N (NEGATED!)
  )
  port map(
    pi_clock => pi_clock,
    pi_reset => pi_reset,

    -- arbiter interface
    po_req   => sig_i2c_req(1),
    pi_grant => sig_i2c_grant(1),

    -- i2c_controler interface
    po_i2c_str        => sig_i2c_str(1),
    po_i2c_write_ena  => sig_i2c_wr(1),
    po_i2c_data_width => sig_i2c_data_width(1),
    po_i2c_data       => sig_i2c_wdata(1),
    po_i2c_addr       => sig_i2c_addr(1),
    pi_i2c_done       => sig_i2c_done(1),

    -- attenuator params
    pi_att_val    => pi_att_val,
    pi_att_sel    => pi_att_sel,
    pi_att_start  => pi_att_start,
    po_att_status => po_att_status
  );

  -- adc
  ins_i2c_ltc2493 : entity desy.ltc2493
  generic map (
    G_ADDR => "0110100")
  port map (
    pi_clock      => pi_clock,
    pi_reset      => pi_reset,
    po_req        => sig_i2c_req(2),
    pi_grant      => sig_i2c_grant(2),

    pi_data       => sig_i2c_rdata,
    pi_done       => sig_i2c_done(2),
    po_str        => sig_i2c_str(2),
    po_wr         => sig_i2c_wr(2),
    po_data       => sig_i2c_wdata(2),
    po_data_width => sig_i2c_data_width(2),
    po_addr       => sig_i2c_addr(2)(6 downto 0),

    po_a_data     => po_adc_a_data,
    pi_a_str      => pi_adc_a_str,
    po_b_data     => po_adc_b_data,
    pi_b_str      => pi_adc_b_str,
    po_c_data     => po_adc_c_data,
    pi_c_str      => pi_adc_c_str,
    po_d_data     => po_adc_d_data,
    pi_d_str      => pi_adc_d_str,
    po_adc_status => po_adc_status,
    pi_adc_conf   => pi_adc_conf
  );

  ins_hyt271_1: entity desy.hyt271
  generic map (
    G_ADDR => "0101000" -- 0x28
  )
  port map (
    pi_clock      => pi_clock,
    pi_reset      => pi_reset,
    -- gpo interface
    pi_trg        => pi_hyt271_trg,
    po_humi       => po_hyt271_humi,
    po_temp       => po_hyt271_temp,
    po_done       => po_hyt271_done,
    -- arbiter interface
    po_req        => sig_i2c_req(3),
    pi_grant      => sig_i2c_grant(3),
    -- i2c_controler interface
    pi_data       => sig_i2c_rdata,
    pi_done       => sig_i2c_done(3),
    po_str        => sig_i2c_str(3),
    po_wr         => sig_i2c_wr(3),
    po_data       => sig_i2c_wdata(3),
    po_data_width => sig_i2c_data_width(3),
    po_addr       => sig_i2c_addr(3)(6 downto 0),
    pi_data_dry   => sig_i2c_rdata_dry(3)
  );

  ins_i2c_cntrl_arb: entity desy.i2c_control_arbiter
  generic map (
    G_PORTS_NUM   => C_PORTS_NUM,
    G_I2C_CLK_DIV => G_I2C_CLK_DIV
    )
  port map (
    pi_clock      => pi_clock,
    pi_reset      => pi_reset,
    
    pi_i2c_req    => sig_i2c_req,
    po_i2c_grant  => sig_i2c_grant,
    
    pi_rep        => (others=>'0'), -- 0 -> Don't send STOP bit 1->Send STOP bit (repeated start)
    pi_str        => sig_i2c_str,
    pi_wr         => sig_i2c_wr,
    pi_data_width => sig_i2c_data_width,
    pi_data       => sig_i2c_wdata,
    pi_addr       => sig_i2c_addr,
    po_data       => sig_i2c_rdata,
    po_dry        => sig_i2c_rdata_dry,
    po_done       => sig_i2c_done,

    pi_sdi        => sig_i2c_sdi,
    po_sdo        => sig_i2c_sdo,
    po_sdt        => sig_i2c_sdt,
    pi_sci        => sig_i2c_sci,
    po_sco        => sig_i2c_sco,
    po_sct        => sig_i2c_sct
  );

end architecture beh;
