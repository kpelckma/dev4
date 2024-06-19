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
--! @date 2018-10-25
--! @author Dariusz Makowski
--! @author Grzegorz Jablonski
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--!  Handles the SPI communication to FLASH + DPM memory to hold
------------------------------------------------------------------------------

library ieee;
library desy;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fpga_spi_programmer is
  port(
    pi_clock        : in  std_logic;   --! Clock input
    pi_reset        : in  std_logic;   --! global reset port

    pi_spi_sdi      : in  std_logic;   --! SPI Connections
    po_spi_sdo      : out std_logic;
    po_spi_cs_n     : out std_logic;
    po_spi_clk      : out std_logic;

    pi_control_rdy       : in std_logic;                     --! Control data ready
    pi_control_data_in   : in std_logic_vector(7 downto 0);  --! Control Data in
    po_control_data_out  : out std_logic_vector(7 downto 0); --! Control Data out
    po_control_data_we   : out std_logic;                    --! Control Data WE

    pi_dpm_wr_en    : in std_logic;                     --! DPM Enable
    pi_dpm_wr_we    : in std_logic;                     --! DPM Write Enable
    pi_dpm_wr_data  : in std_logic_vector(7 downto 0);  --! DPM Data(WR DPM)
    pi_dpm_wr_addr  : in std_logic_vector(9 downto 0);  --! DPM Address
    po_dpm_wr_out   : out std_logic_vector(7 downto 0); --! WR DPM Output

    pi_dpm_rd_en   : in std_logic;                     --! DPM RD Enable
    pi_dpm_rd_addr : in std_logic_vector(9 downto 0);  --! DPM RD Address
    po_dpm_rd_out  : out std_logic_vector(7 downto 0); --! DPM RD Output

    pi_bytes_write       : in std_logic_vector(15 downto 0);
    pi_bytes_read        : in std_logic_vector(15 downto 0);

    pi_spi_clk_div       : in std_logic_vector(15 downto 0)
  );
end fpga_spi_programmer;

architecture arch of fpga_spi_programmer is

  --! SPI Communication related signals
  type   t_state is (ST_IDLE, ST_WRITING, ST_INTERMEDIATE, ST_READING, ST_DONE);
  signal state                : t_state;
  signal reg_control          : std_logic_vector(7 downto 0);
  signal int_rd_address       : integer range 0 to 1023;
  signal int_wr_address       : integer range 0 to 1023;
  signal bit_counter          : integer range 0 to 7;
  signal rd_address           : std_logic_vector(9 downto 0);
  signal wr_address           : std_logic_vector(9 downto 0);
  signal rd_byte              : std_logic_vector(7 downto 0);
  signal wr_byte              : std_logic_vector(7 downto 0);
  signal tx_ready             : std_logic;
  signal clk_cnt              : integer range 0 to 255 := 0;

  signal spi_cs_n             : std_logic;
  signal spi_clk              : std_logic;
  signal spi_sdo              : std_logic;
  signal spi_sdi              : std_logic;

