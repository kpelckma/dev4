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
--! @date 2021-02-10
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief Attenuators interface using PCA9535
--! @description:
--                         _________________________
--                         |                 Port0-0| Clock      -------->
--      FPGA-----I2c-----> | IO Expander     Port0-1| SERIN      --------> HMC624LP4
--                         |  (PCA9535)  Port0-[2-6]| CS1 to CS5 --------> (10x Attenuator)
--                         |             Port1-[0-3]| CS6 to CS9 -------->
--                         |             Port1-[4-7]| Unused (G_DEFAULT_VALUES will apply here)
--                         |________________________|
--
-- Channel 0,1,2,3,4,5 -> ChipSelect line is on Port0
-- Channel 6,7,8,9 -> ChipSelect line is on Port1
-- Updating all channels with 81 MHz with 100kHz I2c takes about ~9.8ms
-- Users should write pi_att_val and pi_att_sel first and then pi_att_start
-- Transaction starts on the rising edge of pi_att_start and if pi_att_sel has non zero values
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library desy;

use desy.common_types.all;

entity hmc624_over_pca9535 is
generic(
  G_PCA9535_I2C_ADDR : std_logic_vector(7 downto 0) := x"20"; -- This must be changed according to RTM
  G_MAX_CHANNELS : natural := 8; -- How many Attenuators are there? Must be greater than 8.
  G_DEFAULT_VALUES : std_logic_vector(15 downto 0) := x"0000" -- What should be the value of unused ports?
);
port(
  pi_clock       : in  std_logic;
  pi_reset       : in  std_logic;
  -- Arbiter interface
  po_req        : out std_logic;
  pi_grant      : in  std_logic;
  -- I2C_CONTROLER interface
  po_i2c_str        : out std_logic;
  po_i2c_write_ena  : out std_logic;
  po_i2c_data_width : out std_logic_vector(1 downto 0);
  po_i2c_data       : out std_logic_vector(31 downto 0);
  po_i2c_addr       : out std_logic_vector(7 downto 0);
  pi_i2c_done       : in  std_logic;
  -- Attenuator params
  pi_att_val     : in  std_logic_vector(5 downto 0);
  pi_att_sel     : in  std_logic_vector(G_MAX_CHANNELS-1 downto 0);
  pi_att_start   : in  std_logic := '0';
  po_att_status  : out std_logic -- 1=>Att.updating 0=>Ready
);
end hmc624_over_pca9535;

architecture Behavioral of hmc624_over_pca9535 is

  type t_fsm_state is (ST_IDLE,             -- Idle State. Waiting for Start flag
                       ST_WAIT_GRANT,       -- Waiting for I2c Arbiter to give grant
                       ST_TRANSACTION_PORT, -- Serial Data sent here
                       ST_WAIT_PCA9535,     -- Intermediate state to wait PCA9535 to finish
                       ST_ASSERT_CS,        -- Asserting CS pin to load the new attenuator value into the ICs
                       ST_DEASSERT_CS);     -- Deassert CS pin

  signal fsm_state         : t_fsm_state;
  signal state_to_comeback : t_fsm_state;

  signal expander_direction  : t_8b_slv_vector(1 downto 0) := (others => (others => '0'));
  signal temp_pin_output     : t_8b_slv_vector(1 downto 0) := (others => (others => '0'));
  signal expander_pin_output : t_8b_slv_vector(1 downto 0) := (0=>G_DEFAULT_VALUES(7 downto 0), 1=>G_DEFAULT_VALUES(15 downto 8));
  
  signal expander_done       : std_logic_vector(1 downto 0) := (others => '0');  -- Done flag for the PCA9535
  signal expander_strobe     : std_logic_vector(1 downto 0) := (others => '0');  -- Start flag for the PCA9535

  signal i2c_strobe     : std_logic_vector(1 downto 0);
  signal i2c_grant      : std_logic_vector(1 downto 0);
  signal i2c_write_ena  : std_logic_vector(1 downto 0);
  signal i2c_data_width : t_2b_slv_vector(1 downto 0);
  signal i2c_data       : t_32b_slv_vector(1 downto 0);

  signal att_clock : std_logic                                   := '0';
  signal att_sel   : std_logic_vector(G_MAX_CHANNELS-1 downto 0) := (others => '0');
  signal att_val   : std_logic_vector(5 downto 0)                := (others => '0');
  signal att_serin : std_logic                                   := '0';
  signal att_cs    : t_6b_slv_vector(1 downto 0)                     := (others => (others => '0'));
    
  signal counter            : natural   := 0;
  signal active_port        : natural   := 0;    -- Indicate which PCA9535 is should use i2c lanes
  signal shift_counter      : std_logic := '0';
  signal prev_start         : std_logic := '0';  -- Rising edge detection signals
  signal start_transaction  : std_logic := '0';  -- When high, starts serial transaction
  signal port0_will_be_used : std_logic := '0';
  signal port1_will_be_used : std_logic := '0';
  
