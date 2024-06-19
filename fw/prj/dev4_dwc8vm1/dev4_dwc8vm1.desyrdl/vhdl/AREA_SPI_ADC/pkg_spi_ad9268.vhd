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

package pkg_spi_ad9268 is

  -----------------------------------------------
  -- per addrmap / module
  -----------------------------------------------
  constant C_ADDR_WIDTH : integer := 11;
  constant C_DATA_WIDTH : integer := 32;

  -- ===========================================================================
  -- ---------------------------------------------------------------------------
  -- registers
  -- ---------------------------------------------------------------------------

  -- ===========================================================================
  -- REGISTERS interface
  -- ---------------------------------------------------------------------------
  -- register type: spi_reg
  -----------------------------------------------
  type t_field_signals_spi_reg_data_in is record
    data : std_logic_vector(8-1 downto 0);--
  end record;

  type t_field_signals_spi_reg_data_out is record
    data : std_logic_vector(8-1 downto 0);--
  end record;--

  -- The actual register types
  type t_reg_spi_reg_in is record--
    data : t_field_signals_spi_reg_data_in;--
  end record;
  type t_reg_spi_reg_out is record--
    data : t_field_signals_spi_reg_data_out;--
  end record;
  type t_reg_spi_reg_2d_in is array (integer range <>) of t_reg_spi_reg_in;
  type t_reg_spi_reg_2d_out is array (integer range <>) of t_reg_spi_reg_out;
  type t_reg_spi_reg_3d_in is array (integer range <>, integer range <>) of t_reg_spi_reg_in;
  type t_reg_spi_reg_3d_out is array (integer range <>, integer range <>) of t_reg_spi_reg_out;
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
  -- spi_ad9268 : Top module address map interface
  -- ---------------------------------------------------------------------------
  type t_addrmap_spi_ad9268_in is record
    --
    spi_regs : t_reg_spi_reg_2d_in(0 to 257-1);--
    --
    --
    --
  end record;

  type t_addrmap_spi_ad9268_out is record
    --
    spi_regs : t_reg_spi_reg_2d_out(0 to 257-1);--
    --
    --
    --
  end record;

  -- ===========================================================================
  -- top level component declaration
  -- must come after defining the interfaces
  -- ---------------------------------------------------------------------------
  subtype t_spi_ad9268_m2s is t_axi4l_m2s;
  subtype t_spi_ad9268_s2m is t_axi4l_s2m;

  component spi_ad9268 is
      port (
        pi_clock : in std_logic;
        pi_reset : in std_logic;
        -- TOP subordinate memory mapped interface
        pi_s_top  : in  t_spi_ad9268_m2s;
        po_s_top  : out t_spi_ad9268_s2m;
        -- to logic interface
        pi_addrmap : in  t_addrmap_spi_ad9268_in;
        po_addrmap : out t_addrmap_spi_ad9268_out
      );
  end component spi_ad9268;

end package pkg_spi_ad9268;
--------------------------------------------------------------------------------
package body pkg_spi_ad9268 is
end package body;

--==============================================================================


--------------------------------------------------------------------------------
-- Register types directly in addmap
--------------------------------------------------------------------------------
--
-- register type: spi_reg
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_spi_ad9268.all;

entity spi_ad9268_spi_reg is
  port (
    pi_clock        : in  std_logic;
    pi_reset        : in  std_logic;
    -- to/from adapter
    pi_decoder_rd_stb : in  std_logic;
    pi_decoder_wr_stb : in  std_logic;
    pi_decoder_data   : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
    po_decoder_data   : out std_logic_vector(C_DATA_WIDTH-1 downto 0);

    pi_reg  : in t_reg_spi_reg_in ;
    po_reg  : out t_reg_spi_reg_out
  );
end entity spi_ad9268_spi_reg;

architecture rtl of spi_ad9268_spi_reg is
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
          l_field_reg <= pi_reg.data.data;
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

--------------------------------------------------------------------------------
-- Register types in regfiles
--------------------------------------------------------------------------------
--