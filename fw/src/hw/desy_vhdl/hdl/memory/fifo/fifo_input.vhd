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
--! FIFO input circuit,
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity fifo_input is
  generic (
    G_IN_WIDTH   : positive := 16;                              -- Input port WIDTH
    G_FIFO_WIDTH : positive := 32                               -- FIFO MEM WIDTH
  );                                                            -- First Word Fall Througth
  port (
    pi_reset  : in  std_logic;                                  -- async reset
    pi_wr_clk : in  std_logic;                                  -- write clock
    pi_data   : in  std_logic_vector(G_IN_WIDTH-1 downto 0);    -- write port
    pi_wr_ena : in  std_logic;                                  -- write request
    pi_full   : in  std_logic;                                  -- FIFO full
    po_wr_ena : out std_logic;                                  -- write request
    po_data   : out std_logic_vector(G_FIFO_WIDTH-1 downto 0);  -- read port
    po_full   : out std_logic
 );

end entity fifo_input;

architecture rtl of fifo_input is

  constant C_N : positive := G_FIFO_WIDTH/G_IN_WIDTH;

  signal reg_input   : std_logic_vector(G_IN_WIDTH*C_N-1 downto 0);
  signal cntr        : std_logic_vector(C_N-1 downto 0) := std_logic_vector(to_unsigned(1, C_N));
  signal cntr_ena    : std_logic;
  signal o_full      : std_logic;
  signal o_full_next : std_logic;

  type t_states is (ST_NFULL,ST_FULL);
  signal state, state_next : t_states;

begin
 
  po_full <= o_full;

  process (pi_wr_clk, pi_reset) is
  begin
    if pi_reset = '1' then -- asynchronous reset (active high)
      cntr <= (others => '0');
      cntr(0) <= '1';
      state <= ST_NFULL;
      o_full <= '0';
    elsif pi_wr_clk'event and pi_wr_clk = '1' then
      state <= state_next;
      o_full <= o_full_next;

      if cntr_ena = '1' then
        cntr(0) <= cntr(cntr'left);
        
        for I in 2 to C_N loop
          reg_input(I*(G_IN_WIDTH)-1 downto (I-1)*(G_IN_WIDTH)) <=
            reg_input((I-1)*(G_IN_WIDTH)-1 downto (I-2)*(G_IN_WIDTH));
        end loop;
        
        for I in 2 to C_N loop
          cntr(I-1) <= cntr(I-2);
        end loop;

        
        reg_input(G_IN_WIDTH-1 downto 0) <= pi_data;
      end if;   
    end if;
  end process;

  process (pi_full, reg_input, reg_input, state,
           cntr, pi_wr_ena, pi_data) is
  begin

    o_full_next <= '0';
    state_next <= state;
    cntr_ena <= '0';

    if pi_wr_ena = '1' then
      cntr_ena <= '1';
    end if;
    po_wr_ena <= '0';

    case state is

      when ST_NFULL =>
        po_data <= reg_input((C_N-1)*G_IN_WIDTH-1 downto (0)*G_IN_WIDTH) & pi_data;
        if cntr(cntr'left) = '1' and pi_wr_ena = '1' then
          if pi_full = '0' then
            po_wr_ena <= '1';
          else
            state_next <= ST_FULL;
            o_full_next <= '1';
          end if;
        end if;  

      when ST_FULL =>
        po_data <= reg_input((C_N)*G_IN_WIDTH-1 downto (0)*G_IN_WIDTH);
        if pi_full = '1' then
          cntr_ena <= '0';
          o_full_next <= '1';
        else
          po_wr_ena <= '1';
          state_next <= ST_NFULL;
        end if;

      when others => null;

    end case;

  end process;

end architecture;
