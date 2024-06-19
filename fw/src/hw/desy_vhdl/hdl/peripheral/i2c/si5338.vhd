--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2013 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2013-09-12
--! @author Bin Yang
--------------------------------------------------------------------------------
--! @brief SI5338 PLL configuration state machine
--!
--! I2C interface shall be available by cascading an adapter*
--! * i2c_controller or i2c_control_arbiter
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library desy;
use desy.common_types.all;

entity si5338 is
  generic (
    G_CLK_FREQ    : natural   := 50_000_000;
    G_CLK_SRC_SEL : std_logic := '0'; --! '0' for CLKIN / '1' for FDBK
    G_PLL_CFG     : t_24b_slv_vector(348 downto 0) := (
      x"00" & x"00" & x"00",
      x"01" & x"00" & x"00",
      x"02" & x"00" & x"00",
      x"03" & x"00" & x"00",
      x"04" & x"00" & x"00",
      x"05" & x"00" & x"00",
      x"06" & x"00" & x"1D",
      x"07" & x"00" & x"00",
      x"08" & x"70" & x"00",
      x"09" & x"0F" & x"00",
      x"0A" & x"00" & x"00",
      x"0B" & x"00" & x"00",
      x"0C" & x"00" & x"00",
      x"0D" & x"00" & x"00",
      x"0E" & x"00" & x"00",
      x"0F" & x"00" & x"00",
      x"10" & x"00" & x"00",
      x"11" & x"00" & x"00",
      x"12" & x"00" & x"00",
      x"13" & x"00" & x"00",
      x"14" & x"00" & x"00",
      x"15" & x"00" & x"00",
      x"16" & x"00" & x"00",
      x"17" & x"00" & x"00",
      x"18" & x"00" & x"00",
      x"19" & x"00" & x"00",
      x"1A" & x"00" & x"00",
      x"1B" & x"70" & x"80",
      x"1C" & x"16" & x"FF",
      x"1D" & x"90" & x"FF",
      x"1E" & x"40" & x"FF",
      x"1F" & x"C0" & x"FF",
      x"20" & x"C0" & x"FF",
      x"21" & x"C0" & x"FF",
      x"22" & x"C0" & x"FF",
      x"23" & x"55" & x"FF",
      x"24" & x"06" & x"1F",
      x"25" & x"06" & x"1F",
      x"26" & x"06" & x"1F",
      x"27" & x"06" & x"1F",
      x"28" & x"84" & x"FF",
      x"29" & x"10" & x"7F",
      x"2A" & x"24" & x"3F",
      x"2B" & x"00" & x"00",
      x"2C" & x"00" & x"00",
      x"2D" & x"00" & x"FF",
      x"2E" & x"00" & x"FF",
      x"2F" & x"14" & x"3F",
      x"30" & x"3A" & x"FF",
      x"31" & x"00" & x"FF",
      x"32" & x"C4" & x"FF",
      x"33" & x"07" & x"FF",
      x"34" & x"10" & x"FF",
      x"35" & x"00" & x"FF",
      x"36" & x"08" & x"FF",
      x"37" & x"00" & x"FF",
      x"38" & x"00" & x"FF",
      x"39" & x"00" & x"FF",
      x"3A" & x"00" & x"FF",
      x"3B" & x"01" & x"FF",
      x"3C" & x"00" & x"FF",
      x"3D" & x"00" & x"FF",
      x"3E" & x"00" & x"3F",
      x"3F" & x"10" & x"FF",
      x"40" & x"00" & x"FF",
      x"41" & x"08" & x"FF",
      x"42" & x"00" & x"FF",
      x"43" & x"00" & x"FF",
      x"44" & x"00" & x"FF",
      x"45" & x"00" & x"FF",
      x"46" & x"01" & x"FF",
      x"47" & x"00" & x"FF",
      x"48" & x"00" & x"FF",
      x"49" & x"00" & x"3F",
      x"4A" & x"10" & x"FF",
      x"4B" & x"00" & x"FF",
      x"4C" & x"08" & x"FF",
      x"4D" & x"00" & x"FF",
      x"4E" & x"00" & x"FF",
      x"4F" & x"00" & x"FF",
      x"50" & x"00" & x"FF",
      x"51" & x"01" & x"FF",
      x"52" & x"00" & x"FF",
      x"53" & x"00" & x"FF",
      x"54" & x"00" & x"3F",
      x"55" & x"10" & x"FF",
      x"56" & x"00" & x"FF",
      x"57" & x"08" & x"FF",
      x"58" & x"00" & x"FF",
      x"59" & x"00" & x"FF",
      x"5A" & x"00" & x"FF",
      x"5B" & x"00" & x"FF",
      x"5C" & x"01" & x"FF",
      x"5D" & x"00" & x"FF",
      x"5E" & x"00" & x"FF",
      x"5F" & x"00" & x"3F",
      x"60" & x"10" & x"00",
      x"61" & x"00" & x"FF",
      x"62" & x"30" & x"FF",
      x"63" & x"00" & x"FF",
      x"64" & x"00" & x"FF",
      x"65" & x"00" & x"FF",
      x"66" & x"00" & x"FF",
      x"67" & x"01" & x"FF",
      x"68" & x"00" & x"FF",
      x"69" & x"00" & x"FF",
      x"6A" & x"80" & x"BF",
      x"6B" & x"00" & x"FF",
      x"6C" & x"00" & x"FF",
      x"6D" & x"00" & x"FF",
      x"6E" & x"40" & x"FF",
      x"6F" & x"00" & x"FF",
      x"70" & x"00" & x"FF",
      x"71" & x"00" & x"FF",
      x"72" & x"40" & x"FF",
      x"73" & x"00" & x"FF",
      x"74" & x"80" & x"FF",
      x"75" & x"00" & x"FF",
      x"76" & x"40" & x"FF",
      x"77" & x"00" & x"FF",
      x"78" & x"00" & x"FF",
      x"79" & x"00" & x"FF",
      x"7A" & x"40" & x"FF",
      x"7B" & x"00" & x"FF",
      x"7C" & x"00" & x"FF",
      x"7D" & x"00" & x"FF",
      x"7E" & x"00" & x"FF",
      x"7F" & x"00" & x"FF",
      x"80" & x"00" & x"FF",
      x"81" & x"00" & x"0F",
      x"82" & x"00" & x"0F",
      x"83" & x"00" & x"FF",
      x"84" & x"00" & x"FF",
      x"85" & x"00" & x"FF",
      x"86" & x"00" & x"FF",
      x"87" & x"00" & x"FF",
      x"88" & x"00" & x"FF",
      x"89" & x"00" & x"FF",
      x"8A" & x"00" & x"FF",
      x"8B" & x"00" & x"FF",
      x"8C" & x"00" & x"FF",
      x"8D" & x"00" & x"FF",
      x"8E" & x"00" & x"FF",
      x"8F" & x"00" & x"FF",
      x"90" & x"00" & x"FF",
      x"91" & x"00" & x"00",
      x"92" & x"FF" & x"00",
      x"93" & x"00" & x"00",
      x"94" & x"00" & x"00",
      x"95" & x"00" & x"00",
      x"96" & x"00" & x"00",
      x"97" & x"00" & x"00",
      x"98" & x"00" & x"FF",
      x"99" & x"00" & x"FF",
      x"9A" & x"00" & x"FF",
      x"9B" & x"00" & x"FF",
      x"9C" & x"00" & x"FF",
      x"9D" & x"00" & x"FF",
      x"9E" & x"00" & x"0F",
      x"9F" & x"00" & x"0F",
      x"A0" & x"00" & x"FF",
      x"A1" & x"00" & x"FF",
      x"A2" & x"00" & x"FF",
      x"A3" & x"00" & x"FF",
      x"A4" & x"00" & x"FF",
      x"A5" & x"00" & x"FF",
      x"A6" & x"00" & x"FF",
      x"A7" & x"00" & x"FF",
      x"A8" & x"00" & x"FF",
      x"A9" & x"00" & x"FF",
      x"AA" & x"00" & x"FF",
      x"AB" & x"00" & x"FF",
      x"AC" & x"00" & x"FF",
      x"AD" & x"00" & x"FF",
      x"AE" & x"00" & x"FF",
      x"AF" & x"00" & x"FF",
      x"B0" & x"00" & x"FF",
      x"B1" & x"00" & x"FF",
      x"B2" & x"00" & x"FF",
      x"B3" & x"00" & x"FF",
      x"B4" & x"00" & x"FF",
      x"B5" & x"00" & x"0F",
      x"B6" & x"00" & x"FF",
      x"B7" & x"00" & x"FF",
      x"B8" & x"00" & x"FF",
      x"B9" & x"00" & x"FF",
      x"BA" & x"00" & x"FF",
      x"BB" & x"00" & x"FF",
      x"BC" & x"00" & x"FF",
      x"BD" & x"00" & x"FF",
      x"BE" & x"00" & x"FF",
      x"BF" & x"00" & x"FF",
      x"C0" & x"00" & x"FF",
      x"C1" & x"00" & x"FF",
      x"C2" & x"00" & x"FF",
      x"C3" & x"00" & x"FF",
      x"C4" & x"00" & x"FF",
      x"C5" & x"00" & x"FF",
      x"C6" & x"00" & x"FF",
      x"C7" & x"00" & x"FF",
      x"C8" & x"00" & x"FF",
      x"C9" & x"00" & x"FF",
      x"CA" & x"00" & x"FF",
      x"CB" & x"00" & x"0F",
      x"CC" & x"00" & x"FF",
      x"CD" & x"00" & x"FF",
      x"CE" & x"00" & x"FF",
      x"CF" & x"00" & x"FF",
      x"D0" & x"00" & x"FF",
      x"D1" & x"00" & x"FF",
      x"D2" & x"00" & x"FF",
      x"D3" & x"00" & x"FF",
      x"D4" & x"00" & x"FF",
      x"D5" & x"00" & x"FF",
      x"D6" & x"00" & x"FF",
      x"D7" & x"00" & x"FF",
      x"D8" & x"00" & x"FF",
      x"D9" & x"00" & x"FF",
      x"DA" & x"00" & x"00",
      x"DB" & x"00" & x"00",
      x"DC" & x"00" & x"00",
      x"DD" & x"0D" & x"00",
      x"DE" & x"00" & x"00",
      x"DF" & x"00" & x"00",
      x"E0" & x"F4" & x"00",
      x"E1" & x"F0" & x"00",
      x"E2" & x"00" & x"00",
      x"E3" & x"00" & x"00",
      x"E4" & x"00" & x"00",
      x"E5" & x"00" & x"00",
      x"E7" & x"00" & x"00",
      x"E8" & x"00" & x"00",
      x"E9" & x"00" & x"00",
      x"EA" & x"00" & x"00",
      x"EB" & x"00" & x"00",
      x"EC" & x"00" & x"00",
      x"ED" & x"00" & x"00",
      x"EE" & x"14" & x"00",
      x"EF" & x"00" & x"00",
      x"F0" & x"00" & x"00",
      x"F2" & x"02" & x"02",
      x"F3" & x"F0" & x"00",
      x"F4" & x"00" & x"00",
      x"F5" & x"00" & x"00",
      x"F7" & x"00" & x"00",
      x"F8" & x"00" & x"00",
      x"F9" & x"A8" & x"00",
      x"FA" & x"00" & x"00",
      x"FB" & x"84" & x"00",
      x"FC" & x"00" & x"00",
      x"FD" & x"00" & x"00",
      x"FE" & x"00" & x"00",
      x"FF" & x"01" & x"FF",
      x"00" & x"00" & x"00",
      x"01" & x"00" & x"00",
      x"02" & x"00" & x"00",
      x"03" & x"00" & x"00",
      x"04" & x"00" & x"00",
      x"05" & x"00" & x"00",
      x"06" & x"00" & x"00",
      x"07" & x"00" & x"00",
      x"08" & x"00" & x"00",
      x"09" & x"00" & x"00",
      x"0A" & x"00" & x"00",
      x"0B" & x"00" & x"00",
      x"0C" & x"00" & x"00",
      x"0D" & x"00" & x"00",
      x"0E" & x"00" & x"00",
      x"0F" & x"00" & x"00",
      x"10" & x"00" & x"00",
      x"11" & x"01" & x"00",
      x"12" & x"00" & x"00",
      x"13" & x"00" & x"00",
      x"14" & x"90" & x"00",
      x"15" & x"31" & x"00",
      x"16" & x"00" & x"00",
      x"17" & x"00" & x"00",
      x"18" & x"01" & x"00",
      x"19" & x"00" & x"00",
      x"1A" & x"00" & x"00",
      x"1B" & x"00" & x"00",
      x"1C" & x"00" & x"00",
      x"1D" & x"00" & x"00",
      x"1E" & x"00" & x"00",
      x"1F" & x"00" & x"FF",
      x"20" & x"00" & x"FF",
      x"21" & x"01" & x"FF",
      x"22" & x"00" & x"FF",
      x"23" & x"00" & x"FF",
      x"24" & x"F0" & x"FF",
      x"25" & x"13" & x"FF",
      x"26" & x"00" & x"FF",
      x"27" & x"00" & x"FF",
      x"28" & x"01" & x"FF",
      x"29" & x"00" & x"FF",
      x"2A" & x"00" & x"FF",
      x"2B" & x"00" & x"0F",
      x"2C" & x"00" & x"00",
      x"2D" & x"00" & x"00",
      x"2E" & x"00" & x"00",
      x"2F" & x"00" & x"FF",
      x"30" & x"00" & x"FF",
      x"31" & x"01" & x"FF",
      x"32" & x"00" & x"FF",
      x"33" & x"00" & x"FF",
      x"34" & x"F0" & x"FF",
      x"35" & x"13" & x"FF",
      x"36" & x"00" & x"FF",
      x"37" & x"00" & x"FF",
      x"38" & x"01" & x"FF",
      x"39" & x"00" & x"FF",
      x"3A" & x"00" & x"FF",
      x"3B" & x"00" & x"0F",
      x"3C" & x"00" & x"00",
      x"3D" & x"00" & x"00",
      x"3E" & x"00" & x"00",
      x"3F" & x"00" & x"FF",
      x"40" & x"00" & x"FF",
      x"41" & x"01" & x"FF",
      x"42" & x"00" & x"FF",
      x"43" & x"00" & x"FF",
      x"44" & x"F0" & x"FF",
      x"45" & x"13" & x"FF",
      x"46" & x"00" & x"FF",
      x"47" & x"00" & x"FF",
      x"48" & x"01" & x"FF",
      x"49" & x"00" & x"FF",
      x"4A" & x"00" & x"FF",
      x"4B" & x"00" & x"0F",
      x"4C" & x"00" & x"00",
      x"4D" & x"00" & x"00",
      x"4E" & x"00" & x"00",
      x"4F" & x"00" & x"FF",
      x"50" & x"00" & x"FF",
      x"51" & x"01" & x"FF",
      x"52" & x"00" & x"FF",
      x"53" & x"00" & x"FF",
      x"54" & x"F0" & x"FF",
      x"55" & x"13" & x"FF",
      x"56" & x"00" & x"FF",
      x"57" & x"00" & x"FF",
      x"58" & x"01" & x"FF",
      x"59" & x"00" & x"FF",
      x"5A" & x"00" & x"FF",
      x"5B" & x"00" & x"0F",
      x"5C" & x"00" & x"00",
      x"5D" & x"00" & x"00",
      x"5E" & x"00" & x"00",
      x"FF" & x"00" & x"FF"
    )
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    --! fsm kick and monitor
    po_cfg_done : out std_logic := '0';
    pi_cfg_str  : in  std_logic;

    --! i2c_control_arbiter interface    
    pi_grant      : in std_logic  := '1';
    po_req        : out std_logic;
    --! i2c_control_arbiter/i2c_controller interface
    pi_done       : in  std_logic;                      --! I2C transaction done
    po_str        : out std_logic;                      --! I2C transaction strobe
    po_wr         : out std_logic;                      --! '1' - write / '0' - read
    pi_dry        : in  std_logic;                      --! I2C read data is ready 
    pi_data       : in  std_logic_vector(31 downto 0);  --! I2C read data
    po_data       : out std_logic_vector(31 downto 0);  --! I2C write data
    po_data_width : out std_logic_vector(1 downto 0);   --! number of bytes - 1
    
    --! memory buffer for configuration
    pi_pll_cfg_re   : in  std_logic := '0';
    pi_pll_cfg_we   : in  std_logic := '0';
    po_pll_cfg_data : out std_logic_vector(23 downto 0);
    pi_pll_cfg_data : in  std_logic_vector(23 downto 0) := (others => '0');
    pi_pll_cfg_addr : in  std_logic_vector(8 downto 0)  := (others => '0');
    --! register access after configuration
    pi_pll_re   : in  std_logic := '0';
    pi_pll_we   : in  std_logic := '0';
    po_pll_data : out std_logic_vector(7 downto 0);
    pi_pll_data : in  std_logic_vector(7 downto 0)  := ( others => '0' );
    pi_pll_addr : in  std_logic_vector(7 downto 0)  := ( others => '0' )
  );
