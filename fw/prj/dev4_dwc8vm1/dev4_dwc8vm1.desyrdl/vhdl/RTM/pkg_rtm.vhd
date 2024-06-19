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

package pkg_rtm is

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
  -- register type: RF_PERMIT
  -----------------------------------------------
  type t_field_signals_RF_PERMIT_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_RF_PERMIT_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_RF_PERMIT_in is record--
    data : t_field_signals_RF_PERMIT_data_in;--
  end record;
  type t_reg_RF_PERMIT_out is record--
    data : t_field_signals_RF_PERMIT_data_out;--
  end record;
  type t_reg_RF_PERMIT_2d_in is array (integer range <>) of t_reg_RF_PERMIT_in;
  type t_reg_RF_PERMIT_2d_out is array (integer range <>) of t_reg_RF_PERMIT_out;
  type t_reg_RF_PERMIT_3d_in is array (integer range <>, integer range <>) of t_reg_RF_PERMIT_in;
  type t_reg_RF_PERMIT_3d_out is array (integer range <>, integer range <>) of t_reg_RF_PERMIT_out;
  -----------------------------------------------
  -- register type: ATT_SEL
  -----------------------------------------------
  type t_field_signals_ATT_SEL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_ATT_SEL_data_out is record
    data : std_logic_vector(9-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ATT_SEL_in is record--
    data : t_field_signals_ATT_SEL_data_in;--
  end record;
  type t_reg_ATT_SEL_out is record--
    data : t_field_signals_ATT_SEL_data_out;--
  end record;
  type t_reg_ATT_SEL_2d_in is array (integer range <>) of t_reg_ATT_SEL_in;
  type t_reg_ATT_SEL_2d_out is array (integer range <>) of t_reg_ATT_SEL_out;
  type t_reg_ATT_SEL_3d_in is array (integer range <>, integer range <>) of t_reg_ATT_SEL_in;
  type t_reg_ATT_SEL_3d_out is array (integer range <>, integer range <>) of t_reg_ATT_SEL_out;
  -----------------------------------------------
  -- register type: ATT_VAL
  -----------------------------------------------
  type t_field_signals_ATT_VAL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_ATT_VAL_data_out is record
    data : std_logic_vector(6-1 downto 0);--
    swmod : std_logic; --
  end record;--

  -- The actual register types
  type t_reg_ATT_VAL_in is record--
    data : t_field_signals_ATT_VAL_data_in;--
  end record;
  type t_reg_ATT_VAL_out is record--
    data : t_field_signals_ATT_VAL_data_out;--
  end record;
  type t_reg_ATT_VAL_2d_in is array (integer range <>) of t_reg_ATT_VAL_in;
  type t_reg_ATT_VAL_2d_out is array (integer range <>) of t_reg_ATT_VAL_out;
  type t_reg_ATT_VAL_3d_in is array (integer range <>, integer range <>) of t_reg_ATT_VAL_in;
  type t_reg_ATT_VAL_3d_out is array (integer range <>, integer range <>) of t_reg_ATT_VAL_out;
  -----------------------------------------------
  -- register type: ATT_STATUS
  -----------------------------------------------
  type t_field_signals_ATT_STATUS_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_ATT_STATUS_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ATT_STATUS_in is record--
    data : t_field_signals_ATT_STATUS_data_in;--
  end record;
  type t_reg_ATT_STATUS_out is record--
    data : t_field_signals_ATT_STATUS_data_out;--
  end record;
  type t_reg_ATT_STATUS_2d_in is array (integer range <>) of t_reg_ATT_STATUS_in;
  type t_reg_ATT_STATUS_2d_out is array (integer range <>) of t_reg_ATT_STATUS_out;
  type t_reg_ATT_STATUS_3d_in is array (integer range <>, integer range <>) of t_reg_ATT_STATUS_in;
  type t_reg_ATT_STATUS_3d_out is array (integer range <>, integer range <>) of t_reg_ATT_STATUS_out;
  -----------------------------------------------
  -- register type: ADC_A
  -----------------------------------------------
  type t_field_signals_ADC_A_data_in is record
    data : std_logic_vector(25-1 downto 0);--
  end record;

  type t_field_signals_ADC_A_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ADC_A_in is record--
    data : t_field_signals_ADC_A_data_in;--
  end record;
  type t_reg_ADC_A_out is record--
    data : t_field_signals_ADC_A_data_out;--
  end record;
  type t_reg_ADC_A_2d_in is array (integer range <>) of t_reg_ADC_A_in;
  type t_reg_ADC_A_2d_out is array (integer range <>) of t_reg_ADC_A_out;
  type t_reg_ADC_A_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_A_in;
  type t_reg_ADC_A_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_A_out;
  -----------------------------------------------
  -- register type: ADC_B
  -----------------------------------------------
  type t_field_signals_ADC_B_data_in is record
    data : std_logic_vector(25-1 downto 0);--
  end record;

  type t_field_signals_ADC_B_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ADC_B_in is record--
    data : t_field_signals_ADC_B_data_in;--
  end record;
  type t_reg_ADC_B_out is record--
    data : t_field_signals_ADC_B_data_out;--
  end record;
  type t_reg_ADC_B_2d_in is array (integer range <>) of t_reg_ADC_B_in;
  type t_reg_ADC_B_2d_out is array (integer range <>) of t_reg_ADC_B_out;
  type t_reg_ADC_B_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_B_in;
  type t_reg_ADC_B_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_B_out;
  -----------------------------------------------
  -- register type: ADC_C
  -----------------------------------------------
  type t_field_signals_ADC_C_data_in is record
    data : std_logic_vector(25-1 downto 0);--
  end record;

  type t_field_signals_ADC_C_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ADC_C_in is record--
    data : t_field_signals_ADC_C_data_in;--
  end record;
  type t_reg_ADC_C_out is record--
    data : t_field_signals_ADC_C_data_out;--
  end record;
  type t_reg_ADC_C_2d_in is array (integer range <>) of t_reg_ADC_C_in;
  type t_reg_ADC_C_2d_out is array (integer range <>) of t_reg_ADC_C_out;
  type t_reg_ADC_C_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_C_in;
  type t_reg_ADC_C_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_C_out;
  -----------------------------------------------
  -- register type: ADC_D
  -----------------------------------------------
  type t_field_signals_ADC_D_data_in is record
    data : std_logic_vector(25-1 downto 0);--
  end record;

  type t_field_signals_ADC_D_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ADC_D_in is record--
    data : t_field_signals_ADC_D_data_in;--
  end record;
  type t_reg_ADC_D_out is record--
    data : t_field_signals_ADC_D_data_out;--
  end record;
  type t_reg_ADC_D_2d_in is array (integer range <>) of t_reg_ADC_D_in;
  type t_reg_ADC_D_2d_out is array (integer range <>) of t_reg_ADC_D_out;
  type t_reg_ADC_D_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_D_in;
  type t_reg_ADC_D_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_D_out;
  -----------------------------------------------
  -- register type: ADC_READ_ENA
  -----------------------------------------------
  type t_field_signals_ADC_READ_ENA_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_ADC_READ_ENA_data_out is record
    data : std_logic_vector(4-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ADC_READ_ENA_in is record--
    data : t_field_signals_ADC_READ_ENA_data_in;--
  end record;
  type t_reg_ADC_READ_ENA_out is record--
    data : t_field_signals_ADC_READ_ENA_data_out;--
  end record;
  type t_reg_ADC_READ_ENA_2d_in is array (integer range <>) of t_reg_ADC_READ_ENA_in;
  type t_reg_ADC_READ_ENA_2d_out is array (integer range <>) of t_reg_ADC_READ_ENA_out;
  type t_reg_ADC_READ_ENA_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_READ_ENA_in;
  type t_reg_ADC_READ_ENA_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_READ_ENA_out;
  -----------------------------------------------
  -- register type: ADC_STATUS
  -----------------------------------------------
  type t_field_signals_ADC_STATUS_data_in is record
    data : std_logic_vector(4-1 downto 0);--
  end record;

  type t_field_signals_ADC_STATUS_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ADC_STATUS_in is record--
    data : t_field_signals_ADC_STATUS_data_in;--
  end record;
  type t_reg_ADC_STATUS_out is record--
    data : t_field_signals_ADC_STATUS_data_out;--
  end record;
  type t_reg_ADC_STATUS_2d_in is array (integer range <>) of t_reg_ADC_STATUS_in;
  type t_reg_ADC_STATUS_2d_out is array (integer range <>) of t_reg_ADC_STATUS_out;
  type t_reg_ADC_STATUS_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_STATUS_in;
  type t_reg_ADC_STATUS_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_STATUS_out;
  -----------------------------------------------
  -- register type: DACAB
  -----------------------------------------------
  type t_field_signals_DACAB_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_DACAB_data_out is record
    data : std_logic_vector(12-1 downto 0);--
    swmod : std_logic; --
  end record;--

  -- The actual register types
  type t_reg_DACAB_in is record--
    data : t_field_signals_DACAB_data_in;--
  end record;
  type t_reg_DACAB_out is record--
    data : t_field_signals_DACAB_data_out;--
  end record;
  type t_reg_DACAB_2d_in is array (integer range <>) of t_reg_DACAB_in;
  type t_reg_DACAB_2d_out is array (integer range <>) of t_reg_DACAB_out;
  type t_reg_DACAB_3d_in is array (integer range <>, integer range <>) of t_reg_DACAB_in;
  type t_reg_DACAB_3d_out is array (integer range <>, integer range <>) of t_reg_DACAB_out;
  -----------------------------------------------
  -- register type: DAC_STATUS
  -----------------------------------------------
  type t_field_signals_DAC_STATUS_data_in is record
    data : std_logic_vector(4-1 downto 0);--
  end record;

  type t_field_signals_DAC_STATUS_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_DAC_STATUS_in is record--
    data : t_field_signals_DAC_STATUS_data_in;--
  end record;
  type t_reg_DAC_STATUS_out is record--
    data : t_field_signals_DAC_STATUS_data_out;--
  end record;
  type t_reg_DAC_STATUS_2d_in is array (integer range <>) of t_reg_DAC_STATUS_in;
  type t_reg_DAC_STATUS_2d_out is array (integer range <>) of t_reg_DAC_STATUS_out;
  type t_reg_DAC_STATUS_3d_in is array (integer range <>, integer range <>) of t_reg_DAC_STATUS_in;
  type t_reg_DAC_STATUS_3d_out is array (integer range <>, integer range <>) of t_reg_DAC_STATUS_out;
  -----------------------------------------------
  -- register type: DAC
  -----------------------------------------------
  type t_field_signals_DAC_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_DAC_data_out is record
    data : std_logic_vector(12-1 downto 0);--
    swmod : std_logic; --
  end record;--

  -- The actual register types
  type t_reg_DAC_in is record--
    data : t_field_signals_DAC_data_in;--
  end record;
  type t_reg_DAC_out is record--
    data : t_field_signals_DAC_data_out;--
  end record;
  type t_reg_DAC_2d_in is array (integer range <>) of t_reg_DAC_in;
  type t_reg_DAC_2d_out is array (integer range <>) of t_reg_DAC_out;
  type t_reg_DAC_3d_in is array (integer range <>, integer range <>) of t_reg_DAC_in;
  type t_reg_DAC_3d_out is array (integer range <>, integer range <>) of t_reg_DAC_out;
  -----------------------------------------------
  -- register type: EXT_INTERLOCK
  -----------------------------------------------
  type t_field_signals_EXT_INTERLOCK_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_EXT_INTERLOCK_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_EXT_INTERLOCK_in is record--
    data : t_field_signals_EXT_INTERLOCK_data_in;--
  end record;
  type t_reg_EXT_INTERLOCK_out is record--
    data : t_field_signals_EXT_INTERLOCK_data_out;--
  end record;
  type t_reg_EXT_INTERLOCK_2d_in is array (integer range <>) of t_reg_EXT_INTERLOCK_in;
  type t_reg_EXT_INTERLOCK_2d_out is array (integer range <>) of t_reg_EXT_INTERLOCK_out;
  type t_reg_EXT_INTERLOCK_3d_in is array (integer range <>, integer range <>) of t_reg_EXT_INTERLOCK_in;
  type t_reg_EXT_INTERLOCK_3d_out is array (integer range <>, integer range <>) of t_reg_EXT_INTERLOCK_out;
  -----------------------------------------------
  -- register type: HYT271_TEMP
  -----------------------------------------------
  type t_field_signals_HYT271_TEMP_data_in is record
    data : std_logic_vector(14-1 downto 0);--
  end record;

  type t_field_signals_HYT271_TEMP_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_HYT271_TEMP_in is record--
    data : t_field_signals_HYT271_TEMP_data_in;--
  end record;
  type t_reg_HYT271_TEMP_out is record--
    data : t_field_signals_HYT271_TEMP_data_out;--
  end record;
  type t_reg_HYT271_TEMP_2d_in is array (integer range <>) of t_reg_HYT271_TEMP_in;
  type t_reg_HYT271_TEMP_2d_out is array (integer range <>) of t_reg_HYT271_TEMP_out;
  type t_reg_HYT271_TEMP_3d_in is array (integer range <>, integer range <>) of t_reg_HYT271_TEMP_in;
  type t_reg_HYT271_TEMP_3d_out is array (integer range <>, integer range <>) of t_reg_HYT271_TEMP_out;
  -----------------------------------------------
  -- register type: HYT271_HUMI
  -----------------------------------------------
  type t_field_signals_HYT271_HUMI_data_in is record
    data : std_logic_vector(14-1 downto 0);--
  end record;

  type t_field_signals_HYT271_HUMI_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_HYT271_HUMI_in is record--
    data : t_field_signals_HYT271_HUMI_data_in;--
  end record;
  type t_reg_HYT271_HUMI_out is record--
    data : t_field_signals_HYT271_HUMI_data_out;--
  end record;
  type t_reg_HYT271_HUMI_2d_in is array (integer range <>) of t_reg_HYT271_HUMI_in;
  type t_reg_HYT271_HUMI_2d_out is array (integer range <>) of t_reg_HYT271_HUMI_out;
  type t_reg_HYT271_HUMI_3d_in is array (integer range <>, integer range <>) of t_reg_HYT271_HUMI_in;
  type t_reg_HYT271_HUMI_3d_out is array (integer range <>, integer range <>) of t_reg_HYT271_HUMI_out;
  -----------------------------------------------
  -- register type: HYT271_READ_ENA
  -----------------------------------------------
  type t_field_signals_HYT271_READ_ENA_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_HYT271_READ_ENA_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_HYT271_READ_ENA_in is record--
    data : t_field_signals_HYT271_READ_ENA_data_in;--
  end record;
  type t_reg_HYT271_READ_ENA_out is record--
    data : t_field_signals_HYT271_READ_ENA_data_out;--
  end record;
  type t_reg_HYT271_READ_ENA_2d_in is array (integer range <>) of t_reg_HYT271_READ_ENA_in;
  type t_reg_HYT271_READ_ENA_2d_out is array (integer range <>) of t_reg_HYT271_READ_ENA_out;
  type t_reg_HYT271_READ_ENA_3d_in is array (integer range <>, integer range <>) of t_reg_HYT271_READ_ENA_in;
  type t_reg_HYT271_READ_ENA_3d_out is array (integer range <>, integer range <>) of t_reg_HYT271_READ_ENA_out;
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
  -- rtm : Top module address map interface
  -- ---------------------------------------------------------------------------
  type t_addrmap_rtm_in is record
    --
    ID : t_reg_ID_in;--
    VERSION : t_reg_VERSION_in;--
    RF_PERMIT : t_reg_RF_PERMIT_in;--
    ATT_SEL : t_reg_ATT_SEL_in;--
    ATT_VAL : t_reg_ATT_VAL_in;--
    ATT_STATUS : t_reg_ATT_STATUS_in;--
    ADC_A : t_reg_ADC_A_in;--
    ADC_B : t_reg_ADC_B_in;--
    ADC_C : t_reg_ADC_C_in;--
    ADC_D : t_reg_ADC_D_in;--
    ADC_READ_ENA : t_reg_ADC_READ_ENA_in;--
    ADC_STATUS : t_reg_ADC_STATUS_in;--
    DACAB : t_reg_DACAB_in;--
    DAC_STATUS : t_reg_DAC_STATUS_in;--
    DAC : t_reg_DAC_2d_in(0 to 2-1);--
    EXT_INTERLOCK : t_reg_EXT_INTERLOCK_in;--
    HYT271_TEMP : t_reg_HYT271_TEMP_in;--
    HYT271_HUMI : t_reg_HYT271_HUMI_in;--
    HYT271_READ_ENA : t_reg_HYT271_READ_ENA_in;--
    --
    --
    --
  end record;

  type t_addrmap_rtm_out is record
    --
    ID : t_reg_ID_out;--
    VERSION : t_reg_VERSION_out;--
    RF_PERMIT : t_reg_RF_PERMIT_out;--
    ATT_SEL : t_reg_ATT_SEL_out;--
    ATT_VAL : t_reg_ATT_VAL_out;--
    ATT_STATUS : t_reg_ATT_STATUS_out;--
    ADC_A : t_reg_ADC_A_out;--
    ADC_B : t_reg_ADC_B_out;--
    ADC_C : t_reg_ADC_C_out;--
    ADC_D : t_reg_ADC_D_out;--
    ADC_READ_ENA : t_reg_ADC_READ_ENA_out;--
    ADC_STATUS : t_reg_ADC_STATUS_out;--
    DACAB : t_reg_DACAB_out;--
    DAC_STATUS : t_reg_DAC_STATUS_out;--
    DAC : t_reg_DAC_2d_out(0 to 2-1);--
    EXT_INTERLOCK : t_reg_EXT_INTERLOCK_out;--
    HYT271_TEMP : t_reg_HYT271_TEMP_out;--
    HYT271_HUMI : t_reg_HYT271_HUMI_out;--
    HYT271_READ_ENA : t_reg_HYT271_READ_ENA_out;--
    --
    --
    --
  end record;

  -- ===========================================================================
  -- top level component declaration
  -- must come after defining the interfaces
  -- ---------------------------------------------------------------------------
  subtype t_rtm_m2s is t_axi4l_m2s;
  subtype t_rtm_s2m is t_axi4l_s2m;

  component rtm is
      port (
        pi_clock : in std_logic;
        pi_reset : in std_logic;
        -- TOP subordinate memory mapped interface
        pi_s_top  : in  t_rtm_m2s;
        po_s_top  : out t_rtm_s2m;
        -- to logic interface
        pi_addrmap : in  t_addrmap_rtm_in;
        po_addrmap : out t_addrmap_rtm_out
      );
  end component rtm;

end package pkg_rtm;
--------------------------------------------------------------------------------
package body pkg_rtm is
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

use work.pkg_rtm.all;

entity rtm_ID is
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
end entity rtm_ID;

architecture rtl of rtm_ID is
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
    data_out(31 downto 0) <= std_logic_vector(to_signed(2,32));--
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

use work.pkg_rtm.all;

entity rtm_VERSION is
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
end entity rtm_VERSION;

architecture rtl of rtm_VERSION is
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
    data_out(7 downto 0) <= std_logic_vector(to_signed(4,8));--
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
-- register type: RF_PERMIT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_RF_PERMIT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_RF_PERMIT_in ;
    po_reg  : out t_reg_RF_PERMIT_out
  );
end entity rtm_RF_PERMIT;

architecture rtl of rtm_RF_PERMIT is
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
-- register type: ATT_SEL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_ATT_SEL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ATT_SEL_in ;
    po_reg  : out t_reg_ATT_SEL_out
  );
