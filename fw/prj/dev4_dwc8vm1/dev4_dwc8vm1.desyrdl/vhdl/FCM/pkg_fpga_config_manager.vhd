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

package pkg_fpga_config_manager is

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
  -- register type: SPI_DIVIDER
  -----------------------------------------------
  type t_field_signals_SPI_DIVIDER_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_SPI_DIVIDER_data_out is record
    data : std_logic_vector(16-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SPI_DIVIDER_in is record--
    data : t_field_signals_SPI_DIVIDER_data_in;--
  end record;
  type t_reg_SPI_DIVIDER_out is record--
    data : t_field_signals_SPI_DIVIDER_data_out;--
  end record;
  type t_reg_SPI_DIVIDER_2d_in is array (integer range <>) of t_reg_SPI_DIVIDER_in;
  type t_reg_SPI_DIVIDER_2d_out is array (integer range <>) of t_reg_SPI_DIVIDER_out;
  type t_reg_SPI_DIVIDER_3d_in is array (integer range <>, integer range <>) of t_reg_SPI_DIVIDER_in;
  type t_reg_SPI_DIVIDER_3d_out is array (integer range <>, integer range <>) of t_reg_SPI_DIVIDER_out;
  -----------------------------------------------
  -- register type: BYTES_TO_WRITE
  -----------------------------------------------
  type t_field_signals_BYTES_TO_WRITE_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_BYTES_TO_WRITE_data_out is record
    data : std_logic_vector(16-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_BYTES_TO_WRITE_in is record--
    data : t_field_signals_BYTES_TO_WRITE_data_in;--
  end record;
  type t_reg_BYTES_TO_WRITE_out is record--
    data : t_field_signals_BYTES_TO_WRITE_data_out;--
  end record;
  type t_reg_BYTES_TO_WRITE_2d_in is array (integer range <>) of t_reg_BYTES_TO_WRITE_in;
  type t_reg_BYTES_TO_WRITE_2d_out is array (integer range <>) of t_reg_BYTES_TO_WRITE_out;
  type t_reg_BYTES_TO_WRITE_3d_in is array (integer range <>, integer range <>) of t_reg_BYTES_TO_WRITE_in;
  type t_reg_BYTES_TO_WRITE_3d_out is array (integer range <>, integer range <>) of t_reg_BYTES_TO_WRITE_out;
  -----------------------------------------------
  -- register type: BYTES_TO_READ
  -----------------------------------------------
  type t_field_signals_BYTES_TO_READ_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_BYTES_TO_READ_data_out is record
    data : std_logic_vector(16-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_BYTES_TO_READ_in is record--
    data : t_field_signals_BYTES_TO_READ_data_in;--
  end record;
  type t_reg_BYTES_TO_READ_out is record--
    data : t_field_signals_BYTES_TO_READ_data_out;--
  end record;
  type t_reg_BYTES_TO_READ_2d_in is array (integer range <>) of t_reg_BYTES_TO_READ_in;
  type t_reg_BYTES_TO_READ_2d_out is array (integer range <>) of t_reg_BYTES_TO_READ_out;
  type t_reg_BYTES_TO_READ_3d_in is array (integer range <>, integer range <>) of t_reg_BYTES_TO_READ_in;
  type t_reg_BYTES_TO_READ_3d_out is array (integer range <>, integer range <>) of t_reg_BYTES_TO_READ_out;
  -----------------------------------------------
  -- register type: CONTROL
  -----------------------------------------------
  type t_field_signals_CONTROL_data_in is record
    data : std_logic_vector(8-1 downto 0);--
    we   : std_logic;--
  end record;

  type t_field_signals_CONTROL_data_out is record
    data : std_logic_vector(8-1 downto 0);--
    swmod : std_logic; --
  end record;--

  -- The actual register types
  type t_reg_CONTROL_in is record--
    data : t_field_signals_CONTROL_data_in;--
  end record;
  type t_reg_CONTROL_out is record--
    data : t_field_signals_CONTROL_data_out;--
  end record;
  type t_reg_CONTROL_2d_in is array (integer range <>) of t_reg_CONTROL_in;
  type t_reg_CONTROL_2d_out is array (integer range <>) of t_reg_CONTROL_out;
  type t_reg_CONTROL_3d_in is array (integer range <>, integer range <>) of t_reg_CONTROL_in;
  type t_reg_CONTROL_3d_out is array (integer range <>, integer range <>) of t_reg_CONTROL_out;
  -----------------------------------------------
  -- register type: JTAG_TCK
  -----------------------------------------------
  type t_field_signals_JTAG_TCK_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_JTAG_TCK_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_JTAG_TCK_in is record--
    data : t_field_signals_JTAG_TCK_data_in;--
  end record;
  type t_reg_JTAG_TCK_out is record--
    data : t_field_signals_JTAG_TCK_data_out;--
  end record;
  type t_reg_JTAG_TCK_2d_in is array (integer range <>) of t_reg_JTAG_TCK_in;
  type t_reg_JTAG_TCK_2d_out is array (integer range <>) of t_reg_JTAG_TCK_out;
  type t_reg_JTAG_TCK_3d_in is array (integer range <>, integer range <>) of t_reg_JTAG_TCK_in;
  type t_reg_JTAG_TCK_3d_out is array (integer range <>, integer range <>) of t_reg_JTAG_TCK_out;
  -----------------------------------------------
  -- register type: JTAG_TMS
  -----------------------------------------------
  type t_field_signals_JTAG_TMS_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_JTAG_TMS_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_JTAG_TMS_in is record--
    data : t_field_signals_JTAG_TMS_data_in;--
  end record;
  type t_reg_JTAG_TMS_out is record--
    data : t_field_signals_JTAG_TMS_data_out;--
  end record;
  type t_reg_JTAG_TMS_2d_in is array (integer range <>) of t_reg_JTAG_TMS_in;
  type t_reg_JTAG_TMS_2d_out is array (integer range <>) of t_reg_JTAG_TMS_out;
  type t_reg_JTAG_TMS_3d_in is array (integer range <>, integer range <>) of t_reg_JTAG_TMS_in;
  type t_reg_JTAG_TMS_3d_out is array (integer range <>, integer range <>) of t_reg_JTAG_TMS_out;
  -----------------------------------------------
  -- register type: JTAG_TDI
  -----------------------------------------------
  type t_field_signals_JTAG_TDI_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_JTAG_TDI_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_JTAG_TDI_in is record--
    data : t_field_signals_JTAG_TDI_data_in;--
  end record;
  type t_reg_JTAG_TDI_out is record--
    data : t_field_signals_JTAG_TDI_data_out;--
  end record;
  type t_reg_JTAG_TDI_2d_in is array (integer range <>) of t_reg_JTAG_TDI_in;
  type t_reg_JTAG_TDI_2d_out is array (integer range <>) of t_reg_JTAG_TDI_out;
  type t_reg_JTAG_TDI_3d_in is array (integer range <>, integer range <>) of t_reg_JTAG_TDI_in;
  type t_reg_JTAG_TDI_3d_out is array (integer range <>, integer range <>) of t_reg_JTAG_TDI_out;
  -----------------------------------------------
  -- register type: JTAG_TDO
  -----------------------------------------------
  type t_field_signals_JTAG_TDO_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_JTAG_TDO_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_JTAG_TDO_in is record--
    data : t_field_signals_JTAG_TDO_data_in;--
  end record;
  type t_reg_JTAG_TDO_out is record--
    data : t_field_signals_JTAG_TDO_data_out;--
  end record;
  type t_reg_JTAG_TDO_2d_in is array (integer range <>) of t_reg_JTAG_TDO_in;
  type t_reg_JTAG_TDO_2d_out is array (integer range <>) of t_reg_JTAG_TDO_out;
  type t_reg_JTAG_TDO_3d_in is array (integer range <>, integer range <>) of t_reg_JTAG_TDO_in;
  type t_reg_JTAG_TDO_3d_out is array (integer range <>, integer range <>) of t_reg_JTAG_TDO_out;
  -----------------------------------------------
  -- register type: MAGIC
  -----------------------------------------------
  type t_field_signals_MAGIC_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_MAGIC_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_MAGIC_in is record--
    data : t_field_signals_MAGIC_data_in;--
  end record;
  type t_reg_MAGIC_out is record--
    data : t_field_signals_MAGIC_data_out;--
  end record;
  type t_reg_MAGIC_2d_in is array (integer range <>) of t_reg_MAGIC_in;
  type t_reg_MAGIC_2d_out is array (integer range <>) of t_reg_MAGIC_out;
  type t_reg_MAGIC_3d_in is array (integer range <>, integer range <>) of t_reg_MAGIC_in;
  type t_reg_MAGIC_3d_out is array (integer range <>, integer range <>) of t_reg_MAGIC_out;
  -----------------------------------------------
  -- register type: REV_SWITCH
  -----------------------------------------------
  type t_field_signals_REV_SWITCH_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_REV_SWITCH_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_REV_SWITCH_in is record--
    data : t_field_signals_REV_SWITCH_data_in;--
  end record;
  type t_reg_REV_SWITCH_out is record--
    data : t_field_signals_REV_SWITCH_data_out;--
  end record;
  type t_reg_REV_SWITCH_2d_in is array (integer range <>) of t_reg_REV_SWITCH_in;
  type t_reg_REV_SWITCH_2d_out is array (integer range <>) of t_reg_REV_SWITCH_out;
  type t_reg_REV_SWITCH_3d_in is array (integer range <>, integer range <>) of t_reg_REV_SWITCH_in;
  type t_reg_REV_SWITCH_3d_out is array (integer range <>, integer range <>) of t_reg_REV_SWITCH_out;
  -----------------------------------------------
  -- register type: REV_SEL
  -----------------------------------------------
  type t_field_signals_REV_SEL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_REV_SEL_data_out is record
    data : std_logic_vector(2-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_REV_SEL_in is record--
    data : t_field_signals_REV_SEL_data_in;--
  end record;
  type t_reg_REV_SEL_out is record--
    data : t_field_signals_REV_SEL_data_out;--
  end record;
  type t_reg_REV_SEL_2d_in is array (integer range <>) of t_reg_REV_SEL_in;
  type t_reg_REV_SEL_2d_out is array (integer range <>) of t_reg_REV_SEL_out;
  type t_reg_REV_SEL_3d_in is array (integer range <>, integer range <>) of t_reg_REV_SEL_in;
  type t_reg_REV_SEL_3d_out is array (integer range <>, integer range <>) of t_reg_REV_SEL_out;
  -----------------------------------------------
  -- register type: CRC_ERROR
  -----------------------------------------------
  type t_field_signals_CRC_ERROR_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_CRC_ERROR_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_CRC_ERROR_in is record--
    data : t_field_signals_CRC_ERROR_data_in;--
  end record;
  type t_reg_CRC_ERROR_out is record--
    data : t_field_signals_CRC_ERROR_data_out;--
  end record;
  type t_reg_CRC_ERROR_2d_in is array (integer range <>) of t_reg_CRC_ERROR_in;
  type t_reg_CRC_ERROR_2d_out is array (integer range <>) of t_reg_CRC_ERROR_out;
  type t_reg_CRC_ERROR_3d_in is array (integer range <>, integer range <>) of t_reg_CRC_ERROR_in;
  type t_reg_CRC_ERROR_3d_out is array (integer range <>, integer range <>) of t_reg_CRC_ERROR_out;
  -----------------------------------------------
  -- register type: CRC_ERROR_CNT
  -----------------------------------------------
  type t_field_signals_CRC_ERROR_CNT_data_in is record
    data : std_logic_vector(32-1 downto 0);--
    incr : std_logic; --
  end record;

  type t_field_signals_CRC_ERROR_CNT_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_CRC_ERROR_CNT_in is record--
    data : t_field_signals_CRC_ERROR_CNT_data_in;--
  end record;
  type t_reg_CRC_ERROR_CNT_out is record--
    data : t_field_signals_CRC_ERROR_CNT_data_out;--
  end record;
  type t_reg_CRC_ERROR_CNT_2d_in is array (integer range <>) of t_reg_CRC_ERROR_CNT_in;
  type t_reg_CRC_ERROR_CNT_2d_out is array (integer range <>) of t_reg_CRC_ERROR_CNT_out;
  type t_reg_CRC_ERROR_CNT_3d_in is array (integer range <>, integer range <>) of t_reg_CRC_ERROR_CNT_in;
  type t_reg_CRC_ERROR_CNT_3d_out is array (integer range <>, integer range <>) of t_reg_CRC_ERROR_CNT_out;
  -----------------------------------------------
  -- register type: ECC_ERROR_CNT
  -----------------------------------------------
  type t_field_signals_ECC_ERROR_CNT_data_in is record
    data : std_logic_vector(32-1 downto 0);--
    incr : std_logic; --
  end record;

  type t_field_signals_ECC_ERROR_CNT_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ECC_ERROR_CNT_in is record--
    data : t_field_signals_ECC_ERROR_CNT_data_in;--
  end record;
  type t_reg_ECC_ERROR_CNT_out is record--
    data : t_field_signals_ECC_ERROR_CNT_data_out;--
  end record;
  type t_reg_ECC_ERROR_CNT_2d_in is array (integer range <>) of t_reg_ECC_ERROR_CNT_in;
  type t_reg_ECC_ERROR_CNT_2d_out is array (integer range <>) of t_reg_ECC_ERROR_CNT_out;
  type t_reg_ECC_ERROR_CNT_3d_in is array (integer range <>, integer range <>) of t_reg_ECC_ERROR_CNT_in;
  type t_reg_ECC_ERROR_CNT_3d_out is array (integer range <>, integer range <>) of t_reg_ECC_ERROR_CNT_out;
  -----------------------------------------------
  -- register type: ECC_SYNDROME
  -----------------------------------------------
  type t_field_signals_ECC_SYNDROME_data_in is record
    data : std_logic_vector(13-1 downto 0);--
  end record;

  type t_field_signals_ECC_SYNDROME_data_out is record
    data : std_logic_vector(13-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ECC_SYNDROME_in is record--
    data : t_field_signals_ECC_SYNDROME_data_in;--
  end record;
  type t_reg_ECC_SYNDROME_out is record--
    data : t_field_signals_ECC_SYNDROME_data_out;--
  end record;
  type t_reg_ECC_SYNDROME_2d_in is array (integer range <>) of t_reg_ECC_SYNDROME_in;
  type t_reg_ECC_SYNDROME_2d_out is array (integer range <>) of t_reg_ECC_SYNDROME_out;
  type t_reg_ECC_SYNDROME_3d_in is array (integer range <>, integer range <>) of t_reg_ECC_SYNDROME_in;
  type t_reg_ECC_SYNDROME_3d_out is array (integer range <>, integer range <>) of t_reg_ECC_SYNDROME_out;
  -----------------------------------------------
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

  ------------------------------------------------------------------------------
  -- Register types in regfiles --

  -- ===========================================================================
  -- REGFILE interface
  -- -----------------------------------------------------------------------------

  -- ===========================================================================
  -- MEMORIES interface
  -- ---------------------------------------------------------------------------
  -- memory type: WRITE_BUF
  -----------------------------------------------
  type t_mem_WRITE_BUF_out is record
    en   : std_logic;
    addr : std_logic_vector(12-1 downto 0);
    --
    we   : std_logic;
    data : std_logic_vector(32-1 downto 0);--
  end record t_mem_WRITE_BUF_out;
  type t_mem_WRITE_BUF_in is record
    --
    data : std_logic_vector(32-1 downto 0);
    --
  end record t_mem_WRITE_BUF_in;
  type t_mem_WRITE_BUF_2d_in is array (integer range <>) of t_mem_WRITE_BUF_in;
  type t_mem_WRITE_BUF_2d_out is array (integer range <>) of t_mem_WRITE_BUF_out;
  -----------------------------------------------
  -- memory type: READ_BUF
  -----------------------------------------------
  type t_mem_READ_BUF_out is record
    en   : std_logic;
    addr : std_logic_vector(12-1 downto 0);
    --
    we   : std_logic;
    data : std_logic_vector(32-1 downto 0);--
  end record t_mem_READ_BUF_out;
  type t_mem_READ_BUF_in is record
    --
    data : std_logic_vector(32-1 downto 0);
    --
  end record t_mem_READ_BUF_in;
  type t_mem_READ_BUF_2d_in is array (integer range <>) of t_mem_READ_BUF_in;
  type t_mem_READ_BUF_2d_out is array (integer range <>) of t_mem_READ_BUF_out;
  -----------------------------------------------

  -- ===========================================================================
  -- fpga_config_manager : Top module address map interface
  -- ---------------------------------------------------------------------------
  type t_addrmap_fpga_config_manager_in is record
    --
    SPI_DIVIDER : t_reg_SPI_DIVIDER_in;--
    BYTES_TO_WRITE : t_reg_BYTES_TO_WRITE_in;--
    BYTES_TO_READ : t_reg_BYTES_TO_READ_in;--
    CONTROL : t_reg_CONTROL_in;--
    JTAG_TCK : t_reg_JTAG_TCK_in;--
    JTAG_TMS : t_reg_JTAG_TMS_in;--
    JTAG_TDI : t_reg_JTAG_TDI_in;--
    JTAG_TDO : t_reg_JTAG_TDO_in;--
    MAGIC : t_reg_MAGIC_in;--
    REV_SWITCH : t_reg_REV_SWITCH_in;--
    REV_SEL : t_reg_REV_SEL_in;--
    CRC_ERROR : t_reg_CRC_ERROR_in;--
    CRC_ERROR_CNT : t_reg_CRC_ERROR_CNT_in;--
    ECC_ERROR_CNT : t_reg_ECC_ERROR_CNT_in;--
    ECC_SYNDROME : t_reg_ECC_SYNDROME_in;--
    ID : t_reg_ID_in;--
    VERSION : t_reg_VERSION_in;--
    --
    --
    WRITE_BUF : t_mem_WRITE_BUF_in;--
    READ_BUF : t_mem_READ_BUF_in;--
    --
  end record;

  type t_addrmap_fpga_config_manager_out is record
    --
    SPI_DIVIDER : t_reg_SPI_DIVIDER_out;--
    BYTES_TO_WRITE : t_reg_BYTES_TO_WRITE_out;--
    BYTES_TO_READ : t_reg_BYTES_TO_READ_out;--
    CONTROL : t_reg_CONTROL_out;--
    JTAG_TCK : t_reg_JTAG_TCK_out;--
    JTAG_TMS : t_reg_JTAG_TMS_out;--
    JTAG_TDI : t_reg_JTAG_TDI_out;--
    JTAG_TDO : t_reg_JTAG_TDO_out;--
    MAGIC : t_reg_MAGIC_out;--
    REV_SWITCH : t_reg_REV_SWITCH_out;--
    REV_SEL : t_reg_REV_SEL_out;--
    CRC_ERROR : t_reg_CRC_ERROR_out;--
    CRC_ERROR_CNT : t_reg_CRC_ERROR_CNT_out;--
    ECC_ERROR_CNT : t_reg_ECC_ERROR_CNT_out;--
    ECC_SYNDROME : t_reg_ECC_SYNDROME_out;--
    ID : t_reg_ID_out;--
    VERSION : t_reg_VERSION_out;--
    --
    --
    WRITE_BUF : t_mem_WRITE_BUF_out;--
    READ_BUF : t_mem_READ_BUF_out;--
    --
  end record;

  -- ===========================================================================
  -- top level component declaration
  -- must come after defining the interfaces
  -- ---------------------------------------------------------------------------
  subtype t_fpga_config_manager_m2s is t_axi4l_m2s;
  subtype t_fpga_config_manager_s2m is t_axi4l_s2m;

  component fpga_config_manager is
      port (
        pi_clock : in std_logic;
        pi_reset : in std_logic;
        -- TOP subordinate memory mapped interface
        pi_s_top  : in  t_fpga_config_manager_m2s;
        po_s_top  : out t_fpga_config_manager_s2m;
        -- to logic interface
        pi_addrmap : in  t_addrmap_fpga_config_manager_in;
        po_addrmap : out t_addrmap_fpga_config_manager_out
      );
  end component fpga_config_manager;

end package pkg_fpga_config_manager;
--------------------------------------------------------------------------------
package body pkg_fpga_config_manager is
end package body;

--==============================================================================


--------------------------------------------------------------------------------
-- Register types directly in addmap
--------------------------------------------------------------------------------
--
-- register type: SPI_DIVIDER
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_SPI_DIVIDER is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SPI_DIVIDER_in ;
    po_reg  : out t_reg_SPI_DIVIDER_out
  );
end entity fpga_config_manager_SPI_DIVIDER;

architecture rtl of fpga_config_manager_SPI_DIVIDER is
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
          l_field_reg <= std_logic_vector(to_signed(10,16));
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
-- register type: BYTES_TO_WRITE
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_BYTES_TO_WRITE is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_BYTES_TO_WRITE_in ;
    po_reg  : out t_reg_BYTES_TO_WRITE_out
  );
end entity fpga_config_manager_BYTES_TO_WRITE;

architecture rtl of fpga_config_manager_BYTES_TO_WRITE is
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
-- register type: BYTES_TO_READ
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_BYTES_TO_READ is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_BYTES_TO_READ_in ;
    po_reg  : out t_reg_BYTES_TO_READ_out
  );
end entity fpga_config_manager_BYTES_TO_READ;

architecture rtl of fpga_config_manager_BYTES_TO_READ is
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
-- register type: CONTROL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_CONTROL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CONTROL_in ;
    po_reg  : out t_reg_CONTROL_out
  );
end entity fpga_config_manager_CONTROL;

architecture rtl of fpga_config_manager_CONTROL is
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
    signal l_sw_wr_stb_q : std_logic;
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,8));
          l_sw_wr_stb_q <= '0';
        else
          -- HW --
          if pi_reg.data.we = '1' then
            l_field_reg <= pi_reg.data.data;
          end if;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(7 downto 0);
          end if;
          l_sw_wr_stb_q <= pi_decoder_wr_stb;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    po_reg.data.swmod <= (not l_sw_wr_stb_q and pi_decoder_wr_stb) when rising_edge(pi_clock);
    data_out(7 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: JTAG_TCK
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_JTAG_TCK is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_JTAG_TCK_in ;
    po_reg  : out t_reg_JTAG_TCK_out
  );
