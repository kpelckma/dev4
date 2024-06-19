-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------
-- Copyright (c) 2020 DESY
-------------------------------------------------------------------------------
--! @brief   
--! @author  Lukasz Butkowski  <lukasz.butkowski@desy.de>
--! @created 2020-04-08
-------------------------------------------------------------------------------
--! Description:
--!
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.PKG_APP_CONFIG.all;
use work.PKG_BOARD_CONFIG.all;
use work.PKG_ADDRESS_SPACE_MISC_DAQ.all;
use work.PKG_II.all;
use work.PKG_TYPES.all;
use work.PKG_AXI.all;
use work.math_basic.all;

------------------------------------------------------------------------------------------------------------------------

entity daq_top_tb is

end entity daq_top_tb;

------------------------------------------------------------------------------------------------------------------------

architecture arch of daq_top_tb is

  constant T_HOLD           : time := 1 ns;
  constant CLOCK_PERIOD     : time := 8 ns;
  constant DAQ_CLOCK_PERIOD : time := 5 ns;
  constant TRG_PERIOD       : time := 100 us;

  -- component generics
  constant G_FIFO_ARCH                : string                                     := "VIRTEX6";
  constant G_INPUT_DATA_CHANNEL_COUNT : natural                                    := 8;
  constant G_CHANNEL_WIDTH            : natural                                    := 32;
  constant G_ADD_INPUT_BUF            : natural                                    := 1;
  constant G_AXI_DATA_WIDTH           : natural                                    := 256;
  constant G_EXT_STR_ENA              : std_logic_vector(C_DAQ_REGIONS-1 downto 0) := (others => '0');

  -- II
  constant C_II_AS : TVII := TVIICreate(VIIItemDeclList, 32, 32);

  -- component ports
  signal pi_clk          : std_logic:='0';
  signal pi_reset        : std_logic:='0';
  signal pi_trg          : std_logic_vector(C_DAQ_REGIONS-1 downto 0) := (others => '0');
  signal pi_ext_str      : std_logic_vector(C_DAQ_REGIONS-1 downto 0) := (others => '0');
  signal pi_ibus         : t_ibus_o := C_IBUS_O_DEFAULT ;
  signal po_ibus         : t_ibus_i := C_IBUS_I_DEFAULT;
  signal pi_axi4_s2m_m   : t_axi4_s2m := C_AXI4_S2M_DEFAULT;
  signal po_axi4_m2s_m   : t_axi4_m2s := C_AXI4_M2S_DEFAULT;
  signal pi_data         : t_32BitArray(G_INPUT_DATA_CHANNEL_COUNT-1 downto 0);
  signal pi_pulse_number : std_logic_vector(31 downto 0) := (others => '0');

  signal daq_aclk        : std_logic:='0';

  signal daq_axi_wdata       : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);
  signal daq_axi_wdata_ch    : std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0);

  signal areset_n      : std_logic:='1';
  signal s_axi_awid    : std_logic_vector (3 downto 0);
  signal s_axi_awaddr  : std_logic_vector (31 downto 0);
  signal s_axi_awlen   : std_logic_vector (7 downto 0);
  signal s_axi_awburst : std_logic_vector (1 downto 0);
  signal s_axi_awvalid : std_logic:='0';
  signal s_axi_awready : std_logic:='0';
  signal s_axi_wdata   : std_logic_vector (255 downto 0);
  signal s_axi_wlast   : std_logic:='0';
  signal s_axi_wvalid  : std_logic:='0';
  signal s_axi_wready  : std_logic:='0';
  signal s_axi_bid     : std_logic_vector (3 downto 0);
  signal s_axi_bresp   : std_logic_vector (1 downto 0);
  signal s_axi_bvalid  : std_logic:='0';
  signal s_axi_bready  : std_logic:='0';

