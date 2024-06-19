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
--! @author Cagil Gumus  <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! CDC Happens here
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library desy;
use desy.math_basic.all;
use desy.common_axi.all;

entity daq_to_axi is
  generic (
    G_ARCH_TYPE      : string := "GENERIC" ;
    G_AXI_ID         : std_logic_vector(3 downto 0) := "0000";
    G_AXI_DATA_WIDTH : natural := 256;  --! Width of the Data Bus (bits) (effects Burst Size)
    G_AXI_ADDR_WIDTH : natural := 32;   --! Width of the Address Bus (bits) This is fixed
    G_AXI_BURST_LEN  : natural := 64;   --! # of beats on each burst
    G_FIFO_DEPTH     : natural := 512;  --! Make sure FIFO can hold 2 bursts at a time
    G_FIFO_FWFT      : natural := 1
  );
  port (
    pi_clock           : in  std_logic :='0'; --! DAQ Clock
    pi_reset           : in  std_logic :='0'; --! Reset coming from DDRs
    pi_data            : in  std_logic_vector(G_AXI_DATA_WIDTH-1 downto 0) := (others => '0'); --! Input Data Port
    pi_data_str        : in  std_logic:='0'; --! Strobe Input for Data
    pi_addr            : in  std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0) := (others => '0'); --! Input Address Port
    pi_addr_str        : in  std_logic:='0'; --! Strobe Input for Address
    pi_last            : in  std_logic:='0'; --! Last Data indicator

    pi_m_axi4_aclk     : in std_logic;
    pi_m_axi4_areset_n : in std_logic;
    pi_m_axi4          : in  T_AXI4_S2M;
    po_m_axi4          : out T_AXI4_M2S;

    po_fifo_status     : out std_logic;  --! Flag to indicate the statuses of FIFO (used in Burst Generator)
    po_sent_burst_cnt  : out std_logic_vector(31 downto 0) := (others => '0');
    po_w_fifo_status   : out std_logic_vector(31 downto 0) := (others => '0');
    po_debug           : out std_logic_vector(255 downto 0)
  );
end entity;