end entity fpga_config_manager_JTAG_TCK;

architecture rtl of fpga_config_manager_JTAG_TCK is
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
-- register type: JTAG_TMS
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_JTAG_TMS is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_JTAG_TMS_in ;
    po_reg  : out t_reg_JTAG_TMS_out
  );
end entity fpga_config_manager_JTAG_TMS;

architecture rtl of fpga_config_manager_JTAG_TMS is
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
-- register type: JTAG_TDI
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_JTAG_TDI is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_JTAG_TDI_in ;
    po_reg  : out t_reg_JTAG_TDI_out
  );
end entity fpga_config_manager_JTAG_TDI;

architecture rtl of fpga_config_manager_JTAG_TDI is
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
-- register type: JTAG_TDO
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_JTAG_TDO is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_JTAG_TDO_in ;
    po_reg  : out t_reg_JTAG_TDO_out
  );
end entity fpga_config_manager_JTAG_TDO;

architecture rtl of fpga_config_manager_JTAG_TDO is
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
-- register type: MAGIC
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_MAGIC is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_MAGIC_in ;
    po_reg  : out t_reg_MAGIC_out
  );
end entity fpga_config_manager_MAGIC;

architecture rtl of fpga_config_manager_MAGIC is
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
-- register type: REV_SWITCH
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_REV_SWITCH is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_REV_SWITCH_in ;
    po_reg  : out t_reg_REV_SWITCH_out
  );
