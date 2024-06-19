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
--! @date 2022-04-20
--! @author Radoslaw Rybaniec
-------------------------------------------------------------------------------
--! @brief
--! First In First Out buffer, functions package
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package memory_fifo is

  type t_fifo_conf is record
    n_18          : natural;
    n_36          : natural;
    n_layers      : natural;
    data_width_18 : natural;
    data_width_36 : natural;
    layer_width   : natural;
    layer_depth   : natural;
    prog_full     : natural;
  end record t_fifo_conf;

  type t_fifo_ultra_conf is record
    n_18             : natural;
    n_36             : natural;
    n_layers         : natural;
    data_wr_width_18 : natural;
    data_rd_width_18 : natural;
    data_wr_width_36 : natural;
    data_rd_width_36 : natural;
    layer_width      : natural;
    layer_depth      : natural;
    prog_full        : natural;
  end record t_fifo_ultra_conf;

  function fun_mode_to_depth (constant mode : natural) return natural;
  function fun_mode_to_width (
    constant mode : natural;
    constant enable_ecc : boolean
  ) return natural;
  function fun_get_fifo_conf (
    constant max_latency : natural;
    constant max_comb    : natural;
    constant width       : natural;
    constant depth       : natural;
    constant pfull       : natural;
    constant enable_ecc  : boolean
  ) return t_fifo_conf ;

end package;

