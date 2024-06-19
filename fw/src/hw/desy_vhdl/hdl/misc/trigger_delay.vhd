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
--! @date 2021-09-14
--! @author MSK FPGA Team
------------------------------------------------------------------------------
--! @brief
--! Delays the triggers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

entity trigger_delay is
  generic (
    G_COUNT_DELAYED_TRG : natural:= 1
  );
  port (
    pi_clock : in std_logic;
    pi_main_trigger : in std_logic;
    pi_delay_val : in t_32b_slv_vector(G_COUNT_DELAYED_TRG-1 downto 0);

    po_delayed_trigger : out std_logic_vector(G_COUNT_DELAYED_TRG-1 downto 0)
  );
end trigger_delay;

architecture Behavioral of trigger_delay is

  type t_delay_state is (ST_IDLE, ST_COUNTING);

  signal delayed_trg        : std_logic_vector(G_COUNT_DELAYED_TRG-1 downto 0) := (others => '0');
  signal delayed_trg_by_one : std_logic_vector(G_COUNT_DELAYED_TRG-1 downto 0) := (others => '0');
begin
  GEN_TRG_DLY : for I in 0 to G_COUNT_DELAYED_TRG-1 generate
    signal l_delay_stt : t_delay_state := ST_IDLE;
    signal l_delay_val_q : signed(33-1 downto 0);
    signal l_delay_counter : signed(33-1 downto 0);
  begin
    po_delayed_trigger(I) <= pi_main_trigger       when pi_delay_val(I) = x"00000000" else
                             delayed_trg_by_one(I) when pi_delay_val(I) = x"00000001" else
                             delayed_trg(I);
    -- improve timing
    l_delay_val_q <= signed('0' & pi_delay_val(I)) when rising_edge(pi_clock);

    delayed_trg_by_one(I) <= pi_main_trigger when rising_edge(pi_clock);

    prs_delay : process(pi_clock)
    begin
      if rising_edge(pi_clock) then

        case l_delay_stt is
          when ST_IDLE =>
            delayed_trg(I)  <= '0';
            l_delay_counter <= l_delay_val_q-3;

            if pi_main_trigger = '1' and delayed_trg_by_one(I) = '0' then
              l_delay_stt <= ST_COUNTING;
            end if;

          -- do not leave this state on a trigger, always finish the delay first
          when ST_COUNTING =>
            l_delay_counter <= l_delay_counter-1;

            -- detect negative number after the backwards counter has reached 0
            if l_delay_counter(l_delay_counter'high) = '1' then
              delayed_trg(I) <= '1';
              l_delay_stt    <= ST_IDLE;
            end if;

          when others =>
            delayed_trg(I)  <= '0';
            l_delay_counter <= l_delay_val_q-3;
            l_delay_stt     <= ST_IDLE;
        end case;
      end if;
    end process;
  end generate;
end Behavioral;
