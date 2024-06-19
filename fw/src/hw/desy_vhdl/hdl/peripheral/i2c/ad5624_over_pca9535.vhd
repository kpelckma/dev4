------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
-- @copyright copyright 2021 DESY
-- SPDX-LICENSE-IDENTIFIER: CERN-OHL-W-2.0
------------------------------------------------------------------------------
-- @date
-- @author radoslaw rybaniec
-- @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
-- @brief
-- AD5624 DAC (12 bits) controlled over PCA9535 IO expander
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity ad5624_over_pca9535 is
port (
  pi_clock : in  std_logic;
  pi_reset : in  std_logic;

  -- arbiter interface
  po_req   : out std_logic;
  pi_grant : in  std_logic;

  -- i2c_controler interface
  po_str        : out std_logic;
  po_wr         : out std_logic;
  po_data_width : out std_logic_vector(1 downto 0);
  po_data       : out std_logic_vector(31 downto 0);
  po_addr       : out std_logic_vector(6 downto 0);
  pi_done       : in  std_logic;

  pi_daca_data    : in  std_logic_vector(11 downto 0) := (others => '0');  -- dac a
  pi_daca_str     : in  std_logic                     := '0';              -- dac a strobe
  pi_dacb_data    : in  std_logic_vector(11 downto 0) := (others => '0');  -- dac b
  pi_dacb_str     : in  std_logic                     := '0';              -- dac b strobe
  pi_dacab_data   : in  std_logic_vector(11 downto 0) := (others => '0');  -- dac all outputs
  pi_dacab_str    : in  std_logic                     := '0';              -- dac all strobe
  pi_dac_raw_data : in  std_logic_vector(23 downto 0) := (others => '0');  -- dac raw data interface
  pi_dac_raw_str  : in  std_logic                     := '0';              -- dac raw strobe
  po_dac_strobed  : out std_logic                     := '0';              -- notification of the first strobe

  -- dac done status register
  -- 0 when command executed
  po_dac_status   : out std_logic_vector(3 downto 0);
  -- swap clk and data lines
  pi_sci_sdi_fix  : in  std_logic := '0'
);
end entity ad5624_over_pca9535;

architecture beh of ad5624_over_pca9535 is

  constant c_cs_n      : std_logic_vector(23 downto 0) := x"000008";
  constant c_cmd_write : std_logic_vector(23 downto 0) := x"020000";

  signal reg_dac_strobes : std_logic_vector(1 to 4) := (others => '0');
  signal reg_data        : std_logic_vector(23 downto 0);
  signal sig_sdi         : std_logic_vector(23 downto 0);
  signal reg_act_chan    : natural := 0;
  signal sig_put_exp_d   : std_logic;
  signal sig_exp_clk     : std_logic;
  signal reg_data_o      : std_logic_vector(23 downto 0);

