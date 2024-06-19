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
--! @brief Cross Clock Domain synchronizer
--! @author Andrea Bellandi <andrea.bellandi@desy.de>
--! @created 2022-09-28
-------------------------------------------------------------------------------
--! Description:
--! Cross Clock Domain synchronizer. It synchronizes a signal of a clock domain
--! 'A' in a clock domain 'B' using double registers
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--! Clock domain crossing. Moves a data vector from one clock domain to another.
entity cdc_synch is
  generic (
    G_WIDTH : natural
  );
  port (
    pi_b_clk : in    std_logic;                              -- destination clock domain B
    pi_a_cdc : in    std_logic_vector(G_WIDTH - 1 downto 0); -- data in CD A
    po_b_cdc : out   std_logic_vector(G_WIDTH - 1 downto 0)  -- data in CD B
  );
end entity cdc_synch;

architecture arch of cdc_synch is

  signal reg_stable     : std_logic_vector(G_WIDTH - 1 downto 0);
  signal reg_metastable : std_logic_vector(G_WIDTH - 1 downto 0);

  attribute async_reg : string;
  attribute async_reg of reg_metastable : signal is "TRUE";
  attribute async_reg of reg_stable : signal is "TRUE";

begin

  prs_cc_registers : process (pi_b_clk) is
  begin

    if rising_edge(pi_b_clk) then

     reg_stable     <= reg_metastable;
     reg_metastable <= pi_a_cdc;

    end if;

  end process prs_cc_registers;

  po_b_cdc <= reg_stable;

end architecture arch;
