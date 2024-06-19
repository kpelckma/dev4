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

package pkg_sis8300ku_bsp_logic is

  -----------------------------------------------
  -- per addrmap / module
  -----------------------------------------------
  constant C_ADDR_WIDTH : integer := 17;
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
  -- register type: PRJ_ID
  -----------------------------------------------
  type t_field_signals_PRJ_ID_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_PRJ_ID_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_PRJ_ID_in is record--
    data : t_field_signals_PRJ_ID_data_in;--
  end record;
  type t_reg_PRJ_ID_out is record--
    data : t_field_signals_PRJ_ID_data_out;--
  end record;
  type t_reg_PRJ_ID_2d_in is array (integer range <>) of t_reg_PRJ_ID_in;
  type t_reg_PRJ_ID_2d_out is array (integer range <>) of t_reg_PRJ_ID_out;
  type t_reg_PRJ_ID_3d_in is array (integer range <>, integer range <>) of t_reg_PRJ_ID_in;
  type t_reg_PRJ_ID_3d_out is array (integer range <>, integer range <>) of t_reg_PRJ_ID_out;
  -----------------------------------------------
  -- register type: PRJ_VERSION
  -----------------------------------------------
  type t_field_signals_PRJ_VERSION_changes_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_PRJ_VERSION_changes_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--
  type t_field_signals_PRJ_VERSION_patch_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_PRJ_VERSION_patch_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--
  type t_field_signals_PRJ_VERSION_minor_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_PRJ_VERSION_minor_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--
  type t_field_signals_PRJ_VERSION_major_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_PRJ_VERSION_major_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_PRJ_VERSION_in is record--
    changes : t_field_signals_PRJ_VERSION_changes_in;--
    patch : t_field_signals_PRJ_VERSION_patch_in;--
    minor : t_field_signals_PRJ_VERSION_minor_in;--
    major : t_field_signals_PRJ_VERSION_major_in;--
  end record;
  type t_reg_PRJ_VERSION_out is record--
    changes : t_field_signals_PRJ_VERSION_changes_out;--
    patch : t_field_signals_PRJ_VERSION_patch_out;--
    minor : t_field_signals_PRJ_VERSION_minor_out;--
    major : t_field_signals_PRJ_VERSION_major_out;--
  end record;
  type t_reg_PRJ_VERSION_2d_in is array (integer range <>) of t_reg_PRJ_VERSION_in;
  type t_reg_PRJ_VERSION_2d_out is array (integer range <>) of t_reg_PRJ_VERSION_out;
  type t_reg_PRJ_VERSION_3d_in is array (integer range <>, integer range <>) of t_reg_PRJ_VERSION_in;
  type t_reg_PRJ_VERSION_3d_out is array (integer range <>, integer range <>) of t_reg_PRJ_VERSION_out;
  -----------------------------------------------
  -- register type: PRJ_SHASUM
  -----------------------------------------------
  type t_field_signals_PRJ_SHASUM_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_PRJ_SHASUM_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_PRJ_SHASUM_in is record--
    data : t_field_signals_PRJ_SHASUM_data_in;--
  end record;
  type t_reg_PRJ_SHASUM_out is record--
    data : t_field_signals_PRJ_SHASUM_data_out;--
  end record;
  type t_reg_PRJ_SHASUM_2d_in is array (integer range <>) of t_reg_PRJ_SHASUM_in;
  type t_reg_PRJ_SHASUM_2d_out is array (integer range <>) of t_reg_PRJ_SHASUM_out;
  type t_reg_PRJ_SHASUM_3d_in is array (integer range <>, integer range <>) of t_reg_PRJ_SHASUM_in;
  type t_reg_PRJ_SHASUM_3d_out is array (integer range <>, integer range <>) of t_reg_PRJ_SHASUM_out;
  -----------------------------------------------
  -- register type: PRJ_TIMESTAMP
  -----------------------------------------------
  type t_field_signals_PRJ_TIMESTAMP_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_PRJ_TIMESTAMP_data_out is record
    data : std_logic_vector(32-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_PRJ_TIMESTAMP_in is record--
    data : t_field_signals_PRJ_TIMESTAMP_data_in;--
  end record;
  type t_reg_PRJ_TIMESTAMP_out is record--
    data : t_field_signals_PRJ_TIMESTAMP_data_out;--
  end record;
  type t_reg_PRJ_TIMESTAMP_2d_in is array (integer range <>) of t_reg_PRJ_TIMESTAMP_in;
  type t_reg_PRJ_TIMESTAMP_2d_out is array (integer range <>) of t_reg_PRJ_TIMESTAMP_out;
  type t_reg_PRJ_TIMESTAMP_3d_in is array (integer range <>, integer range <>) of t_reg_PRJ_TIMESTAMP_in;
  type t_reg_PRJ_TIMESTAMP_3d_out is array (integer range <>, integer range <>) of t_reg_PRJ_TIMESTAMP_out;
  -----------------------------------------------
  -- register type: SCRATCH
  -----------------------------------------------
  type t_field_signals_SCRATCH_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_SCRATCH_data_out is record
    data : std_logic_vector(32-1 downto 0);--
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
  -- register type: RESET_N
  -----------------------------------------------
  type t_field_signals_RESET_N_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_RESET_N_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_RESET_N_in is record--
    data : t_field_signals_RESET_N_data_in;--
  end record;
  type t_reg_RESET_N_out is record--
    data : t_field_signals_RESET_N_data_out;--
  end record;
  type t_reg_RESET_N_2d_in is array (integer range <>) of t_reg_RESET_N_in;
  type t_reg_RESET_N_2d_out is array (integer range <>) of t_reg_RESET_N_out;
  type t_reg_RESET_N_3d_in is array (integer range <>, integer range <>) of t_reg_RESET_N_in;
  type t_reg_RESET_N_3d_out is array (integer range <>, integer range <>) of t_reg_RESET_N_out;
  -----------------------------------------------
  -- register type: CLK_MUX
  -----------------------------------------------
  type t_field_signals_CLK_MUX_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_CLK_MUX_data_out is record
    data : std_logic_vector(2-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_CLK_MUX_in is record--
    data : t_field_signals_CLK_MUX_data_in;--
  end record;
  type t_reg_CLK_MUX_out is record--
    data : t_field_signals_CLK_MUX_data_out;--
  end record;
  type t_reg_CLK_MUX_2d_in is array (integer range <>) of t_reg_CLK_MUX_in;
  type t_reg_CLK_MUX_2d_out is array (integer range <>) of t_reg_CLK_MUX_out;
  type t_reg_CLK_MUX_3d_in is array (integer range <>, integer range <>) of t_reg_CLK_MUX_in;
  type t_reg_CLK_MUX_3d_out is array (integer range <>, integer range <>) of t_reg_CLK_MUX_out;
  -----------------------------------------------
  -- register type: CLK_SEL
  -----------------------------------------------
  type t_field_signals_CLK_SEL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_CLK_SEL_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_CLK_SEL_in is record--
    data : t_field_signals_CLK_SEL_data_in;--
  end record;
  type t_reg_CLK_SEL_out is record--
    data : t_field_signals_CLK_SEL_data_out;--
  end record;
  type t_reg_CLK_SEL_2d_in is array (integer range <>) of t_reg_CLK_SEL_in;
  type t_reg_CLK_SEL_2d_out is array (integer range <>) of t_reg_CLK_SEL_out;
  type t_reg_CLK_SEL_3d_in is array (integer range <>, integer range <>) of t_reg_CLK_SEL_in;
  type t_reg_CLK_SEL_3d_out is array (integer range <>, integer range <>) of t_reg_CLK_SEL_out;
  -----------------------------------------------
  -- register type: CLK_RST
  -----------------------------------------------
  type t_field_signals_CLK_RST_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_CLK_RST_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_CLK_RST_in is record--
    data : t_field_signals_CLK_RST_data_in;--
  end record;
  type t_reg_CLK_RST_out is record--
    data : t_field_signals_CLK_RST_data_out;--
  end record;
  type t_reg_CLK_RST_2d_in is array (integer range <>) of t_reg_CLK_RST_in;
  type t_reg_CLK_RST_2d_out is array (integer range <>) of t_reg_CLK_RST_out;
  type t_reg_CLK_RST_3d_in is array (integer range <>, integer range <>) of t_reg_CLK_RST_in;
  type t_reg_CLK_RST_3d_out is array (integer range <>, integer range <>) of t_reg_CLK_RST_out;
  -----------------------------------------------
  -- register type: CLK_FREQ
  -----------------------------------------------
  type t_field_signals_CLK_FREQ_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_CLK_FREQ_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_CLK_FREQ_in is record--
    data : t_field_signals_CLK_FREQ_data_in;--
  end record;
  type t_reg_CLK_FREQ_out is record--
    data : t_field_signals_CLK_FREQ_data_out;--
  end record;
  type t_reg_CLK_FREQ_2d_in is array (integer range <>) of t_reg_CLK_FREQ_in;
  type t_reg_CLK_FREQ_2d_out is array (integer range <>) of t_reg_CLK_FREQ_out;
  type t_reg_CLK_FREQ_3d_in is array (integer range <>, integer range <>) of t_reg_CLK_FREQ_in;
  type t_reg_CLK_FREQ_3d_out is array (integer range <>, integer range <>) of t_reg_CLK_FREQ_out;
  -----------------------------------------------
  -- register type: CLK_ERR
  -----------------------------------------------
  type t_field_signals_CLK_ERR_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_CLK_ERR_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_CLK_ERR_in is record--
    data : t_field_signals_CLK_ERR_data_in;--
  end record;
  type t_reg_CLK_ERR_out is record--
    data : t_field_signals_CLK_ERR_data_out;--
  end record;
  type t_reg_CLK_ERR_2d_in is array (integer range <>) of t_reg_CLK_ERR_in;
  type t_reg_CLK_ERR_2d_out is array (integer range <>) of t_reg_CLK_ERR_out;
  type t_reg_CLK_ERR_3d_in is array (integer range <>, integer range <>) of t_reg_CLK_ERR_in;
  type t_reg_CLK_ERR_3d_out is array (integer range <>, integer range <>) of t_reg_CLK_ERR_out;
  -----------------------------------------------
  -- register type: SPI_DIV_SEL
  -----------------------------------------------
  type t_field_signals_SPI_DIV_SEL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_SPI_DIV_SEL_data_out is record
    data : std_logic_vector(2-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SPI_DIV_SEL_in is record--
    data : t_field_signals_SPI_DIV_SEL_data_in;--
  end record;
  type t_reg_SPI_DIV_SEL_out is record--
    data : t_field_signals_SPI_DIV_SEL_data_out;--
  end record;
  type t_reg_SPI_DIV_SEL_2d_in is array (integer range <>) of t_reg_SPI_DIV_SEL_in;
  type t_reg_SPI_DIV_SEL_2d_out is array (integer range <>) of t_reg_SPI_DIV_SEL_out;
  type t_reg_SPI_DIV_SEL_3d_in is array (integer range <>, integer range <>) of t_reg_SPI_DIV_SEL_in;
  type t_reg_SPI_DIV_SEL_3d_out is array (integer range <>, integer range <>) of t_reg_SPI_DIV_SEL_out;
  -----------------------------------------------
  -- register type: SPI_DIV_BUSY
  -----------------------------------------------
  type t_field_signals_SPI_DIV_BUSY_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_SPI_DIV_BUSY_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SPI_DIV_BUSY_in is record--
    data : t_field_signals_SPI_DIV_BUSY_data_in;--
  end record;
  type t_reg_SPI_DIV_BUSY_out is record--
    data : t_field_signals_SPI_DIV_BUSY_data_out;--
  end record;
  type t_reg_SPI_DIV_BUSY_2d_in is array (integer range <>) of t_reg_SPI_DIV_BUSY_in;
  type t_reg_SPI_DIV_BUSY_2d_out is array (integer range <>) of t_reg_SPI_DIV_BUSY_out;
  type t_reg_SPI_DIV_BUSY_3d_in is array (integer range <>, integer range <>) of t_reg_SPI_DIV_BUSY_in;
  type t_reg_SPI_DIV_BUSY_3d_out is array (integer range <>, integer range <>) of t_reg_SPI_DIV_BUSY_out;
  -----------------------------------------------
  -- register type: ADC_ENA
  -----------------------------------------------
  type t_field_signals_ADC_ENA_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_ADC_ENA_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ADC_ENA_in is record--
    data : t_field_signals_ADC_ENA_data_in;--
  end record;
  type t_reg_ADC_ENA_out is record--
    data : t_field_signals_ADC_ENA_data_out;--
  end record;
  type t_reg_ADC_ENA_2d_in is array (integer range <>) of t_reg_ADC_ENA_in;
  type t_reg_ADC_ENA_2d_out is array (integer range <>) of t_reg_ADC_ENA_out;
  type t_reg_ADC_ENA_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_ENA_in;
  type t_reg_ADC_ENA_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_ENA_out;
  -----------------------------------------------
  -- register type: ADC_IDELAY_CNT
  -----------------------------------------------
  type t_field_signals_ADC_IDELAY_CNT_data_in is record
    data : std_logic_vector(9-1 downto 0);--
  end record;

  type t_field_signals_ADC_IDELAY_CNT_data_out is record
    data : std_logic_vector(9-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_ADC_IDELAY_CNT_in is record--
    data : t_field_signals_ADC_IDELAY_CNT_data_in;--
  end record;
  type t_reg_ADC_IDELAY_CNT_out is record--
    data : t_field_signals_ADC_IDELAY_CNT_data_out;--
  end record;
  type t_reg_ADC_IDELAY_CNT_2d_in is array (integer range <>) of t_reg_ADC_IDELAY_CNT_in;
  type t_reg_ADC_IDELAY_CNT_2d_out is array (integer range <>) of t_reg_ADC_IDELAY_CNT_out;
  type t_reg_ADC_IDELAY_CNT_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_IDELAY_CNT_in;
  type t_reg_ADC_IDELAY_CNT_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_IDELAY_CNT_out;
  -----------------------------------------------
  -- register type: ADC_REVERT_CLK
  -----------------------------------------------
  type t_field_signals_ADC_REVERT_CLK_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_ADC_REVERT_CLK_data_out is record
    data : std_logic_vector(5-1 downto 0);--
    swmod : std_logic; --
  end record;--

  -- The actual register types
  type t_reg_ADC_REVERT_CLK_in is record--
    data : t_field_signals_ADC_REVERT_CLK_data_in;--
  end record;
  type t_reg_ADC_REVERT_CLK_out is record--
    data : t_field_signals_ADC_REVERT_CLK_data_out;--
  end record;
  type t_reg_ADC_REVERT_CLK_2d_in is array (integer range <>) of t_reg_ADC_REVERT_CLK_in;
  type t_reg_ADC_REVERT_CLK_2d_out is array (integer range <>) of t_reg_ADC_REVERT_CLK_out;
  type t_reg_ADC_REVERT_CLK_3d_in is array (integer range <>, integer range <>) of t_reg_ADC_REVERT_CLK_in;
  type t_reg_ADC_REVERT_CLK_3d_out is array (integer range <>, integer range <>) of t_reg_ADC_REVERT_CLK_out;
  -----------------------------------------------
  -- register type: SPI_ADC_SEL
  -----------------------------------------------
  type t_field_signals_SPI_ADC_SEL_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_SPI_ADC_SEL_data_out is record
    data : std_logic_vector(3-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SPI_ADC_SEL_in is record--
    data : t_field_signals_SPI_ADC_SEL_data_in;--
  end record;
  type t_reg_SPI_ADC_SEL_out is record--
    data : t_field_signals_SPI_ADC_SEL_data_out;--
  end record;
  type t_reg_SPI_ADC_SEL_2d_in is array (integer range <>) of t_reg_SPI_ADC_SEL_in;
  type t_reg_SPI_ADC_SEL_2d_out is array (integer range <>) of t_reg_SPI_ADC_SEL_out;
  type t_reg_SPI_ADC_SEL_3d_in is array (integer range <>, integer range <>) of t_reg_SPI_ADC_SEL_in;
  type t_reg_SPI_ADC_SEL_3d_out is array (integer range <>, integer range <>) of t_reg_SPI_ADC_SEL_out;
  -----------------------------------------------
  -- register type: SPI_ADC_BUSY
  -----------------------------------------------
  type t_field_signals_SPI_ADC_BUSY_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_SPI_ADC_BUSY_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_SPI_ADC_BUSY_in is record--
    data : t_field_signals_SPI_ADC_BUSY_data_in;--
  end record;
  type t_reg_SPI_ADC_BUSY_out is record--
    data : t_field_signals_SPI_ADC_BUSY_data_out;--
  end record;
  type t_reg_SPI_ADC_BUSY_2d_in is array (integer range <>) of t_reg_SPI_ADC_BUSY_in;
  type t_reg_SPI_ADC_BUSY_2d_out is array (integer range <>) of t_reg_SPI_ADC_BUSY_out;
  type t_reg_SPI_ADC_BUSY_3d_in is array (integer range <>, integer range <>) of t_reg_SPI_ADC_BUSY_in;
  type t_reg_SPI_ADC_BUSY_3d_out is array (integer range <>, integer range <>) of t_reg_SPI_ADC_BUSY_out;
  -----------------------------------------------
  -- register type: DAC_ENA
  -----------------------------------------------
  type t_field_signals_DAC_ENA_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_DAC_ENA_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_DAC_ENA_in is record--
    data : t_field_signals_DAC_ENA_data_in;--
  end record;
  type t_reg_DAC_ENA_out is record--
    data : t_field_signals_DAC_ENA_data_out;--
  end record;
  type t_reg_DAC_ENA_2d_in is array (integer range <>) of t_reg_DAC_ENA_in;
  type t_reg_DAC_ENA_2d_out is array (integer range <>) of t_reg_DAC_ENA_out;
  type t_reg_DAC_ENA_3d_in is array (integer range <>, integer range <>) of t_reg_DAC_ENA_in;
  type t_reg_DAC_ENA_3d_out is array (integer range <>, integer range <>) of t_reg_DAC_ENA_out;
  -----------------------------------------------
  -- register type: DAC_IDELAY_INC
  -----------------------------------------------
  type t_field_signals_DAC_IDELAY_INC_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_DAC_IDELAY_INC_data_out is record
    data : std_logic_vector(1-1 downto 0);--
    swmod : std_logic; --
  end record;--

  -- The actual register types
  type t_reg_DAC_IDELAY_INC_in is record--
    data : t_field_signals_DAC_IDELAY_INC_data_in;--
  end record;
  type t_reg_DAC_IDELAY_INC_out is record--
    data : t_field_signals_DAC_IDELAY_INC_data_out;--
  end record;
  type t_reg_DAC_IDELAY_INC_2d_in is array (integer range <>) of t_reg_DAC_IDELAY_INC_in;
  type t_reg_DAC_IDELAY_INC_2d_out is array (integer range <>) of t_reg_DAC_IDELAY_INC_out;
  type t_reg_DAC_IDELAY_INC_3d_in is array (integer range <>, integer range <>) of t_reg_DAC_IDELAY_INC_in;
  type t_reg_DAC_IDELAY_INC_3d_out is array (integer range <>, integer range <>) of t_reg_DAC_IDELAY_INC_out;
  -----------------------------------------------
  -- register type: DAC_IDELAY_CNT
  -----------------------------------------------
  type t_field_signals_DAC_IDELAY_CNT_data_in is record
    data : std_logic_vector(9-1 downto 0);--
  end record;

  type t_field_signals_DAC_IDELAY_CNT_data_out is record
    data : std_logic_vector(9-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_DAC_IDELAY_CNT_in is record--
    data : t_field_signals_DAC_IDELAY_CNT_data_in;--
  end record;
  type t_reg_DAC_IDELAY_CNT_out is record--
    data : t_field_signals_DAC_IDELAY_CNT_data_out;--
  end record;
  type t_reg_DAC_IDELAY_CNT_2d_in is array (integer range <>) of t_reg_DAC_IDELAY_CNT_in;
  type t_reg_DAC_IDELAY_CNT_2d_out is array (integer range <>) of t_reg_DAC_IDELAY_CNT_out;
  type t_reg_DAC_IDELAY_CNT_3d_in is array (integer range <>, integer range <>) of t_reg_DAC_IDELAY_CNT_in;
  type t_reg_DAC_IDELAY_CNT_3d_out is array (integer range <>, integer range <>) of t_reg_DAC_IDELAY_CNT_out;
  -----------------------------------------------
  -- register type: DDR_CALIB_DONE
  -----------------------------------------------
  type t_field_signals_DDR_CALIB_DONE_data_in is record
    data : std_logic_vector(1-1 downto 0);--
  end record;

  type t_field_signals_DDR_CALIB_DONE_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_DDR_CALIB_DONE_in is record--
    data : t_field_signals_DDR_CALIB_DONE_data_in;--
  end record;
  type t_reg_DDR_CALIB_DONE_out is record--
    data : t_field_signals_DDR_CALIB_DONE_data_out;--
  end record;
  type t_reg_DDR_CALIB_DONE_2d_in is array (integer range <>) of t_reg_DDR_CALIB_DONE_in;
  type t_reg_DDR_CALIB_DONE_2d_out is array (integer range <>) of t_reg_DDR_CALIB_DONE_out;
  type t_reg_DDR_CALIB_DONE_3d_in is array (integer range <>, integer range <>) of t_reg_DDR_CALIB_DONE_in;
  type t_reg_DDR_CALIB_DONE_3d_out is array (integer range <>, integer range <>) of t_reg_DDR_CALIB_DONE_out;
  -----------------------------------------------
  -- register type: BOOT_STATUS
  -----------------------------------------------
  type t_field_signals_BOOT_STATUS_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_BOOT_STATUS_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_BOOT_STATUS_in is record--
    data : t_field_signals_BOOT_STATUS_data_in;--
  end record;
  type t_reg_BOOT_STATUS_out is record--
    data : t_field_signals_BOOT_STATUS_data_out;--
  end record;
  type t_reg_BOOT_STATUS_2d_in is array (integer range <>) of t_reg_BOOT_STATUS_in;
  type t_reg_BOOT_STATUS_2d_out is array (integer range <>) of t_reg_BOOT_STATUS_out;
  type t_reg_BOOT_STATUS_3d_in is array (integer range <>, integer range <>) of t_reg_BOOT_STATUS_in;
  type t_reg_BOOT_STATUS_3d_out is array (integer range <>, integer range <>) of t_reg_BOOT_STATUS_out;
  -----------------------------------------------
  -- register type: PCIE_IRQ_ENA
  -----------------------------------------------
  type t_field_signals_PCIE_IRQ_ENA_data_in is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;

  type t_field_signals_PCIE_IRQ_ENA_data_out is record
    data : std_logic_vector(1-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_PCIE_IRQ_ENA_in is record--
    data : t_field_signals_PCIE_IRQ_ENA_data_in;--
  end record;
  type t_reg_PCIE_IRQ_ENA_out is record--
    data : t_field_signals_PCIE_IRQ_ENA_data_out;--
  end record;
  type t_reg_PCIE_IRQ_ENA_2d_in is array (integer range <>) of t_reg_PCIE_IRQ_ENA_in;
  type t_reg_PCIE_IRQ_ENA_2d_out is array (integer range <>) of t_reg_PCIE_IRQ_ENA_out;
  type t_reg_PCIE_IRQ_ENA_3d_in is array (integer range <>, integer range <>) of t_reg_PCIE_IRQ_ENA_in;
  type t_reg_PCIE_IRQ_ENA_3d_out is array (integer range <>, integer range <>) of t_reg_PCIE_IRQ_ENA_out;
  -----------------------------------------------
  -- register type: PCIE_IRQ_ACK_TIMEOUT
  -----------------------------------------------
  type t_field_signals_PCIE_IRQ_ACK_TIMEOUT_data_in is record
    data : std_logic_vector(32-1 downto 0);--
  end record;

  type t_field_signals_PCIE_IRQ_ACK_TIMEOUT_data_out is record
    -- no data if field cannot be written from hw
    data : std_logic_vector(-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_PCIE_IRQ_ACK_TIMEOUT_in is record--
    data : t_field_signals_PCIE_IRQ_ACK_TIMEOUT_data_in;--
  end record;
  type t_reg_PCIE_IRQ_ACK_TIMEOUT_out is record--
    data : t_field_signals_PCIE_IRQ_ACK_TIMEOUT_data_out;--
  end record;
  type t_reg_PCIE_IRQ_ACK_TIMEOUT_2d_in is array (integer range <>) of t_reg_PCIE_IRQ_ACK_TIMEOUT_in;
  type t_reg_PCIE_IRQ_ACK_TIMEOUT_2d_out is array (integer range <>) of t_reg_PCIE_IRQ_ACK_TIMEOUT_out;
  type t_reg_PCIE_IRQ_ACK_TIMEOUT_3d_in is array (integer range <>, integer range <>) of t_reg_PCIE_IRQ_ACK_TIMEOUT_in;
  type t_reg_PCIE_IRQ_ACK_TIMEOUT_3d_out is array (integer range <>, integer range <>) of t_reg_PCIE_IRQ_ACK_TIMEOUT_out;
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
  -- sis8300ku_bsp_logic : Top module address map interface
  -- ---------------------------------------------------------------------------
  type t_addrmap_sis8300ku_bsp_logic_in is record
    --
    ID : t_reg_ID_in;--
    VERSION : t_reg_VERSION_in;--
    PRJ_ID : t_reg_PRJ_ID_in;--
    PRJ_VERSION : t_reg_PRJ_VERSION_in;--
    PRJ_SHASUM : t_reg_PRJ_SHASUM_in;--
    PRJ_TIMESTAMP : t_reg_PRJ_TIMESTAMP_in;--
    SCRATCH : t_reg_SCRATCH_in;--
    RESET_N : t_reg_RESET_N_in;--
    CLK_MUX : t_reg_CLK_MUX_2d_in(0 to 6-1);--
    CLK_SEL : t_reg_CLK_SEL_in;--
    CLK_RST : t_reg_CLK_RST_in;--
    CLK_FREQ : t_reg_CLK_FREQ_2d_in(0 to 8-1);--
    CLK_ERR : t_reg_CLK_ERR_in;--
    SPI_DIV_SEL : t_reg_SPI_DIV_SEL_in;--
    SPI_DIV_BUSY : t_reg_SPI_DIV_BUSY_in;--
    ADC_ENA : t_reg_ADC_ENA_in;--
    ADC_IDELAY_CNT : t_reg_ADC_IDELAY_CNT_2d_in(0 to 5-1);--
    ADC_REVERT_CLK : t_reg_ADC_REVERT_CLK_in;--
    SPI_ADC_SEL : t_reg_SPI_ADC_SEL_in;--
    SPI_ADC_BUSY : t_reg_SPI_ADC_BUSY_in;--
    DAC_ENA : t_reg_DAC_ENA_in;--
    DAC_IDELAY_INC : t_reg_DAC_IDELAY_INC_in;--
    DAC_IDELAY_CNT : t_reg_DAC_IDELAY_CNT_in;--
    DDR_CALIB_DONE : t_reg_DDR_CALIB_DONE_in;--
    BOOT_STATUS : t_reg_BOOT_STATUS_in;--
    PCIE_IRQ_ENA : t_reg_PCIE_IRQ_ENA_2d_in(0 to 16-1);--
    PCIE_IRQ_ACK_TIMEOUT : t_reg_PCIE_IRQ_ACK_TIMEOUT_2d_in(0 to 16-1);--
    --
    --
    --
    FCM : t_axi4l_s2m;--
    AREA_SPI_DIV : t_axi4l_s2m;--
    AREA_SPI_ADC : t_axi4l_s2m;--
  end record;

  type t_addrmap_sis8300ku_bsp_logic_out is record
    --
    ID : t_reg_ID_out;--
    VERSION : t_reg_VERSION_out;--
    PRJ_ID : t_reg_PRJ_ID_out;--
    PRJ_VERSION : t_reg_PRJ_VERSION_out;--
    PRJ_SHASUM : t_reg_PRJ_SHASUM_out;--
    PRJ_TIMESTAMP : t_reg_PRJ_TIMESTAMP_out;--
    SCRATCH : t_reg_SCRATCH_out;--
    RESET_N : t_reg_RESET_N_out;--
    CLK_MUX : t_reg_CLK_MUX_2d_out(0 to 6-1);--
    CLK_SEL : t_reg_CLK_SEL_out;--
    CLK_RST : t_reg_CLK_RST_out;--
    CLK_FREQ : t_reg_CLK_FREQ_2d_out(0 to 8-1);--
    CLK_ERR : t_reg_CLK_ERR_out;--
    SPI_DIV_SEL : t_reg_SPI_DIV_SEL_out;--
    SPI_DIV_BUSY : t_reg_SPI_DIV_BUSY_out;--
    ADC_ENA : t_reg_ADC_ENA_out;--
    ADC_IDELAY_CNT : t_reg_ADC_IDELAY_CNT_2d_out(0 to 5-1);--
    ADC_REVERT_CLK : t_reg_ADC_REVERT_CLK_out;--
    SPI_ADC_SEL : t_reg_SPI_ADC_SEL_out;--
    SPI_ADC_BUSY : t_reg_SPI_ADC_BUSY_out;--
    DAC_ENA : t_reg_DAC_ENA_out;--
    DAC_IDELAY_INC : t_reg_DAC_IDELAY_INC_out;--
    DAC_IDELAY_CNT : t_reg_DAC_IDELAY_CNT_out;--
    DDR_CALIB_DONE : t_reg_DDR_CALIB_DONE_out;--
    BOOT_STATUS : t_reg_BOOT_STATUS_out;--
    PCIE_IRQ_ENA : t_reg_PCIE_IRQ_ENA_2d_out(0 to 16-1);--
    PCIE_IRQ_ACK_TIMEOUT : t_reg_PCIE_IRQ_ACK_TIMEOUT_2d_out(0 to 16-1);--
    --
    --
    --
    FCM : t_axi4l_m2s;--
    AREA_SPI_DIV : t_axi4l_m2s;--
    AREA_SPI_ADC : t_axi4l_m2s;--
  end record;

  -- ===========================================================================
  -- top level component declaration
  -- must come after defining the interfaces
  -- ---------------------------------------------------------------------------
  subtype t_sis8300ku_bsp_logic_m2s is t_axi4l_m2s;
  subtype t_sis8300ku_bsp_logic_s2m is t_axi4l_s2m;

  component sis8300ku_bsp_logic is
      port (
        pi_clock : in std_logic;
        pi_reset : in std_logic;
        -- TOP subordinate memory mapped interface
        pi_s_top  : in  t_sis8300ku_bsp_logic_m2s;
        po_s_top  : out t_sis8300ku_bsp_logic_s2m;
        -- to logic interface
        pi_addrmap : in  t_addrmap_sis8300ku_bsp_logic_in;
        po_addrmap : out t_addrmap_sis8300ku_bsp_logic_out
      );
  end component sis8300ku_bsp_logic;

end package pkg_sis8300ku_bsp_logic;
--------------------------------------------------------------------------------
package body pkg_sis8300ku_bsp_logic is
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

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_ID is
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
end entity sis8300ku_bsp_logic_ID;

architecture rtl of sis8300ku_bsp_logic_ID is
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
    data_out(31 downto 0) <= std_logic_vector(to_signed(535822341,32));--
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

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_VERSION is
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
end entity sis8300ku_bsp_logic_VERSION;

architecture rtl of sis8300ku_bsp_logic_VERSION is
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
    data_out(7 downto 0) <= std_logic_vector(to_signed(42,8));--
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
    data_out(31 downto 24) <= std_logic_vector(to_signed(0,8));--
    --
    po_reg.major.data <= data_out(31 downto 24);--
  end block;--
end rtl;
-----------------------------------------------
-- register type: PRJ_ID
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_PRJ_ID is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_PRJ_ID_in ;
    po_reg  : out t_reg_PRJ_ID_out
  );
end entity sis8300ku_bsp_logic_PRJ_ID;

architecture rtl of sis8300ku_bsp_logic_PRJ_ID is
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
-- register type: PRJ_VERSION
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_PRJ_VERSION is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_PRJ_VERSION_in ;
    po_reg  : out t_reg_PRJ_VERSION_out
  );
end entity sis8300ku_bsp_logic_PRJ_VERSION;

architecture rtl of sis8300ku_bsp_logic_PRJ_VERSION is
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
-- register type: PRJ_SHASUM
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_PRJ_SHASUM is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_PRJ_SHASUM_in ;
    po_reg  : out t_reg_PRJ_SHASUM_out
  );
end entity sis8300ku_bsp_logic_PRJ_SHASUM;

architecture rtl of sis8300ku_bsp_logic_PRJ_SHASUM is
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
    data_out(31 downto 0) <= std_logic_vector(to_signed(-2034747885,32));--
    --
    po_reg.data.data <= data_out(31 downto 0);--
  end block;--
end rtl;
-----------------------------------------------
-- register type: PRJ_TIMESTAMP
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_PRJ_TIMESTAMP is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_PRJ_TIMESTAMP_in ;
    po_reg  : out t_reg_PRJ_TIMESTAMP_out
  );
end entity sis8300ku_bsp_logic_PRJ_TIMESTAMP;

architecture rtl of sis8300ku_bsp_logic_PRJ_TIMESTAMP is
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
    data_out(31 downto 0) <= std_logic_vector(to_signed(1695192362,32));--
    --
    po_reg.data.data <= data_out(31 downto 0);--
  end block;--
end rtl;
-----------------------------------------------
-- register type: SCRATCH
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_SCRATCH is
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
end entity sis8300ku_bsp_logic_SCRATCH;

architecture rtl of sis8300ku_bsp_logic_SCRATCH is
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
-- register type: RESET_N
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_RESET_N is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_RESET_N_in ;
    po_reg  : out t_reg_RESET_N_out
  );
end entity sis8300ku_bsp_logic_RESET_N;

architecture rtl of sis8300ku_bsp_logic_RESET_N is
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
-- register type: CLK_MUX
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_CLK_MUX is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CLK_MUX_in ;
    po_reg  : out t_reg_CLK_MUX_out
  );
end entity sis8300ku_bsp_logic_CLK_MUX;

architecture rtl of sis8300ku_bsp_logic_CLK_MUX is
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
-- register type: CLK_SEL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_CLK_SEL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CLK_SEL_in ;
    po_reg  : out t_reg_CLK_SEL_out
  );
end entity sis8300ku_bsp_logic_CLK_SEL;

architecture rtl of sis8300ku_bsp_logic_CLK_SEL is
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
-- register type: CLK_RST
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_CLK_RST is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CLK_RST_in ;
    po_reg  : out t_reg_CLK_RST_out
  );
