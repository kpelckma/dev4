-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
--! @copyright  (c) 2021 DESY
--! @license    SPDX-License-Identifier: CERN-OHL-W-2.0
-------------------------------------------------------------------------------
--! @ref  git@gitlab.msktools.desy.de:fpgafw/lib/desy_math.git
--! @dir  hdl
--! @file complex_multiplier.vhd   
-------------------------------------------------------------------------------
--! @brief  Complex multiplier with overflow detection
-------------------------------------------------------------------------------
--! @author Burak Dursun
--! @email  burak.dursun@desy.de
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity complex_multiplier is 
  generic (
    G_IN0_WIDTH  : natural := 18;
    G_IN0_RADIX  : natural := 16;
    G_IN1_WIDTH  : natural := 18;
    G_IN1_RADIX  : natural := 16;
    G_OUT_WIDTH  : natural := 18;
    G_OUT_RADIX  : natural := 16
  );
  port (
    pi_clock  : in  std_logic;
    pi_reset  : in  std_logic;

    pi_valid  : in  std_logic;
    pi_re0    : in  std_logic_vector(G_IN0_WIDTH-1 downto 0);
    pi_im0    : in  std_logic_vector(G_IN0_WIDTH-1 downto 0);
    pi_re1    : in  std_logic_vector(G_IN1_WIDTH-1 downto 0);
    pi_im1    : in  std_logic_vector(G_IN1_WIDTH-1 downto 0);

    po_valid  : out std_logic;
    po_re     : out std_logic_vector(G_OUT_WIDTH-1 downto 0);
    po_im     : out std_logic_vector(G_OUT_WIDTH-1 downto 0);
    po_re_of  : out std_logic;
    po_im_of  : out std_logic
    -- component should be cascaded with the following saturation logic if required, consider using registers
    -- re_sat <= (re_sat'left => po_re(po_re'left), others => not(po_re(po_re'left))) when po_re_of = '1' else po_re;
    -- im_sat <= (im_sat'left => po_im(po_im'left), others => not(po_im(po_im'left))) when po_im_of = '1' else po_im;
  );
end complex_multiplier; 

architecture rtl of complex_multiplier is

  function fun_shift(in0_radix, in1_radix, out_radix : natural) return natural is
  begin
    if in0_radix + in1_radix > out_radix then
      return in0_radix + in1_radix - out_radix;
    else
      return 0;
    end if;
  end function fun_shift;

  constant C_SHIFT  : natural := fun_shift(G_IN0_RADIX, G_IN1_RADIX, G_OUT_RADIX);
  constant C_ZEROS  : std_logic_vector(G_IN0_WIDTH+G_IN1_WIDTH-1 downto G_OUT_WIDTH+C_SHIFT-1)  := (others => '0');
  constant C_ONES   : std_logic_vector(G_IN0_WIDTH+G_IN1_WIDTH-1 downto G_OUT_WIDTH+C_SHIFT-1)  := (others => '1');

  signal valid  : std_logic;
  signal rere   : signed(G_IN0_WIDTH+G_IN1_WIDTH-1 downto 0);
  signal reim   : signed(G_IN0_WIDTH+G_IN1_WIDTH-1 downto 0);
  signal imre   : signed(G_IN0_WIDTH+G_IN1_WIDTH-1 downto 0);
  signal imim   : signed(G_IN0_WIDTH+G_IN1_WIDTH-1 downto 0);

  type t_data_pipe is array (1 downto 0) of signed(G_IN0_WIDTH+G_IN1_WIDTH-1 downto 0);
  signal re : t_data_pipe;
  signal im : t_data_pipe;

  type t_pd_pipe is array (1 downto 0) of std_logic_vector(1 downto 0);
  signal re_pd  : t_pd_pipe;
  signal im_pd  : t_pd_pipe;

begin

  prs_valid: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        valid     <= '0';
        po_valid  <= '0';
      else
        valid     <= pi_valid;
        po_valid  <= valid;
      end if;
    end if;
  end process prs_valid;

  prs_in: process(pi_clock) 
  begin
    if rising_edge(pi_clock) then
      if pi_valid = '1' then
        rere <= signed(pi_re0) * signed(pi_re1);
        reim <= signed(pi_re0) * signed(pi_im1);
        imre <= signed(pi_im0) * signed(pi_re1);
        imim <= signed(pi_im0) * signed(pi_im1);
      end if;
    end if ;
  end process prs_in;

  re(0) <= rere - imim;
  im(0) <= reim + imre;

  re_pd(0)(0) <= '1' when std_logic_vector(re(0)(re(0)'left downto G_OUT_WIDTH+C_SHIFT-1)) = C_ZEROS  else '0';
  re_pd(0)(1) <= '1' when std_logic_vector(re(0)(re(0)'left downto G_OUT_WIDTH+C_SHIFT-1)) = C_ONES   else '0';
  im_pd(0)(0) <= '1' when std_logic_vector(im(0)(im(0)'left downto G_OUT_WIDTH+C_SHIFT-1)) = C_ZEROS  else '0';
  im_pd(0)(1) <= '1' when std_logic_vector(im(0)(im(0)'left downto G_OUT_WIDTH+C_SHIFT-1)) = C_ONES   else '0';

  prs_out: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        re(1)     <= (others => '0');
        im(1)     <= (others => '0');
        re_pd(1)  <= (others => '1');
        im_pd(1)  <= (others => '1');
      elsif valid = '1' then
        re(1)     <= re(0); 
        im(1)     <= im(0);
        re_pd(1)  <= re_pd(0);
        im_pd(1)  <= im_pd(0);
      end if;
    end if;
  end process prs_out;

  po_re <= std_logic_vector(resize(shift_right(re(1), C_SHIFT), G_OUT_WIDTH));
  po_im <= std_logic_vector(resize(shift_right(im(1), C_SHIFT), G_OUT_WIDTH));

  po_re_of <= '1' when re_pd(1) = "00" else '0';
  po_im_of <= '1' when im_pd(1) = "00" else '0';

end rtl;
