--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2013 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2023-02-02
--! @author
--! Holger Kay <holger.kay@desy.de>
--------------------------------------------------------------------------------
--! @brief SPI subordinate IF manages IIBUS register access
--! SPI Input is driver: writes to IIBUS and reads from IIBUS
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.bus_ii.all;
--------------------------------------------------------------------------------

entity ii_ov_spi_s is
  generic (
    G_TIMEOUT   : natural := 256
  );
  port (
    pi_reset       : in    std_logic;
    -- Manager internal interface bus
    po_ibus        : out   t_ibus_o;
    pi_ibus        : in    t_ibus_i;
     -- SPI Subordinate Interface
     pi_s_sclk     : in    std_logic ; -- serial clock
     pi_s_cs_n     : in    std_logic ;  -- chip select low activ
     pi_s_mosi     : in    std_logic ; -- serial data input
     po_s_miso     : out   std_logic   -- serial data output
  );
end entity ii_ov_spi_s;

--------------------------------------------------------------------------------

architecture rtl of ii_ov_spi_s is

  -- preserve synthesis optimization which brakes handshaking functionality
  attribute keep_hierarchy : string;
  attribute keep_hierarchy of ii_ov_spi_s : entity is "YES";

  type t_state is (
    ST_IDLE,
    ST_GET_MOSI,
    ST_WAIT_WRITE_RESP,
    ST_SHIFT,
    ST_READ_DATA
  );

  signal state               : t_state := ST_IDLE;

  signal timeout              : natural := 0;
  signal receive_clk_cyc      : natural := 0;
  signal transmit_clk_cyc     : natural := 0;

  constant C_REG_SHIFT_WIDTH : natural                                      := 64; --32 addr + 32 data stream
  signal   spi_reg_shift_out : std_logic_vector(32 downto 0)                := (others => '0'); -- +1 bit r/w ack
  signal   spi_reg_shift_in  : std_logic_vector(C_REG_SHIFT_WIDTH downto 0) := (others => '0'); -- +1 bit for r/w detect

  signal read_not_write      : std_logic := '0';

  signal ibus_addr            : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal ibus_w_data          : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal ibus_wena            : std_logic := '0';
  signal ibus_wack            : std_logic := '0';
  signal ibus_r_data          : std_logic_vector(32 - 1 downto 0) := (others => '0');
  signal ibus_rena            : std_logic := '0';
  signal ibus_rack            : std_logic := '0';

  signal miso                : std_logic := '0';
  signal cs_n                : std_logic := '1';

begin
  ------------------------------------------------------------------------------
  -- II clock domain
  ------------------------------------------------------------------------------  
  po_ibus.clk <= pi_ibus.clk;
  
  prs_ii_sync : process (pi_ibus.clk)
    begin
      if rising_edge(pi_ibus.clk) then
        ibus_wack   <= pi_ibus.wack;
        ibus_rack   <= pi_ibus.rack;
        ibus_r_data <= pi_ibus.data;
        
        po_ibus.data  <= ibus_w_data;
        po_ibus.addr  <= ibus_addr;
        po_ibus.wena  <= ibus_wena;
        po_ibus.rena  <= ibus_rena;
      end if;
    end process;
  ------------------------------------------------------------------------------
  -- SPI clock domain
  ------------------------------------------------------------------------------
    po_s_miso <= miso when rising_edge(pi_s_sclk);
  
    prs_rnw: process(pi_s_cs_n)
    begin 
      if falling_edge(pi_s_cs_n) then
        read_not_write <= pi_s_mosi;

      else 
        read_not_write <= '0';

      end if;
    end process;

    prs_clear_shift: process(pi_s_sclk, pi_s_cs_n)
    begin
      if (pi_s_cs_n = '1') then
        spi_reg_shift_in  <= (others => '0');
      else 
        spi_reg_shift_in  <= spi_reg_shift_in(C_REG_SHIFT_WIDTH - 1 downto 0) & pi_s_mosi when rising_edge(pi_s_sclk);

      end if;
    end process;
  ------------------------------------------------------------------------------
  -- FSM SPI Subordinate
  ------------------------------------------------------------------------------
    prs_fsm : process (pi_s_sclk, pi_s_cs_n) is
      begin
          
        if falling_edge(pi_s_cs_n) then
          state          <= ST_GET_MOSI;
        end if;
    
          if rising_edge(pi_s_sclk) then
          case state is
            when ST_IDLE =>
              timeout           <= 0;
              miso              <= '0';
              spi_reg_shift_out <= (others => '0');
              ibus_w_data       <= (others => '0');
              ibus_addr         <= (others => '0');
              ibus_wena         <= '0';
              ibus_rena         <= '0';
              miso              <= '0';
              timeout           <= 0;
    
            -------------------------------------
            when ST_GET_MOSI =>
              receive_clk_cyc <= receive_clk_cyc + 1;
              if (read_not_write = '1') then          -- get only read address
                if (receive_clk_cyc > 32) then
                  ibus_rena         <= '1';
                  ibus_addr         <= spi_reg_shift_in(30 downto 0) & pi_s_mosi;
                  state             <= ST_READ_DATA;
                  receive_clk_cyc   <= 0;

                end if;
              else                                    -- get write address and data
                if (receive_clk_cyc > C_REG_SHIFT_WIDTH) then
                  ibus_wena         <= '1';
                  ibus_addr         <= spi_reg_shift_in(C_REG_SHIFT_WIDTH-2 downto 31);
                  ibus_w_data       <= spi_reg_shift_in(30 downto 0) & pi_s_mosi;
    
                  state             <= ST_WAIT_WRITE_RESP;
                  receive_clk_cyc   <= 0;
                end if;

              end if;

            -------------------------------------
            when ST_WAIT_WRITE_RESP =>
              spi_reg_shift_out(32) <= '1';
                if (ibus_wack = '1') then
                  ibus_wena                           <= '0';
                  spi_reg_shift_out(32 - 1 downto 0)  <= ibus_addr;
                  state                               <= ST_SHIFT;

                elsif (timeout >= G_TIMEOUT) then
                  spi_reg_shift_out(32 - 1 downto 0)  <= (others => '1');
                  state                               <= ST_SHIFT;

                end if;

              timeout <= timeout + 1;

            -------------------------------------
            when ST_READ_DATA =>
              spi_reg_shift_out(32) <= '1';
                if (ibus_rack = '1') then
                  ibus_rena                           <= '0';
                  spi_reg_shift_out(32 - 1 downto 0)  <= ibus_r_data;
                  state                               <= ST_SHIFT;

                elsif (timeout >= G_TIMEOUT) then
                  spi_reg_shift_out(32 - 1 downto 0)  <= (others => '1');
                  state                               <= ST_SHIFT;

                end if;

              timeout <= timeout + 1;

            -------------------------------------
            when ST_SHIFT =>
              miso              <= spi_reg_shift_out(32);
              spi_reg_shift_out <= spi_reg_shift_out(32-1 downto 0) & '0';
              ibus_wena         <= '0';
              ibus_rena         <= '0';

              if (read_not_write = '1') then          -- get only read address
                if (transmit_clk_cyc > 32) then
                  state             <= ST_IDLE;
                  transmit_clk_cyc  <= 0;

                end if;

                transmit_clk_cyc <= transmit_clk_cyc + 1;

              else
                state <= ST_IDLE;

              end if;

            -------------------------------------
            when others =>
              state <= ST_IDLE;
            
          end case;

        end if;

  end process prs_fsm;

end architecture rtl;
