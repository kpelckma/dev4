------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021-2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2021-05-19/2022-01-05
--! @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
--! @author Katharina Schulz  <katharina.schulz@desy.de>
------------------------------------------------------------------------------
--! @brief
--! CORDIC algorithm
--!
--! Universal pipeline CORDIC.
--! Rotating or vectoring mode can be set over the generic or online over the port.
--! Currently only (Circular) system available
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--==============================================================================
-- cordic entity
--==============================================================================
entity cordic is
  generic(
    G_WORD_BIT_SIZE      : natural := 18;
    -- DEFINES CORDIC iterations and bit size, real G_INTERNAL_BIT_SIZE internal bit size = +1, max 63
    G_INTERNAL_BIT_SIZE  : natural := 20;
    G_CONFIGURATION      : natural := 0;    --0:circular, 1:linear, 2:hyperbolic
    G_OPERATING_MODE     : natural := 2;    --0: IQ->AP, 1:AP->IQ ; 2: pi_mode enabled,
    G_PIPELINED          : boolean := true;
    G_DUAL_CLK_EDGE      : boolean := false;
    G_SCALE              : boolean := true;
    G_SCALE_BIT_SIZE     : natural := 18
  );
  port(
    pi_clock : in std_logic := '0';
    pi_reset : in std_logic := '0';     --active low
    pi_mode  : in std_logic := '0';     --'0':IQ->AP vectoring, '1':AP->IQ rotating,

    pi_valid : in std_logic;
    pi_x     : in std_logic_vector(G_WORD_BIT_SIZE-1 downto 0) := (others => '0');
    pi_y     : in std_logic_vector(G_WORD_BIT_SIZE-1 downto 0) := (others => '0');
    pi_z     : in std_logic_vector(G_WORD_BIT_SIZE-1 downto 0) := (others => '0');

    po_x     : out std_logic_vector(G_WORD_BIT_SIZE-1 downto 0);
    po_y     : out std_logic_vector(G_WORD_BIT_SIZE-1 downto 0);
    po_z     : out std_logic_vector(G_WORD_BIT_SIZE-1 downto 0);
    po_valid : out std_logic
  );
