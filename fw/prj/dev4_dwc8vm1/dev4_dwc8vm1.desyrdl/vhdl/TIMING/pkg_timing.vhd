------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021-2022 DESY
--! SPDX-License-Identifier: Apache-2.0
------------------------------------------------------------------------------
--! @date 2021-10-01
--! @author Michael Büchler <michael.buechler@desy.de>
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! VHDL package of DesyRDL for address space decoder for {node.orig_type_name}
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desyrdl;
use desyrdl.common.all;

-- library desy;
-- use desy.common_axi.all;

package pkg_timing is

  -----------------------------------------------
  -- per addrmap / module
  -----------------------------------------------
  constant C_ADDR_WIDTH : integer := 7;
  constant C_DATA_WIDTH : integer := 32;

  -- ===========================================================================
  -- ---------------------------------------------------------------------------
  -- registers
  -- ---------------------------------------------------------------------------

  -- ===========================================================================
  -- REGISTERS interface
  -- ---------------------------------------------------------------------------
  -- register type: ID
  -----------------------------------------------
  type t_field_signals_ID_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_ID_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ID_in is record--
    data : t_field_signals_ID_data_in;--
  end record;
  type t_reg_ID_out is record--
    data : t_field_signals_ID_data_out;--
  end record;
  type t_reg_ID_2d_in is array (integer range <>) of t_reg_ID_in;
  type t_reg_ID_2d_out is array (integer range <>) of t_reg_ID_out;
  type t_reg_ID_3d_in is array (integer range <>, integer range <>) of t_reg_ID_in;
  type t_reg_ID_3d_out is array (integer range <>, integer range <>) of t_reg_ID_out;
  -----------------------------------------------
  -- register type: VERSION
  -----------------------------------------------
  type t_field_signals_VERSION_changes_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_VERSION_changes_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--
  type t_field_signals_VERSION_patch_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_VERSION_patch_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--
  type t_field_signals_VERSION_minor_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_VERSION_minor_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--
  type t_field_signals_VERSION_major_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_VERSION_major_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_VERSION_in is record--
    changes : t_field_signals_VERSION_changes_in;--
    patch : t_field_signals_VERSION_patch_in;--
    minor : t_field_signals_VERSION_minor_in;--
    major : t_field_signals_VERSION_major_in;--
  end record;
  type t_reg_VERSION_out is record--
    changes : t_field_signals_VERSION_changes_out;--
    patch : t_field_signals_VERSION_patch_out;--
    minor : t_field_signals_VERSION_minor_out;--
    major : t_field_signals_VERSION_major_out;--
  end record;
  type t_reg_VERSION_2d_in is array (integer range <>) of t_reg_VERSION_in;
  type t_reg_VERSION_2d_out is array (integer range <>) of t_reg_VERSION_out;
  type t_reg_VERSION_3d_in is array (integer range <>, integer range <>) of t_reg_VERSION_in;
  type t_reg_VERSION_3d_out is array (integer range <>, integer range <>) of t_reg_VERSION_out;
  -----------------------------------------------
  -- register type: ENABLE
  -----------------------------------------------
  type t_field_signals_ENABLE_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_ENABLE_data_out is record
    data : std_logic_vector(3-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ENABLE_in is record--
    data : t_field_signals_ENABLE_data_in;--
  end record;
  type t_reg_ENABLE_out is record--
    data : t_field_signals_ENABLE_data_out;--
  end record;
  type t_reg_ENABLE_2d_in is array (integer range <>) of t_reg_ENABLE_in;
  type t_reg_ENABLE_2d_out is array (integer range <>) of t_reg_ENABLE_out;
  type t_reg_ENABLE_3d_in is array (integer range <>, integer range <>) of t_reg_ENABLE_in;
  type t_reg_ENABLE_3d_out is array (integer range <>, integer range <>) of t_reg_ENABLE_out;
  -----------------------------------------------
  -- register type: SOURCE_SEL
  -----------------------------------------------
  type t_field_signals_SOURCE_SEL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_SOURCE_SEL_data_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SOURCE_SEL_in is record--
    data : t_field_signals_SOURCE_SEL_data_in;--
  end record;
  type t_reg_SOURCE_SEL_out is record--
    data : t_field_signals_SOURCE_SEL_data_out;--
  end record;
  type t_reg_SOURCE_SEL_2d_in is array (integer range <>) of t_reg_SOURCE_SEL_in;
  type t_reg_SOURCE_SEL_2d_out is array (integer range <>) of t_reg_SOURCE_SEL_out;
  type t_reg_SOURCE_SEL_3d_in is array (integer range <>, integer range <>) of t_reg_SOURCE_SEL_in;
  type t_reg_SOURCE_SEL_3d_out is array (integer range <>, integer range <>) of t_reg_SOURCE_SEL_out;
  -----------------------------------------------
  -- register type: SYNC_SEL
  -----------------------------------------------
  type t_field_signals_SYNC_SEL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_SYNC_SEL_data_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SYNC_SEL_in is record--
    data : t_field_signals_SYNC_SEL_data_in;--
  end record;
  type t_reg_SYNC_SEL_out is record--
    data : t_field_signals_SYNC_SEL_data_out;--
  end record;
  type t_reg_SYNC_SEL_2d_in is array (integer range <>) of t_reg_SYNC_SEL_in;
  type t_reg_SYNC_SEL_2d_out is array (integer range <>) of t_reg_SYNC_SEL_out;
  type t_reg_SYNC_SEL_3d_in is array (integer range <>, integer range <>) of t_reg_SYNC_SEL_in;
  type t_reg_SYNC_SEL_3d_out is array (integer range <>, integer range <>) of t_reg_SYNC_SEL_out;
  -----------------------------------------------
  -- register type: DIVIDER_VALUE
  -----------------------------------------------
  type t_field_signals_DIVIDER_VALUE_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_DIVIDER_VALUE_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_DIVIDER_VALUE_in is record--
    data : t_field_signals_DIVIDER_VALUE_data_in;--
  end record;
  type t_reg_DIVIDER_VALUE_out is record--
    data : t_field_signals_DIVIDER_VALUE_data_out;--
  end record;
  type t_reg_DIVIDER_VALUE_2d_in is array (integer range <>) of t_reg_DIVIDER_VALUE_in;
  type t_reg_DIVIDER_VALUE_2d_out is array (integer range <>) of t_reg_DIVIDER_VALUE_out;
  type t_reg_DIVIDER_VALUE_3d_in is array (integer range <>, integer range <>) of t_reg_DIVIDER_VALUE_in;
  type t_reg_DIVIDER_VALUE_3d_out is array (integer range <>, integer range <>) of t_reg_DIVIDER_VALUE_out;
  -----------------------------------------------
  -- register type: TRIGGER_CNT
  -----------------------------------------------
  type t_field_signals_TRIGGER_CNT_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_TRIGGER_CNT_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_TRIGGER_CNT_in is record--
    data : t_field_signals_TRIGGER_CNT_data_in;--
  end record;
  type t_reg_TRIGGER_CNT_out is record--
    data : t_field_signals_TRIGGER_CNT_data_out;--
  end record;
  type t_reg_TRIGGER_CNT_2d_in is array (integer range <>) of t_reg_TRIGGER_CNT_in;
  type t_reg_TRIGGER_CNT_2d_out is array (integer range <>) of t_reg_TRIGGER_CNT_out;
  type t_reg_TRIGGER_CNT_3d_in is array (integer range <>, integer range <>) of t_reg_TRIGGER_CNT_in;
  type t_reg_TRIGGER_CNT_3d_out is array (integer range <>, integer range <>) of t_reg_TRIGGER_CNT_out;
  -----------------------------------------------
  -- register type: EXT_TRIGGER_CNT
  -----------------------------------------------
  type t_field_signals_EXT_TRIGGER_CNT_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_EXT_TRIGGER_CNT_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_EXT_TRIGGER_CNT_in is record--
    data : t_field_signals_EXT_TRIGGER_CNT_data_in;--
  end record;
  type t_reg_EXT_TRIGGER_CNT_out is record--
    data : t_field_signals_EXT_TRIGGER_CNT_data_out;--
  end record;
  type t_reg_EXT_TRIGGER_CNT_2d_in is array (integer range <>) of t_reg_EXT_TRIGGER_CNT_in;
  type t_reg_EXT_TRIGGER_CNT_2d_out is array (integer range <>) of t_reg_EXT_TRIGGER_CNT_out;
  type t_reg_EXT_TRIGGER_CNT_3d_in is array (integer range <>, integer range <>) of t_reg_EXT_TRIGGER_CNT_in;
  type t_reg_EXT_TRIGGER_CNT_3d_out is array (integer range <>, integer range <>) of t_reg_EXT_TRIGGER_CNT_out;
  -----------------------------------------------
  -- register type: DELAY_ENABLE
  -----------------------------------------------
  type t_field_signals_DELAY_ENABLE_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_DELAY_ENABLE_data_out is record
    data : std_logic_vector(3-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_DELAY_ENABLE_in is record--
    data : t_field_signals_DELAY_ENABLE_data_in;--
  end record;
  type t_reg_DELAY_ENABLE_out is record--
    data : t_field_signals_DELAY_ENABLE_data_out;--
  end record;
  type t_reg_DELAY_ENABLE_2d_in is array (integer range <>) of t_reg_DELAY_ENABLE_in;
  type t_reg_DELAY_ENABLE_2d_out is array (integer range <>) of t_reg_DELAY_ENABLE_out;
  type t_reg_DELAY_ENABLE_3d_in is array (integer range <>, integer range <>) of t_reg_DELAY_ENABLE_in;
  type t_reg_DELAY_ENABLE_3d_out is array (integer range <>, integer range <>) of t_reg_DELAY_ENABLE_out;
  -----------------------------------------------
  -- register type: DELAY_VALUE
  -----------------------------------------------
  type t_field_signals_DELAY_VALUE_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_DELAY_VALUE_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_DELAY_VALUE_in is record--
    data : t_field_signals_DELAY_VALUE_data_in;--
  end record;
  type t_reg_DELAY_VALUE_out is record--
    data : t_field_signals_DELAY_VALUE_data_out;--
  end record;
  type t_reg_DELAY_VALUE_2d_in is array (integer range <>) of t_reg_DELAY_VALUE_in;
  type t_reg_DELAY_VALUE_2d_out is array (integer range <>) of t_reg_DELAY_VALUE_out;
  type t_reg_DELAY_VALUE_3d_in is array (integer range <>, integer range <>) of t_reg_DELAY_VALUE_in;
  type t_reg_DELAY_VALUE_3d_out is array (integer range <>, integer range <>) of t_reg_DELAY_VALUE_out;
  -----------------------------------------------
  -- register type: MANUAL_TRG
  -----------------------------------------------
  type t_field_signals_MANUAL_TRG_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_MANUAL_TRG_data_out is record
    data : std_logic_vector(1-1 downto 0);--
    swmod : std_logic; --
  end record;--

  -- The actual register types
  type t_reg_MANUAL_TRG_in is record--
    data : t_field_signals_MANUAL_TRG_data_in;--
  end record;
  type t_reg_MANUAL_TRG_out is record--
    data : t_field_signals_MANUAL_TRG_data_out;--
  end record;
  type t_reg_MANUAL_TRG_2d_in is array (integer range <>) of t_reg_MANUAL_TRG_in;
  type t_reg_MANUAL_TRG_2d_out is array (integer range <>) of t_reg_MANUAL_TRG_out;
  type t_reg_MANUAL_TRG_3d_in is array (integer range <>, integer range <>) of t_reg_MANUAL_TRG_in;
  type t_reg_MANUAL_TRG_3d_out is array (integer range <>, integer range <>) of t_reg_MANUAL_TRG_out;
  -----------------------------------------------

  ------------------------------------------------------------------------------
  -- Register types in regfiles --

  -- ===========================================================================
  -- REGFILE interface
  -- -----------------------------------------------------------------------------

  -- ===========================================================================
  -- MEMORIES interface
  -- ---------------------------------------------------------------------------

  -- ===========================================================================
  -- timing : Top module address map interface
  -- ---------------------------------------------------------------------------
  type t_addrmap_timing_in is record
    --
    ID : t_reg_ID_in;--
    VERSION : t_reg_VERSION_in;--
    ENABLE : t_reg_ENABLE_in;--
    SOURCE_SEL : t_reg_SOURCE_SEL_2d_in(0 to 3-1);--
    SYNC_SEL : t_reg_SYNC_SEL_2d_in(0 to 3-1);--
    DIVIDER_VALUE : t_reg_DIVIDER_VALUE_2d_in(0 to 3-1);--
    TRIGGER_CNT : t_reg_TRIGGER_CNT_2d_in(0 to 3-1);--
    EXT_TRIGGER_CNT : t_reg_EXT_TRIGGER_CNT_2d_in(0 to 8-1);--
    DELAY_ENABLE : t_reg_DELAY_ENABLE_in;--
    DELAY_VALUE : t_reg_DELAY_VALUE_2d_in(0 to 3-1);--
    MANUAL_TRG : t_reg_MANUAL_TRG_2d_in(0 to 3-1);--
    --
    --
    --
  end record;

  type t_addrmap_timing_out is record
    --
    ID : t_reg_ID_out;--
    VERSION : t_reg_VERSION_out;--
    ENABLE : t_reg_ENABLE_out;--
    SOURCE_SEL : t_reg_SOURCE_SEL_2d_out(0 to 3-1);--
    SYNC_SEL : t_reg_SYNC_SEL_2d_out(0 to 3-1);--
    DIVIDER_VALUE : t_reg_DIVIDER_VALUE_2d_out(0 to 3-1);--
    TRIGGER_CNT : t_reg_TRIGGER_CNT_2d_out(0 to 3-1);--
    EXT_TRIGGER_CNT : t_reg_EXT_TRIGGER_CNT_2d_out(0 to 8-1);--
    DELAY_ENABLE : t_reg_DELAY_ENABLE_out;--
    DELAY_VALUE : t_reg_DELAY_VALUE_2d_out(0 to 3-1);--
    MANUAL_TRG : t_reg_MANUAL_TRG_2d_out(0 to 3-1);--
    --
    --
    --
  end record;

  -- ===========================================================================
  -- top level component declaration
  -- must come after defining the interfaces
  -- ---------------------------------------------------------------------------
  subtype t_timing_m2s is t_axi4l_m2s;
  subtype t_timing_s2m is t_axi4l_s2m;

  component timing is
      port (
        pi_clock : in std_logic;
        pi_reset : in std_logic;
        -- TOP subordinate memory mapped interface
        pi_s_top  : in  t_timing_m2s;
        po_s_top  : out t_timing_s2m;
        -- to logic interface
        pi_addrmap : in  t_addrmap_timing_in;
        po_addrmap : out t_addrmap_timing_out
      );
  end component timing;

end package pkg_timing;
--------------------------------------------------------------------------------
package body pkg_timing is
end package body;

--==============================================================================


--------------------------------------------------------------------------------
-- Register types directly in addmap
--------------------------------------------------------------------------------
--
-- register type: ID
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_ID is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ID_in ;
    po_reg  : out t_reg_ID_out
  );
end entity timing_ID;

architecture rtl of timing_ID is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(32-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,32));
        else
          -- HW --
          l_field_reg <= pi_reg.data.data;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(31 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: VERSION
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_VERSION is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_VERSION_in ;
    po_reg  : out t_reg_VERSION_out
  );
