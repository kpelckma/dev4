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
--! @author Wojciech Jalmuzna
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Radoslaw Rybaniec
--! @author Andrea Bellandi <andrea.bellandi@desy.de>
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! main II BASE with II ITEMS, added II ADAPTER for IBUS support with acknowledge
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

--! Basic definitions of IBUS

--! Internal BUS (IBUS) is the internal bus used in the applications of MSK Firmware
--! repository.
package bus_ii is

  --! Output signals of IBUS. Through this record the application send data/commands to the bus
  type t_ibus_o is record
    addr   : std_logic_vector(31 downto 0);
    data   : std_logic_vector(31 downto 0);
    rena   : std_logic;
    wena   : std_logic;
    clk    : std_logic;
  end record t_ibus_o;

  --! Output signals of IBUS. Through this record the application send data/commands to the bus
  type t_ibus_i is record
    clk    : std_logic;
    data   : std_logic_vector(31 downto 0);
    rack   : std_logic;
    wack   : std_logic;
  end record t_ibus_i;

  --! Array of IBUS outputs
  type t_ibus_o_array is array (natural range<>) of t_ibus_o;

  --! Array of IBUS inputs
  type t_ibus_i_array is array (natural range<>) of t_ibus_i;

  --! Default IBUS connections for the output (All entries equals 0)
  constant C_IBUS_O_DEFAULT : t_ibus_o := (addr => (others => '0'),
                                             data => (others => '0'),
                                             rena => '0',
                                             wena => '0',
                                             clk  => '0');

  --! Default IBUS connections for the input (All entries equals 0)
  constant C_IBUS_I_DEFAULT : t_ibus_i := (clk  => '0',
                                             data => (others => '0'),
                                             rack => '0',
                                             wack => '0');

  --subtype  TN is natural;
--
-- ITEM types
--
  --! Area like element
  constant VII_AREA : natural := 0;
  constant VII_EXTB : natural := 0;
  --! Word like element
  constant VII_WORD : natural := 1;
  --! Bits like element
  constant VII_BITS : natural := 2;


--
-- WRITE permissions
--
  --! Write permission denied
  constant VII_WNOACCESS : natural := 3;
  --! Write permission allowed
  constant VII_WACCESS   : natural := 4;


--
-- READ permissions
--
  --! Read permission denied
  constant VII_RNOACCESS : natural := 5;
  --! Read permission allowed from outside
  constant VII_REXTERNAL : natural := 6;
  --! Read permission allowed
  constant VII_RINTERNAL : natural := 7;

  --! Signed numeric element
  constant VII_SIGNED   : natural := 7;
  --! Unsigned numeric element
  constant VII_UNSIGNED : natural := 8;


  --
  -- BASIC structures
  --

  --! list
  type TVIIItemDeclList is array (natural range<>) of natural;
  type TVII is array (natural range<>) of natural;


  --
  -- ARRAY of params size
  --
  --! number of elements in TVII
  constant ITEM_DESC_SIZE : natural := 11;

  --! Item type
  constant ITEM_TYPE    : natural := 0;

  --! Item name
  constant ITEM_NAME    : natural := 1;

  --! Item width
  constant ITEM_WIDTH   : natural := 2;

  --! Item count
  constant ITEM_COUNT   : natural := 3;

  --! Item write permission
  constant ITEM_WPERM   : natural := 4;

  --! Item read permission
  constant ITEM_RPERM   : natural := 5;

  --! Item address
  constant ITEM_ADDR    : natural := 6;

  --! Item signed/unsigned
  constant ITEM_SIGNED  : natural := 7;

  -- are these three only defined once in a TVII?
  constant ITEM_WR_POS  : natural := 8;
  constant ITEM_RD_POS  : natural := 9;
  constant ITEM_ENA_POS : natural := 10;

  --
  -- Virtual Prams
  --
  constant ITEM_VEC_COUNT    : natural := 0;
  --
  -- MISC functions
  --
  function VIIGetParam (par  : TVII; item_id : natural; name : natural) return natural;
  function VIIGetVParam (par : TVII; item_id : natural; name : natural) return natural;
  function VIIIntLength (par : TVII) return natural;
  function VIIExtLength (par : TVII) return natural;
  function VIIEnaLength (par : TVII) return natural;

  --
  -- INIT functions
  --
  function TVIICreate(list : TVIIItemDeclList; addr_width, data_width : natural) return TVII;


  --
  -- DATA function
  --
  function IIPutItem(list : TVII; name : natural; index : natural; data : std_logic_vector) return std_logic_vector;
  function IIGetItem(list : TVII; vec : std_logic_vector; name : natural; index : natural) return std_logic_vector;

  --
  -- ENA functions
  --
  function IIGetItemEna(list : TVII; vec : std_logic_vector; name : natural; index : natural) return std_logic;
  function IIGetItemStr(list : TVII; vec : std_logic_vector; name : natural; index : natural; str : std_logic) return std_logic;

  --
  -- INTERFACE functions
  --
  function GetCheckSum (list : TVIIItemDeclList; ver : natural) return std_logic_vector;

