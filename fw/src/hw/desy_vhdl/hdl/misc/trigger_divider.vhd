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
--! @date 2021-09-14
--! @author MSK FPGA Team
------------------------------------------------------------------------------
--! @brief
--!  timing generator with divider for external timing lines
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library desy;
use desy.common_types.all ;

entity trigger_divider is
generic (
  G_CHANNELS : natural := 1
);
port (
  pi_clock   : in std_logic;
  pi_reset : in std_logic;

  -- external triggers/strobes
  pi_ext_rst         : in std_logic_vector(G_CHANNELS-1 downto 0) := (others => '0');
  pi_ext_trigger_ena : in std_logic_vector(G_CHANNELS-1 downto 0) := (others => '0');
  pi_ext_trigger     : in std_logic_vector(G_CHANNELS-1 downto 0) := (others => '0');

  pi_div         : in  t_32b_slv_vector(G_CHANNELS-1 downto 0);
  po_trigger_cnt : out t_32b_slv_vector(G_CHANNELS-1 downto 0);
  po_trigger     : out std_logic_vector(G_CHANNELS-1 downto 0)
);
end trigger_divider;

architecture arch of trigger_divider is

  signal cnt     : t_32b_slv_vector(G_CHANNELS-1 downto 0);
  signal ext_trg : std_logic_vector(G_CHANNELS-1 downto 0);
  signal trg     : std_logic_vector(G_CHANNELS-1 downto 0);

begin

  po_trigger_cnt <= cnt;
  po_trigger <= trg;

  gen_trg: for i in 0 to G_CHANNELS-1 generate
    signal l_cnt : std_logic_vector(31 downto 0) ;
  begin

    --! rising edge detector for external triggers/strobes
    process(pi_clock)
      variable v_prev : std_logic;
    begin
      if rising_edge(pi_clock) then
        ext_trg(I) <= pi_ext_trigger(I) and not v_prev ;
        v_prev := pi_ext_trigger(I) ;
      end if;
    end process;

    process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' or pi_ext_rst(i) = '1' then
          l_cnt <= (others =>'0');
          trg(i) <= '0';
        else
          trg(i) <= '0';
          if pi_ext_trigger_ena(i) = '1' then
            if ext_trg(i) = '1' then
              if l_cnt < pi_div(i) then
                l_cnt <= l_cnt + 1;
                trg(i) <= '0';
              else
                l_cnt <= (others=>'0');
                trg(i) <= '1';
              end if;
            end if;
          else
            if l_cnt < pi_div(i) then
              l_cnt <= l_cnt + 1;
              trg(i) <= '0';
            else
              l_cnt <= (others=>'0');
              trg(i) <= '1';
            end if;
          end if;
        end if;
      end if;
    end process;

    --! Counter for each channel for monitoring
    process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if pi_reset = '1' then
          cnt(i) <= ( others => '0' );
        else
          if trg(i) = '1' then
            cnt(i) <= cnt(i) + 1 ;
          end if ;
        end if ;
      end if ;
    end process;

  end generate;

end arch;
