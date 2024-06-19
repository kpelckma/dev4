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
-- @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
-- @brief supported clock divider, different CPHA and CPOL settings
------------------------------------------------------------------------------
-- polarization and phase settings
--           ----.                                                                         .-----
--CS             |                                                                         |
--CPOL  CPHA     `-------------------------------------------------------------------------`
--                         .---.   .---.   .---.   .---.   .---.   .---.   .---.   .---.
--   0     0               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
--           --------------`   `---`   `---`   `---`   `---`   `---`   `---`   `---`   `--------
--                     .---.   .---.   .---.   .---.   .---.   .---.   .---.   .---.
--   0     1           |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
--           ----------`   `---`   `---`   `---`   `---`   `---`   `---`   `---`   `------------
--           --------------.   .---.   .---.   .---.   .---.   .---.   .---.   .---.   .--------
--   1     0               |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
--                         `---`   `---`   `---`   `---`   `---`   `---`   `---`   `---`
--           ----------.   .---.   .---.   .---.   .---.   .---.   .---.   .---.   .------------
--   1     1           |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
--                     `---`   `---`   `---`   `---`   `---`   `---`   `---`   `---`
--           ----------.-------.-------.-------.-------.-------.-------.-------.-------.--------
--                     |  D7   |  D6   |  D5   |  D4   |  D3   |   D2  |  D1   |   D0  |
--           ----------.-------.-------.-------.-------.-------.-------.-------.-------.--------
--
--------------------------------------------------------------------------------------------------
-- TODO: support for multiple slaves needed, CS_N -> to vector, and subordinate select port
--------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity spi_4w is
  generic (
    G_CPHA                : natural  := 0  ;
    G_CPOL                : natural  := 0  ;
    G_READ_ON_FALLING_EDGE: natural  := 0  ;
    G_SPI_CYCLES          : positive := 16 ;
    G_SPI_DATA_OUT_WIDTH  : positive := 16 ;
    G_SPI_DATA_IN_WIDTH   : positive := 16 ;
    G_CLK_DIV_ENA         : natural  := 0  ;
    G_CLK_DIV             : natural  := 50 ;
    G_USE_ODDR            : natural  := 0  ;  -- use ODDR for clock out
    G_ARCH                : string   := "" -- SPARTAN6 for ODDR2 for others ODDR
  ) ;
  port (
    pi_clock   : in std_logic;
    pi_reset : in std_logic;

    pi_str  : in  std_logic ;
    pi_data : in  std_logic_vector(G_SPI_DATA_OUT_WIDTH-1  downto 0) ;
    po_data : out std_logic_vector(G_SPI_DATA_IN_WIDTH-1   downto 0) ;
    po_done : out std_logic ;

    po_busy : out std_logic;

    po_sclk : out std_logic;
    po_mosi : out std_logic;
    pi_miso : in std_logic;
    po_cs_n : out std_logic
  );
end spi_4w;

