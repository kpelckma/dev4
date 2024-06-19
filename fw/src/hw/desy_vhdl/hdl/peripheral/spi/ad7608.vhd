------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
-- @copyright Copyright 2021 DESY
-- SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
-- @date 2021-09-14
-- @author Cagil Gumus  <cagil.guemues@desy.de>
-- @brief   AD7608 ADC component
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library desy;
use desy.common_types.all;

library UNISIM;
use UNISIM.VComponents.all;

entity ad7608 is
generic (
  G_ARCH : string := ""; -- Choose FPGA Architechture (SPARTAN6,VIRTEX5 etc) for ODDR type
  G_CLK_FREQ: natural := 15_625_000 -- pi_clock freq in Hz
);
port (
pi_clock : in std_logic; -- Main clock used inside the module
pi_reset : in std_logic; -- Main reset

pi_start : in std_logic; -- Start conversion flag
po_busy  : out std_logic; -- Busy flag for user
po_data_vld : out std_logic;
po_data_a  : out t_18b_slv_vector(3 downto 0);
po_data_b  : out t_18b_slv_vector(3 downto 0);

-- SPI Interface
pi_douta : in std_logic;
pi_doutb : in std_logic;
pi_busy  : in std_logic;
po_sclk  : out std_logic;
po_cs_n  : out std_logic;
-- Conversion start pin
po_cnvst : out std_logic;
po_reset : out std_logic;
po_error : out std_logic_vector(31 downto 0)
);
end ad7608;

architecture arch of ad7608 is

  constant C_CONVERSION_DURATION : natural := (G_CLK_FREQ/1000000)*4; -- 4 us is typical conv duration
  constant C_RESET_HIGH_DURATION : natural := 5; -- 100 ns min reset high duration so we wait for 3 clk cycles
  constant C_MAX_SPI_FREQ : natural := 23_500_000; -- in Hz
  constant C_SPI_DATA_CNT : natural := 72; -- Amount of bits to get from SPI slave(72 bits)

  type t_main_state_type is (ST_IDLE, ST_WAIT_CONVERSION, ST_CHECK_BUSY, ST_READ_DATA, ST_ERROR);
  signal main_state : t_main_state_type;
  type t_spi_state_type is (ST_IDLE, ST_DEASSERT_CS, ST_DEASSERT_CS2, ST_TRANSACTION);
  signal spi_state : t_spi_state_type;

  signal gated_clk         : std_logic;
  signal cs_n              : std_logic;
  signal data_a            : t_18b_slv_vector(3 downto 0);
  signal data_b            : t_18b_slv_vector(3 downto 0);
  signal spi_start         : std_logic; -- Start flag for SPI FSM
  signal spi_done          : std_logic; -- Done indicator coming from SPI FSM
  signal conversion_timer  : natural := C_CONVERSION_DURATION;
  signal reset_hold_cnt    : natural; -- Counter for reset holding
  signal dout_a            : std_logic_vector(71 downto 0); -- Registered data from AD7608(DoutA)
  signal dout_b            : std_logic_vector(71 downto 0);  -- Registered data from AD7608(DoutB)
  signal spi_transaction   : std_logic; -- Use to indicate SPI transaction is ongoing
  signal spi_transaction_n : std_logic;
  signal start_sampling    : std_logic;
  signal transaction_cnt   : natural; -- Counter for incoming SPI bits
  signal busy_q            : std_logic;
  signal busy_qq           : std_logic;
  signal busy_qq_last      : std_logic;
  signal busy_rising       : std_logic;
  signal adc_responsive    : std_logic; -- If busy doesnt toggle, ADC is unresponsive
  signal error_cnt         : std_logic_vector(31 downto 0);
  signal inverted_clk      : std_logic;

  signal reset_for_adc : std_logic; -- Reset going to ADC (must be min 100ns high)

  component ODDRE1
  generic(
    SRVAL : bit
  );
  port(
    C  : in  std_logic;
    D1 : in  std_logic;
    D2 : in  std_logic;
    Q  : out std_logic;
    SR : in  std_logic
  );
  end component;

  attribute IOB : string;
  attribute DONT_TOUCH : string;
  attribute async_reg : string;
  attribute equivalent_register_removal : string;

  attribute async_reg of busy_q  : signal is "TRUE";
  attribute async_reg of busy_qq : signal is "TRUE";

  attribute DONT_TOUCH of cs_n     : signal is "TRUE";
  attribute DONT_TOUCH of spi_done : signal is "TRUE";
  attribute DONT_TOUCH of dout_a   : signal is "TRUE";
  attribute DONT_TOUCH of dout_b   : signal is "TRUE";

  attribute equivalent_register_removal of spi_done : signal is "NO";
  attribute equivalent_register_removal of cs_n     : signal is "NO";

  attribute IOB of cs_n    : signal is "FORCE";
  attribute IOB of po_sclk : signal is "FORCE";

