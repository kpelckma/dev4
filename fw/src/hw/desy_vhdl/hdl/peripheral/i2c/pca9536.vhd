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
--! @date 2022-06-10
--! @author Katharina Schulz <katharina.schulz@desy.de>
--! @author Radoslaw Rybaniec <radoslaw.rybaniec@desy.de>
-------------------------------------------------------------------------------
--! @description NXP 4 bit I2C I/O expander
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------

entity pca9536 is
  generic(  
    g_clk_freq  : natural := 125_000_000 -- in Hz
    );
  port (
    pi_clock          : in  std_logic;
    pi_reset          : in  std_logic;
    -- Arbiter interface
    po_req            : out std_logic;
    pi_grant          : in  std_logic;
    -- I2C_CONTROLER interface
    po_i2c_str        : out std_logic;
    po_i2c_write_ena  : out std_logic;
    po_i2c_rep        : out std_logic;
    po_i2c_data_width : out std_logic_vector(1 downto 0);
    po_i2c_data       : out std_logic_vector(31 downto 0);
    po_i2c_addr       : out std_logic_vector(7 downto 0);
    pi_i2c_done       : in  std_logic;
    pi_i2c_data       : in  std_logic_vector(31 downto 0); 
    -- User interface
    pi_trg            : in  std_logic;
    pi_data           : in std_logic_vector(3 downto 0); --  output, send data
    po_data_vld       : out std_logic;
    po_busy           : out std_logic
  );
end entity pca9536;
-------------------------------------------------------------------------------
architecture behave of pca9536 is

  type t_fsm_state is ( ST_IDLE, 
                        ST_CONF_IO, 
                        ST_START_TIMER, 
                        ST_CMD_WRITE,
                        ST_WRITE_DONE,
                        ST_WAIT_TIMER
                        );

  signal fsm_state         : t_fsm_state := ST_IDLE;
  signal state_to_comeback : t_fsm_state;

  signal reg_data : std_logic_vector(3 downto 0);
    
  constant C_ADDR         : std_logic_vector(7 downto 0)  := "01000001"; --fixed PCA9536 Address
  constant C_CONF_REG     : std_logic_vector(7 downto 0)  := x"03";
  constant C_CONF_REG_VAL : std_logic_vector(7 downto 0)  := x"00";  -- all outputs
  constant C_OUT_REG      : std_logic_vector(7 downto 0)  := x"01";
 
  constant C_TIMER    : natural := 1 * g_clk_freq/1_000 ; -- wait 1 ms 
  signal timer        : natural := C_TIMER;

  begin

  po_i2c_addr   <= C_ADDR;

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
          po_data_vld       <= '0';          
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
            po_i2c_data(15 downto 0)  <= C_CONF_REG & C_CONF_REG_VAL;
            po_i2c_data_width         <= "01";
            po_i2c_str                <= '1';
            if pi_grant = '1' then
              fsm_state               <= ST_START_TIMER;
              state_to_comeback       <= ST_CMD_WRITE;

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
          when ST_CMD_WRITE =>
            po_i2c_write_ena        <= '1';
            po_i2c_data(15 downto 0) <= C_OUT_REG & "0000" & pi_data;
            po_i2c_data_width       <= "01";
            po_i2c_str              <= '1';
            if pi_grant = '1' then
              fsm_state               <= ST_WRITE_DONE;

            end if;

          ------------------------------------------------------------
           when ST_WRITE_DONE =>
            po_i2c_str      <= '0';
            if pi_i2c_done = '1' then
              fsm_state     <= ST_IDLE;
              po_data_vld   <= '1';

            end if;
            
            when others =>
              fsm_state <= ST_IDLE;
            
          end case;
  
        end if; --pi_reset
  
      end if; -- rising_edge
    
    end process;
    
  end architecture behave;