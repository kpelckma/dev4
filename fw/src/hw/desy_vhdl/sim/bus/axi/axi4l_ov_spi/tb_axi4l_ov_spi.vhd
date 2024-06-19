------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2023 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2023-02-08
--! @author Katharina Schulz  <katharina.schulz@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Test Bench of axi4l_ov_spi verification project including Test Sequencer
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library uvvm_vvc_framework;
use uvvm_vvc_framework.ti_vvc_framework_support_pkg.all;

library bitvis_vip_clock_generator;
context bitvis_vip_clock_generator.vvc_context;

library bitvis_vip_gpio;
context bitvis_vip_gpio.vvc_context;

library bitvis_vip_axilite;
context bitvis_vip_axilite.vvc_context;

library desy;
use desy.common_types.all;
use desy.common_axi.all;

library work;
use work.pkg_config.all;

-- Test bench entity
entity tb_axi4l_ov_spi is
end entity tb_axi4l_ov_spi;
  
  -- Test bench architecture
architecture arch of tb_axi4l_ov_spi is

  constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;
  -- Clock and bit period settings
  constant C_CLK_PERIOD : time := 20 ns;
  
begin
  -----------------------------------------------------------------------------
  -- Instantiate test harness, containing DUT and Executors
  -----------------------------------------------------------------------------
  i_test_harness : entity work.th_axi4l_ov_spi;

  -- PROCESS: p_main
  ------------------------------------------------
  p_main : process
  variable v_cmd_idx         : natural;
  begin

    await_uvvm_initialization(VOID);

    shared_axilite_vvc_config(1).bfm_config.max_wait_cycles := 100000;
    start_clock(CLOCK_GENERATOR_VVCT, 1, "Start clock generator");
    start_clock(CLOCK_GENERATOR_VVCT, 2, "Start IIclock generator");
    wait for (10 * C_CLK_PERIOD);       -- for reset to be turned off
    wait for (10 * C_CLK_PERIOD);       -- for reset to be turned off
    log("Wait 10 clock period for reset to be turned off");

    
    axilite_write(AXILITE_VVCT,1,x"80_00_00_05", x"0F_A0_00_03" , "Writing Data to AXI");
    wait for (1000 ns);
    axilite_read(AXILITE_VVCT,1,x"80_00_00_05", "Reading Data from II");
    wait for (1000 ns);
    axilite_write(AXILITE_VVCT,1,x"80_00_AA_05", x"0A_BC_12_34" , "Writing Data to AXI");
    wait for (4000 ns);
    axilite_read(AXILITE_VVCT,1,x"80_00_AA_05", "Reading Data from II");
    wait for (1000 ns);
    axilite_read(AXILITE_VVCT,1,x"80_00_AA_BB", "Reading Data from II");
    wait for (500 ns);
    axilite_write(AXILITE_VVCT,1,x"12_34_56_78", x"FE_DC_BA_98" , "Writing Data to AXI");
    wait for (500 ns);
    axilite_read(AXILITE_VVCT,1,x"12_34_56_78", "Reading Data from II");
    

    -- -----------------------------------------------------------------------------
    -- -- Ending the simulation
    -- -----------------------------------------------------------------------------
    wait for (1000 * C_CLK_PERIOD);
    -- Finish the simulation
    std.env.stop;
    wait;                               -- to stop completely

  end process p_main;
end architecture arch;