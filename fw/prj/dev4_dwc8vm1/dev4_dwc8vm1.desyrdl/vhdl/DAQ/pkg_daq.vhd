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

package pkg_daq is

  -----------------------------------------------
  -- per addrmap / module
  -----------------------------------------------
  constant C_ADDR_WIDTH : integer := 14;
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
    data : std_logic_vector(1-1 downto 0);--
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
  -- register type: TAB_SEL
  -----------------------------------------------
  type t_field_signals_TAB_SEL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_TAB_SEL_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_TAB_SEL_in is record--
    data : t_field_signals_TAB_SEL_data_in;--
  end record;
  type t_reg_TAB_SEL_out is record--
    data : t_field_signals_TAB_SEL_data_out;--
  end record;
  type t_reg_TAB_SEL_2d_in is array (integer range <>) of t_reg_TAB_SEL_in;
  type t_reg_TAB_SEL_2d_out is array (integer range <>) of t_reg_TAB_SEL_out;
  type t_reg_TAB_SEL_3d_in is array (integer range <>, integer range <>) of t_reg_TAB_SEL_in;
  type t_reg_TAB_SEL_3d_out is array (integer range <>, integer range <>) of t_reg_TAB_SEL_out;
  -----------------------------------------------
  -- register type: STROBE_DIV
  -----------------------------------------------
  type t_field_signals_STROBE_DIV_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_STROBE_DIV_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_STROBE_DIV_in is record--
    data : t_field_signals_STROBE_DIV_data_in;--
  end record;
  type t_reg_STROBE_DIV_out is record--
    data : t_field_signals_STROBE_DIV_data_out;--
  end record;
  type t_reg_STROBE_DIV_2d_in is array (integer range <>) of t_reg_STROBE_DIV_in;
  type t_reg_STROBE_DIV_2d_out is array (integer range <>) of t_reg_STROBE_DIV_out;
  type t_reg_STROBE_DIV_3d_in is array (integer range <>, integer range <>) of t_reg_STROBE_DIV_in;
  type t_reg_STROBE_DIV_3d_out is array (integer range <>, integer range <>) of t_reg_STROBE_DIV_out;
  -----------------------------------------------
  -- register type: STROBE_CNT
  -----------------------------------------------
  type t_field_signals_STROBE_CNT_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_STROBE_CNT_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_STROBE_CNT_in is record--
    data : t_field_signals_STROBE_CNT_data_in;--
  end record;
  type t_reg_STROBE_CNT_out is record--
    data : t_field_signals_STROBE_CNT_data_out;--
  end record;
  type t_reg_STROBE_CNT_2d_in is array (integer range <>) of t_reg_STROBE_CNT_in;
  type t_reg_STROBE_CNT_2d_out is array (integer range <>) of t_reg_STROBE_CNT_out;
  type t_reg_STROBE_CNT_3d_in is array (integer range <>, integer range <>) of t_reg_STROBE_CNT_in;
  type t_reg_STROBE_CNT_3d_out is array (integer range <>, integer range <>) of t_reg_STROBE_CNT_out;
  -----------------------------------------------
  -- register type: SAMPLES
  -----------------------------------------------
  type t_field_signals_SAMPLES_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_SAMPLES_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SAMPLES_in is record--
    data : t_field_signals_SAMPLES_data_in;--
  end record;
  type t_reg_SAMPLES_out is record--
    data : t_field_signals_SAMPLES_data_out;--
  end record;
  type t_reg_SAMPLES_2d_in is array (integer range <>) of t_reg_SAMPLES_in;
  type t_reg_SAMPLES_2d_out is array (integer range <>) of t_reg_SAMPLES_out;
  type t_reg_SAMPLES_3d_in is array (integer range <>, integer range <>) of t_reg_SAMPLES_in;
  type t_reg_SAMPLES_3d_out is array (integer range <>, integer range <>) of t_reg_SAMPLES_out;
  -----------------------------------------------
  -- register type: DOUBLE_BUF_ENA
  -----------------------------------------------
  type t_field_signals_DOUBLE_BUF_ENA_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_DOUBLE_BUF_ENA_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_DOUBLE_BUF_ENA_in is record--
    data : t_field_signals_DOUBLE_BUF_ENA_data_in;--
  end record;
  type t_reg_DOUBLE_BUF_ENA_out is record--
    data : t_field_signals_DOUBLE_BUF_ENA_data_out;--
  end record;
  type t_reg_DOUBLE_BUF_ENA_2d_in is array (integer range <>) of t_reg_DOUBLE_BUF_ENA_in;
  type t_reg_DOUBLE_BUF_ENA_2d_out is array (integer range <>) of t_reg_DOUBLE_BUF_ENA_out;
  type t_reg_DOUBLE_BUF_ENA_3d_in is array (integer range <>, integer range <>) of t_reg_DOUBLE_BUF_ENA_in;
  type t_reg_DOUBLE_BUF_ENA_3d_out is array (integer range <>, integer range <>) of t_reg_DOUBLE_BUF_ENA_out;
  -----------------------------------------------
  -- register type: ACTIVE_BUF
  -----------------------------------------------
  type t_field_signals_ACTIVE_BUF_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_ACTIVE_BUF_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ACTIVE_BUF_in is record--
    data : t_field_signals_ACTIVE_BUF_data_in;--
  end record;
  type t_reg_ACTIVE_BUF_out is record--
    data : t_field_signals_ACTIVE_BUF_data_out;--
  end record;
  type t_reg_ACTIVE_BUF_2d_in is array (integer range <>) of t_reg_ACTIVE_BUF_in;
  type t_reg_ACTIVE_BUF_2d_out is array (integer range <>) of t_reg_ACTIVE_BUF_out;
  type t_reg_ACTIVE_BUF_3d_in is array (integer range <>, integer range <>) of t_reg_ACTIVE_BUF_in;
  type t_reg_ACTIVE_BUF_3d_out is array (integer range <>, integer range <>) of t_reg_ACTIVE_BUF_out;
  -----------------------------------------------
  -- register type: INACTIVE_BUF_ID
  -----------------------------------------------
  type t_field_signals_INACTIVE_BUF_ID_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_INACTIVE_BUF_ID_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_INACTIVE_BUF_ID_in is record--
    data : t_field_signals_INACTIVE_BUF_ID_data_in;--
  end record;
  type t_reg_INACTIVE_BUF_ID_out is record--
    data : t_field_signals_INACTIVE_BUF_ID_data_out;--
  end record;
  type t_reg_INACTIVE_BUF_ID_2d_in is array (integer range <>) of t_reg_INACTIVE_BUF_ID_in;
  type t_reg_INACTIVE_BUF_ID_2d_out is array (integer range <>) of t_reg_INACTIVE_BUF_ID_out;
  type t_reg_INACTIVE_BUF_ID_3d_in is array (integer range <>, integer range <>) of t_reg_INACTIVE_BUF_ID_in;
  type t_reg_INACTIVE_BUF_ID_3d_out is array (integer range <>, integer range <>) of t_reg_INACTIVE_BUF_ID_out;
  -----------------------------------------------
  -- register type: FIFO_STATUS
  -----------------------------------------------
  type t_field_signals_FIFO_STATUS_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_FIFO_STATUS_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_FIFO_STATUS_in is record--
    data : t_field_signals_FIFO_STATUS_data_in;--
  end record;
  type t_reg_FIFO_STATUS_out is record--
    data : t_field_signals_FIFO_STATUS_data_out;--
  end record;
  type t_reg_FIFO_STATUS_2d_in is array (integer range <>) of t_reg_FIFO_STATUS_in;
  type t_reg_FIFO_STATUS_2d_out is array (integer range <>) of t_reg_FIFO_STATUS_out;
  type t_reg_FIFO_STATUS_3d_in is array (integer range <>, integer range <>) of t_reg_FIFO_STATUS_in;
  type t_reg_FIFO_STATUS_3d_out is array (integer range <>, integer range <>) of t_reg_FIFO_STATUS_out;
  -----------------------------------------------
  -- register type: SENT_BURST_CNT
  -----------------------------------------------
  type t_field_signals_SENT_BURST_CNT_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_SENT_BURST_CNT_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SENT_BURST_CNT_in is record--
    data : t_field_signals_SENT_BURST_CNT_data_in;--
  end record;
  type t_reg_SENT_BURST_CNT_out is record--
    data : t_field_signals_SENT_BURST_CNT_data_out;--
  end record;
  type t_reg_SENT_BURST_CNT_2d_in is array (integer range <>) of t_reg_SENT_BURST_CNT_in;
  type t_reg_SENT_BURST_CNT_2d_out is array (integer range <>) of t_reg_SENT_BURST_CNT_out;
  type t_reg_SENT_BURST_CNT_3d_in is array (integer range <>, integer range <>) of t_reg_SENT_BURST_CNT_in;
  type t_reg_SENT_BURST_CNT_3d_out is array (integer range <>, integer range <>) of t_reg_SENT_BURST_CNT_out;
  -----------------------------------------------
  -- register type: TRG_DELAY_VAL
  -----------------------------------------------
  type t_field_signals_TRG_DELAY_VAL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_TRG_DELAY_VAL_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_TRG_DELAY_VAL_in is record--
    data : t_field_signals_TRG_DELAY_VAL_data_in;--
  end record;
  type t_reg_TRG_DELAY_VAL_out is record--
    data : t_field_signals_TRG_DELAY_VAL_data_out;--
  end record;
  type t_reg_TRG_DELAY_VAL_2d_in is array (integer range <>) of t_reg_TRG_DELAY_VAL_in;
  type t_reg_TRG_DELAY_VAL_2d_out is array (integer range <>) of t_reg_TRG_DELAY_VAL_out;
  type t_reg_TRG_DELAY_VAL_3d_in is array (integer range <>, integer range <>) of t_reg_TRG_DELAY_VAL_in;
  type t_reg_TRG_DELAY_VAL_3d_out is array (integer range <>, integer range <>) of t_reg_TRG_DELAY_VAL_out;
  -----------------------------------------------
  -- register type: TRG_DELAY_ENA
  -----------------------------------------------
  type t_field_signals_TRG_DELAY_ENA_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_TRG_DELAY_ENA_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_TRG_DELAY_ENA_in is record--
    data : t_field_signals_TRG_DELAY_ENA_data_in;--
  end record;
  type t_reg_TRG_DELAY_ENA_out is record--
    data : t_field_signals_TRG_DELAY_ENA_data_out;--
  end record;
  type t_reg_TRG_DELAY_ENA_2d_in is array (integer range <>) of t_reg_TRG_DELAY_ENA_in;
  type t_reg_TRG_DELAY_ENA_2d_out is array (integer range <>) of t_reg_TRG_DELAY_ENA_out;
  type t_reg_TRG_DELAY_ENA_3d_in is array (integer range <>, integer range <>) of t_reg_TRG_DELAY_ENA_in;
  type t_reg_TRG_DELAY_ENA_3d_out is array (integer range <>, integer range <>) of t_reg_TRG_DELAY_ENA_out;
  -----------------------------------------------
  -- register type: TRG_CNT_BUF0
  -----------------------------------------------
  type t_field_signals_TRG_CNT_BUF0_data_in is record
    data : std_logic_vector(16-1 downto 0);--
  end record;

  type t_field_signals_TRG_CNT_BUF0_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_TRG_CNT_BUF0_in is record--
    data : t_field_signals_TRG_CNT_BUF0_data_in;--
  end record;
  type t_reg_TRG_CNT_BUF0_out is record--
    data : t_field_signals_TRG_CNT_BUF0_data_out;--
  end record;
  type t_reg_TRG_CNT_BUF0_2d_in is array (integer range <>) of t_reg_TRG_CNT_BUF0_in;
  type t_reg_TRG_CNT_BUF0_2d_out is array (integer range <>) of t_reg_TRG_CNT_BUF0_out;
  type t_reg_TRG_CNT_BUF0_3d_in is array (integer range <>, integer range <>) of t_reg_TRG_CNT_BUF0_in;
  type t_reg_TRG_CNT_BUF0_3d_out is array (integer range <>, integer range <>) of t_reg_TRG_CNT_BUF0_out;
  -----------------------------------------------
  -- register type: TRG_CNT_BUF1
  -----------------------------------------------
  type t_field_signals_TRG_CNT_BUF1_data_in is record
    data : std_logic_vector(16-1 downto 0);--
  end record;

  type t_field_signals_TRG_CNT_BUF1_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_TRG_CNT_BUF1_in is record--
    data : t_field_signals_TRG_CNT_BUF1_data_in;--
  end record;
  type t_reg_TRG_CNT_BUF1_out is record--
    data : t_field_signals_TRG_CNT_BUF1_data_out;--
  end record;
  type t_reg_TRG_CNT_BUF1_2d_in is array (integer range <>) of t_reg_TRG_CNT_BUF1_in;
  type t_reg_TRG_CNT_BUF1_2d_out is array (integer range <>) of t_reg_TRG_CNT_BUF1_out;
  type t_reg_TRG_CNT_BUF1_3d_in is array (integer range <>, integer range <>) of t_reg_TRG_CNT_BUF1_in;
  type t_reg_TRG_CNT_BUF1_3d_out is array (integer range <>, integer range <>) of t_reg_TRG_CNT_BUF1_out;
  -----------------------------------------------
  -- register type: TIMESTAMP_RST
  -----------------------------------------------
  type t_field_signals_TIMESTAMP_RST_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_TIMESTAMP_RST_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_TIMESTAMP_RST_in is record--
    data : t_field_signals_TIMESTAMP_RST_data_in;--
  end record;
  type t_reg_TIMESTAMP_RST_out is record--
    data : t_field_signals_TIMESTAMP_RST_data_out;--
  end record;
  type t_reg_TIMESTAMP_RST_2d_in is array (integer range <>) of t_reg_TIMESTAMP_RST_in;
  type t_reg_TIMESTAMP_RST_2d_out is array (integer range <>) of t_reg_TIMESTAMP_RST_out;
  type t_reg_TIMESTAMP_RST_3d_in is array (integer range <>, integer range <>) of t_reg_TIMESTAMP_RST_in;
  type t_reg_TIMESTAMP_RST_3d_out is array (integer range <>, integer range <>) of t_reg_TIMESTAMP_RST_out;
  -----------------------------------------------

  ------------------------------------------------------------------------------
  -- Register types in regfiles --

  -- ===========================================================================
  -- REGFILE interface
  -- -----------------------------------------------------------------------------

  -- ===========================================================================
  -- MEMORIES interface
  -- ---------------------------------------------------------------------------
  -- memory type: DAQ_TIMES_0
  -----------------------------------------------
  type t_mem_DAQ_TIMES_0_out is record
    en   : std_logic;
    addr : std_logic_vector(12-1 downto 0);
    --
    we   : std_logic;
    data : std_logic_vector(32-1 downto 0);--
  end record t_mem_DAQ_TIMES_0_out;
  type t_mem_DAQ_TIMES_0_in is record
    --
    data : std_logic_vector(32-1 downto 0);
    --
  end record t_mem_DAQ_TIMES_0_in;
  type t_mem_DAQ_TIMES_0_2d_in is array (integer range <>) of t_mem_DAQ_TIMES_0_in;
  type t_mem_DAQ_TIMES_0_2d_out is array (integer range <>) of t_mem_DAQ_TIMES_0_out;
  -----------------------------------------------
  -- memory type: DAQ_TIMES_1
  -----------------------------------------------
  type t_mem_DAQ_TIMES_1_out is record
    en   : std_logic;
    addr : std_logic_vector(12-1 downto 0);
    --
    we   : std_logic;
    data : std_logic_vector(32-1 downto 0);--
  end record t_mem_DAQ_TIMES_1_out;
  type t_mem_DAQ_TIMES_1_in is record
    --
    data : std_logic_vector(32-1 downto 0);
    --
  end record t_mem_DAQ_TIMES_1_in;
  type t_mem_DAQ_TIMES_1_2d_in is array (integer range <>) of t_mem_DAQ_TIMES_1_in;
  type t_mem_DAQ_TIMES_1_2d_out is array (integer range <>) of t_mem_DAQ_TIMES_1_out;
  -----------------------------------------------
  -- memory type: DAQ_TIMES_2
  -----------------------------------------------
  type t_mem_DAQ_TIMES_2_out is record
    en   : std_logic;
    addr : std_logic_vector(12-1 downto 0);
    --
    we   : std_logic;
    data : std_logic_vector(32-1 downto 0);--
  end record t_mem_DAQ_TIMES_2_out;
  type t_mem_DAQ_TIMES_2_in is record
    --
    data : std_logic_vector(32-1 downto 0);
    --
  end record t_mem_DAQ_TIMES_2_in;
  type t_mem_DAQ_TIMES_2_2d_in is array (integer range <>) of t_mem_DAQ_TIMES_2_in;
  type t_mem_DAQ_TIMES_2_2d_out is array (integer range <>) of t_mem_DAQ_TIMES_2_out;
  -----------------------------------------------

  -- ===========================================================================
  -- daq : Top module address map interface
  -- ---------------------------------------------------------------------------
  type t_addrmap_daq_in is record
    --
    ID : t_reg_ID_in;--
    VERSION : t_reg_VERSION_in;--
    ENABLE : t_reg_ENABLE_in;--
    TAB_SEL : t_reg_TAB_SEL_2d_in(0 to 1-1);--
    STROBE_DIV : t_reg_STROBE_DIV_2d_in(0 to 1-1);--
    STROBE_CNT : t_reg_STROBE_CNT_2d_in(0 to 1-1);--
    SAMPLES : t_reg_SAMPLES_2d_in(0 to 1-1);--
    DOUBLE_BUF_ENA : t_reg_DOUBLE_BUF_ENA_in;--
    ACTIVE_BUF : t_reg_ACTIVE_BUF_in;--
    INACTIVE_BUF_ID : t_reg_INACTIVE_BUF_ID_2d_in(0 to 1-1);--
    FIFO_STATUS : t_reg_FIFO_STATUS_2d_in(0 to 1-1);--
    SENT_BURST_CNT : t_reg_SENT_BURST_CNT_2d_in(0 to 1-1);--
    TRG_DELAY_VAL : t_reg_TRG_DELAY_VAL_2d_in(0 to 1-1);--
    TRG_DELAY_ENA : t_reg_TRG_DELAY_ENA_in;--
    TRG_CNT_BUF0 : t_reg_TRG_CNT_BUF0_2d_in(0 to 1-1);--
    TRG_CNT_BUF1 : t_reg_TRG_CNT_BUF1_2d_in(0 to 1-1);--
    TIMESTAMP_RST : t_reg_TIMESTAMP_RST_in;--
    --
    --
    DAQ_TIMES_0 : t_mem_DAQ_TIMES_0_in;--
    DAQ_TIMES_1 : t_mem_DAQ_TIMES_1_in;--
    DAQ_TIMES_2 : t_mem_DAQ_TIMES_2_in;--
    --
  end record;

  type t_addrmap_daq_out is record
    --
    ID : t_reg_ID_out;--
    VERSION : t_reg_VERSION_out;--
    ENABLE : t_reg_ENABLE_out;--
    TAB_SEL : t_reg_TAB_SEL_2d_out(0 to 1-1);--
    STROBE_DIV : t_reg_STROBE_DIV_2d_out(0 to 1-1);--
    STROBE_CNT : t_reg_STROBE_CNT_2d_out(0 to 1-1);--
    SAMPLES : t_reg_SAMPLES_2d_out(0 to 1-1);--
    DOUBLE_BUF_ENA : t_reg_DOUBLE_BUF_ENA_out;--
    ACTIVE_BUF : t_reg_ACTIVE_BUF_out;--
    INACTIVE_BUF_ID : t_reg_INACTIVE_BUF_ID_2d_out(0 to 1-1);--
    FIFO_STATUS : t_reg_FIFO_STATUS_2d_out(0 to 1-1);--
    SENT_BURST_CNT : t_reg_SENT_BURST_CNT_2d_out(0 to 1-1);--
    TRG_DELAY_VAL : t_reg_TRG_DELAY_VAL_2d_out(0 to 1-1);--
    TRG_DELAY_ENA : t_reg_TRG_DELAY_ENA_out;--
    TRG_CNT_BUF0 : t_reg_TRG_CNT_BUF0_2d_out(0 to 1-1);--
    TRG_CNT_BUF1 : t_reg_TRG_CNT_BUF1_2d_out(0 to 1-1);--
    TIMESTAMP_RST : t_reg_TIMESTAMP_RST_out;--
    --
    --
    DAQ_TIMES_0 : t_mem_DAQ_TIMES_0_out;--
    DAQ_TIMES_1 : t_mem_DAQ_TIMES_1_out;--
    DAQ_TIMES_2 : t_mem_DAQ_TIMES_2_out;--
    --
  end record;

  -- ===========================================================================
  -- top level component declaration
  -- must come after defining the interfaces
  -- ---------------------------------------------------------------------------
  subtype t_daq_m2s is t_axi4l_m2s;
  subtype t_daq_s2m is t_axi4l_s2m;

  component daq is
      port (
        pi_clock : in std_logic;
        pi_reset : in std_logic;
        -- TOP subordinate memory mapped interface
        pi_s_top  : in  t_daq_m2s;
        po_s_top  : out t_daq_s2m;
        -- to logic interface
        pi_addrmap : in  t_addrmap_daq_in;
        po_addrmap : out t_addrmap_daq_out
      );
  end component daq;