begin  -- architecture arch

  -- component instantiation
  DUT: entity work.daq_top
    generic map (
      G_FIFO_ARCH                => G_FIFO_ARCH,
      G_INPUT_DATA_CHANNEL_COUNT => G_INPUT_DATA_CHANNEL_COUNT,
      G_CHANNEL_WIDTH            => G_CHANNEL_WIDTH,
      G_ADD_INPUT_BUF            => G_ADD_INPUT_BUF,
      G_AXI_DATA_WIDTH           => G_AXI_DATA_WIDTH,
      G_EXT_STR_ENA              => G_EXT_STR_ENA)
    port map (
      pi_clk          => pi_clk,
      pi_reset        => pi_reset,
      pi_trg          => pi_trg,
      pi_ext_str      => pi_ext_str,
      pi_ibus         => pi_ibus,
      po_ibus         => po_ibus,
      pi_axi4_s2m_m   => pi_axi4_s2m_m,
      po_axi4_m2s_m   => po_axi4_m2s_m,
      pi_data         => pi_data,
      pi_pulse_number => pi_pulse_number
    );

  ------------------------------------------------------------------------------
  -- clock generation
  -- IBUS clock
  pi_clk <= not pi_clk after CLOCK_PERIOD/2;
  pi_ibus.clk <= pi_clk ;

  daq_aclk <= not daq_aclk after DAQ_CLOCK_PERIOD/2;
  pi_axi4_s2m_m.aclk <= daq_aclk;

  ------------------------------------------------------------------------------
  -- generate trigger
  ------------------------------------------------------------------------------
  prs_trg_gen:process
  begin
    pi_trg <= ( others => '0' );
    wait for 1 us;
    wait until rising_edge(pi_clk) ;
    wait for T_HOLD;
    pi_trg <= ( others =>'1' );
    wait until rising_edge(pi_clk) ;
    wait for T_HOLD;
    pi_trg <= ( others =>'0' );
    wait for TRG_PERIOD - (1 us);
  end process;

  ------------------------------------------------------------------------------
  -- generate reset
  ------------------------------------------------------------------------------
  prs_reset_gen:process
  begin
    pi_reset <= '1';
    pi_axi4_s2m_m.areset_n <= '1';
    areset_n <= '0';
    wait for 100 ns;
    wait until rising_edge(pi_clk) ;
    wait for T_HOLD;
    pi_reset <= '0';
    pi_axi4_s2m_m.areset_n <= '0';
    areset_n <= '0';
    wait for 100 ns;
    wait until rising_edge(pi_clk) ;
    wait for T_HOLD;
    pi_reset <= '0';
    pi_axi4_s2m_m.areset_n <= '1';
    areset_n <= '1';
    wait;
  end process;


  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  prs_ibus: process
    --......................................... if many ibuses add bus selection as argument
    -- procedure proc_set_ii_register (ibus_o : t_ibus_o;
    --                                 ibus_i : t_ibus_i;
    --                                 C_II_AS : ...
    --                                 addr : std_logic_vector(31 downto 0);
    --                                 data : std_logic_vector(31 downto 0)) is
    procedure proc_set_ii_register (name : natural; index:natural;
                                    data : std_logic_vector(31 downto 0)) is
      variable addr : natural;
    begin
      addr := VIIGetParam(C_II_AS, name, ITEM_ADDR)+index;
      wait until rising_edge(pi_ibus.clk) ;
      wait for T_HOLD;
      pi_ibus.data  <= data ;
      pi_ibus.addr  <= std_logic_vector(to_unsigned(addr*4,32)) ;
      pi_ibus.wena  <= '1';
      wait until rising_edge(pi_ibus.clk) ;
      wait for T_HOLD;
      pi_ibus.wena <= '0';
      loop
        exit when po_ibus.wack = '1' ;
        wait until rising_edge(pi_ibus.clk) ;
      end loop;
      wait for 2*CLOCK_PERIOD; -- delay for II to close
    end procedure proc_set_ii_register ;


  begin
    -- set registers
    proc_set_ii_register(WORD_SAMPLES, 0, x"00001000") ; -- WORD_SAMPLES[0]
    proc_set_ii_register(WORD_SAMPLES, 1, x"00001000") ; -- WORD_SAMPLES[1]
    proc_set_ii_register(WORD_ENABLE , 0, x"00000001") ; -- WORD_ENABLE

    wait for 10 us;
    proc_set_ii_register(WORD_ENABLE , 0, x"00000003") ; -- WORD_ENABLE

    wait;
  end process;

  pi_axi4_s2m_m.aclk <= daq_aclk;


  ------------------------------------------------------------------------------
  -- DAQ data vector generate
  ------------------------------------------------------------------------------
  gen_daq_cnt: for idx in 0 to 7 generate
  begin
  prs_daq_data_gen: process (pi_clk) is
  begin
    if rising_edge(pi_clk) then
      if pi_trg(0) = '1' then
        pi_data(idx) <= (others => '0') ;
      else
        pi_data(idx) <= std_logic_vector(unsigned(pi_data(idx))+idx+1);
      end if;
    end if;
  end process prs_daq_data_gen;
  end generate;


  ------------------------------------------------------------------------------
  --AXI slave bus handling
  ------------------------------------------------------------------------------
  prc_w_data:process
  begin
    wait until pi_reset  = '1' ;
    wait until pi_trg(0) = '1' ;
    
    -------------------------------------------------
    -------------------------------------------------
    -- both ready before awvalid
