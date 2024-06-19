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
--! @date 2021-12-21
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! SIS8300KU payload Interface Definitions
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_types.all;
use desy.common_axi.all;
use desy.common_bsp_ifs.all;
use desy.common_bsp_ifs_cfg.all;

use work.pkg_bsp_config.all;

package pkg_sis8300ku_payload is

  -------------------------------------------
  -- Input signals towards Application
  type t_payload_i is record

    -- Main reset for the logic
    app_domain_reset : std_logic_vector(7 downto 0);
    app_domain_clock : std_logic_vector(7 downto 0);

    bsp_domain_reset : std_logic_vector(7 downto 0);
    bsp_domain_clock : std_logic_vector(7 downto 0);

    -- Register Interface (DesyRDL)
    m_axi4l_reg_aclk      : std_logic;
    m_axi4l_reg_areset_n  : std_logic; -- Synced to s_axi4l_reg_aclk 
    m_axi4l_reg           : t_axi4l_reg_m2s;

    -- DAQ Interface
    s_axi4_daq_aclk     : std_logic;
    s_axi4_daq_areset_n : std_logic;
    s_axi4_daq          : t_axi4_s2m;

    adc    : t_16b_slv_vector(9 downto 0);
    adc_ov : std_logic_vector(9 downto 0);

    -- Front Panel RJ45 Input
    fp_data_in : std_logic_vector(2 downto 0);
    
    -- MLVDS from MTCA Backplane
    mlvds    : std_logic_vector(7 downto 0);

  end record t_payload_i;

  -- Output signals from Application
  type t_payload_o is record

    -- Register Interface (DesyRDL)
    -- s_axi4l_reg_aclk     : std_logic; -- Subordinates do not send clock and reset back
    -- s_axi4l_reg_areset_n : std_logic;
    m_axi4l_reg          : t_axi4l_reg_s2m;

    -- DAQ
    s_axi4_daq          : t_axi4_m2s;

    pcie_irq_req  : std_logic_vector(C_PCIE_IRQ_CNT-1 downto 0);

    dac_data_i   : std_logic_vector(15 downto 0);
    dac_data_q   : std_logic_vector(15 downto 0);
    dac_data_rdy : std_logic;

    -- Front Panel RJ45 Output
    fp_data_out : std_logic_vector(2 downto 0);
    
    mlvds    : std_logic_vector(7 downto 0);
    mlvds_oe : std_logic_vector(7 downto 0);
    interlock : std_logic_vector(1 downto 0);
    interlock_ena_n : std_logic;

  end record t_payload_o;

  type t_payload_io is record
    rtm_io_p : std_logic_vector(11 downto 0);
    rtm_io_n : std_logic_vector(11 downto 0);
  end record t_payload_io;

  -- ==========================================================================
  -- payload component
  -- ==========================================================================  
  component sis8300ku_payload is
    port (
      pi_bsp2app  : in    t_payload_i;
      po_app2bsp  : out   t_payload_o;
      pi_top2app  : inout t_payload_io
    );
  end component sis8300ku_payload;


end pkg_sis8300ku_payload;
