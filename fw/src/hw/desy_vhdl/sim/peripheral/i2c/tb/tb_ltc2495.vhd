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
--! @file    tb_ltc2495.vhd
--! @brief   Testbench for the LTC2495 ADC (I2C)
--! @author  Cagil Gumus, Katharina Schulz
--! @created 2021-02-10
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

entity tb_ltc2495 is
end tb_ltc2495;

architecture Behavioral of tb_ltc2495 is

  -- Generic constants for DUT
  constant C_I2C_CLK_FREQ  : natural := 100_000; -- I2c Clock Freq. in Hz
  constant C_APP_CLK_FREQ  : natural := 50_000_000;--81_250_000; -- Main Clock Freq. in Hz
  constant CLOCK_PERIOD    : time :=  20 ns ;-- 12.31ns; -- 1/C_APP_CLK_FREQ
 
  -- DUT signals
  signal pi_clock : std_logic :='0';
  signal pi_reset : std_logic :='0';
  signal pi_grant : std_logic :='0';
  signal po_req   : std_logic :='0';

  signal pi_start                 : std_logic;
  signal po_busy                  : std_logic;
  signal po_done                  : std_logic;
  signal pi_channel_sel           : std_logic_vector(16 downto 0):= ( others => '0');

  signal pi_ch_cfg_single_end     : std_logic_vector(15 downto 0) := ( others => '0');
  signal pi_ch_cfg_diff_swap      : std_logic_vector(15 downto 0) := ( others => '0');
  signal pi_ch_cfg_rejection_mode : t_2b_slv_vector(16 downto 0) := ( others => (others => '0'));
  signal pi_ch_cfg_speed_mode     : std_logic_vector(15 downto 0) := ( others => '0');
  signal pi_ch_cfg_gain           : t_3b_slv_vector(15 downto 0) := ( others => (others => '0'));

  signal po_adc_data              : t_17b_slv_vector(16 downto 0);
  signal po_adc_data_vld          : std_logic_vector(16 downto 0);

  -- DUT I2c Interface signals
  signal pi_i2c_done       : std_logic_vector(0 downto 0);
  signal po_i2c_str        : std_logic_vector(0 downto 0);
  signal po_i2c_rep        : std_logic_vector(0 downto 0);
  signal po_i2c_write_ena  : std_logic_vector(0 downto 0);
  signal po_i2c_data_width : t_2b_slv_vector(0 downto 0);
  signal po_i2c_data       : t_32b_slv_vector(0 downto 0):= ( others => (others => '0'));
  signal pi_i2c_data       : std_logic_vector(31 downto 0):= ( others => '0');
  signal po_i2c_addr       : t_8b_slv_vector(0 downto 0);

  -- I2C Bus
  signal p_i_sdi : std_logic;
  signal p_o_sdo : std_logic;
  signal p_o_sdt : std_logic;
  signal p_i_sci : std_logic;
  signal p_o_sco : std_logic;
  signal p_o_sct : std_logic;

  -- Misc
  signal i2c_sda : std_logic;
  signal i2c_scl : std_logic;

  --counter
  signal cnt : integer := 0;
  signal done : std_logic :='0';
  constant C_DATA : t_8b_slv_vector(17 downto 0):=
  (  
  0 => x"FF",
  1 => x"00",
     2 => x"01",
     3 => x"02",
     4 => x"03",
     5 => x"04",
     6 => x"05",
     7 => x"06",
     8 => x"07",
     9 => x"08",
     10 => x"09",
    11 => x"0A",
    12 => x"0B",
    13 => x"0C",
    14 => x"0D",
    15 => x"0E",
    16 => x"0F",
    17 => x"10");  

