--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2014-2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2014-11-20 / 2019-08-16 / 2022-10-11
--! @author
--! Pawel Predki
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--! Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief User logic interface to receive data over LLL
--!
--! TODO: Write RX FSM from scratch and improve/verify AXI handshaking
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_types.all;
use desy.common_bsp_ifs.all;
use desy.bus_lll.all;

entity lll_rx is
  generic (
    G_HEADER_TYPE     : natural := 0;
    G_CRC_ENA         : natural := 0;
    G_DATA_PER_PACKET : natural := 1;
    G_PACKET_CNT      : natural := 1
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;
    po_start  : out std_logic;
    po_header : out std_logic_vector(15 downto 0);
    po_data   : out t_32b_slv_vector(G_DATA_PER_PACKET-1 downto 0);
    po_valid  : out std_logic;
    pi_ready  : in  std_logic;
    po_err    : out std_logic;
    po_end    : out std_logic;
    
    pi_is_up_lll    : in  std_logic := '1';
    pi_s_axi4s_lll  : in  t_axi4s_p2p_m2s;
    po_s_axi4s_lll  : out t_axi4s_p2p_s2m
  );
end entity lll_rx;

architecture rtl of lll_rx is

  signal state        : natural range 0 to 8;
  signal header_valid : std_logic;
  signal last         : std_logic;
  signal data         : t_32b_slv_vector(G_DATA_PER_PACKET+1 downto 1);
  signal crc_reset    : std_logic;
  signal crc_ivalid   : std_logic;
  signal crc_odata    : std_logic_vector(31 downto 0);
  signal crc_error    : std_logic;

