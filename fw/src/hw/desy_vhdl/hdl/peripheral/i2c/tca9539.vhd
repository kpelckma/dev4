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
--! @created 2022-01-18
--! @author  Katharina Schulz <katharina.schulz@desy.de>
-------------------------------------------------------------------------------
--! @description
--! Texas Instruments GPIO Expander 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity tca9539 is
  generic(  
    g_clk_freq  : natural                       := 125_000_000; -- in Hz
    g_i2c_addr  : std_logic_vector(7 downto 0)  := '0'&"1110101"
    );
  port (
    pi_clock      : in  std_logic;
    pi_reset      : in  std_logic;
    -- Arbiter interface
    po_req        : out std_logic;
    pi_grant      : in  std_logic;
    -- i2c_controler interface
    pi_i2c_data       : in  std_logic_vector(31 downto 0);
    pi_i2c_done       : in  std_logic;
    po_i2c_str        : out std_logic;
    po_i2c_write_ena  : out std_logic;
    po_i2c_rep        : out std_logic;
    po_i2c_data_width : out std_logic_vector(1 downto 0);
    po_i2c_data       : out std_logic_vector(31 downto 0);
    po_i2c_addr       : out std_logic_vector(7 downto 0);
    -- User configuration interface
    pi_trg        : in  std_logic;
    pi_data_p0    : in std_logic_vector(7 downto 0);  -- Output write P07 ... P00
    pi_data_p1    : in std_logic_vector(7 downto 0);  -- Output write P17 ... P10
    po_done       : out std_logic;
    po_busy       : out std_logic 
    );
end entity tca9539;
-------------------------------------------------------------------------------
architecture behave of tca9539 is

  type t_fsm_state is ( ST_IDLE,
                      ST_WAIT_GRANT,
                        ST_CONF_P0, 
                        ST_CONF_P1,
                        ST_START_TIMER,
                        ST_WAIT_TIMER,
                        ST_PREPARE,
                        ST_CMD_WRITE,
                        ST_PROVIDE
                        );

  signal fsm_state         : t_fsm_state;
  signal state_to_comeback : t_fsm_state;

  signal cmd_select  : natural;

  -- Control Register Bits
  -- B2 B1  B0  Command Byte  Register                  Protocol        Power up default
  -- 0  0   0   0x00          Input Port 0  (P0-P7)     Read byte       xxxx xxxx
  -- 0  0   1   0x01          Input Port 1  (P10-P17)   Read byte       xxxx xxxx
  -- 0  1   0   0x02          Output Port 0             Read/write byte 1111 1111
  -- 0  1   1   0x03          Output Port 1             Read/write byte 1111 1111
  -- 1  0   0   0x04          Polarity Inversion Port 0 Read/write byte 0000 0000
  -- 1  0   1   0x05          Polarity Inversion Port 1 Read/write byte 0000 0000
  -- 1  1   0   0x06          Configuration Port 0      Read/write byte 1111 1111
  -- 1  1   1   0x07          Configuration Port 1      Read/write byte 1111 1111

  constant C_REG_IODIR_P0   : std_logic_vector(7 downto 0)  := x"06";
  constant C_REG_IODIR_P1   : std_logic_vector(7 downto 0)  := x"07";
  constant C_REG_IO_CONFIG  : std_logic_vector(7 downto 0)  := x"00"; --all outputs
  constant C_REG_GPO_P0     : std_logic_vector(7 downto 0)  := x"02";
  constant C_REG_GPO_P1     : std_logic_vector(7 downto 0)  := x"03";  
  signal reg_write : std_logic_vector(15 downto 0);

  constant C_TIMER    : natural := g_clk_freq/10_000 ; -- wait 0.1 ms 
  signal timer        : natural := C_TIMER;

-------------------------------------------------------------------------------
begin

  po_i2c_addr <= g_i2c_addr;

  process (pi_clock) is
  begin  
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        po_req            <= '0';
        po_i2c_str        <= '0';
        po_i2c_write_ena  <= '0';
        po_i2c_rep        <= '0';
        po_i2c_data_width <= (others => '0');
        po_i2c_data       <= (others => '0');
        po_done           <= '0';
        po_busy           <= '0';
        fsm_state         <= ST_IDLE;
        cmd_select        <= 0;
        reg_write         <= (others => '0');

      else
        case fsm_state is
          ------------------------------------------------------------
          when ST_IDLE =>
            po_done       <= '0';
            po_req            <= '0';
            po_i2c_str        <= '0';
            po_i2c_write_ena  <= '0';
            po_i2c_rep        <= '0';
            po_i2c_data_width <= (others => '0');
            po_i2c_data       <= (others => '0');
            po_busy           <= '0';
            timer             <= C_TIMER;
            cmd_select         <= 0;

            if pi_trg = '1' then
              po_busy   <= '1';
              fsm_state <= ST_CONF_P0;

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
          when ST_CONF_P0 =>
            po_done                   <= '0';
            po_req                    <= '1';
            po_i2c_write_ena          <= '1';
            po_i2c_rep                <= '0';
            po_i2c_data(15 downto 0)  <= C_REG_IODIR_P0 & C_REG_IO_CONFIG;
            po_i2c_data_width         <= "01";
            po_i2c_str                <= '1';
            cmd_select                <= 0;
            if pi_grant = '1' then
              fsm_state               <= ST_START_TIMER;
              state_to_comeback       <= ST_CONF_P1;

            end if;
          ------------------------------------------------------------
           when ST_CONF_P1 =>            
            po_req                    <= '1';
            po_i2c_write_ena          <= '1';
            po_i2c_rep                <= '0';
            po_i2c_data(15 downto 0)  <= C_REG_IODIR_P1 & C_REG_IO_CONFIG;
            po_i2c_data_width         <= "01";
            po_i2c_str                <= '1';
            if pi_grant = '1' then
              fsm_state               <= ST_START_TIMER;
              state_to_comeback       <= ST_PREPARE;

            end if;
          
          ------------------------------------------------------------
          when ST_PREPARE =>
            if cmd_select = 0 then
              reg_write         <= C_REG_GPO_P0 & pi_data_p0;
              state_to_comeback <= ST_PREPARE;
              cmd_select        <= 1;
              fsm_state         <= ST_CMD_WRITE;

            elsif cmd_select = 1 then
              reg_write         <= C_REG_GPO_P1 & pi_data_p1;
              state_to_comeback <= ST_PROVIDE;
              fsm_state         <= ST_CMD_WRITE;
              
            end if;

          ------------------------------------------------------------
          when ST_CMD_WRITE =>
            po_req                  <= '1';
            po_i2c_write_ena        <= '1';
            po_i2c_rep              <= '0';
            po_i2c_data(15 downto 0) <= reg_write;
            po_i2c_data_width       <= "01";
            po_i2c_str              <= '1';
            if pi_grant = '1' then
              fsm_state               <= ST_START_TIMER;

            end if;
          
          ------------------------------------------------------------
          when ST_PROVIDE =>
            po_done   <= '1';
            fsm_state       <= ST_IDLE;
            cmd_select      <= 0;
          
          when others =>
            fsm_state       <= ST_IDLE;
            
        end case;

      end if; --pi_reset

    end if; -- rising_edge
  
  end process;
 
end architecture behave;
