------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2022-07-25
------------------------------------------------------------------------------
--! @brief
--! MTCA.4 RTM interface definitions
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package common_rtm is

  -- Digital signals in the user zone:
  -- Class D1.0: 48 LVDS I/O signals
  -- Class D1.1: 42 LVDS I/O signals, 2 high-speed links
  -- Class D1.2: 38 LVDS I/O signals, 4 high-speed links
  -- Class D1.3: 28 LVDS I/O signals, 8 high-speed links
  -- Class D1.4: 8 LVDS I/O signals, 16 high-speed links

  -- inverted P/N pin mask, 0 - no inversion 1 - inversion
  subtype t_rtm_io_d10_inv_mask is std_logic_vector(47 downto 0);
  subtype t_rtm_io_d11_inv_mask is std_logic_vector(41 downto 0);
  subtype t_rtm_io_d12_inv_mask is std_logic_vector(37 downto 0);
  subtype t_rtm_io_d13_inv_mask is std_logic_vector(27 downto 0);
  subtype t_rtm_io_d14_inv_mask is std_logic_vector(7 downto 0);

  -- RTM IO types
  type t_rtm_io_d10 is record
    io_p   : std_logic_vector(47 downto 0);
    io_n   : std_logic_vector(47 downto 0);
  end record t_rtm_io_d10;

  type t_rtm_io_d11 is record
    io_p   : std_logic_vector(41 downto 0);
    io_n   : std_logic_vector(41 downto 0);
  end record t_rtm_io_d11;

  type t_rtm_io_d12 is record
    io_p   : std_logic_vector(37 downto 0);
    io_n   : std_logic_vector(37 downto 0);
  end record t_rtm_io_d12;

  type t_rtm_io_d13 is record
    io_p   : std_logic_vector(27 downto 0);
    io_n   : std_logic_vector(27 downto 0);
  end record t_rtm_io_d13;

  type t_rtm_io_d14 is record
    io_p   : std_logic_vector(7 downto 0);
    io_n   : std_logic_vector(7 downto 0);
  end record t_rtm_io_d14;

  subtype t_rtm_io is t_rtm_io_d10; --  default is class D1.0, maximum IO count

  -- e.g. f_get_rtm_pin("J30","5","a",pio_rtm_io);
  --?? e.g. alternative ? f_get_rtm_pin("J30_5_a",pio_rtm_io); ??
  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d10 ) return std_logic;
  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d11 ) return std_logic;
  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d12 ) return std_logic;
  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d13 ) return std_logic;
  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d14 ) return std_logic;

  function f_rtm_io_d10_idx ( connector, column , row : string ) return natural;
  function f_rtm_io_d11_idx ( connector, column , row : string ) return natural;
  function f_rtm_io_d12_idx ( connector, column , row : string ) return natural;
  function f_rtm_io_d13_idx ( connector, column , row : string ) return natural;
  function f_rtm_io_d14_idx ( connector, column , row : string ) return natural;

  function f_rtm_mask_d10_to_d11 ( arg_rtm_mask : t_rtm_io_d10_inv_mask ) return t_rtm_io_d11_inv_mask;
  function f_rtm_mask_d10_to_d12 ( arg_rtm_mask : t_rtm_io_d10_inv_mask ) return t_rtm_io_d12_inv_mask;
  function f_rtm_mask_d10_to_d13 ( arg_rtm_mask : t_rtm_io_d10_inv_mask ) return t_rtm_io_d13_inv_mask;
  function f_rtm_mask_d10_to_d14 ( arg_rtm_mask : t_rtm_io_d10_inv_mask ) return t_rtm_io_d14_inv_mask;
  function f_rtm_mask_d11_to_d10 ( arg_rtm_mask : t_rtm_io_d11_inv_mask ) return t_rtm_io_d10_inv_mask;
  function f_rtm_mask_d11_to_d12 ( arg_rtm_mask : t_rtm_io_d11_inv_mask ) return t_rtm_io_d12_inv_mask;
  function f_rtm_mask_d11_to_d13 ( arg_rtm_mask : t_rtm_io_d11_inv_mask ) return t_rtm_io_d13_inv_mask;
  function f_rtm_mask_d11_to_d14 ( arg_rtm_mask : t_rtm_io_d11_inv_mask ) return t_rtm_io_d14_inv_mask;
  function f_rtm_mask_d12_to_d10 ( arg_rtm_mask : t_rtm_io_d12_inv_mask ) return t_rtm_io_d10_inv_mask;
  function f_rtm_mask_d12_to_d11 ( arg_rtm_mask : t_rtm_io_d12_inv_mask ) return t_rtm_io_d11_inv_mask;
  function f_rtm_mask_d12_to_d13 ( arg_rtm_mask : t_rtm_io_d12_inv_mask ) return t_rtm_io_d13_inv_mask;
  function f_rtm_mask_d12_to_d14 ( arg_rtm_mask : t_rtm_io_d12_inv_mask ) return t_rtm_io_d14_inv_mask;
  function f_rtm_mask_d13_to_d10 ( arg_rtm_mask : t_rtm_io_d13_inv_mask ) return t_rtm_io_d10_inv_mask;
  function f_rtm_mask_d13_to_d11 ( arg_rtm_mask : t_rtm_io_d13_inv_mask ) return t_rtm_io_d11_inv_mask;
  function f_rtm_mask_d13_to_d12 ( arg_rtm_mask : t_rtm_io_d13_inv_mask ) return t_rtm_io_d12_inv_mask;
  function f_rtm_mask_d13_to_d14 ( arg_rtm_mask : t_rtm_io_d13_inv_mask ) return t_rtm_io_d14_inv_mask;
  function f_rtm_mask_d14_to_d10 ( arg_rtm_mask : t_rtm_io_d14_inv_mask ) return t_rtm_io_d10_inv_mask;
  function f_rtm_mask_d14_to_d11 ( arg_rtm_mask : t_rtm_io_d14_inv_mask ) return t_rtm_io_d11_inv_mask;
  function f_rtm_mask_d14_to_d12 ( arg_rtm_mask : t_rtm_io_d14_inv_mask ) return t_rtm_io_d12_inv_mask;
  function f_rtm_mask_d14_to_d13 ( arg_rtm_mask : t_rtm_io_d14_inv_mask ) return t_rtm_io_d13_inv_mask;

  --! If limited functionality is allowed or RTM IO supports multiple standards, the type conversion can be done
  --! RTM class conversion can be done on entity pins only - functions on port might not work on some tools
  --! examples
  --  RTM class 1.0 <- AMC class 1.1
  --   pio_rtm.io_p(41 downto 0)  => pio_rtm.io_p(41 downto 0),
  --   pio_rtm.io_p(47 downto 42) => not_used_p(47 downto 42),
  --   pio_rtm.io_n(41 downto 0)  => pio_rtm.io_n(41 downto 0),
  --   pio_rtm.io_n(47 downto 42) => not_used_n(47 downto 42)

  --  RTM class 1.1 <- AMC class 1.0
  --   pio_rtm.io_p(41 downto 0) => pio_rtm.io_p(41 downto 0),
  --   pio_rtm.io_n(41 downto 0) => pio_rtm.io_n(41 downto 0),

  -- RTM class 1.2 <- AMC class 1.0 (remap j31_8_ab)
  --   pio_rtm.io_p(36 downto 0) => pio_rtm.io_p(36 downto 0),
  --   pio_rtm.io_n(36 downto 0) => pio_rtm.io_n(36 downto 0),
  --   pio_rtm.io_p(37)          => pio_rtm.io_p(39),
  --   pio_rtm.io_n(37)          => pio_rtm.io_n(39),

  -- RTM class 1.3 <- AMC class 1.0 (remap j31_4_ab, j31_7_ab, j31_8_ab)
  --   pio_rtm.io_p(24 downto 0) => pio_rtm.io_p(24 downto 0),
  --   pio_rtm.io_n(24 downto 0) => pio_rtm.io_n(24 downto 0),
  --   pio_rtm.io_p(25)          => pio_rtm.io_p(27),
  --   pio_rtm.io_n(25)          => pio_rtm.io_n(27),
  --   pio_rtm.io_p(26)          => pio_rtm.io_p(36),
  --   pio_rtm.io_n(26)          => pio_rtm.io_n(36),
  --   pio_rtm.io_p(27)          => pio_rtm.io_p(39),
  --   pio_rtm.io_n(27)          => pio_rtm.io_n(39),

  -- RTM class 1.4 <- AMC class 1.0 (remap j30_5_ab, j30_6_ab, j30_9_ab, j30_10_ab, j31_3_ab, j31_4_ab, j31_7_ab, j31_8_ab)
  --   pio_rtm.io_p(0) => pio_rtm.io_p(0),
  --   pio_rtm.io_n(0) => pio_rtm.io_n(0),
  --   pio_rtm.io_p(1) => pio_rtm.io_p(3),
  --   pio_rtm.io_n(1) => pio_rtm.io_n(3),
  --   pio_rtm.io_p(2) => pio_rtm.io_p(12),
  --   pio_rtm.io_n(2) => pio_rtm.io_n(12),
  --   pio_rtm.io_p(3) => pio_rtm.io_p(15),
  --   pio_rtm.io_n(3) => pio_rtm.io_n(15),
  --   pio_rtm.io_p(4) => pio_rtm.io_p(24),
  --   pio_rtm.io_n(4) => pio_rtm.io_n(24),
  --   pio_rtm.io_p(5) => pio_rtm.io_p(27),
  --   pio_rtm.io_n(5) => pio_rtm.io_n(27),
  --   pio_rtm.io_p(6) => pio_rtm.io_p(36),
  --   pio_rtm.io_n(6) => pio_rtm.io_n(36),
  --   pio_rtm.io_p(7) => pio_rtm.io_p(39),
  --   pio_rtm.io_n(7) => pio_rtm.io_n(39),

