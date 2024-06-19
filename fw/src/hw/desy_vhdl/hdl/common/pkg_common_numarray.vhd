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
--! @date 2022-01-04
--! @author Burak Dursun <burak.dursun@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Package for arrays of numeric data types
------------------------------------------------------------------------------

package common_numarray is

  type t_real_vector is array (natural range <>) of real;
  type t_integer_vector is array (natural range <>) of integer;
  type t_natural_vector is array (natural range <>) of natural;
  type t_positive_vector is array (natural range <>) of positive;

  type t_real_matrix is array (natural range <>, natural range <>) of real;
  type t_integer_matrix is array (natural range <>, natural range <>) of integer;
  type t_natural_matrix is array (natural range <>, natural range <>) of natural;
  type t_positive_matrix is array (natural range <>, natural range <>) of positive;

  function "+" (C_LEFT: t_real_vector; C_RIGHT: t_real_vector) return t_real_vector;
  function "-" (C_LEFT: t_real_vector; C_RIGHT: t_real_vector) return t_real_vector;
  function "*" (C_LEFT: t_real_vector; C_RIGHT: t_real_vector) return t_real_vector;
  function "/" (C_LEFT: t_real_vector; C_RIGHT: t_real_vector) return t_real_vector;
  function f_sum(C_ARG: t_real_vector) return real;
  function f_max(C_ARG: t_real_vector) return real;
  function f_min(C_ARG: t_real_vector) return real;
  function "+" (C_LEFT: t_integer_vector; C_RIGHT: t_integer_vector) return t_integer_vector;
  function "-" (C_LEFT: t_integer_vector; C_RIGHT: t_integer_vector) return t_integer_vector;
  function "*" (C_LEFT: t_integer_vector; C_RIGHT: t_integer_vector) return t_integer_vector;
  function "/" (C_LEFT: t_integer_vector; C_RIGHT: t_integer_vector) return t_integer_vector;
  function f_sum(C_ARG: t_integer_vector) return integer;
  function f_max(C_ARG: t_integer_vector) return integer;
  function f_min(C_ARG: t_integer_vector) return integer;
  function f_left(C_ARG: t_integer_vector; C_INDEX: natural) return integer;
  function f_right(C_ARG: t_integer_vector; C_INDEX: natural) return integer;

end package common_numarray;

