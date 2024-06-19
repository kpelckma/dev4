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
--! @date 2021.10.25
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief PRBS generator/checker
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity prbs is
  generic (
    G_WIDTH   : natural := 8; --! data width
    G_INVERT  : natural := 0; --! 1: inverted pattern
    G_MODE    : natural := 0; --! 0: generator, 1: checker
    G_ORDER   : natural := 7; --! polynomial order
    G_TAB     : natural := 6  --! polynomial tab
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    po_ready  : out std_logic;  --! CAUTION: combinatorial path from inputs
    pi_valid  : in  std_logic;
    pi_data   : in  std_logic_vector(G_WIDTH-1 downto 0);

    pi_ready  : in  std_logic := '1';
    po_valid  : out std_logic;
    po_data   : out std_logic_vector(G_WIDTH-1 downto 0)
  );
end entity prbs;

architecture rtl of prbs is

  type prbs_vector is array (G_WIDTH downto 0) of std_logic_vector(1 to G_ORDER);

  signal prbs : prbs_vector := (others => (others => '1'));
  signal seed : std_logic_vector(G_WIDTH downto 1);
  signal data : std_logic_vector(G_WIDTH-1 downto 0);

  signal o_valid  : std_logic; 
  signal i_data   : std_logic_vector(G_WIDTH-1 downto 0);

begin

  i_data <= not(pi_data) when G_INVERT = 1 else pi_data;

  gen_vector: for I in 0 to G_WIDTH-1 generate
    data(I) <= prbs(I)(G_TAB) xor prbs(I)(G_ORDER);
    seed(I+1) <= data(I) when G_MODE = 0 else i_data(I);
    prbs(I+1) <= seed(I+1) & prbs(I)(1 to G_ORDER-1);
  end generate gen_vector;

  prs_prbs: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        prbs(0)   <= (others => '1');
        po_data   <= (others => '1');
      elsif pi_valid = '1' and pi_ready = '1' then
        prbs(0)   <= prbs(G_WIDTH);
        po_data   <= data xor i_data;
      end if;
    end if;
  end process prs_prbs;

  o_valid <=  not pi_reset and (
              (pi_valid and pi_ready) or
              (pi_valid and o_valid) or
              (not pi_ready and o_valid)
              ) when rising_edge(pi_clock);

  po_valid <= o_valid;
  po_ready <= not pi_reset and pi_ready;
              
end architecture rtl;

