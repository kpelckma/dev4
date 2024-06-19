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
--! 2-channel I2C-Bus Multiplexer 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity pca9542 is
generic(
  g_i2c_addr        : std_logic_vector(7 downto 0) := x"E0"; -- first byte always "1110" preamble
  g_cfg_pi_addr_ena : std_logic := '0'   --'0' fixed g_i2c_addr, '1' port pi_i2c_addr
);
port(
  pi_clock          : in  std_logic;
  pi_reset          : in  std_logic;
  -- Arbiter interface
  po_req            : out std_logic:='0';
  pi_grant          : in  std_logic;
  -- I2C_CONTROLER interface
  po_i2c_str        : out std_logic:='0';
  po_i2c_write_ena  : out std_logic:='0';
  po_i2c_rep        : out std_logic:='0';
  po_i2c_data_width : out std_logic_vector(1 downto 0)  :=(others=>'0');
  po_i2c_data       : out std_logic_vector(31 downto 0) :=(others=>'0');
  po_i2c_addr       : out std_logic_vector(7 downto 0)  :=(others=>'0');
  pi_i2c_done       : in  std_logic;
  pi_i2c_data       : in  std_logic_vector(31 downto 0);
  -- User Interface
  pi_trg            : in  std_logic;
  pi_cfg_addr       : in  std_logic_vector(7 downto 0);
  pi_cfg_ch_ena     : in  std_logic:='0'; -- '0' ch0 enabled, '1' ch1 enable
  pi_cfg_switch_ena : in  std_logic:='0'; -- '0' disable complete switch, both ch0 and ch1, '1' enable selected ch !!should be used when g_cfg_device_addr_ena is '1'
  po_cfg_done       : out std_logic:='0';
  po_busy           : out std_logic:='0'
);
end pca9542;
-------------------------------------------------------------------------------
architecture Behavioral of pca9542 is

  type t_fsm_state is (ST_IDLE,
                       ST_SET_REGISTER,
                       ST_CFG_DONE);

  signal fsm_state        : t_fsm_state;
  signal reg_control      : std_logic_vector(7 downto 0);
  signal i2c_addr         : std_logic_vector(7 downto 0);
  signal cfg_addr         : std_logic_vector(7 downto 0);
  signal cfg_switch_active: std_logic;
  signal cfg_ch_select    : std_logic;

begin
  --===========================================================================
  --! Generate I2C address propagation and Control register
  --===========================================================================
  gen_fixed_addr: if g_cfg_pi_addr_ena = '0' generate
    cfg_addr <= G_I2C_ADDR;

  end generate;

  gen_cfg_addr: if g_cfg_pi_addr_ena = '1' generate
   cfg_addr <= pi_cfg_addr;
  end generate;

  -- =============================================================================
  prs_main_fsm: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        po_i2c_data         <= (others => '0');
        po_i2c_data_width   <= (others => '0');
        po_i2c_write_ena    <= '0';
        po_i2c_str          <= '0';
        po_req              <= '0';
        po_busy             <= '0';
        po_cfg_done         <= '0';

        fsm_state           <= ST_IDLE;

      else

        case fsm_state is
          ------------------------------------------------------------
          when ST_IDLE =>
            po_i2c_data       <= (others => '0');
            po_i2c_data_width <= (others => '0');
            po_i2c_write_ena  <= '0';
            po_i2c_str        <= '0';
            po_req            <= '0';
            po_cfg_done       <= '0';

            cfg_switch_active <= pi_cfg_switch_ena;
            cfg_ch_select     <= pi_cfg_ch_ena;
            i2c_addr          <= cfg_addr;
            
            if pi_trg = '1' then
              po_busy <= '1';
              fsm_state   <= ST_SET_REGISTER;

            else
              po_busy <= '0';

            end if;

          ------------------------------------------------------------
          when ST_SET_REGISTER =>
            po_req                  <= '1';
            po_i2c_write_ena        <= '1';
            po_i2c_rep              <= '0';
            po_i2c_data(7 downto 0) <= "00"&"00"&'0' & cfg_switch_active & '0' & cfg_ch_select;
            po_i2c_addr             <= i2c_addr;
            po_i2c_data_width       <= "00"; --1 Byte
            po_i2c_str              <= '1';

            if pi_grant = '1' then
              fsm_state             <= ST_CFG_DONE;

            end if;
          ------------------------------------------------------------
          when ST_CFG_DONE => 
            po_i2c_str      <= '0';
            if pi_i2c_done = '1' then
              po_req      <= '0';
              fsm_state   <= ST_IDLE;
              po_cfg_done <= '1';

            end if;
          ------------------------------------------------------------
          when others =>
            fsm_state <= ST_IDLE;

        end case;

      end if; --reset

    end if; --rising

  end process;
end Behavioral;