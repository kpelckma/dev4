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
-- @date 2021-11-10
-- @author  Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
-- @brief
-- DAC controll using I2C controller
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity ltc2607 is
  port (
    pi_clock : in  std_logic;
    pi_reset : in  std_logic;

    -- arbiter interface
    po_req   : out std_logic;
    pi_grant : in  std_logic;

    -- i2c_controler interface
    po_str        : out std_logic;
    po_wr         : out std_logic;
    po_data_width : out std_logic_vector(1 downto 0);
    po_data       : out std_logic_vector(31 downto 0);
    pi_data       : in  std_logic_vector(31 downto 0);
    po_addr       : out std_logic_vector(6 downto 0);
    pi_done       : in  std_logic;

    pi_daca_data    : in  std_logic_vector(15 downto 0) := (others => '0');  -- dac a
    pi_daca_str     : in  std_logic                     := '0';              -- dac a strobe
    pi_dacb_data    : in  std_logic_vector(15 downto 0) := (others => '0');  -- dac b
    pi_dacb_str     : in  std_logic                     := '0';              -- dac b strobe
    pi_dacab_data   : in  std_logic_vector(15 downto 0) := (others => '0');  -- dac all outputs
    pi_dacab_str    : in  std_logic                     := '0';              -- dac all strobe
    pi_dac_raw_data : in  std_logic_vector(23 downto 0) := (others => '0');  -- dac raw data interface
    pi_dac_raw_str  : in  std_logic                     := '0';              -- dac raw strobe
    po_dac_strobed  : out std_logic                     := '0';              -- notification of the first strobe
    po_dac_busy     : out std_logic_vector(3 downto 0); -- dac done status register, 0 when command executed

    pi_sci_sdi_fix  : in  std_logic                     := '0' -- swap clk and data lines
  );
end entity ltc2607;

architecture rtl of ltc2607 is

  signal state           : natural := 0;
  signal reg_act_chan    : natural := 0;
  signal reg_dac_strobes : std_logic_vector(1 to 4) := (others => '0');
  signal reg_data        : std_logic_vector(23 downto 0);
  signal reg_data_out    : std_logic_vector(23 downto 0);

begin

  po_dac_busy <= reg_dac_strobes;

  process (pi_clock, pi_reset) is
  begin
    if pi_reset = '1' then
      state         <= 0;
      po_req        <= '0';
      po_data_width <= (others => '0');
      po_data       <= (others => '0');
      po_wr         <= '0';
      po_str        <= '0';

    elsif rising_edge(pi_clock) then

      if pi_daca_str = '1' then
        reg_dac_strobes(1) <= '1';
        po_dac_strobed    <= '1';
      end if;
      if pi_dacb_str = '1' then
        reg_dac_strobes(2) <= '1';
        po_dac_strobed    <= '1';
      end if;
      if pi_dacab_str = '1' then
        reg_dac_strobes(3) <= '1';
        po_dac_strobed    <= '1';
      end if;
      if pi_dac_raw_str = '1' then
        reg_dac_strobes(4) <= '1';
        po_dac_strobed    <= '1';
      end if;

      po_str <= '0';

      case state is

        when 0 =>
          po_data_width <= (others => '0');
          po_data       <= (others => '0');
          po_wr         <= '0';
          po_str        <= '0';
          po_req        <= '0';
          state         <= 1;

        when 1 =>

          if or_reduce(reg_dac_strobes) = '1' then
            if reg_dac_strobes(1) = '1' then
              reg_act_chan <= 1;
              reg_data_out <= x"30" & pi_daca_data;
            elsif reg_dac_strobes(2) = '1' then
              reg_act_chan <= 2;
              reg_data_out    <= x"31" & pi_dacb_data;
            elsif reg_dac_strobes(3) = '1' then
              reg_act_chan    <= 3;
              reg_data_out    <= x"3f" & pi_dacab_data;
            elsif reg_dac_strobes(4) = '1' then
              reg_act_chan <= 4;
              reg_data_out <= pi_dac_raw_data;
            end if;
            po_req <= '1';
            state  <= 2;
          end if;

        when 2 =>
          if pi_grant = '1' then
            state      <= 3;
          end if;

        when 3 => -- set dir
          po_wr         <= '1';
          po_data(23 downto 0) <= reg_data_out;
          po_data_width <= "10";
          po_str        <= '1';
          state      <= 4;

        when 4 =>
          po_str <= '0';
          if pi_done = '1' then
            reg_dac_strobes(reg_act_chan) <= '0';
            state   <= 0;
          end if;

        when others =>
          state <= 0;

      end case;
    end if;
  end process;
end architecture rtl;
