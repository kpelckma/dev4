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
--! @date 2021-10-11
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Holger Kay <holger.kay@desy.de>
------------------------------------------------------------------------------
--! @brief
--! AXI4-Lite to II (IBUS) translation, part of DesyRdl
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------
library desyrdl;
use desyrdl.common.all;

------------------------------------------------------------------------------
--! @brief AXI4 to II translation
entity axi4l_to_ibus is
  generic (
    G_BUS_TIMEOUT : natural := 4095
  );
  port (
    -- AXI4 slave port
    pi_reset          : in  std_logic;
    pi_clock          : in  std_logic;
    pi_s_decoder    : in  t_axi4l_m2s;
    po_s_decoder    : out t_axi4l_s2m;
    -- IBUS interface
    po_m_ext        : out t_ibus_m2s;
    pi_m_ext        : in  t_ibus_s2m
  );
  -- preserve synthesis optimization which brakes handshaking functionality
  attribute KEEP_HIERARCHY : string;
  attribute KEEP_HIERARCHY of axi4l_to_ibus : entity is "yes";
end axi4l_to_ibus;

------------------------------------------------------------------------------
architecture rtl of axi4l_to_ibus is

  type t_state is (ST_IDLE,
                   ST_READ_DATA_ADDR,
                   ST_READ_DATA,
                   ST_READ_DATA_WAIT,
                   ST_WRITE_DATA_ADDR,
                   ST_WRITE_DATA,
                   ST_WRITE_DATA_WAIT,
                   ST_WRITE_RESP,
                   ST_READ_DATA_PUSH,
                   ST_WAIT_AFTER_TRN);
  signal sig_state   : t_state;
  signal sig_len     : std_logic_vector(7 downto 0);

  signal sig_rena    : std_logic;
  signal sig_wena    : std_logic;
  signal sig_addr    : std_logic_vector(31 downto 0) := (others => '0');

  signal sig_m2s     : t_axi4l_m2s := c_axi4l_m2s_default;
  signal sig_s2m     : t_axi4l_s2m := c_axi4l_s2m_default;

  signal wd_reset : std_logic;
  signal wd_cnt   : natural := 0;
  ---------------------------------------------------------------------------
begin

  -- unsed AXI4 Signals: SIG_M2S.AWSIZE  SIG_M2S.AWBURST  SIG_M2S.WSTRB
  -- unsed AXI4 Signals: SIG_M2S.ARSIZE  SIG_M2S.ARBURST  SIG_M2S.WLAST

  po_s_decoder   <= sig_s2m;
  sig_m2s          <= pi_s_decoder;
  ------------------------------------
  sig_s2m.rresp    <=  "00";

  sig_s2m.bresp    <=  "00";

  po_m_ext.clk    <=  pi_clock;

  po_m_ext.addr   <=  sig_addr;
  po_m_ext.rena   <=  sig_rena when rising_edge(pi_clock); -- delay one clock cycle to have 1 clock cycle delay after data on bus
  po_m_ext.wena   <=  sig_wena when rising_edge(pi_clock);

  prs_main_fsm: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if ( pi_reset = '1' or wd_reset = '1' ) then
        sig_state      <= ST_IDLE;
        sig_rena       <= '0';
        sig_wena       <= '0';
        sig_s2m.bvalid <= '0';
        po_m_ext.data  <= (others => '0');
      else
        sig_rena <= '0';
        sig_wena <= '0';

        case sig_state is
          -------------------------------------
          when ST_IDLE =>

            if (sig_m2s.arvalid = '1') then
              sig_state <= ST_READ_DATA_ADDR;

            elsif (sig_m2s.awvalid = '1') then
              sig_state <= ST_WRITE_DATA_ADDR;

            end if;

          -------------------------------------
          when ST_WRITE_DATA_ADDR =>

            if (sig_m2s.awvalid = '1') then
              sig_addr  <= sig_m2s.awaddr;
              sig_state <= ST_WRITE_DATA;
            end if;

          -------------------------------------
          when ST_WRITE_DATA =>

            if (sig_m2s.wvalid = '1') then
              po_m_ext.data <= sig_m2s.wdata(31 downto 0);
              sig_wena        <= '1';
              sig_state       <= ST_WRITE_DATA_WAIT;
            end if;

          -------------------------------------
          when ST_WRITE_DATA_WAIT =>

            if pi_m_ext.wack = '1' then
              sig_state      <= ST_WRITE_RESP;
              sig_s2m.bvalid <= '1';
            end if;

          -------------------------------------
          when st_write_resp =>
            if sig_m2s.bready = '1' then
              sig_s2m.bvalid <= '0';
              sig_state      <= ST_WAIT_AFTER_TRN;
            end if;

          -------------------------------------
          when ST_READ_DATA_ADDR =>

            if (sig_m2s.arvalid = '1') then
              sig_addr  <= sig_m2s.araddr;
              sig_state <= ST_READ_DATA;
            end if;

          -------------------------------------
          when ST_READ_DATA =>

            sig_rena  <= '1';
            sig_state <= ST_READ_DATA_WAIT;

          -------------------------------------
          when ST_READ_DATA_WAIT =>

            if pi_m_ext.rack = '1' then
              sig_s2m.rdata(31 downto 0) <= pi_m_ext.data;
              sig_state                  <= ST_READ_DATA_PUSH;
            end if;

          -------------------------------------
          when ST_READ_DATA_PUSH =>

            if sig_m2s.rready = '1' then
              -- if std_logic_vector(to_unsigned(sig_addr_cnt,8)) = sig_len then
              sig_state <= ST_WAIT_AFTER_TRN;
            -- else
            -- sig_addr_cnt <= sig_addr_cnt + 1 ;
            -- sig_addr   <= std_logic_vector(unsigned(sig_addr) + 4);
            -- sig_state  <= st_read_data ;
            -- end if;
            end if;

          -------------------------------------
          when ST_WAIT_AFTER_TRN =>
            -- if sig_wait_cnt >= 3 then
            sig_state <= ST_IDLE;
        -- else
        -- sig_wait_cnt <= sig_wait_cnt + 1;
        -- end if;
        end case;
      end if;
    end if;
  end process prs_main_fsm;

  proc_axi_hds : process(sig_state, sig_m2s)
  begin
    sig_s2m.arready <= '0';
    sig_s2m.awready <= '0';
    sig_s2m.wready  <= '0';
    sig_s2m.rvalid  <= '0';

    case sig_state is
      when st_read_data_addr =>
        sig_s2m.arready <= sig_m2s.arvalid;

      when st_write_data_addr =>
        sig_s2m.awready <= sig_m2s.awvalid;

      when st_write_data =>
        sig_s2m.wready <= sig_m2s.wvalid;

      when st_read_data_push =>
        sig_s2m.rvalid <= '1';

      when others =>
    end case;
  end process;

  prs_watchdog: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if ( pi_reset = '1' ) then
        wd_reset <= '1';
        wd_cnt   <= 0;
      else
        if sig_state = ST_IDLE then
          wd_reset <= '0';
          wd_cnt   <= 0;
        elsif wd_cnt >= G_BUS_TIMEOUT then
          wd_reset <= '1';
        else
          wd_cnt <= wd_cnt + 1;
        end if;
      end if;
    end if;
  end process prs_watchdog;

end rtl;