end entity sis8300ku_bsp_logic_CLK_RST;

architecture rtl of sis8300ku_bsp_logic_CLK_RST is
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
-- register type: CLK_FREQ
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_CLK_FREQ is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CLK_FREQ_in ;
    po_reg  : out t_reg_CLK_FREQ_out
  );
end entity sis8300ku_bsp_logic_CLK_FREQ;

architecture rtl of sis8300ku_bsp_logic_CLK_FREQ is
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
-- register type: CLK_ERR
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_CLK_ERR is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_CLK_ERR_in ;
    po_reg  : out t_reg_CLK_ERR_out
  );
end entity sis8300ku_bsp_logic_CLK_ERR;

architecture rtl of sis8300ku_bsp_logic_CLK_ERR is
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
-- register type: SPI_DIV_SEL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_SPI_DIV_SEL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SPI_DIV_SEL_in ;
    po_reg  : out t_reg_SPI_DIV_SEL_out
  );
end entity sis8300ku_bsp_logic_SPI_DIV_SEL;

architecture rtl of sis8300ku_bsp_logic_SPI_DIV_SEL is
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
-- register type: SPI_DIV_BUSY
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_SPI_DIV_BUSY is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SPI_DIV_BUSY_in ;
    po_reg  : out t_reg_SPI_DIV_BUSY_out
  );
