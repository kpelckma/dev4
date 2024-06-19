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
--! @date 2022-02-22
--! @author Wojciech Jalmuzna <wjalmuzn@ntmail.desy.de>
--! @author MSK-FPGA Team
------------------------------------------------------------------------------
--! @brief
--! Basic Mathematical functions (Resize, Summation, Substraction, Max/Min Log etc.)
------------------------------------------------------------------------------

library ieee ;
use ieee.std_logic_1164.all   ;
use ieee.std_logic_signed.all ;
use ieee.std_logic_misc.all   ;
use ieee.std_logic_arith.all   ;

package math_basic is
    subtype TU2V is std_logic_vector ;
    subtype TSL  is std_logic;

    function U2VCreate(arg : integer ; length : integer) return TU2V ;

    function U2VResize (arg : TU2V ; length : natural ) return TU2V;

    function U2VShiftLeft  (arg : TU2V ; shift : natural ) return TU2V ;
    function U2VShiftRight (arg : TU2V ; shift : natural ) return TU2V ;
    function U2VShift  (arg : TU2V ; shift : integer ) return TU2V ;

    function \minimum\(arg1,arg2 : integer ) return integer  ;
    function \maximum\(arg1,arg2 : integer ) return integer  ;

    function U2VSum (arg1,arg2 : TU2V ; length : natural ) return TU2V  ;
    function U2VSub (arg1,arg2 : TU2V ; length : natural ) return TU2V  ;
    function U2VMult(arg1,arg2 : TU2V ; length : natural ) return TU2V  ;

    function U2VNeg(arg : TU2V ) return TU2V  ;
    function U2VAbs(arg : TU2V ) return TU2V  ;
    function log2(arg : natural) return natural ;

    function U2VMax(arg : TU2V ) return TSL  ;
    function U2VMin(arg : TU2V ) return TSL  ;
    function U2VSat(arg : TU2V ) return TSL  ;

end math_basic;

package body math_basic is
--
-- internal functions
--
    function \minimum\(arg1,arg2 : integer ) return integer is
    begin
        if arg1 > arg2 then
            return arg2 ;
        else
            return arg1 ;
        end if ;
    end function ;

    function \maximum\(arg1,arg2 : integer ) return integer is
    begin
        if arg1 > arg2 then
            return arg1 ;
        else
            return arg2 ;
        end if ;
    end function ;


--
-- converts integer vzalue to U2V
--
    function U2VCreate(arg : integer ; length : integer) return TU2V is
    begin
        return CONV_STD_LOGIC_VECTOR(arg,length) ;
    end function ;