architecture Behavioral of spi_4w is

  type T_OUT_STATES is (ST_IDLE, ST_SET_CS, ST_STREAM_OUT, ST_DISABLE_CLK, ST_DONE) ;
  signal state : T_OUT_STATES ;

  signal cs_n       : std_logic := '1';
  signal mosi       : std_logic := '0' ;

  signal spi_clk    : std_logic := '0';
  signal spi_clk_n  : std_logic := '1';
  signal spi_clk_us : std_logic := '0'; -- Used in Ultrascale Arch for gated clock
  signal internal_clk    : std_logic := '0';
  signal strobe        : std_logic := '0';
  signal clk_ena    : std_logic := '0';
  signal clk_ena_n  : std_logic := '0';
  signal data_in_ena: std_logic := '0';
  signal done       : std_logic := '0';
  signal done_prev  : std_logic := '0';

  signal busy : std_logic := '0';

  signal data_out   : std_logic_vector(G_SPI_CYCLES-1 downto 0) := ( others => '0' );
  signal stream_out : std_logic_vector(G_SPI_CYCLES-1 downto 0) := ( others => '0' );
  signal stream_in  : std_logic_vector(G_SPI_CYCLES-1 downto 0) := ( others => '0' );

  attribute KEEP : string;
  attribute DONT_TOUCH : string;
  attribute EQUIVALENT_REGISTER_REMOVAL : string;

  attribute EQUIVALENT_REGISTER_REMOVAL of cs_n : signal is "NO";
  attribute DONT_TOUCH of cs_n : signal is "TRUE";

  attribute EQUIVALENT_REGISTER_REMOVAL of mosi : signal is "NO";
  attribute DONT_TOUCH of mosi : signal is "TRUE";

  attribute KEEP of spi_clk   : signal is "true";
  attribute KEEP of stream_in : signal is "true";

  attribute IOB : string;
  attribute IOB of cs_n : signal is "TRUE";
  attribute IOB of mosi : signal is "TRUE";

  component oddre1
  generic(
    srval : bit
  );
  port(
    c  : in  std_logic;
    d1 : in  std_logic;
    d2 : in  std_logic;
    q  : out std_logic;
    sr : in  std_logic
  );
  end component;