architecture arch of daq_to_axi is

  -- Function Declarations

  --! the address FIFO depth covers exact amount of addresses equivalent to full data FIFO
  --! its depth cannot be smaller then 16x
  function f_set_a_fifo_depth return natural is
    variable v_depth : natural := 0;
  begin  -- function f_set_a_fifo_depth
    v_depth := G_FIFO_DEPTH / G_AXI_BURST_LEN;
    if v_depth < 16 then
      return 16;
    else
      return v_depth;
    end if;
  end function f_set_a_fifo_depth;

  function f_almost_empty_flag return natural is
  begin
    if G_AXI_BURST_LEN <= 8 then
      return 0; --! When burst len is less then 8 we cant use almost empty flag 
                --! However we still need to give a valid flag
    else
      return G_AXI_BURST_LEN-3+G_FIFO_FWFT;
    end if;
  end function f_almost_empty_flag;
  
  function f_almost_full_flag return natural is
  begin
    if G_AXI_BURST_LEN <= 8 then
      return 0; --! When burst len is less then 8 we cant use almost empty flag 
                --! However we still need to give a valid flag
    else
      return G_FIFO_DEPTH-G_AXI_BURST_LEN-2;
    end if;
  end function f_almost_full_flag;

  -- Constants
  constant C_A_FIFO_DEPTH        : natural := f_set_a_fifo_depth;
  constant C_W_FIFO_WIDTH        : natural := G_AXI_DATA_WIDTH + 32; -- Data width + WLAST (WSTRB not needed)
  constant C_BURST_SIZE          : natural := log2(G_AXI_DATA_WIDTH / 8); --! Burst size is in bytes
  constant C_WSTRB_WIDTH         : natural := G_AXI_DATA_WIDTH / 8;                                         
  constant C_W_ALMOST_EMPTY_FLAG : natural := f_almost_empty_flag;
  constant C_W_ALMOST_FULL_FLAG  : natural := f_almost_full_flag;

  -- Global Signals
  signal reset : std_logic;  --! Main Reset used in this entity
  signal fifo_reset : std_logic; -- Reset for the FIFOs

  signal R_M2S_M : T_AXI4_M2S := C_AXI4_M2S_DEFAULT;
  signal R_S2M_M : T_AXI4_S2M := C_AXI4_S2M_DEFAULT;

  -- Write Related Signals
  signal data             : std_logic_vector(pi_data'length-1 downto 0) := (others => '0');
  signal write_addr_start : std_logic := '0'; --! Start flag for address write process(Also indicates start of the burst)
  signal bready           : std_logic := '0'; --! Write Response Ready Flag

  -- FIFO Related Signals
  signal aw_fifo_empty : std_logic := '0'; --! Address FIFO Empty Flag
  signal aw_fifo_full  : std_logic := '0'; --! Address FIFO Full Flag
  signal aw_data_i     : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0) := (others => '0'); --! Input to Address FIFO
  signal aw_data_o     : std_logic_vector(G_AXI_ADDR_WIDTH-1 downto 0) := (others => '0'); --! Output from Address FIFO
  signal aw_rd_ena     : std_logic := '0'; --! Address FIFO Read Enable
  signal aw_wr_ena     : std_logic := '0'; --! Address FIFO Write Enable

  signal w_fifo_empty : std_logic := '0'; --! Data FIFO Empty Flag
  signal w_fifo_full  : std_logic := '0'; --! Data FIFO Full Flag
  signal w_data_i     : std_logic_vector(C_W_FIFO_WIDTH-1 downto 0) := (others => '0'); --! Input to Data FIFO
  signal w_data_o     : std_logic_vector(C_W_FIFO_WIDTH-1 downto 0) := (others => '0'); --! Output from Data FIFO
  signal w_rd_ena     : std_logic := '0'; --! Data FIFO Read Enable
  signal w_wr_ena     : std_logic := '0'; --! Data FIFO Write Enable
  signal wlast        : std_logic := '0'; --! Last transfer in a write burst
  
  signal w_fifo_almost_empty : std_logic := '0'; --! Data FIFO Almost Empty
  signal w_fifo_almost_full  : std_logic := '0'; --! Data FIFO Almost Full
  signal burst_data_in_fifo  : std_logic := '0'; --! Flag to indicate there is burst in Data FIFO

  -- Status counter
  signal sent_burst_cnt  : unsigned(31 downto 0);
  signal w_fifo_full_cnt : unsigned(31 downto 0);