end entity sis8300ku_bsp_logic_SPI_DIV_BUSY;

architecture rtl of sis8300ku_bsp_logic_SPI_DIV_BUSY is
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
-- register type: ADC_ENA
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_ADC_ENA is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_ENA_in ;
    po_reg  : out t_reg_ADC_ENA_out
  );
end entity sis8300ku_bsp_logic_ADC_ENA;

architecture rtl of sis8300ku_bsp_logic_ADC_ENA is
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
-- register type: ADC_IDELAY_CNT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_ADC_IDELAY_CNT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_IDELAY_CNT_in ;
    po_reg  : out t_reg_ADC_IDELAY_CNT_out
  );
end entity sis8300ku_bsp_logic_ADC_IDELAY_CNT;

architecture rtl of sis8300ku_bsp_logic_ADC_IDELAY_CNT is
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
          l_field_reg <= pi_reg.data.data;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
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
-- register type: ADC_REVERT_CLK
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_ADC_REVERT_CLK is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_ADC_REVERT_CLK_in ;
    po_reg  : out t_reg_ADC_REVERT_CLK_out
  );
end entity sis8300ku_bsp_logic_ADC_REVERT_CLK;

architecture rtl of sis8300ku_bsp_logic_ADC_REVERT_CLK is
  signal data_out : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');
