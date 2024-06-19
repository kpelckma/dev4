-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
-------------------------------------------------------------------------------
--! @date 2018-10-08/2022-01-12
--! @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
--! @author Shweta Prasad <shweta.prasad@desy.de>
-------------------------------------------------------------------------------
--! @brief
--! Implementation of dual port memory with port A as read first
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_port_memory is
  generic (
    G_DATA_WIDTH : natural;
    G_ADDR_WIDTH : natural
  ) ;
  port (
    pi_clk_a  : in  std_logic;
    pi_ena_a  : in  std_logic;
    pi_wr_a   : in  std_logic;
    pi_addr_a : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    pi_data_a : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    po_data_a : out std_logic_vector(G_DATA_WIDTH-1 downto 0);

    pi_clk_b  : in  std_logic;
    pi_ena_b  : in  std_logic;
    pi_wr_b   : in  std_logic;
    pi_addr_b : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    pi_data_b : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    po_data_b : out std_logic_vector(G_DATA_WIDTH-1 downto 0)
  ) ;
end dual_port_memory;

architecture behavioral of dual_port_memory is
  type   t_ram is array(2**G_ADDR_WIDTH-1 downto 0) of std_logic_vector(G_DATA_WIDTH-1 downto 0) ;
  shared variable ram_data : t_ram  := (others => (others => '0')) ;
begin

  prs_port_a : process (pi_clk_a)
  begin
    if rising_edge(pi_clk_a) then
      if pi_ena_a = '1' then
        po_data_a <= ram_data(to_integer(unsigned(pi_addr_a)));

        if pi_wr_a = '1' then
          ram_data(to_integer(unsigned(pi_addr_a))) := pi_data_a;
        end if;
      end if;
    end if;
  end process;

  prs_port_b : process (pi_clk_b)
  begin
    if rising_edge(pi_clk_b) then
      if pi_ena_b = '1' then
        po_data_b <= ram_data(to_integer(unsigned(pi_addr_b)));

        if pi_wr_b = '1' then
          ram_data(to_integer(unsigned(pi_addr_b))) := pi_data_b;
        end if;
      end if;
    end if;
  end process;

end behavioral;
