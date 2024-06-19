-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @copyright Copyright 2021 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
-------------------------------------------------------------------------------
--! @date 2021-12-09
--! @author Shweta Prasad <shweta.prasad@desy.de>
-------------------------------------------------------------------------------
--! @brief
--! This is a pipelined NxM multiplier with 6 pipelined stages using DSP48
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult_dsp48 is
  generic (
    g_a_data_width : natural;
    g_b_data_width : natural
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;
    pi_data_a : in  std_logic_vector(g_a_data_width - 1 downto 0);
    pi_data_b : in  std_logic_vector(g_b_data_width - 1 downto 0);
    po_mult   : out std_logic_vector(g_a_data_width + g_b_data_width - 1 downto 0)  ---pipelined product output
  );
end mult_dsp48;

architecture rtl of mult_dsp48 Is

  constant C_A_MSB_SHIFTED_WIDTH : natural := g_a_data_width - 18;
	constant C_B_MSB_SHIFTED_WIDTH : natural := g_b_data_width - 18;
	constant C_MULT4_WIDTH : natural := C_A_MSB_SHIFTED_WIDTH + C_B_MSB_SHIFTED_WIDTH + 1;
	constant C_U_MSB_WIDTH : natural := g_a_data_width + g_b_data_width - 1;
	constant C_L_MSB_WIDTH : natural := C_U_MSB_WIDTH - C_MULT4_WIDTH;

	type t_a_msb_shifted is array(0 To 3) of std_logic_vector(C_A_MSB_SHIFTED_WIDTH downto 0);
	type t_b_msb_shifted is array(0 To 3) of std_logic_vector(C_B_MSB_SHIFTED_WIDTH downto 0);
	type t_lsb_shifted is array(0 To 3) of std_logic_vector(16 downto 0);
	type t_final_shift is array(0 To 3) of signed(47 downto 0);
	--------------------shift registers-----------------------------
	signal a_msb_shifted : t_a_msb_shifted;
	signal b_msb_shifted : t_b_msb_shifted;
	signal a_lsb_shifted, b_lsb_shifted : t_lsb_shifted;
	signal reg_s1_shifted, reg_s3_shifted : t_final_shift;
	----------------------------------------------------------------
	--------------------registers after multiplier------------------
	signal reg_m1 : std_logic_vector(35 downto 0);
	signal reg_m2 : std_logic_vector(C_A_MSB_SHIFTED_WIDTH + 18 downto 0);
	signal reg_m3 : std_logic_vector(C_B_MSB_SHIFTED_WIDTH + 18 downto 0);
	signal reg_m4 : std_logic_vector(C_MULT4_WIDTH downto 0);
	----------------------------------------------------------------
	signal reg_s1, reg_s2, reg_s3, reg_s4 : signed(47 downto 0); ------registers after sum
	signal sig_mult : std_logic_vector(g_a_data_width + g_b_data_width - 1 downto 0);
begin

  prs_dsp48 : process (pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        a_msb_shifted  <= (others => (others => '0'));
        b_msb_shifted  <= (others => (others => '0'));
        a_lsb_shifted  <= (others => (others => '0'));
        b_lsb_shifted  <= (others => (others => '0'));
        reg_s1_shifted <= (others => (others => '0'));
        reg_s3_shifted <= (others => (others => '0'));
        reg_m1         <= (others => '0');
        reg_m2         <= (others => '0');
        reg_m3         <= (others => '0');
        reg_m4         <= (others => '0');
        reg_s1         <= (others => '0');
        reg_s2         <= (others => '0');
        reg_s3         <= (others => '0');
        reg_s4         <= (others => '0');
      else
        a_msb_shifted  <= (pi_data_a(g_a_data_width - 1 downto 17)) & a_msb_shifted(0 to a_msb_shifted'length - 2);
        b_msb_shifted  <= (pi_data_b(g_b_data_width - 1 downto 17)) & b_msb_shifted(0 to b_msb_shifted'length - 2);
        a_lsb_shifted  <= (pi_data_a(16 downto 0)) & a_lsb_shifted(0 to a_lsb_shifted'length - 2);
        b_lsb_shifted  <= (pi_data_b(16 downto 0)) & b_lsb_shifted(0 to b_lsb_shifted'length - 2);
        reg_m1         <= std_logic_vector(signed('0' & a_lsb_shifted(0)) * signed('0' & b_lsb_shifted(0)));
        reg_s1         <= resize(signed(reg_m1), 48);
        reg_m2         <= std_logic_vector(signed(a_msb_shifted(1)) * signed('0' & b_lsb_shifted(1)));
        reg_s2         <= (resize(signed(reg_m2), 48)) + (shift_right(signed(reg_s1), 17));
        reg_m3         <= std_logic_vector(signed(b_msb_shifted(2)) * signed('0' & a_lsb_shifted(2)));
        reg_s3         <= ((resize(signed(reg_m3), 48)) + (reg_s2));
        reg_m4         <= std_logic_vector(signed(a_msb_shifted(3)) * signed(b_msb_shifted(3)));
        reg_s4         <= (resize(signed(reg_m4), 48)) + (shift_right(signed(reg_s3), 17));
        reg_s1_shifted <= (reg_s1 & reg_s1_shifted(0 to reg_s1_shifted'length - 2));
        reg_s3_shifted <= (reg_s3 & reg_s3_shifted(0 to reg_s3_shifted'length - 2));
      end if;
    end if;
  end process prs_dsp48;

  --================================================================================
  -- output of pipelined multiplier
  po_mult(C_U_MSB_WIDTH downto C_L_MSB_WIDTH) <= std_logic_vector(reg_s4(C_MULT4_WIDTH downto 0));
  po_mult(C_L_MSB_WIDTH - 1 downto 17)        <= std_logic_vector(reg_s3_shifted(0)(C_L_MSB_WIDTH - 18 downto 0));
  po_mult(16 downto 0)                        <= std_logic_vector(reg_s1_shifted(2)(16 downto 0));

end rtl;
