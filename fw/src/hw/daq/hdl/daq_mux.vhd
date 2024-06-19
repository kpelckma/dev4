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
--! @author Radoslaw Rybaniec
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! DAQ Multiplexer
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library desy;
use desy.common_numarray.all;

entity daq_mux is
  generic (
    G_CHANNEL_WIDTH     : natural := 32; --! This is pretty much fixed for now.
    G_IN_CHANNEL_COUNT  : natural := 55;  
    G_OUT_CHANNEL_COUNT : natural := 8;
    G_TAB_COUNT         : natural := 3;
    G_SEL_SIZE          : natural := 32
    );
  port (
    pi_clock       : in std_logic;
    pi_channel_tab : in t_natural_vector(G_OUT_CHANNEL_COUNT*G_TAB_COUNT-1 downto 0);
    pi_sel         : in std_logic_vector (G_SEL_SIZE-1 downto 0);
    pi_data        : in std_logic_vector (G_CHANNEL_WIDTH*G_IN_CHANNEL_COUNT-1 downto 0);
    po_data        : out std_logic_vector(G_CHANNEL_WIDTH*G_OUT_CHANNEL_COUNT-1 downto 0);
    pi_daq_enable  : in std_logic;   --! DAQ Input Enable/Disable
    pi_daq_trg     : in std_logic;   --! DAQ Input Trigger 
    pi_daq_dry     : in std_logic;   --! DAQ Input Strobe
    pi_transaction_end : in std_logic := '0'; --! DAQ Input user transaction reset
    po_daq_enable  : out std_logic;  --! DAQ Output Enable/Disable
    po_daq_trg     : out std_logic;  --! DAQ Output Trigger 
    po_daq_dry     : out std_logic;  --! DAQ Output Strobe
    po_transaction_end : out std_logic --! DAQ Output user transaction reset
    );
end entity;

architecture ARCH of daq_mux is

  type T_CHAN is array (natural range <>) of std_logic_vector(G_CHANNEL_WIDTH-1 downto 0);
  type T_MUX is array (natural range <>) of T_CHAN(G_OUT_CHANNEL_COUNT-1 downto 0);

  signal REG_SEL    : std_logic_vector(G_SEL_SIZE-1 downto 0);
  signal muxes  : T_MUX(G_TAB_COUNT-1 downto 0);  
  signal i_data : T_CHAN(G_IN_CHANNEL_COUNT-1 downto 0);
  signal o_data : T_CHAN(G_OUT_CHANNEL_COUNT-1 downto 0);
  signal mux_sel : natural := 0;
  
begin
  
  GEN_MUX_NUMBER_CHECK: if G_TAB_COUNT < 1 generate
    assert 0=1 report "Please give non-zero value for tab count" severity failure;
  end generate;
  
  -- Deserialization of pi_data ( Cut into smaller chunks)
  GEN_I_DATA : for I in 0 to G_IN_CHANNEL_COUNT-1 generate
    i_data(I) <= pi_data((I+1)*G_CHANNEL_WIDTH-1 downto I*G_CHANNEL_WIDTH);
  end generate GEN_I_DATA;

  GEN_MUXES : for I in 0 to G_TAB_COUNT-1 generate
    signal part_mux : T_CHAN(G_OUT_CHANNEL_COUNT-1 downto 0);
  begin
	
    -- Selecting G_OUT_CHANNEL_COUNT amount of channels according to 
    -- what channel tabs tells us
    GEN_PARTMUX : for K in 0 to G_OUT_CHANNEL_COUNT-1 generate
      part_mux(K) <= i_data(pi_channel_tab(I*G_OUT_CHANNEL_COUNT+K));
    end generate GEN_PARTMUX;
		
    -- Giving G_OUT_CHANNEL_COUNT amount of channels to 1 mux 
    -- In total we will have G_TAB_COUNT amount of muxes
    muxes(I) <= part_mux;
	end generate GEN_MUXES;

  process (pi_clock)
  begin
    if rising_edge(pi_clock) then
      mux_sel     <= to_integer(unsigned(pi_sel));
      po_daq_enable <= pi_daq_enable;
      po_daq_trg    <= pi_daq_trg;
      po_daq_dry    <= pi_daq_dry;
      po_transaction_end <= pi_transaction_end;
      o_data      <= muxes(mux_sel);
    end if;
  end process;
	
  -- Serializing the o_data for output port
  GEN_O_DATA : for I in 0 to G_OUT_CHANNEL_COUNT-1 generate
    po_data((I+1)*G_CHANNEL_WIDTH-1 downto I*G_CHANNEL_WIDTH) <= o_data(I);
  end generate GEN_O_DATA;
end ARCH;

