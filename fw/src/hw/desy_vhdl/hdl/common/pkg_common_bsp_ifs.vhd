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
--! @author
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--! Cagil Gumus <cagil.guemues@desy.de>
--! Burak Dursun <burak.dursun@desy.de>
------------------------------------------------------------------------------
--! @brief
--! package with common BSP interfaces
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_bsp_ifs_cfg.all;
use work.common_axi.all;

package common_bsp_ifs is

  --============================================================================
  -- DAQ AXI4 Full interface
  --============================================================================
  type t_axi4_daq_m2s is record
    -- write address channel signals---------------------------------------------
    awid        : std_logic_vector(C_AXI4_DAQ_ID_WIDTH-1 downto 0);
    awaddr      : std_logic_vector(C_AXI4_DAQ_ADDR_WIDTH-1 downto 0);
    awlock      : std_logic;
    awlen       : std_logic_vector(7 downto 0);
    awsize      : std_logic_vector(2 downto 0);
    awburst     : std_logic_vector(1 downto 0);
    awcache     : std_logic_vector(3 downto 0);
    awprot      : std_logic_vector(2 downto 0);
    awqos       : std_logic_vector(3 downto 0);
    awregion    : std_logic_vector(3 downto 0);
    awuser      : std_logic_vector(C_AXI4_DAQ_AWUSER_WIDTH-1 downto 0);
    awvalid     : std_logic;
    -- write data channel signals------------------------------------------------
    wdata       : std_logic_vector(C_AXI4_DAQ_DATA_WIDTH-1 downto 0);
    wstrb       : std_logic_vector(C_AXI4_DAQ_DATA_WIDTH/8-1 downto 0);
    wlast       : std_logic;
    wuser       : std_logic_vector(C_AXI4_DAQ_WUSER_WIDTH-1 downto 0);
    wvalid      : std_logic;
    -- write response channel signals
    bready      : std_logic;
    -- read address channel signals ---------------------------------------------
    arid        : std_logic_vector(C_AXI4_DAQ_ID_WIDTH-1 downto 0);
    araddr      : std_logic_vector(C_AXI4_DAQ_ADDR_WIDTH-1 downto 0);
    arlen       : std_logic_vector(7 downto 0);
    arsize      : std_logic_vector(2 downto 0);
    arburst     : std_logic_vector(1 downto 0);
    arlock      : std_logic;
    arcache     : std_logic_vector(3 downto 0);
    arprot      : std_logic_vector(2 downto 0);
    arqos       : std_logic_vector(3 downto 0);
    arregion    : std_logic_vector(3 downto 0);
    aruser      : std_logic_vector(C_AXI4_DAQ_ARUSER_WIDTH-1 downto 0);
    arvalid     : std_logic;
    -- read data channel signals-------------------------------------------------
    rready      : std_logic;
  end record t_axi4_daq_m2s;

  type t_axi4_daq_s2m is record
    -- write address channel signals---------------------------------------------
    awready     : std_logic;
    -- write data channel signals------------------------------------------------
    wready      : std_logic;
    -- write response channel signals -------------------------------------------
    bid         : std_logic_vector(C_AXI4_DAQ_ID_WIDTH-1 downto 0);
    bresp       : std_logic_vector(1 downto 0);
    buser       : std_logic_vector(C_AXI4_DAQ_BUSER_WIDTH-1 downto 0);
    bvalid      : std_logic;
    -- read address channel signals---------------------------------------------
    arready     : std_logic;
    -- read data channel signals---------------------------------------------
    rid         : std_logic_vector(C_AXI4_DAQ_ID_WIDTH-1 downto 0);
    rdata       : std_logic_vector(C_AXI4_DAQ_DATA_WIDTH-1 downto 0);
    rresp       : std_logic_vector(1 downto 0);
    rlast       : std_logic;
    ruser       : std_logic_vector(C_AXI4_DAQ_RUSER_WIDTH-1 downto 0);
    rvalid      : std_logic;
  end record t_axi4_daq_s2m;


  --============================================================================
  -- AXI4 Full interface for registers (reg)
  --============================================================================
  type t_axi4_reg_m2s is record
    -- write address channel signals---------------------------------------------
    awid        : std_logic_vector(C_AXI4_REG_ID_WIDTH-1 downto 0);
    awaddr      : std_logic_vector(C_AXI4_REG_ADDR_WIDTH-1 downto 0);
    awlock      : std_logic;
    awlen       : std_logic_vector(7 downto 0);
    awsize      : std_logic_vector(2 downto 0);
    awburst     : std_logic_vector(1 downto 0);
    awcache     : std_logic_vector(3 downto 0);
    awprot      : std_logic_vector(2 downto 0);
    awqos       : std_logic_vector(3 downto 0);
    awregion    : std_logic_vector(3 downto 0);
    awuser      : std_logic_vector(C_AXI4_REG_AWUSER_WIDTH-1 downto 0);
    awvalid     : std_logic;
    -- write data channel signals---------------------------------------------
    wdata       : std_logic_vector(C_AXI4_REG_DATA_WIDTH-1 downto 0);
    wstrb       : std_logic_vector(C_AXI4_REG_DATA_WIDTH/8-1 downto 0);
    wlast       : std_logic;
    wuser       : std_logic_vector(C_AXI4_REG_WUSER_WIDTH-1 downto 0);
    wvalid      : std_logic;
    -- write response channel signals
    bready      : std_logic;
    -- read address channel signals -------------------------------------------
    arid        : std_logic_vector(C_AXI4_REG_ID_WIDTH-1 downto 0);
    araddr      : std_logic_vector(C_AXI4_REG_ADDR_WIDTH-1 downto 0);
    arlen       : std_logic_vector(7 downto 0);
    arsize      : std_logic_vector(2 downto 0);
    arburst     : std_logic_vector(1 downto 0);
    arlock      : std_logic;
    arcache     : std_logic_vector(3 downto 0);
    arprot      : std_logic_vector(2 downto 0);
    arqos       : std_logic_vector(3 downto 0);
    arregion    : std_logic_vector(3 downto 0);
    aruser      : std_logic_vector(C_AXI4_REG_ARUSER_WIDTH-1 downto 0);
    arvalid     : std_logic;
    -- read data channel signals-------------------------------------------------
    rready      : std_logic;
  end record t_axi4_reg_m2s;

  type t_axi4_reg_s2m is record
    -- write address channel signals---------------------------------------------
    awready     : std_logic;
    -- write data channel signals------------------------------------------------
    wready      : std_logic;
    -- write response channel signals -------------------------------------------
    bid         : std_logic_vector(C_AXI4_REG_ID_WIDTH-1 downto 0);
    bresp       : std_logic_vector(1 downto 0);
    buser       : std_logic_vector(C_AXI4_REG_BUSER_WIDTH-1 downto 0);
    bvalid      : std_logic;
    -- read address channel signals----------------------------------------------
    arready     : std_logic;
    -- read data channel signals-------------------------------------------------
    rid         : std_logic_vector(C_AXI4_REG_ID_WIDTH-1 downto 0);
    rdata       : std_logic_vector(C_AXI4_REG_DATA_WIDTH-1 downto 0);
    rresp       : std_logic_vector(1 downto 0);
    rlast       : std_logic;
    ruser       : std_logic_vector(C_AXI4_REG_RUSER_WIDTH-1 downto 0);
    rvalid      : std_logic;
  end record t_axi4_reg_s2m;


  --============================================================================
  -- AXI4-Lite Interface
  --============================================================================
  type t_axi4l_reg_m2s is record
    -- write address channel signals--------------------------------------------
    awaddr      : std_logic_vector(C_AXI4L_REG_ADDR_WIDTH-1 downto 0);
    awprot      : std_logic_vector(2 downto 0);
    awvalid     : std_logic;
    -- write data channel signals-----------------------------------------------
    wdata       : std_logic_vector(C_AXI4L_REG_DATA_WIDTH-1 downto 0);
    wstrb       : std_logic_vector(C_AXI4L_REG_DATA_WIDTH/8-1 downto 0);
    wvalid      : std_logic;
    -- write response channel signals
    bready      : std_logic;
    -- read address channel signals --------------------------------------------
    araddr      : std_logic_vector(C_AXI4L_REG_ADDR_WIDTH-1 downto 0);
    arprot      : std_logic_vector(2 downto 0);
    arvalid     : std_logic;
    -- read data channel signals------------------------------------------------
    rready      : std_logic;
  end record t_axi4l_reg_m2s;

  type t_axi4l_reg_s2m is record
    -- write address channel signals--------------------------------------------
    awready     : std_logic;
    -- write data channel signals-----------------------------------------------
    wready      : std_logic;
    -- write response channel signals ------------------------------------------
    bresp       : std_logic_vector(1 downto 0);
    bvalid      : std_logic;
    -- read address channel signals---------------------------------------------
    arready     : std_logic;
    -- read data channel signals------------------------------------------------
    rdata       : std_logic_vector(C_AXI4L_REG_DATA_WIDTH-1 downto 0);
    rresp       : std_logic_vector(1 downto 0);
    rvalid      : std_logic;
  end record t_axi4l_reg_s2m;


  --============================================================================
  -- AXI4-Stream Interface for Port-to-Port (P2P) Links
  --============================================================================
  type t_axi4s_p2p_m2s is record
    tdata   : std_logic_vector(C_AXI4S_P2P_DATA_WIDTH-1 downto 0);
    tstrb   : std_logic_vector(C_AXI4S_P2P_DATA_WIDTH/8-1 downto 0);
    tkeep   : std_logic_vector(C_AXI4S_P2P_DATA_WIDTH/8-1 downto 0);
    tlast   : std_logic;
    tid     : std_logic_vector(C_AXI4S_P2P_ID_WIDTH-1 downto 0);
    tdest   : std_logic_vector(C_AXI4S_P2P_DEST_WIDTH-1 downto 0);
    tuser   : std_logic_vector(C_AXI4S_P2P_USER_WIDTH-1 downto 0);
    tvalid  : std_logic;
  end record t_axi4s_p2p_m2s;

  type t_axi4s_p2p_s2m is record
    tready  : std_logic;
  end record t_axi4s_p2p_s2m;


  --============================================================================
  -- PS HP AXI4 memory mapped interface
  --============================================================================
  type t_axi4_pshp_m2s is record
    -- write address channel signals--------------------------------------------
    awid        : std_logic_vector(C_AXI4_PSHP_ID_WIDTH-1 downto 0);
    awaddr      : std_logic_vector(C_AXI4_PSHP_ADDR_WIDTH-1 downto 0);
    awlock      : std_logic;
    awlen       : std_logic_vector(7 downto 0);
    awsize      : std_logic_vector(2 downto 0);
    awburst     : std_logic_vector(1 downto 0);
    awcache     : std_logic_vector(3 downto 0);
    awprot      : std_logic_vector(2 downto 0);
    awqos       : std_logic_vector(3 downto 0);
    awregion    : std_logic_vector(3 downto 0);
    awuser      : std_logic_vector(C_AXI4_PSHP_AWUSER_WIDTH-1 downto 0);
    awvalid     : std_logic;
    -- write data channel signals------------------------------------------------
    wdata       : std_logic_vector(C_AXI4_PSHP_DATA_WIDTH-1 downto 0);
    wstrb       : std_logic_vector(C_AXI4_PSHP_DATA_WIDTH/8-1 downto 0);
    wlast       : std_logic;
    wuser       : std_logic_vector(C_AXI4_PSHP_WUSER_WIDTH-1 downto 0);
    wvalid      : std_logic;
    -- write response channel signals
    bready      : std_logic;
    -- read address channel signals ---------------------------------------------
    arid        : std_logic_vector(C_AXI4_PSHP_ID_WIDTH-1 downto 0);
    araddr      : std_logic_vector(C_AXI4_PSHP_ADDR_WIDTH-1 downto 0);
    arlen       : std_logic_vector(7 downto 0);
    arsize      : std_logic_vector(2 downto 0);
    arburst     : std_logic_vector(1 downto 0);
    arlock      : std_logic;
    arcache     : std_logic_vector(3 downto 0);
    arprot      : std_logic_vector(2 downto 0);
    arqos       : std_logic_vector(3 downto 0);
    arregion    : std_logic_vector(3 downto 0);
    aruser      : std_logic_vector(C_AXI4_PSHP_ARUSER_WIDTH-1 downto 0);
    arvalid     : std_logic;
    -- read data channel signals-------------------------------------------------
    rready      : std_logic;
  end record t_axi4_pshp_m2s;

  type t_axi4_pshp_s2m is record
    -- write address channel signals---------------------------------------------
    awready     : std_logic;
    -- write data channel signals------------------------------------------------
    wready      : std_logic;
    -- write response channel signals -------------------------------------------
    bid         : std_logic_vector(C_AXI4_PSHP_ID_WIDTH-1 downto 0);
    bresp       : std_logic_vector(1 downto 0);
    buser       : std_logic_vector(C_AXI4_PSHP_BUSER_WIDTH-1 downto 0);
    bvalid      : std_logic;
    -- read address channel signals---------------------------------------------
    arready     : std_logic;
    -- read data channel signals------------------------------------------------
    rid         : std_logic_vector(C_AXI4_PSHP_ID_WIDTH-1 downto 0);
    rdata       : std_logic_vector(C_AXI4_PSHP_DATA_WIDTH-1 downto 0);
    rresp       : std_logic_vector(1 downto 0);
    rlast       : std_logic;
    ruser       : std_logic_vector(C_AXI4_PSHP_RUSER_WIDTH-1 downto 0);
    rvalid      : std_logic;
  end record t_axi4_pshp_s2m;


  --============================================================================
  -- PS HPM AXI4 memory mapped interface
  --============================================================================
  type t_axi4_pshpm_m2s is record
    -- write address channel signals--------------------------------------------
    awid        : std_logic_vector(C_AXI4_PSHPM_ID_WIDTH-1 downto 0);
    awaddr      : std_logic_vector(C_AXI4_PSHPM_ADDR_WIDTH-1 downto 0);
    awlock      : std_logic;
    awlen       : std_logic_vector(7 downto 0);
    awsize      : std_logic_vector(2 downto 0);
    awburst     : std_logic_vector(1 downto 0);
    awcache     : std_logic_vector(3 downto 0);
    awprot      : std_logic_vector(2 downto 0);
    awqos       : std_logic_vector(3 downto 0);
    awregion    : std_logic_vector(3 downto 0);
    awuser      : std_logic_vector(C_AXI4_PSHPM_AWUSER_WIDTH-1 downto 0);
    awvalid     : std_logic;
    -- write data channel signals------------------------------------------------
    wdata       : std_logic_vector(C_AXI4_PSHPM_DATA_WIDTH-1 downto 0);
    wstrb       : std_logic_vector(C_AXI4_PSHPM_DATA_WIDTH/8-1 downto 0);
    wlast       : std_logic;
    wuser       : std_logic_vector(C_AXI4_PSHPM_WUSER_WIDTH-1 downto 0);
    wvalid      : std_logic;
    -- write response channel signals
    bready      : std_logic;
    -- read address channel signals ---------------------------------------------
    arid        : std_logic_vector(C_AXI4_PSHPM_ID_WIDTH-1 downto 0);
    araddr      : std_logic_vector(C_AXI4_PSHPM_ADDR_WIDTH-1 downto 0);
    arlen       : std_logic_vector(7 downto 0);
    arsize      : std_logic_vector(2 downto 0);
    arburst     : std_logic_vector(1 downto 0);
    arlock      : std_logic;
    arcache     : std_logic_vector(3 downto 0);
    arprot      : std_logic_vector(2 downto 0);
    arqos       : std_logic_vector(3 downto 0);
    arregion    : std_logic_vector(3 downto 0);
    aruser      : std_logic_vector(C_AXI4_PSHPM_ARUSER_WIDTH-1 downto 0);
    arvalid     : std_logic;
    -- read data channel signals-------------------------------------------------
    rready      : std_logic;
  end record t_axi4_pshpm_m2s;

  type t_axi4_pshpm_s2m is record
    -- write address channel signals---------------------------------------------
    awready     : std_logic;
    -- write data channel signals------------------------------------------------
    wready      : std_logic;
    -- write response channel signals -------------------------------------------
    bid         : std_logic_vector(C_AXI4_PSHPM_ID_WIDTH-1 downto 0);
    bresp       : std_logic_vector(1 downto 0);
    buser       : std_logic_vector(C_AXI4_PSHPM_BUSER_WIDTH-1 downto 0);
    bvalid      : std_logic;
    -- read address channel signals---------------------------------------------
    arready     : std_logic;
    -- read data channel signals------------------------------------------------
    rid         : std_logic_vector(C_AXI4_PSHPM_ID_WIDTH-1 downto 0);
    rdata       : std_logic_vector(C_AXI4_PSHPM_DATA_WIDTH-1 downto 0);
    rresp       : std_logic_vector(1 downto 0);
    rlast       : std_logic;
    ruser       : std_logic_vector(C_AXI4_PSHPM_RUSER_WIDTH-1 downto 0);
    rvalid      : std_logic;
  end record t_axi4_pshpm_s2m;


  --============================================================================
  -- Chip2Chip AXI4 Full interface
  --============================================================================
  type t_axi4_c2c_m2s is record
    -- write address channel signals -------------------------------------------
    awid        : std_logic_vector(C_AXI4_C2C_ID_WIDTH-1 downto 0);
    awaddr      : std_logic_vector(C_AXI4_C2C_ADDR_WIDTH-1 downto 0);
    awlock      : std_logic;
    awlen       : std_logic_vector(7 downto 0);
    awsize      : std_logic_vector(2 downto 0);
    awburst     : std_logic_vector(1 downto 0);
    awcache     : std_logic_vector(3 downto 0);
    awprot      : std_logic_vector(2 downto 0);
    awqos       : std_logic_vector(3 downto 0);
    awregion    : std_logic_vector(3 downto 0);
    awuser      : std_logic_vector(C_AXI4_C2C_AWUSER_WIDTH-1 downto 0);
    awvalid     : std_logic;
    -- write data channel signals ----------------------------------------------
    wdata       : std_logic_vector(C_AXI4_C2C_DATA_WIDTH-1 downto 0);
    wstrb       : std_logic_vector(C_AXI4_C2C_DATA_WIDTH/8-1 downto 0);
    wlast       : std_logic;
    wuser       : std_logic_vector(C_AXI4_C2C_WUSER_WIDTH-1 downto 0);
    wvalid      : std_logic;
    -- write response channel signals ------------------------------------------
    bready      : std_logic;
    -- read address channel signals --------------------------------------------
    arid        : std_logic_vector(C_AXI4_C2C_ID_WIDTH-1 downto 0);
    araddr      : std_logic_vector(C_AXI4_C2C_ADDR_WIDTH-1 downto 0);
    arlen       : std_logic_vector(7 downto 0);
    arsize      : std_logic_vector(2 downto 0);
    arburst     : std_logic_vector(1 downto 0);
    arlock      : std_logic;
    arcache     : std_logic_vector(3 downto 0);
    arprot      : std_logic_vector(2 downto 0);
    arqos       : std_logic_vector(3 downto 0);
    arregion    : std_logic_vector(3 downto 0);
    aruser      : std_logic_vector(C_AXI4_C2C_ARUSER_WIDTH-1 downto 0);
    arvalid     : std_logic;
    -- read data channel signals -----------------------------------------------
    rready      : std_logic;
  end record t_axi4_c2c_m2s;

  type t_axi4_c2c_s2m is record
    -- write address channel signals -------------------------------------------
    awready     : std_logic;
    -- write data channel signals ----------------------------------------------
    wready      : std_logic;
    -- write response channel signals ------------------------------------------
    bid         : std_logic_vector(C_AXI4_C2C_ID_WIDTH-1 downto 0);
    bresp       : std_logic_vector(1 downto 0);
    buser       : std_logic_vector(C_AXI4_C2C_BUSER_WIDTH-1 downto 0);
    bvalid      : std_logic;
    -- read address channel signals --------------------------------------------
    arready     : std_logic;
    -- read data channel signals -----------------------------------------------
    rid         : std_logic_vector(C_AXI4_C2C_ID_WIDTH-1 downto 0);
    rdata       : std_logic_vector(C_AXI4_C2C_DATA_WIDTH-1 downto 0);
    rresp       : std_logic_vector(1 downto 0);
    rlast       : std_logic;
    ruser       : std_logic_vector(C_AXI4_C2C_RUSER_WIDTH-1 downto 0);
    rvalid      : std_logic;
  end record t_axi4_c2c_s2m;


  --============================================================================
  -- AXI4 arrays
  --============================================================================
  type t_axi4_reg_m2s_vector    is array (natural range <>) of t_axi4_reg_m2s;
  type t_axi4_reg_s2m_vector    is array (natural range <>) of t_axi4_reg_s2m;
  type t_axi4l_reg_m2s_vector   is array (natural range <>) of t_axi4l_reg_m2s;
  type t_axi4l_reg_s2m_vector   is array (natural range <>) of t_axi4l_reg_s2m;
  type t_axi4_daq_m2s_vector    is array (natural range <>) of t_axi4_daq_m2s;
  type t_axi4_daq_s2m_vector    is array (natural range <>) of t_axi4_daq_s2m;
  type t_axi4_pshp_m2s_vector   is array (natural range <>) of t_axi4_pshp_m2s;
  type t_axi4_pshp_s2m_vector   is array (natural range <>) of t_axi4_pshp_s2m;
  type t_axi4_pshpm_m2s_vector  is array (natural range <>) of t_axi4_pshpm_m2s;
  type t_axi4_pshpm_s2m_vector  is array (natural range <>) of t_axi4_pshpm_s2m;
  type t_axi4s_p2p_m2s_vector   is array (natural range <>) of t_axi4s_p2p_m2s;
  type t_axi4s_p2p_s2m_vector   is array (natural range <>) of t_axi4s_p2p_s2m;
  type t_axi4_c2c_m2s_vector    is array (natural range <>) of t_axi4_c2c_m2s;
  type t_axi4_c2c_s2m_vector    is array (natural range <>) of t_axi4_c2c_s2m;
  
  -- default state
  constant C_AXI4_REG_S2M_DEFAULT : t_axi4_reg_s2m := (
    awready     => '0' ,
    wready      => '0' ,
    bid         => (others => '0') ,
    bresp       => (others => '0') ,
    buser       => (others => '0') ,
    bvalid      => '0' ,
    arready     => '0' ,
    rid         => (others => '0') ,
    rdata       => (others => '0') ,
    rresp       => (others => '0'),
    rlast       => '0',
    ruser       => (others => '0'),
    rvalid      => '0'
  );
  constant C_AXI4_REG_M2S_DEFAULT : t_axi4_reg_m2s := (
    awid          => (others => '0'),
    awaddr        => (others => '0'),
    awlock        => '0',
    awlen         => (others => '0'),
    awsize        => (others => '0'),
    awburst       => C_AXI4_BURST_INCR,
    awcache       => (others => '0'),
    awprot        => (others => '0'),
    awqos         => (others => '0'),
    awregion      => (others => '0'),
    awuser        => (others => '0'),
    awvalid       => '0',
    wdata         => (others => '0'),
    wstrb         => (others => '0'),
    wlast         => '0',
    wuser         => (others => '0'),
    wvalid        => '0',
    bready        => '0',
    arid          => (others => '0'),
    araddr        => (others => '0'),
    arlen         => (others => '0'),
    arsize        => (others => '0'),
    arburst       => (others => '0'),
    arlock        => '0',
    arcache       => (others => '0'),
    arprot        => (others => '0'),
    arqos         => (others => '0'),
    arregion      => (others => '0'),
    aruser        => (others => '0'),
    arvalid       => '0',
    rready        => '0'
  );

  constant C_AXI4L_REG_S2M_DEFAULT : t_axi4l_reg_s2m := (
    awready     => '0',
    wready      => '0',
    bresp       => (others => '0'),
    bvalid      => '0',
    arready     => '0' ,
    rdata       => (others => '0'),
    rresp       => (others => '0'),
    rvalid      => '0'
  );

  constant C_AXI4L_REG_M2S_DEFAULT : t_axi4l_reg_m2s := (
    awaddr        => (others => '0'),
    awprot        => (others => '0'),
    awvalid       => '0',
    wdata         => (others => '0'),
    wstrb         => (others => '0'),
    wvalid        => '0',
    bready        => '0',
    araddr        => (others => '0'),
    arprot        => (others => '0'),
    arvalid       => '0',
    rready        => '0'
  );

  constant C_AXI4_DAQ_S2M_DEFAULT : t_axi4_daq_s2m := (
    awready     => '0' ,
    wready      => '0' ,
    bid         => (others => '0') ,
    bresp       => (others => '0') ,
    buser       => (others => '0') ,
    bvalid      => '0' ,
    arready     => '0' ,
    rid         => (others => '0') ,
    rdata       => (others => '0') ,
    rresp       => (others => '0'),
    rlast       => '0',
    ruser       => (others => '0'),
    rvalid      => '0'
  );
  
  constant C_AXI4_DAQ_M2S_DEFAULT : t_axi4_daq_m2s := (
    awid          => (others => '0'),
    awaddr        => (others => '0'),
    awlock        => '0',
    awlen         => (others => '0'),
    awsize        => (others => '0'),
    awburst       => C_AXI4_BURST_INCR,
    awcache       => (others => '0'),
    awprot        => (others => '0'),
    awqos         => (others => '0'),
    awregion      => (others => '0'),
    awuser        => (others => '0'),
    awvalid       => '0',
    wdata         => (others => '0'),
    wstrb         => (others => '0'),
    wlast         => '0',
    wuser         => (others => '0'),
    wvalid        => '0',
    bready        => '0',
    arid          => (others => '0'),
    araddr        => (others => '0'),
    arlen         => (others => '0'),
    arsize        => (others => '0'),
    arburst       => (others => '0'),
    arlock        => '0',
    arcache       => (others => '0'),
    arprot        => (others => '0'),
    arqos         => (others => '0'),
    arregion      => (others => '0'),
    aruser        => (others => '0'),
    arvalid       => '0',
    rready        => '0'
  );
  
  constant C_AXI4_PSHP_S2M_DEFAULT : t_axi4_pshp_s2m := (
    awready     => '0' ,
    wready      => '0' ,
    bid         => (others => '0') ,
    bresp       => (others => '0') ,
    buser       => (others => '0') ,
    bvalid      => '0' ,
    arready     => '0' ,
    rid         => (others => '0') ,
    rdata       => (others => '0') ,
    rresp       => (others => '0'),
    rlast       => '0',
    ruser       => (others => '0'),
    rvalid      => '0'
  );
  
  constant C_AXI4_PSHP_M2S_DEFAULT : t_axi4_pshp_m2s := (
    awid          => (others => '0'),
    awaddr        => (others => '0'),
    awlock        => '0',
    awlen         => (others => '0'),
    awsize        => (others => '0'),
    awburst       => C_AXI4_BURST_INCR,
    awcache       => (others => '0'),
    awprot        => (others => '0'),
    awqos         => (others => '0'),
    awregion      => (others => '0'),
    awuser        => (others => '0'),
    awvalid       => '0',
    wdata         => (others => '0'),
    wstrb         => (others => '0'),
    wlast         => '0',
    wuser         => (others => '0'),
    wvalid        => '0',
    bready        => '0',
    arid          => (others => '0'),
    araddr        => (others => '0'),
    arlen         => (others => '0'),
    arsize        => (others => '0'),
    arburst       => (others => '0'),
    arlock        => '0',
    arcache       => (others => '0'),
    arprot        => (others => '0'),
    arqos         => (others => '0'),
    arregion      => (others => '0'),
    aruser        => (others => '0'),
    arvalid       => '0',
    rready        => '0'
  );

  constant C_AXI4_PSHPM_S2M_DEFAULT : t_axi4_pshpm_s2m := (
    awready     => '0' ,
    wready      => '0' ,
    bid         => (others => '0') ,
    bresp       => (others => '0') ,
    buser       => (others => '0') ,
    bvalid      => '0' ,
    arready     => '0' ,
    rid         => (others => '0') ,
    rdata       => (others => '0') ,
    rresp       => (others => '0'),
    rlast       => '0',
    ruser       => (others => '0'),
    rvalid      => '0'
  );
  
  constant C_AXI4_PSHPM_M2S_DEFAULT : t_axi4_pshpm_m2s := (
    awid          => (others => '0'),
    awaddr        => (others => '0'),
    awlock        => '0',
    awlen         => (others => '0'),
    awsize        => (others => '0'),
    awburst       => C_AXI4_BURST_INCR,
    awcache       => (others => '0'),
    awprot        => (others => '0'),
    awqos         => (others => '0'),
    awregion      => (others => '0'),
    awuser        => (others => '0'),
    awvalid       => '0',
    wdata         => (others => '0'),
    wstrb         => (others => '0'),
    wlast         => '0',
    wuser         => (others => '0'),
    wvalid        => '0',
    bready        => '0',
    arid          => (others => '0'),
    araddr        => (others => '0'),
    arlen         => (others => '0'),
    arsize        => (others => '0'),
    arburst       => (others => '0'),
    arlock        => '0',
    arcache       => (others => '0'),
    arprot        => (others => '0'),
    arqos         => (others => '0'),
    arregion      => (others => '0'),
    aruser        => (others => '0'),
    arvalid       => '0',
    rready        => '0'
  );

  constant C_AXI4S_P2P_M2S_DEFAULT : t_axi4s_p2p_m2s := (
    tdata  => (others => '0'),
    tstrb  => (others => '0'),
    tkeep  => (others => '0'),
    tlast  => '0',
    tid    => (others => '0'),
    tdest  => (others => '0'),
    tuser  => (others => '0'),
    tvalid => '0'
  );
  
  constant C_AXI4S_P2P_S2M_DEFAULT : t_axi4s_p2p_s2m := (
    tready  => '0'
  );
  
  