end entity timing_VERSION;

architecture rtl of timing_VERSION is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  changes_wire : block--
  begin
    --
    data_out(7 downto 0) <= std_logic_vector(to_signed(1,8));--
    --
    po_reg.changes.data <= data_out(7 downto 0);--
  end block;----WIRE
  patch_wire : block--
  begin
    --
    data_out(15 downto 8) <= std_logic_vector(to_signed(2,8));--
    --
    po_reg.patch.data <= data_out(15 downto 8);--
  end block;----WIRE
  minor_wire : block--
  begin
    --
    data_out(23 downto 16) <= std_logic_vector(to_signed(0,8));--
    --
    po_reg.minor.data <= data_out(23 downto 16);--
  end block;----WIRE
  major_wire : block--
  begin
    --
    data_out(31 downto 24) <= std_logic_vector(to_signed(2,8));--
    --
    po_reg.major.data <= data_out(31 downto 24);--
  end block;--
end rtl;
-----------------------------------------------
-- register type: ENABLE
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_ENABLE is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ENABLE_in ;
    po_reg  : out t_reg_ENABLE_out
  );
end entity timing_ENABLE;

architecture rtl of timing_ENABLE is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 3) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(3-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,3));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(2 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(2 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: SOURCE_SEL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_SOURCE_SEL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SOURCE_SEL_in ;
    po_reg  : out t_reg_SOURCE_SEL_out
  );
end entity timing_SOURCE_SEL;

architecture rtl of timing_SOURCE_SEL is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 8) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(8-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,8));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(7 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(7 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: SYNC_SEL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_SYNC_SEL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SYNC_SEL_in ;
    po_reg  : out t_reg_SYNC_SEL_out
  );
end entity timing_SYNC_SEL;

architecture rtl of timing_SYNC_SEL is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 8) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(8-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,8));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(7 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(7 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: DIVIDER_VALUE
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_DIVIDER_VALUE is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DIVIDER_VALUE_in ;
    po_reg  : out t_reg_DIVIDER_VALUE_out
  );
end entity timing_DIVIDER_VALUE;

architecture rtl of timing_DIVIDER_VALUE is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(32-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,32));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(31 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(31 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: TRIGGER_CNT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_TRIGGER_CNT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_TRIGGER_CNT_in ;
    po_reg  : out t_reg_TRIGGER_CNT_out
  );
end entity timing_TRIGGER_CNT;

architecture rtl of timing_TRIGGER_CNT is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(31 downto 0) <= pi_reg.data.data(32-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: EXT_TRIGGER_CNT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_EXT_TRIGGER_CNT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_EXT_TRIGGER_CNT_in ;
    po_reg  : out t_reg_EXT_TRIGGER_CNT_out
  );
end entity timing_EXT_TRIGGER_CNT;

architecture rtl of timing_EXT_TRIGGER_CNT is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(31 downto 0) <= pi_reg.data.data(32-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: DELAY_ENABLE
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_DELAY_ENABLE is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DELAY_ENABLE_in ;
    po_reg  : out t_reg_DELAY_ENABLE_out
  );
end entity timing_DELAY_ENABLE;

architecture rtl of timing_DELAY_ENABLE is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 3) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(3-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,3));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(2 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(2 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: DELAY_VALUE
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_DELAY_VALUE is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DELAY_VALUE_in ;
    po_reg  : out t_reg_DELAY_VALUE_out
  );
end entity timing_DELAY_VALUE;

architecture rtl of timing_DELAY_VALUE is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(32-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,32));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(31 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(31 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: MANUAL_TRG
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_timing.all;

entity timing_MANUAL_TRG is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_MANUAL_TRG_in ;
    po_reg  : out t_reg_MANUAL_TRG_out
  );
end entity timing_MANUAL_TRG;

architecture rtl of timing_MANUAL_TRG is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 1) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(1-1 downto 0);
    signal l_sw_wr_stb_q : std_logic;
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,1));
          l_sw_wr_stb_q <= '0';
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(0 downto 0);
          end if;
          l_sw_wr_stb_q <= pi_decoder_wr_stb;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    po_reg.data.swmod <= (not l_sw_wr_stb_q and pi_decoder_wr_stb) when rising_edge(pi_clock);
    data_out(0 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------

--------------------------------------------------------------------------------
-- Register types in regfiles
--------------------------------------------------------------------------------
--