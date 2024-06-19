------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2021-11-10
--! @author  MSK FPGA Team
------------------------------------------------------------------------------
--! @brief
--! Support of MAX6625/6626 Temperature sensor IC
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity max662x is
generic (
  G_CLK_FREQ : natural := 50_000_000);
port  (
  pi_clock : in std_logic;
  pi_reset : in std_logic;
  
  pi_grant : in std_logic := '1' ;
  po_req : out std_logic;
  
  -- i2c ports
  pi_dry         : in std_logic; --! i2c read data is ready 
  pi_data        : in std_logic_vector(31 downto 0); --! i2c read data
  pi_done        : in std_logic; --! i2c operation done
  po_str         : out std_logic; --! strobe i2c transmission 
  po_wr          : out std_logic; --! read or write to device, '1' - write; '0' - read
  po_data        : out std_logic_vector(31 downto 0); --! data dens to device
  po_data_width  : out std_logic_vector(1 downto 0);  --! number of bytes send to device
  
  -- pll registers ports, accessed after configuration done
  pi_temp_start  : in std_logic;
  po_temp_ready  : out std_logic;
  po_temp_data   : out std_logic_vector(15 downto 0)      
);
end max662x;

architecture behavioral of max662x is

  signal sig_state      : natural :=0 ;--t_fsm_state := idle;
  signal sig_state_next : natural :=0 ;--t_fsm_state := idle;
    
  signal sig_data          : std_logic_vector(31 downto 0);
  signal sig_data_width    : std_logic_vector(1 downto 0);
  signal sig_wr            : std_logic;
  signal sig_str           : std_logic;
  signal sig_reg_addr      : std_logic_vector(7 downto 0);
  signal sig_reg_data      : std_logic_vector(7 downto 0);
  
  signal sig_done          : std_logic;

begin

  po_data       <= sig_data;
  po_data_width <= sig_data_width;
  po_wr         <= sig_wr;
  po_str        <= sig_str;
  
  po_temp_ready <= sig_done;
  
  
  inst_i2c_prog: process (pi_clock, pi_reset)
    variable v_cnt  : integer range 0 to 125e6 := 0;
    variable var_cnt: integer;
  begin
    if pi_reset = '1' then
      sig_state <= 0 ;
      sig_done <= '1';
      po_temp_data <= (others => '0');
    elsif rising_edge(pi_clock) then
      case sig_state is   
        when 0 =>
          sig_data        <= (others=>'0');
          sig_data_width  <= (others=>'0');
          sig_str         <= '0';
          sig_wr          <= '0';
          po_req         <= '0';
          
          if pi_temp_start = '1' then 
            sig_state_next <= 2;
            sig_state      <= 1;  
            sig_done <= '0';
          end if;
          
        when 1 =>
          po_req         <= '1';
          if pi_grant = '1' then
            sig_state <= sig_state_next;
          end if;
          
        when 2 =>   --@ start temperature readout assuming the default address in the device
          sig_data        <=  (others=>'0');
          sig_data_width  <= "01"; -- the response is two bytes
          sig_str         <= '1';
          sig_wr          <= '0';
          sig_state       <= sig_state + 1;
          
        when 3 =>
          sig_str <=  '0';
          if pi_done = '1' then
            sig_wr    <= '0';
            sig_data_width  <= (others=>'0');
            sig_state   <= sig_state + 1;
            po_temp_data   <= pi_data(15 downto 0);
            sig_done  <= '1';
          end if;
          
        when others => sig_state <= 0;
          
      end case;

    end if;   
    
  end process;

end behavioral;