end package;

--==============================================================================
package body common_rtm is

  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d10 ) return std_logic is
  begin
    case connector & "_" & row & "_" & column is
      when "j30_5_a" => return rtm_io.io_p(0);
      when "j30_5_b" => return rtm_io.io_n(0);
      when "j30_5_c" => return rtm_io.io_p(1);
      when "j30_5_d" => return rtm_io.io_n(1);
      when "j30_5_e" => return rtm_io.io_p(2);
      when "j30_5_f" => return rtm_io.io_n(2);
      when "j30_6_a" => return rtm_io.io_p(3);
      when "j30_6_b" => return rtm_io.io_n(3);
      when "j30_6_c" => return rtm_io.io_p(4);
      when "j30_6_d" => return rtm_io.io_n(4);
      when "j30_6_e" => return rtm_io.io_p(5);
      when "j30_6_f" => return rtm_io.io_n(5);
      when "j30_7_a" => return rtm_io.io_p(6);
      when "j30_7_b" => return rtm_io.io_n(6);
      when "j30_7_c" => return rtm_io.io_p(7);
      when "j30_7_d" => return rtm_io.io_n(7);
      when "j30_7_e" => return rtm_io.io_p(8);
      when "j30_7_f" => return rtm_io.io_n(8);
      when "j30_8_a" => return rtm_io.io_p(9);
      when "j30_8_b" => return rtm_io.io_n(9);
      when "j30_8_c" => return rtm_io.io_p(10);
      when "j30_8_d" => return rtm_io.io_n(10);
      when "j30_8_e" => return rtm_io.io_p(11);
      when "j30_8_f" => return rtm_io.io_n(11);
      when "j30_9_a" => return rtm_io.io_p(12);
      when "j30_9_b" => return rtm_io.io_n(12);
      when "j30_9_c" => return rtm_io.io_p(13);
      when "j30_9_d" => return rtm_io.io_n(13);
      when "j30_9_e" => return rtm_io.io_p(14);
      when "j30_9_f" => return rtm_io.io_n(14);
      when "j30_10_a" => return rtm_io.io_p(15);
      when "j30_10_b" => return rtm_io.io_n(15);
      when "j30_10_c" => return rtm_io.io_p(16);
      when "j30_10_d" => return rtm_io.io_n(16);
      when "j30_10_e" => return rtm_io.io_p(17);
      when "j30_10_f" => return rtm_io.io_n(17);
      when "j31_1_a" => return rtm_io.io_p(18);
      when "j31_1_b" => return rtm_io.io_n(18);
      when "j31_1_c" => return rtm_io.io_p(19);
      when "j31_1_d" => return rtm_io.io_n(19);
      when "j31_1_e" => return rtm_io.io_p(20);
      when "j31_1_f" => return rtm_io.io_n(20);
      when "j31_2_a" => return rtm_io.io_p(21);
      when "j31_2_b" => return rtm_io.io_n(21);
      when "j31_2_c" => return rtm_io.io_p(22);
      when "j31_2_d" => return rtm_io.io_n(22);
      when "j31_2_e" => return rtm_io.io_p(23);
      when "j31_2_f" => return rtm_io.io_n(23);
      when "j31_3_a" => return rtm_io.io_p(24);
      when "j31_3_b" => return rtm_io.io_n(24);
      when "j31_3_c" => return rtm_io.io_p(25);
      when "j31_3_d" => return rtm_io.io_n(25);
      when "j31_3_e" => return rtm_io.io_p(26);
      when "j31_3_f" => return rtm_io.io_n(26);
      when "j31_4_a" => return rtm_io.io_p(27);
      when "j31_4_b" => return rtm_io.io_n(27);
      when "j31_4_c" => return rtm_io.io_p(28);
      when "j31_4_d" => return rtm_io.io_n(28);
      when "j31_4_e" => return rtm_io.io_p(29);
      when "j31_4_f" => return rtm_io.io_n(29);
      when "j31_5_a" => return rtm_io.io_p(30);
      when "j31_5_b" => return rtm_io.io_n(30);
      when "j31_5_c" => return rtm_io.io_p(31);
      when "j31_5_d" => return rtm_io.io_n(31);
      when "j31_5_e" => return rtm_io.io_p(32);
      when "j31_5_f" => return rtm_io.io_n(32);
      when "j31_6_a" => return rtm_io.io_p(33);
      when "j31_6_b" => return rtm_io.io_n(33);
      when "j31_6_c" => return rtm_io.io_p(34);
      when "j31_6_d" => return rtm_io.io_n(34);
      when "j31_6_e" => return rtm_io.io_p(35);
      when "j31_6_f" => return rtm_io.io_n(35);
      when "j31_7_a" => return rtm_io.io_p(36);
      when "j31_7_b" => return rtm_io.io_n(36);
      when "j31_7_c" => return rtm_io.io_p(37);
      when "j31_7_d" => return rtm_io.io_n(37);
      when "j31_7_e" => return rtm_io.io_p(38);
      when "j31_7_f" => return rtm_io.io_n(38);
      when "j31_8_a" => return rtm_io.io_p(39);
      when "j31_8_b" => return rtm_io.io_n(39);
      when "j31_8_c" => return rtm_io.io_p(40);
      when "j31_8_d" => return rtm_io.io_n(40);
      when "j31_8_e" => return rtm_io.io_p(41);
      when "j31_8_f" => return rtm_io.io_n(41);
      when "j31_9_a" => return rtm_io.io_p(42);
      when "j31_9_b" => return rtm_io.io_n(42);
      when "j31_9_c" => return rtm_io.io_p(43);
      when "j31_9_d" => return rtm_io.io_n(43);
      when "j31_9_e" => return rtm_io.io_p(44);
      when "j31_9_f" => return rtm_io.io_n(44);
      when "j31_10_a" => return rtm_io.io_p(45);
      when "j31_10_b" => return rtm_io.io_n(45);
      when "j31_10_c" => return rtm_io.io_p(46);
      when "j31_10_d" => return rtm_io.io_n(46);
      when "j31_10_e" => return rtm_io.io_p(47);
      when "j31_10_f" => return rtm_io.io_n(47);
      when others  =>
        report "Wrong RTM Class D1.0 connector settings: " & connector & column & row  severity error;
    end case;
  end function f_get_rtm_pin;


  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d11 ) return std_logic is
  begin
    case connector & "_" & row & "_" & column is
      when "j30_5_a" => return rtm_io.io_p(0);
      when "j30_5_b" => return rtm_io.io_n(0);
      when "j30_5_c" => return rtm_io.io_p(1);
      when "j30_5_d" => return rtm_io.io_n(1);
      when "j30_5_e" => return rtm_io.io_p(2);
      when "j30_5_f" => return rtm_io.io_n(2);
      when "j30_6_a" => return rtm_io.io_p(3);
      when "j30_6_b" => return rtm_io.io_n(3);
      when "j30_6_c" => return rtm_io.io_p(4);
      when "j30_6_d" => return rtm_io.io_n(4);
      when "j30_6_e" => return rtm_io.io_p(5);
      when "j30_6_f" => return rtm_io.io_n(5);
      when "j30_7_a" => return rtm_io.io_p(6);
      when "j30_7_b" => return rtm_io.io_n(6);
      when "j30_7_c" => return rtm_io.io_p(7);
      when "j30_7_d" => return rtm_io.io_n(7);
      when "j30_7_e" => return rtm_io.io_p(8);
      when "j30_7_f" => return rtm_io.io_n(8);
      when "j30_8_a" => return rtm_io.io_p(9);
      when "j30_8_b" => return rtm_io.io_n(9);
      when "j30_8_c" => return rtm_io.io_p(10);
      when "j30_8_d" => return rtm_io.io_n(10);
      when "j30_8_e" => return rtm_io.io_p(11);
      when "j30_8_f" => return rtm_io.io_n(11);
      when "j30_9_a" => return rtm_io.io_p(12);
      when "j30_9_b" => return rtm_io.io_n(12);
      when "j30_9_c" => return rtm_io.io_p(13);
      when "j30_9_d" => return rtm_io.io_n(13);
      when "j30_9_e" => return rtm_io.io_p(14);
      when "j30_9_f" => return rtm_io.io_n(14);
      when "j30_10_a" => return rtm_io.io_p(15);
      when "j30_10_b" => return rtm_io.io_n(15);
      when "j30_10_c" => return rtm_io.io_p(16);
      when "j30_10_d" => return rtm_io.io_n(16);
      when "j30_10_e" => return rtm_io.io_p(17);
      when "j30_10_f" => return rtm_io.io_n(17);
      when "j31_1_a" => return rtm_io.io_p(18);
      when "j31_1_b" => return rtm_io.io_n(18);
      when "j31_1_c" => return rtm_io.io_p(19);
      when "j31_1_d" => return rtm_io.io_n(19);
      when "j31_1_e" => return rtm_io.io_p(20);
      when "j31_1_f" => return rtm_io.io_n(20);
      when "j31_2_a" => return rtm_io.io_p(21);
      when "j31_2_b" => return rtm_io.io_n(21);
      when "j31_2_c" => return rtm_io.io_p(22);
      when "j31_2_d" => return rtm_io.io_n(22);
      when "j31_2_e" => return rtm_io.io_p(23);
      when "j31_2_f" => return rtm_io.io_n(23);
      when "j31_3_a" => return rtm_io.io_p(24);
      when "j31_3_b" => return rtm_io.io_n(24);
      when "j31_3_c" => return rtm_io.io_p(25);
      when "j31_3_d" => return rtm_io.io_n(25);
      when "j31_3_e" => return rtm_io.io_p(26);
      when "j31_3_f" => return rtm_io.io_n(26);
      when "j31_4_a" => return rtm_io.io_p(27);
      when "j31_4_b" => return rtm_io.io_n(27);
      when "j31_4_c" => return rtm_io.io_p(28);
      when "j31_4_d" => return rtm_io.io_n(28);
      when "j31_4_e" => return rtm_io.io_p(29);
      when "j31_4_f" => return rtm_io.io_n(29);
      when "j31_5_a" => return rtm_io.io_p(30);
      when "j31_5_b" => return rtm_io.io_n(30);
      when "j31_5_c" => return rtm_io.io_p(31);
      when "j31_5_d" => return rtm_io.io_n(31);
      when "j31_5_e" => return rtm_io.io_p(32);
      when "j31_5_f" => return rtm_io.io_n(32);
      when "j31_6_a" => return rtm_io.io_p(33);
      when "j31_6_b" => return rtm_io.io_n(33);
      when "j31_6_c" => return rtm_io.io_p(34);
      when "j31_6_d" => return rtm_io.io_n(34);
      when "j31_6_e" => return rtm_io.io_p(35);
      when "j31_6_f" => return rtm_io.io_n(35);
      when "j31_7_a" => return rtm_io.io_p(36);
      when "j31_7_b" => return rtm_io.io_n(36);
      when "j31_7_c" => return rtm_io.io_p(37);
      when "j31_7_d" => return rtm_io.io_n(37);
      when "j31_7_e" => return rtm_io.io_p(38);
      when "j31_7_f" => return rtm_io.io_n(38);
      when "j31_8_a" => return rtm_io.io_p(39);
      when "j31_8_b" => return rtm_io.io_n(39);
      when "j31_8_c" => return rtm_io.io_p(40);
      when "j31_8_d" => return rtm_io.io_n(40);
      when "j31_8_e" => return rtm_io.io_p(41);
      when "j31_8_f" => return rtm_io.io_n(41);
      when others  =>
        report "Wrong RTM Class D1.1 connector settings: " &  connector & "_" & row & "_" &column  severity error;
    end case;
  end function f_get_rtm_pin;

  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d12) return std_logic is
  begin
    case connector & "_" & row & "_" & column is
      when "j30_5_a" => return rtm_io.io_p(0);
      when "j30_5_b" => return rtm_io.io_n(0);
      when "j30_5_c" => return rtm_io.io_p(1);
      when "j30_5_d" => return rtm_io.io_n(1);
      when "j30_5_e" => return rtm_io.io_p(2);
      when "j30_5_f" => return rtm_io.io_n(2);
      when "j30_6_a" => return rtm_io.io_p(3);
      when "j30_6_b" => return rtm_io.io_n(3);
      when "j30_6_c" => return rtm_io.io_p(4);
      when "j30_6_d" => return rtm_io.io_n(4);
      when "j30_6_e" => return rtm_io.io_p(5);
      when "j30_6_f" => return rtm_io.io_n(5);
      when "j30_7_a" => return rtm_io.io_p(6);
      when "j30_7_b" => return rtm_io.io_n(6);
      when "j30_7_c" => return rtm_io.io_p(7);
      when "j30_7_d" => return rtm_io.io_n(7);
      when "j30_7_e" => return rtm_io.io_p(8);
      when "j30_7_f" => return rtm_io.io_n(8);
      when "j30_8_a" => return rtm_io.io_p(9);
      when "j30_8_b" => return rtm_io.io_n(9);
      when "j30_8_c" => return rtm_io.io_p(10);
      when "j30_8_d" => return rtm_io.io_n(10);
      when "j30_8_e" => return rtm_io.io_p(11);
      when "j30_8_f" => return rtm_io.io_n(11);
      when "j30_9_a" => return rtm_io.io_p(12);
      when "j30_9_b" => return rtm_io.io_n(12);
      when "j30_9_c" => return rtm_io.io_p(13);
      when "j30_9_d" => return rtm_io.io_n(13);
      when "j30_9_e" => return rtm_io.io_p(14);
      when "j30_9_f" => return rtm_io.io_n(14);
      when "j30_10_a" => return rtm_io.io_p(15);
      when "j30_10_b" => return rtm_io.io_n(15);
      when "j30_10_c" => return rtm_io.io_p(16);
      when "j30_10_d" => return rtm_io.io_n(16);
      when "j30_10_e" => return rtm_io.io_p(17);
      when "j30_10_f" => return rtm_io.io_n(17);
      when "j31_1_a" => return rtm_io.io_p(18);
      when "j31_1_b" => return rtm_io.io_n(18);
      when "j31_1_c" => return rtm_io.io_p(19);
      when "j31_1_d" => return rtm_io.io_n(19);
      when "j31_1_e" => return rtm_io.io_p(20);
      when "j31_1_f" => return rtm_io.io_n(20);
      when "j31_2_a" => return rtm_io.io_p(21);
      when "j31_2_b" => return rtm_io.io_n(21);
      when "j31_2_c" => return rtm_io.io_p(22);
      when "j31_2_d" => return rtm_io.io_n(22);
      when "j31_2_e" => return rtm_io.io_p(23);
      when "j31_2_f" => return rtm_io.io_n(23);
      when "j31_3_a" => return rtm_io.io_p(24);
      when "j31_3_b" => return rtm_io.io_n(24);
      when "j31_3_c" => return rtm_io.io_p(25);
      when "j31_3_d" => return rtm_io.io_n(25);
      when "j31_3_e" => return rtm_io.io_p(26);
      when "j31_3_f" => return rtm_io.io_n(26);
      when "j31_4_a" => return rtm_io.io_p(27);
      when "j31_4_b" => return rtm_io.io_n(27);
      when "j31_4_c" => return rtm_io.io_p(28);
      when "j31_4_d" => return rtm_io.io_n(28);
      when "j31_4_e" => return rtm_io.io_p(29);
      when "j31_4_f" => return rtm_io.io_n(29);
      when "j31_5_a" => return rtm_io.io_p(30);
      when "j31_5_b" => return rtm_io.io_n(30);
      when "j31_5_c" => return rtm_io.io_p(31);
      when "j31_5_d" => return rtm_io.io_n(31);
      when "j31_5_e" => return rtm_io.io_p(32);
      when "j31_5_f" => return rtm_io.io_n(32);
      when "j31_6_a" => return rtm_io.io_p(33);
      when "j31_6_b" => return rtm_io.io_n(33);
      when "j31_6_c" => return rtm_io.io_p(34);
      when "j31_6_d" => return rtm_io.io_n(34);
      when "j31_6_e" => return rtm_io.io_p(35);
      when "j31_6_f" => return rtm_io.io_n(35);
      when "j31_7_a" => return rtm_io.io_p(36);
      when "j31_7_b" => return rtm_io.io_n(36);
      when "j31_8_a" => return rtm_io.io_p(37);
      when "j31_8_b" => return rtm_io.io_n(37);
      when others  =>
        report "Wrong RTM Class D1.2 connector settings: " &  connector & "_" & row & "_" &column  severity error;
    end case;
  end function f_get_rtm_pin;

  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d13) return std_logic is
  begin
    case connector & "_" & row & "_" &column is
      when "j30_5_a" => return rtm_io.io_p(0);
      when "j30_5_b" => return rtm_io.io_n(0);
      when "j30_5_c" => return rtm_io.io_p(1);
      when "j30_5_d" => return rtm_io.io_n(1);
      when "j30_5_e" => return rtm_io.io_p(2);
      when "j30_5_f" => return rtm_io.io_n(2);
      when "j30_6_a" => return rtm_io.io_p(3);
      when "j30_6_b" => return rtm_io.io_n(3);
      when "j30_6_c" => return rtm_io.io_p(4);
      when "j30_6_d" => return rtm_io.io_n(4);
      when "j30_6_e" => return rtm_io.io_p(5);
      when "j30_6_f" => return rtm_io.io_n(5);
      when "j30_7_a" => return rtm_io.io_p(6);
      when "j30_7_b" => return rtm_io.io_n(6);
      when "j30_7_c" => return rtm_io.io_p(7);
      when "j30_7_d" => return rtm_io.io_n(7);
      when "j30_7_e" => return rtm_io.io_p(8);
      when "j30_7_f" => return rtm_io.io_n(8);
      when "j30_8_a" => return rtm_io.io_p(9);
      when "j30_8_b" => return rtm_io.io_n(9);
      when "j30_8_c" => return rtm_io.io_p(10);
      when "j30_8_d" => return rtm_io.io_n(10);
      when "j30_8_e" => return rtm_io.io_p(11);
      when "j30_8_f" => return rtm_io.io_n(11);
      when "j30_9_a" => return rtm_io.io_p(12);
      when "j30_9_b" => return rtm_io.io_n(12);
      when "j30_9_c" => return rtm_io.io_p(13);
      when "j30_9_d" => return rtm_io.io_n(13);
      when "j30_9_e" => return rtm_io.io_p(14);
      when "j30_9_f" => return rtm_io.io_n(14);
      when "j30_10_a" => return rtm_io.io_p(15);
      when "j30_10_b" => return rtm_io.io_n(15);
      when "j30_10_c" => return rtm_io.io_p(16);
      when "j30_10_d" => return rtm_io.io_n(16);
      when "j30_10_e" => return rtm_io.io_p(17);
      when "j30_10_f" => return rtm_io.io_n(17);
      when "j31_1_a" => return rtm_io.io_p(18);
      when "j31_1_b" => return rtm_io.io_n(18);
      when "j31_1_c" => return rtm_io.io_p(19);
      when "j31_1_d" => return rtm_io.io_n(19);
      when "j31_1_e" => return rtm_io.io_p(20);
      when "j31_1_f" => return rtm_io.io_n(20);
      when "j31_2_a" => return rtm_io.io_p(21);
      when "j31_2_b" => return rtm_io.io_n(21);
      when "j31_2_c" => return rtm_io.io_p(22);
      when "j31_2_d" => return rtm_io.io_n(22);
      when "j31_2_e" => return rtm_io.io_p(23);
      when "j31_2_f" => return rtm_io.io_n(23);
      when "j31_3_a" => return rtm_io.io_p(24);
      when "j31_3_b" => return rtm_io.io_n(24);
      when "j31_4_a" => return rtm_io.io_p(25);
      when "j31_4_b" => return rtm_io.io_n(25);
      when "j31_7_a" => return rtm_io.io_p(26);
      when "j31_7_b" => return rtm_io.io_n(26);
      when "j31_8_a" => return rtm_io.io_p(27);
      when "j31_8_b" => return rtm_io.io_n(27);
      when others  =>
        report "Wrong RTM Class D1.3 connector settings: " &  connector & "_" & row & "_" &column  severity error;
    end case;
  end function f_get_rtm_pin;

  function f_get_rtm_pin ( connector, column , row : string; rtm_io : t_rtm_io_d14) return std_logic is
  begin
    case connector & "_" & row & "_" &column is
      when "j30_5_a"  => return rtm_io.io_p(0);
      when "j30_5_b"  => return rtm_io.io_n(0);
      when "j30_6_a"  => return rtm_io.io_p(1);
      when "j30_6_b"  => return rtm_io.io_n(1);
      when "j30_9_a"  => return rtm_io.io_p(2);
      when "j30_9_b"  => return rtm_io.io_n(2);
      when "j30_10_a" => return rtm_io.io_p(3);
      when "j30_10_b" => return rtm_io.io_n(3);
      when "j31_3_a"  => return rtm_io.io_p(4);
      when "j31_3_b"  => return rtm_io.io_n(4);
      when "j31_4_a"  => return rtm_io.io_p(5);
      when "j31_4_b"  => return rtm_io.io_n(5);
      when "j31_7_a"  => return rtm_io.io_p(6);
      when "j31_7_b"  => return rtm_io.io_n(6);
      when "j31_8_a"  => return rtm_io.io_p(7);
      when "j31_8_b"  => return rtm_io.io_n(7);
      when others     =>
        report "Wrong RTM Class D1.4 connector settings: " &  connector & "_" & row & "_" &column  severity error;
    end case;
  end function f_get_rtm_pin;

  function f_rtm_io_d10_idx ( connector, column , row : string ) return natural is
  begin
    case connector & "_" & row & "_" & column is
      when "j30_5_a" => return 0;
      when "j30_5_b" => return 0;
      when "j30_5_c" => return 1;
      when "j30_5_d" => return 1;
      when "j30_5_e" => return 2;
      when "j30_5_f" => return 2;
      when "j30_6_a" => return 3;
      when "j30_6_b" => return 3;
      when "j30_6_c" => return 4;
      when "j30_6_d" => return 4;
      when "j30_6_e" => return 5;
      when "j30_6_f" => return 5;
      when "j30_7_a" => return 6;
      when "j30_7_b" => return 6;
      when "j30_7_c" => return 7;
      when "j30_7_d" => return 7;
      when "j30_7_e" => return 8;
      when "j30_7_f" => return 8;
      when "j30_8_a" => return 9;
      when "j30_8_b" => return 9;
      when "j30_8_c" => return 10;
      when "j30_8_d" => return 10;
      when "j30_8_e" => return 11;
      when "j30_8_f" => return 11;
      when "j30_9_a" => return 12;
      when "j30_9_b" => return 12;
      when "j30_9_c" => return 13;
      when "j30_9_d" => return 13;
      when "j30_9_e" => return 14;
      when "j30_9_f" => return 14;
      when "j30_10_a" => return 15;
      when "j30_10_b" => return 15;
      when "j30_10_c" => return 16;
      when "j30_10_d" => return 16;
      when "j30_10_e" => return 17;
      when "j30_10_f" => return 17;
      when "j31_1_a" => return 18;
      when "j31_1_b" => return 18;
      when "j31_1_c" => return 19;
      when "j31_1_d" => return 19;
      when "j31_1_e" => return 20;
      when "j31_1_f" => return 20;
      when "j31_2_a" => return 21;
      when "j31_2_b" => return 21;
      when "j31_2_c" => return 22;
      when "j31_2_d" => return 22;
      when "j31_2_e" => return 23;
      when "j31_2_f" => return 23;
      when "j31_3_a" => return 24;
      when "j31_3_b" => return 24;
      when "j31_3_c" => return 25;
      when "j31_3_d" => return 25;
      when "j31_3_e" => return 26;
      when "j31_3_f" => return 26;
      when "j31_4_a" => return 27;
      when "j31_4_b" => return 27;
      when "j31_4_c" => return 28;
      when "j31_4_d" => return 28;
      when "j31_4_e" => return 29;
      when "j31_4_f" => return 29;
      when "j31_5_a" => return 30;
      when "j31_5_b" => return 30;
      when "j31_5_c" => return 31;
      when "j31_5_d" => return 31;
      when "j31_5_e" => return 32;
      when "j31_5_f" => return 32;
      when "j31_6_a" => return 33;
      when "j31_6_b" => return 33;
      when "j31_6_c" => return 34;
      when "j31_6_d" => return 34;
      when "j31_6_e" => return 35;
      when "j31_6_f" => return 35;
      when "j31_7_a" => return 36;
      when "j31_7_b" => return 36;
      when "j31_7_c" => return 37;
      when "j31_7_d" => return 37;
      when "j31_7_e" => return 38;
      when "j31_7_f" => return 38;
      when "j31_8_a" => return 39;
      when "j31_8_b" => return 39;
      when "j31_8_c" => return 40;
      when "j31_8_d" => return 40;
      when "j31_8_e" => return 41;
      when "j31_8_f" => return 41;
      when "j31_9_a" => return 42;
      when "j31_9_b" => return 42;
      when "j31_9_c" => return 43;
      when "j31_9_d" => return 43;
      when "j31_9_e" => return 44;
      when "j31_9_f" => return 44;
      when "j31_10_a" => return 45;
      when "j31_10_b" => return 45;
      when "j31_10_c" => return 46;
      when "j31_10_d" => return 46;
      when "j31_10_e" => return 47;
      when "j31_10_f" => return 47;
      when others  =>
        report "Wrong RTM Class D1.0 connector settings: " & connector & column & row  severity error;
    end case;
  end function f_rtm_io_d10_idx;


  function f_rtm_io_d11_idx ( connector, column , row : string ) return natural is
  begin
    case connector & "_" & row & "_" & column is
      when "j30_5_a" => return 0;
      when "j30_5_b" => return 0;
      when "j30_5_c" => return 1;
      when "j30_5_d" => return 1;
      when "j30_5_e" => return 2;
      when "j30_5_f" => return 2;
      when "j30_6_a" => return 3;
      when "j30_6_b" => return 3;
      when "j30_6_c" => return 4;
      when "j30_6_d" => return 4;
      when "j30_6_e" => return 5;
      when "j30_6_f" => return 5;
      when "j30_7_a" => return 6;
      when "j30_7_b" => return 6;
      when "j30_7_c" => return 7;
      when "j30_7_d" => return 7;
      when "j30_7_e" => return 8;
      when "j30_7_f" => return 8;
      when "j30_8_a" => return 9;
      when "j30_8_b" => return 9;
      when "j30_8_c" => return 10;
      when "j30_8_d" => return 10;
      when "j30_8_e" => return 11;
      when "j30_8_f" => return 11;
      when "j30_9_a" => return 12;
      when "j30_9_b" => return 12;
      when "j30_9_c" => return 13;
      when "j30_9_d" => return 13;
      when "j30_9_e" => return 14;
      when "j30_9_f" => return 14;
      when "j30_10_a" => return 15;
      when "j30_10_b" => return 15;
      when "j30_10_c" => return 16;
      when "j30_10_d" => return 16;
      when "j30_10_e" => return 17;
      when "j30_10_f" => return 17;
      when "j31_1_a" => return 18;
      when "j31_1_b" => return 18;
      when "j31_1_c" => return 19;
      when "j31_1_d" => return 19;
      when "j31_1_e" => return 20;
      when "j31_1_f" => return 20;
      when "j31_2_a" => return 21;
      when "j31_2_b" => return 21;
      when "j31_2_c" => return 22;
      when "j31_2_d" => return 22;
      when "j31_2_e" => return 23;
      when "j31_2_f" => return 23;
      when "j31_3_a" => return 24;
      when "j31_3_b" => return 24;
      when "j31_3_c" => return 25;
      when "j31_3_d" => return 25;
      when "j31_3_e" => return 26;
      when "j31_3_f" => return 26;
      when "j31_4_a" => return 27;
      when "j31_4_b" => return 27;
      when "j31_4_c" => return 28;
      when "j31_4_d" => return 28;
      when "j31_4_e" => return 29;
      when "j31_4_f" => return 29;
      when "j31_5_a" => return 30;
      when "j31_5_b" => return 30;
      when "j31_5_c" => return 31;
      when "j31_5_d" => return 31;
      when "j31_5_e" => return 32;
      when "j31_5_f" => return 32;
      when "j31_6_a" => return 33;
      when "j31_6_b" => return 33;
      when "j31_6_c" => return 34;
      when "j31_6_d" => return 34;
      when "j31_6_e" => return 35;
      when "j31_6_f" => return 35;
      when "j31_7_a" => return 36;
      when "j31_7_b" => return 36;
      when "j31_7_c" => return 37;
      when "j31_7_d" => return 37;
      when "j31_7_e" => return 38;
      when "j31_7_f" => return 38;
      when "j31_8_a" => return 39;
      when "j31_8_b" => return 39;
      when "j31_8_c" => return 40;
      when "j31_8_d" => return 40;
      when "j31_8_e" => return 41;
      when "j31_8_f" => return 41;
      when others  =>
        report "Wrong RTM Class D1.1 connector settings: " &  connector & "_" & row & "_" &column  severity error;
    end case;
  end function f_rtm_io_d11_idx;

  function f_rtm_io_d12_idx ( connector, column , row : string ) return natural is
  begin
    case connector & "_" & row & "_" & column is
      when "j30_5_a" => return 0;
      when "j30_5_b" => return 0;
      when "j30_5_c" => return 1;
      when "j30_5_d" => return 1;
      when "j30_5_e" => return 2;
      when "j30_5_f" => return 2;
      when "j30_6_a" => return 3;
      when "j30_6_b" => return 3;
      when "j30_6_c" => return 4;
      when "j30_6_d" => return 4;
      when "j30_6_e" => return 5;
      when "j30_6_f" => return 5;
      when "j30_7_a" => return 6;
      when "j30_7_b" => return 6;
      when "j30_7_c" => return 7;
      when "j30_7_d" => return 7;
      when "j30_7_e" => return 8;
      when "j30_7_f" => return 8;
      when "j30_8_a" => return 9;
      when "j30_8_b" => return 9;
      when "j30_8_c" => return 10;
      when "j30_8_d" => return 10;
      when "j30_8_e" => return 11;
      when "j30_8_f" => return 11;
      when "j30_9_a" => return 12;
      when "j30_9_b" => return 12;
      when "j30_9_c" => return 13;
      when "j30_9_d" => return 13;
      when "j30_9_e" => return 14;
      when "j30_9_f" => return 14;
      when "j30_10_a" => return 15;
      when "j30_10_b" => return 15;
      when "j30_10_c" => return 16;
      when "j30_10_d" => return 16;
      when "j30_10_e" => return 17;
      when "j30_10_f" => return 17;
      when "j31_1_a" => return 18;
      when "j31_1_b" => return 18;
      when "j31_1_c" => return 19;
      when "j31_1_d" => return 19;
      when "j31_1_e" => return 20;
      when "j31_1_f" => return 20;
      when "j31_2_a" => return 21;
      when "j31_2_b" => return 21;
      when "j31_2_c" => return 22;
      when "j31_2_d" => return 22;
      when "j31_2_e" => return 23;
      when "j31_2_f" => return 23;
      when "j31_3_a" => return 24;
      when "j31_3_b" => return 24;
      when "j31_3_c" => return 25;
      when "j31_3_d" => return 25;
      when "j31_3_e" => return 26;
      when "j31_3_f" => return 26;
      when "j31_4_a" => return 27;
      when "j31_4_b" => return 27;
      when "j31_4_c" => return 28;
      when "j31_4_d" => return 28;
      when "j31_4_e" => return 29;
      when "j31_4_f" => return 29;
      when "j31_5_a" => return 30;
      when "j31_5_b" => return 30;
      when "j31_5_c" => return 31;
      when "j31_5_d" => return 31;
      when "j31_5_e" => return 32;
      when "j31_5_f" => return 32;
      when "j31_6_a" => return 33;
      when "j31_6_b" => return 33;
      when "j31_6_c" => return 34;
      when "j31_6_d" => return 34;
      when "j31_6_e" => return 35;
      when "j31_6_f" => return 35;
      when "j31_7_a" => return 36;
      when "j31_7_b" => return 36;
      when "j31_8_a" => return 37;
      when "j31_8_b" => return 37;
      when others  =>
        report "Wrong RTM Class D1.2 connector settings: " &  connector & "_" & row & "_" &column  severity error;
    end case;
  end function f_rtm_io_d12_idx;

  function f_rtm_io_d13_idx ( connector, column , row : string ) return natural is
  begin
    case connector & "_" & row & "_" &column is
      when "j30_5_a" => return 0;
      when "j30_5_b" => return 0;
      when "j30_5_c" => return 1;
      when "j30_5_d" => return 1;
      when "j30_5_e" => return 2;
      when "j30_5_f" => return 2;
      when "j30_6_a" => return 3;
      when "j30_6_b" => return 3;
      when "j30_6_c" => return 4;
      when "j30_6_d" => return 4;
      when "j30_6_e" => return 5;
      when "j30_6_f" => return 5;
      when "j30_7_a" => return 6;
      when "j30_7_b" => return 6;
      when "j30_7_c" => return 7;
      when "j30_7_d" => return 7;
      when "j30_7_e" => return 8;
      when "j30_7_f" => return 8;
      when "j30_8_a" => return 9;
      when "j30_8_b" => return 9;
      when "j30_8_c" => return 10;
      when "j30_8_d" => return 10;
      when "j30_8_e" => return 11;
      when "j30_8_f" => return 11;
      when "j30_9_a" => return 12;
      when "j30_9_b" => return 12;
      when "j30_9_c" => return 13;
      when "j30_9_d" => return 13;
      when "j30_9_e" => return 14;
      when "j30_9_f" => return 14;
      when "j30_10_a" => return 15;
      when "j30_10_b" => return 15;
      when "j30_10_c" => return 16;
      when "j30_10_d" => return 16;
      when "j30_10_e" => return 17;
      when "j30_10_f" => return 17;
      when "j31_1_a" => return 18;
      when "j31_1_b" => return 18;
      when "j31_1_c" => return 19;
      when "j31_1_d" => return 19;
      when "j31_1_e" => return 20;
      when "j31_1_f" => return 20;
      when "j31_2_a" => return 21;
      when "j31_2_b" => return 21;
      when "j31_2_c" => return 22;
      when "j31_2_d" => return 22;
      when "j31_2_e" => return 23;
      when "j31_2_f" => return 23;
      when "j31_3_a" => return 24;
      when "j31_3_b" => return 24;
      when "j31_4_a" => return 25;
      when "j31_4_b" => return 25;
      when "j31_7_a" => return 26;
      when "j31_7_b" => return 26;
      when "j31_8_a" => return 27;
      when "j31_8_b" => return 27;
      when others  =>
        report "Wrong RTM Class D1.3 connector settings: " &  connector & "_" & row & "_" &column  severity error;
    end case;
  end function f_rtm_io_d13_idx;

  function f_rtm_io_d14_idx ( connector, column , row : string ) return natural is
  begin
    case connector & "_" & row & "_" &column is
      when "j30_5_a"  => return 0;
      when "j30_5_b"  => return 0;
      when "j30_6_a"  => return 1;
      when "j30_6_b"  => return 1;
      when "j30_9_a"  => return 2;
      when "j30_9_b"  => return 2;
      when "j30_10_a" => return 3;
      when "j30_10_b" => return 3;
      when "j31_3_a"  => return 4;
      when "j31_3_b"  => return 4;
      when "j31_4_a"  => return 5;
      when "j31_4_b"  => return 5;
      when "j31_7_a"  => return 6;
      when "j31_7_b"  => return 6;
      when "j31_8_a"  => return 7;
      when "j31_8_b"  => return 7;
      when others     =>
        report "Wrong RTM Class D1.4 connector settings: " &  connector & "_" & row & "_" &column  severity error;
    end case;
  end function f_rtm_io_d14_idx;

  -- mask conversion functions
  function f_rtm_mask_d10_to_d11 ( arg_rtm_mask : t_rtm_io_d10_inv_mask ) return t_rtm_io_d11_inv_mask is
    variable mask : t_rtm_io_d11_inv_mask := (others => '0');
  begin
    mask(41 downto 0) := arg_rtm_mask(41 downto 0);
    return mask;
  end function;

  function f_rtm_mask_d10_to_d12 ( arg_rtm_mask : t_rtm_io_d10_inv_mask ) return t_rtm_io_d12_inv_mask is
    variable mask : t_rtm_io_d12_inv_mask := (others => '0') ;
  begin
    mask(36 downto 0) := arg_rtm_mask(36 downto 0);
    mask(37) := arg_rtm_mask(39);
    return mask;
  end function;

  function f_rtm_mask_d10_to_d13 ( arg_rtm_mask : t_rtm_io_d10_inv_mask ) return t_rtm_io_d13_inv_mask is
    variable mask : t_rtm_io_d13_inv_mask  := (others => '0');
  begin
    mask(24 downto 0) := arg_rtm_mask(24 downto 0);
    mask(25) := arg_rtm_mask(27);
    mask(26) := arg_rtm_mask(36);
    mask(27) := arg_rtm_mask(39);
    return mask;
  end function;

  function f_rtm_mask_d10_to_d14 ( arg_rtm_mask : t_rtm_io_d10_inv_mask ) return t_rtm_io_d14_inv_mask is
    variable mask : t_rtm_io_d14_inv_mask := (others => '0');
  begin
    mask(0) := arg_rtm_mask(0);
    mask(1) := arg_rtm_mask(3);
    mask(2) := arg_rtm_mask(12);
    mask(3) := arg_rtm_mask(15);
    mask(4) := arg_rtm_mask(24);
    mask(5) := arg_rtm_mask(27);
    mask(6) := arg_rtm_mask(36);
    mask(7) := arg_rtm_mask(39);
    return mask;
  end function;

  -------------
  function f_rtm_mask_d11_to_d10 ( arg_rtm_mask : t_rtm_io_d11_inv_mask ) return t_rtm_io_d10_inv_mask is
    variable mask : t_rtm_io_d10_inv_mask := (others => '0');
  begin
    mask(41 downto 0) := arg_rtm_mask(41 downto 0);
    return mask;
  end function;

  function f_rtm_mask_d11_to_d12 ( arg_rtm_mask : t_rtm_io_d11_inv_mask ) return t_rtm_io_d12_inv_mask is
  begin
    return f_rtm_mask_d10_to_d12(f_rtm_mask_d11_to_d10(arg_rtm_mask));
  end function;

  function f_rtm_mask_d11_to_d13 ( arg_rtm_mask : t_rtm_io_d11_inv_mask ) return t_rtm_io_d13_inv_mask is
  begin
    return f_rtm_mask_d10_to_d13(f_rtm_mask_d11_to_d10(arg_rtm_mask));
  end function;

  function f_rtm_mask_d11_to_d14 ( arg_rtm_mask : t_rtm_io_d11_inv_mask ) return t_rtm_io_d14_inv_mask is
  begin
    return f_rtm_mask_d10_to_d14(f_rtm_mask_d11_to_d10(arg_rtm_mask));
  end function;

  -------------
  function f_rtm_mask_d12_to_d10 ( arg_rtm_mask : t_rtm_io_d12_inv_mask ) return t_rtm_io_d10_inv_mask is
    variable mask : t_rtm_io_d10_inv_mask := (others => '0');
  begin
    mask(36 downto 0) := arg_rtm_mask(36 downto 0);
    mask(39)          := arg_rtm_mask(37);
    return mask;
  end function;

  function f_rtm_mask_d12_to_d11 ( arg_rtm_mask : t_rtm_io_d12_inv_mask ) return t_rtm_io_d11_inv_mask is
  begin
    return f_rtm_mask_d10_to_d11(f_rtm_mask_d12_to_d10(arg_rtm_mask));
  end function;

  function f_rtm_mask_d12_to_d13 ( arg_rtm_mask : t_rtm_io_d12_inv_mask ) return t_rtm_io_d13_inv_mask is
  begin
    return f_rtm_mask_d10_to_d13(f_rtm_mask_d12_to_d10(arg_rtm_mask));
  end function;

  function f_rtm_mask_d12_to_d14 ( arg_rtm_mask : t_rtm_io_d12_inv_mask ) return t_rtm_io_d14_inv_mask is
  begin
    return f_rtm_mask_d10_to_d14(f_rtm_mask_d12_to_d10(arg_rtm_mask));
  end function;

  ------------
  function f_rtm_mask_d13_to_d10 ( arg_rtm_mask : t_rtm_io_d13_inv_mask ) return t_rtm_io_d10_inv_mask is
    variable mask : t_rtm_io_d10_inv_mask  := (others => '0');
  begin
    mask(24 downto 0) := arg_rtm_mask(24 downto 0);
    mask(27) := arg_rtm_mask(25);
    mask(36) := arg_rtm_mask(26);
    mask(39) := arg_rtm_mask(27);
    return mask;
  end function;

  function f_rtm_mask_d13_to_d11 ( arg_rtm_mask : t_rtm_io_d13_inv_mask ) return t_rtm_io_d11_inv_mask is
  begin
    return f_rtm_mask_d10_to_d11(f_rtm_mask_d13_to_d10(arg_rtm_mask));
  end function;

  function f_rtm_mask_d13_to_d12 ( arg_rtm_mask : t_rtm_io_d13_inv_mask ) return t_rtm_io_d12_inv_mask is
  begin
    return f_rtm_mask_d10_to_d12(f_rtm_mask_d13_to_d10(arg_rtm_mask));
  end function;

  function f_rtm_mask_d13_to_d14 ( arg_rtm_mask : t_rtm_io_d13_inv_mask ) return t_rtm_io_d14_inv_mask is
  begin
    return f_rtm_mask_d10_to_d14(f_rtm_mask_d13_to_d10(arg_rtm_mask));
  end function;

  ------------
  function f_rtm_mask_d14_to_d10 ( arg_rtm_mask : t_rtm_io_d14_inv_mask ) return t_rtm_io_d10_inv_mask is
    variable mask : t_rtm_io_d10_inv_mask := (others => '0');
  begin
    mask(0)  := arg_rtm_mask(0);
    mask(3)  := arg_rtm_mask(1);
    mask(12) := arg_rtm_mask(2);
    mask(15) := arg_rtm_mask(3);
    mask(24) := arg_rtm_mask(4);
    mask(27) := arg_rtm_mask(5);
    mask(36) := arg_rtm_mask(6);
    mask(39) := arg_rtm_mask(7);
    return mask;
  end function;

  function f_rtm_mask_d14_to_d11 ( arg_rtm_mask : t_rtm_io_d14_inv_mask ) return t_rtm_io_d11_inv_mask is
  begin
    return f_rtm_mask_d10_to_d11(f_rtm_mask_d14_to_d10(arg_rtm_mask));
  end function;
  function f_rtm_mask_d14_to_d12 ( arg_rtm_mask : t_rtm_io_d14_inv_mask ) return t_rtm_io_d12_inv_mask is
  begin
    return f_rtm_mask_d10_to_d13(f_rtm_mask_d14_to_d10(arg_rtm_mask));
  end function;
  function f_rtm_mask_d14_to_d13 ( arg_rtm_mask : t_rtm_io_d14_inv_mask ) return t_rtm_io_d13_inv_mask is
  begin
    return f_rtm_mask_d10_to_d13(f_rtm_mask_d14_to_d10(arg_rtm_mask));
  end function;

end package body common_rtm;