begin
  --
  data_out(C_DATA_WIDTH-1 downto 5) <= (others => '0');--

  -- resize field data out to the register bus width
  -- do only if 1 field and signed--
  po_decoder_data <= data_out;--

  ------------------------------------------------------------STORAGE
  data_storage: block
    signal l_field_reg   : std_logic_vector(5-1 downto 0);
    signal l_sw_wr_stb_q : std_logic;
  begin
    prs_write : process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          l_field_reg <= std_logic_vector(to_signed(0,5));
          l_sw_wr_stb_q <= '0';
        else
          -- HW --
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
          if pi_decoder_wr_stb = '1' then
            l_field_reg <= pi_decoder_data(4 downto 0);
          end if;
          l_sw_wr_stb_q <= pi_decoder_wr_stb;
        end if;
      end if;
    end process;
    --
    po_reg.data.data <= l_field_reg;--
    po_reg.data.swmod <= (not l_sw_wr_stb_q and pi_decoder_wr_stb) when rising_edge(pi_clock);
    data_out(4 downto 0) <= l_field_reg;

  end block data_storage;
  ----------------------------------------------------------
end rtl;
-----------------------------------------------
-- register type: SPI_ADC_SEL
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_SPI_ADC_SEL is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SPI_ADC_SEL_in ;
    po_reg  : out t_reg_SPI_ADC_SEL_out
  );
