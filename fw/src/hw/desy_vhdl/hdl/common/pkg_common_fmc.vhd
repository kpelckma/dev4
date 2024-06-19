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
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! package with common FMC card interfaces
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package common_fmc is

  --============================================================================
  -- FMC LPC Connector
  --============================================================================
  type t_fmc_lpc_m2c is record
    clk_p   : std_logic_vector(1 downto 0);
    clk_n   : std_logic_vector(1 downto 0);
    prsnt_l : std_logic;
  end record t_fmc_lpc_m2c;

  type t_fmc_lpc is record
    la_p   : std_logic_vector(33 downto 0);
    la_n   : std_logic_vector(33 downto 0);
  end record t_fmc_lpc;

  type t_fmc_lpc_mgt_m2c is record
    dp_p  : std_logic_vector(0 downto 0);
    dp_n  : std_logic_vector(0 downto 0);
    clk_p : std_logic_vector(0 downto 0);
    clk_n : std_logic_vector(0 downto 0);
  end record t_fmc_lpc_mgt_m2c;

  type t_fmc_lpc_mgt_c2m is record
    dp_p : std_logic_vector(0 downto 0);
    dp_n : std_logic_vector(0 downto 0);
  end record t_fmc_lpc_mgt_c2m;

  --============================================================================
  -- FMC HPC Connector
  --============================================================================
  type t_fmc_hpc_m2c is record
    clk_p   : std_logic_vector(1 downto 0);
    clk_n   : std_logic_vector(1 downto 0);
    prsnt_l : std_logic;
  end record t_fmc_hpc_m2c;

  type t_fmc_hpc is record
    clk_p    : std_logic_vector(3 downto 2);
    clk_n    : std_logic_vector(3 downto 2);
    clk_dir  : std_logic;
    ha_p     : std_logic_vector(23 downto 0);
    ha_n     : std_logic_vector(23 downto 0);
    hb_p     : std_logic_vector(21 downto 0);
    hb_n     : std_logic_vector(21 downto 0);
    la_p     : std_logic_vector(33 downto 0);
    la_n     : std_logic_vector(33 downto 0);
  end record t_fmc_hpc;

  type t_fmc_hpc_mgt_m2c is record
    dp_p  : std_logic_vector(9 downto 0);
    dp_n  : std_logic_vector(9 downto 0);
    clk_p : std_logic_vector(1 downto 0);
    clk_n : std_logic_vector(1 downto 0);
  end record t_fmc_hpc_mgt_m2c;

  type t_fmc_hpc_mgt_c2m is record
    dp_p : std_logic_vector(9 downto 0);
    dp_n : std_logic_vector(9 downto 0);
  end record t_fmc_hpc_mgt_c2m;

  --============================================================================
  -- FMC+ HSPC Connector
  --============================================================================
  type t_fmc_hspc_m2c is record
    clk_p        : std_logic_vector(1 downto 0);
    clk_n        : std_logic_vector(1 downto 0);
    sync_p       : std_logic;
    sync_n       : std_logic;
    refclk_p     : std_logic;
    refclk_n     : std_logic;
    prsnt_l      : std_logic;
    prsnt_hspc_l : std_logic;
  end record t_fmc_hspc_m2c;

  type t_fmc_hspc_c2m is record
    sync_p   : std_logic;
    sync_n   : std_logic;
    refclk_p : std_logic;
    refclk_n : std_logic;
  end record t_fmc_hspc_c2m;

  type t_fmc_hspc is record
    clk_p    : std_logic_vector(3 downto 2);
    clk_n    : std_logic_vector(3 downto 2);
    clk_dir  : std_logic;
    ha_p     : std_logic_vector(23 downto 0);
    ha_n     : std_logic_vector(23 downto 0);
    hb_p     : std_logic_vector(21 downto 0);
    hb_n     : std_logic_vector(21 downto 0);
    la_p     : std_logic_vector(33 downto 0);
    la_n     : std_logic_vector(33 downto 0);
  end record t_fmc_hspc;

  type t_fmc_hspc_mgt_m2c is record
    dp_p  : std_logic_vector(23 downto 0);
    dp_n  : std_logic_vector(23 downto 0);
    clk_p : std_logic_vector(5 downto 0);
    clk_n : std_logic_vector(5 downto 0);
  end record t_fmc_hspc_mgt_m2c;

  type t_fmc_hspc_mgt_c2m is record
    dp_p : std_logic_vector(23 downto 0);
    dp_n : std_logic_vector(23 downto 0);
  end record t_fmc_hspc_mgt_c2m;


end package common_fmc;
