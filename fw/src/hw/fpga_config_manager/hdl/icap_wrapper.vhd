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
--! @date 2018-10-25
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! ICAP primitive wrapper for different FPGA families
------------------------------------------------------------------------------

library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity icap_wrapper is
  generic (
    g_arch           : string := ""; --! Allowed values: VIRTEX5,VIRTEX5,SPARTAN6,7SERIES,ULTRASCALE
    g_icap_clk_div   : natural := 2  --! Clock divider for ICAP component
  );
  port(
    pi_icap_clock   : in  std_logic;                     --! Clock input to ICAP
    pi_din          : in  std_logic_vector(31 downto 0); --! Input data to ICAP
    po_dout         : out std_logic_vector(31 downto 0); --! Output data from ICAP
    po_busy         : out std_logic;                     --! ICAP Busy Flag
    pi_enable_n     : in  std_logic;                     --! Enable ICAP
    pi_wr_n         : in  std_logic                      --! Read/Write Sel
  );
end icap_wrapper;

architecture arch of icap_wrapper is

  signal din_reversed    : std_logic_vector(31 downto 0);
  signal icap_avail      : std_logic;

begin

  --! Input data needs to be reversed before sending to ICAP
  din_reversed(0)  <= pi_din(7);
  din_reversed(1)  <= pi_din(6);
  din_reversed(2)  <= pi_din(5);
  din_reversed(3)  <= pi_din(4);
  din_reversed(4)  <= pi_din(3);
  din_reversed(5)  <= pi_din(2);
  din_reversed(6)  <= pi_din(1);
  din_reversed(7)  <= pi_din(0);

  din_reversed(8)  <= pi_din(15);
  din_reversed(9)  <= pi_din(14);
  din_reversed(10) <= pi_din(13);
  din_reversed(11) <= pi_din(12);
  din_reversed(12) <= pi_din(11);
  din_reversed(13) <= pi_din(10);
  din_reversed(14) <= pi_din(9);
  din_reversed(15) <= pi_din(8);

  din_reversed(16) <= pi_din(23);
  din_reversed(17) <= pi_din(22);
  din_reversed(18) <= pi_din(21);
  din_reversed(19) <= pi_din(20);
  din_reversed(20) <= pi_din(19);
  din_reversed(21) <= pi_din(18);
  din_reversed(22) <= pi_din(17);
  din_reversed(23) <= pi_din(16);

  din_reversed(24) <= pi_din(31);
  din_reversed(25) <= pi_din(30);
  din_reversed(26) <= pi_din(29);
  din_reversed(27) <= pi_din(28);
  din_reversed(28) <= pi_din(27);
  din_reversed(29) <= pi_din(26);
  din_reversed(30) <= pi_din(25);
  din_reversed(31) <= pi_din(24);

  gen_icap_s6: if g_arch = "SPARTAN6" generate
    component ICAP_SPARTAN6 is
    generic(
      DEVICE_ID         : string;
      SIM_CFG_FILE_NAME : string
    );
    port(
      BUSY  : out std_logic;                      --! 1-bit output: Busy/Ready output
      O     : out std_logic_vector(15 downto 0);  --! 16-bit output: Configuartion data output bus
      CE    : in  std_logic;                      --! 1-bit input: Active-Low ICAP Enable input
      CLK   : in  std_logic;                      --! 1-bit input: Clock input
      I     : in  std_logic_vector(15 downto 0);  --! 16-bit input: Configuration data input bus
      WRITE : in  std_logic
    );
    end component;

    begin
      ins_icap_spartan6: ICAP_SPARTAN6
      generic map (
        DEVICE_ID => X"4000093",               --! Specifies the pre-programmed Device ID value
        SIM_CFG_FILE_NAME => "NONE"            --! Specifies the Raw Bitstream (RBT) file to be parsed by the simulation model
      )
      port map (
        BUSY  => po_busy,                      --! 1-bit output: Busy/Ready output
        O     => po_dout(15 downto 0),         --! 16-bit output: Configuartion data output bus
        CE    => pi_enable_n,                  --! 1-bit input: Active-Low ICAP Enable input
        CLK   => pi_icap_clock,                     --! 1-bit input: Clock input
        I     => din_reversed(15 downto 0), --! 16-bit input: Configuration data input bus
        WRITE => pi_wr_n                       --! 1-bit input: Read/Write control input
      );
  end generate;

  gen_icap_v5: if g_arch = "VIRTEX5" generate
    component ICAP_VIRTEX5 is
    generic(
      ICAP_WIDTH : string
    );
    port(
      BUSY  : out std_logic;                      --! 1-bit output: Busy/Ready output
      O     : out std_logic_vector(31 downto 0);  --! 32-bit output: Configuartion data output bus
      CE    : in  std_logic;                      --! 1-bit input: Active-Low ICAP Enable input
      CLK   : in  std_logic;                      --! 1-bit input: Clock input
      I     : in  std_logic_vector(31 downto 0);  --! 16-bit input: Configuration data input bus
      WRITE : in  std_logic
    );
  end component;
  begin
    ins_icap_virtex5 : ICAP_VIRTEX5
    generic map (
      ICAP_WIDTH => "X32"                    -- "X8", "X16" or "X32"
    )
    port map (
      BUSY   => po_busy,                    --! 1-bit output: Busy/Ready output
      O      => po_dout,                    --! 32-bit output: Configuartion data output bus
      CE     => pi_enable_n,                --! 1-bit input: Active-Low ICAP Enable input
      CLK    => pi_icap_clock,              --! 1-bit input: Clock input
      I      => din_reversed,               --! 32-bit input: Configuration data input bus
      WRITE  => pi_wr_n                     --! 1-bit input: Read/Write control input
    );
  end generate;

  gen_icap_v6: if g_arch = "VIRTEX6" generate
    component ICAP_VIRTEX6 is
    generic(
      DEVICE_ID         : string;
      ICAP_WIDTH        : string;
      SIM_CFG_FILE_NAME : string
    );
    port(
      BUSY  : out std_logic;                      --! 1-bit output: Busy/Ready output
      O     : out std_logic_vector(31 downto 0);  --! 32-bit output: Configuartion data output bus
      CSB   : in  std_logic;                      --! 1-bit input: Active-Low ICAP Enable input
      CLK   : in  std_logic;                      --! 1-bit input: Clock input
      I     : in  std_logic_vector(31 downto 0);  --! 16-bit input: Configuration data input bus
      RDWRB : in  std_logic
    );
    end component;
    begin
      ins_icap_virtex6 : ICAP_VIRTEX6
      generic map (
        DEVICE_ID  => X"4244093",             --! Specifies the pre-programmed Device ID value
        ICAP_WIDTH => "X32",                  --! Specifies the input and output data width to be used with the ICAP_VIRTEX6.
        SIM_CFG_FILE_NAME => "NONE"           --! Specifies the Raw Bitstream (RBT) file to be parsed by the simulation model
      )
      port map (
        BUSY   => po_busy,                    --! 1-bit output: Busy/Ready output
        O      => po_dout,                    --! 32-bit output: Configuartion data output bus
        CSB    => pi_enable_n,                --! 1-bit input: Active-Low ICAP Enable input
        CLK    => pi_icap_clock,              --! 1-bit input: Clock input
        I      => din_reversed,               --! 32-bit input: Configuration data input bus
        RDWRB  => pi_wr_n                     --! 1-bit input: Read/Write control input
      );
 end generate;

  gen_icap_7s: if g_arch = "7SERIES" generate
    component ICAPE2 is
    generic(
      DEVICE_ID         : string;
      ICAP_WIDTH        : string;
      SIM_CFG_FILE_NAME : string
    );
    port(
      O     : out std_logic_vector(31 downto 0);  --! 32-bit output: Configuartion data output bus
      CSIB  : in  std_logic;                      --! 1-bit input: Active-Low ICAP Enable input
      CLK   : in  std_logic;                      --! 1-bit input: Clock input
      I     : in  std_logic_vector(31 downto 0);  --! 16-bit input: Configuration data input bus
      RDWRB : in  std_logic
    );
    end component;
    begin
      ins_icape2 : ICAPE2
      generic map (
        DEVICE_ID => X"3651093",              --! Specifies the pre-programmed Device ID value to be used for simulation
                                              --! purposes.
        ICAP_WIDTH => "X32",                  --! Specifies the input and output data width.
        SIM_CFG_FILE_NAME => "NONE"           --! Specifies the Raw Bitstream (RBT) file to be parsed by the simulation model
      )
      port map (
        O      => po_dout,                    --! 32-bit output: Configuartion data output bus
        CSIB   => pi_enable_n,                --! 1-bit input: Active-Low ICAP Enable input
        CLK    => pi_icap_clock,              --! 1-bit input: Clock input
        I      => din_reversed,               --! 32-bit input: Configuration data input bus
        RDWRB  => pi_wr_n                     --! 1-bit input: Read/Write control input
      );
  end generate;

  gen_icap_ultra: if g_arch = "ULTRASCALE" generate
    component ICAPE3 is
      generic(
        DEVICE_ID         : string;
        ICAP_AUTO_SWITCH  : string;
        SIM_CFG_FILE_NAME : string
      );
      port(
        AVAIL   : out std_logic;
        O       : out std_logic_vector(31 downto 0);
        PRDONE  : out std_logic;
        PRERROR : out std_logic;
        CLK     : in  std_logic;
        CSIB    : in  std_logic;
        I       : in  std_logic_vector(31 downto 0);
        RDWRB   : in  std_logic
      );
    end component;
    begin
      po_busy <= not icap_avail;
      inst_icape3 : ICAPE3
        generic map (
          DEVICE_ID => X"03628093",      -- Specifies the pre-programmed Device ID value to be used for simulation purposes
          ICAP_AUTO_SWITCH => "DISABLE", -- Enable switch ICAP using sync word
          SIM_CFG_FILE_NAME => "NONE"    -- Specifies the Raw Bitstream (RBT) file to be parsed by the simulationmodel
        )
        port map (
          AVAIL   => icap_avail,          --! 1-bit output: Availability status of ICAP
          O       => po_dout,             --! 32-bit output: Configuration data output bus
          PRDONE  => open,                --! 1-bit output: Indicates completion of Partial Reconfiguration
          PRERROR => open,                --! 1-bit output: Indicates Error during Partial Reconfiguration
          CLK     => pi_icap_clock,       --! 1-bit input: Clock input
          CSIB    => pi_enable_n,         --! 1-bit input: Active-Low ICAP enable
          I       => din_reversed,        --! 32-bit input: Configuration data input bus
          RDWRB   => pi_wr_n              --! 1-bit input: Read/Write Select input
        );
  end generate;

end arch;