constant C_AXI4_C2C_S2M_DEFAULT : t_axi4_c2c_s2m := (
    awready     => '0' ,
    wready      => '0' ,
    bid         => (others => '0') ,
    bresp       => (others => '0') ,
    buser       => (others => '0') ,
    bvalid      => '0' ,
    arready     => '0' ,
    rid         => (others => '0') ,
    rdata       => (others => '0') ,
    rresp       => (others => '0'),
    rlast       => '0',
    ruser       => (others => '0'),
    rvalid      => '0'
  );
  
  constant C_AXI4_C2C_M2S_DEFAULT : t_axi4_c2c_m2s := (
    awid          => (others => '0'),
    awaddr        => (others => '0'),
    awlock        => '0',
    awlen         => (others => '0'),
    awsize        => (others => '0'),
    awburst       => C_AXI4_BURST_INCR,
    awcache       => (others => '0'),
    awprot        => (others => '0'),
    awqos         => (others => '0'),
    awregion      => (others => '0'),
    awuser        => (others => '0'),
    awvalid       => '0',
    wdata         => (others => '0'),
    wstrb         => (others => '0'),
    wlast         => '0',
    wuser         => (others => '0'),
    wvalid        => '0',
    bready        => '0',
    arid          => (others => '0'),
    araddr        => (others => '0'),
    arlen         => (others => '0'),
    arsize        => (others => '0'),
    arburst       => (others => '0'),
    arlock        => '0',
    arcache       => (others => '0'),
    arprot        => (others => '0'),
    arqos         => (others => '0'),
    arregion      => (others => '0'),
    aruser        => (others => '0'),
    arvalid       => '0',
    rready        => '0'
  );

  --============================================================================
  -- conversion function to common axi package
  --============================================================================
  -- reg axi4l
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4l_s2m
  )
  return t_axi4l_reg_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4l_m2s
  )
  return t_axi4l_reg_m2s;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4l_reg_s2m
  )
  return t_axi4l_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4l_reg_m2s
  )
  return t_axi4l_m2s;
  -- reg axi4
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_reg_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )
  return t_axi4_reg_m2s;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_reg_s2m
  )
  return t_axi4_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_reg_m2s
  )
  return t_axi4_m2s;
  -- c2c
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_c2c_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )
  return t_axi4_c2c_m2s;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_c2c_s2m
  )
  return t_axi4_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_c2c_m2s
  )
  return t_axi4_m2s;
  -- daq
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_daq_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )
  return t_axi4_daq_m2s;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_daq_s2m
  )
  return t_axi4_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_daq_m2s
  )
  return t_axi4_m2s;

  -- pshp
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_pshp_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )
  return t_axi4_pshp_m2s;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_pshp_s2m
  )
  return t_axi4_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_pshp_m2s
  )
  return t_axi4_m2s;

  -- pshpm
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_pshpm_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )
  return t_axi4_pshpm_m2s;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_pshpm_s2m
  )
  return t_axi4_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_pshpm_m2s
  )
  return t_axi4_m2s;

  -- psp stream
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4s_s2m
  )
  return t_axi4s_p2p_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4s_m2s
  )
  return t_axi4s_p2p_m2s;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4s_p2p_s2m
  )
  return t_axi4s_s2m;
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4s_p2p_m2s
  )
  return t_axi4s_m2s;

