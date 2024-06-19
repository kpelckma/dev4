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
--! @date
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Digital Humidity Sensor
--! Needs i2c_controller component to communicate with chip
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

entity hyt271 is
  generic (
    G_ADDR : std_logic_vector(6 downto 0) := "0101000"
  );
  port (
    pi_clock      : in  std_logic;
    pi_reset      : in  std_logic;
    -- interface
    pi_trg        : in  std_logic; -- trigger conversion, next trigger data readout
    po_humi       : out std_logic_vector(13 downto 0);  -- humidity value out
    po_temp       : out std_logic_vector(13 downto 0);  -- temperature value out
    po_done       : out std_logic;
    -- arbiter interface
    po_req        : out std_logic;
    pi_grant      : in  std_logic := '1';
    -- i2c_controler interface
    po_str        : out std_logic;
    po_wr         : out std_logic;
    po_data_width : out std_logic_vector(1 downto 0);
    po_data       : out std_logic_vector(31 downto 0);
    pi_data       : in  std_logic_vector(31 downto 0);
    pi_data_dry   : in std_logic := '0';
    po_addr       : out std_logic_vector(6 downto 0);
    pi_done       : in  std_logic
    );
end entity hyt271;

architecture beh of hyt271 is

  type t_state is (ST_IDLE, ST_MR, ST_READ,ST_READ_CHECK, ST_FINISH, ST_MR_FINISH);

  signal sig_state         : t_state := ST_IDLE;
  signal sig_received_data : std_logic_vector(31 downto 0);
  signal sig_was_mr        : std_logic := '0';  -- previous transaction was measurement request

begin

  po_addr  <= G_ADDR;

  process (pi_clock, pi_reset) is
    variable v_timeout : natural := 0;
  begin
    if pi_reset = '1' then             -- asynchronous reset (active high)
      sig_state     <= ST_IDLE;
      po_req        <= '0';
      po_data_width <= (others => '0');
      po_wr         <= '0';
      po_str        <= '0';
      sig_was_mr    <= '0';
    elsif rising_edge(pi_clock) then  -- rising clock edge

      po_str <= '0';

      case sig_state is

        when ST_IDLE =>
          po_req  <= '0' ;
          po_done <= '0' ;
          v_timeout := 0 ;
          if pi_trg = '1' then
            po_req   <= '1';
            if sig_was_mr = '0' then
              sig_state <= ST_MR;
              sig_was_mr <= '1';
            else
              sig_state <= ST_READ;
              sig_was_mr <= '0';
            end if;
          end if;

        when ST_MR =>
          if pi_grant = '1' then
            po_wr         <= '1';
            po_data       <= ( others => '0' ) ;
            po_data_width <= "00";
            po_str        <= '1';

            sig_state      <= ST_MR_FINISH;
          end if;

        when ST_READ =>
          if pi_grant = '1' then
            po_wr         <= '0';
            po_data       <= ( others => '0' ) ;
            po_data_width <= "11";
            po_str        <= '1';
            sig_state <= ST_READ_CHECK;
          end if;

        when ST_READ_CHECK =>
          if pi_done = '1' then
            v_timeout := v_timeout + 1 ;
            if sig_received_data(30) = '0' or v_timeout >= 15 then
              sig_state      <= ST_FINISH;
            else
              sig_state      <= ST_READ;
              po_data_width <= "11";
              po_str        <= '1';
            end if;
          end if;

          if pi_data_dry = '1' then
            sig_received_data <= pi_data ;
          end if;

        when ST_FINISH =>
          po_humi       <= sig_received_data(29 downto 16);
          po_temp       <= sig_received_data(15 downto 2);

          po_done       <= '1';
          po_wr         <= '0';
          po_data       <= (others => '0');
          po_data_width <= "00";
          po_str        <= '0';
          po_req        <= '0';
          sig_state      <= ST_IDLE;

        when ST_MR_FINISH =>
          if pi_done = '1' then
            po_done       <= '0';
            po_wr         <= '0';
            po_data       <= (others => '0');
            po_data_width <= "00";
            po_str        <= '0';
            po_req        <= '0';
            sig_state      <= ST_IDLE;
          end if;

        when others =>
          sig_state <= ST_IDLE;

      end case;
    end if;
  end process;

end architecture beh;
