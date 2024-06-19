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
--! @created 
--! @author  Lukasz Butkowski <lukasz.butkowski@desy.de>
-------------------------------------------------------------------------------
--! @description
--! 3 wire SPI implementation
--! supported clock divider, different CPHA and CPOL settings
--------------------------------------------------------------------------------------------------
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
-- TODO: support for multiple slaves needed, CS_N -> to vector, and slave select port
--------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity spi_4w_m is
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
    pi_strobe  : in  std_logic ;
    pi_data : in  std_logic_vector(G_SPI_DATA_OUT_WIDTH-1  downto 0) ;
    po_data : out std_logic_vector(G_SPI_DATA_IN_WIDTH-1   downto 0) ;
    po_done : out std_logic ;
    po_busy : out std_logic;

    po_sclk : out std_logic;
    po_mosi : out std_logic;
    pi_miso : in std_logic;
    po_cs_n : out std_logic
    ) ;
end spi_4w_m;

architecture Behavioral of spi_4w_m is

  type T_OUT_STATES is (IDLE, SET_CS, STREAM_OUT, DISABLE_CLK, DONE) ;
  signal ST_OUT : T_OUT_STATES ;

  signal SIG_CS_N       : std_logic := '1';
  signal SIG_MOSI       : std_logic := '0' ;

  signal SIG_SPI_CLK    : std_logic := '0';
  signal SIG_SPI_CLK_US : std_logic := '0'; -- Used in Ultrascale Arch for gated clock
  signal SIG_INT_CLK    : std_logic := '0';
  signal SIG_STR        : std_logic := '0';
  signal SIG_CLK_ENA    : std_logic := '0';
  signal SIG_CLK_ENA_N  : std_logic := '0';
  signal SIG_DATA_IN_ENA: std_logic := '0';
  signal SIG_DONE       : std_logic := '0';
  signal SIG_DONE_PREV  : std_logic := '0';

  signal SIG_BUSY : std_logic := '0';

  signal SIG_DATA_OUT   : std_logic_vector(G_SPI_CYCLES-1 downto 0) := ( others => '0' );
  signal SIG_STREAM_OUT : std_logic_vector(G_SPI_CYCLES-1 downto 0) := ( others => '0' );
  signal SIG_STREAM_IN  : std_logic_vector(G_SPI_CYCLES-1 downto 0) := ( others => '0' );

  attribute KEEP : string;
  attribute DONT_TOUCH : string;
  attribute equivalent_register_removal : string;

  attribute equivalent_register_removal of SIG_CS_N : signal is "NO";
  attribute DONT_TOUCH of SIG_CS_N : signal is "TRUE";

  attribute equivalent_register_removal of SIG_MOSI : signal is "NO";
  attribute DONT_TOUCH of SIG_MOSI : signal is "TRUE";

  attribute KEEP of SIG_SPI_CLK   : signal is "true";
  attribute KEEP of SIG_STREAM_IN : signal is "true";

  attribute IOB : string;
  attribute IOB of SIG_CS_N : signal is "TRUE";
  attribute IOB of SIG_MOSI : signal is "TRUE";

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

