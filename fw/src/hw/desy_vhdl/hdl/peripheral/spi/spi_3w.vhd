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
--! @author  Lukasz Butkowski <lukasz.butkowski@desy.de>
-------------------------------------------------------------------------------
--! @description
--! 3 wire SPI implementation
-------------------------------------------------------------------------------
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

library ieee;
use ieee.std_logic_1164.all;

entity spi_3w is
  generic (
    G_CPHA                 : natural  := 0;
    G_CPOL                 : natural  := 0;
    G_READ_ON_FALLING_EDGE : natural  := 0;
    G_SPI_CYCLES           : positive := 16;
    G_SPI_DATA_OUT_WIDTH   : positive := 16;
    G_SPI_DATA_IN_WIDTH    : positive := 16;
    G_CLK_DIV_ENA          : natural  := 0;
    G_CLK_DIV              : natural  := 50
    );
  port (
    pi_clock : in std_logic;
    pi_reset : in std_logic;
    pi_strobe : in  std_logic;
    pi_rnw    : in  std_logic; -- 1 -> Read 0 -> Write
    pi_data   : in  std_logic_vector(G_SPI_DATA_OUT_WIDTH-1  downto 0) ;
    po_data   : out std_logic_vector(G_SPI_DATA_IN_WIDTH-1   downto 0) ;
    po_done   : out std_logic;
    po_busy   : out std_logic;
    po_sclk   : out std_logic;
    po_cs_n   : out std_logic;
    po_sdio_t : out std_logic;
    po_sdio_o : out std_logic;
    pi_sdio_i : in  std_logic
  );
end spi_3w;

architecture behavioral of spi_3w is

  type t_out_states is (IDLE, SET_CS, ST_STREAM_OUT, ST_DONE);
  signal state_out : t_out_states;
  
  signal cs_n       : std_logic;
  
  signal spi_clk        : std_logic := '0';
  signal spi_clk_prev   : std_logic := '0';
  signal spi_clk_ena    : std_logic := '0';
  signal int_clk        : std_logic := '0';
  signal strobe         : std_logic := '0';
  signal read_not_write : std_logic := '0';
  signal clk_ena        : std_logic := '0';
  signal done           : std_logic := '0';
  signal done_prev      : std_logic := '0';
  
  signal stream_out : std_logic_vector(G_SPI_CYCLES-1 downto 0);
  signal stream_in  : std_logic_vector(G_SPI_CYCLES-1 downto 0);
  
   attribute KEEP : string;
   attribute KEEP of spi_clk : signal is "true";