end package pkg_daq;
--------------------------------------------------------------------------------
package body pkg_daq is
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

use work.pkg_daq.all;

entity daq_ID is
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
end entity daq_ID;

architecture rtl of daq_ID is
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

use work.pkg_daq.all;

entity daq_VERSION is
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
end entity daq_VERSION;

architecture rtl of daq_VERSION is
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
    data_out(7 downto 0) <= std_logic_vector(to_signed(16,8));--
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
    data_out(31 downto 24) <= std_logic_vector(to_signed(1,8));--
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

use work.pkg_daq.all;

entity daq_ENABLE is
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
end entity daq_ENABLE;

architecture rtl of daq_ENABLE is
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
-- register type: TAB_SEL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_TAB_SEL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_TAB_SEL_in ;
    po_reg  : out t_reg_TAB_SEL_out
  );
end entity daq_TAB_SEL;

architecture rtl of daq_TAB_SEL is
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
-- register type: STROBE_DIV
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_STROBE_DIV is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_STROBE_DIV_in ;
    po_reg  : out t_reg_STROBE_DIV_out
  );
end entity daq_STROBE_DIV;

architecture rtl of daq_STROBE_DIV is
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
-- register type: STROBE_CNT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_STROBE_CNT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_STROBE_CNT_in ;
    po_reg  : out t_reg_STROBE_CNT_out
  );