end entity rtm_ATT_SEL;

architecture rtl of rtm_ATT_SEL is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 9) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(9-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,9));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(8 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(8 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: ATT_VAL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_ATT_VAL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ATT_VAL_in ;
    po_reg  : out t_reg_ATT_VAL_out
  );
end entity rtm_ATT_VAL;

architecture rtl of rtm_ATT_VAL is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 6) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(6-1 downto 0);
    signal l_sw_wr_stb_q : std_logic;
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,6));
          l_sw_wr_stb_q <= '0';
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(5 downto 0);
          end if;
          l_sw_wr_stb_q <= pi_decoder_wr_stb;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    po_reg.data.swmod <= (not l_sw_wr_stb_q and pi_decoder_wr_stb) when rising_edge(pi_clock);
    data_out(5 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: ATT_STATUS
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_ATT_STATUS is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ATT_STATUS_in ;
    po_reg  : out t_reg_ATT_STATUS_out
  );
end entity rtm_ATT_STATUS;

architecture rtl of rtm_ATT_STATUS is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 1) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(0 downto 0) <= pi_reg.data.data(1-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: ADC_A
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_ADC_A is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_A_in ;
    po_reg  : out t_reg_ADC_A_out
  );
end entity rtm_ADC_A;

architecture rtl of rtm_ADC_A is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 25) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= std_logic_vector(resize(signed(data_out(24 downto 0)),C_DATA_WIDTH));--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(24 downto 0) <= pi_reg.data.data(25-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: ADC_B
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_ADC_B is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_B_in ;
    po_reg  : out t_reg_ADC_B_out
  );
