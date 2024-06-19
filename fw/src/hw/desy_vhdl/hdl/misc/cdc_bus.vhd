--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2023 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2023-02-23
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief Clock Domain Crossing of two buses in oposite directions
--!
--! shared handshaking with self trigger
--! single flag synchronization per direction
--! 2-phase (or edge based or alternate or toggle type) handshaking
--! ensures consistent bus content but bandwidth is limited with flag round trip
--! bus data rate should be less than capture rate (1/T) to prevent data loss
--! T ~ pi_clock_a * (G_SYNC_FF_A + 1) + pi_clock_b * (G_SYNC_FF_B + 1) cycles
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity cdc_bus is
  generic (
    G_SYNC_FF_A : natural := 2; --! number of synchronizer stages in clock domain A
    G_SYNC_FF_B : natural := 2; --! number of synchronizer stages in clock domain B
    G_WIDTH_A2B : natural := 8;
    G_WIDTH_B2A : natural := 8
  );
  port (
    pi_clock_a  : in  std_logic;
    pi_reset_a  : in  std_logic;
    pi_data_a2b : in  std_logic_vector(G_WIDTH_A2B-1 downto 0);
    po_data_b2a : out std_logic_vector(G_WIDTH_B2A-1 downto 0);

    pi_clock_b  : in  std_logic;
    pi_reset_b  : in  std_logic;
    po_data_a2b : out std_logic_vector(G_WIDTH_A2B-1 downto 0);
    pi_data_b2a : in  std_logic_vector(G_WIDTH_B2A-1 downto 0)
  );
end entity cdc_bus;

architecture rtl of cdc_bus is

  signal flag_a   : std_logic;
  signal flag_b   : std_logic;
  signal flag_a2b : std_logic_vector(G_SYNC_FF_B-1 downto 0);
  signal flag_b2a : std_logic_vector(G_SYNC_FF_A-1 downto 0);
  signal data_a2b : std_logic_vector(G_WIDTH_A2B-1 downto 0);
  signal data_b2a : std_logic_vector(G_WIDTH_B2A-1 downto 0);

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of flag_a2b : signal is "TRUE";
  attribute ASYNC_REG of flag_b2a : signal is "TRUE";

begin

  flag_a2b <= flag_a & flag_a2b(G_SYNC_FF_B-1 downto 1) when rising_edge(pi_clock_b);
  flag_b2a <= flag_b & flag_b2a(G_SYNC_FF_A-1 downto 1) when rising_edge(pi_clock_a);

  prs_flag_a: process(pi_clock_a, pi_reset_a)
  begin
    if pi_reset_a = '1' then
      flag_a <= '0';
    elsif rising_edge(pi_clock_a) then
      flag_a <= not flag_b2a(0);
    end if;
  end process prs_flag_a;

  prs_flag_b: process(pi_clock_b, pi_reset_b)
  begin
    if pi_reset_b = '1' then
      flag_b <= '0';
    elsif rising_edge(pi_clock_b) then
      flag_b <= flag_a2b(0);
    end if;
  end process prs_flag_b;

  prs_capture_a: process(pi_clock_a)
  begin
    if rising_edge(pi_clock_a) then
      if (flag_a xnor flag_b2a(0)) = '1' then
        data_b2a <= pi_data_b2a;
        po_data_a2b <= data_a2b;
      end if;
    end if;
  end process prs_capture_a;

  prs_capture_b: process(pi_clock_b)
  begin
    if rising_edge(pi_clock_b) then
      if (flag_b xor flag_a2b(0)) = '1' then
        data_a2b <= pi_data_a2b;
        po_data_b2a <= data_b2a;
      end if;
    end if;
  end process prs_capture_b;

end architecture rtl;

