-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
-------------------------------------------------------------------------------
--! @date 2021-11-01
--! @author  Katharina Schulz <katharina.schulz@desy.de>
-------------------------------------------------------------------------------
--! @description
--! Humidity Sensor with Temperature Sensor Texas Instruments 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity hdc1000 is
  generic (
    g_clk_freq    : natural                      := 50_000_000;
    g_i2c_addr    : std_logic_vector(7 downto 0) := x"FF"
    );
  port (
    pi_clock : in  std_logic;
    pi_reset : in  std_logic;
    -- Arbiter Interface
    po_req   : out std_logic;
    pi_grant : in  std_logic;
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
    pi_trg            : in std_logic;
    po_data_vld       : out std_logic;
    po_humidity       : out std_logic_vector(13 downto 0);
    po_temperature    : out std_logic_vector(13 downto 0);
    po_busy           : out  std_logic:='0'
    );
end entity hdc1000;
-------------------------------------------------------------------------------
architecture behave of hdc1000 is
  type t_fsm_state is ( ST_IDLE, 
                        ST_CONF, 
                        ST_START_TIMER,
                        ST_WAIT_TIMER,
                        ST_CMD_POINTER,
                        ST_CMD_READ,
                        ST_READ_HDC,
                        ST_PROVIDE
                        );
  
  signal fsm_state         : t_fsm_state;
  signal state_to_comeback : t_fsm_state;
  signal start_state       : t_fsm_state;

  -- Device Measurement Configuration
  --[15] Software reset 0 Normal Operation, this bit self clears bit
  --                    1 Software Reset
  --[14] Reserved 0 Reserved, must be 0
  --[13] Heater 0 Heater Disabled
  --            1 Heater Enabled
  --[12] Mode of 0 Temperature or Humidity is acquired. acquisition
  --             1 Temperature and Humidity are acquired in sequence, Temperature first.
  --
  --[11] Battery Status 0 Battery voltage > 2.8V (read only)
  --                    1 Battery voltage < 2.8V (read only)
  --[10] Temperature Measurement Resolution 0 14 bit 
  --                                        1 11 bit 
  --[9:8] Humidity  Measurement Resolution 00 14 bit 
  --                                       01 11 bit 
  --                                       10  8 bit
  --[7:0] Reserved 0 Reserved, must be 0
  
  constant C_CONFIG_REG  : std_logic_vector(7 downto 0)  := x"02";
  constant C_CONFIG_DATA : std_logic_vector(15 downto 0) := "0001" & "0000" & "00000000"; --b12=1, b10=0, b98=00
  constant C_READ_REG    : std_logic_vector(7 downto 0)  := x"00";
  signal reg_temperature : std_logic_vector(13 downto 0) := (others=> '0');
  signal reg_humidity    : std_logic_vector(13 downto 0) := (others=> '0');
  constant C_TIMER       : natural                       := 14 * g_clk_freq/1_000; -- wait 14 ms ( ~ RH 6.5 ms + TEMP 6.35 ms)
  signal timer           : natural                       := C_TIMER;
-------------------------------------------------------------------------------
  begin

    po_i2c_addr <= g_i2c_addr; -- Give the i2c address to controller

    prs_main_fsm :   process (pi_clock) is
      begin  
        if rising_edge(pi_clock) then
          if pi_reset = '1' then
            po_req            <= '0';
            po_i2c_str        <= '0';
            po_i2c_write_ena  <= '0';
            po_i2c_rep        <= '0';
            po_i2c_data_width <= (others => '0');
            po_i2c_data       <= (others => '0');
            po_data_vld       <= '0';
            po_humidity       <= (others => '0');
            po_temperature    <= (others => '0');
            po_busy           <= '0';
            fsm_state         <= ST_IDLE;
            start_state       <= ST_CONF;
            
    
          else
            case fsm_state is
              ------------------------------------------------------------
              when ST_IDLE =>
                po_req            <= '0';
                po_i2c_str        <= '0';
                po_i2c_write_ena  <= '0';
                po_i2c_rep        <= '0';
                po_i2c_data_width <= (others => '0');
                po_i2c_data       <= (others => '0');
                po_busy           <= '0';
                po_data_vld       <= '0';
                
                if pi_trg = '1' then
                  po_busy   <= '1';
                  fsm_state <= start_state;
    
                end if;

              ------------------------------------------------------------              
              when ST_CONF =>
                  po_req                  <= '1';
                  po_i2c_write_ena        <= '1';
                  po_i2c_rep              <= '0';
                  po_i2c_data(23 downto 0)  <= C_CONFIG_REG & C_CONFIG_DATA;
                  po_i2c_data_width       <= "10";
                  po_i2c_str              <= '1';

                if pi_grant = '1' then
                  fsm_state         <= ST_START_TIMER;
                  state_to_comeback <= ST_CMD_POINTER;
      
                end if;

              ------------------------------------------------------------
              when ST_START_TIMER =>
                po_i2c_str  <= '0';
                if pi_i2c_done = '1' then
                  po_req            <= '0';
                  fsm_state         <= ST_WAIT_TIMER;
                  timer             <= C_TIMER; 

                end if;
              
              ------------------------------------------------------------
              when ST_WAIT_TIMER =>
                timer <= timer - 1;
                if timer = 0 then
                  fsm_state <= state_to_comeback;
                  
                end if;

              ------------------------------------------------------------
              when ST_CMD_POINTER =>
                po_req                  <= '1';
                po_i2c_write_ena        <= '1';
                po_i2c_rep              <= '0';
                po_i2c_data(7 downto 0) <= C_READ_REG;
                po_i2c_data_width       <= "00";  -- 1 byte pointer address
                po_i2c_str              <= '1';
                  
                if pi_grant = '1' then
                  fsm_state         <= ST_START_TIMER;
                  state_to_comeback <= ST_CMD_READ;
                
                end if;

              ------------------------------------------------------------
              when ST_CMD_READ => 
                po_req            <= '1';
                po_i2c_rep        <= '0';
                po_i2c_str        <= '1';
                po_i2c_write_ena  <= '0';
                po_i2c_data_width <= "11"; --Read 4 Byte

                if pi_grant = '1' then
                  fsm_state       <= ST_READ_HDC;

                end if;

              ------------------------------------------------------------
              when ST_READ_HDC => 
                po_i2c_str      <= '0';
                if pi_i2c_done = '1' then
                  po_req          <= '0';
                  reg_temperature <= pi_i2c_data(31 downto 18);  -- Temperature first
                  reg_humidity    <= pi_i2c_data(15 downto 2);   -- Humidity last
                  fsm_state       <= ST_PROVIDE;
                  
                end if;

              ------------------------------------------------------------
              when ST_PROVIDE =>
                po_data_vld     <= '1';
                po_temperature  <= reg_temperature;
                po_humidity     <= reg_humidity;
                fsm_state       <= ST_IDLE;
                start_state     <= ST_CMD_POINTER;
              
              when others =>
                fsm_state       <= ST_IDLE;
                start_state     <= ST_CONF;
              
            end case;
    
          end if; --pi_reset
    
        end if; -- rising_edge
      
      end process;
  
end architecture behave;