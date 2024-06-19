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
--! @brief Cross Clock Domain flag
--! @author Andrea Bellandi <andrea.bellandi@desy.de>
--! @created 2022-09-28
-------------------------------------------------------------------------------
--! Description:
--! Cross Clock Domain flag. It synchronizes a single bit 'flag' signal a clock domain
--! 'A' in a clock domain 'B'. The entity uses the 'toggle' method
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all;

--! Clock domain crossing. This entity moves a single cycle 'valid' flag from
--! one clock domain to another. An optional data port synchronized with the
--! flag is available.
entity cdc_flag is
  generic (
    G_WIDTH : natural
  );
  port (
    pi_a_clk  : in    std_logic;
    pi_b_clk  : in    std_logic;
    pi_a_flag : in    std_logic;
    po_b_flag : out   std_logic;
    pi_a_data : in    std_logic_vector(G_WIDTH - 1 downto 0);
    po_b_data : out   std_logic_vector(G_WIDTH - 1 downto 0)
  );
end entity cdc_flag;

architecture arch of cdc_flag is

  signal reg_toggle_a : std_logic := '0';
  signal reg_edge_b   : std_logic := '0';
  signal reg_data_a   : std_logic_vector(G_WIDTH - 1 downto 0);
  signal reg_data_b   : std_logic_vector(G_WIDTH - 1 downto 0);
  signal reg_out_data : std_logic_vector(G_WIDTH - 1 downto 0);
  signal reg_out_flag : std_logic;
  signal l_a_value    : std_logic_vector(G_WIDTH downto 0);
  signal l_b_value    : std_logic_vector(G_WIDTH downto 0);

begin

  prs_cd_a : process (pi_a_clk) is
  begin

    if rising_edge(pi_a_clk) then
      if (pi_a_flag = '1') then
        reg_toggle_a <= not reg_toggle_a;
      end if;
      reg_data_a <= pi_a_data;
    end if;

  end process prs_cd_a;

  prs_cd_b : process (pi_b_clk) is
  begin

    if rising_edge(pi_b_clk) then
      reg_out_flag <= reg_edge_b xor l_b_value(0);
      reg_out_data <= reg_data_b;

      reg_edge_b <= l_b_value(G_WIDTH);
      reg_data_b <= l_b_value(G_WIDTH - 1 downto 0);
    end if;

  end process prs_cd_b;

  ins_cdc_synch : entity work.cdc_synch
    generic map (
      G_WIDTH => 1 + G_WIDTH
    )
    port map (
      pi_b_clk => pi_b_clk,
      pi_a_cdc => l_a_value,
      po_b_cdc => l_b_value
    );

  l_a_value(G_WIDTH)              <= reg_toggle_a;
  l_a_value(G_WIDTH - 1 downto 0) <= reg_data_a;

  po_b_flag <= reg_out_flag;
  po_b_data <= reg_out_data;

end architecture arch;
