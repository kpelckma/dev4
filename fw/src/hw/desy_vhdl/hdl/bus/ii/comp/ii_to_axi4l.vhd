--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright Copyright 2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2022-01-05
--! @author Michael Buechler <michael.buechler@desy.de>
--------------------------------------------------------------------------------
--! @brief Bus translator from IBUS to AXI4-Lite
--!
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;
use desy.bus_ii.all;
use desy.common_axi.all;
 
-- old libraries
-- use work.pkg_axi; -- for DAQ
entity ii_to_axi4l is
  port (
    pi_clock     : in  std_logic;
    pi_reset     : in  std_logic;
    -- IBUS subordinate
    pi_ibus      : in  T_IBUS_O;
    po_ibus      : out T_IBUS_I;
    -- AXI4-Lite master port
    po_axi4l_m2s : out t_axi4l_m2s;
    pi_axi4l_s2m : in  t_axi4l_s2m
  );
end ii_to_axi4l;

architecture arch of ii_to_axi4l is
begin
  -- write address
  po_axi4l_m2s.awaddr <= pi_ibus.ADDR;
  po_axi4l_m2s.awprot <= (others => '0');
  po_axi4l_m2s.awvalid <= pi_ibus.WENA;
  -- write data
  po_axi4l_m2s.wdata <= pi_ibus.DATA;
  po_axi4l_m2s.wstrb <= (others => '1');
  po_axi4l_m2s.wvalid <= pi_ibus.WENA;
  -- write response (always ready)
  po_axi4l_m2s.bready <= '1';
  -- read address
  po_axi4l_m2s.araddr <= pi_ibus.ADDR;
  po_axi4l_m2s.arprot <= (others => '0');
  po_axi4l_m2s.arvalid <= pi_ibus.RENA;
  -- read data (always ready)
  po_axi4l_m2s.rready <= '1';

  -- IBUS
  -- ignore awready, wready, bresp, bvalid, arready, rresp
  po_ibus.CLK  <= pi_clock;
  po_ibus.DATA <= pi_axi4l_s2m.rdata;
  po_ibus.RACK <= pi_axi4l_s2m.rvalid;
  po_ibus.WACK <= pi_axi4l_s2m.bvalid;
end architecture;
