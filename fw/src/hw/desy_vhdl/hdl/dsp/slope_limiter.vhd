-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- Copyright (c) 2020 DESY
-------------------------------------------------------------------------------
--! @brief   slope limiter
--! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
--! @created 2020-12-02
-------------------------------------------------------------------------------
--! Description:
--! limits maximum slope between two consecutive samples
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_basic.all;

entity slope_limiter is
  generic(
    G_DATA_WIDTH : natural := 18
  );
  port (
    -- clock
    pi_clock : in std_logic;
    -- CTRL
    pi_enable : in std_logic;
    pi_limit  : in std_logic_vector(G_DATA_WIDTH-1 downto 0);
    -- IN
    pi_valid : in std_logic;
    pi_data  : in std_logic_vector(G_DATA_WIDTH-1 downto 0);
    -- OUT
    po_valid : out std_logic;
    po_data  : out std_logic_vector(G_DATA_WIDTH-1 downto 0)
  );
end entity slope_limiter;

architecture arch of slope_limiter is
  signal data_prev  : std_logic_vector(G_DATA_WIDTH-1 downto 0) := (others=>'0');
  signal data_diff  : std_logic_vector(G_DATA_WIDTH-1 downto 0) := (others=>'0');
  signal data_valid : std_logic := '0';
begin

  data_diff <= u2vsub( pi_data, data_prev, G_DATA_WIDTH);

  -- purpose: main process
  prs_main: process (pi_clock) is
  begin
    if rising_edge(pi_clock) then
      if pi_enable = '0' then -- disable limit function
        data_prev  <= pi_data ;
        data_valid <= pi_valid ;

      elsif pi_valid = '1' then
        data_valid <= '1';
        -- if difference between previous and current sample is above limt
        if abs(signed(data_diff)) > signed(pi_limit) then
          if signed(data_diff) <= 0 then -- negative slope
            data_prev <= u2vsub(data_prev, pi_limit, G_DATA_WIDTH );
          else -- positive slope
            data_prev <= u2vsum(data_prev, pi_limit, G_DATA_WIDTH );
          end if;
        -- no limit
        else
          data_prev <= pi_data;
        end if;
      else
        data_valid <= '0';
      end if;
    end if;
  end process prs_main;

  po_valid <= data_valid;
  po_data  <= data_prev;

end architecture arch;

