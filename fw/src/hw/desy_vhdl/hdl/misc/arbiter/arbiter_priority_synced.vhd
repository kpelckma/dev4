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
--!
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use ieee.std_logic_misc.all;

entity arbiter_priority_synced is
  generic (
    G_REQUESTER : positive := 4   -- Number of requester
  );
  port (
    pi_clock : in    std_logic;
    pi_reset : in    std_logic;
    pi_req   : in    std_logic_vector(G_REQUESTER - 1 downto 0);
    po_grant : out   std_logic_vector(G_REQUESTER - 1 downto 0)
  );
end entity arbiter_priority_synced;

------------------------------------------------------------------------------

architecture simple of arbiter_priority_synced is

  signal reg_grant : std_logic_vector(G_REQUESTER - 1 downto 0) := (others => '0');

begin

  po_grant <= reg_grant;

  prs_grant : process (pi_clock, pi_reset) is
  begin

    if (pi_reset = '1') then
      reg_grant <= (others => '0');
    elsif rising_edge(pi_clock) then
      if (or_reduce(pi_req and reg_grant) = '0') then
        reg_grant <= (others => '0');

        for i in G_REQUESTER - 1 downto 0 loop

          if (pi_req(i) = '1') then
            reg_grant    <= (others => '0');
            reg_grant(i) <= '1';
          end if;

        end loop;

      end if;
    end if;

  end process prs_grant;

end architecture simple;
