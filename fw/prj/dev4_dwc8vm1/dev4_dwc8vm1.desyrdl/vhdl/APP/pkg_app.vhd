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

package pkg_app is

  -----------------------------------------------
  -- per addrmap / module
  -----------------------------------------------
  constant C_ADDR_WIDTH : integer := 16;
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
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
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
  -- register type: IRQ_ACK_CNT
  -----------------------------------------------
  type t_field_signals_IRQ_ACK_CNT_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_IRQ_ACK_CNT_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_IRQ_ACK_CNT_in is record--
    data : t_field_signals_IRQ_ACK_CNT_data_in;--
  end record;
  type t_reg_IRQ_ACK_CNT_out is record--
    data : t_field_signals_IRQ_ACK_CNT_data_out;--
  end record;
  type t_reg_IRQ_ACK_CNT_2d_in is array (integer range <>) of t_reg_IRQ_ACK_CNT_in;
  type t_reg_IRQ_ACK_CNT_2d_out is array (integer range <>) of t_reg_IRQ_ACK_CNT_out;
  type t_reg_IRQ_ACK_CNT_3d_in is array (integer range <>, integer range <>) of t_reg_IRQ_ACK_CNT_in;
  type t_reg_IRQ_ACK_CNT_3d_out is array (integer range <>, integer range <>) of t_reg_IRQ_ACK_CNT_out;
  -----------------------------------------------
  -- register type: SCRATCH
  -----------------------------------------------
  type t_field_signals_SCRATCH_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_SCRATCH_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SCRATCH_in is record--
    data : t_field_signals_SCRATCH_data_in;--
  end record;
  type t_reg_SCRATCH_out is record--
    data : t_field_signals_SCRATCH_data_out;--
  end record;
  type t_reg_SCRATCH_2d_in is array (integer range <>) of t_reg_SCRATCH_in;
  type t_reg_SCRATCH_2d_out is array (integer range <>) of t_reg_SCRATCH_out;
  type t_reg_SCRATCH_3d_in is array (integer range <>, integer range <>) of t_reg_SCRATCH_in;
  type t_reg_SCRATCH_3d_out is array (integer range <>, integer range <>) of t_reg_SCRATCH_out;
  -----------------------------------------------
  -- register type: ADC_OV_LATCHED
  -----------------------------------------------
  type t_field_signals_ADC_OV_LATCHED_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_ADC_OV_LATCHED_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ADC_OV_LATCHED_in is record--
    data : t_field_signals_ADC_OV_LATCHED_data_in;--
  end record;
  type t_reg_ADC_OV_LATCHED_out is record--
    data : t_field_signals_ADC_OV_LATCHED_data_out;--
  end record;
  type t_reg_ADC_OV_LATCHED_2d_in is array (integer range <>) of t_reg_ADC_OV_LATCHED_in;
  type t_reg_ADC_OV_LATCHED_2d_out is array (integer range <>) of t_reg_ADC_OV_LATCHED_out;
  type t_reg_ADC_OV_LATCHED_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_OV_LATCHED_in;
  type t_reg_ADC_OV_LATCHED_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_OV_LATCHED_out;
  -----------------------------------------------
  -- register type: CNT_EVENTS
  -----------------------------------------------
  type t_field_signals_CNT_EVENTS_data_in is record
    data : std_logic_vector(16-1 downto 0);--
  end record;

  type t_field_signals_CNT_EVENTS_data_out is record
    data : std_logic_vector(16-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_CNT_EVENTS_in is record--
    data : t_field_signals_CNT_EVENTS_data_in;--
  end record;
  type t_reg_CNT_EVENTS_out is record--
    data : t_field_signals_CNT_EVENTS_data_out;--
  end record;
  type t_reg_CNT_EVENTS_2d_in is array (integer range <>) of t_reg_CNT_EVENTS_in;
  type t_reg_CNT_EVENTS_2d_out is array (integer range <>) of t_reg_CNT_EVENTS_out;
  type t_reg_CNT_EVENTS_3d_in is array (integer range <>, integer range <>) of t_reg_CNT_EVENTS_in;
  type t_reg_CNT_EVENTS_3d_out is array (integer range <>, integer range <>) of t_reg_CNT_EVENTS_out;
  -----------------------------------------------
  -- register type: FB_SWITCH
  -----------------------------------------------
  type t_field_signals_FB_SWITCH_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_FB_SWITCH_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_FB_SWITCH_in is record--
    data : t_field_signals_FB_SWITCH_data_in;--
  end record;
  type t_reg_FB_SWITCH_out is record--
    data : t_field_signals_FB_SWITCH_data_out;--
  end record;
  type t_reg_FB_SWITCH_2d_in is array (integer range <>) of t_reg_FB_SWITCH_in;
  type t_reg_FB_SWITCH_2d_out is array (integer range <>) of t_reg_FB_SWITCH_out;
  type t_reg_FB_SWITCH_3d_in is array (integer range <>, integer range <>) of t_reg_FB_SWITCH_in;
  type t_reg_FB_SWITCH_3d_out is array (integer range <>, integer range <>) of t_reg_FB_SWITCH_out;
  -----------------------------------------------
  -- register type: MLVDS_I
  -----------------------------------------------
  type t_field_signals_MLVDS_I_data_in is record
    data : std_logic_vector(8-1 downto 0);--
  end record;

  type t_field_signals_MLVDS_I_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_MLVDS_I_in is record--
    data : t_field_signals_MLVDS_I_data_in;--
  end record;
  type t_reg_MLVDS_I_out is record--
    data : t_field_signals_MLVDS_I_data_out;--
  end record;
  type t_reg_MLVDS_I_2d_in is array (integer range <>) of t_reg_MLVDS_I_in;
  type t_reg_MLVDS_I_2d_out is array (integer range <>) of t_reg_MLVDS_I_out;
  type t_reg_MLVDS_I_3d_in is array (integer range <>, integer range <>) of t_reg_MLVDS_I_in;
  type t_reg_MLVDS_I_3d_out is array (integer range <>, integer range <>) of t_reg_MLVDS_I_out;
  -----------------------------------------------
  -- register type: MLVDS_O
  -----------------------------------------------
  type t_field_signals_MLVDS_O_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_MLVDS_O_data_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_MLVDS_O_in is record--
    data : t_field_signals_MLVDS_O_data_in;--
  end record;
  type t_reg_MLVDS_O_out is record--
    data : t_field_signals_MLVDS_O_data_out;--
  end record;
  type t_reg_MLVDS_O_2d_in is array (integer range <>) of t_reg_MLVDS_O_in;
  type t_reg_MLVDS_O_2d_out is array (integer range <>) of t_reg_MLVDS_O_out;
  type t_reg_MLVDS_O_3d_in is array (integer range <>, integer range <>) of t_reg_MLVDS_O_in;
  type t_reg_MLVDS_O_3d_out is array (integer range <>, integer range <>) of t_reg_MLVDS_O_out;
  -----------------------------------------------
  -- register type: MLVDS_OE
  -----------------------------------------------
  type t_field_signals_MLVDS_OE_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_MLVDS_OE_data_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_MLVDS_OE_in is record--
    data : t_field_signals_MLVDS_OE_data_in;--
  end record;
  type t_reg_MLVDS_OE_out is record--
    data : t_field_signals_MLVDS_OE_data_out;--
  end record;
  type t_reg_MLVDS_OE_2d_in is array (integer range <>) of t_reg_MLVDS_OE_in;
  type t_reg_MLVDS_OE_2d_out is array (integer range <>) of t_reg_MLVDS_OE_out;
  type t_reg_MLVDS_OE_3d_in is array (integer range <>, integer range <>) of t_reg_MLVDS_OE_in;
  type t_reg_MLVDS_OE_3d_out is array (integer range <>, integer range <>) of t_reg_MLVDS_OE_out;
  -----------------------------------------------
  -- register type: TIMESTAMP
  -----------------------------------------------
  type t_field_signals_TIMESTAMP_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_TIMESTAMP_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_TIMESTAMP_in is record--
    data : t_field_signals_TIMESTAMP_data_in;--
  end record;
  type t_reg_TIMESTAMP_out is record--
    data : t_field_signals_TIMESTAMP_data_out;--
  end record;
  type t_reg_TIMESTAMP_2d_in is array (integer range <>) of t_reg_TIMESTAMP_in;
  type t_reg_TIMESTAMP_2d_out is array (integer range <>) of t_reg_TIMESTAMP_out;
  type t_reg_TIMESTAMP_3d_in is array (integer range <>, integer range <>) of t_reg_TIMESTAMP_in;
  type t_reg_TIMESTAMP_3d_out is array (integer range <>, integer range <>) of t_reg_TIMESTAMP_out;
  -----------------------------------------------
  -- register type: CNT_RJ45
  -----------------------------------------------
  type t_field_signals_CNT_RJ45_data_in is record
    data : std_logic_vector(16-1 downto 0);--
  end record;

  type t_field_signals_CNT_RJ45_data_out is record
    data : std_logic_vector(16-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_CNT_RJ45_in is record--
    data : t_field_signals_CNT_RJ45_data_in;--
  end record;
  type t_reg_CNT_RJ45_out is record--
    data : t_field_signals_CNT_RJ45_data_out;--
  end record;
  type t_reg_CNT_RJ45_2d_in is array (integer range <>) of t_reg_CNT_RJ45_in;
  type t_reg_CNT_RJ45_2d_out is array (integer range <>) of t_reg_CNT_RJ45_out;
  type t_reg_CNT_RJ45_3d_in is array (integer range <>, integer range <>) of t_reg_CNT_RJ45_in;
  type t_reg_CNT_RJ45_3d_out is array (integer range <>, integer range <>) of t_reg_CNT_RJ45_out;
  -----------------------------------------------
  -- register type: ROTATION
  -----------------------------------------------
  type t_field_signals_ROTATION_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_ROTATION_data_out is record
    data : std_logic_vector(16-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ROTATION_in is record--
    data : t_field_signals_ROTATION_data_in;--
  end record;
  type t_reg_ROTATION_out is record--
    data : t_field_signals_ROTATION_data_out;--
  end record;
  type t_reg_ROTATION_2d_in is array (integer range <>) of t_reg_ROTATION_in;
  type t_reg_ROTATION_2d_out is array (integer range <>) of t_reg_ROTATION_out;
  type t_reg_ROTATION_3d_in is array (integer range <>, integer range <>) of t_reg_ROTATION_in;
  type t_reg_ROTATION_3d_out is array (integer range <>, integer range <>) of t_reg_ROTATION_out;
  -----------------------------------------------
  -- register type: DPM_MODE
  -----------------------------------------------
  type t_field_signals_DPM_MODE_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_DPM_MODE_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_DPM_MODE_in is record--
    data : t_field_signals_DPM_MODE_data_in;--
  end record;
  type t_reg_DPM_MODE_out is record--
    data : t_field_signals_DPM_MODE_data_out;--
  end record;
  type t_reg_DPM_MODE_2d_in is array (integer range <>) of t_reg_DPM_MODE_in;
  type t_reg_DPM_MODE_2d_out is array (integer range <>) of t_reg_DPM_MODE_out;
  type t_reg_DPM_MODE_3d_in is array (integer range <>, integer range <>) of t_reg_DPM_MODE_in;
  type t_reg_DPM_MODE_3d_out is array (integer range <>, integer range <>) of t_reg_DPM_MODE_out;
  -----------------------------------------------

  ------------------------------------------------------------------------------
  -- Register types in regfiles --

  -- ===========================================================================
  -- REGFILE interface
  -- -----------------------------------------------------------------------------

  -- ===========================================================================
  -- MEMORIES interface
  -- ---------------------------------------------------------------------------
  -- memory type: REF_I
  -----------------------------------------------
  type t_mem_REF_I_out is record
    en   : std_logic;
    addr : std_logic_vector(12-1 downto 0);
    --
    we   : std_logic;
    data : std_logic_vector(32-1 downto 0);--
  end record t_mem_REF_I_out;
  type t_mem_REF_I_in is record
    --
    data : std_logic_vector(32-1 downto 0);
    --
  end record t_mem_REF_I_in;
  type t_mem_REF_I_2d_in is array (integer range <>) of t_mem_REF_I_in;
  type t_mem_REF_I_2d_out is array (integer range <>) of t_mem_REF_I_out;
  -----------------------------------------------
  -- memory type: REF_Q
  -----------------------------------------------
  type t_mem_REF_Q_out is record
    en   : std_logic;
    addr : std_logic_vector(12-1 downto 0);
    --
    we   : std_logic;
    data : std_logic_vector(32-1 downto 0);--
  end record t_mem_REF_Q_out;
  type t_mem_REF_Q_in is record
    --
    data : std_logic_vector(32-1 downto 0);
    --
  end record t_mem_REF_Q_in;
  type t_mem_REF_Q_2d_in is array (integer range <>) of t_mem_REF_Q_in;
  type t_mem_REF_Q_2d_out is array (integer range <>) of t_mem_REF_Q_out;
  -----------------------------------------------
  -- memory type: FFD_I
  -----------------------------------------------
  type t_mem_FFD_I_out is record
    en   : std_logic;
    addr : std_logic_vector(12-1 downto 0);
    --
    we   : std_logic;
    data : std_logic_vector(32-1 downto 0);--
  end record t_mem_FFD_I_out;
  type t_mem_FFD_I_in is record
    --
    data : std_logic_vector(32-1 downto 0);
    --
  end record t_mem_FFD_I_in;
  type t_mem_FFD_I_2d_in is array (integer range <>) of t_mem_FFD_I_in;
  type t_mem_FFD_I_2d_out is array (integer range <>) of t_mem_FFD_I_out;
  -----------------------------------------------
  -- memory type: FFD_Q
  -----------------------------------------------
  type t_mem_FFD_Q_out is record
    en   : std_logic;
    addr : std_logic_vector(12-1 downto 0);
    --
    we   : std_logic;
    data : std_logic_vector(32-1 downto 0);--
  end record t_mem_FFD_Q_out;
  type t_mem_FFD_Q_in is record
    --
    data : std_logic_vector(32-1 downto 0);
    --
  end record t_mem_FFD_Q_in;
  type t_mem_FFD_Q_2d_in is array (integer range <>) of t_mem_FFD_Q_in;
  type t_mem_FFD_Q_2d_out is array (integer range <>) of t_mem_FFD_Q_out;
  -----------------------------------------------

  -- ===========================================================================
  -- app : Top module address map interface
  -- ---------------------------------------------------------------------------
  type t_addrmap_app_in is record
    --
    ID : t_reg_ID_in;--
    VERSION : t_reg_VERSION_in;--
    IRQ_ACK_CNT : t_reg_IRQ_ACK_CNT_2d_in(0 to 16-1);--
    SCRATCH : t_reg_SCRATCH_2d_in(0 to 10-1);--
    ADC_OV_LATCHED : t_reg_ADC_OV_LATCHED_2d_in(0 to 10-1);--
    CNT_EVENTS : t_reg_CNT_EVENTS_2d_in(0 to 10-1);--
    FB_SWITCH : t_reg_FB_SWITCH_in;--
    MLVDS_I : t_reg_MLVDS_I_in;--
    MLVDS_O : t_reg_MLVDS_O_in;--
    MLVDS_OE : t_reg_MLVDS_OE_in;--
    TIMESTAMP : t_reg_TIMESTAMP_in;--
    CNT_RJ45 : t_reg_CNT_RJ45_2d_in(0 to 3-1);--
    ROTATION : t_reg_ROTATION_in;--
    DPM_MODE : t_reg_DPM_MODE_in;--
    --
    --
    REF_I : t_mem_REF_I_in;--
    REF_Q : t_mem_REF_Q_in;--
    FFD_I : t_mem_FFD_I_in;--
    FFD_Q : t_mem_FFD_Q_in;--
    --
    TIMING : t_axi4l_s2m;--
    DAQ : t_axi4l_s2m;--
    MIMO : t_axi4l_s2m;--
    RTM : t_axi4l_s2m;--
  end record;

  type t_addrmap_app_out is record
    --
    ID : t_reg_ID_out;--
    VERSION : t_reg_VERSION_out;--
    IRQ_ACK_CNT : t_reg_IRQ_ACK_CNT_2d_out(0 to 16-1);--
    SCRATCH : t_reg_SCRATCH_2d_out(0 to 10-1);--
    ADC_OV_LATCHED : t_reg_ADC_OV_LATCHED_2d_out(0 to 10-1);--
    CNT_EVENTS : t_reg_CNT_EVENTS_2d_out(0 to 10-1);--
    FB_SWITCH : t_reg_FB_SWITCH_out;--
    MLVDS_I : t_reg_MLVDS_I_out;--
    MLVDS_O : t_reg_MLVDS_O_out;--
    MLVDS_OE : t_reg_MLVDS_OE_out;--
    TIMESTAMP : t_reg_TIMESTAMP_out;--
    CNT_RJ45 : t_reg_CNT_RJ45_2d_out(0 to 3-1);--
    ROTATION : t_reg_ROTATION_out;--
    DPM_MODE : t_reg_DPM_MODE_out;--
    --
    --
    REF_I : t_mem_REF_I_out;--
    REF_Q : t_mem_REF_Q_out;--
    FFD_I : t_mem_FFD_I_out;--
    FFD_Q : t_mem_FFD_Q_out;--
    --
    TIMING : t_axi4l_m2s;--
    DAQ : t_axi4l_m2s;--
    MIMO : t_axi4l_m2s;--
    RTM : t_axi4l_m2s;--
  end record;

  -- ===========================================================================
  -- top level component declaration
  -- must come after defining the interfaces
  -- ---------------------------------------------------------------------------
  subtype t_app_m2s is t_axi4l_m2s;
  subtype t_app_s2m is t_axi4l_s2m;

  component app is
      port (
        pi_clock : in std_logic;
        pi_reset : in std_logic;
        -- TOP subordinate memory mapped interface
        pi_s_top  : in  t_app_m2s;
        po_s_top  : out t_app_s2m;
        -- to logic interface
        pi_addrmap : in  t_addrmap_app_in;
        po_addrmap : out t_addrmap_app_out
      );
  end component app;

end package pkg_app;
--------------------------------------------------------------------------------
package body pkg_app is
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

use work.pkg_app.all;

entity app_ID is
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
end entity app_ID;

architecture rtl of app_ID is
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
    data_out(31 downto 0) <= std_logic_vector(to_signed(0,32));--
    --
    po_reg.data.data <= data_out(31 downto 0);--
  end block;--
end rtl;
-----------------------------------------------
-- register type: VERSION
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_VERSION is
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
end entity app_VERSION;

architecture rtl of app_VERSION is
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
    data_out(15 downto 8) <= std_logic_vector(to_signed(0,8));--
    --
    po_reg.patch.data <= data_out(15 downto 8);--
  end block;----WIRE
  minor_wire : block--
  begin
    --
    data_out(23 downto 16) <= std_logic_vector(to_signed(1,8));--
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
-- register type: IRQ_ACK_CNT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_IRQ_ACK_CNT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_IRQ_ACK_CNT_in ;
    po_reg  : out t_reg_IRQ_ACK_CNT_out
  );
end entity app_IRQ_ACK_CNT;

architecture rtl of app_IRQ_ACK_CNT is
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
-- register type: SCRATCH
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_SCRATCH is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SCRATCH_in ;
    po_reg  : out t_reg_SCRATCH_out
  );
end entity app_SCRATCH;

architecture rtl of app_SCRATCH is
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
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,1));
        else
          -- HW --
          l_field_reg <= pi_reg.data.data;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(0 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: ADC_OV_LATCHED
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_ADC_OV_LATCHED is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_OV_LATCHED_in ;
    po_reg  : out t_reg_ADC_OV_LATCHED_out
  );
