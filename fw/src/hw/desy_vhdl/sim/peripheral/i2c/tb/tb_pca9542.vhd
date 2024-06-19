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
--! @file    tb_pca9542.vhd
--! @brief   Testbench for the PCA9542
--! @author  Cagil Gumus
--! @created 13.10.2021
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common_types.all;

entity tb_pca9542 is
end tb_pca9542;

architecture Behavioral of tb_pca9542 is

  -- Generic constants for DUT
  constant C_I2C_CLK_FREQ  : natural := 100_000; -- I2c Clock Freq. in Hz
  constant C_APP_CLK_FREQ  : natural := 81_250_000; -- Main Clock Freq. in Hz
  constant CLOCK_PERIOD : time := 12.31ns; -- 1/C_APP_CLK_FREQ
  
  -- Inputs to DUT
  signal pi_clock : std_logic:='0';
  signal pi_reset : std_logic:='0';
  signal pi_enable_ports : std_logic:='0';
  signal pi_channel_sel : std_logic:='0';
  signal pi_send_or_read_conf : std_logic:='0';
  signal pi_start : std_logic:='0';  
  signal pi_i2c_done : std_logic_vector(0 downto 0);
  signal pi_grant : std_logic;

  -- Outputs from DUT
  signal po_req : std_logic;
  signal po_i2c_str : std_logic;
  signal po_i2c_write_ena : std_logic;
  signal po_i2c_data_width : t_2b_slv_array(0 downto 0);
  signal po_i2c_data : t_32b_slv_array(0 downto 0);
  signal pi_i2c_data : t_32b_slv_array(0 downto 0);
  signal po_i2c_addr : t_8b_slv_array(0 downto 0);
  signal po_configuration : std_logic_vector(7 downto 0);
  signal po_configuration_vld : std_logic;
  signal po_busy : std_logic;

  -- I2C Bus
  signal p_i_sdi : std_logic;
  signal p_o_sdo : std_logic;
  signal p_o_sdt : std_logic;
  signal p_i_sci : std_logic;
  signal p_o_sco : std_logic;
  signal p_o_sct : std_logic;

begin

  DUT : entity work.pca9542
  generic map(
    G_I2C_ADDR => x"20"
  )
  port map(
    pi_clock => pi_clock,
    pi_reset => pi_reset,

    -- Arbiter Interface
    po_req   => po_req,
    pi_grant => pi_grant,

    -- I2C_CONTROLER interface
    po_i2c_str        => po_i2c_str,
    po_i2c_write_ena  => po_i2c_write_ena,
    po_i2c_data_width => po_i2c_data_width(0),
    pi_i2c_data       => pi_i2c_data(0),
    po_i2c_data       => po_i2c_data(0),
    po_i2c_addr       => po_i2c_addr(0),
    pi_i2c_done       => pi_i2c_done(0),
    
    -- User Interface
    pi_channel_sel       => pi_channel_sel,
    pi_enable_ports      => pi_enable_ports,
    pi_send_or_read_conf => pi_send_or_read_conf,
    po_configuration     => po_configuration,
    po_configuration_vld => po_configuration_vld,
    pi_start             => pi_start,
    po_busy              => po_busy
  );
  
  I2C_ctrl : entity work.ent_i2c_cntrl_arb
  generic map(
    G_PORTS_NUM   => 1,
    G_I2C_CLK_DIV => C_APP_CLK_FREQ/C_I2C_CLK_FREQ -- Clock divider for I2C
  )
  port map(
    p_i_clk   => pi_clock,
    p_i_reset => pi_reset,
    ---------------------------------------------------------------------------
    -- Arbiter
    ---------------------------------------------------------------------------
    p_i_i2c_req(0) => po_req,
    p_o_i2c_grant(0) => pi_grant,
    ---------------------------------------------------------------------------
    -- Controller Interface
    ---------------------------------------------------------------------------
    p_i_str(0)     => po_i2c_str,
    p_i_wr(0)      => po_i2c_write_ena,
    p_i_rep        => (others=>'0'), -- Repeat after transaction (Not needed) 
    p_i_data_width(0) => po_i2c_data_width(0),
    p_i_data(0)       => po_i2c_data(0),
    p_i_addr(0)       => po_i2c_addr(0),
    p_o_data       => pi_i2c_data(0),
    p_o_done       => pi_i2c_done,
    p_o_busy       => open,
    p_o_dry        => open,
    ---------------------------------------------------------------------------
    --! i2c interface
    ---------------------------------------------------------------------------
    p_i_sdi => p_i_sdi, 
    p_o_sdo => p_o_sdo, 
    p_o_sdt => p_o_sdt, 
    p_i_sci => p_i_sci, 
    p_o_sco => p_o_sco, 
    p_o_sct => p_o_sct 
  );
  
  -- Clock generation
  pi_clock <= not pi_clock after CLOCK_PERIOD/2;
  
  --Stimulus
  stim_proc : process 
  begin 
    pi_reset <= '1';
    report "Reset asserted" severity note;
    wait for 100 ns;
    pi_reset <= '0';
        
    -- Testing both ports    
    wait until rising_edge(pi_clock);
    pi_channel_sel <= '1';
    pi_enable_ports <= '1';
    pi_send_or_read_conf <= '1'; -- Send configuration
    pi_start <= '1';
    
    wait for 100 ns;
    pi_start <= '0';
    wait until po_busy = '0';
    wait until rising_edge(pi_clock);
    pi_send_or_read_conf <= '0'; -- Read configuration
    pi_start <= '1';
    wait until po_busy = '1';
    pi_start <= '0';
    wait;
      
  end process;
  
end Behavioral;
