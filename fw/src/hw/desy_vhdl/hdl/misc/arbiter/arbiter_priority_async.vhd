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
--! @date 2021-09-14
--! @author MSK Firmware Team
------------------------------------------------------------------------------
--! @brief
--! Simple Synchronous arbiter
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity priority_arbiter is
  generic
  (
    n : positive := 4
  );
  port
  (
    req   : in  std_logic_vector(n-1 downto 0);
    grant : out std_logic_vector(n-1 downto 0)
  );
end priority_arbiter;

architecture simple of ent_priority_arbiter is
  constant zeros   : std_logic_vector(n-1 downto 0) := (others => '0');
  signal   s_grant : std_logic_vector(n-1 downto 0);
begin
  grant <= s_grant;

  process(req, s_grant)
  begin
    if (req and s_grant) = zeros then
      s_grant <= (others => '0');
      for i in n-1 downto 0 loop
        if req(i) = '1' then
          s_grant    <= (others => '0');
          s_grant(i) <= '1';
        end if;
      end loop;
    end if;
  end process;
end simple;