begin
  
  --========================--
  -- Global signals
  --========================--
  reset <= pi_reset;
  fifo_reset <= pi_reset or (not pi_m_axi4_areset_n);

  po_m_axi4 <= R_M2S_M;
  R_S2M_M   <= pi_m_axi4;

  po_fifo_status    <= aw_fifo_full or w_fifo_almost_full;  --! Tell the burst generator to stop counting when fifos are full
  po_sent_burst_cnt <= std_logic_vector(sent_burst_cnt) when rising_edge(pi_clock); --! Synchronizing to the pi_clock domain
  po_w_fifo_status  <= std_logic_vector(w_fifo_full_cnt);
  
  --========================--
  -- Write Address Channel----
  --========================--
  R_M2S_M.AWID(3 downto 0) <= G_AXI_ID;
  R_M2S_M.AWSIZE           <= std_logic_vector(to_unsigned(C_BURST_SIZE, 3));
  R_M2S_M.AWBURST          <= "01";   --AXI4_BURST_INCR;
  R_M2S_M.AWLEN            <= std_logic_vector(to_unsigned(G_AXI_BURST_LEN - 1, 8));
  R_M2S_M.AWADDR           <= aw_data_o(31 downto 0);  
  aw_data_i                <= pi_addr;
  aw_wr_ena                <= pi_addr_str and not aw_fifo_full;

  gen_aw_fifo_std: if G_FIFO_FWFT = 0 generate

    aw_rd_ena <= not aw_fifo_empty and (not R_M2S_M.AWVALID or (R_M2S_M.AWVALID and R_S2M_M.AWREADY));

    prs_awvalid: process(pi_m_axi4_aclk)
    begin
      if rising_edge(pi_m_axi4_aclk) then
        if pi_m_axi4_areset_n = '0' then
          R_M2S_M.AWVALID <= '0';
        else
          if aw_rd_ena = '1' then
            R_M2S_M.AWVALID <= '1';
          elsif R_S2M_M.AWREADY = '1' then
            R_M2S_M.AWVALID <= '0';
          end if;
        end if;
      end if;
    end process prs_awvalid;   

  end generate gen_aw_fifo_std;

  gen_aw_fifo_fwft: if G_FIFO_FWFT = 1 generate
    R_M2S_M.AWVALID <= not aw_fifo_empty;
    aw_rd_ena       <= R_S2M_M.AWREADY and R_M2S_M.AWVALID;
  end generate gen_aw_fifo_fwft;

  ins_aw_fifo: entity desy.fifo
  generic map (
    G_FIFO_DEPTH               => C_A_FIFO_DEPTH, --! fifo needs to be at least 5 elements long and must be power of 2!
    G_FIFO_WIDTH               => G_AXI_ADDR_WIDTH,
    G_FIFO_READ_WIDTH          => G_AXI_ADDR_WIDTH,
    G_FIFO_WRITE_WIDTH         => G_AXI_ADDR_WIDTH,
    G_FIFO_TYPE                => G_ARCH_TYPE,
    G_FIFO_FWFT                => G_FIFO_FWFT,
    G_FIFO_PROG_FULL_OFFSET    => 0,--! not needed
    G_FIFO_PROG_EMPTY_OFFSET   => 0 --! not needed
  )
  port map (
    pi_reset      => fifo_reset, -- async reset
    pi_int_clk    => pi_m_axi4_aclk,
    pi_wr_clk     => pi_clock,
    pi_wr_ena     => aw_wr_ena,
    pi_data       => aw_data_i,
    po_full       => aw_fifo_full,
    po_prog_full  => open, --! no need to use this port
    pi_rd_clk     => pi_m_axi4_aclk,
    pi_rd_ena     => aw_rd_ena,
    po_data       => aw_data_o,
    po_empty      => aw_fifo_empty,
    po_prog_empty => open
  );

  --========================--
  -- Write Data Channel----
  --========================--
  w_wr_ena  <= pi_data_str and not w_fifo_full; --! Enable write only when data fifo not full

  w_data_i(G_AXI_DATA_WIDTH)              <= pi_last;
  w_data_i(G_AXI_DATA_WIDTH-1 downto 0)   <= pi_data ;

  R_M2S_M.WLAST                               <= w_data_o(G_AXI_DATA_WIDTH);
  R_M2S_M.WDATA(G_AXI_DATA_WIDTH-1 downto 0)  <= w_data_o(G_AXI_DATA_WIDTH-1 downto 0);
  R_M2S_M.WSTRB(C_WSTRB_WIDTH-1 downto 0)     <= ( others => '1' ) ;

  gen_w_fifo_std: if G_FIFO_FWFT = 0 generate

    w_rd_ena <= not w_fifo_empty and burst_data_in_fifo and (not R_M2S_M.WVALID or (R_M2S_M.WVALID and R_S2M_M.WREADY));

    prs_wvalid: process(pi_m_axi4_aclk)
    begin
      if rising_edge(pi_m_axi4_aclk) then
        if pi_m_axi4_areset_n = '0' then
          R_M2S_M.WVALID <= '0';
        else
          if w_rd_ena = '1' then
            R_M2S_M.WVALID <= '1';
          elsif R_S2M_M.WREADY = '1' then
            R_M2S_M.WVALID <= '0';
          end if;
        end if;
      end if;
    end process prs_wvalid;   

  end generate gen_w_fifo_std;

  gen_w_fifo_fwft: if G_FIFO_FWFT = 1 generate
    R_M2S_M.WVALID  <= not w_fifo_empty and burst_data_in_fifo;
    w_rd_ena        <= R_S2M_M.WREADY and R_M2S_M.WVALID;
  end generate gen_w_fifo_fwft;

  ins_w_fifo: entity desy.fifo
  generic map (
    G_FIFO_DEPTH             => G_FIFO_DEPTH,
    G_FIFO_WIDTH             => C_W_FIFO_WIDTH,
    G_FIFO_READ_WIDTH        => C_W_FIFO_WIDTH,
    G_FIFO_WRITE_WIDTH       => C_W_FIFO_WIDTH,
    G_FIFO_TYPE              => G_ARCH_TYPE,
    G_FIFO_FWFT              => G_FIFO_FWFT,
    G_FIFO_PROG_FULL_OFFSET  => C_W_ALMOST_FULL_FLAG,--! give almost full flag when fifo
    G_FIFO_PROG_EMPTY_OFFSET => C_W_ALMOST_EMPTY_FLAG --! flag is high when there is 1 burst inside fifo
  )
  port map (
    pi_reset      => fifo_reset, -- Accepts async reset on FIFOs,
    pi_int_clk    => pi_m_axi4_aclk,
    pi_wr_clk     => pi_clock ,
    pi_wr_ena     => w_wr_ena,
    pi_data       => w_data_i,
    po_full       => w_fifo_full,
    po_prog_full  => w_fifo_almost_full,
    pi_rd_clk     => pi_m_axi4_aclk,
    pi_rd_ena     => w_rd_ena,
    po_data       => w_data_o,
    po_empty      => w_fifo_empty,
    po_prog_empty => w_fifo_almost_empty
  );
  
  gen_burst_len0 : if G_AXI_BURST_LEN > 8 generate
    process(pi_m_axi4_aclk)
    begin
      if rising_edge(pi_m_axi4_aclk) then
        if pi_m_axi4_areset_n = '0' then
          burst_data_in_fifo <= '0';
          sent_burst_cnt <= (others => '0');
        else 
          if w_fifo_almost_empty = '0'  then
            burst_data_in_fifo <= '1';
          elsif R_M2S_M.WLAST = '1' and R_S2M_M.WREADY = '1' then
            burst_data_in_fifo <= '0';
            sent_burst_cnt <= sent_burst_cnt + 1;
          end if;
        end if;
      end if;
    end process;
  end generate;
  
  gen_burst_len1 : if G_AXI_BURST_LEN <= 8 generate
    process(pi_m_axi4_aclk)
    begin
      if rising_edge(pi_m_axi4_aclk) then
        if pi_m_axi4_areset_n = '0' then
          burst_data_in_fifo <= '0';
          sent_burst_cnt <= (others => '0');
        else 
          burst_data_in_fifo <= '1';
          sent_burst_cnt <= sent_burst_cnt + 1;
        end if;
      end if;
    end process;
  end generate;

  -- Counting when Data FIFO gets ALMOST full (it will never be full since we are preventing this on burst generation)
  proc_w_fifo_status: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if reset = '1' then
        w_fifo_full_cnt <= (others => '0');
      else
        if w_fifo_almost_full = '1' or aw_fifo_full = '1' then
          w_fifo_full_cnt <= w_fifo_full_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  ----========================--
  ---- Write Response Channel----
  ----========================--
  -- TODO: count errors
  -- accept all responses
  R_M2S_M.BREADY <= '1';

  --========================--
  -- Read Channel Channel----
  --========================--

  --========================--
  -- Read Address Channel----
  --========================--

end arch;
