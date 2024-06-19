--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2019-2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2019-08-16 / 2022-09-09
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief IBUS transaction inserter into LLL
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_types.all;
use desy.common_bsp_ifs.all;

library desyrdl;
use desyrdl.common.all; --! TODO: use desy.common_ibus

entity ibus_into_lll is
  generic (
    G_IBUS_W_WAIT : natural := 63;
    G_IBUS_R_WAIT : natural := 2047
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    --! IBUS subordinate interface
    pi_s_ibus   : in  t_ibus_m2s;
    po_s_ibus   : out t_ibus_s2m;
    po_ibus_err : out std_logic;

    --! LLL interface (excludes IBUS transaction - away from MGT)
    po_is_up_lll    : out std_logic;
    pi_m_axi4s_lll  : in  t_axi4s_p2p_s2m;
    po_m_axi4s_lll  : out t_axi4s_p2p_m2s;
    pi_s_axi4s_lll  : in  t_axi4s_p2p_m2s;
    po_s_axi4s_lll  : out t_axi4s_p2p_s2m;

    --! LLL interface (includes IBUS transaction - closer to MGT)
    pi_is_up_lll        : in  std_logic := '1';
    pi_m_axi4s_lll_ibus : in  t_axi4s_p2p_s2m;
    po_m_axi4s_lll_ibus : out t_axi4s_p2p_m2s;
    pi_s_axi4s_lll_ibus : in  t_axi4s_p2p_m2s;
    po_s_axi4s_lll_ibus : out t_axi4s_p2p_s2m
  );
end entity ibus_into_lll;

architecture rtl of ibus_into_lll is

  signal req    : std_logic_vector(1 downto 0);
  signal grant  : std_logic_vector(1 downto 0);

  signal we   : std_logic;
  signal re   : std_logic;
  signal wack : std_logic;
  signal rack : std_logic;

  signal header : std_logic;
  signal headet : std_logic;
  signal packet : std_logic;

  signal rx_data  : t_32b_slv_vector(0 downto 0);
  signal rx_err   : std_logic ;
  signal rx_end   : std_logic ;

  signal tx_start   : std_logic;
  signal tx_header  : std_logic_vector(15 downto 0) := (others => '0');
  signal tx_data    : t_32b_slv_vector(1 downto 0);
  signal tx_busy    : std_logic;

  signal m_axi4s_m2s  : t_axi4s_p2p_m2s;
  signal m_axi4s_s2m  : t_axi4s_p2p_s2m;
  signal s_axi4s_m2s  : t_axi4s_p2p_m2s;
  signal s_axi4s_s2m  : t_axi4s_p2p_s2m;

  signal state    : natural range 0 to 2  := 0;
  signal timeout  : natural               := 0;

