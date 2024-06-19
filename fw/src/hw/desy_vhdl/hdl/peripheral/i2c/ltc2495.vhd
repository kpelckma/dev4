-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! @license   SPDX-License-Identifier: CERN-OHL-W-2.0
-------------------------------------------------------------------------------
--! @created 2021-10-11
--! @author  Katharina Schulz <katharina.schulz@desy.de>
--! @author  Lukasz Butkowski <lukasz.butkowski@desy.de>
-------------------------------------------------------------------------------
--! @description
--! 16 bit 8-16 Channel ADC over I2c Interface
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library desy;
use desy.common_types.all;

entity ltc2495 is
  generic (
    g_i2c_addr  : std_logic_vector(7 downto 0) := "00110100";
    g_clk_freq  : natural := 125_000_000 
  );
  port (
    pi_clock    : in  std_logic;
    pi_reset    : in  std_logic;
    -- Arbiter Interface
    po_req      : out std_logic;
    pi_grant    : in  std_logic;
    -- i2c_controler interface
    pi_i2c_data       : in  std_logic_vector(31 downto 0);
    pi_i2c_done       : in  std_logic;
    po_i2c_str        : out std_logic;
    po_i2c_write_ena  : out std_logic;
    po_i2c_rep        : out std_logic;
    po_i2c_data_width : out std_logic_vector(1 downto 0);
    po_i2c_data       : out std_logic_vector(31 downto 0);
    po_i2c_addr       : out std_logic_vector(7 downto 0);
  -- User interface
    pi_trg            : in  std_logic;
    po_busy           : out std_logic;
    po_data_vld       : out std_logic;
    po_data           : out t_17b_slv_vector(16 downto 0);
    pi_ch_ena         : in  std_logic_vector(16 downto 0);
    pi_ch_cfg_sgl_ena : in std_logic_vector(15 downto 0);
    pi_ch_cfg_diff_ena: in std_logic_vector(15 downto 0);
    pi_ch_cfg_reject  : in t_2b_slv_vector(16 downto 0);
    pi_ch_cfg_speed   : in std_logic_vector(15 downto 0);
    pi_ch_cfg_gain    : in t_3b_slv_vector(15 downto 0)
  );
end entity ltc2495;

--------------------------------------------------------------------------------
architecture behave of ltc2495 is

  type t_fsm_state is (ST_IDLE,
                       ST_GET_CFG,
                       ST_SET_CFG,
                       ST_WRITE_CFG,
                       ST_WAIT_CFG_DONE,
                       ST_START_TIMER,
                       ST_READ,
                       ST_PARSE_RDATA,
                       ST_PROVIDE
                       );

  signal fsm_state : t_fsm_state;
  signal state_to_comeback : t_fsm_state;
  
  --MUX ADDRESS ODD_A2_A1_A0
  constant C_CH_ADDR : t_4b_slv_vector(16 downto 0):=
  (  0 => "0000",
     1 => "1000",
     2 => "0001",
     3 => "1001",
     4 => "0010",
     5 => "1010",
     6 => "0011",
     7 => "1011",
     8 => "0100",
     9 => "1100",
    10 => "0101",
    11 => "1101",
    12 => "0110",
    13 => "1110",
    14 => "0111",
    15 => "1111",
    16 => "0000");

  signal ch_idx       : natural range 0 to 16 := 0;
  signal ch_last      : std_logic    :='0';

  signal ch_ena       : std_logic_vector(16 downto 0):= (others =>'0');
  signal temp_ena     : std_logic := '0';
  signal sgl_bit      : std_logic := '0';
  signal cfg_sgl_ena  : std_logic_vector(15 downto 0) := (others => '0');
  signal cfg_diff_ena : std_logic_vector(15 downto 0) := (others => '0');
  signal cfg_reject   : t_2b_slv_vector(16 downto 0) := (others => (others => '0'));
  signal cfg_speed    : std_logic_vector(15 downto 0) := (others => '0');
  signal cfg_gain     : t_3b_slv_vector(15 downto 0) := (others => (others => '0'));

  signal cfg_cmd      : std_logic_vector(15 downto 0):= (others =>'0');
  signal rdata        : std_logic_vector(16 downto 0):= (others =>'0');
  signal rdata_sts    : std_logic_vector(1 downto 0):= (others =>'0');

  constant C_TIMER_SP1 : natural := 170 * g_clk_freq/1_000 ; --170 ms
  constant C_TIMER_SP2 : natural := 90 * g_clk_freq/1_000 ; --90 ms
  signal timer         : natural ;

