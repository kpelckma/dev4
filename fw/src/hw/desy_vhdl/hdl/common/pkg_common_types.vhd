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
--! @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! package with common types definitions with common functions
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package common_types is

  type t_1b_slv_vector is array (natural range<>) of std_logic_vector(0 downto 0);
  type t_2b_slv_vector is array (natural range<>) of std_logic_vector(1 downto 0);
  type t_3b_slv_vector is array (natural range<>) of std_logic_vector(2 downto 0);
  type t_4b_slv_vector is array (natural range<>) of std_logic_vector(3 downto 0);
  type t_5b_slv_vector is array (natural range<>) of std_logic_vector(4 downto 0);
  type t_6b_slv_vector is array (natural range<>) of std_logic_vector(5 downto 0);
  type t_7b_slv_vector is array (natural range<>) of std_logic_vector(6 downto 0);
  type t_8b_slv_vector is array (natural range<>) of std_logic_vector(7 downto 0);
  type t_9b_slv_vector is array (natural range<>) of std_logic_vector(8 downto 0);
  type t_10b_slv_vector is array (natural range<>) of std_logic_vector(9 downto 0);
  type t_11b_slv_vector is array (natural range<>) of std_logic_vector(10 downto 0);
  type t_12b_slv_vector is array (natural range<>) of std_logic_vector(11 downto 0);
  type t_13b_slv_vector is array (natural range<>) of std_logic_vector(12 downto 0);
  type t_14b_slv_vector is array (natural range<>) of std_logic_vector(13 downto 0);
  type t_15b_slv_vector is array (natural range<>) of std_logic_vector(14 downto 0);
  type t_16b_slv_vector is array (natural range<>) of std_logic_vector(15 downto 0);
  type t_17b_slv_vector is array (natural range<>) of std_logic_vector(16 downto 0);
  type t_18b_slv_vector is array (natural range<>) of std_logic_vector(17 downto 0);
  type t_19b_slv_vector is array (natural range<>) of std_logic_vector(18 downto 0);
  type t_20b_slv_vector is array (natural range<>) of std_logic_vector(19 downto 0);
  type t_21b_slv_vector is array (natural range<>) of std_logic_vector(20 downto 0);
  type t_22b_slv_vector is array (natural range<>) of std_logic_vector(21 downto 0);
  type t_23b_slv_vector is array (natural range<>) of std_logic_vector(22 downto 0);
  type t_24b_slv_vector is array (natural range<>) of std_logic_vector(23 downto 0);
  type t_25b_slv_vector is array (natural range<>) of std_logic_vector(24 downto 0);
  type t_26b_slv_vector is array (natural range<>) of std_logic_vector(25 downto 0);
  type t_27b_slv_vector is array (natural range<>) of std_logic_vector(26 downto 0);
  type t_28b_slv_vector is array (natural range<>) of std_logic_vector(27 downto 0);
  type t_29b_slv_vector is array (natural range<>) of std_logic_vector(28 downto 0);
  type t_30b_slv_vector is array (natural range<>) of std_logic_vector(29 downto 0);
  type t_31b_slv_vector is array (natural range<>) of std_logic_vector(30 downto 0);
  type t_32b_slv_vector is array (natural range<>) of std_logic_vector(31 downto 0);
  type t_33b_slv_vector is array (natural range<>) of std_logic_vector(32 downto 0);
  type t_34b_slv_vector is array (natural range<>) of std_logic_vector(33 downto 0);
  type t_35b_slv_vector is array (natural range<>) of std_logic_vector(34 downto 0);
  type t_36b_slv_vector is array (natural range<>) of std_logic_vector(35 downto 0);
  type t_37b_slv_vector is array (natural range<>) of std_logic_vector(36 downto 0);
  type t_38b_slv_vector is array (natural range<>) of std_logic_vector(37 downto 0);
  type t_39b_slv_vector is array (natural range<>) of std_logic_vector(38 downto 0);
  type t_40b_slv_vector is array (natural range<>) of std_logic_vector(39 downto 0);
  type t_48b_slv_vector is array (natural range<>) of std_logic_vector(47 downto 0);
  type t_56b_slv_vector is array (natural range<>) of std_logic_vector(55 downto 0);
  type t_64b_slv_vector is array (natural range<>) of std_logic_vector(63 downto 0);
  type t_72b_slv_vector is array (natural range<>) of std_logic_vector(71 downto 0);
  type t_80b_slv_vector is array (natural range<>) of std_logic_vector(79 downto 0);
  type t_88b_slv_vector is array (natural range<>) of std_logic_vector(87 downto 0);
  type t_96b_slv_vector is array (natural range<>) of std_logic_vector(95 downto 0);
  type t_104b_slv_vector is array (natural range<>) of std_logic_vector(103 downto 0);
  type t_112b_slv_vector is array (natural range<>) of std_logic_vector(111 downto 0);
  type t_120b_slv_vector is array (natural range<>) of std_logic_vector(119 downto 0);
  type t_128b_slv_vector is array (natural range<>) of std_logic_vector(127 downto 0);
  type t_136b_slv_vector is array (natural range<>) of std_logic_vector(135 downto 0);
  type t_144b_slv_vector is array (natural range<>) of std_logic_vector(143 downto 0);
  type t_152b_slv_vector is array (natural range<>) of std_logic_vector(151 downto 0);
  type t_160b_slv_vector is array (natural range<>) of std_logic_vector(159 downto 0);
  type t_168b_slv_vector is array (natural range<>) of std_logic_vector(167 downto 0);
  type t_176b_slv_vector is array (natural range<>) of std_logic_vector(175 downto 0);
  type t_184b_slv_vector is array (natural range<>) of std_logic_vector(183 downto 0);
  type t_192b_slv_vector is array (natural range<>) of std_logic_vector(191 downto 0);
  type t_200b_slv_vector is array (natural range<>) of std_logic_vector(199 downto 0);
  type t_208b_slv_vector is array (natural range<>) of std_logic_vector(207 downto 0);
  type t_216b_slv_vector is array (natural range<>) of std_logic_vector(215 downto 0);
  type t_224b_slv_vector is array (natural range<>) of std_logic_vector(223 downto 0);
  type t_232b_slv_vector is array (natural range<>) of std_logic_vector(231 downto 0);
  type t_240b_slv_vector is array (natural range<>) of std_logic_vector(239 downto 0);
  type t_248b_slv_vector is array (natural range<>) of std_logic_vector(247 downto 0);
  type t_256b_slv_vector is array (natural range<>) of std_logic_vector(255 downto 0);
  type t_512b_slv_vector is array (natural range<>) of std_logic_vector(511 downto 0);
  type t_1024b_slv_vector is array (natural range<>) of std_logic_vector(1023 downto 0);

  type t_1b_signed_vector is array (natural range<>) of signed(0 downto 0);
  type t_2b_signed_vector is array (natural range<>) of signed(1 downto 0);
  type t_3b_signed_vector is array (natural range<>) of signed(2 downto 0);
  type t_4b_signed_vector is array (natural range<>) of signed(3 downto 0);
  type t_5b_signed_vector is array (natural range<>) of signed(4 downto 0);
  type t_6b_signed_vector is array (natural range<>) of signed(5 downto 0);
  type t_7b_signed_vector is array (natural range<>) of signed(6 downto 0);
  type t_8b_signed_vector is array (natural range<>) of signed(7 downto 0);
  type t_9b_signed_vector is array (natural range<>) of signed(8 downto 0);
  type t_10b_signed_vector is array (natural range<>) of signed(9 downto 0);
  type t_11b_signed_vector is array (natural range<>) of signed(10 downto 0);
  type t_12b_signed_vector is array (natural range<>) of signed(11 downto 0);
  type t_13b_signed_vector is array (natural range<>) of signed(12 downto 0);
  type t_14b_signed_vector is array (natural range<>) of signed(13 downto 0);
  type t_15b_signed_vector is array (natural range<>) of signed(14 downto 0);
  type t_16b_signed_vector is array (natural range<>) of signed(15 downto 0);
  type t_17b_signed_vector is array (natural range<>) of signed(16 downto 0);
  type t_18b_signed_vector is array (natural range<>) of signed(17 downto 0);
  type t_19b_signed_vector is array (natural range<>) of signed(18 downto 0);
  type t_20b_signed_vector is array (natural range<>) of signed(19 downto 0);
  type t_21b_signed_vector is array (natural range<>) of signed(20 downto 0);
  type t_22b_signed_vector is array (natural range<>) of signed(21 downto 0);
  type t_23b_signed_vector is array (natural range<>) of signed(22 downto 0);
  type t_24b_signed_vector is array (natural range<>) of signed(23 downto 0);
  type t_25b_signed_vector is array (natural range<>) of signed(24 downto 0);
  type t_26b_signed_vector is array (natural range<>) of signed(25 downto 0);
  type t_27b_signed_vector is array (natural range<>) of signed(26 downto 0);
  type t_28b_signed_vector is array (natural range<>) of signed(27 downto 0);
  type t_29b_signed_vector is array (natural range<>) of signed(28 downto 0);
  type t_30b_signed_vector is array (natural range<>) of signed(29 downto 0);
  type t_31b_signed_vector is array (natural range<>) of signed(30 downto 0);
  type t_32b_signed_vector is array (natural range<>) of signed(31 downto 0);
  type t_33b_signed_vector is array (natural range<>) of signed(32 downto 0);
  type t_34b_signed_vector is array (natural range<>) of signed(33 downto 0);
  type t_35b_signed_vector is array (natural range<>) of signed(34 downto 0);
  type t_36b_signed_vector is array (natural range<>) of signed(35 downto 0);
  type t_37b_signed_vector is array (natural range<>) of signed(36 downto 0);
  type t_38b_signed_vector is array (natural range<>) of signed(37 downto 0);
  type t_39b_signed_vector is array (natural range<>) of signed(38 downto 0);
  type t_40b_signed_vector is array (natural range<>) of signed(39 downto 0);
  type t_48b_signed_vector is array (natural range<>) of signed(47 downto 0);
  type t_56b_signed_vector is array (natural range<>) of signed(55 downto 0);
  type t_64b_signed_vector is array (natural range<>) of signed(63 downto 0);
  type t_72b_signed_vector is array (natural range<>) of signed(71 downto 0);
  type t_80b_signed_vector is array (natural range<>) of signed(79 downto 0);
  type t_88b_signed_vector is array (natural range<>) of signed(87 downto 0);
  type t_96b_signed_vector is array (natural range<>) of signed(95 downto 0);
  type t_104b_signed_vector is array (natural range<>) of signed(103 downto 0);
  type t_112b_signed_vector is array (natural range<>) of signed(111 downto 0);
  type t_120b_signed_vector is array (natural range<>) of signed(119 downto 0);
  type t_128b_signed_vector is array (natural range<>) of signed(127 downto 0);
  type t_136b_signed_vector is array (natural range<>) of signed(135 downto 0);
  type t_144b_signed_vector is array (natural range<>) of signed(143 downto 0);
  type t_152b_signed_vector is array (natural range<>) of signed(151 downto 0);
  type t_160b_signed_vector is array (natural range<>) of signed(159 downto 0);
  type t_168b_signed_vector is array (natural range<>) of signed(167 downto 0);
  type t_176b_signed_vector is array (natural range<>) of signed(175 downto 0);
  type t_184b_signed_vector is array (natural range<>) of signed(183 downto 0);
  type t_192b_signed_vector is array (natural range<>) of signed(191 downto 0);
  type t_200b_signed_vector is array (natural range<>) of signed(199 downto 0);
  type t_208b_signed_vector is array (natural range<>) of signed(207 downto 0);
  type t_216b_signed_vector is array (natural range<>) of signed(215 downto 0);
  type t_224b_signed_vector is array (natural range<>) of signed(223 downto 0);
  type t_232b_signed_vector is array (natural range<>) of signed(231 downto 0);
  type t_240b_signed_vector is array (natural range<>) of signed(239 downto 0);
  type t_248b_signed_vector is array (natural range<>) of signed(247 downto 0);
  type t_256b_signed_vector is array (natural range<>) of signed(255 downto 0);
  type t_512b_signed_vector is array (natural range<>) of signed(511 downto 0);
  type t_1024b_signed_vector is array (natural range<>) of signed(1023 downto 0);

  type t_1b_unsigned_vector is array (natural range<>) of unsigned(0 downto 0);
  type t_2b_unsigned_vector is array (natural range<>) of unsigned(1 downto 0);
  type t_3b_unsigned_vector is array (natural range<>) of unsigned(2 downto 0);
  type t_4b_unsigned_vector is array (natural range<>) of unsigned(3 downto 0);
  type t_5b_unsigned_vector is array (natural range<>) of unsigned(4 downto 0);
  type t_6b_unsigned_vector is array (natural range<>) of unsigned(5 downto 0);
  type t_7b_unsigned_vector is array (natural range<>) of unsigned(6 downto 0);
  type t_8b_unsigned_vector is array (natural range<>) of unsigned(7 downto 0);
  type t_9b_unsigned_vector is array (natural range<>) of unsigned(8 downto 0);
  type t_10b_unsigned_vector is array (natural range<>) of unsigned(9 downto 0);
  type t_11b_unsigned_vector is array (natural range<>) of unsigned(10 downto 0);
  type t_12b_unsigned_vector is array (natural range<>) of unsigned(11 downto 0);
  type t_13b_unsigned_vector is array (natural range<>) of unsigned(12 downto 0);
  type t_14b_unsigned_vector is array (natural range<>) of unsigned(13 downto 0);
  type t_15b_unsigned_vector is array (natural range<>) of unsigned(14 downto 0);
  type t_16b_unsigned_vector is array (natural range<>) of unsigned(15 downto 0);
  type t_17b_unsigned_vector is array (natural range<>) of unsigned(16 downto 0);
  type t_18b_unsigned_vector is array (natural range<>) of unsigned(17 downto 0);
  type t_19b_unsigned_vector is array (natural range<>) of unsigned(18 downto 0);
  type t_20b_unsigned_vector is array (natural range<>) of unsigned(19 downto 0);
  type t_21b_unsigned_vector is array (natural range<>) of unsigned(20 downto 0);
  type t_22b_unsigned_vector is array (natural range<>) of unsigned(21 downto 0);
  type t_23b_unsigned_vector is array (natural range<>) of unsigned(22 downto 0);
  type t_24b_unsigned_vector is array (natural range<>) of unsigned(23 downto 0);
  type t_25b_unsigned_vector is array (natural range<>) of unsigned(24 downto 0);
  type t_26b_unsigned_vector is array (natural range<>) of unsigned(25 downto 0);
  type t_27b_unsigned_vector is array (natural range<>) of unsigned(26 downto 0);
  type t_28b_unsigned_vector is array (natural range<>) of unsigned(27 downto 0);
  type t_29b_unsigned_vector is array (natural range<>) of unsigned(28 downto 0);
  type t_30b_unsigned_vector is array (natural range<>) of unsigned(29 downto 0);
  type t_31b_unsigned_vector is array (natural range<>) of unsigned(30 downto 0);
  type t_32b_unsigned_vector is array (natural range<>) of unsigned(31 downto 0);
  type t_33b_unsigned_vector is array (natural range<>) of unsigned(32 downto 0);
  type t_34b_unsigned_vector is array (natural range<>) of unsigned(33 downto 0);
  type t_35b_unsigned_vector is array (natural range<>) of unsigned(34 downto 0);
  type t_36b_unsigned_vector is array (natural range<>) of unsigned(35 downto 0);
  type t_37b_unsigned_vector is array (natural range<>) of unsigned(36 downto 0);
  type t_38b_unsigned_vector is array (natural range<>) of unsigned(37 downto 0);
  type t_39b_unsigned_vector is array (natural range<>) of unsigned(38 downto 0);
  type t_40b_unsigned_vector is array (natural range<>) of unsigned(39 downto 0);
  type t_48b_unsigned_vector is array (natural range<>) of unsigned(47 downto 0);
  type t_56b_unsigned_vector is array (natural range<>) of unsigned(55 downto 0);
  type t_64b_unsigned_vector is array (natural range<>) of unsigned(63 downto 0);
  type t_72b_unsigned_vector is array (natural range<>) of unsigned(71 downto 0);
  type t_80b_unsigned_vector is array (natural range<>) of unsigned(79 downto 0);
  type t_88b_unsigned_vector is array (natural range<>) of unsigned(87 downto 0);
  type t_96b_unsigned_vector is array (natural range<>) of unsigned(95 downto 0);
  type t_104b_unsigned_vector is array (natural range<>) of unsigned(103 downto 0);
  type t_112b_unsigned_vector is array (natural range<>) of unsigned(111 downto 0);
  type t_120b_unsigned_vector is array (natural range<>) of unsigned(119 downto 0);
  type t_128b_unsigned_vector is array (natural range<>) of unsigned(127 downto 0);
  type t_136b_unsigned_vector is array (natural range<>) of unsigned(135 downto 0);
  type t_144b_unsigned_vector is array (natural range<>) of unsigned(143 downto 0);
  type t_152b_unsigned_vector is array (natural range<>) of unsigned(151 downto 0);
  type t_160b_unsigned_vector is array (natural range<>) of unsigned(159 downto 0);
  type t_168b_unsigned_vector is array (natural range<>) of unsigned(167 downto 0);
  type t_176b_unsigned_vector is array (natural range<>) of unsigned(175 downto 0);
  type t_184b_unsigned_vector is array (natural range<>) of unsigned(183 downto 0);
  type t_192b_unsigned_vector is array (natural range<>) of unsigned(191 downto 0);
  type t_200b_unsigned_vector is array (natural range<>) of unsigned(199 downto 0);
  type t_208b_unsigned_vector is array (natural range<>) of unsigned(207 downto 0);
  type t_216b_unsigned_vector is array (natural range<>) of unsigned(215 downto 0);
  type t_224b_unsigned_vector is array (natural range<>) of unsigned(223 downto 0);
  type t_232b_unsigned_vector is array (natural range<>) of unsigned(231 downto 0);
  type t_240b_unsigned_vector is array (natural range<>) of unsigned(239 downto 0);
  type t_248b_unsigned_vector is array (natural range<>) of unsigned(247 downto 0);
  type t_256b_unsigned_vector is array (natural range<>) of unsigned(255 downto 0);
  type t_512b_unsigned_vector is array (natural range<>) of unsigned(511 downto 0);
  type t_1024b_unsigned_vector is array (natural range<>) of unsigned(1023 downto 0);

  function f_2b_slv_vector_to_slv (arg: t_2b_slv_vector) return std_logic_vector ;
  function f_3b_slv_vector_to_slv (arg: t_3b_slv_vector) return std_logic_vector ;
  function f_4b_slv_vector_to_slv (arg: t_4b_slv_vector) return std_logic_vector ;
  function f_5b_slv_vector_to_slv (arg: t_5b_slv_vector) return std_logic_vector ;
  function f_6b_slv_vector_to_slv (arg: t_6b_slv_vector) return std_logic_vector ;
  function f_7b_slv_vector_to_slv (arg: t_7b_slv_vector) return std_logic_vector ;
  function f_8b_slv_vector_to_slv (arg: t_8b_slv_vector) return std_logic_vector ;
  function f_9b_slv_vector_to_slv (arg: t_9b_slv_vector) return std_logic_vector ;
  function f_10b_slv_vector_to_slv (arg: t_10b_slv_vector) return std_logic_vector ;
  function f_11b_slv_vector_to_slv (arg: t_11b_slv_vector) return std_logic_vector ;
  function f_12b_slv_vector_to_slv (arg: t_12b_slv_vector) return std_logic_vector ;
  function f_13b_slv_vector_to_slv (arg: t_13b_slv_vector) return std_logic_vector ;
  function f_14b_slv_vector_to_slv (arg: t_14b_slv_vector) return std_logic_vector ;
  function f_15b_slv_vector_to_slv (arg: t_15b_slv_vector) return std_logic_vector ;
  function f_16b_slv_vector_to_slv (arg: t_16b_slv_vector) return std_logic_vector ;
  function f_17b_slv_vector_to_slv (arg: t_17b_slv_vector) return std_logic_vector ;
  function f_18b_slv_vector_to_slv (arg: t_18b_slv_vector) return std_logic_vector ;
  function f_19b_slv_vector_to_slv (arg: t_19b_slv_vector) return std_logic_vector ;
  function f_20b_slv_vector_to_slv (arg: t_20b_slv_vector) return std_logic_vector ;
  function f_21b_slv_vector_to_slv (arg: t_21b_slv_vector) return std_logic_vector ;
  function f_22b_slv_vector_to_slv (arg: t_22b_slv_vector) return std_logic_vector ;
  function f_23b_slv_vector_to_slv (arg: t_23b_slv_vector) return std_logic_vector ;
  function f_24b_slv_vector_to_slv (arg: t_24b_slv_vector) return std_logic_vector ;
  function f_25b_slv_vector_to_slv (arg: t_25b_slv_vector) return std_logic_vector ;
  function f_26b_slv_vector_to_slv (arg: t_26b_slv_vector) return std_logic_vector ;
  function f_27b_slv_vector_to_slv (arg: t_27b_slv_vector) return std_logic_vector ;
  function f_28b_slv_vector_to_slv (arg: t_28b_slv_vector) return std_logic_vector ;
  function f_29b_slv_vector_to_slv (arg: t_29b_slv_vector) return std_logic_vector ;
  function f_30b_slv_vector_to_slv (arg: t_30b_slv_vector) return std_logic_vector ;
  function f_31b_slv_vector_to_slv (arg: t_31b_slv_vector) return std_logic_vector ;
  function f_32b_slv_vector_to_slv (arg: t_32b_slv_vector) return std_logic_vector ;
  function f_33b_slv_vector_to_slv (arg: t_33b_slv_vector) return std_logic_vector ;
  function f_34b_slv_vector_to_slv (arg: t_34b_slv_vector) return std_logic_vector ;
  function f_35b_slv_vector_to_slv (arg: t_35b_slv_vector) return std_logic_vector ;
  function f_36b_slv_vector_to_slv (arg: t_36b_slv_vector) return std_logic_vector ;
  function f_37b_slv_vector_to_slv (arg: t_37b_slv_vector) return std_logic_vector ;
  function f_38b_slv_vector_to_slv (arg: t_38b_slv_vector) return std_logic_vector ;
  function f_39b_slv_vector_to_slv (arg: t_39b_slv_vector) return std_logic_vector ;

  function f_40b_slv_vector_to_slv (arg: t_40b_slv_vector) return std_logic_vector ;
  function f_48b_slv_vector_to_slv (arg: t_48b_slv_vector) return std_logic_vector ;
  function f_56b_slv_vector_to_slv (arg: t_56b_slv_vector) return std_logic_vector ;
  function f_64b_slv_vector_to_slv (arg: t_64b_slv_vector) return std_logic_vector ;
  function f_72b_slv_vector_to_slv (arg: t_72b_slv_vector) return std_logic_vector ;
  function f_80b_slv_vector_to_slv (arg: t_80b_slv_vector) return std_logic_vector ;
  function f_88b_slv_vector_to_slv (arg: t_88b_slv_vector) return std_logic_vector ;
  function f_96b_slv_vector_to_slv (arg: t_96b_slv_vector) return std_logic_vector ;
  function f_104b_slv_vector_to_slv (arg: t_104b_slv_vector) return std_logic_vector ;
  function f_112b_slv_vector_to_slv (arg: t_112b_slv_vector) return std_logic_vector ;
  function f_120b_slv_vector_to_slv (arg: t_120b_slv_vector) return std_logic_vector ;
  function f_128b_slv_vector_to_slv (arg: t_128b_slv_vector) return std_logic_vector ;
  function f_136b_slv_vector_to_slv (arg: t_136b_slv_vector) return std_logic_vector ;
  function f_144b_slv_vector_to_slv (arg: t_144b_slv_vector) return std_logic_vector ;
  function f_152b_slv_vector_to_slv (arg: t_152b_slv_vector) return std_logic_vector ;
  function f_160b_slv_vector_to_slv (arg: t_160b_slv_vector) return std_logic_vector ;
  function f_168b_slv_vector_to_slv (arg: t_168b_slv_vector) return std_logic_vector ;
  function f_176b_slv_vector_to_slv (arg: t_176b_slv_vector) return std_logic_vector ;
  function f_184b_slv_vector_to_slv (arg: t_184b_slv_vector) return std_logic_vector ;
  function f_192b_slv_vector_to_slv (arg: t_192b_slv_vector) return std_logic_vector ;
  function f_200b_slv_vector_to_slv (arg: t_200b_slv_vector) return std_logic_vector ;
  function f_208b_slv_vector_to_slv (arg: t_208b_slv_vector) return std_logic_vector ;
  function f_216b_slv_vector_to_slv (arg: t_216b_slv_vector) return std_logic_vector ;
  function f_224b_slv_vector_to_slv (arg: t_224b_slv_vector) return std_logic_vector ;
  function f_232b_slv_vector_to_slv (arg: t_232b_slv_vector) return std_logic_vector ;
  function f_240b_slv_vector_to_slv (arg: t_240b_slv_vector) return std_logic_vector ;
  function f_248b_slv_vector_to_slv (arg: t_248b_slv_vector) return std_logic_vector ;
  function f_256b_slv_vector_to_slv (arg: t_256b_slv_vector) return std_logic_vector ;

  function f_512b_slv_vector_to_slv (arg: t_512b_slv_vector) return std_logic_vector ;
  function f_1024b_slv_vector_to_slv (arg: t_1024b_slv_vector) return std_logic_vector ;

  function f_slv_to_2b_slv_vector(arg : std_logic_vector) return t_2b_slv_vector;
  function f_slv_to_3b_slv_vector(arg : std_logic_vector) return t_3b_slv_vector;
  function f_slv_to_4b_slv_vector(arg : std_logic_vector) return t_4b_slv_vector;
  function f_slv_to_5b_slv_vector(arg : std_logic_vector) return t_5b_slv_vector;
  function f_slv_to_6b_slv_vector(arg : std_logic_vector) return t_6b_slv_vector;
  function f_slv_to_7b_slv_vector(arg : std_logic_vector) return t_7b_slv_vector;
  function f_slv_to_8b_slv_vector(arg : std_logic_vector) return t_8b_slv_vector;
  function f_slv_to_9b_slv_vector(arg : std_logic_vector) return t_9b_slv_vector;
  function f_slv_to_10b_slv_vector(arg : std_logic_vector) return t_10b_slv_vector;
  function f_slv_to_11b_slv_vector(arg : std_logic_vector) return t_11b_slv_vector;
  function f_slv_to_12b_slv_vector(arg : std_logic_vector) return t_12b_slv_vector;
  function f_slv_to_13b_slv_vector(arg : std_logic_vector) return t_13b_slv_vector;
  function f_slv_to_14b_slv_vector(arg : std_logic_vector) return t_14b_slv_vector;
  function f_slv_to_15b_slv_vector(arg : std_logic_vector) return t_15b_slv_vector;
  function f_slv_to_16b_slv_vector(arg : std_logic_vector) return t_16b_slv_vector;
  function f_slv_to_17b_slv_vector(arg : std_logic_vector) return t_17b_slv_vector;
  function f_slv_to_18b_slv_vector(arg : std_logic_vector) return t_18b_slv_vector;
  function f_slv_to_19b_slv_vector(arg : std_logic_vector) return t_19b_slv_vector;
  function f_slv_to_20b_slv_vector(arg : std_logic_vector) return t_20b_slv_vector;
  function f_slv_to_21b_slv_vector(arg : std_logic_vector) return t_21b_slv_vector;
  function f_slv_to_22b_slv_vector(arg : std_logic_vector) return t_22b_slv_vector;
  function f_slv_to_23b_slv_vector(arg : std_logic_vector) return t_23b_slv_vector;
  function f_slv_to_24b_slv_vector(arg : std_logic_vector) return t_24b_slv_vector;
  function f_slv_to_25b_slv_vector(arg : std_logic_vector) return t_25b_slv_vector;
  function f_slv_to_26b_slv_vector(arg : std_logic_vector) return t_26b_slv_vector;
  function f_slv_to_27b_slv_vector(arg : std_logic_vector) return t_27b_slv_vector;
  function f_slv_to_28b_slv_vector(arg : std_logic_vector) return t_28b_slv_vector;
  function f_slv_to_29b_slv_vector(arg : std_logic_vector) return t_29b_slv_vector;
  function f_slv_to_30b_slv_vector(arg : std_logic_vector) return t_30b_slv_vector;
  function f_slv_to_31b_slv_vector(arg : std_logic_vector) return t_31b_slv_vector;
  function f_slv_to_32b_slv_vector(arg : std_logic_vector) return t_32b_slv_vector;
  function f_slv_to_33b_slv_vector(arg : std_logic_vector) return t_33b_slv_vector;
  function f_slv_to_34b_slv_vector(arg : std_logic_vector) return t_34b_slv_vector;
  function f_slv_to_35b_slv_vector(arg : std_logic_vector) return t_35b_slv_vector;
  function f_slv_to_36b_slv_vector(arg : std_logic_vector) return t_36b_slv_vector;
  function f_slv_to_37b_slv_vector(arg : std_logic_vector) return t_37b_slv_vector;
  function f_slv_to_38b_slv_vector(arg : std_logic_vector) return t_38b_slv_vector;
  function f_slv_to_39b_slv_vector(arg : std_logic_vector) return t_39b_slv_vector;

  function f_slv_to_40b_slv_vector(arg : std_logic_vector) return t_40b_slv_vector;
  function f_slv_to_48b_slv_vector(arg : std_logic_vector) return t_48b_slv_vector;
  function f_slv_to_56b_slv_vector(arg : std_logic_vector) return t_56b_slv_vector;
  function f_slv_to_64b_slv_vector(arg : std_logic_vector) return t_64b_slv_vector;
  function f_slv_to_72b_slv_vector(arg : std_logic_vector) return t_72b_slv_vector;
  function f_slv_to_80b_slv_vector(arg : std_logic_vector) return t_80b_slv_vector;
  function f_slv_to_88b_slv_vector(arg : std_logic_vector) return t_88b_slv_vector;
  function f_slv_to_96b_slv_vector(arg : std_logic_vector) return t_96b_slv_vector;
  function f_slv_to_104b_slv_vector(arg : std_logic_vector) return t_104b_slv_vector;
  function f_slv_to_112b_slv_vector(arg : std_logic_vector) return t_112b_slv_vector;
  function f_slv_to_120b_slv_vector(arg : std_logic_vector) return t_120b_slv_vector;
  function f_slv_to_128b_slv_vector(arg : std_logic_vector) return t_128b_slv_vector;
  function f_slv_to_136b_slv_vector(arg : std_logic_vector) return t_136b_slv_vector;
  function f_slv_to_144b_slv_vector(arg : std_logic_vector) return t_144b_slv_vector;
  function f_slv_to_152b_slv_vector(arg : std_logic_vector) return t_152b_slv_vector;
  function f_slv_to_160b_slv_vector(arg : std_logic_vector) return t_160b_slv_vector;
  function f_slv_to_168b_slv_vector(arg : std_logic_vector) return t_168b_slv_vector;
  function f_slv_to_176b_slv_vector(arg : std_logic_vector) return t_176b_slv_vector;
  function f_slv_to_184b_slv_vector(arg : std_logic_vector) return t_184b_slv_vector;
  function f_slv_to_192b_slv_vector(arg : std_logic_vector) return t_192b_slv_vector;
  function f_slv_to_200b_slv_vector(arg : std_logic_vector) return t_200b_slv_vector;
  function f_slv_to_208b_slv_vector(arg : std_logic_vector) return t_208b_slv_vector;
  function f_slv_to_216b_slv_vector(arg : std_logic_vector) return t_216b_slv_vector;
  function f_slv_to_224b_slv_vector(arg : std_logic_vector) return t_224b_slv_vector;
  function f_slv_to_232b_slv_vector(arg : std_logic_vector) return t_232b_slv_vector;
  function f_slv_to_240b_slv_vector(arg : std_logic_vector) return t_240b_slv_vector;
  function f_slv_to_248b_slv_vector(arg : std_logic_vector) return t_248b_slv_vector;
  function f_slv_to_256b_slv_vector(arg : std_logic_vector) return t_256b_slv_vector;

  function f_slv_to_512b_slv_vector(arg : std_logic_vector) return t_512b_slv_vector;
  function f_slv_to_1024b_slv_vector(arg : std_logic_vector) return t_1024b_slv_vector;