end entity rtm_ADC_B;

architecture rtl of rtm_ADC_B is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 25) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= std_logic_vector(resize(signed(data_out(24 downto 0)),C_DATA_WIDTH));--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(24 downto 0) <= pi_reg.data.data(25-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: ADC_C
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_ADC_C is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_C_in ;
    po_reg  : out t_reg_ADC_C_out
  );
end entity rtm_ADC_C;

architecture rtl of rtm_ADC_C is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 25) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= std_logic_vector(resize(signed(data_out(24 downto 0)),C_DATA_WIDTH));--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(24 downto 0) <= pi_reg.data.data(25-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: ADC_D
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_ADC_D is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_D_in ;
    po_reg  : out t_reg_ADC_D_out
  );
end entity rtm_ADC_D;

architecture rtl of rtm_ADC_D is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 25) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= std_logic_vector(resize(signed(data_out(24 downto 0)),C_DATA_WIDTH));--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(24 downto 0) <= pi_reg.data.data(25-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: ADC_READ_ENA
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_ADC_READ_ENA is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_READ_ENA_in ;
    po_reg  : out t_reg_ADC_READ_ENA_out
  );
end entity rtm_ADC_READ_ENA;

architecture rtl of rtm_ADC_READ_ENA is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 4) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(4-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,4));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(3 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(3 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: ADC_STATUS
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_ADC_STATUS is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_STATUS_in ;
    po_reg  : out t_reg_ADC_STATUS_out
  );
end entity rtm_ADC_STATUS;

architecture rtl of rtm_ADC_STATUS is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 4) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(3 downto 0) <= pi_reg.data.data(4-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: DACAB
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_DACAB is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DACAB_in ;
    po_reg  : out t_reg_DACAB_out
  );
