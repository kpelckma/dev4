-----------------------------------------------------------------------------
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
--! @author Radoslaw Rybaniec
------------------------------------------------------------------------------
--! @brief
--! I2C Controller
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
------------------------------------------------------------------------------

entity i2c_controller is
  generic (
    G_DIVIDER : natural := 25 --! FREQ_CLK_SPI=FREQ_I_CLK/G_DIVIDER
  );
  port (
    pi_clock        : in    std_logic;
    pi_reset       : in    std_logic;
    ---------------------------------------------------------------------------
    --! Ports
    ---------------------------------------------------------------------------
    pi_str         : in    std_logic;
    pi_wr          : in    std_logic;
    pi_rep         : in    std_logic; --! don't send stop bit (for repeated start)
    pi_data_width  : in    std_logic_vector(1 downto 0);
    pi_data        : in    std_logic_vector(31 downto 0);
    po_data        : out   std_logic_vector(31 downto 0);
    po_data_dry    : out   std_logic;
    pi_addr        : in    std_logic_vector(6 downto 0);
    po_done        : out   std_logic;
    po_busy        : out   std_logic;
    ---------------------------------------------------------------------------
    --! I2C interface
    ---------------------------------------------------------------------------
    pi_sdi         : in    std_logic; -- data input
    po_sdo         : out   std_logic; -- data output
    po_sdt         : out   std_logic; -- data direction, 0: high impedance
    pi_sci         : in    std_logic;
    po_sco         : out   std_logic;
    po_sct         : out   std_logic
  );
end entity i2c_controller;

architecture rtl of i2c_controller is

  type t_state is (ST_IDLE, ST_START, ST_DATA, ST_STOP, ST_DONE, ST_I2C, ST_I2C_0, ST_I2C_1, ST_I2C_2);

  signal sig_st          : t_state := ST_IDLE;
  signal sig_st_ret      : t_state;
  signal sig_st_prev     : t_state;
  signal sig_st_changed  : std_logic;

  signal sig_w_buf       : std_logic_vector(44 downto 0);
  signal sig_cnt         : unsigned(5 downto 0);

  signal sig_sda         : std_logic;                    -- actual on pins
  signal sig_scl         : std_logic;
  signal sig_sda_w       : std_logic_vector(3 downto 0); -- buffer
  signal sig_scl_w       : std_logic_vector(3 downto 0);

  signal sig_done        : std_logic;
  signal sig_busy        : std_logic;
  signal sig_ce          : std_logic;
  signal sig_data_dry    : std_logic;

  signal sig_r_buf       : std_logic_vector(36 downto 0);
  signal sig_sdi         : std_logic;
  signal sig_sdi0        : std_logic;
  signal sig_output_data : std_logic_vector(31 downto 0);
  signal sig_sci         : std_logic;

  signal sig_wr          : std_logic;
  signal sig_rep         : std_logic;
  signal sig_data_width  : std_logic_vector(1 downto 0);

  signal sig_dbg_state   : std_logic_vector(4 downto 0);
  signal sig_dbg_st_ret  : std_logic_vector(4 downto 0);
  signal sig_dbg_st_prev : std_logic_vector(4 downto 0);