-- =============================================================================
begin

  po_i2c_addr <= g_i2c_addr; 
  
  prs_main_fsm : process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        po_i2c_data         <= (others => '0');
        po_i2c_data_width   <= (others => '0');
        po_i2c_write_ena    <= '0';
        po_i2c_str          <= '0';
        po_req              <= '0';

        po_data_vld         <= '0';
        po_busy             <= '0';
        po_data             <= (others => (others => '0'));
        
        fsm_state           <= ST_IDLE;

      else

        case fsm_state is
          ------------------------------------------------------------
          when ST_IDLE =>
            po_data_vld       <= '0';
            po_busy           <= '0';

            po_i2c_data       <= (others => '0');
            po_i2c_data_width <= (others => '0');
            po_i2c_write_ena  <= '0';
            po_i2c_str        <= '0';

            ch_ena        <= pi_ch_ena;
            cfg_sgl_ena   <= pi_ch_cfg_sgl_ena;
            cfg_diff_ena  <= pi_ch_cfg_diff_ena;
            cfg_reject    <= pi_ch_cfg_reject;
            cfg_speed     <= pi_ch_cfg_speed;
            cfg_gain      <= pi_ch_cfg_gain;

            if pi_trg = '1' then
              fsm_state <= ST_GET_CFG;
              po_busy   <= '1';

            end if;

          ------------------------------------------------------------
          when ST_GET_CFG =>
            -- SGL bit
            if cfg_sgl_ena(ch_idx) = '1' then
              sgl_bit <= '1';

            elsif cfg_diff_ena(ch_idx) ='1' then
              sgl_bit <= '0';

            end if; 
            
            --IM bit
            if ch_idx = 16 and pi_ch_ena(16) ='1' then
              temp_ena  <= '1';

            else
              temp_ena  <= '0';
            
            end if;

            fsm_state <= ST_SET_CFG;

          ------------------------------------------------------------
          when ST_SET_CFG =>
            cfg_cmd <=
            --1st Byte Preamble + Single/Differential + MUX Address
              "101" & sgl_bit & C_CH_ADDR(ch_idx) &
            --2nd Byte Converter Configuration
              '1' & temp_ena &
            cfg_reject(ch_idx) &
            cfg_speed(ch_idx) &
            cfg_gain(ch_idx);

            --Speed bit sets different conversion times
            if cfg_speed(ch_idx) ='1' then -- SPD 2x
              timer <= C_TIMER_SP2;

            else
              timer <= C_TIMER_SP1;

            end if;

            fsm_state <= ST_WRITE_CFG;

          ------------------------------------------------------------
          when ST_WRITE_CFG => -- Send configuration
            
            po_i2c_write_ena         <= '1';
            po_i2c_data_width        <= "01";  -- 2 bytes
            po_i2c_data(15 downto 0) <= cfg_cmd;
            po_i2c_str               <= '1';
            po_i2c_rep               <= '1';
            po_req                   <= '1';

            if pi_grant = '1' then
              fsm_state               <= ST_WAIT_CFG_DONE;

            end if;

          ------------------------------------------------------------
          when ST_WAIT_CFG_DONE =>
            po_i2c_str      <= '0';
            if pi_i2c_done = '1' then
              fsm_state     <= ST_READ;

            end if;

          ------------------------------------------------------------
          when ST_START_TIMER =>
            timer <= timer - 1;
            if timer = 1 then
              fsm_state <= state_to_comeback;
              
            end if;

          ------------------------------------------------------------
          when ST_READ =>
            po_i2c_rep        <= '0';
            po_i2c_str        <= '1';
            po_i2c_write_ena  <= '0';
            po_i2c_data_width <= "10";
            if pi_grant = '1' then
              fsm_state       <= ST_PARSE_RDATA;

            end if;

          ------------------------------------------------------------
          when ST_PARSE_RDATA =>
            po_i2c_str <= '0';
            if pi_i2c_done = '1' then
              po_req    <= '0'; 

              if pi_i2c_data(23) = '1' and pi_i2c_data(22) = '1' then -- Vin > FS
                rdata(16)           <= '0';
                rdata(15 downto 0)  <= (others =>'1');

              elsif  pi_i2c_data(23) = '0' and pi_i2c_data(22) = '0' then -- Vin < Fs
                rdata(16)           <= '1';
                rdata(15 downto 0)  <= (others =>'0');

              else
                rdata <= pi_i2c_data(22 downto 6);

              end if;

              rdata_sts <= pi_i2c_data(23 downto 22);
              fsm_state <= ST_PROVIDE;

            end if;

          ------------------------------------------------------------
          when ST_PROVIDE =>
            fsm_state <= ST_START_TIMER;

            if ch_last = '1' then
              po_data_vld   <= '1';
              state_to_comeback <= ST_IDLE;
              po_data(ch_idx)   <= rdata;
              ch_idx            <= 0;
              ch_last           <= '0';

            else
              
              if ch_idx = 16 then -- read channel 15 once more for temperature
                ch_last <= '1';
                state_to_comeback <= ST_SET_CFG;
              
              else
                ch_idx <= ch_idx + 1;
                state_to_comeback <= ST_GET_CFG;
                
              end if; 
                
              if ch_idx > 0 then
                po_data(ch_idx-1) <= rdata;
              end if;

            end if; --ch_last

          ------------------------------------------------------------
          when others => 
            fsm_state <= ST_IDLE;

        end case;
      end if;
    end if;
  end process;

end architecture behave;