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
--! @date
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! I2C controller with priority synced arbiter
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.common_types.all;
------------------------------------------------------------------------------

entity i2c_control_arbiter is
  generic (
    G_PORTS_NUM   : natural := 3;   --! number of ports
    G_I2C_CLK_DIV : integer := 800; --! clock divider for I2C
    G_CS_ENA      : natural := 0    --! enable CS for I2C controller
  );
  port (
    pi_clock      : in    std_logic;
    pi_reset      : in    std_logic;
    ---------------------------------------------------------------------------
    --! Arbiter
    ---------------------------------------------------------------------------
    pi_i2c_req    : in    std_logic_vector(G_PORTS_NUM - 1 downto 0);
    po_i2c_grant  : out   std_logic_vector(G_PORTS_NUM - 1 downto 0);
    ---------------------------------------------------------------------------
    --! Ports
    ---------------------------------------------------------------------------
    pi_str        : in    std_logic_vector(G_PORTS_NUM - 1 downto 0);
    pi_wr         : in    std_logic_vector(G_PORTS_NUM - 1 downto 0);
    pi_rep        : in    std_logic_vector(G_PORTS_NUM - 1 downto 0);
    pi_data_width : in    t_2b_slv_vector(G_PORTS_NUM - 1 downto 0);
    pi_data       : in    t_32b_slv_vector(G_PORTS_NUM - 1 downto 0);
    pi_addr       : in    t_8b_slv_vector(G_PORTS_NUM - 1 downto 0);
    po_data       : out   std_logic_vector(31 downto 0);
    po_done       : out   std_logic_vector(G_PORTS_NUM - 1 downto 0);
    po_busy       : out   std_logic_vector(G_PORTS_NUM - 1 downto 0);
    po_dry        : out   std_logic_vector(G_PORTS_NUM - 1 downto 0);
    ---------------------------------------------------------------------------
    --! I2C interface
    ---------------------------------------------------------------------------
    pi_sdi        : in    std_logic;  --! data input
    po_sdo        : out   std_logic;  --! data output
    po_sdt        : out   std_logic;  --! data direction
    pi_sci        : in    std_logic;  --! clock input
    po_sco        : out   std_logic;  --! clock output
    po_sct        : out   std_logic   --! clock direction
  );
end entity i2c_control_arbiter;

------------------------------------------------------------------------------

architecture arch of i2c_control_arbiter is

  signal sig_clk_cnt        : natural := 0;

  signal sig_i2c_done       : std_logic;
  signal sig_i2c_busy       : std_logic;
  signal sig_i2c_dry        : std_logic;
  signal sig_i2c_str        : std_logic;
  -- signal SIG_I2C_CLK  : std_logic := '0';
  signal sig_i2c_clk2       : std_logic := '0';
  signal sig_i2c_wr         : std_logic;
  signal sig_i2c_rep        : std_logic := '0';

  signal sig_i2c_data_o     : std_logic_vector(31 downto 0);
  signal sig_i2c_data_i     : std_logic_vector(31 downto 0);
  signal sig_i2c_addr       : std_logic_vector(6 downto 0);
  signal sig_i2c_data_width : std_logic_vector(1 downto 0);

  signal sig_sdi            : std_logic;
  signal sig_sdo            : std_logic;
  signal sig_sdt            : std_logic;
  signal sig_sci            : std_logic;
  signal sig_sco            : std_logic;
  signal sig_sct            : std_logic;

  signal sig_arb_req        : std_logic_vector(G_PORTS_NUM - 1 downto 0);
  signal sig_arb_grant      : std_logic_vector(G_PORTS_NUM - 1 downto 0);

  function f_or_arb (arg: std_logic_vector; grant: std_logic_vector; number : natural) return std_logic is

    variable v_loc_or : std_logic_vector(number - 1 downto 0);

  begin

    v_loc_or(0) := arg(0) and grant(0);

    if (number > 0) then

      l_str : for I in 1 to number - 1 loop

        v_loc_or(I) := v_loc_or(I - 1) or (arg(I)  and grant(I));

      end loop;

    end if;

    return v_loc_or(number - 1);

  end function;

  function f_orv2b_arb (arg: t_2b_slv_vector; grant: std_logic_vector; number : natural) return std_logic_vector is

    variable v_loc_or  : t_2b_slv_vector(number - 1 downto 0);
    variable v_and_arg : t_2b_slv_vector(number - 1 downto 0);

  begin

    larg : for I in 0 to number - 1 loop

      if (grant(I) = '1') then
        v_and_arg(I) := arg(I);
      else
        v_and_arg(I) := (others => '0');
      end if;

    -- v_and_arg(I) := arg(I) when grant(I) = '1' else (others => '0');

    end loop;

    v_loc_or(0) := v_and_arg(0);

    if (number > 0) then

      l_str : for I in 1 to number - 1 loop

        v_loc_or(I) := v_loc_or(I - 1) or v_and_arg(I);

      end loop;

    end if;

    return v_loc_or(number - 1);

  end function;

  function f_orv2b_arb (arg: t_8b_slv_vector; grant: std_logic_vector; number : natural) return std_logic_vector is

    variable v_loc_or  : t_8b_slv_vector(number - 1 downto 0);
    variable v_and_arg : t_8b_slv_vector(number - 1 downto 0);

  begin

    larg : for I in 0 to number - 1 loop

      if (grant(I) = '1') then
        v_and_arg(I) := arg(I);
      else
        v_and_arg(I) := (others => '0');
      end if;

    end loop;

    v_loc_or(0) := v_and_arg(0);

    if (number > 0) then

      l_str : for I in 1 to number - 1 loop

        v_loc_or(I) := v_loc_or(I - 1) or v_and_arg(I);

      end loop;

    end if;

    return v_loc_or(number - 1);

  end function;

  function f_orv2b_arb (arg: t_32b_slv_vector; grant: std_logic_vector; number : natural) return std_logic_vector is

    variable v_loc_or  : t_32b_slv_vector(number - 1 downto 0);
    variable v_and_arg : t_32b_slv_vector(number - 1 downto 0);

  begin

    larg : for I in 0 to number - 1 loop

      if (grant(I) = '1') then
        v_and_arg(I) := arg(I);
      else
        v_and_arg(I) := (others => '0');
      end if;

    -- v_and_arg(I) := arg(I) when grant(I) = '1' else (others => '0');

    end loop;

    v_loc_or(0) := v_and_arg(0);

    if (number > 0) then

      l_str : for I in 1 to number - 1 loop

        v_loc_or(I) := v_loc_or(I - 1) or v_and_arg(I);

      end loop;

    end if;

    return v_loc_or(number - 1);

  end function;