end entity daq_STROBE_CNT;

architecture rtl of daq_STROBE_CNT is
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
-- register type: SAMPLES
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_SAMPLES is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SAMPLES_in ;
    po_reg  : out t_reg_SAMPLES_out
  );
end entity daq_SAMPLES;

architecture rtl of daq_SAMPLES is
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
-- register type: DOUBLE_BUF_ENA
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_DOUBLE_BUF_ENA is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DOUBLE_BUF_ENA_in ;
    po_reg  : out t_reg_DOUBLE_BUF_ENA_out
  );
end entity daq_DOUBLE_BUF_ENA;

architecture rtl of daq_DOUBLE_BUF_ENA is
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
-- register type: ACTIVE_BUF
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_ACTIVE_BUF is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ACTIVE_BUF_in ;
    po_reg  : out t_reg_ACTIVE_BUF_out
  );
end entity daq_ACTIVE_BUF;

architecture rtl of daq_ACTIVE_BUF is
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
-- register type: INACTIVE_BUF_ID
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_INACTIVE_BUF_ID is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_INACTIVE_BUF_ID_in ;
    po_reg  : out t_reg_INACTIVE_BUF_ID_out
  );
end entity daq_INACTIVE_BUF_ID;

architecture rtl of daq_INACTIVE_BUF_ID is
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
-- register type: FIFO_STATUS
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_FIFO_STATUS is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_FIFO_STATUS_in ;
    po_reg  : out t_reg_FIFO_STATUS_out
  );