end entity sis8300ku_bsp_logic_SPI_ADC_SEL;

architecture rtl of sis8300ku_bsp_logic_SPI_ADC_SEL is
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
-- register type: SPI_ADC_BUSY
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_SPI_ADC_BUSY is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_SPI_ADC_BUSY_in ;
    po_reg  : out t_reg_SPI_ADC_BUSY_out
  );
end entity sis8300ku_bsp_logic_SPI_ADC_BUSY;

architecture rtl of sis8300ku_bsp_logic_SPI_ADC_BUSY is
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
-- register type: DAC_ENA
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_DAC_ENA is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DAC_ENA_in ;
    po_reg  : out t_reg_DAC_ENA_out
  );
end entity sis8300ku_bsp_logic_DAC_ENA;

architecture rtl of sis8300ku_bsp_logic_DAC_ENA is
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
-- register type: DAC_IDELAY_INC
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_DAC_IDELAY_INC is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DAC_IDELAY_INC_in ;
    po_reg  : out t_reg_DAC_IDELAY_INC_out
  );
end entity sis8300ku_bsp_logic_DAC_IDELAY_INC;

architecture rtl of sis8300ku_bsp_logic_DAC_IDELAY_INC is
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
-- register type: DAC_IDELAY_CNT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_DAC_IDELAY_CNT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DAC_IDELAY_CNT_in ;
    po_reg  : out t_reg_DAC_IDELAY_CNT_out
  );