begin
  -------------------------------------------------------------------
  -- clock enable and set polarity
  GEN_CPOL_0: if G_CPOL = 0 generate 
    proc_ena_clk:process(spi_clk_ena, spi_clk)
    begin
      if spi_clk_ena = '1' then
       po_sclk <= not spi_clk;
      else
       po_sclk <= '0' ;
      end if;
    end process;
  end generate;
  
  GEN_CPOL_1: if G_CPOL = 1 generate 
    proc_ena_clk:process(spi_clk_ena, spi_clk )
    begin
      if spi_clk_ena = '1' then
       po_sclk <= spi_clk;
      else
       po_sclk <= '1' ;
      end if;
    end process;
  end generate;
  
  -------------------------------------------------------------------
  -- clock divider
  gen_div_clk: if G_CLK_DIV_ENA = 1 generate
    -- signal SIG_LOC_SLOW_CLK    : std_logic := '0' ;
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
        spi_clk_prev <= spi_clk ;
      end if;
    end process;
    clk_ena <= '1' when spi_clk_prev = '0' and  spi_clk = '1' else '0' ;
  end generate;
  
  GEN_NO_DIV_CLK: if G_CLK_DIV_ENA = 0 generate
    spi_clk <= pi_clock ;
    clk_ena <= '1' ;
  end generate;
  
  -------------------------------------------------------------------
  -- synch to input clock and latch data
  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if done = '1' then
        strobe <= '0' ;
      elsif pi_strobe = '1' then
        strobe  <= '1' ;
        read_not_write  <= pi_rnw ;
        stream_out(G_SPI_CYCLES-1 downto G_SPI_CYCLES-G_SPI_DATA_OUT_WIDTH) <= pi_data ;
      end if;
      
      if done = '1' and done_prev = '0' then
        po_data <= stream_in(G_SPI_DATA_IN_WIDTH-1 downto 0) ;
        po_done <= '1';
      else
        po_done <= '0';
      end if;
      done_prev <= done;
    end if;
  end process;  
  
  -------------------------------------------------------------------
  -- et phase of clock
  GEN_CPHA_0 : if G_CPHA = 0 generate
    int_clk <= spi_clk ;
  end generate;
  
  GEN_CPHA_1 : if G_CPHA = 1 generate
    int_clk <= not spi_clk ;
  end generate;
 
  -------------------------------------------------------------------
  -- send out stream data
  proc_spi : process(pi_clock)
    variable v_state       : natural;
    variable v_cycle_cnt   : natural;
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        spi_clk_ena <= '0' ;
        po_sdio_o   <= '0' ;
        cs_n        <= '1' ;
        po_busy     <= '0' ;

      else
        if clk_ena = '1' then
          case state_out is

            when IDLE =>
              done        <= '0';
              spi_clk_ena <= '0';
              po_sdio_t   <= '0';
              po_sdio_o   <= '0';
              cs_n        <= '1';
              po_busy     <= '0';
              v_cycle_cnt := 0;
              v_cycle_cnt := G_SPI_CYCLES;

              if strobe = '1' then
                state_out   <= SET_CS ;
                po_busy <= '1';
              end if;

            when SET_CS =>
              cs_n <= '0';
              state_out   <= ST_STREAM_OUT;

            when ST_STREAM_OUT =>
              spi_clk_ena <= '1';
              v_cycle_cnt := v_cycle_cnt - 1;
              po_sdio_o   <= stream_out(v_cycle_cnt);
              
              if read_not_write = '1' and v_cycle_cnt < G_SPI_DATA_IN_WIDTH then
                po_sdio_t  <= '1';
              end if;
              
              if v_cycle_cnt = 0 then
                state_out <= ST_DONE ;
              end if;

            when ST_DONE =>
              spi_clk_ena <= '0';
              done        <= '1';
              cs_n        <= '1';
              po_sdio_t   <= '0';
              state_out   <= IDLE;

            when others => state_out <= IDLE;

          end case;
        end if;
      end if;
    end if;
  end process;
  
  po_cs_n <= cs_n; 
  
  -------------------------------------------------------------------
  -- read data stream and insert to buffer
  gen_read_on_falling: if G_READ_ON_FALLING_EDGE = 1 generate
    process(int_clk)
      variable v_cycle_cnt : natural := 0;
    begin
      if falling_edge(int_clk) then
        if pi_reset = '1' then
          v_cycle_cnt := 0;
          stream_in   <= (others => '0');
        else
          if spi_clk_ena = '1' and v_cycle_cnt > 0 then 
            v_cycle_cnt := v_cycle_cnt - 1 ;
            stream_in(v_cycle_cnt) <= pi_sdio_i;
          else
            v_cycle_cnt := G_SPI_CYCLES;
          end if;
        end if;
      end if;
    end process;
  end generate;

  gen_read_on_rising: if G_READ_ON_FALLING_EDGE = 0 generate
    process(int_clk)
      variable v_cycle_cnt : natural:=0;
    begin
      if rising_edge(int_clk) then
        if pi_reset = '1' then
          v_cycle_cnt := 0 ;
          stream_in   <= (others => '0');
        else
          if spi_clk_ena = '1' and v_cycle_cnt > 0 then 
            v_cycle_cnt := v_cycle_cnt - 1;
            stream_in(v_cycle_cnt) <= pi_sdio_i;
          else
            v_cycle_cnt := G_SPI_CYCLES;
          end if;
        end if;
      end if;
    end process;
  end generate;
  
end behavioral;