end entity cordic;
--==============================================================================
architecture arch of cordic is

  -- internal data size
  constant C_DATA_SIZE        : natural := G_INTERNAL_BIT_SIZE;
  constant C_DATA_FIXPOINT    : natural := G_INTERNAL_BIT_SIZE-1;
  constant C_ADDED_BITS       : natural := G_INTERNAL_BIT_SIZE-G_WORD_BIT_SIZE;

  type t_cordic_array is array(natural range <>) of signed(C_DATA_SIZE downto 0);
  type t_angle_array is array(natural range <>) of signed(64-1 downto 0);

  signal operating_mode   : std_logic := '0'; -- 0 vectoring 1 - rotating
  -------------------
  signal x_data           : t_cordic_array(C_DATA_SIZE downto 0) := (others => (others => '0'));
  signal y_data           : t_cordic_array(C_DATA_SIZE downto 0) := (others => (others => '0'));
  signal z_data           : t_cordic_array(C_DATA_SIZE downto 0) := (others => (others => '0'));
  signal valid            : std_logic_vector(C_DATA_SIZE downto 0) := (others => '0');
  signal sign             : std_logic_vector(C_DATA_SIZE-1 downto 0) := (others => '0');

  signal stage_clock      : std_logic_vector(C_DATA_SIZE-1 downto 0) := (others => '0');

  signal input_reset : std_logic;
  signal input_valid : std_logic;
  signal input_x     : std_logic_vector(G_WORD_BIT_SIZE-1 downto 0) := (others => '0');
  signal input_y     : std_logic_vector(G_WORD_BIT_SIZE-1 downto 0) := (others => '0');
  signal input_z     : std_logic_vector(G_WORD_BIT_SIZE-1 downto 0) := (others => '0');

  ------------------------------------------------------------------------------
  --! function, procedures
  ------------------------------------------------------------------------------
  function fun_gen_angle_table return t_cordic_array is
    variable v_angle_table : t_cordic_array(0 to C_DATA_SIZE-1) := (others => (others => '0'));
    variable v_full_table  : t_angle_array (0 to 64-1);
    variable v_angle       : signed(C_DATA_SIZE downto 0);
  begin
    if G_CONFIGURATION = 0 then
      v_full_table := (
        x"2000000000000000", x"12E4051D9DF30800", x"09FB385B5EE39E80", x"051111D41DDD9A40", x"028B0D430E589B00", x"0145D7E159046280", x"00A2F61E5C282630", x"00517C5511D442B0",
        x"0028BE5346D0C338", x"00145F2EBB30AB38", x"000A2F980091BA7C", x"000517CC14A80CB7", x"00028BE60CDFEC62", x"000145F306C172F2", x"0000A2F9836AE911", x"0000517CC1B6BA7C",
        x"000028BE60DB85FC", x"0000145F306DC816", x"00000A2F9836E4AE", x"00000517CC1B726B", x"0000028BE60DB938", x"00000145F306DC9C", x"000000A2F9836E4E", x"000000517CC1B727",
        x"00000028BE60DB94", x"000000145F306DCA", x"0000000A2F9836E5", x"0000000517CC1B72", x"000000028BE60DB9", x"0000000145F306DD", x"00000000A2F9836E", x"00000000517CC1B7",
        x"0000000028BE60DC", x"00000000145F306E", x"000000000A2F9837", x"000000000517CC1B", x"00000000028BE60E", x"000000000145F307", x"0000000000A2F983", x"0000000000517CC2",
        x"000000000028BE61", x"0000000000145F30", x"00000000000A2F98", x"00000000000517CC", x"0000000000028BE6", x"00000000000145F3", x"000000000000A2FA", x"000000000000517D",
        x"00000000000028BE", x"000000000000145F", x"0000000000000A30", x"0000000000000518", x"000000000000028C", x"0000000000000146", x"00000000000000A3", x"0000000000000051",
        x"0000000000000029", x"0000000000000014", x"000000000000000A", x"0000000000000005", x"0000000000000003", x"0000000000000001", x"0000000000000001", x"0000000000000000");

      for iteration_cnt in 0 to C_DATA_SIZE-1 loop
        -- recalculate angle by shift with rounding
        if v_full_table(iteration_cnt)(64-C_DATA_SIZE-1) = '1' then
          v_angle := resize(v_full_table(iteration_cnt)(64-1 downto 64-C_DATA_SIZE),C_DATA_SIZE+1) + 1;
        else
          v_angle := resize(v_full_table(iteration_cnt)(64-1 downto 64-C_DATA_SIZE),C_DATA_SIZE+1);
        end if;
        v_angle_table(iteration_cnt) := v_angle ;
      end loop;

    else
       assert false report "Wrong CORDIC configuration setting. Now only Circular mode supported." severity error;
    end if;
    return v_angle_table;
  end function;

  ------------------------------------------------------------------------------
  function fun_gen_90deg_angle return signed is
    variable v_angle       : signed(63 downto 0);
  begin
--    if G_CONFIGURATION = 0 then
    -- pi/2 for initial stage
    v_angle := x"4000000000000000" ;
    return resize(v_angle(64-1 downto 64-C_DATA_SIZE),C_DATA_SIZE+1);
