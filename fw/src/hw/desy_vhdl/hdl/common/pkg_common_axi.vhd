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
--! package with common AXI interfaces and components
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common_axi_cfg.all;

--******************************************************************************
package common_axi is

  --============================================================================
  -- AXI4 memory mapped interface (TODO: Evaluate this option)
  --============================================================================
  --  type t_axi4_g is record
  --    aclk     : std_logic;
  --    areset_n : std_logic;
  --  end record t_axi4_g;


  --============================================================================
  -- AXI4 memory mapped interface
  --============================================================================
  type t_axi4_m2s is record
    -- write address channel signals---------------------------------------------
    awid        : std_logic_vector(C_AXI4_ID_WIDTH-1 downto 0);
    awaddr      : std_logic_vector(C_AXI4_ADDR_WIDTH-1 downto 0);
    awlock      : std_logic;
    awlen       : std_logic_vector(7 downto 0);
    awsize      : std_logic_vector(2 downto 0);
    awburst     : std_logic_vector(1 downto 0);
    awcache     : std_logic_vector(3 downto 0);
    awprot      : std_logic_vector(2 downto 0);
    awqos       : std_logic_vector(3 downto 0);
    awregion    : std_logic_vector(3 downto 0);
    awuser      : std_logic_vector(C_AXI4_AWUSER_WIDTH-1 downto 0);
    awvalid     : std_logic;
    -- write data channel signals---------------------------------------------
    wdata       : std_logic_vector(C_AXI4_DATA_WIDTH-1 downto 0);
    wstrb       : std_logic_vector(C_AXI4_DATA_WIDTH/8-1 downto 0);
    wlast       : std_logic;
    wuser       : std_logic_vector(C_AXI4_WUSER_WIDTH-1 downto 0);
    wvalid      : std_logic;
    -- write response channel signals
    bready      : std_logic;
    -- read address channel signals ---------------------------------------------
    arid        : std_logic_vector(C_AXI4_ID_WIDTH-1 downto 0);
    araddr      : std_logic_vector(C_AXI4_ADDR_WIDTH-1 downto 0);
    arlen       : std_logic_vector(7 downto 0);
    arsize      : std_logic_vector(2 downto 0);
    arburst     : std_logic_vector(1 downto 0);
    arlock      : std_logic;
    arcache     : std_logic_vector(3 downto 0);
    arprot      : std_logic_vector(2 downto 0);
    arqos       : std_logic_vector(3 downto 0);
    arregion    : std_logic_vector(3 downto 0);
    aruser      : std_logic_vector(C_AXI4_ARUSER_WIDTH-1 downto 0);
    arvalid     : std_logic;
    -- read data channel signals---------------------------------------------
    rready      : std_logic;
  end record t_axi4_m2s;

  type t_axi4_s2m is record
    -- write address channel signals---------------------------------------------
    awready     : std_logic;
    -- write data channel signals---------------------------------------------
    wready      : std_logic;
    -- write response channel signals ---------------------------------------------
    bid         : std_logic_vector(C_AXI4_ID_WIDTH-1 downto 0);
    bresp       : std_logic_vector(1 downto 0);
    buser       : std_logic_vector(C_AXI4_BUSER_WIDTH-1 downto 0);
    bvalid      : std_logic;
    -- read address channel signals---------------------------------------------
    arready     : std_logic;
    -- read data channel signals---------------------------------------------
    rid         : std_logic_vector(C_AXI4_ID_WIDTH-1 downto 0);
    rdata       : std_logic_vector(C_AXI4_DATA_WIDTH-1 downto 0);
    rresp       : std_logic_vector(1 downto 0);
    rlast       : std_logic;
    ruser       : std_logic_vector(C_AXI4_RUSER_WIDTH-1 downto 0);
    rvalid      : std_logic;
  end record t_axi4_s2m;


  --============================================================================
  -- AXI4-Lite
  --============================================================================
  type t_axi4l_m2s is record
    -- write address channel signals---------------------------------------------
    awaddr      : std_logic_vector(C_AXI4L_ADDR_WIDTH-1 downto 0);
    awprot      : std_logic_vector(2 downto 0);
    awvalid     : std_logic;
    -- write data channel signals---------------------------------------------
    wdata       : std_logic_vector(C_AXI4L_DATA_WIDTH-1 downto 0);
    wstrb       : std_logic_vector(C_AXI4L_DATA_WIDTH/8-1 downto 0);
    wvalid      : std_logic;
    -- write response channel signals
    bready      : std_logic;
    -- read address channel signals ---------------------------------------------
    araddr      : std_logic_vector(C_AXI4L_ADDR_WIDTH-1 downto 0);
    arprot      : std_logic_vector(2 downto 0);
    arvalid     : std_logic;
    -- read data channel signals---------------------------------------------
    rready      : std_logic;
  end record t_axi4l_m2s;

  type t_axi4l_s2m is record
    -- write address channel signals---------------------------------------------
    awready     : std_logic;
    -- write data channel signals---------------------------------------------
    wready      : std_logic;
    -- write response channel signals ---------------------------------------------
    bresp       : std_logic_vector(1 downto 0);
    bvalid      : std_logic;
    -- read address channel signals---------------------------------------------
    arready     : std_logic;
    -- read data channel signals---------------------------------------------
    rdata       : std_logic_vector(C_AXI4L_DATA_WIDTH-1 downto 0);
    rresp       : std_logic_vector(1 downto 0);
    rvalid      : std_logic;
  end record t_axi4l_s2m;


  --============================================================================
  -- AXI4-Stream Interface
  --============================================================================
  type t_axi4s_m2s is record
    tdata   : std_logic_vector(C_AXI4S_DATA_WIDTH-1 downto 0);
    tstrb   : std_logic_vector(C_AXI4S_DATA_WIDTH/8-1 downto 0);
    tkeep   : std_logic_vector(C_AXI4S_DATA_WIDTH/8-1 downto 0);
    tlast   : std_logic;
    tid     : std_logic_vector(C_AXI4S_ID_WIDTH-1 downto 0);
    tdest   : std_logic_vector(C_AXI4S_DEST_WIDTH-1 downto 0);
    tuser   : std_logic_vector(C_AXI4S_USER_WIDTH-1 downto 0);
    tvalid  : std_logic;
  end record t_axi4s_m2s;

  type t_axi4s_s2m is record
    tready  : std_logic;
  end record t_axi4s_s2m;


  --============================================================================
  -- AXI4 arrays
  --============================================================================
  -- type tif_axi4_glb_array is array (natural range <>) of tif_axi4_glb;

  type t_axi4_m2s_vector  is array (natural range <>) of t_axi4_m2s;
  type t_axi4_s2m_vector  is array (natural range <>) of t_axi4_s2m;
  type t_axi4l_m2s_vector is array (natural range <>) of t_axi4l_m2s;
  type t_axi4l_s2m_vector is array (natural range <>) of t_axi4l_s2m;
  type t_axi4s_m2s_vector is array (natural range <>) of t_axi4s_m2s;
  type t_axi4s_s2m_vector is array (natural range <>) of t_axi4s_s2m;


  --============================================================================
  -- AXI4 general useful functions
  --============================================================================
  function f_decode_axi4_axsize(arg_bytes: natural) return std_logic_vector;
  function f_decode_axi4_axsize(arg_axsize: std_logic_vector(2 downto 0)) return natural;

  --============================================================================
  -- AXI4 general constants
  --============================================================================
  -- Burst type (AWBURST, ARBURST)
  constant C_AXI4_BURST_FIXED   : std_logic_vector(1 downto 0) := "00"; -- same address for every transfer in the burst
  constant C_AXI4_BURST_INCR    : std_logic_vector(1 downto 0) := "01"; -- increment address for next transfer
  constant C_AXI4_BURST_WRAP    : std_logic_vector(1 downto 0) := "10"; -- incrementing burst, wraps around to a lower address if an upper address limit is reached.

  -- Read and write response structure (BRESP, RRESP)
  constant C_AXI4_RESP_OKAY     : std_logic_vector(1 downto 0) := "00"; -- Normal access success
  constant C_AXI4_RESP_EXOKAY   : std_logic_vector(1 downto 0) := "01"; -- Exclusive access okay
  constant C_AXI4_RESP_SLVERR   : std_logic_vector(1 downto 0) := "10"; -- Slave error
  constant C_AXI4_RESP_DECERR   : std_logic_vector(1 downto 0) := "11"; -- Decode error

  -- default state
  constant C_AXI4_S2M_DEFAULT : t_axi4_s2m := (
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
  constant C_AXI4_M2S_DEFAULT : t_axi4_m2s := (
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

  constant C_AXI4L_S2M_DEFAULT : t_axi4l_s2m := (
    awready     => '0',
    wready      => '0',
    bresp       => (others => '0'),
    bvalid      => '0',
    arready     => '0' ,
    rdata       => (others => '0'),
    rresp       => (others => '0'),
    rvalid      => '0'
  );
  constant C_AXI4L_M2S_DEFAULT : t_axi4l_m2s := (
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

  constant C_AXI4S_M2S_DEFAULT : t_axi4s_m2s := (
    tdata  => (others => '0'),
    tstrb  => (others => '0'),
    tkeep  => (others => '0'),
    tlast  => '0',
    tid    => (others => '0'),
    tdest  => (others => '0'),
    tuser  => (others => '0'),
    tvalid => '0'
  );

  constant C_AXI4S_S2M_DEFAULT : t_axi4s_s2m := (
    tready  => '0'
  );

end package common_axi;

--******************************************************************************
package body common_axi is
  -- AxSIZE[2:0] Bytes in transfer
  -- 0b000 1
  -- 0b001 2
  -- 0b010 4
  -- 0b011 8
  -- 0b100 16
  -- 0b101 32
  -- 0b110 64
  -- 0b111 128

  function f_decode_axi4_axsize(arg_bytes: natural) return std_logic_vector is
  begin
    case arg_bytes is
      when 1   => return "000";
      when 2   => return "001";
      when 4   => return "010";
      when 8   => return "011";
      when 16  => return "100";
      when 32  => return "101";
      when 64  => return "110";
      when 128 => return "111";
      when others =>
        return "000";
        report "AXI4 not supoprted byte transfer";
    end case;
  end function f_decode_axi4_axsize;

  function f_decode_axi4_axsize(arg_axsize: std_logic_vector(2 downto 0)) return natural is
  begin
    case arg_axsize is
      when "000" => return 1  ;
      when "001" => return 2  ;
      when "010" => return 4  ;
      when "011" => return 8  ;
      when "100" => return 16 ;
      when "101" => return 32 ;
      when "110" => return 64 ;
      when "111" => return 128;
      when others =>
        return 0;
        report "AXI4 not supoprted byte transfer";
    end case;
  end function f_decode_axi4_axsize;


end package body common_axi;