end entity sis8300ku_bsp_logic_DAC_IDELAY_CNT;

architecture rtl of sis8300ku_bsp_logic_DAC_IDELAY_CNT is
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
          l_field_reg <= pi_reg.data.data;
          -- SW -- TODO: handle software access side effects (rcl/rset, woclr/woset, swacc/swmod)
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
-- register type: DDR_CALIB_DONE
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_DDR_CALIB_DONE is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_DDR_CALIB_DONE_in ;
    po_reg  : out t_reg_DDR_CALIB_DONE_out
  );
end entity sis8300ku_bsp_logic_DDR_CALIB_DONE;

architecture rtl of sis8300ku_bsp_logic_DDR_CALIB_DONE is
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
-- register type: BOOT_STATUS
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_BOOT_STATUS is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_BOOT_STATUS_in ;
    po_reg  : out t_reg_BOOT_STATUS_out
  );
end entity sis8300ku_bsp_logic_BOOT_STATUS;

architecture rtl of sis8300ku_bsp_logic_BOOT_STATUS is
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
-- register type: PCIE_IRQ_ENA
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_PCIE_IRQ_ENA is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_PCIE_IRQ_ENA_in ;
    po_reg  : out t_reg_PCIE_IRQ_ENA_out
  );
end entity sis8300ku_bsp_logic_PCIE_IRQ_ENA;

architecture rtl of sis8300ku_bsp_logic_PCIE_IRQ_ENA is
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
-- register type: PCIE_IRQ_ACK_TIMEOUT
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_sis8300ku_bsp_logic.all;

entity sis8300ku_bsp_logic_PCIE_IRQ_ACK_TIMEOUT is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_PCIE_IRQ_ACK_TIMEOUT_in ;
    po_reg  : out t_reg_PCIE_IRQ_ACK_TIMEOUT_out
  );
end entity sis8300ku_bsp_logic_PCIE_IRQ_ACK_TIMEOUT;

architecture rtl of sis8300ku_bsp_logic_PCIE_IRQ_ACK_TIMEOUT is
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

--------------------------------------------------------------------------------
-- Register types in regfiles
--------------------------------------------------------------------------------
--