begin

  SIG_CLK_ENA_N <= not SIG_CLK_ENA;
  -------------------------------------------------------------------
  -- clock OUT clock enable and set polarity
  GEN_CPOL_0: if G_CPOL = 0 generate
    G_CLK_OUT: if G_USE_ODDR = 0 generate
      po_sclk <= not SIG_SPI_CLK when SIG_CLK_ENA = '1' else '0' ;
    end generate;

    G_CLK_OUT_ODDR: if G_USE_ODDR = 1 generate
      GEN_ODDR2: if G_ARCH = "SPARTAN6" generate
        INST_CLK_ODDR : ODDR2
          generic map  (
            DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1"
            INIT          => '0', -- Sets initial state of the Q output to '0' or '1'
            SRTYPE        => "ASYNC"
          ) -- Specifies "SYNC" or "ASYNC" set/reset
          port map
          (
            Q  => po_sclk        ,  -- 1-bit output data
            C0 => SIG_SPI_CLK     ,  -- 1-bit clock input
            C1 => "not"(SIG_SPI_CLK) ,  -- 1-bit clock input
            CE => SIG_CLK_ENA     ,   -- 1-bit clock enable input
            D0 => '0',    -- 1-bit data input (associated with C0)
            D1 => '1',    -- 1-bit data input (associated with C1)
            R  => SIG_CLK_ENA_N,    -- 1-bit reset input
            S  => '0'     -- 1-bit set input
          );
      end generate;

      GEN_ODDR: if G_ARCH /= "SPARTAN6" and G_ARCH /= "ULTRASCALE" generate
        INST_CLK_ODDR : ODDR
        generic map(
          DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE"
          INIT => '1'                    ,  -- Initial value for Q port ('1' or '0')
          SRTYPE => "ASYNC")                 -- Reset Type ("ASYNC" or "SYNC")
        port map (
          Q  => po_sclk    ,          -- 1-bit DDR output
          C  => SIG_SPI_CLK ,          -- 1-bit clock input
          CE => SIG_CLK_ENA,          -- 1-bit clock enable input
          D1 => '0',                   -- 1-bit data input (positive edge)
          D2 => '1',                   -- 1-bit data input (negative edge)
          R  => SIG_CLK_ENA_N,       -- 1-bit reset input
          S  => '0'                    -- 1-bit set input
        );
      end generate;

      gen_oddr_US : if g_arch = "ULTRASCALE" generate
        ins_oddr_us: ODDRE1
        generic map (
          SRVAL => '0')
        port map (
          q  => po_sclk,
          c  => SIG_SPI_CLK_US, -- 1-bit clock input
          d1 => '1',            -- 1-bit data input (positive edge)
          D2 => '0',            -- 1-bit data input (negative edge)
          sr => pi_reset       -- 1-bit set input
        );
        ins_bufgce: BUFGCE -- ODDRE1 does not have CE input
        port map(
          CE => SIG_CLK_ENA,
          I  => not SIG_SPI_CLK,
          O  => SIG_SPI_CLK_US
        );
      end generate;

    end generate;
  end generate;
    -----------------------------------------------------------------
  GEN_CPOL_1: if G_CPOL = 1 generate
    G_CLK_OUT: if G_USE_ODDR = 0 generate
      po_sclk <= SIG_SPI_CLK when SIG_CLK_ENA = '1' else '1' ;
    end generate;

    G_CLK_OUT_ODDR: if G_USE_ODDR = 1 generate
      GEN_ODDR2: if G_ARCH = "SPARTAN6" generate
        INST_CLK_ODDR : ODDR2
          generic map  (
            DDR_ALIGNMENT => "NONE", -- Sets output alignment to "NONE", "C0", "C1"
            INIT          => '1',    -- Sets initial state of the Q output to '0' or '1'
            SRTYPE        => "ASYNC" -- Specifies "SYNC" or "ASYNC" set/reset
          )
          port map
          (
            Q  => po_sclk        ,  -- 1-bit output data
            C0 => SIG_SPI_CLK     ,  -- 1-bit clock input
            C1 => "not"(SIG_SPI_CLK) , -- 1-bit clock input
            CE => SIG_CLK_ENA     ,  -- 1-bit clock enable input
            D0 => '1',               -- 1-bit data input (associated with C0)
            D1 => '0',               -- 1-bit data input (associated with C1)
            R  => '0',               -- 1-bit reset input
            S  => "not"(SIG_CLK_ENA) -- 1-bit set input
          );
      end generate;

      GEN_ODDR: if G_ARCH /= "SPARTAN6" and G_ARCH /= "ULTRASCALE" generate
        ODDR_inst : ODDR
        generic map(
          DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE"
          INIT => '1',                      -- Initial value for Q port ('1' or '0')
          SRTYPE => "ASYNC")                -- Reset Type ("ASYNC" or "SYNC")
        port map (
          Q  => po_sclk    ,    -- 1-bit DDR output
          C  => SIG_SPI_CLK ,    -- 1-bit clock input
          CE => SIG_CLK_ENA,     -- 1-bit clock enable input
          D1 => '1',             -- 1-bit data input (positive edge)
          D2 => '0',             -- 1-bit data input (negative edge)
          R  => '0',             -- 1-bit reset input
          S  => SIG_CLK_ENA_N    -- 1-bit set input
        );
      end generate;

      gen_oddr_US : if g_arch = "ULTRASCALE" generate
        ins_oddr_us: ODDRE1
        generic map (
          SRVAL => '1')
        port map (
          q  => po_sclk,
          c  => SIG_SPI_CLK_US, -- 1-bit clock input
          d1 => '0',         -- 1-bit data input (positive edge)
          D2 => '1',         -- 1-bit data input (negative edge)
          sr => pi_reset          -- 1-bit set input
        );
        ins_bufgce: BUFGCE -- ODDRE1 does not have CE input
        port map(
          CE => SIG_CLK_ENA,
          I  => SIG_SPI_CLK,
          O  => SIG_SPI_CLK_US
        );
      end generate;

    end generate;
  end generate;

  -------------------------------------------------------------------
  -- clock divider
  GEN_DIV_CLK: if G_CLK_DIV_ENA = 1 generate
  begin
    process(pi_clock)
      variable v_cnt  : natural;
    begin
      if rising_edge(pi_clock) then
        if v_cnt < (G_CLK_DIV-1) / 2 then
          v_cnt := v_cnt + 1;
        else
          v_cnt        := 0;
        SIG_SPI_CLK <= not SIG_SPI_CLK;
        end if;
      end if;
    end process;
  end generate;

  GEN_NO_DIV_CLK: if G_CLK_DIV_ENA = 0 generate
    SIG_SPI_CLK <= pi_clock ;
  end generate;

  -------------------------------------------------------------------
  -- synch to input clock and latch data
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        SIG_BUSY <= '0';
        po_done <= '0';
      else
        if SIG_DONE = '1' then
          SIG_STR <= '0' ;
        elsif pi_strobe = '1' and SIG_BUSY = '0' then
          SIG_STR        <= '1' ;
          SIG_DATA_OUT(G_SPI_CYCLES-1 downto G_SPI_CYCLES-G_SPI_DATA_OUT_WIDTH) <= pi_data ;
          SIG_BUSY <= '1';
        end if ;

        if SIG_DONE = '0' and SIG_DONE_PREV = '1' then
          po_data <= SIG_STREAM_IN(G_SPI_DATA_IN_WIDTH-1 downto 0) ;
          po_done <= '1';
          SIG_BUSY <= '0';
        else
          po_done <= '0';
        end if;
      end if;
    end if;
  end process;

  SIG_DONE_PREV <= SIG_DONE when rising_edge(pi_clock);

  po_busy <= SIG_BUSY;
  -------------------------------------------------------------------
  -- set phase of clock
  GEN_CPHA_0 : if G_CPHA = 0 generate
    SIG_INT_CLK <= SIG_SPI_CLK ;
  end generate;

  GEN_CPHA_1 : if G_CPHA = 1 generate
    SIG_INT_CLK <= not SIG_SPI_CLK ;
  end generate;

  -------------------------------------------------------------------
  -- send out stream data
  PROC_SPI:process(SIG_INT_CLK,pi_reset)
    variable v_cycle_cnt   : natural;
  begin
    if pi_reset = '1' then
      ST_OUT <= IDLE ;
      SIG_CS_N <= '1';
      SIG_MOSI <= '0';
      SIG_STREAM_OUT <= (others => '0');
      v_cycle_cnt  := G_SPI_CYCLES ;
    else
      if rising_edge(SIG_INT_CLK) then
        case ST_OUT is
          when IDLE =>
            SIG_DONE    <= '0' ;
            SIG_CLK_ENA <= '0' ;
            SIG_MOSI    <= '0' ;
            SIG_CS_N    <= '1' ;
            SIG_DATA_IN_ENA <= '0';
            v_cycle_cnt  := G_SPI_CYCLES ;
            if SIG_STR = '1' then
              ST_OUT   <= SET_CS ;
            end if ;
          when SET_CS =>
            SIG_MOSI <= '0';
            SIG_CS_N <= '0';
            SIG_STREAM_OUT <= SIG_DATA_OUT;
            ST_OUT <= STREAM_OUT ;

            -- we have to enable clock now
            if G_CPHA /= 0 and G_USE_ODDR /= 0 then
              SIG_CLK_ENA     <= '1';
              SIG_DATA_IN_ENA <= '1';
            end if;

          when STREAM_OUT =>
            SIG_CS_N        <= '0';
            SIG_CLK_ENA     <= '1' ;
            SIG_DATA_IN_ENA <= '1';
            v_cycle_cnt := v_cycle_cnt - 1;
            SIG_MOSI   <= SIG_STREAM_OUT(SIG_STREAM_OUT'left);
            SIG_STREAM_OUT(SIG_STREAM_OUT'left downto 1) <= SIG_STREAM_OUT(SIG_STREAM_OUT'left-1 downto 0);
            if v_cycle_cnt = 0 then
              ST_OUT         <= DONE ;
            end if;
          when DONE =>
            SIG_MOSI    <= '0';
            SIG_DONE    <= '1';
            SIG_CS_N    <= '1';
            SIG_DATA_IN_ENA <= '0'; -- disable data stream in
            ST_OUT      <= DISABLE_CLK; --! Disable clk AFTER CS goes high
                                        --! LTC2758 needs this feature
          when DISABLE_CLK =>
            SIG_MOSI        <= '0';
            SIG_CS_N        <= '1';
            SIG_CLK_ENA     <= '0';
            SIG_DATA_IN_ENA <= '0';
            ST_OUT <= IDLE;
        end case;
      end if;
    end if;
  end process;


  po_cs_n <= SIG_CS_N ;
  po_mosi <= SIG_MOSI ;

  -------------------------------------------------------------------
  -- ead data stream and insert to buffer
  GEN_READ_ON_FALLING: if G_READ_ON_FALLING_EDGE = 1 generate
    process(SIG_INT_CLK)
    begin
--      if pi_reset = '1' then
--        SIG_STREAM_IN <= ( others => '0' ) ;
--      els
      if falling_edge(SIG_INT_CLK) then
        if SIG_DATA_IN_ENA = '1' then
          SIG_STREAM_IN(0) <= pi_miso;
          SIG_STREAM_IN(SIG_STREAM_IN'left downto 1) <= SIG_STREAM_IN(SIG_STREAM_IN'left-1 downto 0);
        end if;
      end if;
    end process;
  end generate;

  GEN_READ_ON_RISING: if G_READ_ON_FALLING_EDGE = 0 generate
    process(SIG_INT_CLK)
    begin
--      if pi_reset = '1' then
--        SIG_STREAM_IN <= ( others => '0' ) ;
--      els
      if rising_edge(SIG_INT_CLK) then
        if SIG_DATA_IN_ENA = '1' then
          SIG_STREAM_IN(0) <= pi_miso;
          SIG_STREAM_IN(SIG_STREAM_IN'left downto 1) <= SIG_STREAM_IN(SIG_STREAM_IN'left-1 downto 0);
        end if;
      end if;
    end process;
  end generate;

end Behavioral;