--
-- this function resizes vector with saturation - basic function for overflow control
--
    function U2VResize (arg : TU2V ; length : natural ) return TU2V is
        variable result : TU2V(length-1 downto 0) ;
    begin
        if length = arg'length then
            return arg ;
        end if ;

        if length < arg'length then
            if arg( arg'length-1 ) = '1' and AND_REDUCE( arg( arg'length-1 downto length-1 ) ) = '0' then
                result := ( others => '0' ) ;
                result(length-1) := '1' ;

                return result ;
            end if ;

            if arg( arg'length-1 ) = '0' and OR_REDUCE( arg( arg'length-1 downto length-1 ) ) = '1' then
                result := ( others => '1' ) ;
                result(length-1) := '0' ;

                return result ;
            end if ;

            return arg(length-1 downto 0) ;
        else
            result := ( others => arg(arg'length-1) ) ;
            result(arg'length-1 downto 0) := arg ;

            return result ;
        end if ;
    end function ;


--
-- this function shifts the value left
--
    function U2VShiftLeft  (arg : TU2V ; shift : natural ) return TU2V is
        variable result : TU2V( arg'length-1+shift downto 0 ) ;
    begin
        result := ( others => '0' ) ;
        result(result'length-1 downto result'length-arg'length) := arg ;

        return result ;--U2VResize(result,arg'length) ;
    end function ;

--
-- this function shifts the value right
--
    function U2VShiftRight  (arg : TU2V ; shift : natural ) return TU2V is
        variable result : TU2V( arg'length-1 downto 0 ) ;
    begin
        result := ( others => arg(arg'length-1) ) ;
        result( result'length-1-shift downto 0) := arg(arg'length-1 downto shift) ;

        if AND_REDUCE(arg) = '1' then
            result := ( others => '0' ) ;
        end if ;

        return result ;
    end function ;

--
-- wrapper for shift functions
--
    function U2VShift  (arg : TU2V ; shift : integer ) return TU2V is
    begin
        if shift = 0 then
            return arg ;
        end if ;

        if shift > 0 then
            return U2VShiftLeft(arg,shift) ;
        else
            return U2VShiftRight(arg,-shift) ;
        end if ;
    end function ;

--
-- sum of 2 vectors
--
    function U2VSum(arg1,arg2 : TU2V ; length : natural ) return TU2V  is
        constant INT_SIZE : natural := \maximum\( arg1'length,arg2'length ) ;
        variable result  : TU2V( INT_SIZE downto 0 ) ;
        variable op1,op2 : TU2V( result'range ) ;
    begin
        op1 := U2VResize( arg1,INT_SIZE+1 ) ;
        op2 := U2VResize( arg2,INT_SIZE+1 ) ;

        result := op1+op2 ;

        return U2VResize(result,length) ;
    end function ;

--
-- sub of 2 vectors
--
    function U2VSub(arg1,arg2 : TU2V ; length : natural ) return TU2V  is
        constant INT_SIZE : natural := \maximum\( arg1'length,arg2'length ) ;
        variable result  : TU2V( INT_SIZE downto 0 ) ;
        variable op1,op2 : TU2V( result'range ) ;
    begin
        op1 := U2VResize( arg1,INT_SIZE+1 ) ;
        op2 := U2VResize( arg2,INT_SIZE+1 ) ;

        result := op1-op2 ;

        return U2VResize(result,length) ;
    end function ;

--
-- mult of 2 vectors
--
    function U2VMult(arg1,arg2 : TU2V ; length : natural ) return TU2V is
        variable result  : TU2V( arg1'length+arg2'length-1 downto 0 ) ;
    begin
        result := arg1 * arg2 ;
        return U2VResize(result,length) ;
    end function  ;

--
-- neg of vector
--
    function U2VNeg(arg : TU2V ) return TU2V  is
        variable result : TU2V(arg'range) ;
    begin
        result := not arg ;
        return result+1 ;
    end function ;

--
-- abs of vector
--
    function U2VAbs(arg : TU2V ) return TU2V is
    begin
        if arg(arg'length-1) = '0' then
            return arg ;
        else
            return U2VNeg(arg) ;
        end if ;
    end function ;


--
-- log2 calculation
--
  function log2(arg : natural) return natural is
    variable result : natural ;
     variable index : natural := 0;
  begin
    while true loop
       if 2**index >= arg then
          result := index ;
          exit ;
        end if ;
        index := index + 1 ;
     end loop ;

     return index ;
  end function;

--
-- Check if the argument achieved max value
--
  function U2VMax(arg : TU2V) return TSL is
    variable result : TSL;
  begin
    if (arg(arg'length-1) = '0') and (AND_REDUCE(arg(arg'length-2 downto 0)) = '1') then
      result := '1';
    else
      result := '0';
    end if;

    return result;
  end function;


--
-- Check if the argument achieved min value
--
  function U2VMin(arg : TU2V) return TSL is
    variable result : TSL;
  begin
    if (arg(arg'length-1) = '1') and (OR_REDUCE(arg(arg'length-2 downto 0)) = '0') then
      result := '1';
    else
      result := '0';
    end if;

    return result;
  end function;

--
-- Check if the argument achieved min or max value
--
  function U2VSat (arg : TU2V) return TSL is
  begin
    return U2VMin(arg) or U2VMax(arg);
  end function;

end math_basic;