end entity fpga_config_manager_REV_SWITCH;

architecture rtl of fpga_config_manager_REV_SWITCH is
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
-- register type: REV_SEL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_REV_SEL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_REV_SEL_in ;
    po_reg  : out t_reg_REV_SEL_out
  );
end entity fpga_config_manager_REV_SEL;

architecture rtl of fpga_config_manager_REV_SEL is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 2) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(2-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,2));
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(1 downto 0);
          end if;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(1 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: CRC_ERROR
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_CRC_ERROR is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CRC_ERROR_in ;
    po_reg  : out t_reg_CRC_ERROR_out
  );
end entity fpga_config_manager_CRC_ERROR;

architecture rtl of fpga_config_manager_CRC_ERROR is
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
-- register type: CRC_ERROR_CNT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_CRC_ERROR_CNT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CRC_ERROR_CNT_in ;
    po_reg  : out t_reg_CRC_ERROR_CNT_out
  );
end entity fpga_config_manager_CRC_ERROR_CNT;

architecture rtl of fpga_config_manager_CRC_ERROR_CNT is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(32-1 downto 0);
    signal l_incrvalue   : natural;
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,32));
        else
          -- HW --
          l_field_reg <= pi_reg.data.data;
          -- counter
          if  pi_reg.data.incr = '1' then
            l_field_reg <= std_logic_vector(unsigned(l_field_reg) + to_unsigned(l_incrvalue, 32));
          end if;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(31 downto 0) <= l_field_reg;

    l_incrvalue <= 1;
  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: ECC_ERROR_CNT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_ECC_ERROR_CNT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ECC_ERROR_CNT_in ;
    po_reg  : out t_reg_ECC_ERROR_CNT_out
  );