begin

  sig_arb_req  <= pi_i2c_req;
  po_i2c_grant <= sig_arb_grant;

  sig_sdi <= pi_sdi;
  po_sdo  <= sig_sdo;
  po_sdt  <= sig_sdt;
  sig_sci <= pi_sci;
  po_sco  <= sig_sco;
  po_sct  <= sig_sct;

  --! I2C Controller
  inst_i2c_controller : entity work.i2c_controller
    generic map (
      G_DIVIDER => ( G_I2C_CLK_DIV )
    )
    port map (
      pi_clock => pi_clock,
      pi_reset => pi_reset,
      --      P_I_SLOW_CLK   => SIG_I2C_CLK,
      pi_str        => sig_i2c_str,
      pi_wr         => sig_i2c_wr,
      pi_rep        => sig_i2c_rep,
      pi_data_width => sig_i2c_data_width,
      pi_data       => sig_i2c_data_i,
      po_data       => sig_i2c_data_o,
      po_data_dry  => sig_i2c_dry,
      pi_addr       => sig_i2c_addr,
      pi_sdi        => sig_sdi,
      po_sdo        => sig_sdo,
      po_sdt        => sig_sdt,
      pi_sci        => sig_sci,
      po_sco        => sig_sco,
      po_sct        => sig_sct,
      po_done       => sig_i2c_done,
      po_busy       => sig_i2c_busy
    );

  -- process(SIG_ARB_GRANT,
  -- pi_str,
  -- pi_wr,
  -- pi_data,
  -- pi_addr,
  -- pi_data_width)
  -- begin
  -- for I in 0 to G_PORTS_NUM-1 loop
  -- if SIG_ARB_GRANT(I) = '1' then
  -- SIG_I2C_STR        <= pi_str(I);
  -- SIG_I2C_WR         <= pi_wr(I);
  -- SIG_I2C_DATA_I     <= pi_data(I);
  -- SIG_I2C_ADDR       <= pi_addr(I)(6 downto 0);
  -- SIG_I2C_DATA_WIDTH <= pi_data_width(I);
  -- end if;
  -- end loop;
  -- end process;

  sig_i2c_str        <= f_or_arb(pi_str, sig_arb_grant, G_PORTS_NUM);
  sig_i2c_wr         <= f_or_arb(pi_wr, sig_arb_grant, G_PORTS_NUM);
  sig_i2c_rep        <= f_or_arb(pi_rep, sig_arb_grant, G_PORTS_NUM);
  sig_i2c_data_i     <= f_orv2b_arb(pi_data, sig_arb_grant, G_PORTS_NUM);
  sig_i2c_addr       <= f_orv2b_arb(pi_addr, sig_arb_grant, G_PORTS_NUM)(6 downto 0);
  sig_i2c_data_width <= f_orv2b_arb(pi_data_width, sig_arb_grant, G_PORTS_NUM);

  po_data <= sig_i2c_data_o;

  gen_i2c_sig : for I in 0 to G_PORTS_NUM - 1 generate
    po_done(I) <= sig_i2c_done and sig_arb_grant(I);
    po_busy(I) <= sig_i2c_busy and sig_arb_grant(I);
    po_dry(I)  <= sig_i2c_dry and sig_arb_grant(I);
  end generate gen_i2c_sig;

  inst_priority_arbiter_synced : entity work.arbiter_priority_synced
    generic map (
      G_REQUESTER => G_PORTS_NUM
    )
    port map (
      pi_clock => pi_clock,
      pi_reset => pi_reset,
      pi_req   => sig_arb_req,
      po_grant => sig_arb_grant
    );

-- process(pi_clock)
-- begin
-- if rising_edge(pi_clock) then
-- if SIG_CLK_CNT < G_I2C_CLK_DIV/2-1 then
-- SIG_CLK_CNT <= SIG_CLK_CNT + 1;
-- else
-- SIG_CLK_CNT <= 0;
-- SIG_I2C_CLK <= not SIG_I2C_CLK;
-- end if;
-- end if;
-- end process;

-- P_O_SLOW_CLK <= SIG_I2C_CLK;

end architecture arch;