package body memory_fifo is

  function fun_mode_to_depth (constant mode : natural)
    return natural is
    variable ret : natural := 0;
  begin
    case mode is
      when 0      => ret := 512;
      when 1      => ret := 1024;
      when 2      => ret := 2048;
      when 3      => ret := 4096;
      when 4      => ret := 8192;
      when others => null;
    end case;
    return ret;
  end fun_mode_to_depth;

  function fun_mode_to_width (
    constant mode : natural;
    constant enable_ecc : boolean
  ) return natural is
    variable ret : natural := 0;
  begin
    if enable_ecc then
      case mode is
        when 0      => ret := 64;
        when 1      => ret := 32;
        when 2      => ret := 16;
        when 3      => ret := 8;
        when 4      => ret := 4;
        when others => null;
      end case;
    else
      case mode is
        when 0      => ret := 72;
        when 1      => ret := 36;
        when 2      => ret := 18;
        when 3      => ret := 9;
        when 4      => ret := 4;
        when others => null;
      end case;
    end if;
    return ret;
  end fun_mode_to_width;


  function fun_get_fifo_conf (
    constant max_latency : natural;
    constant max_comb    : natural;
    constant width       : natural;
    constant depth       : natural;
    constant pfull       : natural;
    constant enable_ecc  : boolean
  ) return t_fifo_conf is
    variable v_goal            : natural := 100000;
    variable v_18_cnt          : natural := 0;  -- number of fifo18 primitives used
    variable v_36_cnt          : natural := 0;  -- number of fifo33 primitives used
    variable v_18_tmpcnt       : natural := 0;
    variable v_36_tmpcnt       : natural := 0;
    variable v_width_comb      : natural := 0;
    variable v_latency         : natural := 0;
    variable v_tmp_latency     : natural := 0;

    --variable v_tmp_mode        : natural;       -- 0:512, 1:1k, 2:2k, 3:4k, 4:8k
    variable v_mode            : natural := 0;  -- 0:512, 1:1k, 2:2k, 3:4k, 4:8k
    variable v_remaining_width : integer := width;
    variable v_remaining_depth : integer := depth;
    variable int               : integer;
    variable result            : t_fifo_conf;
  begin
    --if max_comb /= 0 then
    --  v_width_comb := width / max_comb;
    --  if v_width_comb > 72 then
    --    kiszka
    --  else

    for v_tmp_mode in 0 to 4 loop
      v_18_tmpcnt       := 0;
      v_36_tmpcnt       := 0;
      v_remaining_width := width;
      v_remaining_depth := depth;
      while v_remaining_width > 0 loop
        if v_remaining_width - (fun_mode_to_width(v_tmp_mode, enable_ecc)/2) <= 0 and v_tmp_mode /= 4 and enable_ecc = false then
          v_18_tmpcnt       := v_18_tmpcnt + 1;
          v_remaining_width := v_remaining_width - (fun_mode_to_width(v_tmp_mode, enable_ecc)/2);
        else
          v_36_tmpcnt       := v_36_tmpcnt + 1;
          v_remaining_width := v_remaining_width - fun_mode_to_width(v_tmp_mode, enable_ecc);
        end if;
      end loop;
      -- here we are checking optimization goal
      if v_18_tmpcnt + v_36_tmpcnt <= max_comb or max_comb = 0 then  -- good combination
        v_remaining_depth := depth;
        v_tmp_latency         := 0;
        while v_remaining_depth > 0 loop
          v_remaining_depth := v_remaining_depth - fun_mode_to_depth(v_tmp_mode);
          v_tmp_latency         := v_tmp_latency + 1;
        end loop;
        if v_tmp_latency <= max_latency or max_latency = 0 then  -- levels of latency met
          -- goal function calculation
          -- brams+latency
          -- depth+latency?
          -- 2depth+latency?
          -- depth+2latency?

          --report "---------------" severity note;
          --report "mode is: " & int'image(v_tmp_mode) severity note;
          --report "    v18: " & int'image(v_18_tmpcnt) severity note;
          --report "    v36: " & int'image(v_36_tmpcnt) severity note;
          --report "latency: " & int'image(v_tmp_latency) severity note;
          --report "  goal_width: " &int'image(v_18_tmpcnt*2+v_36_tmpcnt*2+v_tmp_latency) severity note;
          --report "goal_latency: " &int'image(v_18_tmpcnt+v_36_tmpcnt+v_tmp_latency*2) severity note;
          --report "  goal_brams: " &int'image((v_18_tmpcnt+v_36_tmpcnt)*v_tmp_latency+v_tmp_latency) severity note;
          --report "---------------" severity note;

          if v_tmp_latency * (v_18_tmpcnt + v_36_tmpcnt + 1) < v_goal then
            v_goal   := v_tmp_latency * (v_18_tmpcnt + v_36_tmpcnt + 1);
            v_18_cnt := v_18_tmpcnt;
            v_36_cnt := v_36_tmpcnt;
            v_mode   := v_tmp_mode;
            v_latency := v_tmp_latency;
          end if;
        end if;
      end if;

    end loop;  -- v_mode

    if enable_ecc and v_18_cnt > 0 then -- sanity check
      report "selected 18kb fifos but also using ecc" severity failure;
    end if;

    if v_goal < 100000 then
      report "-----fifo configuration-----" severity note;
      report "     layer depth is: " & integer'image(fun_mode_to_depth(v_mode)) severity note;
      report "    number of blk18: " & integer'image(v_18_cnt) severity note;
      report "    number of blk36: " & integer'image(v_36_cnt) severity note;
      report "   number of layers: " & integer'image(v_latency) severity note;
    --  report "   optimization goal: " &int'image((v_18_cnt+v_36_cnt+1)*v_latency) severity note;
      report "----------------------------" severity note;

      result.n_18 := v_18_cnt;
      result.data_width_18 :=  fun_mode_to_width(v_mode, enable_ecc)/2;
      result.data_width_36 :=  fun_mode_to_width(v_mode, enable_ecc);
      result.n_36 := v_36_cnt;
      result.n_layers  := v_latency;
      result.prog_full := pfull mod fun_mode_to_depth(v_mode);
      result.layer_width := result.n_36*result.data_width_36 + result.n_18*result.data_width_18;
      result.layer_depth := fun_mode_to_depth(v_mode);

    else
      report "fun_get_fifo_conf: unable to select fifo configuration" severity failure;
    end if;
    return result;
  end fun_get_fifo_conf;


end package body memory_fifo;
