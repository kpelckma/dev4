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
--! @brief User logic interface to transmit data over LLL
--!
--! TODO: Write TX FSM from scratch and improve/verify AXI handshaking
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library desy;
use desy.common_types.all;
use desy.common_bsp_ifs.all;
use desy.common_bsp_ifs_cfg.all;
use desy.bus_lll.all;

entity lll_tx is
  generic (
    G_HEADER_TYPE     : natural := 0;
    G_CRC_ENA         : natural := 0;
    G_DATA_PER_PACKET : natural := 1;
    G_PACKET_CNT      : natural := 1
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic; 
    pi_start  : in  std_logic;
    pi_header : in  std_logic_vector(15 downto 0);
    pi_data   : in  t_32b_slv_vector(G_DATA_PER_PACKET-1 downto 0);
    pi_valid  : in  std_logic;
    po_ready  : out std_logic;
    po_busy   : out std_logic;
    
    pi_is_up_lll    : in  std_logic := '1';
    pi_m_axi4s_lll  : in  t_axi4s_p2p_s2m;
    po_m_axi4s_lll  : out t_axi4s_p2p_m2s
  );
end entity lll_tx;

architecture rtl of lll_tx is

  constant C_PAYLOAD  : unsigned(15 downto 0) := to_unsigned(G_DATA_PER_PACKET * G_PACKET_CNT, 16);

  type t_state is (ST_IDLE, ST_WAIT, ST_DATA, ST_CHECKSUM);

  signal state      : t_state;
  signal data_cnt   : unsigned(15 downto 0);
  signal packet_cnt : unsigned(natural(ceil(log2(real(G_DATA_PER_PACKET)))) downto 0);
  signal header     : std_logic_vector(31 downto 0);
  signal header_q   : std_logic_vector(31 downto 0);
  signal data       : std_logic_vector(31 downto 0);
  signal is_k       : std_logic_vector(3 downto 0);
  signal crc_reset  : std_logic;
  signal crc_ivalid : std_logic;
  signal crc_idata  : std_logic_vector(31 downto 0);
  signal crc_odata  : std_logic_vector(31 downto 0);

