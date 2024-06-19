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
-------------------------------------------------------------------------------
--! @description
--! Analog Devices Power Monitor
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity ltc2945 is
  generic(
    g_clk_freq      : natural := 125_000_000; -- in Hz
    g_i2c_addr      : std_logic_vector(7 downto 0) := x"DE"
    );
  port (
    pi_clock          : in  std_logic;
    pi_reset          : in  std_logic;
    -- Arbiter interface
    po_req            : out std_logic;
    pi_grant          : in  std_logic;
    po_i2c_rep        : out std_logic;
    -- i2c_controler interface
    pi_i2c_data       : in  std_logic_vector(31 downto 0);
    pi_i2c_done       : in  std_logic;
    po_i2c_str        : out std_logic;
    po_i2c_write_ena  : out std_logic;
    po_i2c_data_width : out std_logic_vector(1 downto 0);
    po_i2c_data       : out std_logic_vector(31 downto 0);
    po_i2c_addr       : out std_logic_vector(7 downto 0);
    -- User interface
    pi_trg            : in std_logic;
    po_data_vld     : out std_logic;
    po_current        : out std_logic_vector(15 downto 0);
    po_voltage        : out std_logic_vector(15 downto 0);
    po_busy           : out  std_logic
    );
end entity ltc2945;
-------------------------------------------------------------------------------
architecture behave of ltc2945 is

  type t_fsm_state is ( ST_IDLE,
                        ST_CMD_I,
                        ST_START_TIMER,
                        ST_WAIT_TIMER,
                        ST_READ,
                        ST_READ_V,
                        ST_READ_I,
                        ST_CMD_V,
                        ST_PROVIDE);

  signal fsm_state         : t_fsm_state;
  signal state_to_comeback : t_fsm_state;

  --Start internal register pointer; increased after each Byte
  constant C_REG_I_MSB : std_logic_vector(7 downto 0) := x"14"; -- Begins with MSByte
  constant C_REG_V_MSB : std_logic_vector(7 downto 0) := x"1E";
  signal current_data : std_logic_vector(15 downto 0);
  signal voltage_data : std_logic_vector(15 downto 0);

  constant C_TIMER : natural := 5 * g_clk_freq/1_000 ; -- wait 5 ms 
  signal timer     : natural := C_TIMER;
-------------------------------------------------------------------------------
begin

  po_i2c_addr <= g_i2c_addr;

  process (pi_clock) is
  begin  
    if rising_edge(pi_clock) then
      if pi_reset = '1' then 
        po_req              <= '0';
        po_i2c_str          <= '0';
        po_i2c_write_ena    <= '0';
        po_i2c_data_width   <= (others => '0');
        po_i2c_data         <= (others => '0');
        po_data_vld       <= '0';
        po_current          <= (others => '0');
        po_voltage          <= (others => '0');
        po_busy             <= '0';
        fsm_state           <= ST_IDLE;
        
      else
        case fsm_state is
          ------------------------------------------------------------
          when ST_IDLE =>
            po_data_vld  <= '0';
            po_busy        <= '0';
            po_i2c_str          <= '0';
            po_i2c_write_ena    <= '0';
            po_i2c_data_width   <= (others => '0');
            po_i2c_data         <= (others => '0');
            timer             <= C_TIMER;

            if pi_trg = '1' then
              po_busy   <= '1';
              fsm_state <= ST_CMD_I;

            end if;

          ------------------------------------------------------------
          when ST_CMD_I =>
            po_req                  <= '1';
            po_i2c_write_ena        <= '1';
            po_i2c_rep              <= '1';
            po_i2c_data(7 downto 0) <= C_REG_I_MSB ;
            po_i2c_data_width       <= "00";
            po_i2c_str              <= '1';

            if pi_grant = '1' then
              fsm_state               <= ST_START_TIMER;
              state_to_comeback       <= ST_READ_I;

            end if;

          ------------------------------------------------------------
          when ST_START_TIMER =>
            po_i2c_str      <= '0';
            if pi_i2c_done = '1' then
              po_req        <= '0';
              fsm_state     <= ST_WAIT_TIMER;
              timer         <= C_TIMER;

            end if;

          ------------------------------------------------------------
          when ST_WAIT_TIMER =>
            timer <= timer - 1;
            if timer = 0 then
              fsm_state <= ST_READ;
              
            end if;

          ------------------------------------------------------------
          when ST_READ =>
            po_req            <= '1';
            po_i2c_rep        <= '0';
            po_i2c_str        <= '1';
            po_i2c_write_ena  <= '0';
            po_i2c_data_width <= "01";
            if pi_grant = '1' then
              fsm_state         <= state_to_comeback;

            end if;

          ------------------------------------------------------------
          when ST_READ_I =>
            po_i2c_str      <= '0';
            if pi_i2c_done = '1' then
              current_data(11 downto 4)  <= pi_i2c_data(15 downto 8); --MSB 
              current_data(3 downto 0)  <= pi_i2c_data(7 downto 4); --high half byte (low half byte zero by default)
              fsm_state     <= ST_CMD_V;
              
            end if;

          ------------------------------------------------------------
          when ST_CMD_V =>
            po_req                  <= '1';
            po_i2c_write_ena        <= '1';
            po_i2c_rep              <= '1';
            po_i2c_data(7 downto 0) <= C_REG_V_MSB;
            po_i2c_data_width       <= "00"; 
            po_i2c_str              <= '1';
            if pi_grant = '1' then
              fsm_state               <= ST_START_TIMER;
              state_to_comeback       <= ST_READ_V;

            end if;

          ------------------------------------------------------------
          when ST_READ_V =>
            po_i2c_str      <= '0';
            if pi_i2c_done = '1' then
              po_req        <= '0';
              voltage_data(11 downto 4) <= pi_i2c_data(15 downto 8);
              voltage_data(3 downto 0)  <= pi_i2c_data(7 downto 4);
              fsm_state                 <= ST_PROVIDE;
              
            end if;

          when ST_PROVIDE =>
            po_data_vld <= '1';
            po_current  <= current_data;
            po_voltage  <= voltage_data;
            fsm_state   <= ST_IDLE;
          
          when others =>
            fsm_state <= ST_IDLE;
          
        end case;

      end if; --pi_reset

    end if; -- rising_edge
  
  end process;
  
end architecture behave;