begin

  po_dac_status <= reg_dac_strobes;
  po_data(31 downto 24) <= (others => '0');
  po_data(23 downto 0) <= reg_data_o or x"000" & "00" & reg_data(23) & sig_exp_clk & x"00" when pi_sci_sdi_fix = '0' and sig_put_exp_d = '1' else
                          reg_data_o or x"000" & "00" & '0' & sig_exp_clk & x"00"          when pi_sci_sdi_fix = '0' and sig_put_exp_d = '0' else
                          reg_data_o or x"000" & "00" & sig_exp_clk & reg_data(23) & x"00" when pi_sci_sdi_fix = '1' and sig_put_exp_d = '1' else
                          reg_data_o or x"000" & "00" & sig_exp_clk & "0" & x"00";

  process(pi_clock, pi_reset)
    variable v_st      : natural := 0;
    variable v_next_st : natural := 0;
    variable v_cnt     : natural := 0;
  begin
    if pi_reset = '1' then
      reg_dac_strobes <= (others => '0');
      po_req         <= '0';
      reg_data_o      <= (others => '0');
      po_data_width  <= (others => '0');
      po_addr        <= (others => '0');
      po_wr          <= '0';
      po_str         <= '0';
      po_dac_strobed <= '0';
      v_st            := 0;
    elsif rising_edge(pi_clock) then
      if pi_daca_str = '1' then
        reg_dac_strobes(1) <= '1';
        po_dac_strobed    <= '1';
      end if;
      if pi_dacb_str = '1' then
        reg_dac_strobes(2) <= '1';
        po_dac_strobed    <= '1';
      end if;
      if pi_dacab_str = '1' then
        reg_dac_strobes(3) <= '1';
        po_dac_strobed    <= '1';
      end if;
      if pi_dac_raw_str = '1' then
        reg_dac_strobes(4) <= '1';
        po_dac_strobed    <= '1';
      end if;
      case v_st is
        when 0 =>
          po_req        <= '0';
          reg_data_o     <= (others => '0');
          po_data_width <= (others => '0');
          po_addr       <= (others => '0');
          po_wr         <= '0';
          po_str        <= '0';
          v_cnt          := 0;

          sig_exp_clk   <= '0';
          sig_put_exp_d <= '0';

          if or_reduce(reg_dac_strobes) = '1' then
            if reg_dac_strobes(1) = '1' then
              reg_act_chan <= 1;
              -- load data
              -- two don't care&command write dac and update&address&data&4don't care
              reg_data     <= b"00_011_000"&pi_daca_data&"0000";
            elsif reg_dac_strobes(2) = '1' then
              reg_act_chan <= 2;
              -- load data
              reg_data     <= b"00_011_001"&pi_dacb_data&"0000";
            elsif reg_dac_strobes(3) = '1' then
              reg_act_chan <= 3;
              -- load data
              reg_data     <= b"00_011_111"&pi_dacab_data&"0000";
            elsif reg_dac_strobes(4) = '1' then
              reg_act_chan <= 4;
              reg_data     <= pi_dac_raw_data;
            end if;
            v_st    := 1;
            po_req <= '1';
          end if;

        when 1 =>
          if pi_grant = '1' then
            po_data_width          <= "10";
            po_addr                <= "0100000";
            po_wr                  <= '1';
            reg_data_o(23 downto 0) <= x"060000";
            po_str                 <= '1';

            sig_exp_clk   <= '0';
            sig_put_exp_d <= '0';

            v_next_st := 2;
            v_st      := 15;
          end if;

        when 2 =>
          --po_data(23 downto 0) <= c_cmd_write or c_clk or c_cs_n;
          reg_data_o    <= c_cmd_write or c_cs_n;
          sig_exp_clk   <= '1';
          sig_put_exp_d <= '0';

          po_str   <= '1';
          v_next_st := 3;
          v_st      := 15;

        when 3 =>
          --po_data(23 downto 0) <= ((c_cmd_write or sig_sdi) and not c_cs_n) or c_clk;       -- next bit
          reg_data_o    <= c_cmd_write and not c_cs_n;
          sig_exp_clk   <= '1';
          sig_put_exp_d <= '1';

          po_str   <= '1';
          v_next_st := 4;
          v_st      := 15;

        when 4 =>
          --po_data(23 downto 0) <= ((c_cmd_write or sig_sdi) and not c_cs_n) and not c_clk;  -- tutaj nastepuje zaczask
          reg_data_o    <= c_cmd_write and not c_cs_n;
          sig_exp_clk   <= '0';
          sig_put_exp_d <= '1';

          po_str <= '1';
          v_st    := 14;

        when 7 =>
          --po_data(23 downto 0) <= (c_cmd_write and not c_clk) or c_cs_n;
          reg_data_o    <= c_cmd_write or c_cs_n;
          sig_exp_clk   <= '0';
          sig_put_exp_d <= '0';

          po_str   <= '1';
          v_next_st := 0;
          v_st      := 15;

        when 14 =>
          po_str <= '0';
          if pi_done = '1' then
            if v_cnt = 23 then
              v_st := 7;
            else
              reg_data(23 downto 1) <= reg_data(22 downto 0);
              v_cnt                 := v_cnt+1;
              v_st                  := 3;
            end if;
          end if;

        when 15 =>
          po_str <= '0';
          if pi_done = '1' then
            v_st := v_next_st;
            if v_next_st = 0 then
              reg_dac_strobes(reg_act_chan) <= '0';
            end if;
          end if;

        when others => v_st := 0;

      end case;

    end if;
  end process;


end architecture beh;