begin

  assert G_CLK_FREQ < C_MAX_SPI_FREQ report "AD7604 exceeded its maximum SPI clock frequency"
  severity error;


  inverted_clk <= not pi_clock;
  spi_transaction_n <= spi_transaction;

  -- Port connections
  po_error <= error_cnt;
  po_reset <= reset_for_adc;
  po_cs_n <= cs_n;


  gen_adc_oddr2 : if G_ARCH = "SPARTAN6" generate
    ins_adc_clk_oddr : oddr2
    generic map(
      ddr_alignment => "NONE",
      init          => '1',
      srtype        => "SYNC"
    )
    port map(
      q  => po_sclk,             -- 1-bit output data
      C0 => pi_clock,            -- 1-bit clock input
      C1 => inverted_clk,        -- 1-bit clock input
      CE => spi_transaction,     -- 1-bit clock enable input
      D0 => '1',                 -- 1-bit data input (associated with C0)
      D1 => '0',                 -- 1-bit data input (associated with C1)
      R  => '0',                 -- 1-bit reset input
      S  => spi_transaction_n    -- 1-bit set input
    );
  end generate;

  gen_adc_oddr : if G_ARCH /= "SPARTAN6" and G_ARCH /= "ULTRASCALE" generate
    ins_adc_clk_oddr : oddr
    generic map (
      ddr_clk_edge => "SAME_EDGE",      -- w/ same_edge we have better setup time and we save resources
      init         => '1',              -- initial value for q port ('1' or '0')
      srtype       => "SYNC")           -- reset type ("async" or "sync")
    port map (
      q  => po_sclk,
      c  => pi_clock,             -- 1-bit clock input
      ce => spi_transaction,      -- 1-bit clock enable input
      d1 => '1',                  -- 1-bit data input (positive edge)
      d2 => '0',                  -- 1-bit data input (negative edge)
      r  => '0',                  -- 1-bit reset input
      s  => spi_transaction_n     -- 1-bit set input
    );
  end generate;

  gen_adc_oddr_US : if G_ARCH = "ULTRASCALE" generate
  ins_adc_clk_oddr : oddre1
  generic map (
    SRVAL => '1'
  )
  port map (
    q  => po_sclk,   -- 1-bit clock output
    c  => gated_clk, -- 1-bit clock input
    d1 => '0',       -- 1-bit data input (positive edge)
    d2 => '1',       -- 1-bit data input (negative edge)
    sr => '0'        -- 1-bit set input
  );

  ins_bufgce: BUFGCE -- ODDRE1 does not have CE input
  port map(
    CE => spi_transaction,
    I  => inverted_clk,
    O  => gated_clk
  );

  end generate;

  -- Improving Metastability
  -- BUSY signal is asynchronous
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      busy_q <= pi_busy;
      busy_qq <= busy_q;
      busy_qq_last <= busy_qq;
      if busy_qq_last = '0' and busy_qq = '1' then -- rising edge detections
        busy_rising <= '1';
      else
        busy_rising <= '0';
      end if;
    end if;
  end process;


  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        reset_for_adc <= '1';
        reset_hold_cnt <= 0;
      else
        reset_hold_cnt <= reset_hold_cnt + 1;
        if reset_hold_cnt = C_RESET_HIGH_DURATION then
          reset_for_adc <= '0';
        end if;
      end if;
    end if;
  end process;


    -- Main FSM
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if reset_for_adc = '1' then
        main_state <= ST_IDLE;
        po_cnvst <= '1';
		  error_cnt <= (others => '0');
		  adc_responsive <= '0';
        spi_start <= '0';
        po_busy <= '0';
        po_data_vld <= '0';
      else
        po_data_vld <= '0';
        case main_state is

          when ST_IDLE =>
				adc_responsive <= '0';
            spi_start <= '0';
            po_cnvst <= '1';
            po_busy <= '0';
            conversion_timer <= C_CONVERSION_DURATION;
            if pi_start = '1' and spi_transaction = '0' then -- Start when valid data comes + spi not busy
              main_state <= ST_WAIT_CONVERSION;
              po_cnvst <= '0'; -- Deassert CNVST to start conversion for 1 clk cycle
            end if;

          when ST_WAIT_CONVERSION => -- Takes about 4us
            po_busy <= '1';
            po_cnvst <= '1'; -- Assert CNVST again.
            if conversion_timer = 0 then
				  if adc_responsive = '1' then -- If ADC didn't assert BUSY, it means ADC is rip.
				    main_state <= ST_CHECK_BUSY;
				  else
				    main_state <= ST_ERROR;
				  end if;
            else
              conversion_timer <= conversion_timer -1;
				  if busy_rising  = '1' then -- If during this time BUSY does not go to high, we have a problem
				    adc_responsive <= '1';
				  end if;
            end if;

          when ST_CHECK_BUSY => -- We waited long enough
            po_cnvst <= '1'; -- Assert CNVST back again.
            if busy_qq = '0' then
               main_state <= ST_READ_DATA;
               spi_start <= '1';
            end if;

          when ST_READ_DATA =>
            spi_start <= '0';
            if spi_done = '1' then
              main_state <= ST_IDLE;
              po_data_vld <= '1';
              po_data_a <= data_a;
              po_data_b <= data_b;
              po_busy <= '0';
            end if;

		     when ST_ERROR =>
			    error_cnt <= std_logic_vector(unsigned(error_cnt)+1);
				 main_state <= ST_IDLE; -- Go back to IDLE after reporting error

        end case;
      end if;
    end if;
  end process;


  -- SPI Transaction FSM
  process(pi_clock, pi_reset)
  begin
    if pi_reset = '1' then
      spi_state <= ST_IDLE;
      spi_transaction <= '0';
      transaction_cnt <= 0;
      cs_n <= '1';
      data_a <= (others =>(others=>'0'));
      data_b <= (others =>(others=>'0'));
      spi_done <= '0';
      start_sampling <= '0';
    else
      if rising_edge(pi_clock) then
        case spi_state is

          when ST_IDLE =>
            cs_n <= '1';
            transaction_cnt <= 0;
            spi_done <= '0';
            spi_transaction <= '0';
            start_sampling <= '0';
            if spi_start = '1' then
              spi_state <= ST_DEASSERT_CS;
            end if;

          when ST_DEASSERT_CS =>
            cs_n <= '0';
            spi_done <= '0';
            spi_transaction <= '1'; -- Enable clock out
            if G_ARCH /= "ULTRASCALE" then
              spi_state <= ST_DEASSERT_CS2; -- If not US, we need to add 1 clock delay to match
            else
              spi_state <= ST_TRANSACTION;
            end if;

          when ST_DEASSERT_CS2 => -- Dummy state to wait until clock is aligned with the incoming data
            spi_done <= '0';
            cs_n <= '0';
            spi_state <= ST_TRANSACTION; -- Create addiotinal delay between spi clock enable and sampling

          when ST_TRANSACTION =>
            if transaction_cnt = C_SPI_DATA_CNT then
              for i in 0 to 3 loop
                data_a(i) <= dout_a((4-i)*18 -1 downto (3-i)*18); -- Demux data
                data_b(i) <= dout_b((4-i)*18 -1 downto (3-i)*18); -- Present to user in a better way
              end loop;
              spi_done <= '1';
              cs_n <= '1';
              spi_state <= ST_IDLE;
            else
              cs_n <= '0';
              transaction_cnt <= transaction_cnt +1;
              dout_a(0) <= pi_douta;
              dout_b(0) <= pi_doutb;
              dout_a(dout_a'left downto 1) <= dout_a(dout_a'left-1 downto 0); -- Shift left
              dout_b(dout_b'left downto 1) <= dout_b(dout_b'left-1 downto 0); -- MSB comes first
            end if;

        end case;
      end if;
    end if;
  end process;

end arch;