begin

  po_is_up_lll <= pi_is_up_lll;

  po_ibus_err <= rx_err;

  po_s_ibus.clk   <= pi_clock;
  po_s_ibus.wack  <= wack;
  po_s_ibus.rack  <= rack;

  prs_ibus : process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        we       <= '0';
        re       <= '0';
        wack     <= '0';
        rack     <= '0';
        tx_start <= '0';
        state    <= 0;
      else
        we       <= pi_s_ibus.wena;
        re       <= pi_s_ibus.rena;
        wack     <= '0';
        rack     <= '0';
        tx_start <= '0';
        case state is
          when 0 =>                     --! idle
            if (pi_s_ibus.rena = '1' and re = '0') then
              tx_header  <= x"0000";
              tx_start   <= '1';
              state      <= 1;
            elsif (pi_s_ibus.wena = '1' and we = '0') then
              tx_header  <= x"0001";
              tx_start   <= '1';
              state      <= 2;
            end if;
            tx_data(0) <= pi_s_ibus.addr;
            tx_data(1) <= pi_s_ibus.data;
            timeout    <= 0;
          when 1 =>                     --! read
            if rx_end = '1' and rx_err = '0' then
              po_s_ibus.data <= rx_data(0);
              rack           <= '1';
              state          <= 0;
            elsif timeout >= G_IBUS_R_WAIT then      --! read timeout after G_IBUS_R_WAIT
              po_s_ibus.data <= (others => '0');
              rack           <= '1';
              state          <= 0;
            end if;
            timeout <= timeout + 1;
          when 2 =>                     --! write
            if timeout >= G_IBUS_W_WAIT then         --! write timeout after G_IBUS_WR_WAIT
              wack  <= '1';
              state <= 0;
            else
              timeout <= timeout + 1;
            end if;
          when others =>
            state <= 0;
        end case;
      end if;
    end if;
  end process prs_ibus;

  ins_ibus_lll_tx: entity desy.lll_tx
    generic map (
      G_HEADER_TYPE     => 9,
      G_CRC_ENA         => 1,
      G_DATA_PER_PACKET => 2,
      G_PACKET_CNT      => 1
    )
    port map (
      pi_clock  => pi_clock,
      pi_reset  => pi_reset,
      pi_start  => tx_start,
      pi_header => tx_header,
      pi_data   => tx_data,
      pi_valid  => '1',
      po_ready  => open,
      po_busy   => tx_busy,

      pi_is_up_lll    => pi_is_up_lll,
      pi_m_axi4s_lll  => s_axi4s_s2m,
      po_m_axi4s_lll  => s_axi4s_m2s
    );

  ins_ibus_lll_rx: entity desy.lll_rx
    generic map (
      G_HEADER_TYPE     => 9,
      G_CRC_ENA         => 1,
      G_DATA_PER_PACKET => 1,
      G_PACKET_CNT      => 1
    )
    port map (
      pi_clock  => pi_clock,
      pi_reset  => pi_reset,
      po_start  => open,
      po_header => open,
      po_data   => rx_data,
      po_valid  => open,
      pi_ready  => '1',
      po_err    => rx_err,
      po_end    => rx_end,

      pi_is_up_lll    => pi_is_up_lll,
      pi_s_axi4s_lll  => m_axi4s_m2s,
      po_s_axi4s_lll  => m_axi4s_s2m
    );

  --! ibus header detection
  header <= '1' when (m_axi4s_m2s.tuser(3 downto 0) = "1000") and (m_axi4s_m2s.tdata(31 downto 24) = x"FE") else '0';

  --! register detected ibus header
  prs_headet: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if rx_end = '1' then
        headet <= '0';
      elsif header = '1' then
        headet <= '1';
      end if;
    end if;
  end process prs_headet;

  --! ibus packet indicator
  packet <= header or headet;

  -- arbiter for lll_ibus <= lll or ibus
  ins_arbiter: entity desy.arbiter_priority_synced
    generic map (
      G_REQUESTER => 2
    )
    port map (
      pi_clock  => pi_clock,
      pi_reset  => pi_reset,
      pi_req    => req,
      po_grant  => grant
    );

  --! arbiter request definition
  req(0) <= pi_s_axi4s_lll.tvalid;
  req(1) <= s_axi4s_m2s.tvalid or tx_busy;

  --! arbitration by arbiter grant
  --! lll_ibus <= lll or ibus (dataflow and backpressure)
  prs_grant: process(grant, s_axi4s_m2s, pi_s_axi4s_lll, pi_m_axi4s_lll_ibus)
  begin
    case grant is
      when "01" =>
        po_m_axi4s_lll_ibus.tvalid  <= pi_s_axi4s_lll.tvalid;
        po_m_axi4s_lll_ibus.tdata   <= pi_s_axi4s_lll.tdata;
        po_m_axi4s_lll_ibus.tstrb   <= pi_s_axi4s_lll.tstrb;
        po_m_axi4s_lll_ibus.tkeep   <= pi_s_axi4s_lll.tkeep;
        po_m_axi4s_lll_ibus.tlast   <= pi_s_axi4s_lll.tlast;
        po_m_axi4s_lll_ibus.tid     <= pi_s_axi4s_lll.tid;
        po_m_axi4s_lll_ibus.tdest   <= pi_s_axi4s_lll.tdest;
        po_m_axi4s_lll_ibus.tuser   <= pi_s_axi4s_lll.tuser;

        po_s_axi4s_lll.tready <= pi_m_axi4s_lll_ibus.tready;

        s_axi4s_s2m.tready <= '0';
      when "10" =>
        po_m_axi4s_lll_ibus.tvalid  <= s_axi4s_m2s.tvalid;
        po_m_axi4s_lll_ibus.tdata   <= s_axi4s_m2s.tdata;
        po_m_axi4s_lll_ibus.tstrb   <= s_axi4s_m2s.tstrb;
        po_m_axi4s_lll_ibus.tkeep   <= s_axi4s_m2s.tkeep;
        po_m_axi4s_lll_ibus.tlast   <= s_axi4s_m2s.tlast;
        po_m_axi4s_lll_ibus.tid     <= s_axi4s_m2s.tid;
        po_m_axi4s_lll_ibus.tdest   <= s_axi4s_m2s.tdest;
        po_m_axi4s_lll_ibus.tuser   <= s_axi4s_m2s.tuser;

        po_s_axi4s_lll.tready <= '0';

        s_axi4s_s2m.tready <= pi_m_axi4s_lll_ibus.tready;
      when others =>
        po_m_axi4s_lll_ibus.tvalid  <= '0';
        po_m_axi4s_lll_ibus.tdata   <= (others => '0');
        po_m_axi4s_lll_ibus.tstrb   <= (others => '0');
        po_m_axi4s_lll_ibus.tkeep   <= (others => '0');
        po_m_axi4s_lll_ibus.tlast   <= '0';
        po_m_axi4s_lll_ibus.tid     <= (others => '0');
        po_m_axi4s_lll_ibus.tdest   <= (others => '0');
        po_m_axi4s_lll_ibus.tuser   <= (others => '0');

        po_s_axi4s_lll.tready <= '0';

        s_axi4s_s2m.tready <= '0';
    end case;
  end process prs_grant;

  --! lll <= lll_ibus (dataflow)
  m_axi4s_m2s.tvalid  <= pi_s_axi4s_lll_ibus.tvalid;
  m_axi4s_m2s.tdata   <= pi_s_axi4s_lll_ibus.tdata;
  m_axi4s_m2s.tstrb   <= pi_s_axi4s_lll_ibus.tstrb;
  m_axi4s_m2s.tkeep   <= pi_s_axi4s_lll_ibus.tkeep;
  m_axi4s_m2s.tlast   <= pi_s_axi4s_lll_ibus.tlast;
  m_axi4s_m2s.tid     <= pi_s_axi4s_lll_ibus.tid;
  m_axi4s_m2s.tdest   <= pi_s_axi4s_lll_ibus.tdest;
  m_axi4s_m2s.tuser   <= pi_s_axi4s_lll_ibus.tuser;

  --! ibus <= lll_ibus (dataflow)
  po_m_axi4s_lll.tvalid <= pi_s_axi4s_lll_ibus.tvalid;
  po_m_axi4s_lll.tdata  <= pi_s_axi4s_lll_ibus.tdata;
  po_m_axi4s_lll.tstrb  <= pi_s_axi4s_lll_ibus.tstrb;
  po_m_axi4s_lll.tkeep  <= pi_s_axi4s_lll_ibus.tkeep;
  po_m_axi4s_lll.tlast  <= pi_s_axi4s_lll_ibus.tlast;
  po_m_axi4s_lll.tid    <= pi_s_axi4s_lll_ibus.tid;
  po_m_axi4s_lll.tdest  <= pi_s_axi4s_lll_ibus.tdest;
  po_m_axi4s_lll.tuser  <= pi_s_axi4s_lll_ibus.tuser;

  --! lll and ibus <= lll_ibus (backpressure)
  po_s_axi4s_lll_ibus.tready <= m_axi4s_s2m.tready when packet = '1' else (pi_m_axi4s_lll.tready or not(pi_is_up_lll));

end architecture rtl;