end package common_bsp_ifs;

--******************************************************************************
package body common_bsp_ifs is

  -- ==========================================================================
  -- conversion functions to common AXI
  -- Assumption that AXI vector width >= then BSP ones
  -- ==========================================================================

  ----------------------------------------------------------
  -- c2c ---------------------------------------------------
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_c2c_s2m is
    variable res : t_axi4_c2c_s2m;
  begin
    res.awready  := arg_axi4.awready;
    res.wready   := arg_axi4.wready;
    res.bid      := arg_axi4.bid(res.bid'range);
    res.bresp    := arg_axi4.bresp;
    res.buser    := arg_axi4.buser(res.buser'range);
    res.bvalid   := arg_axi4.bvalid;
    res.arready  := arg_axi4.arready;
    res.rid      := arg_axi4.rid(res.rid'range);
    res.rdata    := arg_axi4.rdata(res.rdata'range);
    res.rresp    := arg_axi4.rresp;
    res.rlast    := arg_axi4.rlast;
    res.ruser    := arg_axi4.ruser(res.ruser'range);
    res.rvalid   := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )  return t_axi4_c2c_m2s is
    variable res : t_axi4_c2c_m2s;
  begin
    res.awid      := arg_axi4.awid(res.awid'range);
    res.awaddr    := arg_axi4.awaddr(res.awaddr'range);
    res.awlock    := arg_axi4.awlock;
    res.awlen     := arg_axi4.awlen;
    res.awsize    := arg_axi4.awsize;
    res.awburst   := arg_axi4.awburst;
    res.awcache   := arg_axi4.awcache;
    res.awprot    := arg_axi4.awprot;
    res.awqos     := arg_axi4.awqos;
    res.awregion  := arg_axi4.awregion;
    res.awuser    := arg_axi4.awuser(res.awuser'range);
    res.awvalid   := arg_axi4.awvalid;
    res.wdata     := arg_axi4.wdata(res.wdata'range);
    res.wstrb     := arg_axi4.wstrb(res.wstrb'range);
    res.wlast     := arg_axi4.wlast;
    res.wuser     := arg_axi4.wuser(res.wuser'range);
    res.wvalid    := arg_axi4.wvalid;
    res.bready    := arg_axi4.bready;
    res.arid      := arg_axi4.arid(res.arid'range);
    res.araddr    := arg_axi4.araddr(res.araddr'range);
    res.arlen     := arg_axi4.arlen;
    res.arsize    := arg_axi4.arsize;
    res.arburst   := arg_axi4.arburst;
    res.arlock    := arg_axi4.arlock;
    res.arcache   := arg_axi4.arcache;
    res.arprot    := arg_axi4.arprot;
    res.arqos     := arg_axi4.arqos;
    res.arregion  := arg_axi4.arregion;
    res.aruser    := arg_axi4.aruser(res.aruser'range);
    res.arvalid   := arg_axi4.arvalid;
    res.rready    := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4 : t_axi4_c2c_s2m
  )
  return t_axi4_s2m is
    variable res : t_axi4_s2m;
  begin
    res.awready                     := arg_axi4.awready;
    res.wready                      := arg_axi4.wready;
    res.bid(arg_axi4.bid'range)     := arg_axi4.bid;
    res.bresp                       := arg_axi4.bresp;
    res.buser(arg_axi4.buser'range) := arg_axi4.buser;
    res.bvalid                      := arg_axi4.bvalid;
    res.arready                     := arg_axi4.arready;
    res.rid(arg_axi4.rid'range)     := arg_axi4.rid;
    res.rdata(arg_axi4.rdata'range) := arg_axi4.rdata;
    res.rresp                       := arg_axi4.rresp;
    res.rlast                       := arg_axi4.rlast;
    res.ruser(arg_axi4.ruser'range) := arg_axi4.ruser;
    res.rvalid                      := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_c2c_m2s
  )  return t_axi4_m2s is
    variable res : t_axi4_m2s;
  begin
    res.awid(arg_axi4.awid'range)     := arg_axi4.awid;
    res.awaddr(arg_axi4.awaddr'range) := arg_axi4.awaddr;
    res.awlock                        := arg_axi4.awlock;
    res.awlen                         := arg_axi4.awlen;
    res.awsize                        := arg_axi4.awsize;
    res.awburst                       := arg_axi4.awburst;
    res.awcache                       := arg_axi4.awcache;
    res.awprot                        := arg_axi4.awprot;
    res.awqos                         := arg_axi4.awqos;
    res.awregion                      := arg_axi4.awregion;
    res.awuser(arg_axi4.awuser'range) := arg_axi4.awuser;
    res.awvalid                       := arg_axi4.awvalid;
    res.wdata(arg_axi4.wdata'range)   := arg_axi4.wdata;
    res.wstrb(arg_axi4.wstrb'range)   := arg_axi4.wstrb;
    res.wlast                         := arg_axi4.wlast;
    res.wuser(arg_axi4.wuser'range)   := arg_axi4.wuser;
    res.wvalid                        := arg_axi4.wvalid;
    res.bready                        := arg_axi4.bready;
    res.arid(arg_axi4.arid'range)     := arg_axi4.arid;
    res.araddr(arg_axi4.araddr'range) := arg_axi4.araddr;
    res.arlen                         := arg_axi4.arlen;
    res.arsize                        := arg_axi4.arsize;
    res.arburst                       := arg_axi4.arburst;
    res.arlock                        := arg_axi4.arlock;
    res.arcache                       := arg_axi4.arcache;
    res.arprot                        := arg_axi4.arprot;
    res.arqos                         := arg_axi4.arqos;
    res.arregion                      := arg_axi4.arregion;
    res.aruser(arg_axi4.aruser'range) := arg_axi4.aruser;
    res.arvalid                       := arg_axi4.arvalid;
    res.rready                        := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  ----------------------------------------------------------
  -- DAQ ---------------------------------------------------
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_daq_s2m is
    variable res : t_axi4_daq_s2m;
  begin
    res.awready  := arg_axi4.awready;
    res.wready   := arg_axi4.wready;
    res.bid      := arg_axi4.bid(res.bid'range);
    res.bresp    := arg_axi4.bresp;
    res.buser    := arg_axi4.buser(res.buser'range);
    res.bvalid   := arg_axi4.bvalid;
    res.arready  := arg_axi4.arready;
    res.rid      := arg_axi4.rid(res.rid'range);
    res.rdata    := arg_axi4.rdata(res.rdata'range);
    res.rresp    := arg_axi4.rresp;
    res.rlast    := arg_axi4.rlast;
    res.ruser    := arg_axi4.ruser(res.ruser'range);
    res.rvalid   := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )  return t_axi4_daq_m2s is
    variable res : t_axi4_daq_m2s;
  begin
    res.awid      := arg_axi4.awid(res.awid'range);
    res.awaddr    := arg_axi4.awaddr(res.awaddr'range);
    res.awlock    := arg_axi4.awlock;
    res.awlen     := arg_axi4.awlen;
    res.awsize    := arg_axi4.awsize;
    res.awburst   := arg_axi4.awburst;
    res.awcache   := arg_axi4.awcache;
    res.awprot    := arg_axi4.awprot;
    res.awqos     := arg_axi4.awqos;
    res.awregion  := arg_axi4.awregion;
    res.awuser    := arg_axi4.awuser(res.awuser'range);
    res.awvalid   := arg_axi4.awvalid;
    res.wdata     := arg_axi4.wdata(res.wdata'range);
    res.wstrb     := arg_axi4.wstrb(res.wstrb'range);
    res.wlast     := arg_axi4.wlast;
    res.wuser     := arg_axi4.wuser(res.wuser'range);
    res.wvalid    := arg_axi4.wvalid;
    res.bready    := arg_axi4.bready;
    res.arid      := arg_axi4.arid(res.arid'range);
    res.araddr    := arg_axi4.araddr(res.araddr'range);
    res.arlen     := arg_axi4.arlen;
    res.arsize    := arg_axi4.arsize;
    res.arburst   := arg_axi4.arburst;
    res.arlock    := arg_axi4.arlock;
    res.arcache   := arg_axi4.arcache;
    res.arprot    := arg_axi4.arprot;
    res.arqos     := arg_axi4.arqos;
    res.arregion  := arg_axi4.arregion;
    res.aruser    := arg_axi4.aruser(res.aruser'range);
    res.arvalid   := arg_axi4.arvalid;
    res.rready    := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4 : t_axi4_daq_s2m
  )
  return t_axi4_s2m is
    variable res : t_axi4_s2m;
  begin
    res.awready                     := arg_axi4.awready;
    res.wready                      := arg_axi4.wready;
    res.bid(arg_axi4.bid'range)     := arg_axi4.bid;
    res.bresp                       := arg_axi4.bresp;
    res.buser(arg_axi4.buser'range) := arg_axi4.buser;
    res.bvalid                      := arg_axi4.bvalid;
    res.arready                     := arg_axi4.arready;
    res.rid(arg_axi4.rid'range)     := arg_axi4.rid;
    res.rdata(arg_axi4.rdata'range) := arg_axi4.rdata;
    res.rresp                       := arg_axi4.rresp;
    res.rlast                       := arg_axi4.rlast;
    res.ruser(arg_axi4.ruser'range) := arg_axi4.ruser;
    res.rvalid                      := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_daq_m2s
  )  return t_axi4_m2s is
    variable res : t_axi4_m2s;
  begin
    res.awid(arg_axi4.awid'range)     := arg_axi4.awid;
    res.awaddr(arg_axi4.awaddr'range) := arg_axi4.awaddr;
    res.awlock                        := arg_axi4.awlock;
    res.awlen                         := arg_axi4.awlen;
    res.awsize                        := arg_axi4.awsize;
    res.awburst                       := arg_axi4.awburst;
    res.awcache                       := arg_axi4.awcache;
    res.awprot                        := arg_axi4.awprot;
    res.awqos                         := arg_axi4.awqos;
    res.awregion                      := arg_axi4.awregion;
    res.awuser(arg_axi4.awuser'range) := arg_axi4.awuser;
    res.awvalid                       := arg_axi4.awvalid;
    res.wdata(arg_axi4.wdata'range)   := arg_axi4.wdata;
    res.wstrb(arg_axi4.wstrb'range)   := arg_axi4.wstrb;
    res.wlast                         := arg_axi4.wlast;
    res.wuser(arg_axi4.wuser'range)   := arg_axi4.wuser;
    res.wvalid                        := arg_axi4.wvalid;
    res.bready                        := arg_axi4.bready;
    res.arid(arg_axi4.arid'range)     := arg_axi4.arid;
    res.araddr(arg_axi4.araddr'range) := arg_axi4.araddr;
    res.arlen                         := arg_axi4.arlen;
    res.arsize                        := arg_axi4.arsize;
    res.arburst                       := arg_axi4.arburst;
    res.arlock                        := arg_axi4.arlock;
    res.arcache                       := arg_axi4.arcache;
    res.arprot                        := arg_axi4.arprot;
    res.arqos                         := arg_axi4.arqos;
    res.arregion                      := arg_axi4.arregion;
    res.aruser(arg_axi4.aruser'range) := arg_axi4.aruser;
    res.arvalid                       := arg_axi4.arvalid;
    res.rready                        := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  ----------------------------------------------------------
  -- pshp ---------------------------------------------------
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_pshp_s2m is
    variable res : t_axi4_pshp_s2m;
  begin
    res.awready  := arg_axi4.awready;
    res.wready   := arg_axi4.wready;
    res.bid      := arg_axi4.bid(res.bid'range);
    res.bresp    := arg_axi4.bresp;
    res.buser    := arg_axi4.buser(res.buser'range);
    res.bvalid   := arg_axi4.bvalid;
    res.arready  := arg_axi4.arready;
    res.rid      := arg_axi4.rid(res.rid'range);
    res.rdata    := arg_axi4.rdata(res.rdata'range);
    res.rresp    := arg_axi4.rresp;
    res.rlast    := arg_axi4.rlast;
    res.ruser    := arg_axi4.ruser(res.ruser'range);
    res.rvalid   := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )  return t_axi4_pshp_m2s is
    variable res : t_axi4_pshp_m2s;
  begin
    res.awid      := arg_axi4.awid(res.awid'range);
    res.awaddr    := arg_axi4.awaddr(res.awaddr'range);
    res.awlock    := arg_axi4.awlock;
    res.awlen     := arg_axi4.awlen;
    res.awsize    := arg_axi4.awsize;
    res.awburst   := arg_axi4.awburst;
    res.awcache   := arg_axi4.awcache;
    res.awprot    := arg_axi4.awprot;
    res.awqos     := arg_axi4.awqos;
    res.awregion  := arg_axi4.awregion;
    res.awuser    := arg_axi4.awuser(res.awuser'range);
    res.awvalid   := arg_axi4.awvalid;
    res.wdata     := arg_axi4.wdata(res.wdata'range);
    res.wstrb     := arg_axi4.wstrb(res.wstrb'range);
    res.wlast     := arg_axi4.wlast;
    res.wuser     := arg_axi4.wuser(res.wuser'range);
    res.wvalid    := arg_axi4.wvalid;
    res.bready    := arg_axi4.bready;
    res.arid      := arg_axi4.arid(res.arid'range);
    res.araddr    := arg_axi4.araddr(res.araddr'range);
    res.arlen     := arg_axi4.arlen;
    res.arsize    := arg_axi4.arsize;
    res.arburst   := arg_axi4.arburst;
    res.arlock    := arg_axi4.arlock;
    res.arcache   := arg_axi4.arcache;
    res.arprot    := arg_axi4.arprot;
    res.arqos     := arg_axi4.arqos;
    res.arregion  := arg_axi4.arregion;
    res.aruser    := arg_axi4.aruser(res.aruser'range);
    res.arvalid   := arg_axi4.arvalid;
    res.rready    := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4 : t_axi4_pshp_s2m
  )
  return t_axi4_s2m is
    variable res : t_axi4_s2m;
  begin
    res.awready                     := arg_axi4.awready;
    res.wready                      := arg_axi4.wready;
    res.bid(arg_axi4.bid'range)     := arg_axi4.bid;
    res.bresp                       := arg_axi4.bresp;
    res.buser(arg_axi4.buser'range) := arg_axi4.buser;
    res.bvalid                      := arg_axi4.bvalid;
    res.arready                     := arg_axi4.arready;
    res.rid(arg_axi4.rid'range)     := arg_axi4.rid;
    res.rdata(arg_axi4.rdata'range) := arg_axi4.rdata;
    res.rresp                       := arg_axi4.rresp;
    res.rlast                       := arg_axi4.rlast;
    res.ruser(arg_axi4.ruser'range) := arg_axi4.ruser;
    res.rvalid                      := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_pshp_m2s
  )  return t_axi4_m2s is
    variable res : t_axi4_m2s;
  begin
    res.awid(arg_axi4.awid'range)     := arg_axi4.awid;
    res.awaddr(arg_axi4.awaddr'range) := arg_axi4.awaddr;
    res.awlock                        := arg_axi4.awlock;
    res.awlen                         := arg_axi4.awlen;
    res.awsize                        := arg_axi4.awsize;
    res.awburst                       := arg_axi4.awburst;
    res.awcache                       := arg_axi4.awcache;
    res.awprot                        := arg_axi4.awprot;
    res.awqos                         := arg_axi4.awqos;
    res.awregion                      := arg_axi4.awregion;
    res.awuser(arg_axi4.awuser'range) := arg_axi4.awuser;
    res.awvalid                       := arg_axi4.awvalid;
    res.wdata(arg_axi4.wdata'range)   := arg_axi4.wdata;
    res.wstrb(arg_axi4.wstrb'range)   := arg_axi4.wstrb;
    res.wlast                         := arg_axi4.wlast;
    res.wuser(arg_axi4.wuser'range)   := arg_axi4.wuser;
    res.wvalid                        := arg_axi4.wvalid;
    res.bready                        := arg_axi4.bready;
    res.arid(arg_axi4.arid'range)     := arg_axi4.arid;
    res.araddr(arg_axi4.araddr'range) := arg_axi4.araddr;
    res.arlen                         := arg_axi4.arlen;
    res.arsize                        := arg_axi4.arsize;
    res.arburst                       := arg_axi4.arburst;
    res.arlock                        := arg_axi4.arlock;
    res.arcache                       := arg_axi4.arcache;
    res.arprot                        := arg_axi4.arprot;
    res.arqos                         := arg_axi4.arqos;
    res.arregion                      := arg_axi4.arregion;
    res.aruser(arg_axi4.aruser'range) := arg_axi4.aruser;
    res.arvalid                       := arg_axi4.arvalid;
    res.rready                        := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  ----------------------------------------------------------
  -- pshpm ---------------------------------------------------
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_pshpm_s2m is
    variable res : t_axi4_pshpm_s2m;
  begin
    res.awready  := arg_axi4.awready;
    res.wready   := arg_axi4.wready;
    res.bid      := arg_axi4.bid(res.bid'range);
    res.bresp    := arg_axi4.bresp;
    res.buser    := arg_axi4.buser(res.buser'range);
    res.bvalid   := arg_axi4.bvalid;
    res.arready  := arg_axi4.arready;
    res.rid      := arg_axi4.rid(res.rid'range);
    res.rdata    := arg_axi4.rdata(res.rdata'range);
    res.rresp    := arg_axi4.rresp;
    res.rlast    := arg_axi4.rlast;
    res.ruser    := arg_axi4.ruser(res.ruser'range);
    res.rvalid   := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )  return t_axi4_pshpm_m2s is
    variable res : t_axi4_pshpm_m2s;
  begin
    res.awid      := arg_axi4.awid(res.awid'range);
    res.awaddr    := arg_axi4.awaddr(res.awaddr'range);
    res.awlock    := arg_axi4.awlock;
    res.awlen     := arg_axi4.awlen;
    res.awsize    := arg_axi4.awsize;
    res.awburst   := arg_axi4.awburst;
    res.awcache   := arg_axi4.awcache;
    res.awprot    := arg_axi4.awprot;
    res.awqos     := arg_axi4.awqos;
    res.awregion  := arg_axi4.awregion;
    res.awuser    := arg_axi4.awuser(res.awuser'range);
    res.awvalid   := arg_axi4.awvalid;
    res.wdata     := arg_axi4.wdata(res.wdata'range);
    res.wstrb     := arg_axi4.wstrb(res.wstrb'range);
    res.wlast     := arg_axi4.wlast;
    res.wuser     := arg_axi4.wuser(res.wuser'range);
    res.wvalid    := arg_axi4.wvalid;
    res.bready    := arg_axi4.bready;
    res.arid      := arg_axi4.arid(res.arid'range);
    res.araddr    := arg_axi4.araddr(res.araddr'range);
    res.arlen     := arg_axi4.arlen;
    res.arsize    := arg_axi4.arsize;
    res.arburst   := arg_axi4.arburst;
    res.arlock    := arg_axi4.arlock;
    res.arcache   := arg_axi4.arcache;
    res.arprot    := arg_axi4.arprot;
    res.arqos     := arg_axi4.arqos;
    res.arregion  := arg_axi4.arregion;
    res.aruser    := arg_axi4.aruser(res.aruser'range);
    res.arvalid   := arg_axi4.arvalid;
    res.rready    := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4 : t_axi4_pshpm_s2m
  )
  return t_axi4_s2m is
    variable res : t_axi4_s2m;
  begin
    res.awready                     := arg_axi4.awready;
    res.wready                      := arg_axi4.wready;
    res.bid(arg_axi4.bid'range)     := arg_axi4.bid;
    res.bresp                       := arg_axi4.bresp;
    res.buser(arg_axi4.buser'range) := arg_axi4.buser;
    res.bvalid                      := arg_axi4.bvalid;
    res.arready                     := arg_axi4.arready;
    res.rid(arg_axi4.rid'range)     := arg_axi4.rid;
    res.rdata(arg_axi4.rdata'range) := arg_axi4.rdata;
    res.rresp                       := arg_axi4.rresp;
    res.rlast                       := arg_axi4.rlast;
    res.ruser(arg_axi4.ruser'range) := arg_axi4.ruser;
    res.rvalid                      := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_pshpm_m2s
  )  return t_axi4_m2s is
    variable res : t_axi4_m2s;
  begin
    res.awid(arg_axi4.awid'range)     := arg_axi4.awid;
    res.awaddr(arg_axi4.awaddr'range) := arg_axi4.awaddr;
    res.awlock                        := arg_axi4.awlock;
    res.awlen                         := arg_axi4.awlen;
    res.awsize                        := arg_axi4.awsize;
    res.awburst                       := arg_axi4.awburst;
    res.awcache                       := arg_axi4.awcache;
    res.awprot                        := arg_axi4.awprot;
    res.awqos                         := arg_axi4.awqos;
    res.awregion                      := arg_axi4.awregion;
    res.awuser(arg_axi4.awuser'range) := arg_axi4.awuser;
    res.awvalid                       := arg_axi4.awvalid;
    res.wdata(arg_axi4.wdata'range)   := arg_axi4.wdata;
    res.wstrb(arg_axi4.wstrb'range)   := arg_axi4.wstrb;
    res.wlast                         := arg_axi4.wlast;
    res.wuser(arg_axi4.wuser'range)   := arg_axi4.wuser;
    res.wvalid                        := arg_axi4.wvalid;
    res.bready                        := arg_axi4.bready;
    res.arid(arg_axi4.arid'range)     := arg_axi4.arid;
    res.araddr(arg_axi4.araddr'range) := arg_axi4.araddr;
    res.arlen                         := arg_axi4.arlen;
    res.arsize                        := arg_axi4.arsize;
    res.arburst                       := arg_axi4.arburst;
    res.arlock                        := arg_axi4.arlock;
    res.arcache                       := arg_axi4.arcache;
    res.arprot                        := arg_axi4.arprot;
    res.arqos                         := arg_axi4.arqos;
    res.arregion                      := arg_axi4.arregion;
    res.aruser(arg_axi4.aruser'range) := arg_axi4.aruser;
    res.arvalid                       := arg_axi4.arvalid;
    res.rready                        := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  -- p2p stream
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4s_s2m
  )
  return t_axi4s_p2p_s2m is
    variable res : t_axi4s_p2p_s2m;
  begin
    res.tready := arg_axi4.tready;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4s_m2s
  )
  return t_axi4s_p2p_m2s is
    variable res : t_axi4s_p2p_m2s;
  begin
    res.tdata := arg_axi4.tdata(res.tdata'range);
    res.tstrb := arg_axi4.tstrb(res.tstrb'range);
    res.tkeep := arg_axi4.tkeep(res.tkeep'range);
    res.tlast := arg_axi4.tlast;
    res.tid   := arg_axi4.tid(res.tid'range);
    res.tdest := arg_axi4.tdest(res.tdest'range);
    res.tuser := arg_axi4.tuser(res.tuser'range);
    res.tvalid:= arg_axi4.tvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4s_p2p_s2m
  )
  return t_axi4s_s2m is
    variable res : t_axi4s_s2m;
  begin
    res.tready := arg_axi4.tready;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4s_p2p_m2s
  )
  return t_axi4s_m2s is
    variable res : t_axi4s_m2s;
  begin
    res.tdata(res.tdata'range) := arg_axi4.tdata;
    res.tstrb(res.tstrb'range) := arg_axi4.tstrb;
    res.tkeep(res.tkeep'range) := arg_axi4.tkeep;
    res.tlast                  := arg_axi4.tlast;
    res.tid(res.tid'range)     := arg_axi4.tid;
    res.tdest(res.tdest'range) := arg_axi4.tdest;
    res.tuser(res.tuser'range) := arg_axi4.tuser;
    res.tvalid                 := arg_axi4.tvalid;
    return res;
  end function f_common_to_bsp;

  ----------------------------------------------------------
  -- reg axi4l
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4l_s2m
  )
  return t_axi4l_reg_s2m is
    variable res : t_axi4l_reg_s2m;
  begin
    res.awready := arg_axi4.awready;
    res.wready  := arg_axi4.wready;
    res.bresp   := arg_axi4.bresp;
    res.bvalid  := arg_axi4.bvalid;
    res.arready := arg_axi4.arready;
    res.rdata   := arg_axi4.rdata;
    res.rresp   := arg_axi4.rresp;
    res.rvalid  := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4l_m2s
  )
  return t_axi4l_reg_m2s is
    variable res : t_axi4l_reg_m2s;
  begin
    res.awaddr   := arg_axi4.awaddr;
    res.awprot   := arg_axi4.awprot;
    res.awvalid  := arg_axi4.awvalid;
    res.wdata    := arg_axi4.wdata;
    res.wstrb    := arg_axi4.wstrb;
    res.wvalid   := arg_axi4.wvalid;
    res.bready   := arg_axi4.bready;
    res.araddr   := arg_axi4.araddr;
    res.arprot   := arg_axi4.arprot;
    res.arvalid  := arg_axi4.arvalid;
    res.rready   := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4l_reg_s2m
  )
  return t_axi4l_s2m is
    variable res : t_axi4l_s2m;
  begin
    res.awready := arg_axi4.awready;
    res.wready  := arg_axi4.wready;
    res.bresp   := arg_axi4.bresp;
    res.bvalid  := arg_axi4.bvalid;
    res.arready := arg_axi4.arready;
    res.rdata   := arg_axi4.rdata;
    res.rresp   := arg_axi4.rresp;
    res.rvalid  := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4l_reg_m2s
  )
  return t_axi4l_m2s is
    variable res : t_axi4l_m2s;
  begin
    res.awaddr   := arg_axi4.awaddr;
    res.awprot   := arg_axi4.awprot;
    res.awvalid  := arg_axi4.awvalid;
    res.wdata    := arg_axi4.wdata;
    res.wstrb    := arg_axi4.wstrb;
    res.wvalid   := arg_axi4.wvalid;
    res.bready   := arg_axi4.bready;
    res.araddr   := arg_axi4.araddr;
    res.arprot   := arg_axi4.arprot;
    res.arvalid  := arg_axi4.arvalid;
    res.rready   := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  ----------------------------------------------------------
  -- reg axi4 ---------------------------------------------------
  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_s2m
  )
  return t_axi4_reg_s2m is
    variable res : t_axi4_reg_s2m;
  begin
    res.awready  := arg_axi4.awready;
    res.wready   := arg_axi4.wready;
    res.bid      := arg_axi4.bid(res.bid'range);
    res.bresp    := arg_axi4.bresp;
    res.buser    := arg_axi4.buser(res.buser'range);
    res.bvalid   := arg_axi4.bvalid;
    res.arready  := arg_axi4.arready;
    res.rid      := arg_axi4.rid(res.rid'range);
    res.rdata    := arg_axi4.rdata(res.rdata'range);
    res.rresp    := arg_axi4.rresp;
    res.rlast    := arg_axi4.rlast;
    res.ruser    := arg_axi4.ruser(res.ruser'range);
    res.rvalid   := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_m2s
  )
  return t_axi4_reg_m2s is
    variable res : t_axi4_reg_m2s;
  begin
    res.awid      := arg_axi4.awid(res.awid'range);
    res.awaddr    := arg_axi4.awaddr(res.awaddr'range);
    res.awlock    := arg_axi4.awlock;
    res.awlen     := arg_axi4.awlen;
    res.awsize    := arg_axi4.awsize;
    res.awburst   := arg_axi4.awburst;
    res.awcache   := arg_axi4.awcache;
    res.awprot    := arg_axi4.awprot;
    res.awqos     := arg_axi4.awqos;
    res.awregion  := arg_axi4.awregion;
    res.awuser    := arg_axi4.awuser(res.awuser'range);
    res.awvalid   := arg_axi4.awvalid;
    res.wdata     := arg_axi4.wdata(res.wdata'range);
    res.wstrb     := arg_axi4.wstrb(res.wstrb'range);
    res.wlast     := arg_axi4.wlast;
    res.wuser     := arg_axi4.wuser(res.wuser'range);
    res.wvalid    := arg_axi4.wvalid;
    res.bready    := arg_axi4.bready;
    res.arid      := arg_axi4.arid(res.arid'range);
    res.araddr    := arg_axi4.araddr(res.araddr'range);
    res.arlen     := arg_axi4.arlen;
    res.arsize    := arg_axi4.arsize;
    res.arburst   := arg_axi4.arburst;
    res.arlock    := arg_axi4.arlock;
    res.arcache   := arg_axi4.arcache;
    res.arprot    := arg_axi4.arprot;
    res.arqos     := arg_axi4.arqos;
    res.arregion  := arg_axi4.arregion;
    res.aruser    := arg_axi4.aruser(res.aruser'range);
    res.arvalid   := arg_axi4.arvalid;
    res.rready    := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4 : t_axi4_reg_s2m
  )
  return t_axi4_s2m is
    variable res : t_axi4_s2m;
  begin
    res.awready                     := arg_axi4.awready;
    res.wready                      := arg_axi4.wready;
    res.bid(arg_axi4.bid'range)     := arg_axi4.bid;
    res.bresp                       := arg_axi4.bresp;
    res.buser(arg_axi4.buser'range) := arg_axi4.buser;
    res.bvalid                      := arg_axi4.bvalid;
    res.arready                     := arg_axi4.arready;
    res.rid(arg_axi4.rid'range)     := arg_axi4.rid;
    res.rdata(arg_axi4.rdata'range) := arg_axi4.rdata;
    res.rresp                       := arg_axi4.rresp;
    res.rlast                       := arg_axi4.rlast;
    res.ruser(arg_axi4.ruser'range) := arg_axi4.ruser;
    res.rvalid                      := arg_axi4.rvalid;
    return res;
  end function f_common_to_bsp;

  function f_common_to_bsp (
    signal arg_axi4  : t_axi4_reg_m2s
  )
  return t_axi4_m2s is
    variable res : t_axi4_m2s;
  begin
    res.awid(arg_axi4.awid'range)     := arg_axi4.awid;
    res.awaddr(arg_axi4.awaddr'range) := arg_axi4.awaddr;
    res.awlock                        := arg_axi4.awlock;
    res.awlen                         := arg_axi4.awlen;
    res.awsize                        := arg_axi4.awsize;
    res.awburst                       := arg_axi4.awburst;
    res.awcache                       := arg_axi4.awcache;
    res.awprot                        := arg_axi4.awprot;
    res.awqos                         := arg_axi4.awqos;
    res.awregion                      := arg_axi4.awregion;
    res.awuser(arg_axi4.awuser'range) := arg_axi4.awuser;
    res.awvalid                       := arg_axi4.awvalid;
    res.wdata(arg_axi4.wdata'range)   := arg_axi4.wdata;
    res.wstrb(arg_axi4.wstrb'range)   := arg_axi4.wstrb;
    res.wlast                         := arg_axi4.wlast;
    res.wuser(arg_axi4.wuser'range)   := arg_axi4.wuser;
    res.wvalid                        := arg_axi4.wvalid;
    res.bready                        := arg_axi4.bready;
    res.arid(arg_axi4.arid'range)     := arg_axi4.arid;
    res.araddr(arg_axi4.araddr'range) := arg_axi4.araddr;
    res.arlen                         := arg_axi4.arlen;
    res.arsize                        := arg_axi4.arsize;
    res.arburst                       := arg_axi4.arburst;
    res.arlock                        := arg_axi4.arlock;
    res.arcache                       := arg_axi4.arcache;
    res.arprot                        := arg_axi4.arprot;
    res.arqos                         := arg_axi4.arqos;
    res.arregion                      := arg_axi4.arregion;
    res.aruser(arg_axi4.aruser'range) := arg_axi4.aruser;
    res.arvalid                       := arg_axi4.arvalid;
    res.rready                        := arg_axi4.rready;
    return res;
  end function f_common_to_bsp;

end package body common_bsp_ifs;
