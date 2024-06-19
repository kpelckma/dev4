-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- $Header$
-------------------------------------------------------------------------------
--! @file   control_tables.vhd
--! @brief  Control Tables
--! @author Lukasz Butkowski, Cagil Gumus
--! @email  lukasz.butkowski@desy.de
--! $Date$
--! $Revision$
--! $URL$
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library desy;
use desy.common_types.all;

--! BRAM-based control tables used to store trace data through the ii bus
entity control_tables is
  generic (
    G_DSP_WORD_WIDTH   : natural := 18; -- This cannot be changed. Because of t_18b_slv_vector
    G_ADDR_WIDTH       : natural := 11;
    G_CTL_TABLES_COUNT : natural := 6;
    G_CTL_TABLES_DBF   : natural := 1
  );
  port (
    pi_clock     : in    std_logic;
    pi_ii_data   : in    std_logic_vector(G_DSP_WORD_WIDTH - 1 downto 0);
    po_ii_data   : out   std_logic_vector(G_DSP_WORD_WIDTH - 1 downto 0);
    pi_ii_addr   : in    std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
    pi_ii_wr_ena : in    std_logic;
    pi_ii_str    : in    std_logic_vector(G_CTL_TABLES_COUNT - 1 downto 0);
    pi_buf       : in    std_logic_vector(G_CTL_TABLES_COUNT - 1 downto 0);
    pi_ctl_str   : in    std_logic_vector(G_CTL_TABLES_COUNT - 1 downto 0);
    pi_ctl_addr  : in    std_logic_vector(G_CTL_TABLES_COUNT * G_ADDR_WIDTH - 1 downto 0);
    po_ctl_done  : out   std_logic_vector(G_CTL_TABLES_COUNT - 1 downto 0);
    po_ctl_data  : out   t_18b_slv_vector(G_CTL_TABLES_COUNT - 1 downto 0)
  );
end entity control_tables;

architecture arch of control_tables is

  signal sig_mux_ctl      : natural;
  signal sig_data_m       : t_18b_slv_vector(G_CTL_TABLES_COUNT - 1 downto 0);
  signal sig_data_b       : t_18b_slv_vector(G_CTL_TABLES_COUNT - 1 downto 0);
  signal sig_ctl_data_m   : t_18b_slv_vector(G_CTL_TABLES_COUNT - 1 downto 0);
  signal sig_ctl_data_b   : t_18b_slv_vector(G_CTL_TABLES_COUNT - 1 downto 0);
  signal sig_done         : std_logic_vector(G_CTL_TABLES_COUNT - 1 downto 0);
  signal sig_port_b_ena_m : std_logic_vector(G_CTL_TABLES_COUNT - 1 downto 0);
  signal sig_port_b_ena_b : std_logic_vector(G_CTL_TABLES_COUNT - 1 downto 0);
  signal sig_port_b_addr  : std_logic_vector(G_CTL_TABLES_COUNT * G_ADDR_WIDTH - 1 downto 0);