begin

  po_sco <= '0';
  po_sdo <= '0';

  po_sdt  <= not sig_sda;
  po_sct  <= not sig_scl;
  po_data <= sig_output_data;

  po_done     <= sig_done;
  po_busy     <= sig_busy;
  po_data_dry <= sig_data_dry;

  -- synchronize
  sig_sdi0 <= pi_sdi when rising_edge(pi_clock);
  sig_sdi  <= sig_sdi0 when rising_edge(pi_clock);

  sig_sci <= pi_sci when rising_edge(pi_clock);

  sig_dbg_state <= "00000" when sig_st = ST_IDLE else
                   "00001" when sig_st = ST_START else
                   "00010" when sig_st = ST_DATA  else
                   "00011" when sig_st = ST_STOP else
                   "00100" when sig_st = ST_DONE else
                   "01000" when sig_st = ST_I2C else
                   "01001" when sig_st = ST_I2C_0 else
                   "01010" when sig_st = ST_I2C_1 else
                   "01011" when sig_st = ST_I2C_2 else
                   "11111";

  sig_dbg_st_ret <= "00000" when sig_st_ret = ST_IDLE else
                    "00001" when sig_st_ret = ST_START else
                    "00010" when sig_st_ret = ST_DATA  else
                    "00011" when sig_st_ret = ST_STOP else
                    "00100" when sig_st_ret = ST_DONE else
                    "01000" when sig_st_ret = ST_I2C else
                    "01001" when sig_st_ret = ST_I2C_0 else
                    "01010" when sig_st_ret = ST_I2C_1 else
                    "01011" when sig_st_ret = ST_I2C_2 else
                    "11111";

  sig_dbg_st_prev <= "00000" when sig_st_prev = ST_IDLE else
                     "00001" when sig_st_prev = ST_START else
                     "00010" when sig_st_prev = ST_DATA  else
                     "00011" when sig_st_prev = ST_STOP else
                     "00100" when sig_st_prev = ST_DONE else
                     "01000" when sig_st_prev = ST_I2C else
                     "01001" when sig_st_prev = ST_I2C_0 else
                     "01010" when sig_st_prev = ST_I2C_1 else
                     "01011" when sig_st_prev = ST_I2C_2 else
                     "11111";

  process (pi_clock, pi_reset) is

    variable v_cnt : natural range 0 to (G_DIVIDER) / 4 - 1;

  begin

    if (pi_reset = '1') then
      v_cnt  := 0;
      sig_ce <= '0';
    elsif rising_edge(pi_clock) then
      if (v_cnt = (G_DIVIDER) / 4 - 1) then
        v_cnt  := 0;
        sig_ce <= '1';
      else
        v_cnt  := v_cnt + 1;
        sig_ce <= '0';
      end if;
    end if;

  end process;

  process (pi_clock, pi_reset) is

    variable v_cnt : natural;

  begin

    if (pi_reset = '1') then
      sig_st       <= ST_IDLE;
      sig_sda      <= '1';
      sig_scl      <= '1';
      sig_busy     <= '0';
      sig_done     <= '0';
      sig_data_dry <= '0';
    elsif rising_edge(pi_clock) then

      case sig_st is

        when ST_IDLE =>
          sig_sda      <= '1';
          sig_scl      <= '1';
          sig_busy     <= '0';
          sig_done     <= '0';
          sig_data_dry <= '0';
          if (pi_str = '1') then
            sig_st         <= ST_START;
            sig_wr         <= pi_wr;
            sig_data_width <= pi_data_width;
            sig_busy       <= '1';
            sig_rep        <= pi_rep;
            if (pi_wr = '1') then
              -- device address W/R bit data and ackonwledge bit
              case pi_data_width is

                when "00" =>
                  sig_cnt   <= to_unsigned(8 + 8 + 1, 6);
                  sig_w_buf <= pi_addr & not pi_wr & '1'
                               & pi_data(7 downto 0) & '1'
                               & X"FFFFFF" & "111";

                when "01" =>
                  sig_cnt   <= to_unsigned(8 + 16 + 2, 6);
                  sig_w_buf <= pi_addr & not pi_wr & '1'
                               & pi_data(15 downto 8) & '1'
                               & pi_data(7 downto 0) & '1'
                               & X"FFFF" & "11";

                when "10" =>
                  sig_cnt   <= to_unsigned(8 + 24 + 3, 6);
                  sig_w_buf <= pi_addr & not pi_wr & '1'
                               & pi_data(23 downto 16) & '1'
                               & pi_data(15 downto 8) & '1'
                               & pi_data(7 downto 0) & '1'
                               & X"FF" & '1';

                when others =>
                  sig_cnt   <= to_unsigned(8 + 32 + 4, 6);
                  sig_w_buf <= pi_addr & not pi_wr & '1'
                               & pi_data(31 downto 24) & '1'
                               & pi_data(23 downto 16) & '1'
                               & pi_data(15 downto 8) & '1'
                               & pi_data(7 downto 0) & '1';

              end case;

            else
              -- SDA HIGH (NACK) after last byte
              case pi_data_width is

                when "00" =>
                  sig_cnt   <= to_unsigned(8 + 8 + 1, 6);
                  sig_w_buf <= pi_addr & not pi_wr & '1'
                               & X"FF" & '1'
                               & X"FFFFFF" & "111";

                when "01" =>
                  sig_cnt   <= to_unsigned(8 + 16 + 2, 6);
                  sig_w_buf <= pi_addr & not pi_wr & '1'
                               & X"FF" & '0'
                               & X"FF" & '1'
                               & X"FFFF" & "11";

                when "10" =>
                  sig_cnt   <= to_unsigned(8 + 24 + 3, 6);
                  sig_w_buf <= pi_addr & not pi_wr & '1'
                               & X"FF" & '0'
                               & X"FF" & '0'
                               & X"FF" & '1'
                               & X"FF" & '1';

                when others =>
                  sig_cnt   <= to_unsigned(8 + 32 + 4, 6);
                  sig_w_buf <= pi_addr & not pi_wr & '1'
                               & X"FF" & '0'
                               & X"FF" & '0'
                               & X"FF" & '0'
                               & X"FF" & '1';

              end case;

            end if;
          end if;

        when ST_START =>
          sig_sda_w  <= "1100";
          sig_scl_w  <= "1110";
          sig_st     <= ST_I2C;
          sig_st_ret <= ST_DATA;

        when ST_DATA =>
          sig_sda_w <= (others => sig_w_buf(sig_w_buf'left));
          sig_scl_w <= "0110";
          sig_st    <= ST_I2C;
          if (sig_cnt = 0) then
            sig_st_ret <= ST_STOP;
          else
            sig_st_ret <= ST_DATA;
            sig_cnt    <= sig_cnt - 1;
            sig_w_buf  <= sig_w_buf(sig_w_buf'left-1 downto 0) & '0';
          end if;

        when ST_STOP =>
          if (sig_rep = '0') then         --! send stop bit
            sig_sda_w <= "0011";
          else
            sig_sda_w <= "1111";          --! don't send stop (repeated start)
          end if;
          sig_scl_w  <= "0111";
          sig_st     <= ST_I2C;
          sig_st_ret <= ST_DONE;

        when ST_DONE =>
          sig_st   <= ST_IDLE;
          sig_done <= '1';
          sig_busy <= '0';

          if (sig_wr = '0') then          -- there was a read request
            sig_data_dry <= '1';
            -- decode read data stream
            case sig_data_width is

              when "00" =>
                -- ignore ack and stop bits
                sig_output_data <= X"000000" & sig_r_buf(9 downto 2);

              when "01" =>
                sig_output_data <= X"0000" & sig_r_buf(18 downto 11) & sig_r_buf(9 downto 2);

              when "10" =>
                sig_output_data <= X"00" & sig_r_buf(27 downto 20) & sig_r_buf(18 downto 11) & sig_r_buf(9 downto 2);

              when others =>
                sig_output_data <= sig_r_buf(36 downto 29) & sig_r_buf(27 downto 20)
                                   & sig_r_buf(18 downto 11) & sig_r_buf(9 downto 2);

            end case;

          end if;

        -- single bit transaction on the I2C bus
        when ST_I2C =>
          if (sig_ce = '1') then
            sig_sda <= sig_sda_w(3);
            sig_scl <= sig_scl_w(3);
            sig_st  <= ST_I2C_0;
          end if;

        when ST_I2C_0 =>
          if (sig_ce = '1') then
            sig_sda <= sig_sda_w(2);
            sig_scl <= sig_scl_w(2);
            sig_st  <= ST_I2C_1;
          end if;

        when ST_I2C_1 =>
          if (sig_ce = '1') then
            sig_sda <= sig_sda_w(1);
            sig_scl <= sig_scl_w(1);
            sig_st  <= ST_I2C_2;
          end if;

        when ST_I2C_2 =>
          if (sig_ce = '1') then
            sig_sda   <= sig_sda_w(0);
            sig_scl   <= sig_scl_w(0);
            sig_r_buf <= sig_r_buf(sig_r_buf'left-1 downto 0) & sig_sdi;
            sig_st    <= sig_st_ret;
          end if;

        when others =>
          sig_st <= ST_IDLE;

      end case;

      -- for debug
      sig_st_changed <= '0';
      if (sig_st_prev /= sig_st) then
        sig_st_changed <= '1';
      end if;
      sig_st_prev <= sig_st;
    end if;

  end process;

end architecture rtl;
