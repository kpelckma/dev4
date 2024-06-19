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
-- @date 
-- @author  Radoslaw Rybaniec
------------------------------------------------------------------------------
-- @brief
--  DWC PLL control via PCA9535 I2C converter,
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity lmk04906_over_pca9535 is
port (
  pi_clock : in  std_logic;
  pi_reset : in  std_logic;
  
  -- I2C Arbiter interface
  po_req        : out std_logic;
  pi_grant      : in  std_logic;

  -- i2c_controler interface
  po_str        : out std_logic;
  po_wr         : out std_logic;
  po_data_width : out std_logic_vector(1 downto 0);
  po_data       : out std_logic_vector(31 downto 0);
  pi_data       : in  std_logic_vector(31 downto 0);
  po_addr       : out std_logic_vector(6 downto 0);
  pi_done       : in  std_logic;

  pi_pll_data   : in  std_logic_vector(31 downto 0) := (others => '0');  -- pll data
  pi_pll_str    : in  std_logic                     := '0';              -- pll strobe
  po_pll_busy   : out std_logic; -- pll done busy status register

  -- swap clk and data lines
  pi_sci_sdi_fix : in std_logic := '0'
);
end entity lmk04906_over_pca9535;

architecture rtl of lmk04906_over_pca9535 is

  constant c_cs_n      : std_logic_vector(23 downto 0) := x"000308";
  constant c_cmd_write : std_logic_vector(23 downto 0) := x"02fcff";

  signal reg_pll_strobe : std_logic;
  signal reg_data       : std_logic_vector(31 downto 0);
  signal sdi            : std_logic_vector(23 downto 0);
  signal vst            : integer;
  signal vcnt           : integer;
  signal put_exp_d      : std_logic;
  signal exp_clk        : std_logic;
  signal reg_data_o     : std_logic_vector(23 downto 0);
  
begin

  po_pll_busy <= reg_pll_strobe;

  po_data(31 downto 24) <= (others => '0');
  po_data(23 downto 0) <= reg_data_o or x"000" & "00" & reg_data(31) & exp_clk&x"00"   when pi_sci_sdi_fix = '0' and put_exp_d = '1' else
                          reg_data_o or x"000" & "00" & '0' & exp_clk & x"00"          when pi_sci_sdi_fix = '0' and put_exp_d = '0' else
                          reg_data_o or x"000" & "00" & exp_clk & reg_data(31) & x"00" when pi_sci_sdi_fix = '1' and put_exp_d = '1' else
                          reg_data_o or x"000" & "00" & exp_clk & "0" & x"00";
  
  process(pi_clock, pi_reset)
    variable v_st      : natural := 0;
    variable v_next_st : natural := 0;
    variable v_cnt     : natural := 0;
  begin
    if pi_reset = '1' then
      reg_pll_strobe <= '0';
      po_req <= '0';
      reg_data_o <= (others => '0');
      po_data_width <= (others => '0');
      po_addr <= (others => '0');
      po_wr <= '0';
      po_str <= '0';
      v_st := 0;

    elsif rising_edge(pi_clock) then

      if pi_pll_str = '1' then
        reg_pll_strobe <= '1';  
      end if;
      
      vst  <= v_st;
      vcnt <= v_cnt;

      case v_st is

        when 0 =>
          po_req <= '0';
          reg_data_o <= (others => '0');
          po_data_width <= (others => '0');
          po_addr <= (others => '0');
          po_wr <= '0';
          po_str <= '0';
          exp_clk <= '0';
          put_exp_d <= '0';
          v_cnt := 0;

          if reg_pll_strobe = '1' then
            reg_data <= pi_pll_data;
            v_st := 1;
            po_req <= '1';
          end if;

        when 1 =>
          if pi_grant = '1' then
            po_data_width <= "10";
            po_addr <= "0100000";
            po_wr <= '1';
            reg_data_o(23 downto 0) <= x"060000";
            po_str <= '1';
            exp_clk   <= '0';
            put_exp_d <= '0';
            v_next_st := 2;
            v_st      := 15;
          end if;

        when 2 =>
          reg_data_o    <= c_cmd_write and not c_cs_n;
          exp_clk   <= '0';
          put_exp_d <= '0';

          po_str   <= '1';
          v_next_st := 3;
          v_st      := 15;

        when 3 =>
          reg_data_o    <= c_cmd_write and not c_cs_n;
          exp_clk   <= '0';
          put_exp_d <= '1';

          po_str   <= '1';
          v_next_st := 4;
          v_st      := 15;

        when 4 =>
          reg_data_o    <= c_cmd_write and not c_cs_n;
          exp_clk   <= '1';
          put_exp_d <= '1';
          po_str <= '1';
          v_st    := 14;

        when 7 =>
          reg_data_o <= c_cmd_write;
          exp_clk <= '0';
          put_exp_d <= '1';
          po_str <= '1';
          v_next_st := 8;
          v_st := 15;

        when 8 =>
          reg_data_o <= c_cmd_write;
          exp_clk <= '0';
          put_exp_d <= '0';
          po_str <= '1';
          v_next_st := 0;
          v_st := 15;  

        when 14 =>
          po_str <= '0';
          if pi_done = '1' then
            if v_cnt = 31 then
              v_st := 7;
            else
              reg_data(31 downto 1) <= reg_data(30 downto 0);
              v_cnt := v_cnt+1;
              v_st := 3;
            end if;
          end if;

        when 15 =>
          po_str <= '0';
          if pi_done = '1' then
            v_st := v_next_st;
            if v_next_st = 0 then
              reg_pll_strobe <= '0';
            end if;
          end if;

        when others => v_st := 0;

      end case;

    end if;
  end process;
end architecture rtl;
