------------------------------------------------------------------------------
--
-- internal 32bit fixed point representation in the MIMO control implementation
--
-- we use Q15.16 with a sign bit
--
-- Format (b32 in fixed point):
-- 0     000000000_00000000 . 000000000_000000000
-- sign  integer_part (15b) . fractional part (16b)
--
-- converion to 16b signals (representing integer values) is hence done by
-- selecting the first 16bits. This done by the function to_b16()
--
--
-- x = s1 * 2^-16
-- y = s2 * 2^-16
-- x * y = s1*s2 * 2^-32  *  2^16 = shift_right(signed(s1)*signed(s2) , 16)
--
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package b32 is

  -- vector
  type t_b32v is array (natural range<>) of std_logic_vector(31 downto 0);
  type t_s32v is array (natural range<>) of signed(31 downto 0);
  type t_u32v is array (natural range<>) of unsigned(31 downto 0);
  
  -- matrix
  type t_b32m is array (natural range<>, natural range<>) of std_logic_vector(31 downto 0);
  type t_s32m is array (natural range<>, natural range<>) of signed(31 downto 0);
  type t_u32m is array (natural range<>, natural range<>) of unsigned(31 downto 0);

  -- conversion to slv from/to b32v
  function b32v_to_slv(arg: t_b32v) return std_logic_vector;
  function slv_to_b32v(arg: std_logic_vector) return t_b32v;
  function to_16b(arg: std_logic_vector) return std_logic_vector;

  -- simple matrix-vector or matrix-matrix products
  function "+" (l, r : t_b32v) return t_b32v;  -- elemtwise sum
  function "*" (l, r : t_b32v) return t_b32v;  -- elementwise prof=duct
  function "**" (l, r : t_b32v) return std_logic_vector; -- vector-vector product
  function "**" (l, r : t_b32m) return t_b32m; -- matrix-matrix product

  function cumsum(arg: t_b32v) return signed;

end b32;


-- ============================================================================
package body b32 is

  function b32v_to_slv(arg : t_b32v) return std_logic_vector is
    variable v_vec : std_logic_vector(32*(arg'length)-1 downto 0);
  begin
    for I in 0 to arg'length-1 loop
      v_vec(32*(I+1)-1 downto 32*I) := arg(I) ;
    end loop ;
    return v_vec ;
  end function ;


  function slv_to_b32v(arg : std_logic_vector) return t_b32v is
    variable v_arr : t_b32v((arg'length/32)-1 downto 0) ;
  begin
    for I in 0 to arg'length/32-1 loop
      v_arr(I) := arg(32*(I+1)-1 downto 32*I) ;
    end loop ;
    return v_arr ;
  end function ;

  -- return integer part of the b32  argument
  function to_16b(arg: std_logic_vector) return std_logic_vector is
    variable result : std_logic_vector(15 downto 0);
    begin
      result := arg(31 downto 16);
      return result;
    end function;


  function "+" (l, r : t_b32v) return t_b32v is
      variable result : t_b32v(l'length-1 downto 0);
    begin
      for I in 0 to l'length-1 loop
        result(I) := std_logic_vector(signed(l(I)) + signed(r(I)) );
      end loop ;
      return result;
    end function "+";


  function "*" (l, r : t_b32v) return t_b32v is
      variable result : t_b32v(l'length-1 downto 0);
    begin
      for I in 0 to l'length-1 loop
        result(I) := std_logic_vector(resize(shift_right(signed(l(I)) * signed(r(I)),16), 32 ));
      end loop ;
      return result;
    end function "*";

  function "**" (l,r: t_b32v) return std_logic_vector is
  begin
    return std_logic_vector(cumsum(l * r));
  end function "**";
  
  
  function "**" (l,r: t_b32m) return t_b32m is
    variable ff : t_s32m(l'length-1 downto 0, r'length-1 downto 0) := (others=>(others=>(others=>'0')));  
    variable result : t_b32m(l'length-1 downto 0, r'length-1 downto 0);
  begin
    for i in 0 to l'length(1)-1 loop
      for j in 0 to r'length(2)-1 loop
        for k in 0 to l'length(2)-1 loop
          ff(i,j) := ff(i,j) + signed(l(i,k))*signed(r(j,k));
        end loop;
        result(i,j) := std_logic_vector(ff(i,j)); 
      end loop ;
    end loop;
    return result; 
  end function "**";


  --------------------------------------------------------
  function cumsum(arg : t_b32v) return signed is
    variable result : signed(31 downto 0) := (others=>'0');
    begin
      for I in 0 to arg'length-1 loop
        result := result + signed(arg(I)) ;
      end loop ;
      return result;
    end function ;



end b32;
