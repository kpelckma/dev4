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
--! @date 2022-02-08
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Delay based on the FIFO
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library desy;

entity fifo_delay is
  generic(
    G_FIFO_ARCH  : string := "GENERIC";
    G_FIFO_WIDTH : integer := 18;
    G_FIFO_DEPTH : integer := 256
  );
  port (
    pi_clock  : in std_logic;
    pi_reset  : in std_logic;

    pi_dry  : in std_logic;
    pi_data : in std_logic_vector(G_FIFO_WIDTH-1 downto 0);

    pi_set   : in std_logic;
    pi_delay : in std_logic_vector(integer(ceil(log2(real(G_FIFO_DEPTH))))-1 downto 0);

    po_dry  : out std_logic;
    po_data : out std_logic_vector(G_FIFO_WIDTH-1 downto 0)
  );
end fifo_delay;

architecture rtl of fifo_delay is

  signal fifo_reset       : std_logic ;
  signal fifo_rd_ena      : std_logic ;
  signal fifo_wr_ena      : std_logic ;
  signal fifo_rd_ena_and  : std_logic ;
  signal fifo_wr_ena_and  : std_logic ;

  signal fifo_empty       : std_logic ;
  signal fifo_full        : std_logic ;

  signal delay_cnt        : integer := 0 ;
  signal cnt              : integer := 0 ;

  signal state            : natural range 0 to 3 := 0 ;

  signal delay_line       : std_logic_vector(G_FIFO_DEPTH downto 0);

begin

  proc_cnt : process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_set = '1' then
        state       <= 0;
        delay_cnt   <= 0;
        cnt         <= 0;
        fifo_reset  <= '0';
        fifo_rd_ena <= '0';
        fifo_wr_ena <= '0';
      else
        case state is
          when 0 => -- RESET and wait for reset to finish
            fifo_reset  <= '1';
            cnt <= cnt + 1 ;
            if cnt >= 3 then
              cnt   <= 0;
              state <= 1;
            end if;

          when 1 => -- wait for FIFO after reset
            fifo_reset  <= '0';
            cnt <= cnt + 1 ;
            if cnt >= 3 then
              cnt   <= 0;
              state <= 2;
            end if;

          when 2 => -- enable write and wait
            fifo_wr_ena <= '1';
            if delay_cnt >= to_integer(unsigned(pi_delay))-1 then
              state  <= 3;
            else
              delay_cnt <= delay_cnt + 1;
            end if;
          when 3 => -- enable read and stay
            fifo_rd_ena  <= '1';
          when others =>
        end case;
      end if;
    end if;
  end process proc_cnt;

  prc_delay_dry : process (pi_clock, pi_reset)
  begin
    if rising_edge(pi_clock) then
      if fifo_wr_ena = '0' then
        delay_line <= (others => '0');
      else
        delay_line(0) <= pi_dry;
        for i in 1 to G_FIFO_DEPTH loop
          delay_line(i) <= delay_line(i-1);
        end loop;
      end if;
    end if;
  end process;

  po_dry <= pi_dry when (to_integer(unsigned(pi_delay)) = 0 ) else delay_line( to_integer(unsigned(pi_delay)) - 1);

  fifo_wr_ena_and <= fifo_wr_ena and not fifo_full;
  fifo_rd_ena_and <= fifo_rd_ena and not fifo_empty;

  ins_fifo : entity desy.fifo
    generic map (
      G_FIFO_DEPTH       => G_FIFO_DEPTH,
      G_FIFO_WIDTH       => G_FIFO_WIDTH,
      G_FIFO_READ_WIDTH  => G_FIFO_WIDTH,
      G_FIFO_WRITE_WIDTH => G_FIFO_WIDTH,
      G_FIFO_TYPE        => G_FIFO_ARCH,
      G_FIFO_FWFT        => 1
     )
    port map(
      pi_reset   => fifo_reset,
      pi_int_clk => pi_clock,

      pi_wr_clk     => pi_clock,
      pi_wr_ena     => fifo_wr_ena_and,
      pi_data       => pi_data,
      po_full       => fifo_full,
      po_prog_full  => open,

      pi_rd_clk     => pi_clock,
      pi_rd_ena     => fifo_rd_ena_and,
      po_data       => po_data,
      po_empty      => fifo_empty,
      po_prog_empty => open
    );

end rtl;
