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
--! @created 2021-11-18
--! @author  Katharina Schulz <katharina.schulz@desy.de>
-------------------------------------------------------------------------------
--! @description
--! Microchip 16 Bit GPIO Expander
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity mcp23017 is
  generic(  
    g_clk_freq  : natural                       := 125_000_000; -- in Hz
    g_i2c_addr  : std_logic_vector(7 downto 0)  := x"40"
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
    pi_trg            : in  std_logic;
    po_data_a         : out std_logic_vector(7 downto 0); -- GPIO_A intput, read
    po_data_b         : out std_logic_vector(7 downto 0); -- GPIO_B intput, read
    po_data_vld       : out std_logic;
    po_busy           : out std_logic 
    );
end entity mcp23017;
-------------------------------------------------------------------------------
architecture behave of mcp23017 is

  type t_fsm_state is ( ST_IDLE, 
                        ST_CONF_IO, 
                        ST_START_TIMER,
                        ST_CMD_READ,
                        ST_READ_DONE,
                        ST_READ,
                        ST_READ_IO,
                        ST_PROVIDE,
                        ST_WAIT_TIMER
                        );

  signal fsm_state         : t_fsm_state;
  signal state_to_comeback : t_fsm_state;

  -- ICON Controll Register
  --[7] BANK: Controls how the registers are addressed
  --    1 = The registers associated with each port are separated into different banks
  --    0 = The registers are in the same bank (addresses are sequential)
  --[6] MIRROR: INT Pins Mirror bit
  --    1 = The INT pins are internally connected
  --    0 = The INT pins are not connected. INTA is associated with PORTA and INTB is associated with PORTB
  --[5] SEQOP: Sequential Operation mode bit
  --    1 =  Sequential operation disabled, address pointer does not increment.
  --    0 =  Sequential operation enabled, address pointer increments
  --[4] DISSLW: Slew Rate control bit for SDA output
  --    1 =  Slew rate disabled
  --    0 =  Slew rate enabled
  --[3] HAEN: Hardware Address Enable bit (always enabled for mcp23017) 
  --    must be 1
  --[2] ODR: Configures the INT pin as an open-drain output
  --    1 =  Open-drain output (overrides the INTPOL bit.)
  --    0 =  Active driver output (INTPOL bit sets the polarity.)
  --[1] INTPOL: This bitsets the polarity of the INT output pin
  --    1 =  Active-high
  --    0 =Active-low
  --[0] Unimplemented: Read as'0'

  --DEFAULT REGISTER ASSIGNMENT: 0000 0000 => addresses sequent., address pointer increments!
  --not needed to be configured

  -- IODIR Controll Register
  --[7:0]: Controls the direction of data I/O
  -- 1 =  Pin is configured as an input.
  -- 0 =  Pin is configured as an out 
  constant C_REG_IODIR    : std_logic_vector(7 downto 0)  := x"00";           --start address
  constant C_IODIR_A_DATA : std_logic_vector(7 downto 0)  := (others => '1'); --all inputs
  constant C_IODIR_B_DATA : std_logic_vector(7 downto 0)  := (others => '1'); --all inputs
  
  constant C_READ_REG : std_logic_vector(7 downto 0)      := x"12";           --start address port A in bank=0
  signal port_a       : std_logic_vector(7 downto 0)  := (others => '0');
  signal port_b       : std_logic_vector(7 downto 0)  := (others => '0');

  constant C_TIMER    : natural := 1 * g_clk_freq/1_000 ; -- wait 1 ms 
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
        po_data_vld         <= '0';
        po_data_a          <= (others => '0');
        po_data_b          <= (others => '0');
        po_busy           <= '0';    
        fsm_state         <= ST_IDLE;

      else
        case fsm_state is
        ------------------------------------------------------------
        when ST_IDLE =>
          po_data_vld       <= '0';
          po_req            <= '0';
          po_i2c_str        <= '0';
          po_i2c_write_ena  <= '0';
          po_i2c_rep        <= '0';
          po_i2c_data_width <= (others => '0');
          po_i2c_data       <= (others => '0');
          po_busy           <= '0';
          timer             <= C_TIMER;

          if pi_trg = '1' then
            po_busy   <= '1';
            fsm_state <= ST_CONF_IO;

          end if;
          ------------------------------------------------------------
          when ST_CONF_IO =>            
            po_req                    <= '1';
            po_i2c_write_ena          <= '1';
            po_i2c_data(23 downto 0)  <= C_REG_IODIR & C_IODIR_A_DATA & C_IODIR_A_DATA;
            po_i2c_data_width         <= "10";
            po_i2c_str                <= '1';
            if pi_grant = '1' then
              fsm_state               <= ST_START_TIMER;
              state_to_comeback       <= ST_CMD_READ;

            end if;

          ------------------------------------------------------------
          when ST_START_TIMER =>
            po_i2c_str  <= '0';
            if pi_i2c_done = '1' then
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
          when ST_CMD_READ =>
            po_i2c_write_ena        <= '1';
            po_i2c_rep              <= '1';
            po_i2c_data(7 downto 0) <= C_READ_REG ;
            po_i2c_data_width       <= "00";
            po_i2c_str              <= '1';
            if pi_grant = '1' then
              fsm_state               <= ST_READ_DONE;

            end if;

          ------------------------------------------------------------
          when ST_READ_DONE =>
          po_i2c_str      <= '0';
          if pi_i2c_done = '1' then
            fsm_state     <= ST_READ;

          end if;
          
          ------------------------------------------------------------
          when ST_READ =>
            po_req            <= '1';
            po_i2c_rep        <= '0';
            po_i2c_str        <= '1';
            po_i2c_write_ena  <= '0';
            po_i2c_data_width <= "01";
            if pi_grant = '1' then
              fsm_state         <= ST_READ_IO;

            end if;

          ------------------------------------------------------------
          when ST_READ_IO =>
            po_i2c_str      <= '0';
            if pi_i2c_done = '1' then
              po_req        <= '0';
              port_a        <= pi_i2c_data(15 downto 8);
              port_b        <= pi_i2c_data(7 downto 0);
              fsm_state     <= ST_PROVIDE;
              
            end if;

          ------------------------------------------------------------
          when ST_PROVIDE =>
            po_data_vld   <= '1';
            po_data_a    <= port_a;
            po_data_b    <= port_b;
            fsm_state   <= ST_IDLE;
          
          when others =>
            fsm_state <= ST_IDLE;
          
        end case;

      end if; --pi_reset

    end if; -- rising_edge
  
  end process;
  
end architecture behave;
