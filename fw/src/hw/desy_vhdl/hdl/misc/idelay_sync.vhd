--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2017 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2017-04-12
--! @author
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--! Cagil Gumus <cagil.guemues@desy.de>
--------------------------------------------------------------------------------
--! @brief Delay and synchronize external input
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library desy;
use desy.common_types.all;

entity idelay_sync is
  generic (
    G_ARCH            : string  := "";
    G_USE_IDELAYCTRL  : boolean := true;
    G_IODELAY_GROUP   : string  := "";
    G_CHANNEL         : natural := 1
  );
  port (
    pi_reset      : in  std_logic;
    pi_clock      : in  std_logic;
    pi_clock_ref  : in  std_logic;

    pi_iodelay_valid  : in  std_logic_vector(G_CHANNEL-1 downto 0);
    pi_iodelay_value  : in  t_6b_slv_vector(G_CHANNEL-1 downto 0);

    pi_data : in  std_logic_vector(G_CHANNEL-1 downto 0) := (others => '0');
    po_data : out std_logic_vector(G_CHANNEL-1 downto 0)
  );
end entity idelay_sync;

architecture rtl of idelay_sync is

  attribute iob           : string;
  attribute iodelay_group : string;
  attribute async_reg     : string;

begin

  assert not (G_ARCH = "ULTRASCALE" and not G_USE_IDELAYCTRL) report "IODELAYCTRL has be to used with Ultrascale architecture because IDELAYE3 is used in TIME mode." severity failure;
  assert not (G_ARCH = "VIRTEX5") report "Virtex-5 is not supported." severity failure;  

  gen_idelayctrl: if G_USE_IDELAYCTRL generate

    gen_idelayctrl_us: if G_ARCH = "ULTRASCALE" generate
      attribute iodelay_group of ins_idelayctrl: label is G_IODELAY_GROUP;
      component idelayctrl is
        generic (
          SIM_DEVICE  : string  := "ULTRASCALE"
        );
        port (
          rdy     : out std_logic;
          refclk  : in  std_logic;
          rst     : in  std_logic
        );
      end component idelayctrl;
    begin
      ins_idelayctrl: idelayctrl
        generic map (
          SIM_DEVICE  => "ULTRASCALE"
        )
        port map (
          rdy     => open,          --! 1-bit Output indicates validity of the refclk
          refclk  => pi_clock_ref,  --! 1-bit Reference clock input
          rst     => pi_reset       --! 1-bit Asynchronous reset input
        );
    end generate gen_idelayctrl_us;

    gen_idelayctrl_us_n: if G_ARCH /= "ULTRASCALE" generate
      attribute iodelay_group of ins_idelayctrl: label is G_IODELAY_GROUP;
    begin
      ins_idelayctrl: idelayctrl
        port map (
          rdy     => open,          --! 1-bit Output indicates validity of the refclk
          refclk  => pi_clock_ref,  --! 1-bit Reference clock input
          rst     => pi_reset       --! 1-bit Asynchronous reset input
        );
    end generate gen_idelayctrl_us_n;

  end generate gen_idelayctrl;

  gen_channels: for I in 0 to G_CHANNEL-1 generate

    signal l_iodelay_rst     : std_logic;
    signal l_iodelay_ce      : std_logic;
    signal l_iodelay_en_vtc  : std_logic;
    signal l_iodelay_inc     : std_logic;
    signal l_iodelay_dataout : std_logic;

    signal l_data_ilogic  : std_logic;
    signal l_data_sync    : std_logic_vector(1 downto 0);

    --! ilogic is used to share idelay input with combinatorial logic
    --! iob and async_reg attributes are used mutually exclusive,
    --! otherwise iob wins and tool place synchronizer registers apart
    --! TODO: consider using iddr with pipelined option 
    attribute iob       of l_data_ilogic  : signal is "true";
    attribute async_reg of l_data_sync    : signal is "true";
 
  begin

    --! Synchronizing the output signal to pi_clock domain
    prs_sync: process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        l_data_ilogic <= l_iodelay_dataout;
        l_data_sync   <= l_data_sync(0) & l_data_ilogic;
      end if;
    end process prs_sync;

    po_data(i) <= l_data_sync(1);

    ins_iodelay_shifter: entity desy.iodelay_shifter
      generic map(
        G_ARCH  => G_ARCH
      )
      port map(
        pi_reset  => pi_reset,
        pi_clock  => pi_clock,
  
        pi_valid  => pi_iodelay_valid(i),
        pi_value  => pi_iodelay_value(i),
  
        po_iodelay_rst    => l_iodelay_rst, --! Needed only for IODELAYE1
        po_iodelay_ce     => l_iodelay_ce,
        po_iodelay_inc    => l_iodelay_inc,
        po_iodelay_en_vtc => l_iodelay_en_vtc
      );

    gen_iodelaye1: if G_ARCH /= "ULTRASCALE" generate
      attribute iodelay_group of ins_iodelaye1: label is G_IODELAY_GROUP;
    begin
      ins_iodelaye1: iodelaye1
        generic map (
          idelay_type   => "VARIABLE",
          idelay_value  => 0,
          delay_src     => "i"
        )
        port map (
          dataout     => l_iodelay_dataout,
          idatain     => pi_data(i),
          inc         => '1',
          c           => pi_clock,
          ce          => l_iodelay_ce,
          cinvctrl    => '0',
          clkin       => '0',
          cntvaluein  => (others => '0'),
          datain      => '0',
          odatain     => '0',
          rst         => l_iodelay_rst, --! Loads the pre-programmed value in VARIABLE mode
          t           => '1'
        );
    end generate gen_iodelaye1;
    
    --! The IDELAYE3 has a clock/data align delay that is in addition to the DELAY_VALUE attribute.
    --! The total delay through the IDELAYE3 is the align delay plus the DELAY_VALUE.
    gen_iodelaye3: if G_ARCH = "ULTRASCALE" generate
      attribute iodelay_group of ins_idelaye3 : label is G_IODELAY_GROUP;
      component idelaye3 is
        generic (
          cascade           : string  := "NONE";
          delay_format      : string  := "TIME";
          delay_src         : string  := "IDATAIN";
          delay_type        : string  := "VARIABLE";
          delay_value       : natural := 0;
          is_clk_inverted   : bit     := '0';
          is_rst_inverted   : bit     := '0';
          refclk_frequency  : real    := 200.0;
          sim_device        : string  := "ULTRASCALE";
          update_mode       : string  := "ASYNC"
        );
        port (
          dataout     : out std_logic;
          idatain     : in  std_logic;
          casc_out    : out std_logic;
          cntvalueout : out std_logic_vector(8 downto 0);
          casc_in     : in  std_logic;
          casc_return : in  std_logic;
          ce          : in  std_logic;
          clk         : in  std_logic;
          cntvaluein  : in  std_logic_vector(8 downto 0);
          datain      : in  std_logic;
          en_vtc      : in  std_logic;
          inc         : in  std_logic;
          load        : in  std_logic;
          rst         : in  std_logic
        );
      end component;
    begin
      ins_idelaye3: idelaye3
        generic map (
          cascade           => "NONE",
          delay_format      => "TIME",
          delay_src         => "IDATAIN",
          delay_type        => "VARIABLE",
          delay_value       => 0, --! Initial offset delay in ps
          is_clk_inverted   => '0',
          is_rst_inverted   => '0',
          refclk_frequency  => 200.0,
          sim_device        => "ULTRASCALE",
          update_mode       => "ASYNC"
        )
        port map (
          dataout     => l_iodelay_dataout,
          idatain     => pi_data(i),
          casc_out    => open,
          cntvalueout => open,
          casc_in     => '0',
          casc_return => '0',
          ce          => l_iodelay_ce,
          clk         => pi_clock,
          cntvaluein  => (others => '0'),
          datain      => '0',
          en_vtc      => l_iodelay_en_vtc,
          inc         => l_iodelay_inc,
          load        => '0',
          rst         => pi_reset
        );
    end generate gen_iodelaye3;

  end generate gen_channels;

end architecture rtl;
