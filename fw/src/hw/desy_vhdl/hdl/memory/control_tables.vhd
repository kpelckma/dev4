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
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Has double buffering feature using 2x DPM 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library desy;
use work.common_types.all;

entity control_tables is
generic (
  G_DSP_WIDTH            : natural := 18;
  G_TABLE_ADDR_WIDTH     : natural := 11;
  G_TABLE_CNT            : natural := 6;
  G_TABLE_DOUBLE_BUF_ENA : natural := 1
) ;
port (
  pi_clock : in std_logic;
  
  -- Port A
  pi_table_a_data : in  std_logic_vector(G_DSP_WIDTH-1 downto 0);
  po_table_a_data : out std_logic_vector(G_DSP_WIDTH-1 downto 0);
  pi_table_a_addr : in  std_logic_vector(G_TABLE_ADDR_WIDTH-1 downto 0);
  pi_table_a_wr   : in  std_logic_vector(G_TABLE_CNT-1 downto 0); -- 1 -> Write 0 -> Read
  pi_table_a_ena  : in  std_logic_vector(G_TABLE_CNT-1 downto 0);
  
  pi_table_swap   : in  std_logic_vector(G_TABLE_CNT-1 downto 0);

  -- Port B
  pi_table_b_str  : in  std_logic_vector(G_TABLE_CNT-1 downto 0);
  pi_table_b_addr : in  std_logic_vector(G_TABLE_CNT*G_TABLE_ADDR_WIDTH-1 downto 0);
  po_table_b_done : out std_logic_vector(G_TABLE_CNT-1 downto 0);
  po_table_b_data : out t_18b_slv_vector(G_TABLE_CNT-1 downto 0)
);
end control_tables;

architecture arch of control_tables is

  signal mux_ctl      : natural;
  signal data_m       : t_18b_slv_vector(G_TABLE_CNT-1 downto 0);
  signal data_b       : t_18b_slv_vector(G_TABLE_CNT-1 downto 0);
  signal table_data_m : t_18b_slv_vector(G_TABLE_CNT-1 downto 0);
  signal table_data_b : t_18b_slv_vector(G_TABLE_CNT-1 downto 0);
  signal done         : std_logic_vector(G_TABLE_CNT-1 downto 0);
  signal port_b_ena_m : std_logic_vector(G_TABLE_CNT-1 downto 0);
  signal port_b_ena_b : std_logic_vector(G_TABLE_CNT-1 downto 0);
  signal port_b_addr  : std_logic_vector(G_TABLE_CNT*G_TABLE_ADDR_WIDTH-1 downto 0);
  
begin
  
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      for i in 0 to G_TABLE_CNT-1 loop
        if pi_table_a_ena(i) = '1' then 
          mux_ctl <= i; 
        end if;
      end loop;
    end if;
  end process;

  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_table_swap(mux_ctl) = '0' and G_TABLE_DOUBLE_BUF_ENA = 1 then
        po_table_a_data <= data_b(mux_ctl);
      else 
        po_table_a_data <= data_m(mux_ctl);
      end if;
    end if;
  end process;
  
  -- po_table_a_data <= data_b(mux_ctl) when (pi_table_swap(mux_ctl) = '0' and G_TABLE_DOUBLE_BUF_ENA = 1) else data_m(mux_ctl);

  port_b_ena_m <= pi_table_b_str;
  port_b_ena_b <= pi_table_b_str;
  port_b_addr  <= pi_table_b_addr;

  -- main tables
  GEN_MEM : for i in 0 to G_TABLE_CNT-1 generate
    signal l_ena_m : std_logic;
    signal l_ena_b : std_logic;
    
    signal l_wr : std_logic;
    signal l_rd : std_logic;
    signal l_dummy : std_logic_vector(G_DSP_WIDTH-1 downto 0);
  begin

    proc_done : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        done(i) <= pi_table_b_str(i);
        po_table_b_done(i) <= done(i);
      end if;
    end process;
  
    process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_table_swap(i) = '0' and G_TABLE_DOUBLE_BUF_ENA = 1 then
          po_table_b_data(i) <= table_data_b(i);
        else 
          po_table_b_data(i) <= table_data_m(i);
        end if;
      end if;
    end process;
    
    l_wr <= '1' when pi_table_a_ena(I) = '1' and G_TABLE_DOUBLE_BUF_ENA = 1 and pi_table_a_wr(i) = '1' else '0';
    l_rd <= '1' when pi_table_a_ena(I) = '1' and G_TABLE_DOUBLE_BUF_ENA = 1 and pi_table_a_wr(i) = '0' else '0';

    l_ena_m <= '1' when (l_wr = '1' and pi_table_swap(I) = '0') or (l_rd = '1' and pi_table_swap(I) = '1') else '0';
    l_ena_b <= '1' when (l_wr = '1' and pi_table_swap(I) = '1') or (l_rd = '1' and pi_table_swap(I) = '0') else '0';

    ins_mem1 : entity desy.dual_port_memory
    generic map (
      G_DATA_WIDTH => G_DSP_WIDTH,
      G_ADDR_WIDTH => G_TABLE_ADDR_WIDTH
    )
    port map(
      pi_clk_a  => pi_clock,
      pi_ena_a  => l_ena_m,
      pi_wr_a   => pi_table_a_wr(i),
      pi_addr_a => pi_table_a_addr,
      pi_data_a => pi_table_a_data,
      po_data_a => data_m(I),

      pi_clk_b  => pi_clock,
      pi_ena_b  => port_b_ena_m(I),
      pi_addr_b => port_b_addr((I+1)*G_TABLE_ADDR_WIDTH-1 downto I*G_TABLE_ADDR_WIDTH),
      po_data_b => table_data_m(I),
      pi_wr_b   => '0' ,
      pi_data_b => l_dummy
    );

    gen_dbl : if G_TABLE_DOUBLE_BUF_ENA = 1 generate
    begin
      ins_mem2 : entity desy.dual_port_memory
      generic map(
        G_DATA_WIDTH => G_DSP_WIDTH,
        G_ADDR_WIDTH => G_TABLE_ADDR_WIDTH
      )
      port map(
        pi_clk_a  => pi_clock,
        pi_ena_a  => l_ena_b,
        pi_wr_a   => pi_table_a_wr(i),
        pi_addr_a => pi_table_a_addr,
        pi_data_a => pi_table_a_data,
        po_data_a => data_b(i),

        pi_clk_b  => pi_clock,
        pi_ena_b  => port_b_ena_b(i),
        pi_addr_b => port_b_addr( (i+1)*G_TABLE_ADDR_WIDTH - 1 downto i*G_TABLE_ADDR_WIDTH),
        po_data_b => table_data_b(i),
        pi_wr_b   => '0', 
        pi_data_b => l_dummy
      );
    end generate;
    
  end generate;
  
end arch;


