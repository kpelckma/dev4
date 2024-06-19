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
--! @author Dariusz Makowski <dmakow@dmcs.pl>
--! @author Grzegorz Jablonski
--! @author Konrad Przygoda
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! SPI PROM Programmer with II interface wrapper
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity fpga_spi_io_phy is
  generic(
    g_arch            : string  := "SPARTAN6"
  );
  port (
    pi_clock          : in  std_logic;

    po_prog_spi_sdi   : out std_logic;        --! SPI Signals coming to/from programmer
    pi_prog_spi_sdo   : in  std_logic;
    pi_prog_spi_cs_n  : in  std_logic;
    pi_prog_spi_clk   : in  std_logic;

    pi_spi_sdi        :  in  std_logic;       --! SPI Connections to/from outside
    po_spi_sdo        :  out std_logic;
    po_spi_cs_n       :  out std_logic;
    po_spi_clk        :  out std_logic;

    pi_ext_spi_en     : in  std_logic := '0'; --! SPI Forwarding (eg. from Microblaze)
    pi_ext_spi_sdo    : in  std_logic := '0';
    pi_ext_spi_cs_n   : in  std_logic := '0';
    po_ext_spi_sdi    : out std_logic;
    pi_ext_spi_clk    : in  std_logic := '0'
  );
end fpga_spi_io_phy;

architecture arch of fpga_spi_io_phy is

  signal spi_sdi : std_logic;