end common_types;


-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;

package body common_types is

  ----------------------------------------------------------------------------
  -- conversion slv to slv
  ----------------------------------------------------------------------------
  function f_2b_slv_vector_to_slv(arg : t_2b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(2*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(2*(I+1)-1 downto 2*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_3b_slv_vector_to_slv(arg : t_3b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(3*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(3*(I+1)-1 downto 3*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_4b_slv_vector_to_slv(arg : t_4b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(4*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(4*(I+1)-1 downto 4*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_5b_slv_vector_to_slv(arg : t_5b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(5*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(5*(I+1)-1 downto 5*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_6b_slv_vector_to_slv(arg : t_6b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(6*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(6*(I+1)-1 downto 6*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_7b_slv_vector_to_slv(arg : t_7b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(7*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(7*(I+1)-1 downto 7*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_8b_slv_vector_to_slv(arg : t_8b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(8*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(8*(I+1)-1 downto 8*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_9b_slv_vector_to_slv(arg : t_9b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(9*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(9*(I+1)-1 downto 9*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_10b_slv_vector_to_slv(arg : t_10b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(10*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(10*(I+1)-1 downto 10*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_11b_slv_vector_to_slv(arg : t_11b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(11*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(11*(I+1)-1 downto 11*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_12b_slv_vector_to_slv(arg : t_12b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(12*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(12*(I+1)-1 downto 12*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_13b_slv_vector_to_slv(arg : t_13b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(13*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(13*(I+1)-1 downto 13*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_14b_slv_vector_to_slv(arg : t_14b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(14*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(14*(I+1)-1 downto 14*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_15b_slv_vector_to_slv(arg : t_15b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(15*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(15*(I+1)-1 downto 15*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_16b_slv_vector_to_slv(arg : t_16b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(16*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(16*(I+1)-1 downto 16*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_17b_slv_vector_to_slv(arg : t_17b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(17*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(17*(I+1)-1 downto 17*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_18b_slv_vector_to_slv(arg : t_18b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(18*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(18*(I+1)-1 downto 18*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_19b_slv_vector_to_slv(arg : t_19b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(19*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(19*(I+1)-1 downto 19*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_20b_slv_vector_to_slv(arg : t_20b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(20*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(20*(I+1)-1 downto 20*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_21b_slv_vector_to_slv(arg : t_21b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(21*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(21*(I+1)-1 downto 21*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_22b_slv_vector_to_slv(arg : t_22b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(22*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(22*(I+1)-1 downto 22*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_23b_slv_vector_to_slv(arg : t_23b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(23*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(23*(I+1)-1 downto 23*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_24b_slv_vector_to_slv(arg : t_24b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(24*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(24*(I+1)-1 downto 24*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_25b_slv_vector_to_slv(arg : t_25b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(25*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(25*(I+1)-1 downto 25*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_26b_slv_vector_to_slv(arg : t_26b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(26*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(26*(I+1)-1 downto 26*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_27b_slv_vector_to_slv(arg : t_27b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(27*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(27*(I+1)-1 downto 27*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_28b_slv_vector_to_slv(arg : t_28b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(28*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(28*(I+1)-1 downto 28*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_29b_slv_vector_to_slv(arg : t_29b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(29*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(29*(I+1)-1 downto 29*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_30b_slv_vector_to_slv(arg : t_30b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(30*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(30*(I+1)-1 downto 30*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_31b_slv_vector_to_slv(arg : t_31b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(31*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(31*(I+1)-1 downto 31*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_32b_slv_vector_to_slv(arg : t_32b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(32*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(32*(I+1)-1 downto 32*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_33b_slv_vector_to_slv(arg : t_33b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(33*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(33*(I+1)-1 downto 33*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_34b_slv_vector_to_slv(arg : t_34b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(34*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(34*(I+1)-1 downto 34*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_35b_slv_vector_to_slv(arg : t_35b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(35*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(35*(I+1)-1 downto 35*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_36b_slv_vector_to_slv(arg : t_36b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(36*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(36*(I+1)-1 downto 36*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_37b_slv_vector_to_slv(arg : t_37b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(37*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(37*(I+1)-1 downto 37*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_38b_slv_vector_to_slv(arg : t_38b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(38*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(38*(I+1)-1 downto 38*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_39b_slv_vector_to_slv(arg : t_39b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(39*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(39*(I+1)-1 downto 39*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_40b_slv_vector_to_slv(arg : t_40b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(40*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(40*(I+1)-1 downto 40*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_48b_slv_vector_to_slv(arg : t_48b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(48*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(48*(I+1)-1 downto 48*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_56b_slv_vector_to_slv(arg : t_56b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(56*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(56*(I+1)-1 downto 56*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_64b_slv_vector_to_slv(arg : t_64b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(64*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(64*(I+1)-1 downto 64*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_72b_slv_vector_to_slv(arg : t_72b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(72*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(72*(I+1)-1 downto 72*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_80b_slv_vector_to_slv(arg : t_80b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(80*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(80*(I+1)-1 downto 80*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_88b_slv_vector_to_slv(arg : t_88b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(88*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(88*(I+1)-1 downto 88*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_96b_slv_vector_to_slv(arg : t_96b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(96*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(96*(I+1)-1 downto 96*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_104b_slv_vector_to_slv(arg : t_104b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(104*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(104*(I+1)-1 downto 104*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_112b_slv_vector_to_slv(arg : t_112b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(112*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(112*(I+1)-1 downto 112*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_120b_slv_vector_to_slv(arg : t_120b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(120*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(120*(I+1)-1 downto 120*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_128b_slv_vector_to_slv(arg : t_128b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(128*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(128*(I+1)-1 downto 128*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_136b_slv_vector_to_slv(arg : t_136b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(136*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(136*(I+1)-1 downto 136*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_144b_slv_vector_to_slv(arg : t_144b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(144*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(144*(I+1)-1 downto 144*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_152b_slv_vector_to_slv(arg : t_152b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(152*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(152*(I+1)-1 downto 152*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_160b_slv_vector_to_slv(arg : t_160b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(160*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(160*(I+1)-1 downto 160*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_168b_slv_vector_to_slv(arg : t_168b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(168*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(168*(I+1)-1 downto 168*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_176b_slv_vector_to_slv(arg : t_176b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(176*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(176*(I+1)-1 downto 176*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_184b_slv_vector_to_slv(arg : t_184b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(184*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(184*(I+1)-1 downto 184*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_192b_slv_vector_to_slv(arg : t_192b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(192*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(192*(I+1)-1 downto 192*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_200b_slv_vector_to_slv(arg : t_200b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(200*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(200*(I+1)-1 downto 200*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_208b_slv_vector_to_slv(arg : t_208b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(208*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(208*(I+1)-1 downto 208*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_216b_slv_vector_to_slv(arg : t_216b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(216*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(216*(I+1)-1 downto 216*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_224b_slv_vector_to_slv(arg : t_224b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(224*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(224*(I+1)-1 downto 224*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_232b_slv_vector_to_slv(arg : t_232b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(232*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(232*(I+1)-1 downto 232*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_240b_slv_vector_to_slv(arg : t_240b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(240*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(240*(I+1)-1 downto 240*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_248b_slv_vector_to_slv(arg : t_248b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(248*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(248*(I+1)-1 downto 248*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_256b_slv_vector_to_slv(arg : t_256b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(256*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(256*(I+1)-1 downto 256*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_512b_slv_vector_to_slv(arg : t_512b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(512*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(512*(I+1)-1 downto 512*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

  function f_1024b_slv_vector_to_slv(arg : t_1024b_slv_vector) return std_logic_vector is
    variable v_vec : std_logic_vector(1024*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(1024*(I+1)-1 downto 1024*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;

    function f_slv_to_2b_slv_vector(arg : std_logic_vector) return t_2b_slv_vector is
    variable v_arr : t_2b_slv_vector((arg'length/2)-1 downto 0) ;
  begin
    for I in 0 to arg'length/2-1 loop
      v_arr(I) := arg(2*(I+1)-1 downto 2*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_3b_slv_vector(arg : std_logic_vector) return t_3b_slv_vector is
    variable v_arr : t_3b_slv_vector((arg'length/3)-1 downto 0) ;
  begin
    for I in 0 to arg'length/3-1 loop
      v_arr(I) := arg(3*(I+1)-1 downto 3*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_4b_slv_vector(arg : std_logic_vector) return t_4b_slv_vector is
    variable v_arr : t_4b_slv_vector((arg'length/4)-1 downto 0) ;
  begin
    for I in 0 to arg'length/4-1 loop
      v_arr(I) := arg(4*(I+1)-1 downto 4*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_5b_slv_vector(arg : std_logic_vector) return t_5b_slv_vector is
    variable v_arr : t_5b_slv_vector((arg'length/5)-1 downto 0) ;
  begin
    for I in 0 to arg'length/5-1 loop
      v_arr(I) := arg(5*(I+1)-1 downto 5*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_6b_slv_vector(arg : std_logic_vector) return t_6b_slv_vector is
    variable v_arr : t_6b_slv_vector((arg'length/6)-1 downto 0) ;
  begin
    for I in 0 to arg'length/6-1 loop
      v_arr(I) := arg(6*(I+1)-1 downto 6*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_7b_slv_vector(arg : std_logic_vector) return t_7b_slv_vector is
    variable v_arr : t_7b_slv_vector((arg'length/7)-1 downto 0) ;
  begin
    for I in 0 to arg'length/7-1 loop
      v_arr(I) := arg(7*(I+1)-1 downto 7*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_8b_slv_vector(arg : std_logic_vector) return t_8b_slv_vector is
    variable v_arr : t_8b_slv_vector((arg'length/8)-1 downto 0) ;
  begin
    for I in 0 to arg'length/8-1 loop
      v_arr(I) := arg(8*(I+1)-1 downto 8*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_9b_slv_vector(arg : std_logic_vector) return t_9b_slv_vector is
    variable v_arr : t_9b_slv_vector((arg'length/9)-1 downto 0) ;
  begin
    for I in 0 to arg'length/9-1 loop
      v_arr(I) := arg(9*(I+1)-1 downto 9*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_10b_slv_vector(arg : std_logic_vector) return t_10b_slv_vector is
    variable v_arr : t_10b_slv_vector((arg'length/10)-1 downto 0) ;
  begin
    for I in 0 to arg'length/10-1 loop
      v_arr(I) := arg(10*(I+1)-1 downto 10*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_11b_slv_vector(arg : std_logic_vector) return t_11b_slv_vector is
    variable v_arr : t_11b_slv_vector((arg'length/11)-1 downto 0) ;
  begin
    for I in 0 to arg'length/11-1 loop
      v_arr(I) := arg(11*(I+1)-1 downto 11*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_12b_slv_vector(arg : std_logic_vector) return t_12b_slv_vector is
    variable v_arr : t_12b_slv_vector((arg'length/12)-1 downto 0) ;
  begin
    for I in 0 to arg'length/12-1 loop
      v_arr(I) := arg(12*(I+1)-1 downto 12*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_13b_slv_vector(arg : std_logic_vector) return t_13b_slv_vector is
    variable v_arr : t_13b_slv_vector((arg'length/13)-1 downto 0) ;
  begin
    for I in 0 to arg'length/13-1 loop
      v_arr(I) := arg(13*(I+1)-1 downto 13*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_14b_slv_vector(arg : std_logic_vector) return t_14b_slv_vector is
    variable v_arr : t_14b_slv_vector((arg'length/14)-1 downto 0) ;
  begin
    for I in 0 to arg'length/14-1 loop
      v_arr(I) := arg(14*(I+1)-1 downto 14*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_15b_slv_vector(arg : std_logic_vector) return t_15b_slv_vector is
    variable v_arr : t_15b_slv_vector((arg'length/15)-1 downto 0) ;
  begin
    for I in 0 to arg'length/15-1 loop
      v_arr(I) := arg(15*(I+1)-1 downto 15*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_16b_slv_vector(arg : std_logic_vector) return t_16b_slv_vector is
    variable v_arr : t_16b_slv_vector((arg'length/16)-1 downto 0) ;
  begin
    for I in 0 to arg'length/16-1 loop
      v_arr(I) := arg(16*(I+1)-1 downto 16*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_17b_slv_vector(arg : std_logic_vector) return t_17b_slv_vector is
    variable v_arr : t_17b_slv_vector((arg'length/17)-1 downto 0) ;
  begin
    for I in 0 to arg'length/17-1 loop
      v_arr(I) := arg(17*(I+1)-1 downto 17*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_18b_slv_vector(arg : std_logic_vector) return t_18b_slv_vector is
    variable v_arr : t_18b_slv_vector((arg'length/18)-1 downto 0) ;
  begin
    for I in 0 to arg'length/18-1 loop
      v_arr(I) := arg(18*(I+1)-1 downto 18*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_19b_slv_vector(arg : std_logic_vector) return t_19b_slv_vector is
    variable v_arr : t_19b_slv_vector((arg'length/19)-1 downto 0) ;
  begin
    for I in 0 to arg'length/19-1 loop
      v_arr(I) := arg(19*(I+1)-1 downto 19*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_20b_slv_vector(arg : std_logic_vector) return t_20b_slv_vector is
    variable v_arr : t_20b_slv_vector((arg'length/20)-1 downto 0) ;
  begin
    for I in 0 to arg'length/20-1 loop
      v_arr(I) := arg(20*(I+1)-1 downto 20*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_21b_slv_vector(arg : std_logic_vector) return t_21b_slv_vector is
    variable v_arr : t_21b_slv_vector((arg'length/21)-1 downto 0) ;
  begin
    for I in 0 to arg'length/21-1 loop
      v_arr(I) := arg(21*(I+1)-1 downto 21*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_22b_slv_vector(arg : std_logic_vector) return t_22b_slv_vector is
    variable v_arr : t_22b_slv_vector((arg'length/22)-1 downto 0) ;
  begin
    for I in 0 to arg'length/22-1 loop
      v_arr(I) := arg(22*(I+1)-1 downto 22*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_23b_slv_vector(arg : std_logic_vector) return t_23b_slv_vector is
    variable v_arr : t_23b_slv_vector((arg'length/23)-1 downto 0) ;
  begin
    for I in 0 to arg'length/23-1 loop
      v_arr(I) := arg(23*(I+1)-1 downto 23*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_24b_slv_vector(arg : std_logic_vector) return t_24b_slv_vector is
    variable v_arr : t_24b_slv_vector((arg'length/24)-1 downto 0) ;
  begin
    for I in 0 to arg'length/24-1 loop
      v_arr(I) := arg(24*(I+1)-1 downto 24*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_25b_slv_vector(arg : std_logic_vector) return t_25b_slv_vector is
    variable v_arr : t_25b_slv_vector((arg'length/25)-1 downto 0) ;
  begin
    for I in 0 to arg'length/25-1 loop
      v_arr(I) := arg(25*(I+1)-1 downto 25*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_26b_slv_vector(arg : std_logic_vector) return t_26b_slv_vector is
    variable v_arr : t_26b_slv_vector((arg'length/26)-1 downto 0) ;
  begin
    for I in 0 to arg'length/26-1 loop
      v_arr(I) := arg(26*(I+1)-1 downto 26*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_27b_slv_vector(arg : std_logic_vector) return t_27b_slv_vector is
    variable v_arr : t_27b_slv_vector((arg'length/27)-1 downto 0) ;
  begin
    for I in 0 to arg'length/27-1 loop
      v_arr(I) := arg(27*(I+1)-1 downto 27*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_28b_slv_vector(arg : std_logic_vector) return t_28b_slv_vector is
    variable v_arr : t_28b_slv_vector((arg'length/28)-1 downto 0) ;
  begin
    for I in 0 to arg'length/28-1 loop
      v_arr(I) := arg(28*(I+1)-1 downto 28*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_29b_slv_vector(arg : std_logic_vector) return t_29b_slv_vector is
    variable v_arr : t_29b_slv_vector((arg'length/29)-1 downto 0) ;
  begin
    for I in 0 to arg'length/29-1 loop
      v_arr(I) := arg(29*(I+1)-1 downto 29*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_30b_slv_vector(arg : std_logic_vector) return t_30b_slv_vector is
    variable v_arr : t_30b_slv_vector((arg'length/30)-1 downto 0) ;
  begin
    for I in 0 to arg'length/30-1 loop
      v_arr(I) := arg(30*(I+1)-1 downto 30*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_31b_slv_vector(arg : std_logic_vector) return t_31b_slv_vector is
    variable v_arr : t_31b_slv_vector((arg'length/31)-1 downto 0) ;
  begin
    for I in 0 to arg'length/31-1 loop
      v_arr(I) := arg(31*(I+1)-1 downto 31*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_32b_slv_vector(arg : std_logic_vector) return t_32b_slv_vector is
    variable v_arr : t_32b_slv_vector((arg'length/32)-1 downto 0) ;
  begin
    for I in 0 to arg'length/32-1 loop
      v_arr(I) := arg(32*(I+1)-1 downto 32*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_33b_slv_vector(arg : std_logic_vector) return t_33b_slv_vector is
    variable v_arr : t_33b_slv_vector((arg'length/33)-1 downto 0) ;
  begin
    for I in 0 to arg'length/33-1 loop
      v_arr(I) := arg(33*(I+1)-1 downto 33*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_34b_slv_vector(arg : std_logic_vector) return t_34b_slv_vector is
    variable v_arr : t_34b_slv_vector((arg'length/34)-1 downto 0) ;
  begin
    for I in 0 to arg'length/34-1 loop
      v_arr(I) := arg(34*(I+1)-1 downto 34*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_35b_slv_vector(arg : std_logic_vector) return t_35b_slv_vector is
    variable v_arr : t_35b_slv_vector((arg'length/35)-1 downto 0) ;
  begin
    for I in 0 to arg'length/35-1 loop
      v_arr(I) := arg(35*(I+1)-1 downto 35*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_36b_slv_vector(arg : std_logic_vector) return t_36b_slv_vector is
    variable v_arr : t_36b_slv_vector((arg'length/36)-1 downto 0) ;
  begin
    for I in 0 to arg'length/36-1 loop
      v_arr(I) := arg(36*(I+1)-1 downto 36*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_37b_slv_vector(arg : std_logic_vector) return t_37b_slv_vector is
    variable v_arr : t_37b_slv_vector((arg'length/37)-1 downto 0) ;
  begin
    for I in 0 to arg'length/37-1 loop
      v_arr(I) := arg(37*(I+1)-1 downto 37*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_38b_slv_vector(arg : std_logic_vector) return t_38b_slv_vector is
    variable v_arr : t_38b_slv_vector((arg'length/38)-1 downto 0) ;
  begin
    for I in 0 to arg'length/38-1 loop
      v_arr(I) := arg(38*(I+1)-1 downto 38*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_39b_slv_vector(arg : std_logic_vector) return t_39b_slv_vector is
    variable v_arr : t_39b_slv_vector((arg'length/39)-1 downto 0) ;
  begin
    for I in 0 to arg'length/39-1 loop
      v_arr(I) := arg(39*(I+1)-1 downto 39*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_40b_slv_vector(arg : std_logic_vector) return t_40b_slv_vector is
    variable v_arr : t_40b_slv_vector((arg'length/40)-1 downto 0) ;
  begin
    for I in 0 to arg'length/40-1 loop
      v_arr(I) := arg(40*(I+1)-1 downto 40*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_48b_slv_vector(arg : std_logic_vector) return t_48b_slv_vector is
    variable v_arr : t_48b_slv_vector((arg'length/48)-1 downto 0) ;
  begin
    for I in 0 to arg'length/48-1 loop
      v_arr(I) := arg(48*(I+1)-1 downto 48*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_56b_slv_vector(arg : std_logic_vector) return t_56b_slv_vector is
    variable v_arr : t_56b_slv_vector((arg'length/56)-1 downto 0) ;
  begin
    for I in 0 to arg'length/56-1 loop
      v_arr(I) := arg(56*(I+1)-1 downto 56*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_64b_slv_vector(arg : std_logic_vector) return t_64b_slv_vector is
    variable v_arr : t_64b_slv_vector((arg'length/64)-1 downto 0) ;
  begin
    for I in 0 to arg'length/64-1 loop
      v_arr(I) := arg(64*(I+1)-1 downto 64*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_72b_slv_vector(arg : std_logic_vector) return t_72b_slv_vector is
    variable v_arr : t_72b_slv_vector((arg'length/72)-1 downto 0) ;
  begin
    for I in 0 to arg'length/72-1 loop
      v_arr(I) := arg(72*(I+1)-1 downto 72*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_80b_slv_vector(arg : std_logic_vector) return t_80b_slv_vector is
    variable v_arr : t_80b_slv_vector((arg'length/80)-1 downto 0) ;
  begin
    for I in 0 to arg'length/80-1 loop
      v_arr(I) := arg(80*(I+1)-1 downto 80*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_88b_slv_vector(arg : std_logic_vector) return t_88b_slv_vector is
    variable v_arr : t_88b_slv_vector((arg'length/88)-1 downto 0) ;
  begin
    for I in 0 to arg'length/88-1 loop
      v_arr(I) := arg(88*(I+1)-1 downto 88*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_96b_slv_vector(arg : std_logic_vector) return t_96b_slv_vector is
    variable v_arr : t_96b_slv_vector((arg'length/96)-1 downto 0) ;
  begin
    for I in 0 to arg'length/96-1 loop
      v_arr(I) := arg(96*(I+1)-1 downto 96*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_104b_slv_vector(arg : std_logic_vector) return t_104b_slv_vector is
    variable v_arr : t_104b_slv_vector((arg'length/104)-1 downto 0) ;
  begin
    for I in 0 to arg'length/104-1 loop
      v_arr(I) := arg(104*(I+1)-1 downto 104*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_112b_slv_vector(arg : std_logic_vector) return t_112b_slv_vector is
    variable v_arr : t_112b_slv_vector((arg'length/112)-1 downto 0) ;
  begin
    for I in 0 to arg'length/112-1 loop
      v_arr(I) := arg(112*(I+1)-1 downto 112*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_120b_slv_vector(arg : std_logic_vector) return t_120b_slv_vector is
    variable v_arr : t_120b_slv_vector((arg'length/120)-1 downto 0) ;
  begin
    for I in 0 to arg'length/120-1 loop
      v_arr(I) := arg(120*(I+1)-1 downto 120*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_128b_slv_vector(arg : std_logic_vector) return t_128b_slv_vector is
    variable v_arr : t_128b_slv_vector((arg'length/128)-1 downto 0) ;
  begin
    for I in 0 to arg'length/128-1 loop
      v_arr(I) := arg(128*(I+1)-1 downto 128*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_136b_slv_vector(arg : std_logic_vector) return t_136b_slv_vector is
    variable v_arr : t_136b_slv_vector((arg'length/136)-1 downto 0) ;
  begin
    for I in 0 to arg'length/136-1 loop
      v_arr(I) := arg(136*(I+1)-1 downto 136*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_144b_slv_vector(arg : std_logic_vector) return t_144b_slv_vector is
    variable v_arr : t_144b_slv_vector((arg'length/144)-1 downto 0) ;
  begin
    for I in 0 to arg'length/144-1 loop
      v_arr(I) := arg(144*(I+1)-1 downto 144*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_152b_slv_vector(arg : std_logic_vector) return t_152b_slv_vector is
    variable v_arr : t_152b_slv_vector((arg'length/152)-1 downto 0) ;
  begin
    for I in 0 to arg'length/152-1 loop
      v_arr(I) := arg(152*(I+1)-1 downto 152*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_160b_slv_vector(arg : std_logic_vector) return t_160b_slv_vector is
    variable v_arr : t_160b_slv_vector((arg'length/160)-1 downto 0) ;
  begin
    for I in 0 to arg'length/160-1 loop
      v_arr(I) := arg(160*(I+1)-1 downto 160*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_168b_slv_vector(arg : std_logic_vector) return t_168b_slv_vector is
    variable v_arr : t_168b_slv_vector((arg'length/168)-1 downto 0) ;
  begin
    for I in 0 to arg'length/168-1 loop
      v_arr(I) := arg(168*(I+1)-1 downto 168*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_176b_slv_vector(arg : std_logic_vector) return t_176b_slv_vector is
    variable v_arr : t_176b_slv_vector((arg'length/176)-1 downto 0) ;
  begin
    for I in 0 to arg'length/176-1 loop
      v_arr(I) := arg(176*(I+1)-1 downto 176*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_184b_slv_vector(arg : std_logic_vector) return t_184b_slv_vector is
    variable v_arr : t_184b_slv_vector((arg'length/184)-1 downto 0) ;
  begin
    for I in 0 to arg'length/184-1 loop
      v_arr(I) := arg(184*(I+1)-1 downto 184*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_192b_slv_vector(arg : std_logic_vector) return t_192b_slv_vector is
    variable v_arr : t_192b_slv_vector((arg'length/192)-1 downto 0) ;
  begin
    for I in 0 to arg'length/192-1 loop
      v_arr(I) := arg(192*(I+1)-1 downto 192*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_200b_slv_vector(arg : std_logic_vector) return t_200b_slv_vector is
    variable v_arr : t_200b_slv_vector((arg'length/200)-1 downto 0) ;
  begin
    for I in 0 to arg'length/200-1 loop
      v_arr(I) := arg(200*(I+1)-1 downto 200*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_208b_slv_vector(arg : std_logic_vector) return t_208b_slv_vector is
    variable v_arr : t_208b_slv_vector((arg'length/208)-1 downto 0) ;
  begin
    for I in 0 to arg'length/208-1 loop
      v_arr(I) := arg(208*(I+1)-1 downto 208*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_216b_slv_vector(arg : std_logic_vector) return t_216b_slv_vector is
    variable v_arr : t_216b_slv_vector((arg'length/216)-1 downto 0) ;
  begin
    for I in 0 to arg'length/216-1 loop
      v_arr(I) := arg(216*(I+1)-1 downto 216*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_224b_slv_vector(arg : std_logic_vector) return t_224b_slv_vector is
    variable v_arr : t_224b_slv_vector((arg'length/224)-1 downto 0) ;
  begin
    for I in 0 to arg'length/224-1 loop
      v_arr(I) := arg(224*(I+1)-1 downto 224*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_232b_slv_vector(arg : std_logic_vector) return t_232b_slv_vector is
    variable v_arr : t_232b_slv_vector((arg'length/232)-1 downto 0) ;
  begin
    for I in 0 to arg'length/232-1 loop
      v_arr(I) := arg(232*(I+1)-1 downto 232*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_240b_slv_vector(arg : std_logic_vector) return t_240b_slv_vector is
    variable v_arr : t_240b_slv_vector((arg'length/240)-1 downto 0) ;
  begin
    for I in 0 to arg'length/240-1 loop
      v_arr(I) := arg(240*(I+1)-1 downto 240*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_248b_slv_vector(arg : std_logic_vector) return t_248b_slv_vector is
    variable v_arr : t_248b_slv_vector((arg'length/248)-1 downto 0) ;
  begin
    for I in 0 to arg'length/248-1 loop
      v_arr(I) := arg(248*(I+1)-1 downto 248*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_256b_slv_vector(arg : std_logic_vector) return t_256b_slv_vector is
    variable v_arr : t_256b_slv_vector((arg'length/256)-1 downto 0) ;
  begin
    for I in 0 to arg'length/256-1 loop
      v_arr(I) := arg(256*(I+1)-1 downto 256*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_512b_slv_vector(arg : std_logic_vector) return t_512b_slv_vector is
    variable v_arr : t_512b_slv_vector((arg'length/512)-1 downto 0) ;
  begin
    for I in 0 to arg'length/512-1 loop
      v_arr(I) := arg(512*(I+1)-1 downto 256*I) ;
    end loop ;
    return v_arr ;
  end function ;

  function f_slv_to_1024b_slv_vector(arg : std_logic_vector) return t_1024b_slv_vector is
    variable v_arr : t_1024b_slv_vector((arg'length/1024)-1 downto 0) ;
  begin
    for I in 0 to arg'length/1024-1 loop
      v_arr(I) := arg(1024*(I+1)-1 downto 256*I) ;
    end loop ;
    return v_arr ;
  end function ;


end common_types;