end entity rtm_DACAB;

architecture rtl of rtm_DACAB is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 12) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(12-1 downto 0);
    signal l_sw_wr_stb_q : std_logic;
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,12));
          l_sw_wr_stb_q <= '0';
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(11 downto 0);
          end if;
          l_sw_wr_stb_q <= pi_decoder_wr_stb;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    po_reg.data.swmod <= (not l_sw_wr_stb_q and pi_decoder_wr_stb) when rising_edge(pi_clock);
    data_out(11 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: DAC_STATUS
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_DAC_STATUS is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DAC_STATUS_in ;
    po_reg  : out t_reg_DAC_STATUS_out
  );
end entity rtm_DAC_STATUS;

architecture rtl of rtm_DAC_STATUS is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 4) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(3 downto 0) <= pi_reg.data.data(4-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: DAC
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_DAC is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DAC_in ;
    po_reg  : out t_reg_DAC_out
  );
end entity rtm_DAC;

architecture rtl of rtm_DAC is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 12) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(12-1 downto 0);
    signal l_sw_wr_stb_q : std_logic;
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,12));
          l_sw_wr_stb_q <= '0';
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(11 downto 0);
          end if;
          l_sw_wr_stb_q <= pi_decoder_wr_stb;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    po_reg.data.swmod <= (not l_sw_wr_stb_q and pi_decoder_wr_stb) when rising_edge(pi_clock);
    data_out(11 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: EXT_INTERLOCK
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_EXT_INTERLOCK is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_EXT_INTERLOCK_in ;
    po_reg  : out t_reg_EXT_INTERLOCK_out
  );
end entity rtm_EXT_INTERLOCK;

architecture rtl of rtm_EXT_INTERLOCK is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 1) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(0 downto 0) <= pi_reg.data.data(1-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: HYT271_TEMP
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_HYT271_TEMP is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_HYT271_TEMP_in ;
    po_reg  : out t_reg_HYT271_TEMP_out
  );
end entity rtm_HYT271_TEMP;

architecture rtl of rtm_HYT271_TEMP is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 14) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(13 downto 0) <= pi_reg.data.data(14-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: HYT271_HUMI
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_HYT271_HUMI is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_HYT271_HUMI_in ;
    po_reg  : out t_reg_HYT271_HUMI_out
  );
end entity rtm_HYT271_HUMI;

architecture rtl of rtm_HYT271_HUMI is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 14) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(13 downto 0) <= pi_reg.data.data(14-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: HYT271_READ_ENA
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_rtm.all;

entity rtm_HYT271_READ_ENA is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_HYT271_READ_ENA_in ;
    po_reg  : out t_reg_HYT271_READ_ENA_out
  );
end entity rtm_HYT271_READ_ENA;

architecture rtl of rtm_HYT271_READ_ENA is
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