-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( m | s | k )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--! @file   dac_ltc2758.vhd
--! @brief  SPI module for ltc2758 dac
--! @author Cagil Gumus
--! @email  cagil.guemues@desy.de
--! $date: 2017-06-13 15:15:21 +0200 (di, 13 jun 2017) $
--! $revision: 2007 $
--! $url: https://mskllrfredminesrv.desy.de/svn/utca_firmware_framework/trunk/modules/rtm/pzt4/hdl/ent_dac_spi.vhd $
--! Data is latched at the rising edge of SCK on the DAC side
--!
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac_ltc2758 is
  generic (
    G_ARCH     : string  := "";        -- Choose ODDR Type (for SPARTAN6 -> ODDR2  others -> ODDR)
    G_CLK_FREQ : natural := 31_250_000 --! frequency of the main clock (pi_clock)
  );
  port (
    pi_clock         : in    std_logic;                     -- This clock is forwarded to DAC as SCK
    pi_reset         : in    std_logic;
    --! User Interface
    po_busy          : out   std_logic;
    po_done          : out   std_logic;
    pi_data_strobe   : in    std_logic;
    pi_data          : in    std_logic_vector(17 downto 0);
    pi_command       : in    std_logic_vector(3 downto 0);  --! Write/Configure/Update etc.
    pi_address       : in    std_logic_vector(3 downto 0);  --! Choose DACA or DACB or both
    pi_span          : in    std_logic_vector(2 downto 0);  --! Span Codes
    pi_mode          : in    std_logic;                     --! 0 -> Send DAC Value 1-> Configuration Mode
    po_readback_data : out   std_logic_vector(31 downto 0); --! Readback from the IC
    -- SPI Interface
    pi_spi_sro       : in    std_logic;
    po_spi_sdi       : out   std_logic;
    po_spi_ldac      : out   std_logic;
    po_spi_cs_n      : out   std_logic;
    po_spi_sck       : out   std_logic
  );
end entity dac_ltc2758;

architecture behavioral of dac_ltc2758 is

  --! Address Codes: (Choose which DAC should execute the command)
  -- pi_address -> '000x' -> DAC_A
  --            -> '001x' -> DAC_B
  --            -> '111x' -> All DACs
  --! Span Codes (Used with SPI interface Softspan Mode) each channel can have different spans
  -- pi_span -> '000' Unipolar   0V to 5V
  --         -> '001' Unipolar   0V to 10V
  --         -> '010' Bipolar   -5V to 5V
  --         -> '011' Bipolar  -10V to 10V
  --         -> '100' Bipolar -2.5V to 2.5V
  --         -> '101' Bipolar -2.5V to 7.5V
  --! Command Codes (there are more but we wont be needing them just read the datasheet)
  -- pi_command -> '0010' Write Span for given DAC channel
  --            -> '0011' Write Code for ''   ''   ''
  --            -> '0100' Update DAC for ''   ''   ''
  --            -> '0101' Update all DAC channels
  --            -> '

  constant C_MAX_SPI_FREQ : natural := 40_000_000;         -- in Hz

  type t_state_type is (ST_IDLE, ST_TRANSACTION);

  signal state            : t_state_type;
  signal valid_data       : std_logic_vector(31 downto 0); --! What goes to DAC
  signal data_out         : std_logic_vector(31 downto 0); --! What comes from DAC
  signal spi_done         : std_logic;
  signal spi_start        : std_logic;
  signal spi_busy         : std_logic;

begin

  assert G_CLK_FREQ < C_MAX_SPI_FREQ
    report "LTC2758 exceeded its maximum SPI clock frequency"
    severity error;

  --! Port connections
  po_spi_ldac <= '1';      --! Asynchronous update pin (Not used)
  po_busy     <= spi_busy; --! SPI Busy signal going out
  po_done     <= spi_done;

  prs_latch_data : process (pi_clock) is --! Data latched when valid and constructed for SPI transaction
  begin                           --! What to send to data changes according to pi_mode (send data or send config)

    if rising_edge(pi_clock) then
      if (pi_data_strobe = '1') then
        if (pi_mode = '0') then --! Update DAC output value
          valid_data <= pi_command & pi_address & pi_data & "000000";
        else                    --! Change span value using SPI
          -- "...when writing span code it should occupy the last 4 bits of the second data byte"
          valid_data <= pi_command & pi_address & x"00" & x"0" & '0' & pi_span & x"00";
        end if;
      end if;
    end if;

  end process prs_latch_data;

  --! Main FSM

  prs_fsm : process (pi_clock) is
  begin

    if rising_edge(pi_clock) then
      if (pi_reset = '1') then
        state            <= ST_IDLE;
        spi_start        <= '0';
        po_readback_data <= (others => '0');
      else

        case state is

          when ST_IDLE =>
            spi_start <= '0';
            if (pi_data_strobe = '1' and spi_busy = '0') then -- Start when strobe comes + spi not busy
              state     <= ST_TRANSACTION;
              spi_start <= '1';                               -- Signal to SPI to start for 1 clk cycle
            end if;

          when ST_TRANSACTION =>
            spi_start <= '0';
            if (spi_done = '1') then
              state            <= ST_IDLE;
              po_readback_data <= data_out;
            end if;

        end case;

      end if;
    end if;

  end process prs_fsm;

  ins_spi_4w : entity work.spi_4w
    generic map (
      G_CPHA                 => 0,
      G_CPOL                 => 0,
      G_READ_ON_FALLING_EDGE => 0,
      G_SPI_CYCLES           => 32,
      G_SPI_DATA_OUT_WIDTH   => 32,
      G_SPI_DATA_IN_WIDTH    => 32,
      G_CLK_DIV_ENA          => 0,
      G_CLK_DIV              => 0,
      G_USE_ODDR             => 1,
      G_ARCH                 => G_ARCH
    )
    port map (
      pi_clock   => pi_clock,
      pi_reset => pi_reset,

      pi_str  => spi_start,
      pi_data => valid_data,
      po_data => data_out,
      po_done => spi_done,
      po_busy => spi_busy,

      -- SPI Interface going outside
      po_sclk => po_spi_sck,
      po_mosi => po_spi_sdi,
      pi_miso => pi_spi_sro,
      po_cs_n => po_spi_cs_n
    );

end architecture behavioral;