begin

  --==============================================================================
  --IO Connections
  --==============================================================================
  spi_sdi       <= pi_spi_sdi when rising_edge(pi_clock); --! 1 stage synchronizer;
  po_spi_sdo    <= spi_sdo;
  po_spi_cs_n   <= spi_cs_n;
  po_spi_clk    <= spi_clk;

  po_control_data_out <= reg_control;
  --==============================================================================
  -- 2xDual Port Memory for ST_WRITING to Flash and storing from Flash
  --==============================================================================
  ins_dpm_wr : entity desy.dual_port_memory --ii wr and read, spi read
  generic map (
    g_data_width => 8,
    g_addr_width => 10
  )
  port map (
    pi_clk_a   => pi_clock,
    pi_ena_a   => pi_dpm_wr_en,
    pi_wr_a    => pi_dpm_wr_we,
    pi_addr_a  => pi_dpm_wr_addr,
    pi_data_a  => pi_dpm_wr_data,
    po_data_a  => po_dpm_wr_out,

    pi_clk_b   => pi_clock,
    pi_ena_b   => '1',
    pi_wr_b    => '0',
    pi_addr_b  => wr_address,
    pi_data_b  => x"00",
    po_data_b  => wr_byte
  );

  ins_dpm_rd : entity desy.dual_port_memory --ii rd, spi wr
  generic map (
    g_data_width => 8,
    g_addr_width => 10
  )
  port map (
    pi_clk_a   => pi_clock,
    pi_ena_a   => pi_dpm_rd_en,
    pi_wr_a    => '0', --rd only
    pi_addr_a  => pi_dpm_rd_addr,
    pi_data_a  => x"00",
    po_data_a  => po_dpm_rd_out ,

    pi_clk_b   => pi_clock,
    pi_ena_b   => '1', --wr only
    pi_wr_b    => '1',
    pi_addr_b  => rd_address,
    pi_data_b  => rd_byte,
    po_data_b  => open
  ) ;

  --! Control register handling
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      -- only write to the register when necessary
      po_control_data_we <= '0';

      if pi_control_rdy = '1' then
        reg_control <= pi_control_data_in;
      else
        if tx_ready = '1' then
          reg_control(0)     <= '0';
          po_control_data_we <= '1';
        end if;
        if reg_control(3) = '1' then
          reg_control(3)     <= '0';
          po_control_data_we <= '1';
        end if;
      end if;
    end if;
  end process;

  --============================================================================
  --! SPI Communication FSM
  --============================================================================
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        tx_ready        <= '0';
        state           <= ST_IDLE;
        clk_cnt         <= 0;
        bit_counter     <= 0;
        spi_cs_n        <= '1';
        spi_clk         <= '0';
        spi_sdo         <= '1';
        int_wr_address  <= 0;
      else

        rd_address    <= std_logic_vector(to_unsigned(int_rd_address, 10));
        wr_address    <= std_logic_vector(to_unsigned(int_wr_address, 10));

        if clk_cnt /= 0 then
          clk_cnt <= clk_cnt - 1;
        else
          clk_cnt <= to_integer(unsigned(pi_spi_clk_div)) - 1;
        end if;

        case state is

        ---------------------------------------------------
        when ST_IDLE =>
          tx_ready        <= '0';
          int_wr_address  <=  0 ;
          spi_clk         <= '1';
          spi_sdo         <= '1' ;

          if reg_control(0) = '1' and tx_ready = '0' then
            state           <= ST_WRITING;
            spi_cs_n        <= '0';
            clk_cnt         <=  0 ;
            spi_clk         <= '0';
            int_rd_address  <=  0 ;
            bit_counter     <=  7 ;
          end if;

        ---------------------------------------------------
        when ST_WRITING =>

          if clk_cnt = to_integer(unsigned(pi_spi_clk_div)) / 2 then
            spi_clk <= '1';

          elsif clk_cnt = 0 then
            spi_sdo <= wr_byte(bit_counter);
            spi_clk <= '0';
            if bit_counter = 0 then
              bit_counter <= 7;
              if int_wr_address = to_integer(unsigned(pi_bytes_write)) then
                state <= ST_INTERMEDIATE;
              else
                int_wr_address <= int_wr_address + 1;
              end if;
            else
              bit_counter <= bit_counter - 1;
            end if;
          end if;

        ---------------------------------------------------
        when ST_INTERMEDIATE =>

          if clk_cnt = to_integer(unsigned(pi_spi_clk_div)) / 2 then
            spi_clk <= '1';

          elsif clk_cnt = 0 then
            if reg_control(1) = '1' then
              spi_clk <= '0';
              state   <= ST_READING;
            else
              spi_clk   <= '1';
              spi_cs_n  <= '1';
              state     <= ST_DONE;
            end if;
          end if;

        ---------------------------------------------------
        when ST_READING =>

          if clk_cnt = to_integer(unsigned(pi_spi_clk_div)) / 2 then
            spi_clk             <= '1';
            rd_byte(bit_counter) <= spi_sdi;

          elsif clk_cnt = to_integer(unsigned(pi_spi_clk_div)) / 2 - 1 then
            if bit_counter = 0 then
              bit_counter <= 7;
              if int_rd_address = to_integer(unsigned(pi_bytes_read)) then
                state     <= ST_DONE;
                spi_cs_n  <= '1';
                spi_clk   <= '1';
              else
                int_rd_address <= int_rd_address + 1;
              end if;
            else
              bit_counter <= bit_counter - 1;
            end if;

          elsif clk_cnt = 0 then
            spi_clk <= '0';
          end if;

        ---------------------------------------------------
        when ST_DONE =>
          if clk_cnt = 0 then
            state    <= ST_IDLE;
            tx_ready <= '1';
          end if;
        ---------------------------------------------------

        end case;
      end if;
    end if;
  end process;

end arch;
