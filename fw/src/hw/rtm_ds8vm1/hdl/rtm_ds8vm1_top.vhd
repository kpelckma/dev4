------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
-- @copyright Copyright 2021 DESY
-- SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
-- @date 2018-10-25
-- @author Radoslaw Rybaniec
-- @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
-- @brief
-- Top VHDL file for the DRTM-DS8VM1 Board. It mostly holds the slow diagnostic ICs (I2C)
-- as well as interlock logic.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library desy;
use desy.common_types.all;

library desyrdl;
use desyrdl.pkg_rtm.all;

use work.pkg_version_rtm_ds8vm1.all;

entity rtm_ds8vm1_top is
  generic(
    G_CLK_FREQ : natural := 78_000_000); -- pi_clock frequency in Hz (used for I2C Clock divider setting)
  port(
    pi_clock : in std_logic;
    pi_reset : in std_logic;

    -- register interface
    pi_s_reg_reset : in  std_logic;
    pi_s_reg : in  t_rtm_m2s;
    po_s_reg : out t_rtm_s2m;
    
    pi_interlock     : in std_logic;   -- interlock produced by application -> Will forward this to Zone3 pins
    po_ext_interlock : out std_logic;  -- external interlock monitoring coming from Zone3 Pin

    pio_rtm_io_p : inout std_logic_vector(11 downto 0); -- Zone3 Pins
    pio_rtm_io_n : inout std_logic_vector(11 downto 0)
  );
end rtm_ds8vm1_top;

architecture arch of rtm_ds8vm1_top is

  signal addrmap_i : t_addrmap_rtm_in;
  signal addrmap_o : t_addrmap_rtm_out;
  
  signal sdi : std_logic;
  signal sdo : std_logic;
  signal sdt : std_logic;
  signal sci : std_logic;
  signal sco : std_logic; 
  signal sct : std_logic;
  
  -- _data post_fix is for registers
  -- _str post_fix is for strobes when those registers get touched by software
  signal att_sel_data    : std_logic_vector(8 downto 0);
  signal att_val_data    : std_logic_vector(5 downto 0);
  signal att_val_str     : std_logic;
  signal att_start_data  : std_logic;
  signal att_data_data   : std_logic_vector(31 downto 0);
  signal att_busy        : std_logic;
  signal adc_rd_ena_data : std_logic;
  signal ref_power_str   : std_logic;
  signal ref_power_data  : std_logic_vector(24 downto 0);
  signal ref_temp_str    : std_logic;
  signal ref_temp_data   : std_logic_vector(24 downto 0);
  signal ref_adc_busy    : std_logic_vector(3 downto 0);
  signal adc_c_str       : std_logic;
  signal adc_d_str       : std_logic;
  signal adc_a_data_data : std_logic_vector(24 downto 0);
  signal adc_b_data_data : std_logic_vector(24 downto 0);
  signal adc_c_data_data : std_logic_vector(24 downto 0);
  signal adc_d_data_data : std_logic_vector(24 downto 0);
  signal adc_status_data : std_logic_vector(3 downto 0);
  signal temp_a_str      : std_logic;
  signal temp_b_str      : std_logic;
  signal temp_c_str      : std_logic;
  signal temp_d_str      : std_logic;
  signal temp_e_str      : std_logic;
  signal temp_f_str      : std_logic;
  signal temp_a_data     : std_logic_vector(24 downto 0);
  signal temp_b_data     : std_logic_vector(24 downto 0);
  signal temp_c_data     : std_logic_vector(11 downto 0);
  signal temp_d_data     : std_logic_vector(11 downto 0);
  signal temp_e_data     : std_logic_vector(11 downto 0);
  signal temp_f_data     : std_logic_vector(11 downto 0);
  signal dac_status_data : std_logic_vector(3 downto 0);
  signal daca_str        : std_logic;
  signal daca_data       : std_logic_vector(15 downto 0);
  signal dacb_str        : std_logic;
  signal dacb_data       : std_logic_vector(15 downto 0);
  signal dac_busy        : std_logic_vector(1 downto 0);
  signal pll_str         : std_logic;
  signal pll_busy        : std_logic;
  signal pll_data        : std_logic_vector(31 downto 0);

  signal expander_0_out_str  : std_logic;
  signal expander_0_out_data : std_logic_vector(7 downto 0);
  signal expander_1_in_str   : std_logic;
  signal expander_1_in_data  : std_logic_vector(7 downto 0);

  -- External interlock monitoring comes to FPGA asynchronously
  signal ext_interlock    : std_logic; -- External interlock monitoring coming from Zone3
  signal ext_interlock_q  : std_logic; -- 2xFF registers
  signal ext_interlock_qq : std_logic; 
  attribute async_reg : string;
  attribute async_reg of ext_interlock_q : signal is "TRUE";
  attribute async_reg of ext_interlock_qq: signal is "TRUE";
    
