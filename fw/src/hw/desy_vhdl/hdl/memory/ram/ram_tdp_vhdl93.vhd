--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2022-01-25
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief True Dual Port Random Access Memory
--!
--! Architecture is based on deprecated shared variables of IEEE Std 1076-1993
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_tdp is
  generic (
    G_MODE  : integer := 1; --! 1: write first / 2: read first / 3: no change
    G_ADDR  : integer := 10;
    G_DATA  : integer := 4
  );
  port (
    pi_clk_a  : in  std_logic;
    pi_en_a   : in  std_logic;
    pi_we_a   : in  std_logic;
    pi_addr_a : in  std_logic_vector(G_ADDR-1 downto 0);
    pi_data_a : in  std_logic_vector(G_DATA-1 downto 0);
    po_data_a : out std_logic_vector(G_DATA-1 downto 0);

    pi_clk_b  : in  std_logic;
    pi_en_b   : in  std_logic;
    pi_we_b   : in  std_logic;
    pi_addr_b : in  std_logic_vector(G_ADDR-1 downto 0);
    pi_data_b : in  std_logic_vector(G_DATA-1 downto 0);
    po_data_b : out std_logic_vector(G_DATA-1 downto 0)
  );
end entity ram_tdp;

architecture vhdl93 of ram_tdp is

  type t_memory is array (0 to 2**G_ADDR-1) of std_logic_vector(G_DATA-1 downto 0);
  shared variable memory : t_memory := (others => (others => '0'));

begin

  prs_port_a: process(pi_clk_a)
  begin
    if rising_edge(pi_clk_a) then
      if pi_en_a = '1' then
        if G_MODE = 3 then
          if pi_we_a = '0' then
            po_data_a <= memory(to_integer(unsigned(pi_addr_a)));
          end if;
        elsif G_MODE = 2 then
          po_data_a <= memory(to_integer(unsigned(pi_addr_a)));
        end if;
        if pi_we_a = '1' then
          memory(to_integer(unsigned(pi_addr_a))) := pi_data_a;
        end if;
        if G_MODE = 1 then
          po_data_a <= memory(to_integer(unsigned(pi_addr_a)));
        end if;
      end if;
    end if;
  end process prs_port_a;

  prs_port_b: process(pi_clk_b)
  begin
    if rising_edge(pi_clk_b) then
      if pi_en_b = '1' then
        if G_MODE = 3 then
          if pi_we_b = '0' then
            po_data_b <= memory(to_integer(unsigned(pi_addr_b)));
          end if;
        elsif G_MODE = 2 then
          po_data_b <= memory(to_integer(unsigned(pi_addr_b)));
        end if;
        if pi_we_b = '1' then
          memory(to_integer(unsigned(pi_addr_b))) := pi_data_b;
        end if;
        if G_MODE = 1 then
          po_data_b <= memory(to_integer(unsigned(pi_addr_b)));
        end if;
      end if;
    end if;
  end process prs_port_b;

end architecture vhdl93;