--    end if;
  end function;
  ------------------------------------------------------------------------------
  function fun_gain_correction(length: natural) return signed is
    variable v_gain            : signed(63 downto 0) ;
    variable v_result          : signed(length-1 downto 0) := (others => '0');          --An
  begin
    if G_CONFIGURATION = 0 then
      v_gain := x"4DBA76D421AF3000"; -- 0.6072529350088813 in 64 bit with 63 fixed points
      v_result := resize(v_gain(64-1 downto 64-length), length);
    elsif G_CONFIGURATION = 1 then
      v_result := to_signed(integer(1.0), length);

    end if;
    -- report "gain:  " & integer'image(integer(to_integer(C_GAIN_CORRECTION)));
    return v_result;
  end function;

  ------------------------------------------------------------------------------
  function fun_resize (arg : signed; length : natural  ) return std_logic_vector is
    variable result    : std_logic_vector(length-1 downto 0) ;
    variable all_ones  : std_logic_vector(arg'length-1 downto length-1) := (others => '1');
    variable all_zeros : std_logic_vector(arg'length-1 downto length-1) := (others => '0');
  begin
    if length < arg'length then
      if arg( arg'length-1 ) = '1' and std_logic_vector(arg( arg'length-1 downto length-1 )) /= all_ones then
        result(length-2 downto 0) := ( others => '0' ) ;
        result(length-1) := '1' ;
        return result ;
      elsif arg( arg'length-1 ) = '0' and std_logic_vector(arg( arg'length-1 downto length-1 )) /= all_zeros then
        result(length-2 downto 0) := ( others => '1' ) ;
        result(length-1) := '0' ;
        return result ;
      else
        return std_logic_vector(arg(length-1 downto 0));
      end if;
    elsif length > arg'length then
      result := ( others => arg(arg'length-1) ) ;
      result(arg'length-1 downto 0) := std_logic_vector(arg) ;
      return result ;
    else -- length = arg'length
      return std_logic_vector(arg) ;
    end if;
  end function;
  ------------------------------------------------------------------------------
  function fun_get_sign(par_x, par_y, par_z : signed;
                        par_operating_mode  : std_logic
  ) return std_logic is
  begin
    if (par_operating_mode = '0') then
      --vectoring sign
      if par_y <= 0 then
        return '0';
      else
        return '1';
      end if;
--       return not par_y(par_y'left);
    else
      --rotating sign
      if par_z >= 0  then
        return '0';
      else
        return '1';
      end if;
--      return par_z(par_z'left);
    end if;
  end function;
  ------------------------------------------------------------------------------
  function fun_new_x(par_x, par_y, par_z : signed;
                     par_sign            : std_logic;
                     par_shift           : natural) return signed is
    variable v_new_x  : signed(par_x'range) := (others => '0');
    variable v_round  : signed(0 downto 0) := (others => '0');
  begin
    if par_shift > 0 then
      v_round(0) := par_y(par_shift-1);
    else
      v_round(0) := '0';
    end if;
    if (par_sign = '1') then
      v_new_x := par_x + resize(shift_right(par_y, par_shift), par_x'length) - v_round;
    else
      v_new_x := par_x - resize(shift_right(par_y, par_shift), par_x'length) + v_round;
    end if;
    return v_new_x;
  end function;
  ------------------------------------------------------------------------------
  function fun_new_y(par_x, par_y, par_z : signed;
                     par_sign            : std_logic;
                     par_shift           : natural) return signed is
    variable v_new_y  : signed(par_y'range) := (others => '0');
    variable v_round  : signed(0 downto 0) := (others => '0');
  begin
    if par_shift > 0 then
      v_round(0) := par_x(par_shift-1);
    else
      v_round(0) := '0';
    end if;
    if (par_sign = '1') then
      v_new_y := par_y - resize(shift_right(par_x, par_shift), par_y'length) + v_round;
    else
      v_new_y := par_y + resize(shift_right(par_x, par_shift), par_y'length) - v_round;
    end if;

    return v_new_y;
  end function;
  ------------------------------------------------------------------------------
  function fun_new_z(par_angle, par_z : signed;
                     par_sign  : std_logic) return signed is
    variable v_new_z : signed(par_z'range) := (others => '0');  --temporary variable
  begin
    if (par_sign = '1') then
      v_new_z := par_z + par_angle;
    else
      v_new_z := par_z - par_angle;
    end if;
    return v_new_z;
  end function;
  ------------------------------------------------------------------------------
  function fun_set_op_mode (mode : std_logic) return std_logic is
  begin
    if g_operating_mode = 0 then
      return '0';
    elsif g_operating_mode = 1 then
      return '1';
    else
      return mode;
    end if;
  end fun_set_op_mode;

  ------------------------------------------------------------------------------

  constant C_ANGLE_TABLE   : t_cordic_array(0 to C_DATA_SIZE-1) := fun_gen_angle_table;
  constant C_ANGLE_90DEG   : signed := fun_gen_90deg_angle;
  constant C_CORDIC_NORM   : signed(G_SCALE_BIT_SIZE-1 downto 0) := fun_gain_correction(G_SCALE_BIT_SIZE);

begin

  --============================================================================
  -- generate clock for stage
  --============================================================================
  gen_double_edge_clk: if G_DUAL_CLK_EDGE = true generate
    assert C_DATA_SIZE mod 2 = 0
    report "cordic.vhd: G_INTERNAL_BIT_SIZE has to be even if G_DUAL_CLK_EDGE = true, value: "
    & integer'image(G_INTERNAL_BIT_SIZE) severity error;

    gen_clk : for idx in 0 to C_DATA_SIZE/2-1 generate
      stage_clock(2*idx)   <= pi_clock;
      stage_clock(2*idx+1) <= not pi_clock;
    end generate;
  end generate;

  gen_single_edge_clk: if G_DUAL_CLK_EDGE = false generate
    gen_clk : for idx in 0 to C_DATA_SIZE-1 generate
      stage_clock(idx)   <= pi_clock;
    end generate;
  end generate;

  -- reassign input the same as clock to work in simulation
  input_reset <= pi_reset;
  input_valid <= pi_valid;
  input_x     <= pi_x;
  input_y     <= pi_y;
  input_z     <= pi_z;

  --============================================================================
  -- set operating mode
  --============================================================================
  -- TODO make operating mode pipe over stages
  operating_mode <= fun_set_op_mode(pi_mode) ;

  --============================================================================
  -- CORDIC Init Stege
  -- move to the I or IV quadrant, CORDIC work area,
  -- done by rotation by 90 deg based on data sign
  -- I -> IV, II -> I , III -> IV , IV -> I
  --
  --        ^
  --        |
  --    II  |   I
  --        |
  -- -------+-------->
  --        |
  --   III  |   IV
  --        |
  --
  --============================================================================
  gen_circular_init_stage : if G_CONFIGURATION = 0 generate
  begin

    prs_90deg_rot : process(stage_clock(0))
    begin
      if rising_edge(stage_clock(0)) then
        if input_reset = '1' then
          valid(0)  <= '0';
          x_data(0) <= (others => '0');
          y_data(0) <= (others => '0');
          z_data(0) <= (others => '0');
        else
          valid(0)  <= input_valid;
          if input_valid = '1' then
            if operating_mode = '0' then

              if signed(input_y) <= 0 then
                x_data(0) <= -resize(signed(input_y), C_DATA_SIZE+1);
                y_data(0) <= resize(signed(input_x), C_DATA_SIZE+1);
                z_data(0) <= -C_ANGLE_90DEG;
              else
                x_data(0) <= resize(signed(input_y), C_DATA_SIZE+1);
                y_data(0) <= -resize(signed(input_x), C_DATA_SIZE+1);
                z_data(0) <= C_ANGLE_90DEG ;
              end if;

            else
              if signed(input_z) >= 0 then
                x_data(0) <= resize(signed(input_y), C_DATA_SIZE+1);
                y_data(0) <= resize(signed(input_x), C_DATA_SIZE+1);
                z_data(0) <= -(shift_left(resize(signed(input_z),C_DATA_SIZE+1),C_ADDED_BITS)) + C_ANGLE_90DEG;
              else
                x_data(0) <= -resize(signed(input_y), C_DATA_SIZE+1);
                y_data(0) <= -resize(signed(input_x), C_DATA_SIZE+1);
                z_data(0) <= -(shift_left(resize(signed(input_z),C_DATA_SIZE+1),C_ADDED_BITS)) - C_ANGLE_90DEG;
              end if;
            end if; -- mode
          end if;  --valid
        end if;   --reset
      end if;   --rising_edge
    end process;

  end generate gen_circular_init_stage;

  --============================================================================
  -- CORDIC Stege 0:n-1
  --============================================================================
  gen_stages : for STAGE in 0 to C_DATA_SIZE - 1 generate
  begin
    sign(STAGE) <= fun_get_sign(x_data(STAGE),y_data(STAGE),z_data(STAGE),operating_mode);

    prs_stage: process(stage_clock(STAGE))
    begin
      if rising_edge(stage_clock(STAGE)) then
        valid(STAGE+1) <= valid(STAGE);
        if valid(STAGE) = '1' then
          x_data(STAGE+1) <= fun_new_x( x_data(STAGE), y_data(STAGE), z_data(STAGE), sign(STAGE), STAGE);
          y_data(STAGE+1) <= fun_new_y( x_data(STAGE), y_data(STAGE), z_data(STAGE), sign(STAGE), STAGE);
          z_data(STAGE+1) <= fun_new_z( C_ANGLE_TABLE(STAGE), z_data(STAGE), sign(STAGE));
        end if;
      end if;
    end process prs_stage;
  end generate gen_stages;

  --============================================================================
  -- CORDIC Out Stege, resize and optionally scale
  --============================================================================
  -- TODO: improve out stage for scale case,
  -- need DSP patter recognition for overflow protection to improve timing
  ------------------------------------------------------------------------------
  gen_no_scale_out : if G_SCALE = false generate
    prs_out : process(stage_clock(0))
    begin
      if rising_edge(stage_clock(0)) then
        if input_reset = '1' then
          po_x     <= (others => '0');
          po_y     <= (others => '0');
          po_z     <= (others => '0');
          po_valid <= '0';
        else
          if valid(C_DATA_SIZE) = '1' then
            if operating_mode = '0' then     --IQ -> AP
              po_x <= fun_resize(x_data(C_DATA_SIZE), G_WORD_BIT_SIZE);
              po_y <= (others => '0');
              po_z <= fun_resize(shift_right(z_data(C_DATA_SIZE),C_ADDED_BITS), G_WORD_BIT_SIZE);
            else                      --AP -> IQ
              po_x <= fun_resize(-x_data(C_DATA_SIZE), G_WORD_BIT_SIZE);
              po_y <= fun_resize(y_data(C_DATA_SIZE), G_WORD_BIT_SIZE);
              po_z <= (others => '0');
            end if;  --operating_mode
          end if;  --valid
          po_valid <= valid(C_DATA_SIZE);
        end if;  --reset
      end if;  --rising_edge
    end process prs_out;
  end generate gen_no_scale_out;

  gen_scale_out : if G_SCALE = true generate
    signal l_x_data : signed(G_SCALE_BIT_SIZE + C_DATA_SIZE downto 0);
    signal l_y_data : signed(G_SCALE_BIT_SIZE + C_DATA_SIZE downto 0);
    signal l_z_data : signed(C_DATA_SIZE downto 0);
    signal l_valid  : std_logic;
  begin
    prs_scale: process(stage_clock(0))
    begin
      if rising_edge(stage_clock(0)) then
        l_x_data <= x_data(C_DATA_SIZE)*C_CORDIC_NORM;
        l_y_data <= y_data(C_DATA_SIZE)*C_CORDIC_NORM;
        l_z_data <= shift_right(z_data(C_DATA_SIZE), C_ADDED_BITS);
        l_valid  <= valid(C_DATA_SIZE);
      end if;
    end process prs_scale;

    prs_out : process(stage_clock(0))
    begin
      if rising_edge(stage_clock(0)) then
        if input_reset = '1' then
          po_x     <= (others => '0');
          po_y     <= (others => '0');
          po_z     <= (others => '0');
          po_valid <= '0';
        else
          if l_valid = '1' then
            if operating_mode = '0' then     --IQ -> AP
              po_x <= fun_resize(shift_right(l_x_data, G_SCALE_BIT_SIZE-1), G_WORD_BIT_SIZE);
              po_y <= (others => '0');
              po_z <= fun_resize(l_z_data, G_WORD_BIT_SIZE);
            else                      --AP -> IQ
              po_x <= fun_resize(-(shift_right(l_x_data, G_SCALE_BIT_SIZE-1)), G_WORD_BIT_SIZE);
              po_y <= fun_resize(shift_right(l_y_data, G_SCALE_BIT_SIZE-1), G_WORD_BIT_SIZE);
              po_z <= (others => '0');
            end if;
          end if;
          po_valid <= l_valid;
        end if;  --reset
      end if;  --rising_edge
    end process prs_out;
  end generate gen_scale_out;

end arch;