begin

  -- Muxing the 2x PCA9535 outputs according to which one is active
  po_i2c_str        <= i2c_strobe(0)     when active_port = 0 else i2c_strobe(1);
  po_i2c_write_ena  <= i2c_write_ena(0)  when active_port = 0 else i2c_write_ena(1);
  po_i2c_data_width <= i2c_data_width(0) when active_port = 0 else i2c_data_width(1);
  po_i2c_data       <= i2c_data(0)       when active_port = 0 else i2c_data(1);

  po_i2c_addr <= G_PCA9535_I2C_ADDR;

  expander_direction(0)  <= "00000000"; -- All ports will be configured as Output
  expander_direction(1)  <= "00000000";
  expander_pin_output(0) <=  att_cs(0) & att_serin & att_clock;
  expander_pin_output(1)(G_MAX_CHANNELS-7 downto 0) <= att_cs(1)(G_MAX_CHANNELS-7 downto 0);
  
 -- Rising edge detection for the start flag
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
    prev_start <= pi_att_start;
      if prev_start = '0' and pi_att_start = '1' then
        start_transaction <= '1';
      else
        start_transaction <= '0';
      end if;
    end if;
  end process;

  -- Serial transaction over PCA9535 pins
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        fsm_state     <= ST_IDLE;
        po_att_status <= '0';
        po_req        <= '0';

      else
        case fsm_state is

          when ST_IDLE =>
            po_att_status   <= '0';
            counter         <= 0;
            att_clock       <= '0';
            po_req          <= '0';
            expander_strobe <= "00";
            att_sel         <= (others => '0');
            shift_counter   <= '0';
            i2c_grant       <= (others => '0');
            att_serin       <= '0';
            att_cs          <= (others => (others => '0'));

            if start_transaction = '1' and or_reduce(pi_att_sel) /= '0' then
              fsm_state          <= ST_WAIT_GRANT;
              po_att_status      <= '1';  -- Indicate that attenuators are busy
              att_val            <= pi_att_val;
              att_sel            <= pi_att_sel;
              port0_will_be_used <= or_reduce(pi_att_sel(5 downto 0));                 -- For CS assertion only.
              port1_will_be_used <= or_reduce(pi_att_sel(G_MAX_CHANNELS-1 downto 6));  -- For CS assertion only.
            end if;


          when ST_WAIT_GRANT =>
            po_req <= '1';                   -- Request I2c Access
            if pi_grant = '1' then
              fsm_state <= ST_TRANSACTION_PORT;
              i2c_grant <= (others => '1');  -- Give grant to both ports
            end if;


          when ST_TRANSACTION_PORT => -- Use Port0 for sending serial data

            if counter = 13 then -- End of serial transaction go to next state
              counter         <= 0;
              expander_strobe <= "00";
              att_serin       <= '0';
              fsm_state       <= ST_ASSERT_CS;
            else 
              counter           <= counter + 1;
              active_port       <= 0;
              fsm_state         <= ST_WAIT_PCA9535;
              state_to_comeback <= ST_TRANSACTION_PORT;
              expander_strobe   <= "01";                         -- Enable the Port0 for serial transaction
              att_serin         <= att_val(5);                   -- Send MSB first
              att_cs            <= (others => (others => '0'));  -- Don't assert CS here

              shift_counter <= not shift_counter;
              if shift_counter = '1' then  -- Shift left on every second clock edge
                att_val <= att_val(4 downto 0) & '0';
              end if;

              if counter > 0 and counter < 13 then  -- Delay the clock by 1 sample
                if att_clock = '0' then
                  att_clock <= '1';
                else
                  att_clock <= '0';
                end if;
              else 
                att_clock <= '0';
              end if;

            end if;


          when ST_ASSERT_CS =>          -- Assert CS depending on which attenuator is active
            if port0_will_be_used = '1' then
              active_port        <= 0;
              port0_will_be_used <= '0';
              expander_strobe    <= "01";
              att_cs(0)          <= att_sel(5 downto 0);
              att_cs(1)          <= (others => '0');
              fsm_state          <= ST_WAIT_PCA9535;
              state_to_comeback  <= ST_DEASSERT_CS;

            elsif port1_will_be_used = '1' then
              active_port          <= 1;
              port1_will_be_used   <= '0';
              expander_strobe      <= "10";
              att_cs(0)            <= (others => '0');
              att_cs(1)(G_MAX_CHANNELS-7 downto 0) <= att_sel(G_MAX_CHANNELS-1 downto 6);
              fsm_state            <= ST_WAIT_PCA9535;
              state_to_comeback    <= ST_DEASSERT_CS;

            else
              fsm_state <= ST_IDLE;     -- No more work to be done

            end if;


          when ST_DEASSERT_CS =>
            att_cs                       <= (others => (others => '0'));
            expander_strobe(active_port) <= '1';
            fsm_state                    <= ST_WAIT_PCA9535;
            state_to_comeback            <= ST_ASSERT_CS;


          when ST_WAIT_PCA9535 =>       -- State where we will wait for Done signal
            expander_strobe <= "00";    -- Turn off strobe briefly
            if expander_done(active_port) = '1' then
              fsm_state <= state_to_comeback;
            end if;


          when others => fsm_state <= ST_IDLE;

        end case;
      end if;
    end if;
  end process;

  -- pca9535 entity handles logic per port
  -- Hence we need to instantiate 2x
  gen_ports : for i in 0 to 1 generate
    ins_pca9535 : entity desy.pca9535
    generic map(
      G_PORT_NB => i
    )
    port map(
      pi_clock  => pi_clock,
      pi_reset  => pi_reset,

      -- GPIO Interface
      pi_str   => expander_strobe(i),
      pi_gpo   => expander_pin_output(i),
      po_gpo   => open, -- Not needed
      pi_gpo_dir  => expander_direction(i), -- 1=> Input 0=> Output
      po_gpo_done => expander_done(i),

      -- arbiter interface
      po_req    => open, -- Above FSM handles the requests
      pi_grant  => i2c_grant(i),

      -- i2c_controller
      po_str         => i2c_strobe(i),
      po_wr          => i2c_write_ena(i),
      po_data_width  => i2c_data_width(i),
      po_data        => i2c_data(i),
      pi_data        => (others=>'0'), -- Not Needed
      pi_dry         => '0', -- Not Needed
      pi_done        => pi_i2c_done
    );
  end generate;

end Behavioral;