begin

  clk_ena_n <= not clk_ena;

  spi_clk_n <= spi_clk;
  -------------------------------------------------------------------
  -- clock OUT clock enable and set polarity
  gen_cpol_0: if G_CPOL = 0 generate
    g_clk_out: if G_USE_ODDR = 0 generate
      po_sclk <= not spi_clk when clk_ena = '1' else '0' ;
    end generate;

    g_clk_out_oddr: if G_USE_ODDR = 1 generate
      g_oddr2: if G_ARCH = "SPARTAN6" generate
        ins_clk_oddr : oddr2
          generic map  (
            DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1"
            INIT          => '0', -- Sets initial state of the Q output to '0' or '1'
            SRTYPE        => "ASYNC"
          ) -- Specifies "SYNC" or "ASYNC" set/reset
          port map
          (
            q  => po_sclk,        -- 1-bit output data
            c0 => spi_clk,        -- 1-bit clock input
            c1 => spi_clk_n,      -- 1-bit clock input
            ce => clk_ena,        -- 1-bit clock enable input
            d0 => '0',            -- 1-bit data input (associated with c0)
            d1 => '1',            -- 1-bit data input (associated with c1)
            r  => clk_ena_n,      -- 1-bit reset input
            s  => '0'             -- 1-bit set input
          );
      end generate;

      gen_oddr: if G_ARCH /= "SPARTAN6" and G_ARCH /= "ULTRASCALE" generate
        ins_clk_oddr : ODDR
        generic map(
          DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE"
          INIT => '1'                    ,  -- Initial value for Q port ('1' or '0')
          SRTYPE => "ASYNC")                 -- Reset Type ("ASYNC" or "SYNC")
        port map (
          q  => po_sclk,    -- 1-bit ddr output
          c  => spi_clk,    -- 1-bit clock input
          ce => clk_ena,    -- 1-bit clock enable input
          d1 => '0',        -- 1-bit data input (positive edge)
          d2 => '1',        -- 1-bit data input (negative edge)
          r  => clk_ena_n,  -- 1-bit reset input
          s  => '0'         -- 1-bit set input
        );
      end generate;

      gen_oddr_US : if g_arch = "ULTRASCALE" generate
        ins_oddr_us: oddre1
        generic map (
          SRVAL => '0')
        port map (
          q  => po_sclk,
          c  => spi_clk_us, -- 1-bit clock input
          d1 => '1',        -- 1-bit data input (positive edge)
          D2 => '0',        -- 1-bit data input (negative edge)
          sr => pi_reset    -- 1-bit set input
        );
        ins_bufgce: bufgce -- oddre1 does not have ce input
        port map(
          CE => clk_ena,
          I  => spi_clk_n,
          O  => spi_clk_us
        );
      end generate;

    end generate;
  end generate;
    -----------------------------------------------------------------
  GEN_CPOL_1: if G_CPOL = 1 generate
    G_CLK_OUT: if G_USE_ODDR = 0 generate
      po_sclk <= spi_clk when clk_ena = '1' else '1' ;
    end generate;

    g_clk_out_oddr: if G_USE_ODDR = 1 generate
      gen_oddr2: if G_ARCH = "SPARTAN6" generate
        ins_clk_oddr : oddr2
          generic map  (
            DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1"
            INIT          => '1',    -- Sets initial state of the Q output to '0' or '1'
            SRTYPE        => "ASYNC" -- Specifies "SYNC" or "ASYNC" set/reset
          )
          port map
          (
            q  => po_sclk,        -- 1-bit output data
            c0 => spi_clk,        -- 1-bit clock input
            c1 => spi_clk_n,      -- 1-bit clock input
            ce => clk_ena,        -- 1-bit clock enable input
            d0 => '1',            -- 1-bit data input (associated with c0)
            d1 => '0',            -- 1-bit data input (associated with c1)
            r  => '0',            -- 1-bit reset input
            s  => clk_ena_n       -- 1-bit set input
          );
      end generate;

      gen_oddr: if G_ARCH /= "SPARTAN6" and G_ARCH /= "ULTRASCALE" generate
        ins_oddr : oddr
        generic map(
          DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE"
          INIT => '1',                      -- Initial value for Q port ('1' or '0')
          SRTYPE => "ASYNC")                -- Reset Type ("ASYNC" or "SYNC")
        port map (
          q  => po_sclk,   -- 1-bit ddr output
          c  => spi_clk,   -- 1-bit clock input
          ce => clk_ena,   -- 1-bit clock enable input
          d1 => '1',       -- 1-bit data input (positive edge)
          d2 => '0',       -- 1-bit data input (negative edge)
          r  => '0',       -- 1-bit reset input
          s  => clk_ena_n  -- 1-bit set input
        );
      end generate;

      gen_oddr_US : if g_arch = "ULTRASCALE" generate
        ins_oddr_us: ODDRE1
        generic map (
          SRVAL => '1')
        port map (
          q  => po_sclk,
          c  => spi_clk_us, -- 1-bit clock input
          d1 => '0',        -- 1-bit data input (positive edge)
          D2 => '1',        -- 1-bit data input (negative edge)
          sr => pi_reset    -- 1-bit set input
        );
        ins_bufgce: BUFGCE  -- ODDRE1 does not have CE input
        port map(
          CE => clk_ena,
          I  => spi_clk,
          O  => spi_clk_us
        );
      end generate;

    end generate;
  end generate;

  -------------------------------------------------------------------
  -- clock divider
  gen_div_clk: if G_CLK_DIV_ENA = 1 generate
  begin
    process(pi_clock)
      variable v_cnt  : natural;
    begin
      if rising_edge(pi_clock) then
        if v_cnt < (G_CLK_DIV-1) / 2 then
          v_cnt := v_cnt + 1;
        else
          v_cnt        := 0;
        spi_clk <= not spi_clk;
        end if;
      end if;
    end process;
  end generate;

  gen_no_div_clk: if G_CLK_DIV_ENA = 0 generate
    spi_clk <= pi_clock ;
  end generate;

  -------------------------------------------------------------------
  -- synch to input clock and latch data
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        busy <= '0';
        po_done <= '0';
      else
        if done = '1' then
          strobe <= '0';
        elsif pi_str = '1' and busy = '0' then
          strobe <= '1';
          data_out(G_SPI_CYCLES-1 downto G_SPI_CYCLES-G_SPI_DATA_OUT_WIDTH) <= pi_data ;
          busy <= '1';
        end if;

        if done = '0' and done_prev = '1' then
          po_data <= stream_in(G_SPI_DATA_IN_WIDTH-1 downto 0) ;
          po_done <= '1';
          busy <= '0';
        else
          po_done <= '0';
        end if;
      end if;
    end if;
  end process;

  done_prev <= done when rising_edge(pi_clock);

  po_busy <= busy;
  -------------------------------------------------------------------
  -- set phase of clock
  gen_cpha_0 : if G_CPHA = 0 generate
    internal_clk <= spi_clk;
  end generate;

  gen_cpha_1 : if G_CPHA = 1 generate
    internal_clk <= not spi_clk;
  end generate;

  -------------------------------------------------------------------
  -- send out stream data
  proc_spi:process(internal_clk, pi_reset)
    variable v_cycle_cnt   : natural;
  begin
    if pi_reset = '1' then
      state <= ST_IDLE;
      cs_n <= '1';
      mosi <= '0';
      stream_out <= (others => '0');
      v_cycle_cnt := G_SPI_CYCLES;
    else
      if rising_edge(internal_clk) then
        case state is

          when ST_IDLE =>
            done    <= '0';
            clk_ena <= '0';
            mosi    <= '0';
            cs_n    <= '1';
            data_in_ena <= '0';
            v_cycle_cnt  := G_SPI_CYCLES ;
            if strobe = '1' then
              state <= ST_SET_CS ;
            end if ;

          when ST_SET_CS =>
            mosi <= '0';
            cs_n <= '0';
            stream_out <= data_out;
            state <= ST_STREAM_OUT ;

            -- we have to enable clock now
            if G_CPHA /= 0 and G_USE_ODDR /= 0 then
              clk_ena     <= '1';
              data_in_ena <= '1';
            end if;

          when ST_STREAM_OUT =>
            cs_n        <= '0';
            clk_ena     <= '1';
            data_in_ena <= '1';
            v_cycle_cnt := v_cycle_cnt - 1;
            mosi   <= stream_out(stream_out'left);
            stream_out(stream_out'left downto 1) <= stream_out(stream_out'left-1 downto 0);
            if v_cycle_cnt = 0 then
              state <= ST_DONE;
            end if;

          when ST_DONE =>
            mosi <= '0';
            done <= '1';
            cs_n <= '1';
            data_in_ena <= '0'; -- disable data stream in
            state <= ST_DISABLE_CLK; -- Disable clk AFTER CS goes high
                                        -- LTC2758 needs this feature
          when ST_DISABLE_CLK =>
            mosi <= '0';
            cs_n <= '1';
            clk_ena <= '0';
            data_in_ena <= '0';
            state <= ST_IDLE;

        end case;
      end if;
    end if;
  end process;

  po_cs_n <= cs_n ;
  po_mosi <= mosi ;

  -------------------------------------------------------------------
  -- ead data stream and insert to buffer
  gen_read_on_falling: if G_READ_ON_FALLING_EDGE = 1 generate
    process(internal_clk)
    begin
--      if pi_reset = '1' then
--        stream_in <= ( others => '0' ) ;
--      els
      if falling_edge(internal_clk) then
        if data_in_ena = '1' then
          stream_in(0) <= pi_miso;
          stream_in(stream_in'left downto 1) <= stream_in(stream_in'left-1 downto 0);
        end if;
      end if;
    end process;
  end generate;

  gen_read_on_rising: if G_READ_ON_FALLING_EDGE = 0 generate
    process(internal_clk)
    begin
--      if pi_reset = '1' then
--        stream_in <= ( others => '0' ) ;
--      els
      if rising_edge(internal_clk) then
        if data_in_ena = '1' then
          stream_in(0) <= pi_miso;
          stream_in(stream_in'left downto 1) <= stream_in(stream_in'left-1 downto 0);
        end if;
      end if;
    end process;
  end generate;

end Behavioral;

