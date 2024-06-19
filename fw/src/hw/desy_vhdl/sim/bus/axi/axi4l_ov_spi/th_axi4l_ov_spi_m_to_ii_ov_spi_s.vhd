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
--! @date 2023-03-28
--! @author Katharina Schulz  <katharina.schulz@desy.de>
------------------------------------------------------------------------------
--! @brief
--! UVVM Test Harnes of axi4l_ov_spi 
--! Transaction axi4l manager interface over spi to II subordinate register 
-- axi4l_s       ov_spi_m      ov_spi_s      II_m
-- +--------------+             +-----------+
-- |              |             |           |
-- |axi4l_ov_spi_m| ---4w_SPI-->|ii_ov_spi_s|
-- |              |             |           |
-- +--------------+             +-----------+
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

library bitvis_vip_sbi;
context bitvis_vip_sbi.vvc_context;

library bitvis_vip_axilite;
context bitvis_vip_axilite.vvc_context;

library desy;
use desy.common_types.all;
use desy.common_axi.all;
use desy.bus_ii.all;

library work;
use work.pkg_config.all;

------------------------------------------------------------------------------------------------------------------------
entity th_axi4l_ov_spi is
  generic (
    G_TIMEOUT     : natural := 256;
    G_CPOL        : natural := 0
  );
end entity th_axi4l_ov_spi;
------------------------------------------------------------------------------------------------------------------------

architecture sim of th_axi4l_ov_spi is

  constant C_CLK_PERIOD : time      := 20 ns; -- 50 MHz
  constant C_CLK_PERIOD_II : time   := 19 ns;

  signal  clock        : std_logic := '0';
  signal  ii_clock     : std_logic := '0';
  signal  reset        : std_logic := '0';

  --SPI IF
  signal  spi_m2s_mosi : std_logic := '0';
  signal  spi_m2s_miso : std_logic := '0';
  signal  spi_m2s_sclk : std_logic := '0';
  signal  spi_m2s_sc_n : std_logic := '0';

  --AXI4L Manager IF to spi
  signal  m2s_axi4l_s_if : t_axi4l_m2s := C_AXI4L_M2S_DEFAULT;
  signal  s2m_axi4l_s_if : t_axi4l_s2m := C_AXI4L_S2M_DEFAULT;
  --II Subordinate IF from spi
   signal  ii_in        : t_ibus_i := C_IBUS_I_DEFAULT;
   signal  ii_out       : t_ibus_o := C_IBUS_O_DEFAULT;