begin

  po_prog_spi_sdi <= spi_sdi;
  po_ext_spi_sdi  <= spi_sdi;

  -- async process as ext and programmer SPI might work on different clocks - need better solution
  po_spi_sdo      <= pi_ext_spi_sdo when pi_ext_spi_en = '1' else pi_prog_spi_sdo;
  po_spi_clk      <= pi_ext_spi_clk when pi_ext_spi_en = '1' else pi_prog_spi_clk;
  po_spi_cs_n     <= pi_ext_spi_cs_n when pi_ext_spi_en = '1' else pi_prog_spi_cs_n;

  --! Switching to external SPI source (eg Microblaze taking control of the connection)
  -- process (pi_clock) is
  -- begin
  --   if rising_edge(pi_clock) then
  --     if pi_ext_spi_en = '1' then
  --       po_spi_sdo      <= pi_ext_spi_sdo;
  --       po_spi_clk      <= pi_ext_spi_clk;
  --       po_spi_cs_n     <= pi_ext_spi_cs_n;
  --     else
  --       po_spi_sdo      <= pi_prog_spi_sdo;
  --       po_spi_clk      <= pi_prog_spi_clk;
  --       po_spi_cs_n     <= pi_prog_spi_cs_n;
  --     end if;
  --   end if;
  -- end process;

  -----------------------------------------------------------------------------------
  ---! STARTUP primitive gives access to the dedicated FPGA Configuration pins
  -----------------------------------------------------------------------------------

  gen_startup_spartan6: if G_ARCH = "SPARTAN6" generate
  --! Spartan 6 has no STARTUP primitive hence SPI connections are done
  --! through traditional way.
    spi_sdi <= pi_spi_sdi;
  end generate;

  gen_startup_virtex5: if G_ARCH = "VIRTEX5" generate
    component STARTUP_VIRTEX5 is
    port (
      CFGCLK    : out std_logic;  -- Config logic clock 1-bit output
      CFGMCLK   : out std_logic;  -- Config internal osc clock 1-bit output
      DINSPI    : out std_logic;  -- DIN SPI PROM access 1-bit output
      EOS       : out std_logic;  -- End of Startup 1-bit output
      TCKSPI    : out std_logic;  -- TCK SPI PROM access 1-bit output
      CLK       : in std_logic;  -- Clock input for start-up sequence
      GSR       : in std_logic;  -- Global Set/Reset input (GSR cannot be used for the port name)
      GTS       : in std_logic;  -- Global 3-state input (GTS cannot be used for the port name)
      USRCCLKO  : in std_logic;  -- User CCLK 1-bit input
      USRCCLKTS : in std_logic;  -- User CCLK 3-state, 1-bit input
      USRDONEO  : in std_logic;  -- User Done 1-bit input
      USRDONETS : in std_logic   -- User Done 3-state, 1-bit input
    );
    end component;
  begin
    ins_startup_virtex5 : STARTUP_VIRTEX5
    port map (
      CFGCLK    => open,                  --! Config logic clock 1-bit output
      CFGMCLK   => open,                  --! Config internal osc clock 1-bit output
      DINSPI    => spi_sdi,               --! DIN SPI PROM access 1-bit output
      EOS       => open,                  --! End of Startup 1-bit output
      TCKSPI    => open,
      CLK       => '0',                   --! Clock input for start-up sequence
      GSR       => '0',                   --! Global Set/Reset input (GSR cannot be used for the port name)
      GTS       => '0',                   --! Global 3-state input (GTS cannot be used for the port name)
      USRCCLKO  => pi_prog_spi_clk,       --! User CCLK 1-bit input
      USRCCLKTS => '0',                   --! User CCLK 3-state, 1-bit input
      USRDONEO  => '0',                   --! User Done 1-bit input
      USRDONETS => '0'                    --! User Done 3-state, 1-bit input
     );
  end generate;

  gen_startup_virtex6: if G_ARCH = "VIRTEX6" generate
    component STARTUP_VIRTEX6 is
    port (
      CFGCLK    : out std_logic; -- 1-bit output: Configuration main clock output
      CFGMCLK   : out std_logic; -- 1-bit output: Configuration internal oscillator clock output
      DINSPI    : out std_logic; -- 1-bit output: DIN SPI PROM access output
      EOS       : out std_logic; -- 1-bit output: Active high output signal indicating the End Of Configuration.
      PREQ      : out std_logic; -- 1-bit output: PROGRAM request to fabric output
      TCKSPI    : out std_logic; -- 1-bit output: TCK configuration pin access output
      CLK       : in std_logic;  -- 1-bit input: User start-up clock input
      GSR       : in std_logic;  -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
      GTS       : in std_logic;  -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
      KEYCLEARB : in std_logic;  -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
      PACK      : in std_logic;  -- 1-bit input: PROGRAM acknowledge input
      USRCCLKO  : in std_logic;  -- 1-bit input: User CCLK input
      USRCCLKTS : in std_logic;  -- 1-bit input: User CCLK 3-state enable input
      USRDONEO  : in std_logic;  -- 1-bit input: User DONE pin output control
      USRDONETS : in std_logic   -- 1-bit input: User DONE 3-state enable output
    );
    end component;
  begin
    ins_startup_virtex6 : STARTUP_VIRTEX6
    port map (
      CFGCLK    => open,                  -- Config logic clock 1-bit output
      CFGMCLK   => open,                  -- Config internal osc clock 1-bit output
      DINSPI    => spi_sdi,               -- DIN SPI PROM access 1-bit output
      EOS       => open,                  -- End of Startup 1-bit output
      TCKSPI    => open,
      CLK       => '1',                   -- Clock input for start-up sequence
      GSR       => '0',                   -- Global Set/Reset input (GSR cannot be used for the port name)
      GTS       => '0',                   -- Global 3-state input (GTS cannot be used for the port name)
      USRCCLKO  => pi_prog_spi_clk,       -- User CCLK 1-bit input
      USRCCLKTS => '0',                   -- User CCLK 3-state, 1-bit input
      USRDONETS => '1',                   -- User Done 3-state, 1-bit input
      KEYCLEARB => '1',
      PACK      => '0',
      USRDONEO  => '1'
    );
  end generate;

  gen_startup_7series: if G_ARCH = "7SERIES" generate
    component STARTUPE2 is
    port (
      CFGCLK    : out std_logic;   -- 1-bit output: Configuration main clock output
      CFGMCLK   : out std_logic;   -- 1-bit output: Configuration internal oscillator clock output
      EOS       : out std_logic;   -- 1-bit output: Active high output signal indicating the End Of Startup.
      PREQ      : out std_logic;   -- 1-bit output: PROGRAM request to fabric output
      CLK       : in std_logic;    -- 1-bit input: User start-up clock input
      GSR       : in std_logic;    -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
      GTS       : in std_logic;    -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
      KEYCLEARB : in std_logic;    -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
      PACK      : in std_logic;    -- 1-bit input: PROGRAM acknowledge input
      USRCCLKO  : in std_logic;    -- 1-bit input: User CCLK input
      USRCCLKTS : in std_logic;    -- 1-bit input: User CCLK 3-state enable input
      USRDONEO  : in std_logic;    -- 1-bit input: User DONE pin output control
      USRDONETS : in std_logic     -- 1-bit input: User DONE 3-state enable output
    );
    end component;
  begin
    ins_startupe2 : STARTUPE2
    port map (
      CFGCLK    => open,               -- 1-bit output: Configuration main clock output
      CFGMCLK   => open,               -- 1-bit output: Configuration internal oscillator clock output
      EOS       => open,               -- 1-bit output: Active high output signal indicating the End Of Startup.
      PREQ      => open,               -- 1-bit output: PROGRAM request to fabric output
      CLK       => '1',                -- 1-bit input: User start-up clock input
      GSR       => '0',                -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
      GTS       => '0',                -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
      KEYCLEARB => '1',                -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
      PACK      => '0',                -- 1-bit input: PROGRAM acknowledge input
      USRCCLKO  => pi_prog_spi_clk,    -- 1-bit input: User CCLK input
      USRCCLKTS => '0',                -- 1-bit input: User CCLK 3-state enable input
      USRDONEO  => '1',                -- 1-bit input: User DONE pin output control
      USRDONETS => '0'                 -- 1-bit input: User DONE 3-state enable output
    );
    spi_sdi <= pi_spi_sdi;
  end generate;

  gen_startup_ultrascale: if G_ARCH = "ULTRASCALE"  generate
    signal l_spi_sdo : std_logic_vector(3 downto 0);
    signal l_spi_sdi : std_logic_vector(3 downto 0);

    component STARTUPE3 is
    generic(
      PROG_USR : string ;
      SIM_CCLK_FREQ : real
    );
    port(
      CFGCLK    : out std_logic;
      CFGMCLK   : out std_logic;
      DI        : out std_logic_vector(3 downto 0);
      EOS       : out std_logic;
      PREQ      : out std_logic;
      DO        : in std_logic_vector(3 downto 0);
      DTS       : in std_logic_vector(3 downto 0);
      FCSBO     : in std_logic;
      FCSBTS    : in std_logic;
      GSR       : in std_logic;
      GTS       : in std_logic;
      KEYCLEARB : in std_logic;
      PACK      : in std_logic;
      USRCCLKO  : in std_logic;
      USRCCLKTS : in std_logic;
      USRDONEO  : in std_logic;
      USRDONETS : in std_logic
    );
    end component;
  begin

      l_spi_sdo(0) <= pi_prog_spi_sdo;
      spi_sdi <= l_spi_sdi(1);

      ins_startup3 : STARTUPE3
      generic map(
        PROG_USR      => "FALSE",           --! Activate program event security feature.
        SIM_CCLK_FREQ => 10.0               --! Set the Configuration Clock Frequency(ns) for simulation.
      )
      port map(
        CFGCLK    => open,                  --! 1-bit output: Configuration main clock output
        CFGMCLK   => open,                  --! 1-bit output: Configuration internal oscillator clock output
        DI        => l_spi_sdi,             --! 4-bit output: Allow receiving on the D input pin
        EOS       => open,                  --! 1-bit output: Active-High output signal indicating the End Of Startup
        PREQ      => open,                  --! 1-bit output: PROGRAM request to fabric output
        DO        => l_spi_sdo,             --! 4-bit input: Allows control of the D pin output
        DTS       => "1110",                --! Allows tristate of the D pin Enabling only 1 SPI lane
        FCSBO     => pi_prog_spi_cs_n,      --! 1-bit input: Contols the FCS_B pin for flash access
        FCSBTS    => '0',                   --! 1-bit input: Tristate the FCS_B pin
        GSR       => '0',                   --! 1-bit input: Global Set/Reset input (Must connected to GND)
        GTS       => '0',                   --! 1-bit input: Global 3-state input (Must connected to GND)
        KEYCLEARB => '1',                   --! 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
        PACK      => '0',                   --! 1-bit input: PROGRAM acknowledge input
        USRCCLKO  => pi_prog_spi_clk,       --! 1-bit input: User CCLK input
        USRCCLKTS => '0',                   --! 1-bit input: User CCLK 3-state enable input
        USRDONEO  => '1',                   --! 1-bit input: User DONE pin output control
        USRDONETS => '0'                    --! 1-bit input: User DONE 3-state enable output
       );
  end generate;

end arch;