begin

  ltc2495_1: entity work.ltc2495
    generic map (
      G_I2C_ADDR => "00010100",
      G_CLK_FREQ => C_APP_CLK_FREQ
    )
    port map (
      pi_clock                 => pi_clock,
      pi_reset                 => pi_reset,
      po_req                   => po_req,
      pi_grant                 => pi_grant,
      pi_i2c_data              => pi_i2c_data,
      pi_i2c_done              => pi_i2c_done(0),
      po_i2c_str               => po_i2c_str(0),
      po_i2c_rep               => po_i2c_rep(0),
      po_i2c_write_ena         => po_i2c_write_ena(0),
      po_i2c_data_width        => po_i2c_data_width(0),
      po_i2c_data              => po_i2c_data(0),
      po_i2c_addr              => po_i2c_addr(0),
      pi_start                 => pi_start,
      po_busy                  => po_busy,
      po_done                  => po_done,
      pi_channel_sel           => pi_channel_sel,
      pi_ch_cfg_single_end     => pi_ch_cfg_single_end,
      pi_ch_cfg_diff_swap      => pi_ch_cfg_diff_swap,
      pi_ch_cfg_rejection_mode => pi_ch_cfg_rejection_mode,
      pi_ch_cfg_speed_mode     => pi_ch_cfg_speed_mode,
      pi_ch_cfg_gain           => pi_ch_cfg_gain,
      po_adc_data              => po_adc_data,
      po_adc_data_vld          => po_adc_data_vld
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
    p_i_str(0)        => po_i2c_str(0),
    p_i_wr(0)         => po_i2c_write_ena(0),
    p_i_rep(0)        => po_i2c_rep(0),
    p_i_data_width(0) => po_i2c_data_width(0),
    p_i_data(0)       => po_i2c_data(0),
    p_i_addr(0)       => po_i2c_addr(0),
    p_o_data          => open,--pi_i2c_data,
    p_o_done(0)       => pi_i2c_done(0),
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
  -- bus drive
  i2c_sda <= 'Z' when p_o_sdt = '0' else p_o_sdo;
  i2c_scl <= 'Z' when p_o_sct = '0' else p_o_sco;

  -- Clock generation
  pi_clock <= not pi_clock after CLOCK_PERIOD/2;

  --Stimulus
  stim_proc : process
  begin  
    pi_start <= '0';
    pi_reset <= '1';
    report "Reset asserted" severity note;
    wait for 100 ns;
    pi_reset <= '0';
    wait for 10 us;


    -- -- All channels are single ended
    -- wait until rising_edge(pi_clock);
    -- pi_ch_cfg_single_end     <= x"FFFF";
    -- pi_ch_cfg_diff_swap      <= x"0000";
    -- pi_channel_sel           <= "11111111111111111";
    -- pi_ch_cfg_rejection_mode <= ( others => "00");
    -- pi_ch_cfg_speed_mode     <= ( others => '0');
    -- pi_ch_cfg_gain           <= (others => "000");
    -- p_i_sdi <= '0';
    -- pi_start                 <= '1';
    -- wait until rising_edge(pi_clock);
    -- pi_start                 <= '0';
    
    
    -- -- Some channels are single ended
    -- wait until po_done = '1';
    -- wait for 10 us;
    -- wait until rising_edge(pi_clock);
    -- pi_ch_cfg_single_end     <= x"03FF";
    -- pi_ch_cfg_diff_swap      <= x"7000";
    -- pi_channel_sel           <= "11111111111111111";
    -- pi_ch_cfg_rejection_mode <= ( others => "00");
    -- pi_ch_cfg_speed_mode     <= ( others => '0');
    -- pi_ch_cfg_gain           <= (others => "000");
    -- pi_start                 <= '1';
    -- p_i_sdi                  <= '1';
    -- wait until rising_edge(pi_clock);
    -- pi_start                 <= '0';
    
        
    -- FLMO Diagnostic Hub Settings for ADC1
    -- wait until po_done = '1';
    -- wait for 10 us;
    wait until rising_edge(pi_clock);
    pi_ch_cfg_single_end     <= x"01FF";
    pi_ch_cfg_diff_swap      <= x"4300";
    pi_channel_sel           <= '1'& x"55FF"; 
    pi_ch_cfg_rejection_mode <= (others => "01");
    pi_ch_cfg_speed_mode     <= ( others => '0');
    pi_ch_cfg_gain           <= (others => "000");
    pi_start                 <= '1';
    p_i_sdi                  <= '1';
    
    wait until po_req='1';
    for cnt in 0 to 17 loop
      pi_i2c_data <=x"00"&"10"&"0000"&"0000"&C_DATA(cnt)&"000000";
      wait until po_req='1';
    end loop;
    
    for cnt in 0 to 17 loop
      pi_i2c_data <=x"00"&"10"&"0000"&"0000"&C_DATA(cnt)&"000000";
      wait until po_req='1';
    end loop;

--    -- FLMO Diagnostic Hub Settings for ADC2
----     wait until po_done = '1';
--     wait for 10 us;
--     wait until rising_edge(pi_clock);
--     pi_ch_cfg_single_end     <= x"0000";
--     pi_ch_cfg_diff_swap      <= x"5555";
--     pi_channel_sel           <= '1'& x"5555"; 
--     pi_ch_cfg_rejection_mode <= (others => "01");
--     pi_ch_cfg_speed_mode     <= ( others => '0');
--     pi_ch_cfg_gain           <= (others => "000");
--     pi_start                 <= '1';
--     p_i_sdi                  <= '1';
--     wait until rising_edge(pi_clock);
--     pi_start                 <= '0';
--for cnt in 0 to 17 loop
--pi_i2c_data <=x"00"&"10"&"0000"&"0000"&C_DATA(cnt)&"000000";
--wait on po_adc_data_vld;
----wait until pi_i2c_done(0)='1';
--end loop;

    -- -- None of the channels are single ended
    -- wait until po_done = '1';
    -- wait for 10 us;
    -- wait until rising_edge(pi_clock);
    -- pi_ch_cfg_single_end     <= x"0000";
    -- pi_ch_cfg_diff_swap      <= x"7000";
    -- pi_channel_sel           <= "11111111111111111";
    -- pi_ch_cfg_rejection_mode <= ( others => "00");
    -- pi_ch_cfg_speed_mode     <= ( others => '0');
    -- pi_ch_cfg_gain           <= (others => "000");
    -- pi_start                 <= '1';
    -- p_i_sdi                  <= '1';
    -- wait until rising_edge(pi_clock);
    -- pi_start                 <= '0';
    
    
    -- -- Reading the 17th Channel (Enables temperature reading) 
    -- wait until po_done = '1';
    -- wait for 10 us;
    -- wait until rising_edge(pi_clock);
    -- pi_channel_sel           <= '1' & x"0000";
    -- pi_start                 <= '1';
    -- wait until rising_edge(pi_clock);
    -- pi_start                 <= '0';
    
    -- -- Chaos... 
    -- wait until po_done = '1' ;
    -- wait for 10 us;
    -- wait until rising_edge(pi_clock);
    -- pi_ch_cfg_rejection_mode <= ( 0 => "11", others => "00");
    -- pi_ch_cfg_speed_mode     <= ( 1 => '1', others => '0');
    -- pi_channel_sel           <= '1' & x"0F0F";
    -- pi_start                 <= '1';
    -- wait until rising_edge(pi_clock);
    -- pi_start                 <= '0';
    
    wait;

  end process;


end Behavioral;