begin

  -----------------------------------------------------------------------------
  -- Instantiate the concurrent procedure that initializes UVVM
  -----------------------------------------------------------------------------
  i_ti_uvvm_engine : entity uvvm_vvc_framework.ti_uvvm_engine;

  --Clock Generation
  vvc_clk_gen : entity bitvis_vip_clock_generator.clock_generator_vvc 
  generic map(
    GC_INSTANCE_IDX    => 1,
    GC_CLOCK_NAME      => "Clock",
    GC_CLOCK_PERIOD    => C_CLK_PERIOD,
    GC_CLOCK_HIGH_TIME => C_CLK_PERIOD / 2
  )
  port map(
    clk   => clock
  );

  --Clock Generation
  vvc_clk_gen_ii : entity bitvis_vip_clock_generator.clock_generator_vvc 
  generic map(
    GC_INSTANCE_IDX    => 2,
    GC_CLOCK_NAME      => "II_Clock",
    GC_CLOCK_PERIOD    => C_CLK_PERIOD_II,
    GC_CLOCK_HIGH_TIME => C_CLK_PERIOD / 2
  )
  port map(
    clk   => ii_in.clk
  );
  
  p_arst : reset <= '1', '0' after 5 * C_CLK_PERIOD;

  vvc_axi4l_m : entity bitvis_vip_axilite.axilite_vvc
  generic map(
    GC_ADDR_WIDTH                            => C_AXI4L_ADDR_WIDTH,
    GC_DATA_WIDTH                            => C_AXI4L_DATA_WIDTH,
    GC_INSTANCE_IDX                          => 1
  )
  port map(
    clk                   => clock,
    axilite_vvc_master_if.write_address_channel.awaddr  => m2s_axi4l_s_if.awaddr,
    axilite_vvc_master_if.write_address_channel.awvalid => m2s_axi4l_s_if.awvalid,
    axilite_vvc_master_if.write_address_channel.awprot  => m2s_axi4l_s_if.awprot,
    axilite_vvc_master_if.write_data_channel.wdata      => m2s_axi4l_s_if.wdata,
    axilite_vvc_master_if.write_data_channel.wstrb      => m2s_axi4l_s_if.wstrb,
    axilite_vvc_master_if.write_data_channel.wvalid     => m2s_axi4l_s_if.wvalid,
    axilite_vvc_master_if.write_response_channel.bready => m2s_axi4l_s_if.bready,
    axilite_vvc_master_if.read_address_channel.araddr   => m2s_axi4l_s_if.araddr,
    axilite_vvc_master_if.read_address_channel.arvalid  => m2s_axi4l_s_if.arvalid,
    axilite_vvc_master_if.read_address_channel.arprot   => m2s_axi4l_s_if.arprot,
    axilite_vvc_master_if.read_data_channel.rready      => m2s_axi4l_s_if.rready,
    --DUV spi_m axi4l subordinate output
    axilite_vvc_master_if.write_address_channel.awready => s2m_axi4l_s_if.awready,
    axilite_vvc_master_if.write_data_channel.wready     => s2m_axi4l_s_if.wready,
    axilite_vvc_master_if.write_response_channel.bresp  => s2m_axi4l_s_if.bresp,
    axilite_vvc_master_if.write_response_channel.bvalid => s2m_axi4l_s_if.bvalid,
    axilite_vvc_master_if.read_address_channel.arready  => s2m_axi4l_s_if.arready,
    axilite_vvc_master_if.read_data_channel.rdata       => s2m_axi4l_s_if.rdata,
    axilite_vvc_master_if.read_data_channel.rresp       => s2m_axi4l_s_if.rresp,
    axilite_vvc_master_if.read_data_channel.rvalid      => s2m_axi4l_s_if.rvalid
  );
  
  duv_spi_axi4l_m: entity desy.axi4l_ov_spi_4w_m
  generic map(
    G_TIMEOUT   => G_TIMEOUT,
    G_CPOL        => G_CPOL,
    G_AXI4L_ADDR_WIDTH => C_AXI4L_ADDR_WIDTH,
    G_AXI4L_DATA_WIDTH => C_AXI4L_DATA_WIDTH
  )
  port map(
    pi_clock    => clock,
    pi_reset    => reset,
    -- AXI4 Subordinate Interface
    pi_s_axi4l  =>  m2s_axi4l_s_if,
    po_s_axi4l  =>  s2m_axi4l_s_if,
    -- SPI Manager Interface
    po_m_sclk   => spi_m2s_sclk,-- serial clock out
    po_m_cs_n   => spi_m2s_sc_n,-- chip select low activ
    po_m_mosi   => spi_m2s_miso,-- serial data output
    pi_m_miso   => spi_m2s_mosi-- serial data input
  ); 

  duv_spi_ii_s: entity desy.ii_ov_spi_s
  generic map(
    G_TIMEOUT   => G_TIMEOUT
  )
  port map(
    pi_reset    => reset,
    -- Manager internal interface bus
    po_ibus     => ii_out,
    pi_ibus     => ii_in,
    -- SPI manager interface
    po_s_miso   => spi_m2s_mosi,
    pi_s_mosi   => spi_m2s_miso,
    pi_s_sclk   => spi_m2s_sclk,-- serial clock in
    pi_s_cs_n   => spi_m2s_sc_n
  );

  p_data: ii_in.data <= ii_out.data when ii_in.wack = '1';
  ii_in.wack <= ii_out.wena;
  ii_in.rack <= ii_out.rena;

end architecture sim;