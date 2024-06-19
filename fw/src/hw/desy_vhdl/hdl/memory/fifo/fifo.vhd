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
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library desy;
use desy.memory_fifo.all;

entity fifo is
  generic (
    G_FIFO_DEPTH       : positive := 1024;       --! FIFO Depth (write words)
    G_FIFO_WIDTH       : positive := 256;        --! FIFO WRITE PORT WIDTH
    G_FIFO_READ_WIDTH  : natural  := 64;         --! FIFO READ PORT WIDTH
    G_FIFO_WRITE_WIDTH : natural  := 256;        --! FIFO WRITE PORT WIDTH
    G_FIFO_TYPE        : string   := "GENERIC";  --! use dedicated fifo logic on VIRTEX5,
    G_RELATED_CLOCKS   : natural  := 0;          --! 1 if rd and wr clocks are related
    G_CDC_SYNC_STAGES  : positive := 2;          --! CDC sync stages

    G_FIFO_VIRTEX_MAX_LAYERS   : natural := 0;   --! maximum layers of VIRTEX implementation
    G_FIFO_VIRTEX_MAX_IN_LAYER : natural := 0;   --! maximum primitives in one
                                                 --! layer in VIRTEX implementation
    G_FIFO_FWFT              : natural := 1;     --! First Word Fall Througth
    G_FIFO_PROG_FULL_OFFSET  : natural := 128;   --! Programmable offset, FIFO words
    G_FIFO_PROG_EMPTY_OFFSET : natural := 128;   --! Programmable offset, in FIFO words
    G_FIFO_ENABLE_ECC        : boolean := FALSE  --! With ECC maximum data width is 64:
                                                 --! in VIRTEX6 and 7SERIES only FIFO36 and FIFO36_72 modes are supported
                                                 --! in VIRTEX5 only FIFO36_72 mode is supported
  );

  port (
    pi_reset   : in  std_logic; --! async reset
    pi_wr_clk  : in  std_logic; --! write clock
    pi_rd_clk  : in  std_logic; --! read clock
    pi_int_clk : in  std_logic; --! clock for internal layers
                                --! connect to faster of WR|RD

    pi_data       : in  std_logic_vector(G_FIFO_WRITE_WIDTH-1 downto 0); --! write port
    pi_wr_ena     : in  std_logic;                                       --! write request
    pi_rd_ena     : in  std_logic;                                       --! read request
    po_data       : out std_logic_vector(G_FIFO_READ_WIDTH-1 downto 0);  --! read port
    po_full       : out std_logic;                                       --! FIFO full
    po_empty      : out std_logic;                                       --! FIFO empty
    po_prog_full  : out std_logic;                                       --! Programmable full
    po_prog_empty : out std_logic                                        --! Programmable empty
  );

end entity fifo;

architecture rtl of fifo is
  function fun_fifo_prog_full_offset_calc
    return natural is
    variable v_ret : natural := 0;
  begin
    v_ret := G_FIFO_PROG_FULL_OFFSET;
    if G_FIFO_PROG_FULL_OFFSET /= 0 then
      if G_FIFO_WIDTH/G_FIFO_READ_WIDTH > 1 then
        v_ret := v_ret - 1;
      end if;
      if v_ret <= 1 then
        report "Wrong prog full offset" severity failure;
      end if;
    end if;
    return v_ret;
  end function fun_fifo_prog_full_offset_calc;

  function fun_fifo_prog_empty_offset_calc
    return natural is
    variable v_ret : natural := 0;
  begin
    v_ret := G_FIFO_PROG_EMPTY_OFFSET;
    if G_FIFO_PROG_EMPTY_OFFSET /= 0 then
      if G_FIFO_WIDTH/G_FIFO_READ_WIDTH > 1 then
        v_ret := v_ret ;
      end if;
      if v_ret <= 1 then
        report "Wrong prog empty offset" severity failure;
      end if;
    end if;
    return v_ret;
  end function fun_fifo_prog_empty_offset_calc;


  function fun_fifo_inner_layer_fwft
    return natural is
  begin
    if (G_FIFO_READ_WIDTH /= G_FIFO_WIDTH) or (G_FIFO_FWFT /= 0) then
      return 1;
    else
      return 0;
    end if;
  end function fun_fifo_inner_layer_fwft;

  constant C_INNER_LAYER_FWFT : natural := fun_fifo_inner_layer_fwft;

  signal fifo_data_i     : std_logic_vector(G_FIFO_WIDTH-1 downto 0);
  signal fifo_data_o     : std_logic_vector(G_FIFO_WIDTH-1 downto 0);
  signal fifo_wr_ena     : std_logic;
  signal fifo_rd_ena     : std_logic;
  signal fifo_full       : std_logic;
  signal fifo_empty      : std_logic;
  signal fifo_prog_full  : std_logic;
  signal fifo_prog_empty : std_logic;

  constant C_FIFO_PROG_FULL_OFFSET  : natural := fun_fifo_prog_full_offset_calc;
  constant C_FIFO_PROG_EMPTY_OFFSET : natural := fun_fifo_prog_empty_offset_calc;