begin

  prs_sync: process(pi_clock)
    variable v_data_cnt   : natural range 0 to G_DATA_PER_PACKET  := 0;
    variable v_packet_cnt : natural range 0 to G_PACKET_CNT       := 0;
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        v_data_cnt := 0;
        v_packet_cnt := 0;
        state <= 8; --! reset state
        po_header <= (others => '0');
        crc_reset <= '1';
      else
        po_start <= '0';
        if pi_s_axi4s_lll.tvalid = '1' and header_valid = '1' and pi_is_up_lll = '1' then
          v_data_cnt := 0;
          v_packet_cnt := 0;
          po_header <= pi_s_axi4s_lll.tdata(15 downto 0);
          po_start <= '1';
          last <= '0';
          if G_DATA_PER_PACKET = 1 then --! skip the data capture state
            if G_CRC_ENA = 1 then
              state <= 3;
            else
              state <= 2;
            end if;
          else
            state <= 1;
          end if;
        end if;
        case state is
          when 0 => --! wait for header
            v_data_cnt := 0;
            v_packet_cnt := 0;
            last <= '0';
            crc_reset <= '0';
          when 1 => --! capture data
            if pi_s_axi4s_lll.tvalid = '1' and header_valid = '0' then
              v_data_cnt := v_data_cnt + 1;
              data(v_data_cnt) <= pi_s_axi4s_lll.tdata(31 downto 0);
              if v_data_cnt >= G_DATA_PER_PACKET-1 then --! received all data except the last one
                if G_CRC_ENA = 1 then
                  state <= 3;
                else
                  state <= 2;
                end if;
              end if;
            end if;
          when 2 => --! wait for last data and propagate it directly to the ouput (no CRC case)
            v_data_cnt := 0;
            if pi_s_axi4s_lll.tvalid = '1' and pi_ready = '1' then  
              v_packet_cnt := v_packet_cnt + 1; --! received the entire packet
              if v_packet_cnt >= G_PACKET_CNT then  --! all done, wait for header
                  state <= 0; 
                  last <= '1';                  
              else  --! more packets to receive
                if G_DATA_PER_PACKET = 1 then --! skip the data capture state
                  state <= 2; --! keep state and directly propagate the single data to the output
                else
                  state <= 1; --! goto data capture state
                end if;
              end if ;
            end if;
          when 3 => --! wait last data and capture (CRC case)
            v_data_cnt := 0;
            if pi_s_axi4s_lll.tvalid = '1' then
              data(G_DATA_PER_PACKET) <= pi_s_axi4s_lll.tdata(31 downto 0);
              v_packet_cnt := v_packet_cnt + 1;
              if v_packet_cnt >= G_PACKET_CNT then  --! next is CRC
                  state <= 6 ;                  
                  last <= '1';                   
              else  --! more packets to receive
                  state <= 4 ;                  
              end if ;
            end if;
          when 4 => --! previous packet has been received, waiting user acknowledgement
            if pi_ready = '1' then  --! user acknowledged
              if pi_s_axi4s_lll.tvalid = '1' then --! more lll data is already waiting
                data(1) <= pi_s_axi4s_lll.tdata(31 downto 0);
                v_data_cnt := v_data_cnt + 1;
                if G_DATA_PER_PACKET = 1 then --! and it is received
                  v_packet_cnt := v_packet_cnt + 1; --! received the entire packet
                  if v_packet_cnt >= G_PACKET_CNT then  --! it was last packet so next is CRC
                    state <= 6;
                  else  --! more packets to receive
                    state <= 4;
                  end if;
                elsif G_DATA_PER_PACKET = 2 then  --! wait last data of this packet
                  state <= 3;
                else  --! more data to receive for this packet
                  state <= 1;
                end if;
              else
                if G_DATA_PER_PACKET = 1 then --! single data is expected in this packet
                  state <= 3;
                else  --! more data to receive for this packet
                  state <= 1;
                end if;
              end if;
            end if;
          when 6 => --! calculate CRC
            if pi_s_axi4s_lll.tvalid = '1' then
              crc_reset <= '1';
              if pi_ready = '1' then
                state <= 0;
              else
                state <= 7;
              end if;
            end if;
          when 7 => --! wait for user acknowledgement
            if pi_ready = '1' then
              state <= 0;
            end if;
          when others =>
            state <= 0;
        end case;
      end if;
    end if;
  end process prs_sync;

  prs_comb: process(state, pi_s_axi4s_lll.tvalid, header_valid, pi_ready, pi_s_axi4s_lll.tdata, data, last, crc_error)
  begin
    po_s_axi4s_lll.tready <= '0';     
    po_valid <= '0';
    po_data <= (others => (others => '0'));
    crc_ivalid <= '0';
    po_err <= '0';
    po_end <= '0';
    case state is
      when 0 => 
        po_s_axi4s_lll.tready <= '1';
        crc_ivalid <= pi_s_axi4s_lll.tvalid and header_valid;
      when 1 =>
        po_s_axi4s_lll.tready <= '1';
        crc_ivalid <= pi_s_axi4s_lll.tvalid and not header_valid;
      when 2 =>
        po_s_axi4s_lll.tready <= pi_ready;
        po_valid <= pi_s_axi4s_lll.tvalid and not header_valid;
        if G_DATA_PER_PACKET = 1 then
          po_data(0) <= pi_s_axi4s_lll.tdata(31 downto 0);
        else
          po_data <= pi_s_axi4s_lll.tdata(31 downto 0) & data(G_DATA_PER_PACKET-1 downto 1);
        end if;
        po_end <= last;
      when 3 =>
        po_s_axi4s_lll.tready <= '1';
        crc_ivalid <= pi_s_axi4s_lll.tvalid;
      when 4 =>
        po_s_axi4s_lll.tready <= pi_s_axi4s_lll.tvalid and pi_ready;
        po_valid <= '1';
        po_data <= data(G_DATA_PER_PACKET downto 1);
        crc_ivalid <= pi_s_axi4s_lll.tvalid and pi_ready;
      when 6 =>
        po_s_axi4s_lll.tready <= not pi_s_axi4s_lll.tvalid;
        po_valid <= pi_s_axi4s_lll.tvalid;
        po_data <= data(G_DATA_PER_PACKET downto 1);
        po_err <= crc_error and pi_s_axi4s_lll.tvalid;
        po_end <= pi_s_axi4s_lll.tvalid;
      when 7 =>
        po_valid <= '1';
        po_data <= data(G_DATA_PER_PACKET downto 1);
        po_end <= '1';
      when others =>
        null;
    end case;
  end process prs_comb;

  header_valid <= '1' when pi_s_axi4s_lll.tuser(3 downto 0) = "1000" and pi_s_axi4s_lll.tdata(31 downto 24) = C_K_CHARS(G_HEADER_TYPE) else '0';  
  crc_error <= '0' when (crc_odata xor pi_s_axi4s_lll.tdata(31 downto 0)) = x"00000000" else '1';

  gen_crc: if (G_CRC_ENA /= 0) generate
    ins_crc: entity desy.crc
      port map(
        pi_clock  => pi_clock,
        pi_reset  => crc_reset,
        pi_init   => x"FFFFFFFF",
        pi_valid  => crc_ivalid,
        pi_data   => pi_s_axi4s_lll.tdata(31 downto 0),
        po_crc    => crc_odata
      ); 
  end generate gen_crc;

end architecture rtl;