end entity fpga_config_manager_ECC_ERROR_CNT;

architecture rtl of fpga_config_manager_ECC_ERROR_CNT is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(32-1 downto 0);
    signal l_incrvalue   : natural;
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,32));
        else
          -- HW --
          l_field_reg <= pi_reg.data.data;
          -- counter
          if  pi_reg.data.incr = '1' then
            l_field_reg <= std_logic_vector(unsigned(l_field_reg) + to_unsigned(l_incrvalue, 32));
          end if;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(31 downto 0) <= l_field_reg;

    l_incrvalue <= 1;
  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: ECC_SYNDROME
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_ECC_SYNDROME is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ECC_SYNDROME_in ;
    po_reg  : out t_reg_ECC_SYNDROME_out
  );
end entity fpga_config_manager_ECC_SYNDROME;

architecture rtl of fpga_config_manager_ECC_SYNDROME is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 13) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(13-1 downto 0);
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,13));
        else
          -- HW --
          l_field_reg <= pi_reg.data.data;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    data_out(12 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: ID
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_ID is
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
end entity fpga_config_manager_ID;

architecture rtl of fpga_config_manager_ID is
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
    data_out(31 downto 0) <= std_logic_vector(to_signed(32940047,32));--
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

use work.pkg_fpga_config_manager.all;

entity fpga_config_manager_VERSION is
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
end entity fpga_config_manager_VERSION;

architecture rtl of fpga_config_manager_VERSION is
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

--------------------------------------------------------------------------------
-- Register types in regfiles
--------------------------------------------------------------------------------
--