begin

  po_ext_interlock <= ext_interlock_qq; -- Giving external interlock monitoring signal to application

  -- Register access
  ins_desyrdl : entity desyrdl.rtm
  port map (
    pi_clock     => pi_clock,
    pi_reset     => pi_s_reg_reset,
    pi_s_top     => pi_s_reg,
    po_s_top     => po_s_reg,
    pi_addrmap   => addrmap_i,
    po_addrmap   => addrmap_o
  );
  
  att_val_data   <= addrmap_o.ATT_VAL.data.data;
  att_sel_data   <= addrmap_o.ATT_SEL.data.data;
  att_val_str <=  addrmap_o.ATT_VAL.data.swmod;

  ref_power_str <= addrmap_o.REF_POWER.data.swacc;
  ref_temp_str <= addrmap_o.REF_TEMP.data.swacc;

  -- Strobes for the temperature sensors
  temp_a_str <= addrmap_o.TEMP_A.data.swacc;
  temp_b_str <= addrmap_o.TEMP_B.data.swacc;
  temp_c_str <= addrmap_o.TEMP_C.data.swacc;
  temp_d_str <= addrmap_o.TEMP_D.data.swacc;
  temp_e_str <= addrmap_o.TEMP_E.data.swacc;
  temp_f_str <= addrmap_o.TEMP_F.data.swacc;

  daca_data <= addrmap_o.DAC_VM_COM_MODE_Q.data.data;
  dacb_data <= addrmap_o.DAC_VM_COM_MODE_I.data.data;
  daca_str  <= addrmap_o.DAC_VM_COM_MODE_Q.data.swmod;
  dacb_str  <= addrmap_o.DAC_VM_COM_MODE_I.data.swmod;

  pll_data <= addrmap_o.PLL_DATA.data.data;
  pll_str <= addrmap_o.PLL_DATA.data.swmod;

  expander_0_out_str <= addrmap_o.PLL_OSC_SEL.data.swmod or
                        addrmap_o.PLL_CLK_IN_SEL.data.swmod or
                        addrmap_o.REFERENCE_DIV.data.swmod or
                        addrmap_o.CLK_RST_SELECT.data.swmod or
                        addrmap_o.CLK_RST_SOURCE.data.swmod or
                        addrmap_o.CLK_RST_ENABLE.data.swmod or 
                        addrmap_o.SYNC_CLK_SELECT.data.swmod;
                                
  expander_0_out_data(0)          <= addrmap_o.PLL_OSC_SEL.data.data(0);
  expander_0_out_data(2 downto 1) <= addrmap_o.REFERENCE_DIV.data.data;
  expander_0_out_data(3)          <= addrmap_o.PLL_CLK_IN_SEL.data.data(0);
  expander_0_out_data(4)          <= addrmap_o.CLK_RST_SELECT.data.data(0);
  expander_0_out_data(5)          <= addrmap_o.CLK_RST_SOURCE.data.data(0);
  expander_0_out_data(6)          <= addrmap_o.CLK_RST_ENABLE.data.data(0);
  expander_0_out_data(7)          <= addrmap_o.SYNC_CLK_SELECT.data.data(0);
  
  expander_1_in_str <= addrmap_o.RTM_STATUS.data.swacc;
  
  addrmap_i.NAME(0).data.data          <= x"20445338";
  addrmap_i.NAME(1).data.data          <= x"564d3120";
  addrmap_i.REF_POWER.data.data        <= ref_power_data;
  addrmap_i.REF_TEMP.data.data         <= ref_temp_data;
  addrmap_i.REF_ADC_BUSY.data.data     <= ref_adc_busy;
  addrmap_i.DAC_VM_BUSY.data.data      <= dac_busy;
  addrmap_i.ATT_BUSY.data.data(0)      <= att_busy;
  addrmap_i.PLL_BUSY.data.data(0)      <= pll_busy;
  addrmap_i.RTM_STATUS.data.data       <= expander_1_in_data;
  addrmap_i.TEMP_A.data.data           <= temp_a_data;
  addrmap_i.TEMP_B.data.data           <= temp_b_data;
  addrmap_i.TEMP_C.data.data           <= temp_c_data;
  addrmap_i.TEMP_D.data.data           <= temp_d_data;
  addrmap_i.TEMP_E.data.data           <= temp_e_data;
  addrmap_i.TEMP_F.data.data           <= temp_f_data;
  addrmap_i.EXT_INTERLOCK.data.data(0) <= ext_interlock_qq;

  
  -- Handling RTM Zone3 Signals (Interlock)
  blk_rtm_io : block
    signal l_interlock : std_logic;
    signal l_sdt_n : std_logic;
    signal l_sct_n : std_logic; 
  begin
    
    l_sdt_n <=  not sdt;
    l_sct_n <=  not sct;
    
    ins_rtm_i2c_p : iobuf port map (io => pio_rtm_io_p(3), i => sdo, o => sdi, t => l_sdt_n);
    ins_rtm_i2c_n : iobuf port map (io => pio_rtm_io_n(3), i => sco, o => sci, t => l_sct_n);
    
    -- If RF_PERMIT is '1' -> Go 
    -- IF RF_PERMIT is '0' -> Stop RF (Interlock asserted)
    l_interlock <= addrmap_o.RF_PERMIT.data.data(0) and (not pi_interlock);

    pio_rtm_io_p(10) <= l_interlock;
    pio_rtm_io_n(10) <= 'Z';  -- switching to single ended because default application pin constrains are differential 
                              -- however on the digitizer this pin is single ended
    ibufds_ins : ibufds
    generic map (DIFF_TERM => TRUE) -- differential termination)
    port map (
      o => ext_interlock,  
      i => pio_rtm_io_p(4), 
      ib => pio_rtm_io_n(4));

    -- synching external interlock to pi_clock domain
    sync_interlock: process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        ext_interlock_q  <= ext_interlock;
        ext_interlock_qq <= ext_interlock_q;
      end if;
    end process;
    
  end block;


  ins_i2c_subsys : entity work.i2c_subsys
  generic map (
    G_CLK_FREQ => G_CLK_FREQ,
    G_I2C_CLK_FREQ => 800)
  port map (
    pi_clock => pi_clock,
    pi_reset => pi_reset,
    
    pi_att_val    => att_val_data,
    pi_att_sel    => att_sel_data,
    pi_att_start  => att_val_str,
    po_att_busy   => att_busy,

    pi_daca_data => daca_data,
    pi_daca_str  => daca_str,
    pi_dacb_data => dacb_data,
    pi_dacb_str  => dacb_str,

    po_dac_busy  => dac_busy,

    po_adc_a_data => ref_power_data,
    pi_adc_a_str  => ref_power_str,
    po_adc_b_data => ref_temp_data,
    pi_adc_b_str  => ref_temp_str,
    po_adc_busy   => ref_adc_busy,
    
    po_temp_a_data => temp_a_data,
    pi_temp_a_str  => temp_a_str,
    po_temp_b_data => temp_b_data,
    pi_temp_b_str  => temp_b_str,
    po_temp_c_data => temp_c_data,
    pi_temp_c_str  => temp_c_str,
    po_temp_d_data => temp_d_data,
    pi_temp_d_str  => temp_d_str,
    po_temp_e_data => temp_e_data,
    pi_temp_e_str  => temp_e_str,
    po_temp_f_data => temp_f_data,
    pi_temp_f_str  => temp_f_str,

    pi_pll_data => pll_data,
    pi_pll_str  => pll_str,
    po_pll_busy => pll_busy,
    
    pi_expander_0_out_str  => expander_0_out_str,
    pi_expander_0_out_data => expander_0_out_data,
    pi_expander_1_in_str   => expander_1_in_str,
    po_expander_1_in_data  => expander_1_in_data,

    pi_sdi => sdi,
    po_sdo => sdo,
    po_sdt => sdt,
    pi_sci => sci,
    po_sco => sco,
    po_sct => sct
  );


end arch;

