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
-- @date 2021-11-10
-- @author  Radoslaw Rybaniec
-- @author  Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
-- @brief
-- TheLTC2493 is a 4-channel (2-channel differential), 24-bit DAC with I2C interface
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_misc.all;

entity ltc2493 is
generic (
  G_ADDR     : std_logic_vector(6 downto 0) := "0110100";
  G_CLK_FREQ : natural := 125_000_000;
  G_DISABLE_DIFF_MODE: std_logic := '1' -- 1 Single ended 0-> Differential Mode
);
port (
  pi_clock      : in  std_logic;
  pi_reset      : in  std_logic;
  -- Arbiter interface
  po_req        : out std_logic;
  pi_grant      : in  std_logic;
  -- I2C_CONTROLER interface
  po_str        : out std_logic;
  po_wr         : out std_logic;
  po_data_width : out std_logic_vector(1 downto 0);
  po_data       : out std_logic_vector(31 downto 0);
  pi_data       : in  std_logic_vector(31 downto 0);
  po_addr       : out std_logic_vector(6 downto 0);
  pi_done       : in  std_logic;
  -- ADC REGISTERS
  -- ADC A DATA
  po_a_data     : out std_logic_vector(24 downto 0) := (others => '0');
  -- ADC A STROBE
  pi_a_str      : in  std_logic                     := '0';
  -- ADC B
  po_b_data     : out std_logic_vector(24 downto 0) := (others => '0');
  pi_b_str      : in  std_logic                     := '0';
  -- ADC C
  po_c_data     : out std_logic_vector(24 downto 0) := (others => '0');
  pi_c_str      : in  std_logic                     := '0';
  -- ADC D
  po_d_data     : out std_logic_vector(24 downto 0) := (others => '0');
  pi_d_str      : in  std_logic                     := '0';

  -- Conv done status register
  po_adc_status : out std_logic_vector(3 downto 0);

  -- ADC configuration register
  -- 3:    IM    (1 - measure temperature)
  -- 21:   FA FB (00 - both 50/60Hz rejection; 01 - 50Hz; 10 - 60Hz)
  -- 0:    SPD   (1 - disable auto calibration, 2xSPS)
  -- 0000: External input, 50/60 rejection with auto calibration
  pi_adc_conf   : in  std_logic_vector(3 downto 0) := "0000"
);
end entity ltc2493;

architecture beh of ltc2493 is

  signal reg_adc_strobes : std_logic_vector(1 to 4) := (others => '0');
  signal reg_data        : std_logic_vector(15 downto 0);
  signal reg_state       : natural := 0;
  signal reg_act_chan    : natural := 0;
  signal timer           : natural := 0;
begin

  po_adc_status <= reg_adc_strobes;

  process(pi_clock, pi_reset)
    variable v_tmp_data : std_logic_vector(31 downto 0);
  begin
    if pi_reset = '1' then
      reg_adc_strobes <= (others => '0');
      po_req         <= '0';
      po_data        <= (others => '0');
      po_data_width  <= (others => '0');
      po_addr        <= (others => '0');
      po_wr          <= '0';
      po_str         <= '0';
      reg_state       <= 0;
    elsif rising_edge(pi_clock) then
      if pi_a_str = '1' then
        reg_adc_strobes(1) <= '1';
      end if;
      if pi_b_str = '1' then
        reg_adc_strobes(2) <= '1';
      end if;
      if pi_c_str = '1' then
        reg_adc_strobes(3) <= '1';
      end if;
      if pi_d_str = '1' then
        reg_adc_strobes(4) <= '1';
      end if;
      case reg_state is
        when 0 =>
          po_req        <= '0';
          po_data       <= (others => '0');
          po_data_width <= (others => '0');
          po_addr       <= (others => '0');
          po_wr         <= '0';
          po_str        <= '0';
          timer          <= integer(real(G_CLK_FREQ) * 0.164) ; -- wait for conversion, time = 164ms
          if or_reduce(reg_adc_strobes) = '1' then
            if reg_adc_strobes(1) = '1' then
              -- load data
              -- two don't care&command write adc and update&address&data&4don't care
              reg_data     <= "101" & G_DISABLE_DIFF_MODE & "0000" & "1" & pi_adc_conf & "000";
              reg_act_chan <= 1;
            elsif reg_adc_strobes(2) = '1' then
              -- load data
              reg_data     <= "101" & G_DISABLE_DIFF_MODE & "1000" & "1" & pi_adc_conf & "000";
              reg_act_chan <= 2;
            elsif reg_adc_strobes(3) = '1' then
              -- load data
              reg_data     <= "101" & G_DISABLE_DIFF_MODE & "0001" & "1" & pi_adc_conf & "000";
              reg_act_chan <= 3;
            elsif reg_adc_strobes(4) = '1' then
              reg_data     <= "101" & G_DISABLE_DIFF_MODE & "1001" & "1" & pi_adc_conf & "000";
              reg_act_chan <= 4;
            end if;
            reg_state <= 1;
            po_req   <= '1';
          end if;
        when 1 =>                       -- conf
          if pi_grant = '1' then
            po_data_width        <= "01";
            po_addr              <= G_ADDR;
            po_wr                <= '1';
            po_data(15 downto 0) <= reg_data;
            po_str               <= '1';
            reg_state             <= 2;
          end if;
        when 2 =>                       -- wait
          po_str <= '0';
          if pi_done = '1' then
            reg_state <= 3;
            po_req   <= '0';
          end if;
        when 3 => -- wait for conversion time
          if timer > 0 then
            timer <= timer - 1 ;
          else
            reg_state <= 4;
            po_req   <= '1';
          end if;
        when 4 =>                       -- read
          if pi_grant = '1' then
            po_wr  <= '0';
            po_str <= '1';
            po_data_width <= "11";
            reg_state <= 5;
          end if;
        when 5 =>                       -- wait
          timer <= integer(real(G_CLK_FREQ) * 0.164) ; -- wait for conversion, time = 164ms
          po_str <= '0';
          if pi_done = '1' then
            reg_state <= 6;

            -- reg_adc_strobes(reg_act_chan) <= '0';
            v_tmp_data := pi_data;

            if (v_tmp_data(31) or v_tmp_data(30)) = '0' then
              v_tmp_data(30)          := '1';
              v_tmp_data(29 downto 6) := (others => '0');
            end if;
            if (v_tmp_data(31) and v_tmp_data(30)) = '1' then
              v_tmp_data(30)          := '0';
              v_tmp_data(29 downto 6) := (others => '1');
            end if;
            if reg_act_chan = 1 then
              po_a_data <= v_tmp_data(30 downto 6);
              reg_adc_strobes(1) <= '0' ;
            end if;
            if reg_act_chan = 2 then
              po_b_data <= v_tmp_data(30 downto 6);
              reg_adc_strobes(2) <= '0' ;
            end if;
            if reg_act_chan = 3 then
              po_c_data <= v_tmp_data(30 downto 6);
              reg_adc_strobes(3) <= '0' ;
            end if;
            if reg_act_chan = 4 then
              po_d_data <= v_tmp_data(30 downto 6);
              reg_adc_strobes(4) <= '0' ;
            end if;
          end if;

        when 6 => -- wait for conversion time after read
          po_req <= '0';
          if timer > 0 then
            timer <= timer - 1 ;
          else
            reg_state <= 0;
          end if;
        when others =>
          reg_state <= 0;
      end case;
    end if;
  end process;

end architecture beh;

