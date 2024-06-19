--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2013 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2022-11-21
--! @author
--! Bin Yang         <bin.yang@desy.de>
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--! Katharina Schulz <katharina.schulz@desy.de>
--------------------------------------------------------------------------------
--! @brief II-Bus synchronizer
---------------------------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.bus_ii.all;
--------------------------------------------------------------------------------
entity ii_sync is
  port (
    -- manager clock domain
    pi_m_ibus        : in  t_ibus_o;
    po_m_ibus        : out t_ibus_i;
    -- subordinate clock domain
    pi_s_ibus        : in  t_ibus_i;
    po_s_ibus        : out t_ibus_o
  );
end ii_sync;
--------------------------------------------------------------------------------
architecture behave of ii_sync is

  signal sig_ibus_addr      : std_logic_vector(31 downto 0) := (others => '0');
  signal sig_ibus_rdata     : std_logic_vector(31 downto 0) := (others => '0');
  signal sig_ibus_wdata     : std_logic_vector(31 downto 0) := (others => '0');

  signal sig_ibus_rena      : std_logic                     := '0';
  signal sig_ibus_wena      : std_logic                     := '0';
  signal sig_ibus_rena_sync : std_logic_vector(2 downto 0)  := (others => '0');
  signal sig_ibus_wena_sync : std_logic_vector(2 downto 0)  := (others => '0');

  signal sig_ibus_rack      : std_logic                     := '0';
  signal sig_ibus_wack      : std_logic                     := '0';
  signal sig_ibus_rack_sync : std_logic_vector(2 downto 0)  := (others => '0');
  signal sig_ibus_wack_sync : std_logic_vector(2 downto 0)  := (others => '0');

  attribute shreg_extract : string;
  attribute shreg_extract of sig_ibus_rena_sync : signal is "no";
  attribute shreg_extract of sig_ibus_wena_sync : signal is "no";
  attribute shreg_extract of sig_ibus_rack_sync : signal is "no";
  attribute shreg_extract of sig_ibus_wack_sync : signal is "no";

  attribute async_reg : string;
  attribute async_reg of sig_ibus_rena_sync : signal is "true";
  attribute async_reg of sig_ibus_wena_sync : signal is "true";
  attribute async_reg of sig_ibus_rack_sync : signal is "true";
  attribute async_reg of sig_ibus_wack_sync : signal is "true";
  attribute async_reg of sig_ibus_addr      : signal is "true";
  attribute async_reg of sig_ibus_wdata     : signal is "true";
  attribute async_reg of sig_ibus_rdata     : signal is "true";

begin
  -- Clock --
  po_m_ibus.CLK <= pi_m_ibus.CLK;
  po_s_ibus.CLK <= pi_s_ibus.CLK;
  -- manager to subordinate
  prs_m2s: process(pi_s_ibus.CLK)  -- subordinate clock domain
  begin
    if rising_edge(pi_s_ibus.CLK) then
      sig_ibus_addr   <= pi_m_ibus.ADDR;
      po_s_ibus.ADDR <= sig_ibus_addr;
      sig_ibus_wdata  <= pi_m_ibus.DATA;
      po_s_ibus.DATA <= sig_ibus_wdata;
    end if;
  end process;
  -- subordinate to manager
  prs_s2m: process(pi_m_ibus.CLK)
  begin
    if rising_edge(pi_m_ibus.CLK) then
      sig_ibus_rdata <= pi_s_ibus.DATA;
      po_m_ibus.DATA <= sig_ibus_rdata;
    end if;
  end process;
-------------------------------------------------------------------------------
-- Read handshaking --
  prs_sync_rena: process(pi_m_ibus.CLK)  -- mananger clock domain
  begin
    if rising_edge(pi_m_ibus.CLK) then
      sig_ibus_rack_sync <= sig_ibus_rack_sync(1 downto 0) & sig_ibus_rack;

      if pi_m_ibus.RENA = '1' then
        sig_ibus_rena   <= '1';
      elsif sig_ibus_rack_sync(1) = '1' then
        sig_ibus_rena   <= '0';
      end if;

      po_m_ibus.RACK <= sig_ibus_rack_sync(1) and not sig_ibus_rack_sync(2);
    end if;
  end process;

  prs_sync_rack: process(pi_s_ibus.CLK)  -- slave clock domain
  begin
    if rising_edge(pi_s_ibus.CLK) then
      sig_ibus_rena_sync <= sig_ibus_rena_sync(1 downto 0) & sig_ibus_rena;

      if sig_ibus_rena_sync(1) = '0' then
        sig_ibus_rack <= '0';
      elsif pi_s_ibus.RACK = '1' then
        sig_ibus_rack  <= '1';
      end if;

      po_s_ibus.RENA <= sig_ibus_rena_sync(1) and not sig_ibus_rena_sync(2);
    end if;
  end process;

------------------------------------------------------------------------------
-- WRITE handshaking --
  prs_sync_wena: process(pi_m_ibus.CLK)  -- manager clock domain
  begin
    if rising_edge(pi_m_ibus.CLK) then
      sig_ibus_wack_sync <= sig_ibus_wack_sync(1 downto 0) & sig_ibus_wack;

      if pi_m_ibus.WENA = '1' then
         sig_ibus_wena  <= '1';
      elsif sig_ibus_wack_sync(1) = '1' then
        sig_ibus_wena  <= '0';
      end if;

      po_m_ibus.WACK <= sig_ibus_wack_sync(1) and not sig_ibus_wack_sync(2);
    end if;
  end process;

  prs_sync_wack: process(pi_s_ibus.CLK)  -- subordinate clock domain
  begin
    if rising_edge(pi_s_ibus.CLK) then
      sig_ibus_wena_sync <= sig_ibus_wena_sync(1 downto 0) & sig_ibus_wena;

      if sig_ibus_wena_sync(1) = '0' then
        sig_ibus_wack   <= '0';
      elsif pi_s_ibus.WACK = '1' then
        sig_ibus_wack   <= '1';
      end if;

      po_s_ibus.WENA <= sig_ibus_wena_sync(1) and not sig_ibus_wena_sync(2);
    end if;
  end process;

end behave;
