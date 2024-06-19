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
--! @date 2013-01-03
--! @author
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--! Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief Summation of up to 12 input vectors
--!
--! TODO: add pipeline stages based on arbitrary number of channels
--! TODO: use number of guard bits according to the number of channels
--! TODO: make dynamic scaling optional based on a generic
--! TODO: add a generic to enable optional saturation
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all ;

library desy;
use desy.common_types.all ;

entity vector_sum is 
  generic (
    G_DATA_WIDTH    : natural := 18;
    G_CHANNEL_COUNT : natural := 4
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    pi_enable : in  std_logic_vector(G_CHANNEL_COUNT-1 downto 0);
    pi_shift  : in  std_logic_vector(1 downto 0);

    pi_valid  : in  std_logic;
    pi_i      : in  t_18b_slv_vector(G_CHANNEL_COUNT-1 downto 0);
    pi_q      : in  t_18b_slv_vector(G_CHANNEL_COUNT-1 downto 0);

    po_valid  : out std_logic;
    po_i      : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    po_q      : out std_logic_vector(G_DATA_WIDTH-1 downto 0)
  );
end vector_sum;

architecture rtl of vector_sum is

  type t_pipe is array(natural range <>) of signed(2*G_DATA_WIDTH-1 downto 0);

  signal i_pipe0  : t_pipe(11 downto 0);
  signal q_pipe0  : t_pipe(11 downto 0);
  signal i_pipe1  : t_pipe(3 downto 0);
  signal q_pipe1  : t_pipe(3 downto 0);
  signal i_pipe2  : t_pipe(1 downto 0);
  signal q_pipe2  : t_pipe(1 downto 0);
  signal valid    : std_logic_vector(2 downto 0);

begin

  prs_pipe: process(pi_clock) 
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        po_valid  <= '0';
        valid     <= (others => '0');
        i_pipe0   <= (others => (others => '0'));
        q_pipe0   <= (others => (others => '0'));
      else
        valid <= valid(1 downto 0) & pi_valid;
        if pi_valid = '1' then
          for I in 0 to G_CHANNEL_COUNT-1 loop
            if pi_enable(I) = '1' then
              i_pipe0(I) <= resize(signed(pi_i(I)), 2*G_DATA_WIDTH);
              q_pipe0(I) <= resize(signed(pi_q(I)), 2*G_DATA_WIDTH);
            else
              i_pipe0(I) <= (others => '0');
              q_pipe0(I) <= (others => '0');
            end if;
          end loop;
        end if;
        if valid(0) = '1' then
          for I in 0 to 3 loop
            i_pipe1(I) <= i_pipe0(3*I+0) + i_pipe0(3*I+1) + i_pipe0(3*I+2);
            q_pipe1(I) <= q_pipe0(3*I+0) + q_pipe0(3*I+1) + q_pipe0(3*I+2);
          end loop ;
        end if;
        if valid(1) = '1' then
          i_pipe2(0) <= i_pipe1(0) + i_pipe1(1);
          q_pipe2(0) <= q_pipe1(0) + q_pipe1(1);
          i_pipe2(1) <= i_pipe1(2) + i_pipe1(3);
          q_pipe2(1) <= q_pipe1(2) + q_pipe1(3);
        end if;
        if valid(2) = '1' then
          case pi_shift is
            when "01" =>
              po_i <= std_logic_vector(resize(shift_right(i_pipe2(0) + i_pipe2(1), 1), G_DATA_WIDTH));
              po_q <= std_logic_vector(resize(shift_right(q_pipe2(0) + q_pipe2(1), 1), G_DATA_WIDTH));
            when "10" =>
              po_i <= std_logic_vector(resize(shift_right(i_pipe2(0) + i_pipe2(1), 2), G_DATA_WIDTH));
              po_q <= std_logic_vector(resize(shift_right(q_pipe2(0) + q_pipe2(1), 2), G_DATA_WIDTH));
            when "11" =>
              po_i <= std_logic_vector(resize(shift_right(i_pipe2(0) + i_pipe2(1), 3), G_DATA_WIDTH));
              po_q <= std_logic_vector(resize(shift_right(q_pipe2(0) + q_pipe2(1), 3), G_DATA_WIDTH));
            when others =>
              po_i <= std_logic_vector(resize(i_pipe2(0) + i_pipe2(1) ,G_DATA_WIDTH));
              po_q <= std_logic_vector(resize(q_pipe2(0) + q_pipe2(1) ,G_DATA_WIDTH));
          end case ;
          po_valid <= '1';
        else
          po_valid <= '0';
        end if;
      end if;
    end if;
  end process prs_pipe;

end rtl;
