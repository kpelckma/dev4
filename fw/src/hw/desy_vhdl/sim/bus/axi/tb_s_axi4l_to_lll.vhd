------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2023 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2023-01-25
--! @author Katharina Schulz  <katharina.schulz@desy.de>
------------------------------------------------------------------------------
--! @brief
--! AXI4L Bridge to LLL Interface Test Bench
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;
use desy.common_axi.all;
use desy.common_bsp_ifs.all;

------------------------------------------------------------------------------------------------------------------------
entity tb_s_axi4l_to_lll is
end entity tb_s_axi4l_to_lll;

------------------------------------------------------------------------------------------------------------------------

architecture sim of tb_s_axi4l_to_lll is

  constant C_THOLD: time := 1 ns;
  -- component generics
  constant g_word_bit_size      : natural := 18;
  
  -- component ports
  signal pi_clock : std_logic                                    := '1';
  signal pi_reset : std_logic                                    := '0';
  
  signal pi_s_axi4l : t_axi4l_m2s := C_AXI4_M2S_DEFAULT;
  signal po_s_axi4l : t_axi4l_s2m := C_AXI4_S2M_DEFAULT;

  -- LLL Master Interface
  signal po_is_up_lll  : std_logic;
  signal pi_m_lll      : t_axi4s_p2p_s2m;
  signal po_m_lll      : t_axi4s_p2p_m2s;
  signal pi_s_lll      : t_axi4s_p2p_m2s;
  signal po_s_lll      : t_axi4s_p2p_s2m;

begin

  DUT: entity desy.s_axil_to_lll
  generic map(
    G_W_WAIT <= 63,
    G_R_WAIT <= 2047
  )
  port map (
    pi_clock => pi_clock,
    pi_reset => pi_reset,
    -- AXI4 Slave Interface
    pi_s_axi4l <= pi_s_axi4l,
    po_s_axi4l <= po_s_axi4l,
    -- LLL Master Interface
    po_is_up_lll  <= po_is_up_lll,
    pi_m_lll      <= pi_m_lll,
    po_m_lll      <= po_m_lll,
    pi_s_lll      <= pi_s_lll,
    po_s_lll      <= po_s_lll
    );

  -- clock generation
  pi_clock <= not pi_clock after 5 ns;

  -- write transaction
  prs_write: process
    begin
      -- insert signal assignments here
      pi_reset <= '1';
      wait for 100 ns;
      wait until rising_edge(pi_clock);
      wait for C_THOLD;
      pi_reset <= '0';

    end process;

end architecture sim;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
