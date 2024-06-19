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
--! AD56XX DAC Module w/ SPI
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy; -- for spi_3w component

entity ad56xx is
generic(
  G_CLK_DIV       : natural := 2;   -- Clock division for SPI Communication
  G_DATA_WIDTH    : natural := 12  -- DAC bit size AD5621 => (12 bits) 
);                                 --              AD5611 => (10 bits)
                                   --              AD5601 =>  (8 bits)
port(                              
  pi_clock     : in std_logic;
  pi_reset     : in std_logic;
  
  pi_data      : in std_logic_vector(G_DATA_WIDTH-1 downto 0); -- Data to be send to DAC
  pi_data_rdy  : in std_logic; -- pi_data Ready Strobe
  
  -- SPI Interface    
  po_sclk      : out std_logic;
  po_sdin      : out std_logic;
  po_sync      : out std_logic
);
end ad56xx;

architecture Behavioral of ad56xx is

  -- Define type for FSM State Signal
  type state_type is (IDLE, SENDING); 
  -- Signal for FSM that uses state_type 
  signal state : state_type;

  -- Data to be transmitted (always 16 bits, regardless of AD56xx type)
  signal tx_data    : std_logic_vector(15 downto 0) := (others => '0');
  signal busy       : std_logic; 
  signal done       : std_logic; 
  -- Start flag for SPI Master
  signal start      : std_logic; 
  signal cs_n       : std_logic;
  
begin

  po_sync <= cs_n;

  process(pi_clock, pi_reset)
  begin 
    if(pi_reset = '1') then
      state <=  IDLE;
      start <= '0'; 
      tx_data <= (others => '0');
    elsif (rising_edge(pi_clock)) then 
      case(state) is 
        when IDLE => 
          start <= '0';
          tx_data <= (others => '0');
          if (pi_data_rdy = '1' and busy = '0') then 
            state <= SENDING;
            start <= '1';
            tx_data(15 downto 14) <= "00"; -- Configuration bits (Normal Operation)
            tx_data(13 downto 14-G_DATA_WIDTH) <= pi_data; -- 2 bits config & data &
                                                                -- rest are dontcare
          end if; 

        when SENDING =>
          if (done = '1') then 
              state <= IDLE;
            end if; 
            
        when others => 
          state <= IDLE;
          
      end case;
    end if;
  end process; 
  
  blk_spi_master: block
    begin
    
    ins_spi_3w: entity desy.spi_3w
      generic map (
        G_CPHA                 => 1,
        G_CPOL                 => 0,
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
        pi_rnw    => '0',          -- 0 => Write, 1=> Read
        pi_data   => tx_data,  -- Data to be send
        po_data   => open,         -- Received Data (Not used)
        po_done   => done,     -- Done Flag (Not used)
        po_busy   => busy,
        po_sclk   => po_sclk,
        po_cs_n   => cs_n,     -- Chip Select (CS)
        po_sdio_t => open,         -- Transfer Flag ? (Not used)
        po_sdio_o => po_sdin,     -- MOSI
        pi_sdio_i => '0'           -- MISO (Not used)
      );
    end block;
    
end Behavioral;