end si5338;

architecture rtl of si5338 is

  type t_state is (
    ST_IDLE, ST_WAIT_FOR_GRANT, ST_DISABLE_OUTPUT, ST_ACK, ST_PAUSE_LOL, 
    ST_REG_MAP, ST_REG_ADDR, ST_REG_READ, ST_REG_READ_ACK,
    ST_REG_WRITE, ST_REG_WRITE_ACK, ST_LOS_ADDR, ST_LOS_READ, ST_LOS_READ_ACK,
    ST_VALIDATE_CLKIN, ST_CONFIG_PLL_LOCK, ST_INIT_LOCK_PLL, ST_INIT_LOCK_PLL_ACK,
    ST_DELAY, ST_RESTART_LOL, ST_PLL_LOCK_ADDR, ST_PLL_LOCK_READ,
    ST_PLL_LOCK_READ_ACK, ST_VALIDATE_PLL_LOCK, ST_FCAL_ADDR, ST_FCAL_READ,
    ST_FCAL_READ_ACK, ST_FCAL_OVRD, ST_USE_FCAL, ST_ENABLE_OUTPUT,
    ST_ENABLE_OUTPUT_ACK, ST_PLL_SOFT_RESET, ST_READ_REGISTER_ADDR,
    ST_READ_REGISTER, ST_READ_REGISTER_ACK, ST_WRITE_REGISTER
  );

  signal state        : t_state := ST_IDLE;
  signal state_next   : t_state := ST_IDLE;
  signal o_data       : std_logic_vector(31 downto 0);
  signal o_data_width : std_logic_vector(1 downto 0);
  signal wr           : std_logic;
  signal str          : std_logic;
  signal reg_addr     : std_logic_vector(7 downto 0);
  signal reg_data     : std_logic_vector(7 downto 0);
  signal reg_mask     : std_logic_vector(7 downto 0);
  signal i_data       : std_logic_vector(7 downto 0);
  signal los_clkin    : std_logic;
  signal pll_lock     : std_logic_vector(2 downto 0);
  signal fcal         : std_logic_vector(23 downto 0);
  signal cfg_data     : std_logic_vector(23 downto 0);
  signal cfg_addr     : natural ;
  signal cfg_mem      : t_24b_slv_vector(G_PLL_CFG'left downto 0) := G_PLL_CFG;

begin

  po_str        <= str;
  po_wr         <= wr;
  po_data_width <= o_data_width;
  po_data       <= o_data;
 
  prs_io: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      cfg_data <= cfg_mem(cfg_addr);
      if pi_pll_cfg_re = '1' then
        po_pll_cfg_data <= cfg_mem(to_integer(unsigned(pi_pll_cfg_addr)));
      end if;
      if pi_pll_cfg_we = '1' then
        cfg_mem(to_integer(unsigned(pi_pll_cfg_addr))) <= pi_pll_cfg_data;
      end if;
    end if;
   end process prs_io;
  
  prs_fsm: process(pi_clock)
    variable v_count    : integer range 0 to 125e6 := 0;
    variable v_timeout  : integer range 0 to 16383 := 0;  --! timeout for clock validity
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        state <= ST_IDLE ;
      else
        case state is
          when ST_IDLE =>
            o_data <= (others=>'0');
            o_data_width <= (others=>'0');
            str <= '0';
            wr <= '0';
            po_req <= '0';
            cfg_addr <= cfg_mem'length - 1;
            if pi_cfg_str = '1' then
              state_next <= ST_DISABLE_OUTPUT;
              state <= ST_WAIT_FOR_GRANT;
            elsif pi_pll_re = '1' then
              state_next <= ST_READ_REGISTER_ADDR;
              state <= ST_WAIT_FOR_GRANT;  
            elsif pi_pll_we = '1' then
              state_next <= ST_WRITE_REGISTER;
              state <= ST_WAIT_FOR_GRANT;
            end if;
          when ST_WAIT_FOR_GRANT =>
            v_timeout := 16383;
            po_req <= '1';
            if pi_grant = '1' then
              state <= state_next;
            end if;
          when ST_DISABLE_OUTPUT =>
            po_cfg_done <= '0';
            o_data(15 downto 0) <= x"E6" & x"10"; --! set OEB_ALL = 1, reg230[4] 
            o_data_width <= "01";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_PAUSE_LOL;
          when ST_ACK =>
            str <= '0';
            if pi_done = '1' then
              wr <= '0';
              state <= state_next;
            end if;
          when ST_PAUSE_LOL =>
            o_data(15 downto 0) <= x"F1" & x"E5"; --! set DIS_LOL = 1, reg241[7], reg241[6:0] = 0x65
            o_data_width <= "01";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_REG_MAP;
          -----------------------------------------------------------
          --! read-modify-write 
          when ST_REG_MAP =>
            o_data <= (others=>'0');
            o_data_width <= (others=>'0');
            str <= '0';
            wr <= '0';
            state <= ST_REG_ADDR;
          when ST_REG_ADDR => --! address of register
            reg_addr <= cfg_data(23 downto 16);
            reg_data <= cfg_data(15 downto 8);
            reg_mask <= cfg_data(7 downto 0);
            o_data <= (others=>'0');
            o_data(7 downto 0) <= cfg_data(23 downto 16); --! write address of register
            o_data_width <= "00";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_REG_READ;
          when ST_REG_READ => --! read data of register
            o_data <= (others=>'0');
            o_data_width <= "00";
            str <= '1';
            wr <= '0';
            if reg_mask = x"00" then  --! ignore registers with masks of X"00"
              state <= ST_REG_WRITE_ACK;
            else
              state <= ST_REG_READ_ACK;
            end if;
          when ST_REG_READ_ACK =>
            str <= '0';
            if pi_done = '1' then
              wr <= '0';
              state <= ST_REG_WRITE;
            end if;
            if pi_dry = '1' then
              i_data <= pi_data(7 downto 0);
            end if;
          when ST_REG_WRITE =>  --! write masked data to register
            o_data <=  (others=>'0');
            o_data(15 downto 8) <= reg_addr;
            o_data(7 downto 0) <= (reg_data and reg_mask) or (i_data and not reg_mask);
            o_data_width <= "01";
            str <= '1';
            wr <= '1';
            state <= ST_REG_WRITE_ACK;
          when ST_REG_WRITE_ACK =>
            str <= '0';
            if pi_done = '1' then
              wr <= '0';
              if cfg_addr = 0 then
                state <= ST_LOS_ADDR;
              else
                cfg_addr <= cfg_addr - 1;
                state <= ST_REG_MAP;
              end if;
            end if;
          --! read-modify-write 
          -----------------------------------------------------------
          when ST_LOS_ADDR =>
            o_data <= (others=>'0');
            o_data(7 downto 0) <=  x"DA"; --! write address of register 218, for LOS alarm
            o_data_width <= "00";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_LOS_READ;
            v_timeout := v_timeout - 1;
          when ST_LOS_READ => --! read data of LOS
            o_data <= (others=>'0');
            o_data_width <= "00";
            str <= '1';
            wr <= '0';
            state <= ST_LOS_READ_ACK;
          when ST_LOS_READ_ACK =>
            str <= '0';
            if pi_done = '1' then
              wr <= '0';
              state <= ST_VALIDATE_CLKIN;
            end if;
            if pi_dry = '1' then
              los_clkin <= pi_data(2);
            end if;
          when ST_VALIDATE_CLKIN => --! validate input clock status
            if los_clkin = '0' then
              state <= ST_CONFIG_PLL_LOCK;
            else
              if v_timeout = 0 then
                state <= ST_PLL_SOFT_RESET;
              else
                state <= ST_LOS_ADDR;
              end if;
            end if;
          when ST_CONFIG_PLL_LOCK =>  --! configure PLL for locking
            o_data(15 downto 0) <= x"31" & x"00"; --! set FCAL_OVRD_EN = 0, reg49[7] 
            o_data_width <= "01";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_INIT_LOCK_PLL;
          when ST_INIT_LOCK_PLL =>  --! initiate locking of PLL
            o_data(15 downto 0) <= x"F6" & x"02"; --! Set SOFT_RESET = 1, reg246[1]  
            o_data_width <= "01";
            str <= '1';
            wr <= '1';
            state <= ST_INIT_LOCK_PLL_ACK;
          when ST_INIT_LOCK_PLL_ACK =>
            str <= '0';
            if pi_done = '1' then
              wr <= '0';
              v_count := integer(real(G_CLK_FREQ) * 0.0255); --! set timer for min 25ms
              state <= ST_DELAY;
            end if;
          when ST_DELAY =>
            if v_count > 0 then
              v_count := v_count - 1;
            else
              state <= ST_RESTART_LOL;
            end if;
          when ST_RESTART_LOL =>  --! restart LOL
            o_data(15 downto 0) <= x"F1" & x"65"; --! set DIS_LOL = 0, reg241[7] 
            o_data_width <= "01";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_PLL_LOCK_ADDR;
            v_timeout := 16383;
          when ST_PLL_LOCK_ADDR =>  --! address of PLL_LOL, SYS_CAL
            o_data  <= (others=>'0');
            o_data(7 downto 0) <= x"DA";  --! write address of register 218, for PLL_LOL and SYS_CAL
            o_data_width <= "00";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_PLL_LOCK_READ;
            v_timeout := v_timeout - 1;
          when ST_PLL_LOCK_READ =>  --! read data of PLL_LOL, SYS_CAL
            o_data <= (others=>'0');
            o_data_width <= "00";
            str <= '1';
            wr <= '0';
            state <= ST_PLL_LOCK_READ_ACK;
          when ST_PLL_LOCK_READ_ACK =>
            str <= '0';
            if pi_done = '1' then
              wr <= '0';
              state <= ST_VALIDATE_PLL_LOCK;
            end if;
            if pi_dry = '1' then
              if G_CLK_SRC_SEL = '1' then
                pll_lock <= pi_data(4) & pi_data(3) & pi_data(0);
              else
                pll_lock <= pi_data(4) & pi_data(2) & pi_data(0);
              end if;
            end if;
          when ST_VALIDATE_PLL_LOCK =>  --! validate if PLL locked
            if pll_lock = "000" then
              state <= ST_FCAL_ADDR;
            else
              if v_timeout = 0 then
                state <= ST_PLL_SOFT_RESET;
              else
                state <= ST_PLL_LOCK_ADDR;
              end if;
            end if;
          when ST_FCAL_ADDR =>
            o_data <= (others=>'0');
            o_data(7 downto 0) <= x"EB";  --! write address of register 235, for FCAL
            o_data_width <= "00";
            str <=  '1';
            wr <=  '1';
            state <= ST_ACK;
            state_next <= ST_FCAL_READ;
          when ST_FCAL_READ => --! read data of LOS
            o_data <= (others=>'0');
            o_data_width <= "10";
            str <= '1';
            wr <=  '0';
            state <= ST_FCAL_READ_ACK;
          when ST_FCAL_READ_ACK =>
            str <= '0';
            if pi_done = '1' then
              wr <= '0';
              state <= ST_FCAL_OVRD;
            end if;
            if pi_dry = '1' then
              fcal  <= pi_data(23 downto 0);
            end if;
          when ST_FCAL_OVRD =>  --! copy fcal to fcal_ovrd
            o_data <= x"2D" & fcal(23 downto 8) & "000101" & fcal(1 downto 0); 
              --! reg45 <= reg235, reg46 <= reg236, reg47 <= "000101"& reg237[1:0]   
            o_data_width <= "11";
            str <=  '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_USE_FCAL;
          when ST_USE_FCAL => --! set Pll to use FCAL values
            o_data(15 downto 0) <= x"31" & x"80"; --! set FCAL_OVRD_EN = 1, reg49[7] 
            o_data_width <= "01";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_ENABLE_OUTPUT;
          when ST_ENABLE_OUTPUT =>
            o_data(15 downto 0) <= X"E6" & X"00"; --! set OEB_ALL = 0, reg230[4]
            o_data_width <= "01";
            str <= '1';
            wr <= '1';
            state <= ST_ENABLE_OUTPUT_ACK;
          when ST_ENABLE_OUTPUT_ACK =>
            str <= '0';
            if pi_done = '1' then
              po_cfg_done <= '1';
              wr <= '0';
              state <= ST_IDLE;
            end if;
          when ST_PLL_SOFT_RESET =>
            o_data(15 downto 0) <= x"F6" & x"02"; --! set SOFT RESET = 2, reg246
            o_data_width <= "01";
            str <= '1';
            wr <=  '1';
            state <= ST_ACK;
            state_next <= ST_IDLE;
          when ST_READ_REGISTER_ADDR =>
            o_data <= (others=>'0');
            o_data(7 downto 0) <= pi_pll_addr(7 downto 0);
            o_data_width <= "00";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_READ_REGISTER;
          when ST_READ_REGISTER => 
            o_data <= (others=>'0');
            o_data_width <= "00";
            str <= '1';
            wr <= '0';
            state <= ST_READ_REGISTER_ACK;
          when ST_READ_REGISTER_ACK =>
            str <= '0';
            if pi_done = '1' then
              wr <= '0';
              state <= ST_IDLE;
            end if;
            if pi_dry = '1' then
              po_pll_data <= pi_data(7 downto 0);
            end if;
          when ST_WRITE_REGISTER => --! enable outputs
            o_data(15 downto 0) <= pi_pll_addr(7 downto 0) & pi_pll_data(7 downto 0);
            o_data_width <= "01";
            str <= '1';
            wr <= '1';
            state <= ST_ACK;
            state_next <= ST_IDLE;
          when others =>
            null;
        end case;
      end if;
    end if;
  end process prs_fsm;

end rtl;

