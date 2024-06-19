-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
-- Date        : Wed Sep 20 09:21:31 2023
-- Host        : workstation running 64-bit unknown
-- Command     : write_vhdl -force -mode synth_stub
--               /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.srcs/sources_1/bd/sis8300ku_bsp_system/ip/sis8300ku_bsp_system_sys_reset_0_0/sis8300ku_bsp_system_sys_reset_0_0_stub.vhdl
-- Design      : sis8300ku_bsp_system_sys_reset_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku040-ffva1156-1-c
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sis8300ku_bsp_system_sys_reset_0_0 is
  Port ( 
    slowest_sync_clk : in STD_LOGIC;
    ext_reset_in : in STD_LOGIC;
    aux_reset_in : in STD_LOGIC;
    mb_debug_sys_rst : in STD_LOGIC;
    dcm_locked : in STD_LOGIC;
    mb_reset : out STD_LOGIC;
    bus_struct_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    interconnect_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 );
    peripheral_aresetn : out STD_LOGIC_VECTOR ( 0 to 0 )
  );

end sis8300ku_bsp_system_sys_reset_0_0;

architecture stub of sis8300ku_bsp_system_sys_reset_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "slowest_sync_clk,ext_reset_in,aux_reset_in,mb_debug_sys_rst,dcm_locked,mb_reset,bus_struct_reset[0:0],peripheral_reset[0:0],interconnect_aresetn[0:0],peripheral_aresetn[0:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "proc_sys_reset,Vivado 2020.1";
begin
end;