package body common_numarray is

  function "+" (C_LEFT: t_real_vector; C_RIGHT: t_real_vector) return t_real_vector is
    variable v_result : t_real_vector(C_LEFT'range);
  begin
    assert C_LEFT'length = C_RIGHT'length report "dimensions must aggree" severity error;
    assert C_LEFT'ascending xnor C_RIGHT'ascending report "ranges must aggree" severity error;
    for I in C_LEFT'range loop
      v_result(I) := C_LEFT(I) + C_RIGHT(I);
    end loop;
    return v_result;
  end function "+";

  function "-" (C_LEFT: t_real_vector; C_RIGHT: t_real_vector) return t_real_vector is
    variable v_result : t_real_vector(C_LEFT'range);
  begin
    assert C_LEFT'length = C_RIGHT'length report "dimensions must aggree" severity error;
    assert C_LEFT'ascending xnor C_RIGHT'ascending report "ranges must aggree" severity error;
    for I in C_LEFT'range loop
      v_result(I) := C_LEFT(I) - C_RIGHT(I);
    end loop;
    return v_result;
  end function "-";

  function "*" (C_LEFT: t_real_vector; C_RIGHT: t_real_vector) return t_real_vector is
    variable v_result : t_real_vector(C_LEFT'range);
  begin
    assert C_LEFT'length = C_RIGHT'length report "dimensions must aggree" severity error;
    assert C_LEFT'ascending xnor C_RIGHT'ascending report "ranges must aggree" severity error;
    for I in C_LEFT'range loop
      v_result(I) := C_LEFT(I) * C_RIGHT(I);
    end loop;
    return v_result;
  end function "*";

  function "/" (C_LEFT: t_real_vector; C_RIGHT: t_real_vector) return t_real_vector is
    variable v_result : t_real_vector(C_LEFT'range);
  begin
    assert C_LEFT'length = C_RIGHT'length report "dimensions must aggree" severity error;
    assert C_LEFT'ascending xnor C_RIGHT'ascending report "ranges must aggree" severity error;
    for I in C_LEFT'range loop
      v_result(I) := C_LEFT(I) / C_RIGHT(I);
    end loop;
    return v_result;
  end function "/";

  function f_sum(C_ARG: t_real_vector) return real is
    variable v_result : real := 0.0;
  begin
    for I in C_ARG'range loop
      v_result := C_ARG(I) + v_result;
    end loop;
    return v_result;
  end function f_sum;

  function f_max(C_ARG: t_real_vector) return real is
    variable v_result : real := real'low;
  begin
    for I in C_ARG'range loop
      if C_ARG(I) > v_result then
        v_result := C_ARG(I);
      end if;
    end loop;
    return v_result;
  end function f_max;

  function f_min(C_ARG: t_real_vector) return real is
    variable v_result : real := real'high;
  begin
    for I in C_ARG'range loop
      if C_ARG(I) < v_result then
        v_result := C_ARG(I);
      end if;
    end loop;
    return v_result;
  end function f_min;

  function "+" (C_LEFT: t_integer_vector; C_RIGHT: t_integer_vector) return t_integer_vector is
    variable v_result : t_integer_vector(C_LEFT'range);
  begin
    assert C_LEFT'length = C_RIGHT'length report "dimensions must aggree" severity error;
    assert C_LEFT'ascending xnor C_RIGHT'ascending report "ranges must aggree" severity error;
    for I in C_LEFT'range loop
      v_result(I) := C_LEFT(I) + C_RIGHT(I);
    end loop;
    return v_result;
  end function "+";

  function "-" (C_LEFT: t_integer_vector; C_RIGHT: t_integer_vector) return t_integer_vector is
    variable v_result : t_integer_vector(C_LEFT'range);
  begin
    assert C_LEFT'length = C_RIGHT'length report "dimensions must aggree" severity error;
    assert C_LEFT'ascending xnor C_RIGHT'ascending report "ranges must aggree" severity error;
    for I in C_LEFT'range loop
      v_result(I) := C_LEFT(I) - C_RIGHT(I);
    end loop;
    return v_result;
  end function "-";

  function "*" (C_LEFT: t_integer_vector; C_RIGHT: t_integer_vector) return t_integer_vector is
    variable v_result : t_integer_vector(C_LEFT'range);
  begin
    assert C_LEFT'length = C_RIGHT'length report "dimensions must aggree" severity error;
    assert C_LEFT'ascending xnor C_RIGHT'ascending report "ranges must aggree" severity error;
    for I in C_LEFT'range loop
      v_result(I) := C_LEFT(I) * C_RIGHT(I);
    end loop;
    return v_result;
  end function "*";

  function "/" (C_LEFT: t_integer_vector; C_RIGHT: t_integer_vector) return t_integer_vector is
    variable v_result : t_integer_vector(C_LEFT'range);
  begin
    assert C_LEFT'length = C_RIGHT'length report "dimensions must aggree" severity error;
    assert C_LEFT'ascending xnor C_RIGHT'ascending report "ranges must aggree" severity error;
    for I in C_LEFT'range loop
      v_result(I) := C_LEFT(I) / C_RIGHT(I);
    end loop;
    return v_result;
  end function "/";

  function f_sum(C_ARG: t_integer_vector) return integer is
    variable v_result : integer := 0;
  begin
    for I in C_ARG'range loop
      v_result := C_ARG(I) + v_result;
    end loop;
    return v_result;
  end function f_sum;

  function f_max(C_ARG: t_integer_vector) return integer is
    variable v_result : integer := integer'low;
  begin
    for I in C_ARG'range loop
      if C_ARG(I) > v_result then
        v_result := C_ARG(I);
      end if;
    end loop;
    return v_result;
  end function f_max;

  function f_min(C_ARG: t_integer_vector) return integer is
    variable v_result : integer := integer'high;
  begin
    for I in C_ARG'range loop
      if C_ARG(I) < v_result then
        v_result := C_ARG(I);
      end if;
    end loop;
    return v_result;
  end function f_min;

  function f_left(C_ARG: t_integer_vector; C_INDEX: natural) return integer is
  begin
    return f_sum(C_ARG(C_INDEX downto 0)) - 1;
  end function f_left;

  function f_right(C_ARG: t_integer_vector; C_INDEX: natural) return integer is
  begin
    return f_sum(C_ARG(C_INDEX-1 downto 0));
  end function f_right;

end package body common_numarray;
