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
--! @date 2019-05-11
--! @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! simple 2 registers buffer for AXI4 bus
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library desy;
use desy.common_axi.all;

entity axi4_buf is
  generic (
    G_DATA_WIDTH : natural := 1024;
    G_ID_WIDTH   : natural := 4
  );
  port (
    pi_areset_n : in std_logic;
    pi_aclk     : in std_logic;
    -- Master port
    po_m_axi4          : out t_axi4_m2s;
    pi_m_axi4          : in  t_axi4_s2m;
    po_m_axi4_areset_n : out std_logic;
    po_m_axi4_aclk     : out std_logic;
    -- Slave port
    pi_s_axi4          : in  t_axi4_m2s;
    po_s_axi4          : out t_axi4_s2m;
    po_s_axi4_areset_n : out std_logic;
    po_s_axi4_aclk     : out std_logic
  );
end entity axi4_buf;

architecture rtl of axi4_buf is

  signal aw_data_m : std_logic_vector(G_ID_WIDTH+45-1 downto 0);
  signal aw_data_s : std_logic_vector(G_ID_WIDTH+45-1 downto 0);
  signal ar_data_m : std_logic_vector(G_ID_WIDTH+45-1 downto 0);
  signal ar_data_s : std_logic_vector(G_ID_WIDTH+45-1 downto 0);
  signal r_data_m  : std_logic_vector(G_ID_WIDTH+G_DATA_WIDTH downto 0);
  signal r_data_s  : std_logic_vector(G_ID_WIDTH+G_DATA_WIDTH downto 0);
  signal w_data_m  : std_logic_vector(G_DATA_WIDTH+G_DATA_WIDTH/8 downto 0);
  signal w_data_s  : std_logic_vector(G_DATA_WIDTH+G_DATA_WIDTH/8 downto 0);
  signal b_data_m  : std_logic_vector(G_ID_WIDTH+1 downto 0);
  signal b_data_s  : std_logic_vector(G_ID_WIDTH+1 downto 0);
