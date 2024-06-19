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
--! @date 2022-02-08
--! @author Radoslaw Rybaniec
------------------------------------------------------------------------------
--! @brief
--! 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity fifo_dpram is
  generic (
    --  G_ADDR_WIDTH : positive := 16; -- data bus width
    GEN_DATA_WIDTH : positive := 16;   -- data bus width
    GEN_SIZE       : positive := 2048  -- number of words
  );
  port (
    pi_rd_clk  : in  std_logic;
    pi_rd_addr : in  std_logic_vector(integer(ceil(log2(real(GEN_SIZE))))-1 downto 0) := (others => '0');
    po_rd_data : out std_logic_vector(GEN_DATA_WIDTH-1 downto 0);
  
    pi_wr_clk : in std_logic;
    pi_wr_ena : in std_logic := '0';
  
    pi_wr_addr : in std_logic_vector (integer(ceil(log2(real(GEN_SIZE))))-1 downto 0);
    pi_wr_data : in std_logic_vector (GEN_DATA_WIDTH-1 downto 0) := (others => '0')
);
end fifo_dpram;

architecture Behavioral of fifo_dpram is
  type ram_type is array (GEN_SIZE-1 downto 0) of std_logic_vector (GEN_DATA_WIDTH-1 downto 0);
  signal ram : ram_type := ( others => ( others => '0' ) ) ;
begin
  
  process(pi_wr_clk)
  begin
    if pi_wr_clk'event and pi_wr_clk = '1' then
      if pi_wr_ena = '1' then
        ram(conv_integer(pi_wr_addr)) <= pi_wr_data;
      end if;
    end if;
  end process;

  --process(pi_rd_clk)
  --begin
 --   if pi_rd_clk'event and pi_rd_clk = '1' then
      po_rd_data <= ram(conv_integer(pi_rd_addr));
--    end if;
--  end process;
  
end Behavioral;