end entity app_ADC_OV_LATCHED;

architecture rtl of app_ADC_OV_LATCHED is
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
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,1));
        else
          -- HW --
          l_field_reg <= pi_reg.data.data;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(0 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: CNT_EVENTS
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_CNT_EVENTS is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CNT_EVENTS_in ;
    po_reg  : out t_reg_CNT_EVENTS_out
  );
end entity app_CNT_EVENTS;

architecture rtl of app_CNT_EVENTS is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 16) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(16-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,16));
        else
          -- HW --
          l_field_reg <= pi_reg.data.data;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(15 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: FB_SWITCH
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_FB_SWITCH is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_FB_SWITCH_in ;
    po_reg  : out t_reg_FB_SWITCH_out
  );
end entity app_FB_SWITCH;

architecture rtl of app_FB_SWITCH is
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
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,1));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(0 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(0 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: MLVDS_I
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_MLVDS_I is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_MLVDS_I_in ;
    po_reg  : out t_reg_MLVDS_I_out
  );
end entity app_MLVDS_I;

architecture rtl of app_MLVDS_I is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 8) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(7 downto 0) <= pi_reg.data.data(8-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: MLVDS_O
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_MLVDS_O is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_MLVDS_O_in ;
    po_reg  : out t_reg_MLVDS_O_out
  );
