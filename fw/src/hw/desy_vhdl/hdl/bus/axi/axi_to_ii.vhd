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
--! @date 2022-02-08
--! @author Holger Kay  <holger.kay@desy.de>
--! @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! AXI to II convertor
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library desy;
use desy.common_ii.all;
use desy.common_axi.all;

entity axi_to_ii is
  port (
    -- common axi and ibus clock and reset
    pi_areset_n : in  std_logic;
    pi_aclk     : in  std_logic;
    -- AXI4 subordinate port
    pi_s_axi4          : in  t_axi4_m2s;
    po_s_axi4          : out t_axi4_s2m;

    -- IBUS interface
    po_ibus : out t_ibus_o;
    pi_ibus : in  t_ibus_i
  );

  -- preserve synthesis optimization which brakes handshaking functionality
  attribute KEEP_HIERARCHY : string;
  attribute KEEP_HIERARCHY of axi_to_ii : entity is "YES";
end axi_to_ii;

architecture rtl of axi_to_ii is

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

  signal state : t_state;
  signal len   : std_logic_vector(7 downto 0);
  signal rena  : std_logic;
  signal wena  : std_logic;
  signal addr  : std_logic_vector(31 downto 0) := (others => '0');
  signal m2s   : t_axi4_m2s := C_AXI4_M2S_DEFAULT;
  signal s2m   : t_axi4_s2m := C_AXI4_S2M_DEFAULT;

begin

  -- unsed AXI4 Signals: m2s.AWSIZE  m2s.AWBURST  m2s.WSTRB
  -- unsed AXI4 Signals: m2s.ARSIZE  m2s.ARBURST  m2s.WLAST

  po_s_axi4 <= s2m;
  m2s         <= pi_s_axi4;
  ------------------------------------
  s2m.RRESP <= C_AXI4_RESP_OKAY;
  s2m.BRESP <= C_AXI4_RESP_OKAY;

  s2m.aclk    <= pi_aclk;
  po_ibus.clk <= pi_aclk;

  po_ibus.addr <=  addr;
  po_ibus.rena <=  rena when rising_edge(pi_aclk); -- delay one clock cycle to have 1 clock cycle delay after data on bus
  po_ibus.wena <=  wena when rising_edge(pi_aclk);

  process(pi_aclk)
  begin
      if rising_edge(pi_aclk) then
        if (pi_areset_n = '0') then
          state        <= ST_IDLE ;
          rena         <= '0';
          wena         <= '0';
          s2m.BVALID   <= '0';
        else
          rena         <= '0';
          wena         <= '0';

          case state is
            -------------------------------------
            when ST_IDLE =>

              if ( m2s.arvalid = '1' ) then
                  state <= ST_READ_DATA_ADDR;
              elsif ( m2s.awvalid  = '1' ) then
                  state   <= ST_WRITE_DATA_ADDR;
              end if;

            -------------------------------------
            when ST_WRITE_DATA_ADDR =>

              if ( m2s.awvalid  = '1' ) then
                s2m.bid <= m2s.awid;
                len     <= m2s.awlen ;
                addr    <= m2s.awaddr;
                state   <= ST_WRITE_DATA;
              end if;

            -------------------------------------
            when ST_WRITE_DATA =>

                if ( m2s.wvalid  = '1' ) then
                    po_ibus.data <= m2s.wdata(31 downto 0);
                    wena      <= '1';
                    state     <= ST_WRITE_DATA_WAIT;
                end if;

            -------------------------------------
            when ST_WRITE_DATA_WAIT =>

                if pi_ibus.wack = '1' then
                    state      <= ST_WRITE_RESP ;
                    s2m.bvalid <= '1';
                end if;

            -------------------------------------
            when ST_WRITE_RESP =>
                if pi_s_axi4.bready = '1' then
                  s2m.bvalid <= '0';
                  state      <= ST_WAIT_AFTER_TRN ;
                end if;

            -------------------------------------
            when ST_READ_DATA_ADDR =>

              if ( m2s.ARVALID = '1' ) then
                s2m.rid <= m2s.arid;
                len     <= m2s.arlen;
                addr    <= m2s.araddr;
                state   <= ST_READ_DATA;
              end if;

            -------------------------------------
            when ST_READ_DATA =>

                rena <= '1';
                state  <= ST_READ_DATA_WAIT ;

            -------------------------------------
            when ST_READ_DATA_WAIT =>

                if pi_ibus.rack = '1' then
                    s2m.rdata(31 downto 0)  <= pi_ibus.data;
                    state      <= ST_READ_DATA_PUSH ;
                end if;

            -------------------------------------
            when ST_READ_DATA_PUSH =>

                if m2s.rready = '1' then

                  state <= ST_WAIT_AFTER_TRN ;

                end if;

            -------------------------------------
            when ST_WAIT_AFTER_TRN =>

                state <= ST_IDLE ;

          end case ;
        end if;
      end if;
  end process;

  proc_axi_hds:process(state, m2s)
  begin

    s2m.arready  <= '0';
    s2m.awready  <= '0';
    s2m.wready   <= '0';
    s2m.rvalid   <= '0';
    s2m.rlast    <= '1';

    case state is
      when ST_READ_DATA_ADDR =>
          s2m.arready <= m2s.arvalid;

      when ST_WRITE_DATA_ADDR =>
          s2m.awready <= m2s.awvalid;

      when ST_WRITE_DATA =>
          s2m.wready <= m2s.wvalid;

      when ST_READ_DATA_PUSH =>
          s2m.rvalid <= '1';

      when others =>

    end case;
  end process;

end rtl;
