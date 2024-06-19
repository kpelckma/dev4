--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2019 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2019-06-17
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief Ultrascale built-in FIFO
--!
--! Instantiates FIFO18E2 and/or FIFO36E2 primitives
--! Supports serial cascading feature of the primitive to increase depth
--! G_FIFO18_NUM + G_FIFO36_NUM is the number of parallel FIFO chains
--! WARNING: pi_reset is synchronous to pi_wr_clk (property of the primitive)
--! TODO: Add parallel cascading feature (improves timing but reduces bandwidth)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity fifo_ultrascale is
  generic (
    G_FIFO_LAYER_NUM          : natural   := 1;
    G_FIFO18_NUM              : natural   := 0;
    G_FIFO36_NUM              : natural   := 2;
    G_FIFO36_WIDTH            : positive  := 18;
    G_FIFO_WIDTH              : positive  := 18*2+9*0;
    G_FIFO_DEPTH              : positive  := 2048;
    G_FIFO_FWFT               : natural   := 1;
    G_FIFO_PROG_FULL_OFFSET   : natural   := 128;
    G_FIFO_PROG_EMPTY_OFFSET  : natural   := 128
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
end entity fifo_ultrascale;

architecture rtl of fifo_ultrascale is

  component fifo36e2 is
    generic(
      CASCADE_ORDER           : string;
      CLOCK_DOMAINS           : string;
      EN_ECC_PIPE             : string;
      EN_ECC_READ             : string;
      EN_ECC_WRITE            : string;
      FIRST_WORD_FALL_THROUGH : string;
      INIT                    : std_logic_vector(71 downto 0);
      PROG_EMPTY_THRESH       : positive;
      PROG_FULL_THRESH        : positive;
      IS_RDCLK_INVERTED       : bit;
      IS_RDEN_INVERTED        : bit;
      IS_RSTREG_INVERTED      : bit;
      IS_RST_INVERTED         : bit;
      IS_WRCLK_INVERTED       : bit;
      IS_WREN_INVERTED        : bit;
      RDCOUNT_TYPE            : string;
      READ_WIDTH              : natural;
      REGISTER_MODE           : string;
      RSTREG_PRIORITY         : string;
      SLEEP_ASYNC             : string;
      SRVAL                   : std_logic_vector(71 downto 0);
      WRCOUNT_TYPE            : string;
      WRITE_WIDTH             : natural
    );
    port(
      casdout       : out std_logic_vector(63 downto 0);
      casdoutp      : out std_logic_vector(7 downto 0);
      casnxtempty   : out std_logic;
      casprvrden    : out std_logic;
      dbiterr       : out std_logic;
      eccparity     : out std_logic_vector(7 downto 0);
      sbiterr       : out std_logic;
      dout          : out std_logic_vector(63 downto 0);
      doutp         : out std_logic_vector(7 downto 0);
      empty         : out std_logic;
      full          : out std_logic;
      progempty     : out std_logic;
      progfull      : out std_logic;
      rdcount       : out std_logic_vector(13 downto 0);
      rderr         : out std_logic;
      rdrstbusy     : out std_logic;
      wrcount       : out std_logic_vector(13 downto 0);
      wrerr         : out std_logic;
      wrrstbusy     : out std_logic;
      casdin        : in  std_logic_vector(63 downto 0);
      casdinp       : in  std_logic_vector(7 downto 0);
      casdomux      : in  std_logic;
      casdomuxen    : in  std_logic;
      casnxtrden    : in  std_logic;
      casoregimux   : in  std_logic;
      casoregimuxen : in  std_logic;
      casprvempty   : in  std_logic;
      injectdbiterr : in  std_logic;
      injectsbiterr : in  std_logic;
      rdclk         : in  std_logic;
      rden          : in  std_logic;
      regce         : in  std_logic;
      rstreg        : in  std_logic;
      sleep         : in  std_logic;
      rst           : in  std_logic;
      wrclk         : in  std_logic;
      wren          : in  std_logic;
      din           : in  std_logic_vector(63 downto 0);
      dinp          : in  std_logic_vector(7 downto 0)
    );
  end component fifo36e2;

  component fifo18e2 is
    generic(
      CASCADE_ORDER           : string;
      CLOCK_DOMAINS           : string;
      FIRST_WORD_FALL_THROUGH : string;
      INIT                    : std_logic_vector(35 downto 0);
      PROG_EMPTY_THRESH       : positive;
      PROG_FULL_THRESH        : positive;
      IS_RDCLK_INVERTED       : bit;
      IS_RDEN_INVERTED        : bit;
      IS_RSTREG_INVERTED      : bit;
      IS_RST_INVERTED         : bit;
      IS_WRCLK_INVERTED       : bit;
      IS_WREN_INVERTED        : bit;
      RDCOUNT_TYPE            : string;
      READ_WIDTH              : natural;
      REGISTER_MODE           : string;
      RSTREG_PRIORITY         : string;
      SLEEP_ASYNC             : string;
      SRVAL                   : std_logic_vector(35 downto 0);
      WRCOUNT_TYPE            : string;
      WRITE_WIDTH             : natural
    );
    port(
      casdout       : out std_logic_vector(31 downto 0);
      casdoutp      : out std_logic_vector(3 downto 0);
      casnxtempty   : out std_logic;
      casprvrden    : out std_logic;
      dout          : out std_logic_vector(31 downto 0);
      doutp         : out std_logic_vector(3 downto 0);
      empty         : out std_logic;
      full          : out std_logic;
      progempty     : out std_logic;
      progfull      : out std_logic;
      rdcount       : out std_logic_vector(12 downto 0);
      rderr         : out std_logic;
      rdrstbusy     : out std_logic;
      wrcount       : out std_logic_vector(12 downto 0);
      wrerr         : out std_logic;
      wrrstbusy     : out std_logic;
      casdin        : in  std_logic_vector(31 downto 0);
      casdinp       : in  std_logic_vector(3 downto 0);
      casdomux      : in  std_logic;
      casdomuxen    : in  std_logic;
      casnxtrden    : in  std_logic;
      casoregimux   : in  std_logic;
      casoregimuxen : in  std_logic;
      casprvempty   : in  std_logic;
      rdclk         : in  std_logic;
      rden          : in  std_logic;
      regce         : in  std_logic;
      rstreg        : in  std_logic;
      sleep         : in  std_logic;
      rst           : in  std_logic;
      wrclk         : in  std_logic;
      wren          : in  std_logic;
      din           : in  std_logic_vector(31 downto 0);
      dinp          : in  std_logic_vector(3 downto 0)
    );
  end component fifo18e2;

  function fun_natural_to_boolstring(arg : natural) return string is
  begin
    if arg /= 0 then
      return "TRUE ";
    end if;
    return "FALSE";
  end function fun_natural_to_boolstring;

  constant C_FIFO_FWFT : string := fun_natural_to_boolstring(G_FIFO_FWFT);

  function fun_natural_to_positive(arg : natural) return positive is
  begin
    if arg = 0 then
      return 1;
    end if;
    return arg;
  end function fun_natural_to_positive;

  constant C_PROG_EMPTY_THRESH  : positive  := fun_natural_to_positive(G_FIFO_PROG_EMPTY_OFFSET);
  constant C_PROG_FULL_THRESH   : positive  := fun_natural_to_positive(G_FIFO_PROG_FULL_OFFSET);

  function fun_before_space(arg: string) return natural is
  begin
    for i in arg'range loop
      if arg(i) = ' ' then
        return i-1;
      end if;
    end loop;
    return arg'right;
  end function fun_before_space;

  function fun_no_space(arg: string) return string is
    constant RIGHT: natural := fun_before_space(arg);
  begin
    return arg(1 to RIGHT);
  end function fun_no_space;

  type t_fifo36_generics is record
    cascade_order           : string(1 to 8);
    clock_domains           : string(1 to 11);
    en_ecc_pipe             : string(1 to 5);
    en_ecc_read             : string(1 to 5);
    en_ecc_write            : string(1 to 5);
    first_word_fall_through : string(1 to 5);
    init                    : std_logic_vector(71 downto 0);
    prog_empty_thresh       : positive;
    prog_full_thresh        : positive;
    is_rdclk_inverted       : bit;
    is_rden_inverted        : bit;
    is_rstreg_inverted      : bit;
    is_rst_inverted         : bit;
    is_wrclk_inverted       : bit;
    is_wren_inverted        : bit;
    rdcount_type            : string(1 to 16);
    read_width              : natural;
    register_mode           : string(1 to 12);
    rstreg_priority         : string(1 to 6);
    sleep_async             : string(1 to 5);
    srval                   : std_logic_vector(71 downto 0);
    wrcount_type            : string(1 to 16);
    write_width             : natural;
  end record t_fifo36_generics;

  type t_fifo36_generics_array is array (1 to G_FIFO_LAYER_NUM) of t_fifo36_generics;

  function fun_fifo36_generics(
      layer_num     : natural;
      fifo_width    : natural;
      fwft          : string;
      full_thresh   : positive;
      empty_thresh  : positive) return t_fifo36_generics_array is
    constant C_FIFO36_GENERICS_DEFAULT  : t_fifo36_generics := (
        CASCADE_ORDER           => "MIDDLE  ",
        CLOCK_DOMAINS           => "COMMON     ",
        EN_ECC_PIPE             => "FALSE",
        EN_ECC_READ             => "FALSE",
        EN_ECC_WRITE            => "FALSE",
        FIRST_WORD_FALL_THROUGH => "TRUE ",
        INIT                    => X"000000000000000000",
        PROG_EMPTY_THRESH       => 1,
        PROG_FULL_THRESH        => 1,
        IS_RDCLK_INVERTED       => '0',
        IS_RDEN_INVERTED        => '0',
        IS_RSTREG_INVERTED      => '0',
        IS_RST_INVERTED         => '0',
        IS_WRCLK_INVERTED       => '0',
        IS_WREN_INVERTED        => '0',
        RDCOUNT_TYPE            => "RAW_PNTR        ",
        READ_WIDTH              => FIFO_WIDTH,
        REGISTER_MODE           => "UNREGISTERED",
        RSTREG_PRIORITY         => "RSTREG",
        SLEEP_ASYNC             => "FALSE",
        SRVAL                   => X"000000000000000000",
        WRCOUNT_TYPE            => "RAW_PNTR        ",
        WRITE_WIDTH             => FIFO_WIDTH);
    variable v_fifo36_generics  : t_fifo36_generics_array;
  begin
    for i in 1 to LAYER_NUM loop
      v_fifo36_generics(i)                              := C_FIFO36_GENERICS_DEFAULT;
      if i = 1 then
        if LAYER_NUM = 1 then
          v_fifo36_generics(i).CASCADE_ORDER            := "NONE    ";
          v_fifo36_generics(i).CLOCK_DOMAINS            := "INDEPENDENT";
          v_fifo36_generics(i).FIRST_WORD_FALL_THROUGH  := FWFT;
          v_fifo36_generics(i).PROG_EMPTY_THRESH        := EMPTY_THRESH;
          v_fifo36_generics(i).PROG_FULL_THRESH         := FULL_THRESH;
        else
          v_fifo36_generics(I).CASCADE_ORDER            := "FIRST   ";
          v_fifo36_generics(I).CLOCK_DOMAINS            := "INDEPENDENT";
          v_fifo36_generics(I).PROG_FULL_THRESH         := FULL_THRESH;
        end if;
      elsif I = LAYER_NUM then
        v_fifo36_generics(I).CASCADE_ORDER              := "LAST    ";
        v_fifo36_generics(I).CLOCK_DOMAINS              := "INDEPENDENT";
        v_fifo36_generics(I).FIRST_WORD_FALL_THROUGH    := FWFT;
        v_fifo36_generics(I).PROG_EMPTY_THRESH          := EMPTY_THRESH;
      end if;
    end loop;
    return V_FIFO36_GENERICS;
  end function FUN_FIFO36_GENERICS;

  constant C_FIFO36_GENERICS : t_fifo36_generics_array := fun_fifo36_generics(
      G_FIFO_LAYER_NUM,
      G_FIFO36_WIDTH,
      C_FIFO_FWFT,
      C_PROG_FULL_THRESH,
      C_PROG_EMPTY_THRESH);

  type t_fifo18_generics is record
    CASCADE_ORDER           : string(1 to 8);
    CLOCK_DOMAINS           : string(1 to 11);
    FIRST_WORD_FALL_THROUGH : string(1 to 5);
    INIT                    : std_logic_vector(35 downto 0);
    PROG_EMPTY_THRESH       : positive;
    PROG_FULL_THRESH        : positive;
    IS_RDCLK_INVERTED       : bit;
    IS_RDEN_INVERTED        : bit;
    IS_RSTREG_INVERTED      : bit;
    IS_RST_INVERTED         : bit;
    IS_WRCLK_INVERTED       : bit;
    IS_WREN_INVERTED        : bit;
    RDCOUNT_TYPE            : string(1 to 16);
    READ_WIDTH              : natural;
    REGISTER_MODE           : string(1 to 12);
    RSTREG_PRIORITY         : string(1 to 6);
    SLEEP_ASYNC             : string(1 to 5);
    SRVAL                   : std_logic_vector(35 downto 0);
    WRCOUNT_TYPE            : string(1 to 16);
    WRITE_WIDTH             : natural;
  end record t_fifo18_generics;
  type t_fifo18_generics_array is array (1 to G_FIFO_LAYER_NUM) of t_fifo18_generics;

  function fun_fifo18_generics(
      LAYER_NUM     : natural;
      FIFO_WIDTH    : natural;
      FWFT          : string;
      FULL_OFFSET   : positive;
      EMPTY_OFFSET  : positive) return t_fifo18_generics_array is
    constant C_FIFO18_GENERICS_DEFAULT  : t_fifo18_generics := (
        CASCADE_ORDER           => "MIDDLE  ",
        CLOCK_DOMAINS           => "COMMON     ",
        FIRST_WORD_FALL_THROUGH => "TRUE ",
        INIT                    => X"000000000",
        PROG_EMPTY_THRESH       => 1,
        PROG_FULL_THRESH        => 1,
        IS_RDCLK_INVERTED       => '0',
        IS_RDEN_INVERTED        => '0',
        IS_RSTREG_INVERTED      => '0',
        IS_RST_INVERTED         => '0',
        IS_WRCLK_INVERTED       => '0',
        IS_WREN_INVERTED        => '0',
        RDCOUNT_TYPE            => "RAW_PNTR        ",
        READ_WIDTH              => FIFO_WIDTH,
        REGISTER_MODE           => "UNREGISTERED",
        RSTREG_PRIORITY         => "RSTREG",
        SLEEP_ASYNC             => "FALSE",
        SRVAL                   => X"000000000",
        WRCOUNT_TYPE            => "RAW_PNTR        ",
        WRITE_WIDTH             => FIFO_WIDTH);
    variable v_fifo18_generics  : t_fifo18_generics_array;
  begin
    for i in 1 to layer_num loop
      v_fifo18_generics(i)                              := C_FIFO18_GENERICS_DEFAULT;
      if i = 1 then
        if layer_num = 1 then
          v_fifo18_generics(i).CASCADE_ORDER            := "NONE    ";
          v_fifo18_generics(i).CLOCK_DOMAINS            := "INDEPENDENT";
          v_fifo18_generics(i).FIRST_WORD_FALL_THROUGH  := FWFT;
          v_fifo18_generics(i).PROG_EMPTY_THRESH        := EMPTY_OFFSET;
          v_fifo18_generics(i).PROG_FULL_THRESH         := FULL_OFFSET;
        else
          v_fifo18_generics(i).CASCADE_ORDER            := "FIRST   ";
          v_fifo18_generics(i).CLOCK_DOMAINS            := "INDEPENDENT";
          v_fifo18_generics(i).PROG_FULL_THRESH         := FULL_OFFSET;
        end if;
      elsif i = layer_num then
        v_fifo18_generics(i).CASCADE_ORDER              := "LAST    ";
        v_fifo18_generics(i).CLOCK_DOMAINS              := "INDEPENDENT";
        v_fifo18_generics(i).FIRST_WORD_FALL_THROUGH    := FWFT;
        v_fifo18_generics(i).PROG_EMPTY_THRESH          := EMPTY_OFFSET;
      end if;
    end loop;
    return v_fifo18_generics;
  end function fun_fifo18_generics;

  constant C_FIFO18_GENERICS  : t_fifo18_generics_array := fun_fifo18_generics(
      G_FIFO_LAYER_NUM,
      G_FIFO36_WIDTH/2,
      C_FIFO_FWFT,
      C_PROG_FULL_THRESH,
      C_PROG_EMPTY_THRESH);

  function fun_parity_width(fifo_width : integer) return integer is
  begin
    if fifo_width = 72 then
      return 8;
    else
      return fifo_width/8;
    end if;
  end function fun_parity_width;

  type t_d_fifo36   is array (1 to G_FIFO_LAYER_NUM, 1 to G_FIFO36_NUM) of std_logic_vector(63 downto 0);
  type t_dp_fifo36  is array (1 to G_FIFO_LAYER_NUM, 1 to G_FIFO36_NUM) of std_logic_vector(7 downto 0);

  signal din36      : t_d_fifo36;
  signal dinp36     : t_dp_fifo36;
  signal dout36     : t_d_fifo36;
  signal doutp36    : t_dp_fifo36;
  signal casdin36   : t_d_fifo36;
  signal casdinp36  : t_dp_fifo36;
  signal casdout36  : t_d_fifo36;
  signal casdoutp36 : t_dp_fifo36;

  type t_d_fifo18   is array (1 to G_FIFO_LAYER_NUM, 1 to G_FIFO18_NUM) of std_logic_vector(31 downto 0);
  type t_dp_fifo18  is array (1 to G_FIFO_LAYER_NUM, 1 to G_FIFO18_NUM) of std_logic_vector(3 downto 0);

  signal din18      : t_d_fifo18;
  signal dinp18     : t_dp_fifo18;
  signal dout18     : t_d_fifo18;
  signal doutp18    : t_dp_fifo18;
  signal casdin18   : t_d_fifo18;
  signal casdinp18  : t_dp_fifo18;
  signal casdout18  : t_d_fifo18;
  signal casdoutp18 : t_dp_fifo18;

  type t_c_fifo36 is array (1 to G_FIFO_LAYER_NUM, 1 to G_FIFO36_NUM) of std_logic;

  signal wrclk36        : t_c_fifo36;
  signal rdclk36        : t_c_fifo36;
  signal wren36         : t_c_fifo36;
  signal rden36         : t_c_fifo36;
  signal casnxtempty36  : t_c_fifo36;
  signal casprvempty36  : t_c_fifo36;
  signal casnxtrden36   : t_c_fifo36;
  signal casprvrden36   : t_c_fifo36;
  signal empty36        : t_c_fifo36;
  signal full36         : t_c_fifo36;
  signal progempty36    : t_c_fifo36;
  signal progfull36     : t_c_fifo36;

  type t_c_fifo18 is array (1 to G_FIFO_LAYER_NUM, 1 to G_FIFO18_NUM) of std_logic;

  signal wrclk18        : t_c_fifo18;
  signal rdclk18        : t_c_fifo18;
  signal wren18         : t_c_fifo18;
  signal rden18         : t_c_fifo18;
  signal casnxtempty18  : t_c_fifo18;
  signal casprvempty18  : t_c_fifo18;
  signal casnxtrden18   : t_c_fifo18;
  signal casprvrden18   : t_c_fifo18;
  signal empty18        : t_c_fifo18;
  signal full18         : t_c_fifo18;
  signal progempty18    : t_c_fifo18;
  signal progfull18     : t_c_fifo18;

  signal empty : std_logic;
  signal full  : std_logic;

begin

  --! backpressure of the FIFO
  proc_backpressure: process(
      full36,
      empty36,
      progfull36,
      progempty36,
      full18,
      empty18,
      progfull18,
      progempty18)
    variable v_full       : std_logic;
    variable v_empty      : std_logic;
    variable v_progfull   : std_logic;
    variable v_progempty  : std_logic;
  begin
    v_full      := '0';
    v_empty     := '0';
    v_progfull  := '0';
    v_progempty := '0';
    for j in 1 to G_FIFO36_NUM loop
      v_full      := v_full or full36(1,J);
      v_empty     := v_empty or empty36(G_FIFO_LAYER_NUM,J);
      v_progfull  := v_progfull or progfull36(1,J);
      v_progempty := v_progempty or progempty36(G_FIFO_LAYER_NUM,J);
    end loop;
    for j in 1 to G_FIFO18_NUM loop
      v_full      := v_full or full18(1,J);
      v_empty     := v_empty or empty18(G_FIFO_LAYER_NUM,J);
      v_progfull  := v_progfull or progfull18(1,J);
      v_progempty := v_progempty or progempty18(G_FIFO_LAYER_NUM,J);
    end loop;
    full        <= v_full;
    empty       <= v_empty;
    po_prog_full   <= v_progfull;
    po_prog_empty  <= v_progempty;
  end process proc_backpressure;

  po_full  <= full;
  po_empty <= empty;

  --! output encoding using last layer FIFO18/36 outputs
  proc_o_data: process(dout36, doutp36, dout18, doutp18)
  begin
    for j in 1 to G_FIFO36_NUM loop
      po_data((J-1)*G_FIFO36_WIDTH+fun_parity_width(G_FIFO36_WIDTH)-1 downto (J-1)*G_FIFO36_WIDTH)
          <= doutp36(G_FIFO_LAYER_NUM,j)(fun_parity_width(G_FIFO36_WIDTH)-1 downto 0);
      po_data(j*G_FIFO36_WIDTH-1 downto (J-1)*G_FIFO36_WIDTH+fun_parity_width(G_FIFO36_WIDTH))
          <= dout36(G_FIFO_LAYER_NUM,j)(G_FIFO36_WIDTH-fun_parity_width(G_FIFO36_WIDTH)-1 downto 0);
    end loop;
    for j in 1 to G_FIFO18_NUM loop
      po_data((j-1)*G_FIFO36_WIDTH/2+fun_parity_width(G_FIFO36_WIDTH/2)+G_FIFO36_WIDTH*G_FIFO36_NUM-1
          downto (j-1)*G_FIFO36_WIDTH/2+G_FIFO36_WIDTH*G_FIFO36_NUM)
          <= doutp18(G_FIFO_LAYER_NUM,j)(fun_parity_width(G_FIFO36_WIDTH/2)-1 downto 0);
      po_data(j*G_FIFO36_WIDTH/2+G_FIFO36_WIDTH*G_FIFO36_NUM-1
          downto (j-1)*G_FIFO36_WIDTH/2+fun_parity_width(G_FIFO36_WIDTH/2)+G_FIFO36_WIDTH*G_FIFO36_NUM)
          <= dout18(G_FIFO_LAYER_NUM,J)(G_FIFO36_WIDTH/2-fun_parity_width(G_FIFO36_WIDTH/2)-1 downto 0);
    end loop;
  end process proc_o_data;

  --! input decoding into first layer FIFO18/36 inputs
  proc_i_data: process(pi_data)
  begin
    for j in 1 to G_FIFO36_NUM loop
      dinp36(1,j)(fun_parity_width(G_FIFO36_WIDTH)-1 downto 0)
          <= pi_data((j-1)*G_FIFO36_WIDTH+fun_parity_width(G_FIFO36_WIDTH)-1 downto (J-1)*G_FIFO36_WIDTH);
      din36(1,j)(G_FIFO36_WIDTH-fun_parity_width(G_FIFO36_WIDTH)-1 downto 0)
          <= pi_data(j*G_FIFO36_WIDTH-1 downto (j-1)*G_FIFO36_WIDTH+fun_parity_width(G_FIFO36_WIDTH));
    end loop;
    for j in 1 to G_FIFO18_NUM loop
      dinp18(1,j)(fun_parity_width(G_FIFO36_WIDTH/2)-1 downto 0)
          <= pi_data((j-1)*G_FIFO36_WIDTH/2+FUN_PARITY_WIDTH(G_FIFO36_WIDTH/2)+G_FIFO36_WIDTH*G_FIFO36_NUM-1
          downto (J-1)*G_FIFO36_WIDTH/2+G_FIFO36_WIDTH*G_FIFO36_NUM);
      din18(1,j)(G_FIFO36_WIDTH/2-fun_parity_width(G_FIFO36_WIDTH/2)-1 downto 0)
          <= pi_data(j*G_FIFO36_WIDTH/2+G_FIFO36_WIDTH*G_FIFO36_NUM-1
          downto (j-1)*G_FIFO36_WIDTH/2+fun_parity_width(G_FIFO36_WIDTH/2)+G_FIFO36_WIDTH*G_FIFO36_NUM);
    end loop;
  end process proc_i_data;

  --! inputs of external FIFO36s
  gen_input_external_fifo36: for J in 1 to G_FIFO36_NUM generate
    wrclk36(1,j)                      <= pi_wr_clk;
    rdclk36(G_FIFO_LAYER_NUM,j)       <= pi_rd_clk;
    wren36(1,j)                       <= pi_wr_ena; -- and not(full);
    rden36(G_FIFO_LAYER_NUM,j)        <= pi_rd_ena; -- and not(empty);
    casprvempty36(1,j)                <= '0';             -- unused input
    casnxtrden36(G_FIFO_LAYER_NUM,j)  <= '0';             -- unused input
    casdin36(1,j)                     <= (others => '0'); -- unused input
    casdinp36(1,j)                    <= (others => '0'); -- unused input
  end generate gen_input_external_fifo36;

  --! inputs of external FIFO18s
  gen_input_external_fifo18: for j in 1 to G_FIFO18_NUM generate
    wrclk18(1,j)                      <= pi_wr_clk;
    rdclk18(G_FIFO_LAYER_NUM,j)       <= pi_rd_clk;
    wren18(1,j)                       <= pi_wr_ena; -- and not(full);
    rden18(G_FIFO_LAYER_NUM,j)        <= pi_rd_ena; -- and not(empty);
    casprvempty18(1,j)                <= '0';             -- unused input
    casnxtrden18(G_FIFO_LAYER_NUM,j)  <= '0';             -- unused input
    casdin18(1,j)                     <= (others => '0'); -- unused input
    casdinp18(1,j)                    <= (others => '0'); -- unused input
  end generate gen_input_external_fifo18;

  gen_multilayer: if G_FIFO_LAYER_NUM > 1 generate

    --! inputs of external FIFO36s those are available only for multilayer case
    gen_input_external_fifo36_multilayer: for j in 1 to G_FIFO36_NUM generate
      wrclk36(G_FIFO_LAYER_NUM,j) <= pi_int_clk;
      rdclk36(1,j)                <= pi_int_clk;
      wren36(G_FIFO_LAYER_NUM,j)  <= '0';             -- unused input
      rden36(1,j)                 <= '0';             -- unused input
      din36(G_FIFO_LAYER_NUM,j)   <= (others => '0'); -- unused input
      dinp36(G_FIFO_LAYER_NUM,j)  <= (others => '0'); -- unused input
    end generate gen_input_external_fifo36_multilayer;

    --! inputs of external FIFO18s those are available only for multilayer case
    gen_input_external_fifo18_multilayer: for j in 1 to G_FIFO18_NUM generate
      wrclk18(G_FIFO_LAYER_NUM,j) <= pi_int_clk;
      rdclk18(1,j)                <= pi_int_clk;
      wren18(G_FIFO_LAYER_NUM,j)  <= '0';             -- unused input
      rden18(1,j)                 <= '0';             -- unused input
      din18(G_FIFO_LAYER_NUM,j)   <= (others => '0'); -- unused input
      dinp18(G_FIFO_LAYER_NUM,j)  <= (others => '0'); -- unused input
    end generate gen_input_external_fifo18_multilayer;

  end generate gen_multilayer;

  --! depth(layer) generation for the FIFO
  gen_depth: for i in 1 to G_FIFO_LAYER_NUM generate

    gen_input_internal: if ((i > 1) and (i < G_FIFO_LAYER_NUM)) generate

      --! inputs of internal FIFO36s
      gen_input_internal_fifo36: for j in 1 to G_FIFO36_NUM generate
        wrclk36(i,j)  <= pi_int_clk;
        rdclk36(i,j)  <= pi_int_clk;
        wren36(i,j)   <= '0';             -- unused input
        rden36(i,j)   <= '0';             -- unused input
        din36(i,j)    <= (others => '0'); -- unused input
        dinp36(i,j)   <= (others => '0'); -- unused input
      end generate gen_input_internal_fifo36;

      --! inputs of internal FIFO18s
      gen_input_internal_fifo18: for j in 1 to G_FIFO18_NUM generate
        wrclk18(i,j)  <= pi_int_clk;
        rdclk18(i,j)  <= pi_int_clk;
        wren18(i,j)   <= '0';             -- unused input
        rden18(i,j)   <= '0';             -- unused input
        din18(i,j)    <= (others => '0'); -- unused input
        dinp18(i,j)   <= (others => '0'); -- unused input
      end generate gen_input_internal_fifo18;

    end generate gen_input_internal;

    gen_cascade: if i > 1 generate

      --! serial cascading of FIFO36s
      gen_cascade_fifo36: for j in 1 to G_FIFO36_NUM generate
        casdin36(I,J)       <= casdout36(i-1,j);
        casdinp36(I,J)      <= casdoutp36(i-1,j);
        casprvempty36(I,J)  <= casnxtempty36(i-1,j);
        casnxtrden36(I-1,J) <= casprvrden36(i,j);
      end generate gen_cascade_fifo36;

      --! serial cascading of fifo18s
      gen_cascade_fifo18: for j in 1 to G_FIFO18_NUM generate
        casdin18(i,j)       <= casdout18(i-1,j);
        casdinp18(i,j)      <= casdoutp18(i-1,j);
        casprvempty18(i,j)  <= casnxtempty18(i-1,j);
        casnxtrden18(i-1,j) <= casprvrden18(i,j);
      end generate gen_cascade_fifo18;

    end generate gen_cascade;

    --! FIFO36 instantiations at each layer of the FIFO
    gen_width_fifo36: for j in 1 to G_FIFO36_NUM generate
      ins_single_fifo36e2: fifo36e2
        generic map (
          CASCADE_ORDER            => fun_no_space(C_FIFO36_GENERICS(i).CASCADE_ORDER),
          CLOCK_DOMAINS            => fun_no_space(C_FIFO36_GENERICS(i).CLOCK_DOMAINS),
          EN_ECC_PIPE              => fun_no_space(C_FIFO36_GENERICS(i).EN_ECC_PIPE),
          EN_ECC_READ              => fun_no_space(C_FIFO36_GENERICS(i).EN_ECC_READ),
          EN_ECC_WRITE             => fun_no_space(C_FIFO36_GENERICS(i).EN_ECC_WRITE),
          FIRST_WORD_FALL_THROUGH  => fun_no_space(C_FIFO36_GENERICS(i).FIRST_WORD_FALL_THROUGH),
          INIT                     => C_FIFO36_GENERICS(i).INIT,
          PROG_EMPTY_THRESH        => C_FIFO36_GENERICS(i).PROG_EMPTY_THRESH,
          PROG_FULL_THRESH         => C_FIFO36_GENERICS(i).PROG_FULL_THRESH,
          IS_RDCLK_INVERTED        => C_FIFO36_GENERICS(i).IS_RDCLK_INVERTED,
          IS_RDEN_INVERTED         => C_FIFO36_GENERICS(i).IS_RDEN_INVERTED,
          IS_RSTREG_INVERTED       => C_FIFO36_GENERICS(i).IS_RSTREG_INVERTED,
          IS_RST_INVERTED          => C_FIFO36_GENERICS(i).IS_RST_INVERTED,
          IS_WRCLK_INVERTED        => C_FIFO36_GENERICS(i).IS_WRCLK_INVERTED,
          IS_WREN_INVERTED         => C_FIFO36_GENERICS(i).IS_WREN_INVERTED,
          RDCOUNT_TYPE             => fun_no_space(C_FIFO36_GENERICS(i).RDCOUNT_TYPE),
          READ_WIDTH               => C_FIFO36_GENERICS(i).READ_WIDTH,
          REGISTER_MODE            => fun_no_space(C_FIFO36_GENERICS(i).REGISTER_MODE),
          RSTREG_PRIORITY          => fun_no_space(C_FIFO36_GENERICS(i).RSTREG_PRIORITY),
          SLEEP_ASYNC              => fun_no_space(C_FIFO36_GENERICS(i).SLEEP_ASYNC),
          SRVAL                    => C_FIFO36_GENERICS(i).SRVAL,
          WRCOUNT_TYPE             => fun_no_space(C_FIFO36_GENERICS(i).WRCOUNT_TYPE),
          WRITE_WIDTH              => C_FIFO36_GENERICS(i).WRITE_WIDTH
        )
        port map (
          casdout        => casdout36(i,j),
          casdoutp       => casdoutp36(i,j),
          casnxtempty    => casnxtempty36(i,j),
          casprvrden     => casprvrden36(i,j),
          dbiterr        => open, -- unused input
          eccparity      => open, -- unused input
          sbiterr        => open, -- unused input
          dout           => dout36(i,j),
          doutp          => doutp36(i,j),
          empty          => empty36(i,j),
          full           => full36(i,j),
          progempty      => progempty36(i,j),
          progfull       => progfull36(i,j),
          rdcount        => open, -- unused input
          rderr          => open, -- unused input
          rdrstbusy      => open, -- unused input
          wrcount        => open, -- unused input
          wrerr          => open, -- unused input
          wrrstbusy      => open, -- unused input
          casdin         => casdin36(i,j),
          casdinp        => casdinp36(i,j),
          casdomux       => '0',  -- unused input
          casdomuxen     => '1',  -- unused input
          casnxtrden     => casnxtrden36(i,j),
          casoregimux    => '0',  -- unused input
          casoregimuxen  => '1',  -- unused input
          casprvempty    => casprvempty36(i,j),
          injectdbiterr  => '0',  -- unused input
          injectsbiterr  => '0',  -- unused input
          rdclk          => rdclk36(i,j),
          rden           => rden36(i,j),
          regce          => '1',  -- unused input
          rstreg         => '0',  -- unused input
          sleep          => '0',  -- unused input
          rst            => pi_reset,
          wrclk          => wrclk36(i,j),
          wren           => wren36(i,j),
          din            => din36(i,j),
          dinp           => dinp36(i,j)
        );
    end generate gen_width_fifo36;

    --! FIFO18 instantiations at each layer of the FIFO
    gen_width_fifo18: for j in 1 to G_FIFO18_NUM generate
      ins_single_fifo18e2: fifo18e2
        generic map (
          CASCADE_ORDER            => fun_no_space(C_FIFO18_GENERICS(i).CASCADE_ORDER),
          CLOCK_DOMAINS            => fun_no_space(C_FIFO18_GENERICS(i).CLOCK_DOMAINS),
          FIRST_WORD_FALL_THROUGH  => fun_no_space(C_FIFO18_GENERICS(i).FIRST_WORD_FALL_THROUGH),
          INIT                     => C_FIFO18_GENERICS(i).INIT,
          PROG_EMPTY_THRESH        => C_FIFO18_GENERICS(i).PROG_EMPTY_THRESH,
          PROG_FULL_THRESH         => C_FIFO18_GENERICS(i).PROG_FULL_THRESH,
          IS_RDCLK_INVERTED        => C_FIFO18_GENERICS(i).IS_RDCLK_INVERTED,
          IS_RDEN_INVERTED         => C_FIFO18_GENERICS(i).IS_RDEN_INVERTED,
          IS_RSTREG_INVERTED       => C_FIFO18_GENERICS(i).IS_RSTREG_INVERTED,
          IS_RST_INVERTED          => C_FIFO18_GENERICS(i).IS_RST_INVERTED,
          IS_WRCLK_INVERTED        => C_FIFO18_GENERICS(i).IS_WRCLK_INVERTED,
          IS_WREN_INVERTED         => C_FIFO18_GENERICS(i).IS_WREN_INVERTED,
          RDCOUNT_TYPE             => fun_no_space(C_FIFO18_GENERICS(i).RDCOUNT_TYPE),
          READ_WIDTH               => C_FIFO18_GENERICS(i).READ_WIDTH,
          REGISTER_MODE            => fun_no_space(C_FIFO18_GENERICS(i).REGISTER_MODE),
          RSTREG_PRIORITY          => fun_no_space(C_FIFO18_GENERICS(i).RSTREG_PRIORITY),
          SLEEP_ASYNC              => fun_no_space(C_FIFO18_GENERICS(i).SLEEP_ASYNC),
          SRVAL                    => C_FIFO18_GENERICS(i).SRVAL,
          WRCOUNT_TYPE             => fun_no_space(C_FIFO18_GENERICS(i).WRCOUNT_TYPE),
          WRITE_WIDTH              => C_FIFO18_GENERICS(i).WRITE_WIDTH
        )
        port map (
          casdout        => casdout18(i,j),
          casdoutp       => casdoutp18(i,j),
          casnxtempty    => casnxtempty18(i,j),
          casprvrden     => casprvrden18(i,j),
          dout           => dout18(i,j),
          doutp          => doutp18(i,j),
          empty          => empty18(i,j),
          full           => full18(i,j),
          progempty      => progempty18(i,j),
          progfull       => progfull18(i,j),
          rdcount        => open, -- unused input
          rderr          => open, -- unused input
          rdrstbusy      => open, -- unused input
          wrcount        => open, -- unused input
          wrerr          => open, -- unused input
          wrrstbusy      => open, -- unused input
          casdin         => casdin18(i,j),
          casdinp        => casdinp18(i,j),
          casdomux       => '0',  -- unused input
          casdomuxen     => '1',  -- unused input
          casnxtrden     => casnxtrden18(i,j),
          casoregimux    => '0',  -- unused input
          casoregimuxen  => '1',  -- unused input
          casprvempty    => casprvempty18(i,j),
          rdclk          => rdclk18(i,j),
          rden           => rden18(i,j),
          regce          => '1',  -- unused input
          rstreg         => '0',  -- unused input
          sleep          => '0',  -- unused input
          rst            => pi_reset,
          wrclk          => wrclk18(i,j),
          wren           => wren18(i,j),
          din            => din18(i,j),
          dinp           => dinp18(i,j)
        );
    end generate gen_width_fifo18;

  end generate gen_depth;

end architecture rtl;
