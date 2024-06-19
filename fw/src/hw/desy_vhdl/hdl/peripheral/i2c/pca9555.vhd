-----------------------------------------------------------------------------
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
--! @date
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Needs I2C_CONTROLLER component to communicate with chip
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity pca9555 is
port (
  pi_clock      : in  std_logic;
  pi_reset      : in  std_logic;
  -- GPIO interface
  pi_str        : in std_logic;
  pi_gpo        : in std_logic_vector(15 downto 0);   -- general purpose output
  po_gpo        : out std_logic_vector(15 downto 0);  -- general purpose input
  pi_gpo_dir    : in std_logic_vector(15 downto 0);   -- general purpose direction
  po_gpo_done   : out std_logic;

  -- Arbiter interface
  po_req        : out std_logic;
  pi_grant      : in  std_logic := '1';
  -- I2C_CONTROLER interface
  po_str        : out std_logic;
  po_wr         : out std_logic;
  po_data_width : out std_logic_vector(1 downto 0);
  po_data       : out std_logic_vector(31 downto 0);
  pi_data       : in  std_logic_vector(31 downto 0);
  pi_dry        : in std_logic := '0';
  pi_done       : in  std_logic
);
end entity pca9555;

architecture beh of pca9555 is

  signal state          : natural := 0;
  signal next_state     : natural := 0;

  signal data_out : std_logic_vector(15 downto 0);
  signal data_dir : std_logic_vector(15 downto 0);

  signal command_in  : std_logic_vector(7 downto 0);
  signal command_out : std_logic_vector(7 downto 0);
  signal command_dir : std_logic_vector(7 downto 0);


  -- Command Register
-- 0 Input port 0
-- 1 Input port 1
-- 2 Output port 0
-- 3 Output port 1
-- 4 Polarity Inversion port 0
-- 5 Polarity Inversion port 1
-- 6 Configuration port 0
-- 7 Configuration port 1

begin

  -- GEN_COMMANDS_0: if G_PORT_NB = 0 generate
    command_in  <= x"00" ;
    command_out <= x"02" ;
    command_dir <= x"06" ;
  -- end generate;

  -- GEN_COMMANDS_1: if G_PORT_NB = 1 generate
    -- command_in  <= x"01" ;
    -- command_out <= x"03" ;
    -- command_dir <= x"07" ;
  -- end generate;

  process(pi_clock, pi_reset) is
  begin
    if pi_reset = '1' then
      state         <= 0;
      po_req        <= '0';
      po_data_width <= (others => '0');
      po_data       <= (others => '0');
      po_wr         <= '0';
      po_str        <= '0';
      po_gpo_done   <= '0';
    elsif rising_edge(pi_clock) then

      po_str <= '0';

      case state is

        when 0 =>
          po_data_width <= (others => '0');
          po_data       <= (others => '0');
          po_wr         <= '0';
          po_str        <= '0';
          po_req        <= '0';
          po_gpo_done   <= '1';
          state      <= 1;

        when 1 =>
          po_gpo_done  <= '0';
          if pi_str = '1' then
            data_out    <= pi_gpo(7 downto 0) & pi_gpo(15 downto 8);
            data_dir    <= pi_gpo_dir(7 downto 0) & pi_gpo_dir(15 downto 8);
            po_req         <= '1';
            state       <= 2;
            -- next_state <= 4;
          end if;

        when 2 =>
          if pi_grant = '1' then
            state      <= 4;
          end if;

        when 3 =>
          po_str <= '0';
          if pi_done = '1' then
            state <= next_state;
          end if;

        when 4 => -- set dir
          po_wr         <= '1';
          po_data(23 downto 0) <= command_dir & data_dir;
          po_data_width <= "10";
          po_str        <= '1';
          state      <= 3;
          if data_dir = x"FFFF" then -- If all ports are inputs skip setting output register state
            next_state <= 6;
          else
            next_state <= 5;
          end if;

        when 5 => -- set output register
          po_wr         <= '1';
          po_data(23 downto 0) <= command_out & data_out;
          po_data_width <= "10";
          po_str        <= '1';
          state      <= 3;
          if data_dir = x"0000" then -- If all ports are outputs skip reading input register state
            next_state <= 0;
          else
            next_state <= 6;
          end if;

        when 6 => -- Point to input register
          po_wr <= '1';
          po_data(7 downto 0) <= command_in;
          po_data_width <= "00";
          po_str <= '1';
          state <= 3;
          next_state <= 7;

        when 7 => -- Read the input register
          po_wr <= '0';
          po_data_width <= "01";
          po_str <= '1';
          state <= 8;

        when 8 =>
          po_str <=  '0';
          if pi_done = '1' then
            po_wr <= '0';
            state <= 0;
          end if;

        when others =>
          state <= 0;

      end case;

      if pi_dry = '1' then
        po_gpo <= pi_data(7 downto 0) & pi_data(15 downto 8);
      end if;
      
    end if;
  end process;

end architecture beh;