--     wait until rising_edge(daq_aclk);

    --s_axi_awready  <= '1' ;

    loop
      exit when s_axi_awvalid = '1' ;
      wait until rising_edge(pi_ibus.clk) ;
      wait for T_HOLD;
    end loop;

    s_axi_wready   <= '1' ;

    wait for 100 * DAQ_CLOCK_PERIOD ;
    wait until s_axi_wlast = '1';
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;
    -------------------------------------------------
    -- both ready after awvalid
    --s_axi_awready  <= '0' ;
    s_axi_wready   <= '0' ;
    wait until s_axi_awvalid = '1';
    wait for 100 * DAQ_CLOCK_PERIOD ;
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;
    --s_axi_awready  <= '1' ;
    s_axi_wready   <= '1' ;

    wait until s_axi_wlast = '1';
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;
    -------------------------------------------------
    -- both ready with the awvalid
    --s_axi_awready  <= '0' ;
    s_axi_wready   <= '0' ;
    wait until s_axi_awvalid = '1';
    --s_axi_awready  <= '1' ;
    s_axi_wready   <= '1' ;

    wait for 100 * DAQ_CLOCK_PERIOD ;
    wait until s_axi_wlast = '1';
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;

    --s_axi_awready  <= '0' ;
    s_axi_wready   <= '0' ;
    wait for 100 * DAQ_CLOCK_PERIOD ;
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;
    --s_axi_awready  <= '1' ;
    s_axi_wready   <= '1' ;

    wait until s_axi_wlast = '1';
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;


    --------------------------------------------------
    --------------------------------------------------
    wait until pi_trg(0) = '1';
    --s_axi_awready  <= '0' ;
    s_axi_wready   <= '0' ;
    wait for 500 * DAQ_CLOCK_PERIOD ;
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;
    --s_axi_awready  <= '0' ;
    s_axi_wready   <= '0' ;
    wait for 3000 * DAQ_CLOCK_PERIOD ;
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;
    --s_axi_awready  <= '1' ;
    s_axi_wready   <= '1' ;

    wait until pi_trg(0) = '1';
    s_axi_wready   <= '0' ;
    wait until s_axi_wvalid = '1';
    s_axi_wready   <= '1' ;
    loop
    wait for 160 * DAQ_CLOCK_PERIOD ;
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;
    --s_axi_awready  <= '0' ;
    s_axi_wready   <= '0' ;

    wait for 100 * DAQ_CLOCK_PERIOD ;
    wait until rising_edge(daq_aclk);
    wait for T_HOLD;
    --s_axi_awready  <= '1' ;
    s_axi_wready   <= '1' ;

    end loop;

    wait;
  end process;

  -- emulate AXI mux with DDRs. 
  prc_aw_data:process
  begin
    loop
      s_axi_awready  <= '0' ;
      if s_axi_awvalid = '1' then
        wait for 3 * DAQ_CLOCK_PERIOD ;
        wait until rising_edge(daq_aclk);
        wait for T_HOLD;
        s_axi_awready  <= '1' ;
        wait until rising_edge(daq_aclk);
        wait for T_HOLD;
      else
        wait until rising_edge(daq_aclk);
        wait for T_HOLD;
      end if;
    end loop;
  end process;


  -- record AXI stream data
  prs_daq_data_save: process (daq_aclk) is
  begin
    if rising_edge(daq_aclk) then
      if s_axi_wvalid = '1' and s_axi_wready='1' then
        daq_axi_wdata <= s_axi_wdata;
      end if;
    end if;
  end process;


  -- check AXI stream data counter in single channel
  prs_daq_data_check: process
    variable idx : natural := 0;
  begin

    -- wait until rising_edge(daq_aclk);
    -- wait for T_HOLD;
  end process;



  -- ------------------------------------------------------------------------------
  -- -- waveform generation
  -- ------------------------------------------------------------------------------
  -- -- WaveGen_Proc: process
  -- -- begin
  -- --   -- insert signal assignments here

  -- --   wait until Clk = '1';
  -- -- end process WaveGen_Proc;

  s_axi_awid(3 downto 0)        <= po_axi4_m2s_m.awid(3 downto 0)   ;
  s_axi_awaddr                  <= po_axi4_m2s_m.awaddr ;
  s_axi_awlen                   <= po_axi4_m2s_m.awlen  ;
  s_axi_awburst                 <= po_axi4_m2s_m.awburst;
  s_axi_awvalid                 <= po_axi4_m2s_m.awvalid;
  pi_axi4_s2m_m.awready         <= s_axi_awready;
  s_axi_wdata(G_AXI_DATA_WIDTH-1 downto 0) <= po_axi4_m2s_m.wdata(G_AXI_DATA_WIDTH-1 downto 0)  ;
  s_axi_wlast                   <= po_axi4_m2s_m.wlast  ;
  s_axi_wvalid                  <= po_axi4_m2s_m.wvalid ;
  pi_axi4_s2m_m.wready          <= s_axi_wready;
  pi_axi4_s2m_m.bid(3 downto 0) <= s_axi_bid(3 downto 0)    ;
  pi_axi4_s2m_m.bresp           <= s_axi_bresp  ;
  pi_axi4_s2m_m.bvalid          <= s_axi_bvalid ;
  s_axi_bready                  <= po_axi4_m2s_m.bready ;


end architecture arch;

------------------------------------------------------------------------------------------------------------------------

configuration daq_top_tb_arch_cfg of daq_top_tb is
  for arch
  end for;
end daq_top_tb_arch_cfg;

------------------------------------------------------------------------------------------------------------------------