end entity daq_FIFO_STATUS;

architecture rtl of daq_FIFO_STATUS is
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
-- register type: SENT_BURST_CNT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_SENT_BURST_CNT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SENT_BURST_CNT_in ;
    po_reg  : out t_reg_SENT_BURST_CNT_out
  );
end entity daq_SENT_BURST_CNT;

architecture rtl of daq_SENT_BURST_CNT is
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
-- register type: TRG_DELAY_VAL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_TRG_DELAY_VAL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_TRG_DELAY_VAL_in ;
    po_reg  : out t_reg_TRG_DELAY_VAL_out
  );
end entity daq_TRG_DELAY_VAL;

architecture rtl of daq_TRG_DELAY_VAL is
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
-- register type: TRG_DELAY_ENA
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_TRG_DELAY_ENA is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_TRG_DELAY_ENA_in ;
    po_reg  : out t_reg_TRG_DELAY_ENA_out
  );
end entity daq_TRG_DELAY_ENA;

architecture rtl of daq_TRG_DELAY_ENA is
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
-- register type: TRG_CNT_BUF0
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_TRG_CNT_BUF0 is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_TRG_CNT_BUF0_in ;
    po_reg  : out t_reg_TRG_CNT_BUF0_out
  );
end entity daq_TRG_CNT_BUF0;

architecture rtl of daq_TRG_CNT_BUF0 is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 16) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(15 downto 0) <= pi_reg.data.data(16-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: TRG_CNT_BUF1
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_TRG_CNT_BUF1 is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_TRG_CNT_BUF1_in ;
    po_reg  : out t_reg_TRG_CNT_BUF1_out
  );
end entity daq_TRG_CNT_BUF1;

architecture rtl of daq_TRG_CNT_BUF1 is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 16) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------WIRE
  data_wire : block--
  begin
    --
    data_out(15 downto 0) <= pi_reg.data.data(16-1 downto 0);--
    --no signal to read by HW
    po_reg.data.data <= (others => '0');--
  end block;--
end rtl;
-----------------------------------------------
-- register type: TIMESTAMP_RST
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_daq.all;

entity daq_TIMESTAMP_RST is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_TIMESTAMP_RST_in ;
    po_reg  : out t_reg_TIMESTAMP_RST_out
  );
end entity daq_TIMESTAMP_RST;

architecture rtl of daq_TIMESTAMP_RST is
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