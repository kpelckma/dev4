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
--! @created 2022-06-21
--! @author  Cagil Gumus <cagil.guemues@desy.de>
-------------------------------------------------------------------------------
--! @description
--! AD79XX Module w/ 3-wire SPI Interface
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;

entity ad79xx is
generic(
  G_CLK_DIV : natural := 50  -- Clock division for SPI Communication
);
port(
  pi_clock      : in std_logic;
  pi_reset      : in std_logic;
  po_data       : out std_logic_vector(11 downto 0); -- Data from ADC
  pi_start_conv : in std_logic; -- Start conversion flag (Active high)

  -- SPI Interface
  po_sclk      : out std_logic;
  pi_sdata     : in  std_logic;
  po_cs_n      : out std_logic
);
end ad79xx;

architecture Behavioral of ad79xx is

  -- Define type for FSM State Signal
  type state_type is (IDLE, RECEIVING);
  -- Signal for FSM that uses STATE_TYPE
  signal state : state_type;

  -- Data to be received (always 16 bits, regardless of AD79xx type)
  -- AD7920 => '0000' & 12 bits ADC Data
  -- AD7910 => '0000' & 10 bits ADC Data & '00'
  signal rx_data    : std_logic_vector(15 downto 0) := (others => '0');
  signal tx_data    : std_logic_vector(15 downto 0) := (others => '0');
  signal busy       : std_logic;
  signal done       : std_logic;
  -- Start flag for SPI Master
  signal start      : std_logic;

begin

 process(pi_clock, pi_reset)
  begin
    if(pi_reset = '1') then
      state <=  IDLE;
      start <= '0';
      po_data  <= (others => '0');
    elsif (rising_edge(pi_clock)) then
      case(state) is
        when IDLE =>
          start   <= '0';
          if (pi_start_conv = '1' and busy = '0') then
            state <= RECEIVING;
            start <= '1';
          end if;
        when RECEIVING =>
          if (done = '1') then
            state <= IDLE;
            po_data  <= rx_data(11 downto 0); -- Discard the MSB 4 bits
                                              -- Since they are zeros
                                              -- AD7910 puts 2 zeros at LSB 2 bits
          end if;

        when others =>
          state <= IDLE;

      end case;
    end if;
  end process;

  ins_spi_3w: entity desy.spi_3w
    generic map (
      G_CPHA                 => 0,
      G_CPOL                 => 1,
      G_READ_ON_FALLING_EDGE => 0,
      G_SPI_CYCLES           => 16,
      G_SPI_DATA_OUT_WIDTH   => 16,
      G_SPI_DATA_IN_WIDTH    => 16,
      G_CLK_DIV_ENA          => 1,
      G_CLK_DIV              => G_CLK_DIV
    )
    port map(
      pi_clock  => pi_clock,
      pi_reset  => pi_reset,
      pi_strobe => start,    -- Go Flag (should come from II)
      pi_rnw    => '1',      -- 0 => Write, 1=> Read
      pi_data   => tx_data,  -- Data to be send (Not used)
      po_data   => rx_data,  -- Received Data
      po_done   => done,     -- Done Flag
      po_busy   => busy,
      po_sclk   => po_sclk,
      po_cs_n   => po_cs_n,  -- Chip Select (CS)
      po_sdio_t => open,     -- Transfer Flag ? (Not used)
      po_sdio_o => open,     -- MOSI (Not used)
      pi_sdio_i => pi_sdata  -- MISO
    );

end Behavioral;