begin
  
  po_m_axi4s_lll.tdata  <= (C_AXI4S_P2P_DATA_WIDTH-1 downto 32 => '0') & data;
  po_m_axi4s_lll.tstrb  <= x"000F";
  po_m_axi4s_lll.tkeep  <= x"000F";
  po_m_axi4s_lll.tlast  <= '0';
  po_m_axi4s_lll.tid    <= (others => '0');
  po_m_axi4s_lll.tdest  <= (others => '0');
  po_m_axi4s_lll.tuser  <= (C_AXI4S_P2P_USER_WIDTH-1 downto 4 => '0') & is_k;

  gen_crc: if (G_CRC_ENA /= 0) generate
    ins_crc: entity desy.crc
      port map(           
        pi_clock  => pi_clock,
        pi_reset  => crc_reset,
        pi_init   => x"FFFFFFFF",
        pi_valid  => crc_ivalid, 
        pi_data   => crc_idata,
        po_crc    => crc_odata
      ); 
  end generate gen_crc;
  
  --! the synchronous process is used mainly to jump between states and to count the number of words/packets sent
  --! the control and handshaking signals are set in asynchronous, combinatorial equations below
  prs_tx: process(pi_clock)
  begin
    if rising_edge(pi_clock) then              
      if pi_reset = '1' then                        
        state <= ST_IDLE;            
        header_q <= (others => '0');
        data_cnt <= (others => '0');  --! reset the burst counter
        packet_cnt <= (others => '0');  --! reset the packet pointer
        crc_reset <= '1';
      else
        if pi_is_up_lll = '1' then
          case state is
            
            --! pi_start is used to signal that a new burst can be started
            when ST_IDLE =>
              data_cnt <= (others => '0'); --! reset the burst counter
              packet_cnt <= (others => '0'); --! reset the packet pointer
              crc_reset <= '0';
              if pi_start = '1' and pi_m_axi4s_lll.tready = '1' then  --! if the lll tx queue is ready to accept the header, quickly move to the data sending state
                state <= ST_DATA;
                header_q <= C_K_CHARS(G_HEADER_TYPE) & x"00" & pi_header;
              elsif pi_start = '1' and pi_m_axi4s_lll.tready = '0' then --! otherwise wait for the ready signal in the next state
                state <= ST_WAIT;
                header_q <= C_K_CHARS(G_HEADER_TYPE) & x"00" & pi_header;
              end if;
                
            --! wait for confirmation that the header has been accepted by the lll tx queue
            when ST_WAIT => 
              if pi_m_axi4s_lll.tready = '1' then
                state <= ST_DATA;
              end if;
              
            --! keep sending data until the entire burst is sent. the total number of words to be sent is C_PAYLOAD
            when ST_DATA =>
              if pi_m_axi4s_lll.tready = '1' and pi_valid = '1' then  --! a new packet is ready
                if (packet_cnt = to_unsigned(G_DATA_PER_PACKET-1, packet_cnt'length)) then  --! is this the final word in the current packet
                  if (to_unsigned(to_integer(data_cnt) + G_DATA_PER_PACKET, data_cnt'length) = C_PAYLOAD) then  --! is this the final packet in the burst?
                    if (G_CRC_ENA /= 0) then  --! do we need crc?
                      state <= ST_CHECKSUM; --! yes! finish calculation and send it
                    else
                      state <= ST_IDLE; --! no! wait for another burst
                    end if;
                  else  --! we need more packets in the current burst
                    packet_cnt <= (others => '0');  --! reset packet counter
                    data_cnt <= to_unsigned(to_integer(data_cnt) + G_DATA_PER_PACKET, data_cnt'length); --! increase burst counter
                  end if;
                else  --! there are more words in the current packet
                  packet_cnt <= packet_cnt + 1; --! increase packet counter
                end if;
              end if;           
          
            --! wait for the crc calculation to complete and send it after the data burst
            when ST_CHECKSUM =>
              if pi_m_axi4s_lll.tready = '1' then --! wait until handshake is complete
                state <= ST_IDLE;
                crc_reset <= '1';
              end if;

          end case;
        end if;
      end if; 
    end if;
  end process prs_tx;
  
  --! po_busy is only deasserted when the burst has not yet started
  po_busy <= '0' when pi_reset = '1' or (pi_start = '0' and state = ST_IDLE) else '1';
        
  --! po_ready is for handshaking at user interface
  po_ready <=
    '1' when  --! the data is considered to have been accepted by the transmitter only if:
      pi_reset = '0' and  --! 1. not on reset
      pi_is_up_lll = '1' and  --! 2. link is up
      packet_cnt = to_unsigned(G_DATA_PER_PACKET-1, packet_cnt'length) and  --! 3. the last word in a packet is provided to the tx queue
      pi_m_axi4s_lll.tready = '1' and --! 4. the tx queue is ready to accept the data
      state = ST_DATA --! 5. the state machine is in the ST_DATA state
    else '0';
  
  --! po_m_axi4s_lll.tvalid is for AXI handshaking
  po_m_axi4s_lll.tvalid <=
    '1' when  --! the data is considered to be ready for the tx queue if:
      pi_reset = '0' and  --! 1. not on reset
      pi_is_up_lll = '1' and (  --! 2. link is up AND either:
      (state = ST_IDLE and pi_start = '1') or --! a. the header is being sent
      state = ST_WAIT or  --! b. the header is being sent
      (state = ST_DATA and pi_valid = '1') or --! c. the data is being sent and the user data is valid
      state = ST_CHECKSUM)  --! d. the checksum is being sent
    else '0';

  --! the data that is provided to the tx queue
  data <=
    header when state = ST_IDLE or state = ST_WAIT else   
    crc_odata when state = ST_CHECKSUM else
    pi_data(to_integer(packet_cnt));
                      
  --! only the most significant byte can be the k character in the sent data and only when the header is being sent
  is_k <= "1000" when state = ST_IDLE or state = ST_WAIT else "0000";
                          
  --! the header is updated every time the start signal is asserted by the user
  header <= C_K_CHARS(G_HEADER_TYPE) & x"00" & pi_header when pi_start = '1' else header_q;
                          
  --! the crc data is always taken from the input data packet and indexed using the packet counter
  crc_idata <=
    (others => '0') when G_CRC_ENA = 0 else
    C_K_CHARS(G_HEADER_TYPE) & x"00" & pi_header when state = ST_IDLE and pi_start = '1' else
    pi_data(to_integer(packet_cnt));

  --! the crc valid signal is only asserted when the input data is provided by the user and the tx queue is able to accept the data. 
  --! this ensures that the crc valid signal is active for only one clock cycle per word
  crc_ivalid <=
    '1' when G_CRC_ENA = 1 and pi_is_up_lll = '1' and (
      (state = ST_IDLE and pi_start = '1') or
      (state = ST_DATA and pi_valid = '1' and pi_m_axi4s_lll.tready = '1'))
    else '0';

end architecture rtl;
