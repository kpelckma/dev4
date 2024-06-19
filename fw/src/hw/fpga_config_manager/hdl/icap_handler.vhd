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
--! @date 2018-10-25
--! @author Md Rahat Ibna Kamal
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! ICAP wrapper along with ICAP Controller FSM
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity icap_handler is
  generic (
    g_arch           : string  := "";   --! VIRTEX5,VIRTEX6,SPARTAN6,7SERIES,ULTRASCALE
    g_icap_clk_div   : natural := 0;
    g_mem_addr_width : natural := 23
  );
  port (
    pi_clock    : in std_logic;
    pi_switch   : in std_logic_vector(31 downto 0);
    pi_prog_sel : in std_logic_vector(g_mem_addr_width-22 downto 0)
  );
end icap_handler;

architecture arch of icap_handler is

  signal icap_clock    : std_logic;
  signal icap_din      : std_logic_vector(31 downto 0);
  signal icap_dout     : std_logic_vector(31 downto 0);
  signal icap_busy     : std_logic;
  signal icap_enable_n : std_logic;
  signal icap_wr_n     : std_logic;

begin

  --==============================================================================
  -- ICAP Primitive Wrapper
  --==============================================================================
  inst_icap_wrapper : entity work.icap_wrapper
  generic map(
    g_arch => G_ARCH
  )
  port map(
    pi_icap_clock => icap_clock,
    pi_din        => icap_din,
    po_dout       => icap_dout,
    po_busy       => icap_busy,
    pi_enable_n   => icap_enable_n,
    pi_wr_n       => icap_wr_n
  );

  --==============================================================================
  -- Multiboot operation FSM
  --==============================================================================
  inst_icap_boot_fsm : entity work.icap_boot_fsm
  generic map(
    g_arch           => g_arch,
    g_icap_clk_div   => g_icap_clk_div,
    g_mem_addr_width => g_mem_addr_width
  )
  port map(
    pi_clock      => pi_clock,
    pi_switch     => pi_switch,
    pi_prog_sel   => pi_prog_sel,
    po_icap_clock => icap_clock,
    po_din        => icap_din,
    pi_dout       => icap_dout,
    pi_busy       => icap_busy,
    po_enable_n   => icap_enable_n,
    po_wr_n       => icap_wr_n
  );

end arch;
