-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- Copyright (c) 2021 DESY
-------------------------------------------------------------------------------
--! @file    tb_hdc1000.vhd
--! @author  Katharina Schulz
--! @created 2021-10-15
-------------------------------------------------------------------------------
--! @description:
--!
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity tb_hdc1000 is
end entity tb_hdc1000;
-------------------------------------------------------------------------------
architecture sim of tb_hdc1000 is
  -- Generic constants for DUT
  constant C_I2C_CLK_FREQ   : natural   := 100_000;     -- I2c Clock Freq. in Hz
  constant C_APP_CLK_FREQ   : natural   := 81_250_000;  -- Main Clock Freq. in Hz
  -- component ports
  signal pi_clock           : std_logic := '1';
  signal pi_reset           : std_logic := '0';
  -- Arbiter interface
  signal po_req             : std_logic := '0';
  signal pi_grant           : std_logic := '0';
  -- GPIO interface  
  signal pi_trg             : std_logic := '0';
  signal po_data_valid      : std_logic := '0';
  signal po_temperature     : std_logic_vector(13 downto 0) := (others => '0');
  signal po_humidity        : std_logic_vector(13 downto 0) := (others => '0');
  signal po_busy            :  std_logic := '0';
  -- I2C_CONTROLER interface
  signal pi_i2c_done        : std_logic:= '0';
  signal pi_i2c_data        : std_logic_vector(31 downto 0) := (others => '0'); 
  signal po_i2c_str         : std_logic:= '0';
  signal po_i2c_write_ena   : std_logic:= '0';
  signal po_i2c_data_width  : std_logic_vector(1 downto 0)  := (others => '0');
  signal po_i2c_data        : std_logic_vector(31 downto 0) := (others => '0');
  signal po_i2c_addr        : std_logic_vector(7 downto 0)  := (others => '0');
  -- I2C Bus
  signal p_i_sdi : std_logic := '0'; --! data input
  signal p_o_sdo : std_logic := '0'; --! data output
  signal p_o_sdt : std_logic := '0'; --! data direction
  signal p_i_sci : std_logic := '0'; --! clock input
  signal p_o_sco : std_logic := '0'; --! clock output
  signal p_o_sct : std_logic := '0'; --! clock direction
  
  signal P_I_DATA       : std_logic_vector(31 downto 0):= (others => '0');
  signal P_O_DONE       : std_logic                     := '0';
  signal P_O_BUSY       : std_logic                     := '0';
  signal P_O_DATA       : std_logic_vector(31 downto 0) := (others => '0');
  signal P_O_DATA_DRY   : std_logic                     := '0';
-------------------------------------------------------------------------------
begin
  -- component instantiation
  DUT: entity work.hdc1000
    generic map (
    g_i2c_addr => x"43",
    g_clk_freq => C_APP_CLK_FREQ
    )
    port map (
    pi_clock    => pi_clock,
    pi_reset    => pi_reset,
    po_req      => po_req,
    pi_grant    => pi_grant,

    po_i2c_str         => po_i2c_str,
    po_i2c_write_ena   => po_i2c_write_ena,
    po_i2c_data_width  => po_i2c_data_width,
    po_i2c_data        => po_i2c_data,
    pi_i2c_data        => pi_i2c_data,
    po_i2c_addr        => po_i2c_addr,
    pi_i2c_done        => pi_i2c_done,

    pi_trg             => pi_trg,
    po_data_valid      => po_data_valid,
    po_humidity        => po_humidity,
    po_temperature     => po_temperature,
    po_busy            => po_busy
    );
  
  I2C_ctrl_arb : entity work.ent_i2c_cntrl_arb
    generic map(
      G_PORTS_NUM   => 1,
      G_I2C_CLK_DIV => C_APP_CLK_FREQ/C_I2C_CLK_FREQ -- Clock divider for I2C
    )
    port map(
      p_i_clk           => pi_clock,
      p_i_reset         => pi_reset,
      -- Arbiter
      p_i_i2c_req(0)    => po_req,
      p_o_i2c_grant(0)  => pi_grant,
      -- Controller Interface
      p_i_str(0)     => po_i2c_str,
      p_i_wr(0)      => po_i2c_write_ena,
      p_i_rep        => (others=>'0'), -- Repeat after transaction (Not needed) 
      p_i_data_width(0) => po_i2c_data_width,
      p_i_data(0)    => po_i2c_data,
      p_i_addr(0)    => po_i2c_addr,
      p_o_data       => pi_i2c_data,
      p_o_done(0)    => pi_i2c_done,
      p_o_busy(0)    => p_o_busy,
      p_o_dry(0)     => P_O_DATA_DRY,
      --! i2c interface
      p_i_sdi => p_i_sdi, 
      p_o_sdo => p_o_sdo, 
      p_o_sdt => p_o_sdt, 
      p_i_sci => p_i_sci, 
      p_o_sco => p_o_sco, 
      p_o_sct => p_o_sct 
    );
  
  -- clock generation
  pi_clock <= not pi_clock after 12.31 ns;

  -- waveform generation
  prs_wave: process
  begin
    pi_reset <= '1';

    wait for 100 ns;
    wait until pi_clock = '1';
    pi_reset <= '0';
    pi_trg <= '0';

    wait for 100 ns;
    wait until rising_edge(pi_i2c_done);
    pi_trg <= '1';

    wait until rising_edge(pi_i2c_done);
    pi_trg <= '0';


    wait for 2 ms;
  end process prs_wave;
  
end architecture sim;