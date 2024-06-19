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
--! @date 2021-09-16
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! SIS8300KU payload for example application
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desyrdl;
use desyrdl.pkg_app.all;

library desy;
use desy.common_to_desyrdl.all;
use desy.common_bsp_ifs.all;

use work.pkg_sis8300ku_payload.all; -- Interfaces are defined in BSP part
use work.pkg_bsp_config.all;

entity sis8300ku_payload is
  port (
    pi_payload  : in    t_payload_i;
    po_payload  : out   t_payload_o;
    pio_payload : inout t_payload_io
  );
end entity sis8300ku_payload;

architecture rtl of sis8300ku_payload is

  signal interlock : std_logic;
  
  signal axi4l_reg_m2s : t_app_m2s;
  signal axi4l_reg_s2m : t_app_s2m;

begin

  -- Negating the Interlock lanes in-case interlock circuit has NOR-gate.
  po_payload.interlock(0) <= interlock when C_RTM_INTERLOCK_NEGATE = 0  else not interlock;
  po_payload.interlock(1) <= interlock when C_RTM_INTERLOCK_NEGATE = 0  else not interlock;

  po_payload.interlock_ena_n <= '0'; -- Enable the interlock circuitry
  
  axi4l_reg_m2s <= f_common_to_desyrdl(pi_payload.m_axi4l_reg);
  po_payload.m_axi4l_reg <= f_common_to_desyrdl(axi4l_reg_s2m);

  -------------------------------------------------------------------------------
  -- main application module
  -------------------------------------------------------------------------------
  ins_app_top: entity work.app_top
    port map (
      pi_clock => pi_payload.app_domain_clock, -- Clocks that are synced to Application Clock Domain
      pi_reset => pi_payload.app_domain_reset, -- Resets that are synced to Application Clock Domain

      pi_bsp_clock => pi_payload.bsp_domain_clock, -- Clocks that are synced to BSP Clock Domain
      pi_bsp_reset => pi_payload.bsp_domain_reset, -- Resets that are synced to BSP Clock Domain
      
        -- ADC signals
      pi_adc    => pi_payload.adc,    -- ! adc application interface port
      pi_adc_ov => pi_payload.adc_ov, -- ! adc overvoltage
      
      po_dac_data_i => po_payload.dac_data_i,
      po_dac_data_q => po_payload.dac_data_q,
      po_dac_data_rdy => po_payload.dac_data_rdy,

      pi_mlvds    => pi_payload.mlvds,
      po_mlvds    => po_payload.mlvds,
      po_mlvds_oe => po_payload.mlvds_oe,

      -- Zone3 Connections
      pio_top_io_p(9 downto 0) => pio_payload.rtm_io_p(9 downto 0),
      pio_top_io_p(10)         => interlock, -- Single out the interlock lane for possible inversion
      pio_top_io_p(11)         => pio_payload.rtm_io_p(11),
      pio_top_io_n             => pio_payload.rtm_io_n,

      -- Interrupts
      po_irq_req               => po_payload.pcie_irq_req, -- Sync to App Clock Domain

      -- RJ45 on FP
      pi_rj45 => pi_payload.fp_data_in,
      po_rj45 => po_payload.fp_data_out,

      -- AXI4.Lite Registers/Memory (DesyRdl)
      pi_s_axi4l_reg          => axi4l_reg_m2s,
      po_s_axi4l_reg          => axi4l_reg_s2m,
      pi_s_axi4l_reg_aclk     => pi_payload.m_axi4l_reg_aclk,
      pi_s_axi4l_reg_areset_n => pi_payload.m_axi4l_reg_areset_n,
      
      -- AXI4 DAQ 
      pi_m_axi4_daq_aclk      => pi_payload.s_axi4_daq_aclk,
      pi_m_axi4_daq_areset_n  => pi_payload.s_axi4_daq_areset_n,
      po_m_axi4_daq           => po_payload.s_axi4_daq,
      pi_m_axi4_daq           => pi_payload.s_axi4_daq
    );

end architecture rtl;
