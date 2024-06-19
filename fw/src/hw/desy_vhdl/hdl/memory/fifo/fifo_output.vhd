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
--! FIFO output circuit
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity fifo_output is
  generic (
    G_OUT_WIDTH    : positive := 64;    -- Output port WIDTH
    G_FIFO_WIDTH   : positive := 256;   -- FIFO MEM WIDTH
    G_FIFO_FWFT    : natural  := 1      -- First Word Fall Througth
  );
  port (
    pi_reset    : in  std_logic;                                -- async reset
    pi_rd_clk : in  std_logic;                                  -- read clock
    pi_data   : in  std_logic_vector(G_FIFO_WIDTH-1 downto 0);  -- read port
    pi_rd_ena : in  std_logic;                                  -- read request
    pi_empty  : in  std_logic;                                  -- FIFO EMPTY
    po_rd_ena : out std_logic;                                  -- read request
    po_data   : out std_logic_vector(G_OUT_WIDTH-1 downto 0);   -- read port
    po_empty  : out std_logic
  );
end entity fifo_output;

architecture rtl of fifo_output is

  constant C_N : natural := G_OUT_WIDTH/G_FIFO_WIDTH;
  constant C_M : natural := G_FIFO_WIDTH/G_OUT_WIDTH;

  signal output_data   : std_logic_vector(G_FIFO_WIDTH-1 downto 0);
  signal output_empty  : std_logic;
  signal output_rd_ena : std_logic;

  signal o_empty : std_logic; --! same as po_empty signal
  signal data_fwft : std_logic_vector(G_OUT_WIDTH-1 downto 0); --! FWFT data
  
begin

  po_empty <= o_empty;
  
  output_data  <= pi_data;
  output_empty <= pi_empty;
  po_rd_ena       <= output_rd_ena;
  
  gen_demux : if C_N > 1 generate
    blk_out_demux : block is

      signal l_reg_output : std_logic_vector(G_FIFO_WIDTH*C_N-1 downto 0);
      signal l_reg_filled : std_logic_vector(C_N-1 downto 0);
      
    begin

      process (pi_rd_clk, pi_reset) is
      begin  
        if pi_reset = '1' then         
          l_reg_output <= (others => '0');
          l_reg_filled <= (others => '0');
        elsif pi_rd_clk'event and pi_rd_clk = '1' then  
          if output_rd_ena = '1' and output_empty = '0' then
            l_reg_output <= l_reg_output(l_reg_output'left-output_data'length downto 0) & output_data;
            l_reg_filled <= l_reg_filled(l_reg_filled'left-1 downto 0) & '1';                          
          end if;
          if and_reduce(l_reg_filled) = '1' and output_rd_ena = '1' then
            if output_empty = '1' then
              l_reg_filled <= (others => '0');
            else
              l_reg_filled(l_reg_filled'left downto 1) <= (others => '0');
              l_reg_filled(0) <= '1';
              l_reg_output(output_data'range) <= output_data;
            end if;
          end if;
        end if;
      end process;

      output_rd_ena <= (not and_reduce(l_reg_filled)) or (and_reduce(l_reg_filled) and pi_rd_ena);
      data_fwft     <= l_reg_output;
      o_empty       <= not and_reduce(l_reg_filled);
      
    end block blk_out_demux;
  end generate gen_demux;

  gen_no_demux : if C_N = 1 generate
    data_fwft     <= output_data;
    o_empty       <= output_empty;
    output_rd_ena <= pi_rd_ena;
  end generate gen_no_demux;

  gen_mux : if C_M > 1 generate
    blk_mux : block is
      type t_demux_state is (ST_EMPTY, ST_NEMPTY);
      signal l_reg_state  : t_demux_state;
      signal l_state_next : t_demux_state;
      signal l_reg_cntr   : std_logic_vector(C_M-2 downto 0);
      signal l_cntr_load  : std_logic;
      signal l_cntr_ena   : std_logic;
      signal l_reg_data   : std_logic_vector(G_FIFO_WIDTH-1 downto 0);
    begin

      data_fwft <= l_reg_data(C_M*G_OUT_WIDTH-1 downto (C_M-1)*G_OUT_WIDTH);

      proc_mux_seq : process (pi_rd_clk, pi_reset) is
      begin
        if pi_reset = '1' then
          l_reg_state <= ST_EMPTY;
          l_reg_data  <= (others => '0');
          l_reg_cntr  <= (others => '0');
        elsif rising_edge(pi_rd_clk) then
          l_reg_state <= l_state_next;
          if l_cntr_ena = '1' then
            for N in 1 to C_M-2 loop
              l_reg_cntr(N) <= l_reg_cntr(N-1);
            end loop;
            for N in 1 to C_M-1 loop
              l_reg_data((N+1)*G_OUT_WIDTH-1 downto N*G_OUT_WIDTH)
                <= l_reg_data(N*G_OUT_WIDTH-1 downto (N-1)*G_OUT_WIDTH);
            end loop;  -- N
            l_reg_cntr(0) <= '0';
          end if;
          if l_cntr_load = '1' then
            l_reg_cntr    <= (others => '0');
            l_reg_cntr(0) <= '1';
            l_reg_data    <= output_data;
          end if;
        end if;
      end process proc_mux_seq;

      proc_mux_comb : process(pi_rd_ena, l_reg_cntr, l_reg_state,
                             output_empty) is
      begin
        l_state_next  <= l_reg_state;
        l_cntr_load   <= '0';
        l_cntr_ena    <= '0';
        output_rd_ena <= '0';
        o_empty       <= '1';
        case l_reg_state is
          when ST_EMPTY =>
            if output_empty = '0' then
              l_state_next <= ST_NEMPTY;
              l_cntr_load  <= '1';
              output_rd_ena  <= '1';
            end if;
          when ST_NEMPTY =>
            if OR_REDUCE(l_reg_cntr) = '1' then
              o_empty <= '0';
              if pi_rd_ena = '1' then
                l_cntr_ena <= '1';
              end if;
            else
              if output_empty = '0' then
                o_empty <= '0';
                if pi_rd_ena = '1' then
                  l_cntr_load <= '1';
                  output_rd_ena <= '1';
                end if;
              else
                o_empty <= '0';
                if pi_rd_ena = '1' then
                  l_state_next <= ST_EMPTY;
                end if;
              end if;
            end if;
        end case;
      end process proc_mux_comb;
    end block blk_mux;
  end generate gen_mux;

  -- FWFT logic
  gen_fwft: if G_FIFO_FWFT /= 0 generate
    po_data <= data_fwft;
  end generate gen_fwft;

  gen_no_fwft: if G_FIFO_FWFT = 0 generate
    process (pi_rd_clk) is
    begin
      if pi_rd_clk'event and pi_rd_clk = '1' then
        if o_empty = '0' and pi_rd_ena = '1' then
          po_data <= data_fwft;
        end if;
      end if;
    end process;
  end generate gen_no_fwft;
  
end architecture;