end bus_ii;


--******************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;


package body bus_ii is

  --! Extract parameter of intem `item_id` named `name` from `par`
  function VIIGetParam(par : TVII; item_id : natural; name : natural) return natural is
  begin
    return par(ITEM_DESC_SIZE*item_id+name);
  end function;

  --! Extract parameter of intem `item_id` named `name` from `par`
  function VIIGetVParam(par : TVII; item_id : natural; name : natural) return natural is
  begin
    if name = ITEM_VEC_COUNT then
      if VIIGetParam(par, item_id, ITEM_TYPE) = VII_AREA then
        return 1; -- is it because Area is a single entity?
      else
        return VIIGetParam(par, item_id, ITEM_COUNT);
      end if; -- return the counts of elements
    end if;
  end function;

  --! Return a new TVII from a list of items. The address and data width has to be passed
  function TVIICreate(list : TVIIItemDeclList; addr_width, data_width : natural) return TVII is
    variable v_int_pos : integer;
    variable v_ext_pos : integer;
    variable v_ena_pos : integer;

    -- Returned TVII. variable. bit cumbersome. IS the ITEM_DESC trimmed?
    variable result     : TVII(0 to list'length/(ITEM_DESC_SIZE-3)*ITEM_DESC_SIZE-1 +3);

    variable item_count : natural;
  begin
    v_int_pos := -1;
    v_ext_pos := -1;
    v_ena_pos := -1;


    for I in 0 to list'length/(ITEM_DESC_SIZE-3)-1 loop
      if list(I*(ITEM_DESC_SIZE-3)) = VII_WORD then
        item_count := list(I*(ITEM_DESC_SIZE-3)+3); -- index 3. Element counts
      else
        item_count := 1; -- otherwise 0
      end if;

      for J in 0 to (ITEM_DESC_SIZE-3)-1 loop
        result(I*ITEM_DESC_SIZE+J) := list(I*(ITEM_DESC_SIZE-3)+J); -- copy of elements except the last three.
      end loop;

      if result(I*ITEM_DESC_SIZE+4) = VII_WACCESS then -- if write permission
                                                       -- add the size to internal position
        v_int_pos                  := v_int_pos+result(I*ITEM_DESC_SIZE+2)*item_count;
        result(I*ITEM_DESC_SIZE+8) := v_int_pos;
      end if;

      if result(I*ITEM_DESC_SIZE+5) = VII_REXTERNAL then -- if external read add the size to
                                                         -- internal position

        v_ext_pos                  := v_ext_pos+result(I*ITEM_DESC_SIZE+2)*item_count;
        result(I*ITEM_DESC_SIZE+9) := v_ext_pos;
      end if;

      v_ena_pos                   := v_ena_pos + item_count; -- add item count to ena
                                                             -- pos
      result(I*ITEM_DESC_SIZE+10) := v_ena_pos;
    end loop;

    result(result'length-3) := v_ena_pos;
    result(result'length-2) := v_int_pos;
    result(result'length-1) := v_ext_pos;

    return result;
  end;

  -- internal length
  function VIIIntLength(par : TVII) return natural is
  begin
    return par(par'length-2)+1;
  end function;

  -- external length
  function VIIExtLength(par : TVII) return natural is
  begin
    return par(par'length-1)+1;
  end function;

  -- enable position
  function VIIEnaLength(par : TVII) return natural is
  begin
    return par(par'length-3)+1;
  end function;

--
-- DATA functions
--
-- write on TVII
  function IIPutItem(list : TVII; name : natural; index : natural; data : std_logic_vector) return std_logic_vector is
    variable result   : std_logic_vector(VIIExtLength(list)-1 downto 0);
    variable rd_pos   : natural := VIIGetParam(list, name, ITEM_RD_POS);
    variable rd_width : natural := VIIGetParam(list, name, ITEM_WIDTH);
  begin
    result                                                           := (others => '0');
    result(rd_pos-rd_width*index downto rd_pos-rd_width*(index+1)+1) := data;
    return result;
  end function;

  function IIGetItem(list : TVII; vec : std_logic_vector; name : natural; index : natural) return std_logic_vector is
    variable result   : std_logic_vector(VIIGetParam(list, name, ITEM_WIDTH)-1 downto 0);
    variable wr_pos   : natural := VIIGetParam(list, name, ITEM_WR_POS);
    variable wr_width : natural := VIIGetParam(list, name, ITEM_WIDTH);
  begin
    result := (others => '0');
    result := vec(wr_pos-wr_width*index downto wr_pos-wr_width*(index+1)+1);
    return result;
  end function;

  function IIGetItemEna(list : TVII; vec : std_logic_vector; name : natural; index : natural) return std_logic is
    variable result               : std_logic_vector(0 downto 0);
    constant C_TEMP_ENA_INDEX_L : natural := VIIGetParam(list, name, ITEM_ENA_POS);
    --constant C_TEMP_ENA_INDEX_R : natural := C_TEMP_ENA_INDEX_L - VIIGetParam(list,name,ITEM_VEC_COUNT) ;
  begin
    result := vec(C_TEMP_ENA_INDEX_L-index downto C_TEMP_ENA_INDEX_L-index);
    return result(0);
  end function;

  function IIGetItemStr(list : TVII; vec : std_logic_vector; name : natural; index : natural; str : std_logic) return std_logic is
    variable result : std_logic;
  begin
    if str = '0' then
      result := IIGetItemEna(list, vec, name, index);
    else
      result := '0';
    end if;

    return result;
  end function;

-- list -- is data to count the checksum for; -- size -- is a length of list;
-- ver -- "16" means a 16 bit vector as a result and "32" means a 32 bit vector as a result, default is 32bits
  function GetCheckSum(list : TVIIItemDeclList; ver : natural) return std_logic_vector is
    variable tmp  : std_logic_vector(63 downto 0);
    variable poly : std_logic_vector(32 downto 0);
  begin
    tmp(63 downto 32) := (others => '0');
    tmp(31 downto 0)  := conv_std_logic_vector(list(list'length-1), 32);
    if(ver = 16) then
      poly := "000000000000000011000000000000101";  --CRC-16 IBM
    else
      poly := "100000100110000010001110110110111";  --CRC-32 Ethernet
    end if;
    for i in list'length-1 downto 0 loop
      tmp(63 downto 32) := tmp(31 downto 0);
      if(i /= 0) then
        tmp(31 downto 0) := conv_std_logic_vector(list(i-1), 32);
      else
        tmp(31 downto 0) := (others => '0');
      end if;
      for k in 0 to 31 loop
        if(tmp(63-k) /= '0')then
          tmp(63-k downto 63-k-ver) := tmp(63-k downto 63-k-ver) xor poly(ver downto 0);
        end if;
      end loop;
    end loop;
    return tmp(31 downto 32-ver);
  end GetCheckSum;

end bus_ii;



--******************************************************************************
library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

use work.bus_ii.all;

entity ii_item is
  generic (
    GEN_ADDR       : natural;
    GEN_WORD_WIDTH : natural := 16;
    GEN_WORD_COUNT : natural := 1;
    GEN_VEC_COUNT  : natural := 1;
    GEN_OFFSET     : natural := 0;
    GEN_WPERM      : natural;
    GEN_RPERM      : natural;
    GEN_SIGNED     : natural
    ) ;
  port (
    P_I_CLK   : in std_logic;
    P_I_ENA_N : in std_logic;

    P_I_ADDR : in  std_logic_vector(31 downto 0);
    P_I_DATA : in  std_logic_vector(31 downto 0);
    P_O_DATA : out std_logic_vector(31 downto 0);

    P_I_OPER_N   : in std_logic;
    P_I_WRITE_N  : in std_logic;
    P_I_STROBE_N : in std_logic;
    P_I_RESET_N  : in std_logic;

    P_I_ACK_N : in  std_logic;
    P_O_ACK_N : out std_logic;

    P_O_WR_ENA : out std_logic_vector(GEN_VEC_COUNT-1 downto 0);
    P_O_RD_ENA : out std_logic_vector(GEN_VEC_COUNT-1 downto 0);

    P_O_VEC_INT : out std_logic_vector(GEN_VEC_COUNT*GEN_WORD_WIDTH-1 downto 0);
    P_I_VEC_EXT : in  std_logic_vector(GEN_VEC_COUNT*GEN_WORD_WIDTH-1 downto 0)
    ) ;
end ii_item;

architecture Behavioral of ii_item is

  function TEMP_Resize(arg : std_logic_vector ; length : natural ) return std_logic_vector is
    variable result : std_logic_vector(length-1 downto 0) ;
  begin
    if length = arg'length then
      return arg ;
    end if ;

    if length < arg'length then
      if arg( arg'length-1 ) = '1' and AND_REDUCE( arg( arg'length-1 downto length-1 ) ) = '0' then
        result := ( others => '0' ) ;
        result(length-1) := '1' ;
        return result ;
      end if ;

      if arg( arg'length-1 ) = '0' and OR_REDUCE( arg( arg'length-1 downto length-1 ) ) = '1' then
        result := ( others => '1' ) ;
        result(length-1) := '0' ;
        return result ;
      end if ;

      return arg(length-1 downto 0) ;
    else
      result := ( others => arg(arg'length-1) ) ;
      result(arg'length-1 downto 0) := arg ;
      return result ;
    end if ;
  end function ;


  -- internal storage
  type   TWordArray is array(GEN_VEC_COUNT-1 downto 0) of std_logic_vector(GEN_WORD_WIDTH-1 downto 0);
  signal SIG_INT_REGS : TWordArray:= (others => (others => '0'));
  signal SIG_EXT_REGS : TWordArray:= (others => (others => '0'));

  -- signals
  signal SIG_REG_ENA : std_logic;

  -- data
  signal SIG_DATA_OUT : std_logic_vector(31 downto 0) := (others => '0');

  attribute keep                 : string;
  attribute keep of SIG_DATA_OUT : signal is "true";
begin
  process (P_I_CLK, P_I_RESET_N)
  begin
    if P_I_RESET_N = '0' then
      SIG_REG_ENA <= '0';
    elsif rising_edge(P_I_CLK) then
      if ( P_I_OPER_N = '0' ) and  (to_integer(unsigned(P_I_ADDR)) >= GEN_ADDR ) and (to_integer(unsigned(P_I_ADDR)) < GEN_ADDR+GEN_WORD_COUNT )then
        SIG_REG_ENA <= '1';
      else
        SIG_REG_ENA <= '0';
      end if;
    end if;
  end process;


  -- write and read enable signals
  -- process (SIG_REG_ENA, P_I_ADDR, P_I_WRITE_N)
  process (SIG_REG_ENA, P_I_ADDR, P_I_WRITE_N,P_I_STROBE_N)
  begin
    P_O_WR_ENA <= (others => '0');
    P_O_RD_ENA <= (others => '0');

    if SIG_REG_ENA = '1' and P_I_STROBE_N = '0' and P_I_WRITE_N = '0' then
      if GEN_VEC_COUNT > 1 then
        if GEN_WPERM /= VII_WNOACCESS then
          P_O_WR_ENA(to_integer(unsigned(P_I_ADDR))-GEN_ADDR) <= (not P_I_WRITE_N);
        end if;
      else
        if GEN_WPERM /= VII_WNOACCESS then
          P_O_WR_ENA(0) <= (not P_I_WRITE_N);
        end if;
      end if;
    end if;
    if SIG_REG_ENA = '1' and P_I_STROBE_N = '0' and P_I_WRITE_N = '1' then
      if GEN_VEC_COUNT > 1 then
        if GEN_RPERM /= VII_RNOACCESS then
          P_O_RD_ENA(to_integer(unsigned(P_I_ADDR))-GEN_ADDR) <= P_I_WRITE_N;
        end if;
      else
        if GEN_RPERM /= VII_RNOACCESS then
          P_O_RD_ENA(0) <= P_I_WRITE_N;
        end if;
      end if;
    end if;

  end process;


  -- internal write regs
  gen1 : if GEN_WPERM /= VII_WNOACCESS generate
    process (P_I_CLK, P_I_RESET_N)
    begin
      if P_I_RESET_N = '0' then
        for I in 0 to GEN_VEC_COUNT-1 loop SIG_INT_REGS(I) <= (others => '0'); end loop;

      elsif rising_edge(P_I_CLK) then
        if SIG_REG_ENA = '1' and P_I_STROBE_N = '0' and P_I_WRITE_N = '0' then
          if GEN_VEC_COUNT = 1 then
            SIG_INT_REGS(0) <= P_I_DATA(GEN_WORD_WIDTH-1 downto 0);
          else
            SIG_INT_REGS(to_integer(unsigned(P_I_ADDR))-GEN_ADDR) <= P_I_DATA(GEN_WORD_WIDTH-1 downto 0);
          end if;
        end if;
      end if;
    end process;

    process (SIG_INT_REGS)
      variable v_temp : std_logic_vector(GEN_VEC_COUNT*GEN_WORD_WIDTH-1 downto 0);
    begin
      for I in 0 to GEN_VEC_COUNT-1 loop
        v_temp((I+1)*GEN_WORD_WIDTH-1 downto (I)*GEN_WORD_WIDTH) := SIG_INT_REGS(GEN_VEC_COUNT-1-I);
      end loop;

      P_O_VEC_INT <= v_temp;
    end process;
  end generate;

  gen2 : if GEN_RPERM = VII_RINTERNAL generate
    process (P_I_CLK, P_I_RESET_N)
    begin
      if rising_edge(P_I_CLK) then
        if SIG_REG_ENA = '1' and P_I_STROBE_N = '0' and P_I_WRITE_N = '1' then
          if GEN_SIGNED = VII_UNSIGNED then
            SIG_DATA_OUT(GEN_WORD_WIDTH-1 downto 0) <= SIG_INT_REGS(to_integer(unsigned(P_I_ADDR))-GEN_ADDR);
          else
            SIG_DATA_OUT <= TEMP_Resize(SIG_INT_REGS(to_integer(unsigned(P_I_ADDR))-GEN_ADDR), 32);
          end if;
        end if;
      end if;
    end process;
  end generate;

  gen3 : if GEN_RPERM = VII_REXTERNAL generate
    process (P_I_CLK, P_I_RESET_N)
      variable v_index : natural;
    begin
      if rising_edge(P_I_CLK) then
        if SIG_REG_ENA = '1' and P_I_STROBE_N = '0' and P_I_WRITE_N = '1' then
          v_index := to_integer(unsigned(P_I_ADDR))-GEN_ADDR;
          if GEN_VEC_COUNT > 1 then
            if GEN_SIGNED = VII_UNSIGNED then
              SIG_DATA_OUT(GEN_WORD_WIDTH-1 downto 0) <= SIG_EXT_REGS(v_index);
            else
              SIG_DATA_OUT <= TEMP_Resize(SIG_EXT_REGS(v_index), 32);
            end if;
          else
            if GEN_SIGNED = VII_UNSIGNED then
              SIG_DATA_OUT(GEN_WORD_WIDTH-1 downto 0) <= P_I_VEC_EXT;
            else
              SIG_DATA_OUT <= std_logic_vector(resize(signed(P_I_VEC_EXT),32)) ;--TEMP_Resize(P_I_VEC_EXT, 32);
            end if;
          end if;
        end if;
      end if;
    end process;

    process (P_I_VEC_EXT)
      variable v_temp : std_logic_vector(GEN_VEC_COUNT*GEN_WORD_WIDTH-1 downto 0);
    begin
      for I in 0 to GEN_VEC_COUNT-1 loop
        SIG_EXT_REGS(GEN_VEC_COUNT-I-1) <= P_I_VEC_EXT((I+1)*GEN_WORD_WIDTH-1 downto I*GEN_WORD_WIDTH);
      end loop;
    end process;
  end generate;

  P_O_DATA <= SIG_DATA_OUT when SIG_REG_ENA = '1' else (others => '0');

end Behavioral;





--******************************************************************************
library ieee;
use ieee.std_logic_1164.all;

use work.bus_ii.all;

entity ii_base is
  generic (
    IIPar        : TVII;
    II_DATA_SIZE : natural;
    II_ADDR_SIZE : natural
    );
  port(
    ii_addr     : in  std_logic_vector(II_ADDR_SIZE-1 downto 0);
    ii_data_in  : in  std_logic_vector(II_DATA_SIZE-1 downto 0);
    ii_data_out : out std_logic_vector(II_DATA_SIZE-1 downto 0);
    ii_operN    : in  std_logic;
    ii_writeN   : in  std_logic;
    ii_strobeN  : in  std_logic;
    ii_resetN   : in  std_logic;

    ii_ackN : out std_logic;
    ii_enaN : in  std_logic;
    ii_clk  : in  std_logic;

    IIVecInt  : out std_logic_vector(VIIIntLength(IIPar)-1 downto 0);
    IIVecExt  : in  std_logic_vector(VIIExtLength(IIPar)-1 downto 0);
    IIVecWEna : out std_logic_vector(VIIEnaLength(IIPar)-1 downto 0);
    IIVecREna : out std_logic_vector(VIIEnaLength(IIPar)-1 downto 0)

    );
end ii_base;


architecture ARCH of ii_base is
  constant C_ITEM_COUNT : natural := (IIPar'length-3)/ITEM_DESC_SIZE;

  type   TDataArray is array(0 to C_ITEM_COUNT-1) of std_logic_vector(31 downto 0);
  signal DataArray : TDataArray := (others => (others => '0') ) ;

  signal SIG_ACK : std_logic_vector(C_ITEM_COUNT-1 downto 0);
begin

  gen1 : for I in 0 to C_ITEM_COUNT-1 generate
  begin
    gen4 : if VIIGetParam(IIPar, I, ITEM_COUNT) > 0 generate
      signal SIG_TEMP_INT : std_logic_vector(VIIGetVParam(IIPar, I, ITEM_VEC_COUNT)* VIIGetParam(IIPar, I, ITEM_WIDTH)-1 downto 0);
      signal SIG_TEMP_EXT : std_logic_vector(VIIGetVParam(IIPar, I, ITEM_VEC_COUNT)* VIIGetParam(IIPar, I, ITEM_WIDTH)-1 downto 0);
    begin

      gen2 : if VIIGetParam(IIPar, I, ITEM_WPERM) = VII_WACCESS and VIIGetParam(IIPar, I, ITEM_TYPE) /= VII_AREA generate
        IIVecInt(VIIGetParam(IIPar, I, ITEM_WR_POS) downto VIIGetParam(IIPar, I, ITEM_WR_POS)-SIG_TEMP_INT'length+1) <= SIG_TEMP_INT;
      end generate;

      gen3 : if VIIGetParam(IIPar, I, ITEM_RPERM) = VII_REXTERNAL generate
        SIG_TEMP_EXT <= IIVecExt(VIIGetParam(IIPar, I, ITEM_RD_POS) downto VIIGetParam(IIPar, I, ITEM_RD_POS)-SIG_TEMP_INT'length+1);
      end generate;

      assert false report "generating II item: " & integer'image(I) & " , address: " & integer'image(VIIGetParam(IIPar, I, ITEM_ADDR)) & " , width: " & integer'image(VIIGetParam(IIPar, I, ITEM_WIDTH))severity note;

      ii_item : entity work.ii_item
        generic map (
          VIIGetParam(IIPar, I, ITEM_ADDR),
          VIIGetParam(IIPar, I, ITEM_WIDTH),
          VIIGetParam(IIPar, I, ITEM_COUNT),
          VIIGetVParam(IIPar, I, ITEM_VEC_COUNT),
          0,
          VIIGetParam(IIPar, I, ITEM_WPERM),
          VIIGetParam(IIPar, I, ITEM_RPERM),
          VIIGetParam(IIPar, I, ITEM_SIGNED))
        port map (
          ii_clk,
          ii_enaN,
          ii_addr,
          ii_data_in,
          DataArray(I),
          ii_operN,
          ii_writeN,
          ii_strobeN,
          ii_resetN,
          '0',
          SIG_ACK(I),
          IIVecWEna(VIIGetParam(IIPar, I, ITEM_ENA_POS) downto VIIGetParam(IIPar, I, ITEM_ENA_POS) - VIIGetVParam(IIPar, I, ITEM_VEC_COUNT)+1),
          IIVecREna(VIIGetParam(IIPar, I, ITEM_ENA_POS) downto VIIGetParam(IIPar, I, ITEM_ENA_POS) - VIIGetVParam(IIPar, I, ITEM_VEC_COUNT)+1),
          SIG_TEMP_INT,
          SIG_TEMP_EXT
          ) ;
    end generate;
  end generate;


  process (DataArray, ii_writeN)
    variable v_data : std_logic_vector(31 downto 0);
  begin
    if ii_writeN = '1' then
      v_data := (others => '0');
      for I in 0 to C_ITEM_COUNT-1 loop
        v_data := v_data or DataArray(I);
      end loop;
      ii_data_out <= v_data;
    else
      ii_data_out <= (others => '0');
    end if;
  end process;
end ARCH;



--------------------------------------------------------------------------------------------------------------------------------
--! Adapter for the II interface
--------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.math_real.all;

use work.bus_ii.all;

library desy;
use desy.common_types.all;
use desy.common_numarray.all;

entity ii_adapter is
  generic (
    G_II_AS     : TVII;
    G_TIMEOUT   : natural := 1000;         -- timeout for external bus
    G_EXT_BUS   : natural := 0;            -- number of external module buses
    G_EXT_ID    : t_natural_vector := (0 => 0 )
  );
  port (
    pi_clock  : in  std_logic;

    pi_ibus   : in   t_ibus_o;
    po_ibus   : out  t_ibus_i;

    pi_ibus_ext_o  : in  t_ibus_i_array(g_ext_bus-1 downto 0) := (others => c_ibus_i_default);  -- external module bus output
    po_ibus_ext_i  : out t_ibus_o_array(g_ext_bus-1 downto 0) := (others => c_ibus_o_default);  -- external module bus input

    po_strobe_n : out std_logic;
    po_write_n  : out std_logic;
    po_data     : out std_logic_vector(31 downto 0);
    po_addr     : out std_logic_vector(31 downto 0);

    po_vecint   : out std_logic_vector(viiintlength(g_ii_as)-1 downto 0);
    pi_vecext   : in  std_logic_vector(viiextlength(g_ii_as)-1 downto 0);
    po_vecrena  : out std_logic_vector(viienalength(g_ii_as)-1 downto 0);
    po_vecwena  : out std_logic_vector(viienalength(g_ii_as)-1 downto 0)
  );
end entity ii_adapter;


architecture arch of ii_adapter is

  signal sig_vecint    : std_logic_vector(viiintlength(g_ii_as)-1 downto 0);
  signal sig_vecext    : std_logic_vector(viiextlength(g_ii_as)-1 downto 0);
  signal sig_vecrena   : std_logic_vector(viienalength(g_ii_as)-1 downto 0);
  signal sig_vecwena   : std_logic_vector(viienalength(g_ii_as)-1 downto 0);

  signal sig_ii_write_n  : std_logic;
  signal sig_ii_strobe_n : std_logic;

begin

    po_ibus.clk <= pi_clock;
    po_strobe_n <= sig_ii_strobe_n;
    po_write_n  <= sig_ii_write_n;

    po_data     <= pi_ibus.data;
    po_addr     <= pi_ibus.addr;

    --=========================================================================
    -- generate external buses handling
    GEN_EXT_BUS: if G_EXT_BUS >= 1 generate
      signal sig_loc_rena      : std_logic_vector(g_ext_bus-1 downto 0) ;
      signal sig_loc_rena_prev : std_logic_vector(g_ext_bus-1 downto 0) ;
      signal sig_loc_wena      : std_logic_vector(g_ext_bus-1 downto 0) ;
      signal sig_loc_wena_prev : std_logic_vector(g_ext_bus-1 downto 0) ;
      type t_ext_vect is array (natural range<>) of std_logic_vector(viiextlength(g_ii_as)-1 downto 0);

      signal sig_vecext_ext    : t_ext_vect(g_ext_bus-1 downto 0) ;
      signal sig_ext_rena      : std_logic;
      signal sig_ext_rack      : std_logic;
      signal sig_ext_wena      : std_logic;
      signal sig_ext_wack      : std_logic;
      signal sig_ext_rena_prev : std_logic;
      signal sig_ext_wena_prev : std_logic;

      signal sig_wait_for_ext  : std_logic := '0' ;
      signal sig_str_pipe      : std_logic_vector(7 downto 0) := (others => '1');
    begin
      -- check EXT IDs
      assert false report "Generate II with external buses: " & integer'image(G_EXT_BUS) severity note;
      GEN_EXTCHECK: for I in 0 to G_EXT_BUS-1 generate
        assert G_EXT_ID(I) > 0 report "Set proper EXT ID for external bus I: " & integer'image(I)  severity failure;
      end generate;

      -----------------------------------------------------------------------
      GEN_I: for I in 0 to G_EXT_BUS-1 generate
        constant C_ADDR_WIDTH : integer := integer(ceil(log2(real(VIIGetParam(G_II_AS, G_EXT_ID(I), ITEM_COUNT)))));
      begin
        assert false report "GEN EXT ID:" & integer'image(G_EXT_ID(I)) & ", Address width:" & integer'image(C_ADDR_WIDTH) & ", Address: " & integer'image(VIIGetParam(G_II_AS, G_EXT_ID(I), ITEM_ADDR)) severity note;

        po_ibus_ext_i(i).addr(c_addr_width+1 downto 0)  <= pi_ibus.addr(c_addr_width+1 downto 0);
        po_ibus_ext_i(i).addr(31 downto c_addr_width+2) <= (others => '0' );
        po_ibus_ext_i(i).data                             <= pi_ibus.data;
        po_ibus_ext_i(i).rena <= '1' when sig_loc_rena(i) = '1' and sig_loc_rena_prev(i) = '0' else '0' ; -- one clock cycle strobe
        po_ibus_ext_i(i).wena <= '1' when sig_loc_wena(i) = '1' and sig_loc_wena_prev(i) = '0' else '0' ; -- one clock cycle strobe
        po_ibus_ext_i(i).clk  <= pi_clock;

        sig_loc_rena(i) <= iigetitemstr(g_ii_as, sig_vecrena, g_ext_id(i), 0, sig_ii_strobe_n);
        sig_loc_wena(i) <= iigetitemstr(g_ii_as, sig_vecwena, g_ext_id(i), 0, sig_ii_strobe_n);

        sig_loc_rena_prev(i) <= sig_loc_rena(i) when rising_edge(pi_clock);
        sig_loc_wena_prev(i) <= sig_loc_wena(i) when rising_edge(pi_clock);

      end generate;

      -----------------------------------------------------------------------
      process(sig_vecext_ext,pi_ibus_ext_o)
      begin
        for I in 0 to G_EXT_BUS-1 loop
          if i = 0 then
            sig_vecext_ext(0) <= iiputitem(g_ii_as, g_ext_id(i) , 0, pi_ibus_ext_o(i).data(viigetparam(g_ii_as, g_ext_id(i), item_width)-1 downto 0));
          else
            sig_vecext_ext(i) <= sig_vecext_ext(i-1) or iiputitem(g_ii_as, g_ext_id(i) , 0, pi_ibus_ext_o(i).data(viigetparam(g_ii_as, g_ext_id(i), item_width)-1 downto 0));
          end if;
        end loop;
      end process;

      SIG_VECExt  <= PI_VECEXT or SIG_VECExt_EXT(G_EXT_BUS-1) ;
      -----------------------------------------------------------------------

      process(pi_clock)
        variable v_str_pipe     : std_logic_vector(7 downto 0) := (others => '1');
        variable v_wait_for_ext : std_logic := '0';
        variable v_timeout      : natural;
      begin
        if rising_edge(pi_clock) then

          sig_ext_rena <= '0'; sig_ext_rack <= '0';
          for i in 0 to g_ext_bus-1 loop
            if sig_loc_rena(i) = '1' then
              sig_ext_rena <= '1';
            end if;
            if pi_ibus_ext_o(i).rack = '1' then
              sig_ext_rack <= '1';
            end if;
          end loop;

          sig_ext_wena <= '0'; sig_ext_wack <= '0';
          for i in 0 to g_ext_bus-1 loop
            if sig_loc_wena(i) = '1' then
              sig_ext_wena <= '1';
            end if;
            if pi_ibus_ext_o(i).wack = '1' then
              sig_ext_wack <= '1';
            end if;
          end loop;

          sig_ext_rena_prev <= sig_ext_rena;
          sig_ext_wena_prev <= sig_ext_wena;

          if pi_ibus.rena = '1' then
            sig_ii_write_n <= '1';
          end if;

          if pi_ibus.wena = '1' then
            sig_ii_write_n <= '0';
          end if;

          v_wait_for_ext:= ( sig_ext_rena and not sig_ext_rena_prev ) or ( sig_ext_rena and not sig_ext_rena_prev ) or sig_wait_for_ext  ;

          if sig_ext_rena = '1' and sig_ext_rena_prev = '0' then
            sig_wait_for_ext <= '1' ;
            v_timeout        := g_timeout;
          end if;
          if sig_ext_wena = '1' and sig_ext_wena_prev = '0' then
            sig_wait_for_ext <= '1' ;
            v_timeout        := g_timeout;
          end if;

          if v_wait_for_ext = '1' then -- in case read from ext module wait for read acknolage
            v_timeout := v_timeout - 1 ;
            if sig_ext_rack = '1' or sig_ext_wack = '1' or v_timeout = 0 then
              po_ibus.rack <= sig_ii_write_n ;
              po_ibus.wack <= not sig_ii_write_n ;
              sig_wait_for_ext <= '0' ;
            end if;
            -- v_str_pipe(7 downto 0) := x"ff";
            sig_str_pipe(7 downto 0) <= x"ff";
          else
            if sig_str_pipe(7) = '0' then
              po_ibus.rack <= sig_ii_write_n ;
              po_ibus.wack <= not sig_ii_write_n ;
              -- v_str_pipe(7 downto 0) := x"ff";
              sig_str_pipe(7 downto 0) <= x"ff";
            else
              po_ibus.rack <= '0';
              po_ibus.wack <= '0';
              -- v_str_pipe(7 downto 1) := v_str_pipe(6 downto 0);
              -- v_str_pipe(0)          := not (pi_ibus.rena or pi_ibus.wena);
              sig_str_pipe(7 downto 1) <= sig_str_pipe(6 downto 0);
              sig_str_pipe(0)          <= not (pi_ibus.rena or pi_ibus.wena);
            end if;
          end if;

          sig_ii_strobe_n <= and_reduce(sig_str_pipe(6 downto 1)) and not v_wait_for_ext ;


        end if;
      end process;
    end generate gen_ext_bus;

    --=========================================================================
    -- no external buses
    gen_no_ext_bus: if g_ext_bus = 0 generate
      signal sig_str_pipe      : std_logic_vector(3 downto 0) := (others => '1');
    begin
      sig_vecext  <= pi_vecext;

      process(pi_clock)
        -- variable v_str_pipe : std_logic_vector(3 downto 0);
      begin
        if rising_edge(pi_clock) then
          if pi_ibus.rena = '1' then
            sig_ii_write_n <= '1';
          end if;

          if pi_ibus.wena = '1' then
            sig_ii_write_n <= '0';
          end if;

          if sig_str_pipe(3) = '0' then
            po_ibus.rack <= sig_ii_write_n;
            po_ibus.wack <= not sig_ii_write_n;
            sig_str_pipe(3 downto 0) <= x"f";
          else
            po_ibus.rack <= '0';
            po_ibus.wack <= '0';
            sig_str_pipe(3 downto 1) <= sig_str_pipe(2 downto 0);
            sig_str_pipe(0)          <= not (pi_ibus.rena or pi_ibus.wena);
          end if;

          sig_ii_strobe_n <= and_reduce(sig_str_pipe(3 downto 0)) ;

          -- sig_ii_strobe_n <= and_reduce(v_str_pipe(2 downto 1));
          -- v_str_pipe(3 downto 1) := v_str_pipe(2 downto 0);
          -- v_str_pipe(0)          := not (pi_ibus.rena or pi_ibus.wena);
        end if;
      end process;
    end generate gen_no_ext_bus;

    --=========================================================================
    -- ii base
    ii1 : entity work.ii_base generic map (g_ii_as, 32, 32)
      port map(
        ii_addr(21 downto 0)  => pi_ibus.addr(23 downto 2),
        ii_addr(31 downto 22) => "0000000000",

        ii_data_in  => pi_ibus.data,
        ii_data_out => po_ibus.data,
        ii_opern    => '0',
        ii_writen   => sig_ii_write_n,
        ii_stroben  => sig_ii_strobe_n,
        ii_resetn   => '1',
        ii_ackn     => open,
        ii_enan     => '0',
        ii_clk      => pi_clock,

        iivecint  => sig_vecint ,
        iivecext  => sig_vecext ,
        iivecwena => sig_vecwena,
        iivecrena => sig_vecrena
      );

    po_vecint  <= sig_vecint  ;
    po_vecwena <= sig_vecwena ;
    po_vecrena <= sig_vecrena ;

end architecture arch;