begin

  prs_mux_ctl : process (pi_clock) is
  -- variable v_index : natural;
  begin

    if rising_edge(pi_clock) then

      for I in 0 to G_CTL_TABLES_COUNT - 1 loop

        if (pi_ii_str(I) = '1') then
          sig_mux_ctl <= I;
        end if;

      end loop;

    -- SIG_MUX_CTL <= v_index;
    end if;

  end process prs_mux_ctl;

  prs_ii_data : process (pi_clock) is
  begin

    if rising_edge(pi_clock) then
      if (pi_buf(sig_mux_ctl) = '0' and G_CTL_TABLES_DBF = 1) then
        po_ii_data <= sig_data_b(sig_mux_ctl);
      else
        po_ii_data <= sig_data_m(sig_mux_ctl);
      end if;
    end if;

  end process prs_ii_data;

  sig_port_b_ena_m <= pi_ctl_str;
  sig_port_b_ena_b <= pi_ctl_str;
  sig_port_b_addr  <= pi_ctl_addr;

  -- main tables
  gen_mem : for I in 0 to G_CTL_TABLES_COUNT - 1 generate
    signal sig_loc_ena_m : std_logic;
    signal sig_loc_ena_b : std_logic;

    signal sig_loc_wr    : std_logic;
    signal sig_loc_rd    : std_logic;
    signal sig_loc_dummy : std_logic_vector(G_DSP_WORD_WIDTH - 1 downto 0);
  begin

    prs_done : process (pi_clock) is
    begin

      if rising_edge(pi_clock) then
        sig_done(I)    <= pi_ctl_str(I);
        po_ctl_done(I) <= sig_done(I);
      end if;

    end process prs_done;

    prs_ctl_data : process (pi_clock) is
    begin

      if rising_edge(pi_clock) then
        if (pi_buf(I) = '0' and G_CTL_TABLES_DBF = 1) then
          po_ctl_data(I) <= sig_ctl_data_b(I);
        else
          po_ctl_data(I) <= sig_ctl_data_m(I);
        end if;
      end if;

    end process prs_ctl_data;

    sig_loc_wr <= '1' when pi_ii_str(I) = '1' and G_CTL_TABLES_DBF = 1 and pi_ii_wr_ena = '1' else
                  '0';
    sig_loc_rd <= '1' when pi_ii_str(I) = '1' and G_CTL_TABLES_DBF = 1 and pi_ii_wr_ena = '0' else
                  '0';

    sig_loc_ena_m <= '1' when (sig_loc_wr = '1' and pi_buf(I) = '0') or (sig_loc_rd = '1' and pi_buf(I) = '1') else
                     '0';
    sig_loc_ena_b <= '1' when (sig_loc_wr = '1' and pi_buf(I) = '1') or (sig_loc_rd = '1' and pi_buf(I) = '0') else
                     '0';

    ins_mem1 : entity work.dual_port_memory
      generic map (
        G_DATA_WIDTH => G_DSP_WORD_WIDTH,
        G_ADDR_WIDTH => G_ADDR_WIDTH
      )
      port map (
        pi_clk_a  => pi_clock,
        pi_ena_a  => sig_loc_ena_m,
        pi_wr_a   => pi_ii_wr_ena,
        pi_addr_a => pi_ii_addr,
        pi_data_a => pi_ii_data,
        po_data_a => sig_data_m(I),

        pi_clk_b  => pi_clock,
        pi_ena_b  => sig_port_b_ena_m(I),
        pi_addr_b => sig_port_b_addr((I + 1)*G_ADDR_WIDTH - 1 downto I*G_ADDR_WIDTH),
        po_data_b => sig_ctl_data_m(I),
        pi_wr_b   => '0',
        pi_data_b => sig_loc_dummy
      );

    gen_dbl : if G_CTL_TABLES_DBF = 1 generate
    begin

      ins_mem2 : entity work.dual_port_memory
        generic map (
          G_DATA_WIDTH => G_DSP_WORD_WIDTH,
          G_ADDR_WIDTH => G_ADDR_WIDTH
        )
        port map (
          pi_clk_a  => pi_clock,
          pi_ena_a  => sig_loc_ena_b,
          pi_wr_a   => pi_ii_wr_ena,
          pi_addr_a => pi_ii_addr,
          pi_data_a => pi_ii_data,
          po_data_a => sig_data_b(I),

          pi_clk_b  => pi_clock,
          pi_ena_b  => sig_port_b_ena_b(I),
          pi_addr_b => sig_port_b_addr((I + 1)*G_ADDR_WIDTH - 1 downto I*G_ADDR_WIDTH),
          po_data_b => sig_ctl_data_b(I),
          pi_wr_b   => '0',
          pi_data_b => sig_loc_dummy
        );

    end generate gen_dbl;

  end generate gen_mem;

end architecture arch;