begin

  assert (G_FIFO_TYPE = "VIRTEX5"     or
          G_FIFO_TYPE = "VIRTEX6"     or
          G_FIFO_TYPE = "7SERIES"     or
          G_FIFO_TYPE = "XPM"         or
          G_FIFO_TYPE = "ULTRASCALE"  or
          G_FIFO_TYPE = "GENERIC" )
    report "Wrong G_FIFO_TYPE Correct values: VIRTEX5 VIRTEX6 7SERIES GENERIC XPM ULTRASCALE"
    severity failure;

  assert (
    (G_FIFO_ENABLE_ECC = TRUE and (G_FIFO_TYPE = "VIRTEX5" or G_FIFO_TYPE = "VIRTEX6" or G_FIFO_TYPE = "7SERIES")) or
    (G_FIFO_ENABLE_ECC = FALSE)
  )
  report "ECC is supported only for G_FIFO_TYPE: VIRTEX5 VIRTEX6 7SERIES"
  severity failure;


-- INPUT
  -- GEN_INPUT : if G_FIFO_WRITE_WIDTH /= G_FIFO_WIDTH and G_FIFO_TYPE /= "XPM" generate
  gen_input : if G_FIFO_WRITE_WIDTH /= G_FIFO_WIDTH   generate
    ins_fifo_input : entity desy.fifo_input
      generic map (
        G_IN_WIDTH   => G_FIFO_WRITE_WIDTH,
        G_FIFO_WIDTH => G_FIFO_WIDTH)
      port map (
        pi_reset  => pi_reset,
        pi_wr_clk => pi_wr_clk,
        pi_data   => pi_data,
        pi_wr_ena => pi_wr_ena,
        pi_full   => fifo_full,
        po_wr_ena => fifo_wr_ena,
        po_data   => fifo_data_i,
        po_full   => po_full);
  end generate GEN_INPUT;

  gen_no_input : if G_FIFO_WRITE_WIDTH = G_FIFO_WIDTH  generate
    fifo_wr_ena <= pi_wr_ena;
    po_full     <= fifo_full;
    fifo_data_i <= pi_data;
  end generate gen_no_input;

  gen_fifo_virtex : if G_FIFO_TYPE = "VIRTEX5" or G_FIFO_TYPE = "VIRTEX6" or G_FIFO_TYPE = "7SERIES" generate
    -- purpose: FIFO using VIRTEX primitives
    blk_fifo_virtex : block is
      constant C_FIFO_CONF : T_FIFO_CONF := FUN_GET_FIFO_CONF (
          max_latency => G_FIFO_VIRTEX_MAX_LAYERS,
          max_comb    => G_FIFO_VIRTEX_MAX_IN_LAYER,
          width       => G_FIFO_WIDTH,
          depth       => G_FIFO_DEPTH,
          pfull       => C_FIFO_PROG_FULL_OFFSET,
          enable_ecc  => G_FIFO_ENABLE_ECC);
      signal l_fifo_data_i : std_logic_vector(C_FIFO_CONF.LAYER_WIDTH-1 downto 0);
      signal l_fifo_data_o : std_logic_vector(C_FIFO_CONF.LAYER_WIDTH-1 downto 0);

    begin
      fifo_data_o <= l_fifo_data_o(fifo_data_o'left downto 0);
      l_fifo_data_i(fifo_data_i'left downto 0) <= fifo_data_i;

      ins_fifo_virtex : entity desy.fifo_virtex
        generic map (
          G_FIFO_LAYER_NUM         => C_FIFO_CONF.N_LAYERS,
          G_FIFO18_NUM             => C_FIFO_CONF.N_18,
          G_FIFO36_NUM             => C_FIFO_CONF.N_36,
          G_FIFO36_WIDTH           => C_FIFO_CONF.DATA_WIDTH_36,
          G_FIFO_WIDTH             => C_FIFO_CONF.LAYER_WIDTH,
          G_FIFO_DEPTH             => C_FIFO_CONF.LAYER_DEPTH,
          G_FIFO_FWFT              => C_INNER_LAYER_FWFT,
          G_FIFO_PROG_FULL_OFFSET  => C_FIFO_CONF.PROG_FULL,
          G_FIFO_PROG_EMPTY_OFFSET => C_FIFO_PROG_EMPTY_OFFSET,
          G_FIFO_TYPE              => G_FIFO_TYPE,
          G_FIFO_ENABLE_ECC        => G_FIFO_ENABLE_ECC
          )
        port map (
          pi_reset       => pi_reset,
          pi_wr_clk     => pi_wr_clk,
          pi_rd_clk     => pi_rd_clk,
          pi_int_clk    => pi_int_clk,
          pi_data       => l_fifo_data_i,
          pi_wr_ena     => fifo_wr_ena,
          pi_rd_ena     => fifo_rd_ena,
          po_data       => l_fifo_data_o,
          po_full       => fifo_full,
          po_empty      => fifo_empty,
          po_prog_full  => fifo_prog_full,
          po_prog_empty => fifo_prog_empty
        );
    end block blk_fifo_virtex;

  end generate gen_fifo_virtex;


  --! FIFO using ULTRASCALE primitives
  gen_fifo_ultrascale: if G_FIFO_TYPE = "ULTRASCALE" generate

    component fifo_ultrascale is
      generic (
        G_FIFO_LAYER_NUM         : natural;
        G_FIFO18_NUM             : natural;
        G_FIFO36_NUM             : natural;
        G_FIFO36_WIDTH           : positive;
        G_FIFO_WIDTH             : positive;
        G_FIFO_DEPTH             : positive;
        G_FIFO_FWFT              : natural;
        G_FIFO_PROG_FULL_OFFSET  : natural;
        G_FIFO_PROG_EMPTY_OFFSET : natural
      );
      port (
        pi_reset       : in  std_logic;
        pi_wr_clk      : in  std_logic;
        pi_rd_clk      : in  std_logic;
        pi_int_clk     : in  std_logic;
        pi_data        : in  std_logic_vector(G_FIFO_WIDTH-1 downto 0);
        pi_wr_ena      : in  std_logic;
        pi_rd_ena      : in  std_logic;
        po_data        : out std_logic_vector(G_FIFO_WIDTH-1 downto 0);
        po_full        : out std_logic;
        po_empty       : out std_logic;
        po_prog_full   : out std_logic;
        po_prog_empty  : out std_logic
      );
    end component fifo_ultrascale;

    constant C_LOC_FIFO_CONF : t_fifo_conf := fun_get_fifo_conf(
        max_latency => G_FIFO_VIRTEX_MAX_LAYERS,
        max_comb    => G_FIFO_VIRTEX_MAX_IN_LAYER,
        width       => G_FIFO_WIDTH,
        depth       => G_FIFO_DEPTH,
        pfull       => C_FIFO_PROG_FULL_OFFSET,
        enable_ecc  => G_FIFO_ENABLE_ECC);
    signal l_fifo_data_i : std_logic_vector(C_LOC_FIFO_CONF.LAYER_WIDTH-1 downto 0);
    signal l_fifo_data_o : std_logic_vector(C_LOC_FIFO_CONF.LAYER_WIDTH-1 downto 0);

    signal l_reset  : std_logic_vector(G_CDC_SYNC_STAGES-1 downto 0);

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of l_reset  : signal is "TRUE";

  begin

    --! reset synchronization to the write clock domain
    l_reset <= pi_reset & l_reset(G_CDC_SYNC_STAGES-1 downto 1) when rising_edge(pi_wr_clk);

    fifo_data_o <= l_fifo_data_o(fifo_data_o'left downto 0);
    l_fifo_data_i(fifo_data_i'left downto 0) <= fifo_data_i;
    l_fifo_data_i(l_fifo_data_i'left downto fifo_data_i'left+1) <= (others => '0');

    ins_fifo_ultrascale: fifo_ultrascale
      generic map (
        G_FIFO_LAYER_NUM         => C_LOC_FIFO_CONF.N_LAYERS,
        G_FIFO18_NUM             => C_LOC_FIFO_CONF.N_18,
        G_FIFO36_NUM             => C_LOC_FIFO_CONF.N_36,
        G_FIFO36_WIDTH           => C_LOC_FIFO_CONF.DATA_WIDTH_36,
        G_FIFO_WIDTH             => C_LOC_FIFO_CONF.LAYER_WIDTH,
        G_FIFO_DEPTH             => C_LOC_FIFO_CONF.LAYER_DEPTH,
        G_FIFO_FWFT              => C_INNER_LAYER_FWFT,
        G_FIFO_PROG_FULL_OFFSET  => C_LOC_FIFO_CONF.PROG_FULL,
        G_FIFO_PROG_EMPTY_OFFSET => C_FIFO_PROG_EMPTY_OFFSET
      )
      port map (
        pi_reset       => l_reset(0),
        pi_wr_clk      => pi_wr_clk,
        pi_rd_clk      => pi_rd_clk,
        pi_int_clk     => pi_int_clk,
        pi_data        => l_fifo_data_i,
        pi_wr_ena      => fifo_wr_ena,
        pi_rd_ena      => fifo_rd_ena,
        po_data        => l_fifo_data_o,
        po_full        => fifo_full,
        po_empty       => fifo_empty,
        po_prog_full   => fifo_prog_full,
        po_prog_empty  => fifo_prog_empty
      );

  end generate gen_fifo_ultrascale;


  ------------------------------------------------------------------------------
  -- GENERIC
  ------------------------------------------------------------------------------
  gen_fifo_generic : if G_FIFO_TYPE = "GENERIC"  generate
    ins_fifo_generic : entity desy.fifo_generic
      generic map (
        G_FIFO_DEPTH        => G_FIFO_DEPTH,
        G_FIFO_WIDTH        => G_FIFO_WIDTH,
        G_PROG_FULL_OFFSET  => C_FIFO_PROG_FULL_OFFSET,
        G_PROG_EMPTY_OFFSET => C_FIFO_PROG_EMPTY_OFFSET,
        G_FIFO_TYPE         => G_FIFO_TYPE,
        G_FIFO_FWFT         => C_INNER_LAYER_FWFT
        )
      port map (
        pi_reset      => pi_reset,
        pi_wr_clk     => pi_wr_clk,
        pi_rd_clk     => pi_rd_clk,
        pi_int_clk    => pi_int_clk,
        pi_data       => fifo_data_i,
        pi_wr_ena     => fifo_wr_ena,
        pi_rd_ena     => fifo_rd_ena,
        po_data       => fifo_data_o,
        po_full       => fifo_full,
        po_empty      => fifo_empty,
        po_prog_full  => fifo_prog_full,
        po_prog_empty => fifo_prog_empty
        );
  end generate gen_fifo_generic;

  ------------------------------------------------------------------------------
  -- XPM Xilinx parameterized macro
  ------------------------------------------------------------------------------
  gen_fifo_xpm : if G_FIFO_TYPE = "XPM" generate

    component fifo_xpm is
      generic (
        G_FIFO_WRITE_WIDTH       : positive;
        G_FIFO_READ_WIDTH        : positive;
        G_FIFO_DEPTH             : positive;
        G_FIFO_FWFT              : natural;
        G_RELATED_CLOCKS         : natural;
        G_CDC_SYNC_STAGES        : positive;
        G_FIFO_PROG_FULL_OFFSET  : natural;
        G_FIFO_PROG_EMPTY_OFFSET : natural);
      port(
        pi_reset        : in  std_logic;
        pi_wr_clk       : in  std_logic;
        pi_wr_ena       : in  std_logic;
        pi_data         : in  std_logic_vector(G_FIFO_WRITE_WIDTH-1 downto 0);
        po_full         : out std_logic;
        po_prog_full    : out std_logic;
        po_wr_rst_busy  : out std_logic;
        pi_rd_clk       : in  std_logic;
        pi_rd_ena       : in  std_logic;
        po_data         : out std_logic_vector(G_FIFO_READ_WIDTH-1 downto 0);
        po_empty        : out std_logic;
        po_prog_empty   : out std_logic;
        po_rd_rst_busy  : out std_logic);
    end component fifo_xpm;

    -- fifo_wr_ena <= pi_wr_ena;
    -- po_full        <= fifo_full;
    -- fifo_data_i <= pi_data;
  begin

    ins_fifo_xpm: fifo_xpm
      generic map(
        G_FIFO_WRITE_WIDTH       => G_FIFO_WIDTH,
        G_FIFO_READ_WIDTH        => G_FIFO_WIDTH,
        G_FIFO_DEPTH             => G_FIFO_DEPTH,
        G_FIFO_FWFT              => C_INNER_LAYER_FWFT,
        G_RELATED_CLOCKS         => G_RELATED_CLOCKS,
        G_CDC_SYNC_STAGES        => G_CDC_SYNC_STAGES,
        G_FIFO_PROG_FULL_OFFSET  => C_FIFO_PROG_FULL_OFFSET,
        G_FIFO_PROG_EMPTY_OFFSET => C_FIFO_PROG_EMPTY_OFFSET
      )
      port map (
        pi_reset        => pi_reset,
        pi_wr_clk       => pi_wr_clk,
        pi_wr_ena       => fifo_wr_ena,
        pi_data         => fifo_data_i,
        po_full         => fifo_full,
        po_prog_full    => fifo_prog_full,
        po_wr_rst_busy  => open,
        pi_rd_clk       => pi_rd_clk,
        pi_rd_ena       => fifo_rd_ena,
        po_data         => fifo_data_o,
        po_empty        => fifo_empty,
        po_prog_empty   => fifo_prog_empty,
        po_rd_rst_busy  => open
      );

    -- po_data        <= fifo_data_o;
    -- po_empty       <= fifo_empty;
    -- fifo_rd_ena <= pi_rd_ena;

  end generate gen_fifo_xpm;

-------------------------------------------------------------------------------
-- OUTPUT
  gen_output : if G_FIFO_READ_WIDTH /= G_FIFO_WIDTH generate
    fifo_output : entity desy.fifo_output
      generic map (
        G_OUT_WIDTH  => G_FIFO_READ_WIDTH,
        G_FIFO_WIDTH => G_FIFO_WIDTH,
        G_FIFO_FWFT  => G_FIFO_FWFT
      )
      port map(
        pi_reset   => pi_reset,
        pi_rd_clk  => pi_rd_clk,
        pi_data    => fifo_data_o,
        pi_rd_ena  => pi_rd_ena,
        pi_empty   => fifo_empty,
        po_rd_ena  => fifo_rd_ena,
        po_data    => po_data,
        po_empty   => po_empty
      );
  end generate gen_output;

  gen_no_output : if G_FIFO_READ_WIDTH = G_FIFO_WIDTH  generate
    po_data     <= fifo_data_o;
    po_empty    <= fifo_empty;
    fifo_rd_ena <= pi_rd_ena;
  end generate gen_no_output;

-------------------------------------------------------------------------------
  po_prog_full  <= fifo_prog_full;
  po_prog_empty <= fifo_prog_empty;

end architecture rtl;