end entity app_MLVDS_O;

architecture rtl of app_MLVDS_O is
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
-- register type: MLVDS_OE
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_MLVDS_OE is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_MLVDS_OE_in ;
    po_reg  : out t_reg_MLVDS_OE_out
  );
end entity app_MLVDS_OE;

architecture rtl of app_MLVDS_OE is
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
-- register type: TIMESTAMP
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_TIMESTAMP is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_TIMESTAMP_in ;
    po_reg  : out t_reg_TIMESTAMP_out
  );
end entity app_TIMESTAMP;

architecture rtl of app_TIMESTAMP is
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
-- register type: CNT_RJ45
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_CNT_RJ45 is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CNT_RJ45_in ;
    po_reg  : out t_reg_CNT_RJ45_out
  );
end entity app_CNT_RJ45;

architecture rtl of app_CNT_RJ45 is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 16) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(16-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,16));
        else
          -- HW --
          l_field_reg <= pi_reg.data.data;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(15 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: ROTATION
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_ROTATION is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ROTATION_in ;
    po_reg  : out t_reg_ROTATION_out
  );
end entity app_ROTATION;

architecture rtl of app_ROTATION is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 16) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(16-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,16));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(15 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(15 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: DPM_MODE
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_app.all;

entity app_DPM_MODE is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DPM_MODE_in ;
    po_reg  : out t_reg_DPM_MODE_out
  );
end entity app_DPM_MODE;

architecture rtl of app_DPM_MODE is
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
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,1));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(0 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(0 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------

--------------------------------------------------------------------------------
-- Register types in regfiles
--------------------------------------------------------------------------------
--