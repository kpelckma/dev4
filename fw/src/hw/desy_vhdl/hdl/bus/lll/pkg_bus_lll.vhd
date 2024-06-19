--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2022-09-19
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief Low Latency Link utilities package
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_types.all;
use desy.common_bsp_ifs.all;
use desy.common_mgt.all;

package bus_lll is

  constant C_K_CHARS  : t_8b_slv_vector(0 to 9) := (x"1C", x"3C", x"5C", x"7C", x"9C", x"DC", x"F7", x"FB", x"FD", x"FE");

  component lll is
    generic (
      G_MGT_CLK_CNT     : natural := 1;
      G_MGT_CLK         : natural := 0;
      G_MGT_SHARED_CNT  : natural := 0;
      G_MGT_SHARED      : natural := 0;
      G_DATA_BYTE       : natural := 4
    );
    port (
      pi_clock    : in  std_logic;
      pi_reset    : in  std_logic;
      pi_control  : in  std_logic_vector(31 downto 0);
      po_status   : out std_logic_vector(31 downto 0);
  
      pi_mgt_rx_p : in  std_logic;
      pi_mgt_rx_n : in  std_logic;
      po_mgt_tx_p : out std_logic; 
      po_mgt_tx_n : out std_logic;

      pi_mgt_clk  : in  std_logic_vector(G_MGT_CLK_CNT-1 downto 0);
  
      pi_mgt_shared : in  t_mgt_shared_vector(G_MGT_SHARED_CNT-1 downto 0);
      po_mgt_shared : out t_mgt_shared;
  
      pi_m_axi4s_aclk     : in  std_logic;
      pi_m_axi4s_areset_n : in  std_logic;
      pi_m_axi4s          : in  t_axi4s_p2p_s2m;
      po_m_axi4s          : out t_axi4s_p2p_m2s;
  
      pi_s_axi4s_aclk     : in  std_logic;
      pi_s_axi4s_areset_n : in  std_logic;
      pi_s_axi4s          : in  t_axi4s_p2p_m2s;
      po_s_axi4s          : out t_axi4s_p2p_s2m
    );
  end component lll;

end package bus_lll;