begin

  po_m_axi4_areset_n <= pi_areset_n;
  po_m_axi4_aclk     <= pi_aclk;
  po_s_axi4_areset_n <= pi_areset_n;
  po_s_axi4_aclk     <= pi_aclk;

  
  ------------------------------------------------------------------------------
  -- Write Address channel
  ------------------------------------------------------------------------------
  aw_data_s(G_ID_WIDTH+44 downto 45)<= pi_s_axi4.awid(G_ID_WIDTH-1 downto 0);
  aw_data_s(44 downto 42)           <= pi_s_axi4.awsize;
  aw_data_s(41 downto 40)           <= pi_s_axi4.awburst;
  aw_data_s(39 downto 32)           <= pi_s_axi4.awlen;
  aw_data_s(31 downto 0)            <= pi_s_axi4.awaddr;

  po_m_axi4.awid(G_ID_WIDTH-1 downto 0) <= aw_data_m(G_ID_WIDTH+44 downto 45);
  po_m_axi4.awsize                      <= aw_data_m(44 downto 42);
  po_m_axi4.awburst                     <= aw_data_m(41 downto 40);
  po_m_axi4.awlen                       <= aw_data_m(39 downto 32);
  po_m_axi4.awaddr                      <= aw_data_m(31 downto 0);

  ins_axi_buf_aw: entity desy.axi4_buf_sch
    generic map (
      G_DATA_WIDTH => G_ID_WIDTH+45
    )
    port map (
      pi_aclk    => pi_aclk ,

      po_m_ready => po_s_axi4.awready,
      pi_m_valid => pi_s_axi4.awvalid,
      pi_m_data  => aw_data_s ,

      pi_s_ready => pi_m_axi4.awready,
      po_s_valid => po_m_axi4.awvalid,
      po_s_data  => aw_data_m
    );


  ------------------------------------------------------------------------------
  -- Read Address channel
  ------------------------------------------------------------------------------
  ar_data_s(G_ID_WIDTH+44 downto 45)<= pi_s_axi4.arid(G_ID_WIDTH-1 downto 0);
  ar_data_s(44 downto 42)           <= pi_s_axi4.arsize;
  ar_data_s(41 downto 40)           <= pi_s_axi4.arburst;
  ar_data_s(39 downto 32)           <= pi_s_axi4.arlen;
  ar_data_s(31 downto 0)            <= pi_s_axi4.araddr;

  po_m_axi4.arid(G_ID_WIDTH-1 downto 0) <= ar_data_m(G_ID_WIDTH+44 downto 45);
  po_m_axi4.arsize                      <= ar_data_m(44 downto 42);
  po_m_axi4.arburst                     <= ar_data_m(41 downto 40);
  po_m_axi4.arlen                       <= ar_data_m(39 downto 32);
  po_m_axi4.araddr                      <= ar_data_m(31 downto 0);

  ins_axi_buf_ar: entity desy.axi4_buf_sch
    generic map (
      G_DATA_WIDTH => G_ID_WIDTH+45
    )
    port map (
      pi_aclk => pi_aclk,

      po_m_ready => po_s_axi4.ARREADY,
      pi_m_valid => pi_s_axi4.ARVALID,
      pi_m_data  => ar_data_s ,

      pi_s_ready => pi_m_axi4.ARREADY,
      po_s_valid => po_m_axi4.ARVALID,
      po_s_data  => ar_data_m
    );


  ------------------------------------------------------------------------------
  -- Write Data Channel
  ------------------------------------------------------------------------------
  w_data_s(G_DATA_WIDTH+G_DATA_WIDTH/8 downto G_DATA_WIDTH+1) <= pi_s_axi4.wstrb(G_DATA_WIDTH/8-1 downto 0);
  w_data_s(G_DATA_WIDTH downto 1)                             <= pi_s_axi4.wdata(G_DATA_WIDTH-1 downto 0);
  w_data_s(0)                                                 <= pi_s_axi4.wlast;

  po_m_axi4.wstrb(G_DATA_WIDTH/8-1 downto 0) <= w_data_m(G_DATA_WIDTH+G_DATA_WIDTH/8 downto G_DATA_WIDTH+1);
  po_m_axi4.wdata(G_DATA_WIDTH-1 downto 0)   <= w_data_m(G_DATA_WIDTH downto 1);
  po_m_axi4.wlast                            <= w_data_m(0);

  ins_axi_buf_w: entity desy.axi4_buf_sch
    generic map (
      G_DATA_WIDTH => G_DATA_WIDTH+G_DATA_WIDTH/8+1
    )
    port map (
      pi_aclk => pi_aclk,

      po_m_ready => po_s_axi4.WREADY,
      pi_m_valid => pi_s_axi4.WVALID,
      pi_m_data  => w_data_s ,

      pi_s_ready => pi_m_axi4.WREADY,
      po_s_valid => po_m_axi4.WVALID,
      po_s_data  => w_data_m
    );

  ------------------------------------------------------------------------------
  -- Write Response Data Channel
  ------------------------------------------------------------------------------
  b_data_m(G_ID_WIDTH+1 downto 2) <= pi_m_axi4.bid(G_ID_WIDTH-1 downto 0);
  b_data_m(1 downto 0)            <= pi_m_axi4.bresp;

  po_s_axi4.bid(G_ID_WIDTH-1 downto 0) <= b_data_s(G_ID_WIDTH+1 downto 2);
  po_s_axi4.bresp                      <= b_data_s(1 downto 0);

  ins_axi_buf_b: entity desy.axi4_buf_sch
    generic map (
      G_DATA_WIDTH => G_ID_WIDTH+2
    )
    port map (
      pi_aclk    => pi_aclk,

      po_m_ready => po_m_axi4.bready,
      pi_m_valid => pi_m_axi4.bvalid,
      pi_m_data  => b_data_m,

      pi_s_ready => pi_s_axi4.BREADY,
      po_s_valid => po_s_axi4.BVALID,
      po_s_data  => b_data_s
    );

  ------------------------------------------------------------------------------
  -- Read Data channel
  ------------------------------------------------------------------------------
  r_data_m(G_DATA_WIDTH+G_ID_WIDTH downto G_DATA_WIDTH+1) <= pi_m_axi4.rid(G_ID_WIDTH-1 downto 0);
  r_data_m(G_DATA_WIDTH downto 1)                         <= pi_m_axi4.rdata(G_DATA_WIDTH-1 downto 0);
  r_data_m(0)                                             <= pi_m_axi4.rlast;

  po_s_axi4.rid(G_ID_WIDTH-1 downto 0)     <= r_data_s(G_DATA_WIDTH+G_ID_WIDTH downto G_DATA_WIDTH+1);
  po_s_axi4.rdata(G_DATA_WIDTH-1 downto 0) <= r_data_s(G_DATA_WIDTH downto 1);
  po_s_axi4.rlast                          <= r_data_s(0);


  ins_axi_buf_r: entity work.axi4_buf_sch
    generic map (
      G_DATA_WIDTH => G_DATA_WIDTH+G_ID_WIDTH+1
    )
    port map (
      pi_aclk    => pi_aclk,

      po_m_ready => po_m_axi4.RREADY,
      pi_m_valid => pi_m_axi4.RVALID,
      pi_m_data  => r_data_m,

      pi_s_ready => pi_s_axi4.RREADY,
      po_s_valid => po_s_axi4.RVALID,
      po_s_data  => r_data_s
    );

end architecture rtl;
