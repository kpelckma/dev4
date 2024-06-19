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
--! @file    tb_hmc624_over_pca9535.vhd
--! @brief   Testbench for the Attenuators interface using PCA9535 
--! @author  Cagil Gumus
--! @created 2021-02-10
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_types.all;

entity tb_hmc624_over_pca9535 is
end tb_hmc624_over_pca9535;

architecture Behavioral of tb_hmc624_over_pca9535 is

  -- Generic constants for DUT
  constant C_I2C_CLK_FREQ  : natural := 100_000; -- I2c Clock Freq. in Hz
  constant C_APP_CLK_FREQ  : natural := 81_250_000; -- Main Clock Freq. in Hz
  constant CLOCK_PERIOD : time := 12.31ns; -- 1/C_APP_CLK_FREQ
  constant G_MAX_CHANNELS : natural := 8;

  -- Inputs to DUT
  signal pi_clock : std_logic:='0';
  signal pi_reset : std_logic:='0';
  signal pi_att_val : std_logic_vector(5 downto 0);
  signal pi_att_sel : std_logic_vector(G_MAX_CHANNELS-1 downto 0);
  signal pi_att_start : std_logic := '0';
  signal pi_i2c_done : std_logic_vector(0 downto 0);
  signal pi_grant : std_logic;

  -- Outputs from DUT
  signal po_req : std_logic;
  signal po_i2c_str : std_logic;
  signal po_i2c_write_ena : std_logic;
  signal po_i2c_data_width : t_2bitarray(0 downto 0);
  signal po_i2c_data : t_32bitarray(0 downto 0);
  signal po_i2c_addr : t_8bitarray(0 downto 0);
  signal po_att_status : std_logic;

  -- I2C Bus
  signal p_i_sdi : std_logic;
  signal p_o_sdo : std_logic;
  signal p_o_sdt : std_logic;
  signal p_i_sci : std_logic;
  signal p_o_sco : std_logic;
  signal p_o_sct : std_logic;
  
  -- Misc
  signal pi_i2c_rep : std_logic;

begin

  DUT : entity work.hmc624_over_pca9535
  generic map(
    G_PCA9535_I2C_ADDR => x"20",
    G_MAX_CHANNELS => G_MAX_CHANNELS,
    G_DEFAULT_VALUES => x"FFFF"
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
    po_i2c_data       => po_i2c_data(0),
    po_i2c_addr       => po_i2c_addr(0),
    pi_i2c_done       => pi_i2c_done(0),
    
    -- Attenuator params
    pi_att_val    => pi_att_val,
    pi_att_sel    => pi_att_sel,
    pi_att_start  => pi_att_start,
    po_att_status => po_att_status
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
    p_i_data_width => po_i2c_data_width,
    p_i_data       => po_i2c_data,
    p_i_addr       => po_i2c_addr,
    p_o_data       => open,
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
    pi_att_val <= "110101";
    pi_att_sel <= "11010100";
    pi_att_start <= '1';
    wait for 100 ns;
    wait until rising_edge(pi_clock);
    pi_att_start <= '0';
    
    -- Testing only port0
    wait for 11 ms;
    wait until rising_edge(pi_clock);
    pi_att_val <= "110101";
    pi_att_sel <= "00111111";
    pi_att_start <= '1';
    wait for 100 ns;
    wait until rising_edge(pi_clock);
    pi_att_start <= '0';
    
    
    -- Testing only port1
    wait for 11 ms; 
    wait until rising_edge(pi_clock);
    pi_att_val <= "110101";
    pi_att_sel <= "01000000";
    pi_att_start <= '1';
    wait for 100 ns;
    wait until rising_edge(pi_clock);
    pi_att_start <= '0';
    
    -- Testing weird Reset Assertion during transaction
    wait for 11 ms; 
    wait until rising_edge(pi_clock);
    pi_att_val <= "110101";
    pi_att_sel <= "10000000";
    pi_att_start <= '1';
    wait for 100 ns;
    wait until rising_edge(pi_clock);
    pi_att_start <= '0';
    wait for 1 ms; 
    pi_reset <= '1';
    wait for 10 us;
    pi_reset <= '0';
    
    -- Testing if it can recover after async reset assertion
    wait for 11 ms; 
    wait until rising_edge(pi_clock);
    pi_att_val <= "110101";
    pi_att_sel <= "10000000";
    pi_att_start <= '1';
    wait for 100 ns;
    wait until rising_edge(pi_clock);
    pi_att_start <= '0';
    
    wait;
    
    
    
  end process;
  

end Behavioral;
