-----------------------------------------------------------------------------
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
-- @date
-- @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
-- @brief PCA9535 is an IO expander chip. It is used mostly on RTM cards
-- This entity needs an i2c_controller from desy_vhdl library to work.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity pca9535 is
generic(
  G_PORT_NB : natural := 0
);
port (
  pi_clock      : in  std_logic;
  pi_reset      : in  std_logic;
  -- gpio interface
  pi_str        : in  std_logic;
  pi_gpo        : in  std_logic_vector(7 downto 0); -- general purpose output
  po_gpo        : out std_logic_vector(7 downto 0); -- general purpose input
  pi_gpo_dir    : in  std_logic_vector(7 downto 0); -- general purpose direction 1=> Input 0=> Output
  po_gpo_done   : out std_logic;

  -- arbiter interface
  po_req        : out std_logic;
  pi_grant      : in  std_logic := '1';
  -- i2c_controler interface
  po_str        : out std_logic;
  po_wr         : out std_logic;
  po_data_width : out std_logic_vector(1 downto 0);
  po_data       : out std_logic_vector(31 downto 0);
  pi_data       : in  std_logic_vector(31 downto 0);
  pi_dry        : in std_logic := '0';
  pi_done       : in  std_logic
  );
end entity pca9535;

architecture beh of pca9535 is

  signal state      : natural := 0;
  signal next_state : natural := 0;

  signal reg_data_out : std_logic_vector(7 downto 0);
  signal reg_data_dir : std_logic_vector(7 downto 0);

  signal reg_comand_in  : std_logic_vector(7 downto 0);
  signal reg_comand_out : std_logic_vector(7 downto 0);
  signal reg_comand_dir : std_logic_vector(7 downto 0);

  -- command register
  -- 0 input port 0
  -- 1 input port 1
  -- 2 output port 0
  -- 3 output port 1
  -- 4 polarity inversion port 0
  -- 5 polarity inversion port 1
  -- 6 configuration port 0
  -- 7 configuration port 1

begin

  gen_commands_0: if G_PORT_NB = 0 generate
    reg_comand_in  <= x"00" ;
    reg_comand_out <= x"02" ;
    reg_comand_dir <= x"06" ;
  end generate;

  gen_commands_1: if G_PORT_NB = 1 generate
    reg_comand_in  <= x"01" ;
    reg_comand_out <= x"03" ;
    reg_comand_dir <= x"07" ;
  end generate;

  process (pi_clock, pi_reset) is
  begin
    if pi_reset = '1' then -- asynchronous reset (Is this really necessary?)
      state         <= 0;
      po_req        <= '0';
      po_data_width <= (others => '0');
      po_data       <= (others => '0');
      po_wr         <= '0';
      po_str        <= '0';
      po_gpo_done   <= '0';

    elsif rising_edge(pi_clock) then  -- rising clock edge

      po_str <= '0';

      case state is

        when 0 =>
          po_data_width <= (others => '0');
          po_data       <= (others => '0');
          po_wr         <= '0';
          po_str        <= '0';
          po_req        <= '0';
          po_gpo_done   <= '1';
          state         <= 1;

        when 1 =>
          po_gpo_done <= '0';
          if pi_str = '1' then
            reg_data_out <= pi_gpo;
            reg_data_dir <= pi_gpo_dir;
            po_req <= '1';
            state <= 2;
            -- next_state <= 4;
          end if;

        when 2 =>
          if pi_grant = '1' then
            state <= 4;
          end if;

        when 3 =>
          po_str <= '0';
          if pi_done = '1' then
            state <= next_state;
          end if;

        when 4 => -- set dir
          po_wr <= '1';
          po_data(15 downto 0) <= reg_comand_dir & reg_data_dir;
          po_data_width <= "01";
          po_str <= '1';
          state <= 3;
          if reg_data_dir = x"ff" then
            next_state <= 6;
          else
            next_state <= 5;
          end if;

        when 5 => -- set out
          po_wr <= '1';
          po_data(15 downto 0) <= reg_comand_out & reg_data_out;
          po_data_width <= "01";
          po_str <= '1';
          state <= 3;
          if reg_data_dir = x"00" then
            next_state <= 0;
          else
            next_state <= 6;
          end if;

        when 6 => -- set in reg
          po_wr <= '1';
          po_data(7 downto 0) <= reg_comand_in;
          po_data_width <= "00";
          po_str <= '1';
          state <= 3;
          next_state <= 7;

        when 7 => -- get in reg
          po_wr         <= '0';
          po_data_width <= "00";
          po_str        <= '1';
          state         <= 8;

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
        po_gpo <= pi_data(7 downto 0);
      end if;

    end if;
  end process;

end architecture beh;
