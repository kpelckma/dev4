--------------------------------------------------------------------------------
--          ____  _____________  __                                           --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                 --
--        / / / / __/  \__ \  \  /                 / \ / \ / \                --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=              --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/                --
--                                                                            --
--------------------------------------------------------------------------------
--! @copyright (c) 2023 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
--------------------------------------------------------------------------------
--! @date 2023-02-16
--! @author Burak Dursun <burak.dursun@desy.de>
--------------------------------------------------------------------------------
--! @brief Low Latency Link channel
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;
use desy.common_logic_utils.all;
use desy.common_bsp_ifs.all;
use desy.common_mgt.all;
use desy.bus_lll.all;

entity lll is
  generic (
    G_MGT_CLK_CNT     : natural := 1;
    G_MGT_CLK         : natural := 0;
    G_MGT_SHARED_CNT  : natural := 0;
    G_MGT_SHARED      : natural := 0;
    G_DATA_BYTE       : natural := 4
  );
  port (
    pi_clock    : in  std_logic;
    pi_reset    : in  std_logic;
    pi_control  : in  std_logic_vector(31 downto 0);
    po_status   : out std_logic_vector(31 downto 0);

    pi_mgt_rx_p : in  std_logic;
    pi_mgt_rx_n : in  std_logic;
    po_mgt_tx_p : out std_logic; 
    po_mgt_tx_n : out std_logic;

    pi_mgt_clk  : in  std_logic_vector(G_MGT_CLK_CNT-1 downto 0);

    pi_mgt_shared : in  t_mgt_shared_vector(G_MGT_SHARED_CNT-1 downto 0);
    po_mgt_shared : out t_mgt_shared;

    pi_m_axi4s_aclk     : in  std_logic;
    pi_m_axi4s_areset_n : in  std_logic;
    pi_m_axi4s          : in  t_axi4s_p2p_s2m;
    po_m_axi4s          : out t_axi4s_p2p_m2s;

    pi_s_axi4s_aclk     : in  std_logic;
    pi_s_axi4s_areset_n : in  std_logic;
    pi_s_axi4s          : in  t_axi4s_p2p_m2s;
    po_s_axi4s          : out t_axi4s_p2p_s2m
  );
end entity lll;

architecture ultrascale of lll is

  component mgt is
    port (
      gthrxp_in                           : in  std_logic_vector(0 downto 0);
      gthrxn_in                           : in  std_logic_vector(0 downto 0);
      gthtxp_out                          : out std_logic_vector(0 downto 0);
      gthtxn_out                          : out std_logic_vector(0 downto 0);
      gtrefclk_in                         : in  std_logic_vector(0 downto 0);
      qplloutrefclk_out                   : out std_logic_vector(0 downto 0);
      qplloutclk_out                      : out std_logic_vector(0 downto 0);
      drpclk_in                           : in  std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_srcclk_out         : out std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_usrclk_out         : out std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_usrclk2_out        : out std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_active_out         : out std_logic_vector(0 downto 0);
      gtwiz_userclk_rx_reset_in           : in  std_logic_vector(0 downto 0);
      gtwiz_userclk_tx_srcclk_out         : out std_logic_vector(0 downto 0);
      gtwiz_userclk_tx_usrclk_out         : out std_logic_vector(0 downto 0);
      gtwiz_userclk_tx_usrclk2_out        : out std_logic_vector(0 downto 0);
      gtwiz_userclk_tx_active_out         : out std_logic_vector(0 downto 0);
      gtwiz_userclk_tx_reset_in           : in  std_logic_vector(0 downto 0);
      gtwiz_reset_clk_freerun_in          : in  std_logic_vector(0 downto 0);
      gtwiz_reset_all_in                  : in  std_logic_vector(0 downto 0);
      gtwiz_reset_rx_datapath_in          : in  std_logic_vector(0 downto 0);
      gtwiz_reset_rx_pll_and_datapath_in  : in  std_logic_vector(0 downto 0);
      gtwiz_reset_rx_done_out             : out std_logic_vector(0 downto 0);
      gtwiz_reset_rx_cdr_stable_out       : out std_logic_vector(0 downto 0);
      gtwiz_reset_tx_datapath_in          : in  std_logic_vector(0 downto 0);
      gtwiz_reset_tx_pll_and_datapath_in  : in  std_logic_vector(0 downto 0);
      gtwiz_reset_tx_done_out             : out std_logic_vector(0 downto 0);
      rxpmaresetdone_out                  : out std_logic_vector(0 downto 0);
      txpmaresetdone_out                  : out std_logic_vector(0 downto 0);
      gtpowergood_out                     : out std_logic_vector(0 downto 0);
      rxclkcorcnt_out                     : out std_logic_vector(1 downto 0);
      rxbufreset_in                       : in  std_logic_vector(0 downto 0);
      rxbufstatus_out                     : out std_logic_vector(2 downto 0);
      rxcommadeten_in                     : in  std_logic_vector(0 downto 0);
      rxcommadet_out                      : out std_logic_vector(0 downto 0);
      rxpcommaalignen_in                  : in  std_logic_vector(0 downto 0);
      rxmcommaalignen_in                  : in  std_logic_vector(0 downto 0);
      rxbyterealign_out                   : out std_logic_vector(0 downto 0);
      rxbyteisaligned_out                 : out std_logic_vector(0 downto 0);
      rx8b10ben_in                        : in  std_logic_vector(0 downto 0);
      tx8b10ben_in                        : in  std_logic_vector(0 downto 0);
      loopback_in                         : in  std_logic_vector(2 downto 0);
      rxprbssel_in                        : in  std_logic_vector(3 downto 0);
      rxprbserr_out                       : out std_logic_vector(0 downto 0);
      rxprbscntreset_in                   : in  std_logic_vector(0 downto 0);
      rxprbslocked_out                    : out std_logic_vector(0 downto 0);
      txprbssel_in                        : in  std_logic_vector(3 downto 0);
      txprbsforceerr_in                   : in  std_logic_vector(0 downto 0);
      rxctrl0_out                         : out std_logic_vector(15 downto 0);
      rxctrl1_out                         : out std_logic_vector(15 downto 0);
      rxctrl2_out                         : out std_logic_vector(7 downto 0);
      rxctrl3_out                         : out std_logic_vector(7 downto 0);
      txctrl0_in                          : in  std_logic_vector(15 downto 0);
      txctrl1_in                          : in  std_logic_vector(15 downto 0);
      txctrl2_in                          : in  std_logic_vector(7 downto 0);
      gtwiz_userdata_rx_out               : out std_logic_vector;
      gtwiz_userdata_tx_in                : in  std_logic_vector
    );
  end component mgt;

  constant C_SYNC_FF          : natural := 2;
  constant C_RX_BUF_TIMEOUT   : natural := 12;
  constant C_RX_COMMA_TIMEOUT : natural := 10;
  constant C_TX_COMMA_TIMEOUT : natural := 8;

  signal reset              : std_logic;
  signal rx_areset          : std_logic;
  signal tx_areset          : std_logic;
  signal rx_reset           : std_logic;
  signal tx_reset           : std_logic;
  signal rx_clock           : std_logic;
  signal tx_clock           : std_logic;
  signal rx_ce              : std_logic;
  signal tx_ce              : std_logic;
  signal rx_pma_reset_done  : std_logic;
  signal tx_pma_reset_done  : std_logic;
  signal rx_reset_done      : std_logic;
  signal tx_reset_done      : std_logic;
  signal cdr_stable         : std_logic;
  signal power_good         : std_logic;
  signal loopback           : std_logic_vector(2 downto 0);
  signal rx_clkcor_cnt      : std_logic_vector(1 downto 0);
  signal rx_buf_reset       : std_logic;
  signal rx_buf_status      : std_logic_vector(2 downto 0);
  signal rx_comma_detected  : std_logic;
  signal rx_comma_align_en  : std_logic;
  signal rx_byte_is_aligned : std_logic;
  signal rx_prbs_sel        : std_logic_vector(3 downto 0);
  signal tx_prbs_sel        : std_logic_vector(3 downto 0);
  signal rx_prbs_err        : std_logic;
  signal tx_prbs_err        : std_logic;
  signal rx_prbs_rst        : std_logic;
  signal rx_prbs_lock       : std_logic;
  signal rx_align_err_cnt   : std_logic_vector(2 downto 0)  := (others => '0');
  signal rx_comma_err_cnt   : std_logic_vector(2 downto 0)  := (others => '0');
  signal rx_buf_err_cnt     : std_logic_vector(2 downto 0)  := (others => '0');
  signal rx_8b10b_err_cnt   : std_logic_vector(2 downto 0)  := (others => '0');
  signal rx_disp_err_cnt    : std_logic_vector(2 downto 0)  := (others => '0');
  signal rx_frame_err_cnt   : std_logic_vector(2 downto 0)  := (others => '0');
  signal rx_fifo_err_cnt    : std_logic_vector(2 downto 0)  := (others => '0');
  signal rx_ctrl            : t_8b_slv_vector(3 downto 0) := (others => (others => '0'));
  signal tx_ctrl            : t_8b_slv_vector(2 downto 0) := (others => (others => '0'));
  signal rx_data            : std_logic_vector(G_DATA_BYTE*8-1 downto 0);
  signal tx_data            : std_logic_vector(G_DATA_BYTE*8-1 downto 0);
  signal dummy              : t_8b_slv_vector(1 downto 0);

begin

  --! GTWizard IP wrapper instantiation
  ins_mgt: mgt
    port map (
      gthrxp_in(0)  => pi_mgt_rx_p,
      gthrxn_in(0)  => pi_mgt_rx_n,

      gthtxp_out(0) => po_mgt_tx_p,
      gthtxn_out(0) => po_mgt_tx_n,

      gtrefclk_in(0)    => pi_mgt_clk(G_MGT_CLK),
      qplloutrefclk_out => open,
      qplloutclk_out    => open,
      drpclk_in(0)      => pi_clock,

      gtwiz_userclk_rx_srcclk_out     => open,
      gtwiz_userclk_rx_usrclk_out     => open,
      gtwiz_userclk_rx_usrclk2_out(0) => rx_clock,
      gtwiz_userclk_rx_active_out(0)  => rx_ce,
      gtwiz_userclk_rx_reset_in(0)    => rx_areset,

      gtwiz_userclk_tx_srcclk_out     => open,
      gtwiz_userclk_tx_usrclk_out     => open,
      gtwiz_userclk_tx_usrclk2_out(0) => tx_clock,
      gtwiz_userclk_tx_active_out(0)  => tx_ce,
      gtwiz_userclk_tx_reset_in(0)    => tx_areset, 

      gtwiz_reset_clk_freerun_in(0)       => pi_clock,
      gtwiz_reset_all_in(0)               => reset,
      gtwiz_reset_rx_datapath_in          => (others => '0'),
      gtwiz_reset_rx_pll_and_datapath_in  => (others => '0'),
      gtwiz_reset_rx_done_out(0)          => rx_reset_done,
      gtwiz_reset_rx_cdr_stable_out(0)    => cdr_stable,
      gtwiz_reset_tx_datapath_in          => (others => '0'),
      gtwiz_reset_tx_pll_and_datapath_in  => (others => '0'),
      gtwiz_reset_tx_done_out(0)          => tx_reset_done,

      rxpmaresetdone_out(0)   => rx_pma_reset_done,
      txpmaresetdone_out(0)   => tx_pma_reset_done,
      gtpowergood_out(0)      => power_good,
      rxclkcorcnt_out         => rx_clkcor_cnt,
      rxbufreset_in(0)        => rx_buf_reset,
      rxbufstatus_out         => rx_buf_status,
      rxcommadeten_in         => (others => '1'),
      rxcommadet_out(0)       => rx_comma_detected,
      rxpcommaalignen_in(0)   => rx_comma_align_en,
      rxmcommaalignen_in(0)   => rx_comma_align_en,
      rxbyterealign_out       => open,
      rxbyteisaligned_out(0)  => rx_byte_is_aligned,
      rx8b10ben_in            => (others => '1'),
      tx8b10ben_in            => (others => '1'),
      loopback_in             => loopback,
      rxprbssel_in            => rx_prbs_sel,
      rxprbserr_out(0)        => rx_prbs_err,
      rxprbscntreset_in(0)    => rx_prbs_rst,
      rxprbslocked_out(0)     => rx_prbs_lock,
      txprbssel_in            => tx_prbs_sel,
      txprbsforceerr_in(0)    => tx_prbs_err,

      rxctrl0_out(15 downto 8)  => dummy(0),
      rxctrl0_out(7 downto 0)   => rx_ctrl(0),
      rxctrl1_out(15 downto 8)  => dummy(1),
      rxctrl1_out(7 downto 0)   => rx_ctrl(1),
      rxctrl2_out               => rx_ctrl(2),
      rxctrl3_out               => rx_ctrl(3),

      txctrl0_in(15 downto 8) => (others => '0'),
      txctrl0_in(7 downto 0)  => tx_ctrl(0),
      txctrl1_in(15 downto 8) => (others => '0'),
      txctrl1_in(7 downto 0)  => tx_ctrl(1),
      txctrl2_in              => tx_ctrl(2),

      gtwiz_userdata_rx_out => rx_data,
      gtwiz_userdata_tx_in  => tx_data
    );

  --! LLL supervisor
  blk_lsv: block
  begin

    --! CDC for control and status registers
    blk_cdc: block

      signal rx_control     : std_logic_vector(4 downto 0);
      signal rx_status      : std_logic_vector(28 downto 0);
      signal tx_control     : std_logic_vector(4 downto 0);
      signal tx_status      : std_logic_vector(0 downto 0);
      signal async_control  : std_logic_vector(3 downto 0);
      signal async_status   : std_logic_vector(1 downto 0);
      signal sync_status    : t_2b_slv_vector(C_SYNC_FF-1 downto 0);

      attribute ASYNC_REG : string;
      attribute ASYNC_REG of sync_status : signal is "TRUE";

    begin

      async_control <= pi_control(3 downto 0);

      sync_status <= sync_status(C_SYNC_FF-2 downto 0) & async_status when rising_edge(pi_clock);
      po_status(1 downto 0) <= sync_status(C_SYNC_FF-1);

      ins_tx_cdc: entity desy.cdc_bus(rtl)
        generic map (
          G_SYNC_FF_A => C_SYNC_FF,
          G_SYNC_FF_B => C_SYNC_FF,
          G_WIDTH_A2B => 5,
          G_WIDTH_B2A => 1
        )
        port map (
          pi_clock_a  => pi_clock,
          pi_reset_a  => pi_reset,
          pi_data_a2b => pi_control(8 downto 4),
          po_data_b2a => po_status(2 downto 2),

          pi_clock_b  => tx_clock,
          pi_reset_b  => tx_reset,
          po_data_a2b => tx_control,
          pi_data_b2a => tx_status
        );

      ins_rx_cdc: entity desy.cdc_bus(rtl)
        generic map (
          G_SYNC_FF_A => C_SYNC_FF,
          G_SYNC_FF_B => C_SYNC_FF,
          G_WIDTH_A2B => 5,
          G_WIDTH_B2A => 29
        )
        port map (
          pi_clock_a  => pi_clock,
          pi_reset_a  => pi_reset,
          pi_data_a2b => pi_control(13 downto 9),
          po_data_b2a => po_status(31 downto 3),

          pi_clock_b  => rx_clock,
          pi_reset_b  => rx_reset,
          po_data_a2b => rx_control,
          pi_data_b2a => rx_status
        );

      --! asynchronous control
      reset <= pi_reset or async_control(0);
      loopback <= async_control(3 downto 1);

      --! tx clock domain control
      tx_prbs_sel <= tx_control(3 downto 0);
      tx_prbs_err <= tx_control(4);

      --! rx clock domain control
      rx_prbs_sel <= rx_control(3 downto 0);
      rx_prbs_rst <= rx_control(4);

      --! asynchronous status
      async_status(0) <= cdr_stable;
      async_status(1) <= power_good;

      --! tx clock domain status
      tx_status(0) <= tx_reset_done;

      --! rx clock domain status
      rx_status(0) <= rx_reset_done;
      rx_status(2 downto 1) <= rx_clkcor_cnt;
      rx_status(5 downto 3) <= rx_buf_status;
      rx_status(6) <= rx_prbs_err;
      rx_status(7) <= rx_prbs_lock;
      rx_status(10 downto 8) <= rx_align_err_cnt;
      rx_status(13 downto 11) <= rx_comma_err_cnt;
      rx_status(16 downto 14) <= rx_buf_err_cnt;
      rx_status(19 downto 17) <= rx_8b10b_err_cnt;
      rx_status(22 downto 20) <= rx_disp_err_cnt;
      rx_status(25 downto 23) <= rx_frame_err_cnt;
      rx_status(28 downto 26) <= rx_fifo_err_cnt;

    end block blk_cdc;

    blk_rx: block

      signal rx_comma       : std_logic;
      signal rx_comma_timer : std_logic_vector(C_RX_COMMA_TIMEOUT+1 downto 0);
      signal rx_buf_error   : std_logic;
      signal rx_buf_timer   : std_logic_vector(C_RX_BUF_TIMEOUT+1 downto 0);
      signal rx_disp_err    : std_logic;
      signal rx_8b10b_err   : std_logic;
      signal rx_frame       : std_logic;
      signal rx_fifo_err    : std_logic;
      signal rx_fifo_full   : std_logic;
      signal rx_fifo_empty  : std_logic;
      signal rx_fifo_we     : std_logic;
      signal rx_fifo_re     : std_logic;
      signal rx_fifo_data   : std_logic_vector(35 downto 0);

    begin

      rx_areset <= not rx_pma_reset_done;

      prs_rx_reset: process(rx_clock, rx_areset)
      begin
        if rx_areset = '1' then
          rx_reset <= '1';  -- asynchronous assertion
        elsif rising_edge(rx_clock) then
          if rx_ce = '1' then
            rx_reset <= '0';  -- synchronous deassertion
          end if;
        end if;
      end process prs_rx_reset;

      prs_rx_align: process(rx_clock, rx_reset)
      begin
        if rx_reset = '1' then
          rx_comma_align_en <= '0';
        elsif rising_edge(rx_clock) then
          rx_comma_align_en <= not rx_byte_is_aligned;
        end if;
      end process prs_rx_align;

      prs_rx_comma: process(rx_clock, rx_reset)
      begin
        if rx_reset = '1' then
          rx_comma_timer <= (C_RX_COMMA_TIMEOUT => '1', others => '0');
          rx_comma <= '0';
        elsif rising_edge(rx_clock) then
          if or_reduce(rx_ctrl(2)(G_DATA_BYTE-1 downto 1)) = '0' and rx_ctrl(2)(0) = '1' then -- " rx_comma_detected = '1' then
            rx_comma_timer <= (C_RX_COMMA_TIMEOUT => '1', others => '0');
            rx_comma <= '1';
          elsif rx_comma_timer(C_RX_COMMA_TIMEOUT + 1) = '1' then
            rx_comma <= '0';
          else
            rx_comma_timer <= std_logic_vector(signed(rx_comma_timer) - 1);
          end if;
        end if;
      end process prs_rx_comma;

      with rx_buf_status select rx_buf_error <=
        '0' when "000",
        '0' when "001",
        '0' when "010",
        '1' when others;

      rx_buf_reset <= rx_buf_error or rx_buf_timer(C_RX_BUF_TIMEOUT + 1) when rising_edge(rx_clock);

      prs_rx_buf: process(rx_clock, rx_reset)
      begin
        if rx_reset = '1' then
          rx_buf_timer <= (C_RX_BUF_TIMEOUT => '1', others => '0');
        elsif rising_edge(rx_clock) then
          if rx_comma = '1' or rx_buf_timer(C_RX_BUF_TIMEOUT + 1) = '1' then
            rx_buf_timer <= (C_RX_BUF_TIMEOUT => '1', others => '0');
          else
            rx_buf_timer <= std_logic_vector(signed(rx_buf_timer) - 1);
          end if;
        end if;
      end process prs_rx_buf;

      prs_rx_err_cnt: process(rx_clock)
      begin
        if rising_edge(rx_clock) then
          if rx_ce = '1' then
            if rx_comma_align_en = '1' then
              rx_align_err_cnt <= std_logic_vector(signed(rx_align_err_cnt) + 1);
            end if;
            if rx_comma = '0' then
              rx_comma_err_cnt <= std_logic_vector(signed(rx_comma_err_cnt) + 1);
            end if;
            if rx_buf_reset = '1' then
              rx_buf_err_cnt <= std_logic_vector(signed(rx_buf_err_cnt) + 1);
            end if;
            if rx_8b10b_err = '1' then
              rx_8b10b_err_cnt <= std_logic_vector(signed(rx_8b10b_err_cnt) + 1);
            end if;
            if rx_disp_err = '1' then
              rx_disp_err_cnt <= std_logic_vector(signed(rx_disp_err_cnt) + 1);
            end if;
            if rx_frame = '0' then
              rx_frame_err_cnt <= std_logic_vector(signed(rx_frame_err_cnt) + 1);
            end if;
            if rx_fifo_err = '1' then
              rx_fifo_err_cnt <= std_logic_vector(signed(rx_fifo_err_cnt) + 1);
            end if;
          end if;
        end if;
      end process prs_rx_err_cnt;

      rx_disp_err <= or_reduce(rx_ctrl(1)(G_DATA_BYTE-1 downto 0));
      rx_8b10b_err <= or_reduce(rx_ctrl(3)(G_DATA_BYTE-1 downto 0));

      gen_rx_2byte: if G_DATA_BYTE = 2 generate
        signal l_frame  : std_logic;
      begin
        prs_rx_frame: process(rx_clock, rx_reset)
        begin
          if rx_reset = '1' then
            rx_fifo_data <= (others => '0');
            rx_fifo_err <= '0';
            rx_fifo_we <= '0';
            rx_frame <= '0';
            l_frame <= '0';
          elsif rising_edge(rx_clock) then
            rx_fifo_err <= '0';
            rx_fifo_we <= '0';
            if rx_comma = '0' then
              rx_frame <= '0';
              l_frame <= '0';
            elsif rx_ctrl(2)(1 downto 0) /= "01" then
              rx_fifo_data <= rx_fifo_data(17 downto 0) & rx_ctrl(0)(1 downto 0) & rx_data(15 downto 0);
              if rx_ctrl(0)(1 downto 0) = "10" then
                rx_frame <= '1';
                l_frame <= '1';
              else
                rx_fifo_err <= rx_fifo_full and l_frame;
                rx_fifo_we <= not rx_fifo_full and l_frame;
                l_frame <= not l_frame;
              end if; 
            end if;
          end if;
        end process prs_rx_frame;
      end generate gen_rx_2byte;

      gen_rx_4byte: if G_DATA_BYTE = 4 generate
        prs_rx_frame: process(rx_clock, rx_reset)
        begin
          if rx_reset = '1' then
            rx_fifo_data <= (others => '0');
            rx_fifo_err <= '0';
            rx_fifo_we <= '0';
            rx_frame <= '0';
          elsif rising_edge(rx_clock) then
            rx_fifo_err <= '0';
            rx_fifo_we <= '0';
            if rx_comma = '0' then
              rx_frame <= '0';
            elsif rx_ctrl(2)(3 downto 0) /= "0001" then
              rx_fifo_data(35 downto 34) <= rx_ctrl(0)(3 downto 2);
              rx_fifo_data(17 downto 16) <= rx_ctrl(0)(1 downto 0);
              rx_fifo_data(33 downto 18) <= rx_data(31 downto 16);
              rx_fifo_data(15 downto 0) <= rx_data(15 downto 0);
              rx_fifo_err <= rx_fifo_full;
              rx_fifo_we <= not rx_fifo_full;
              if rx_ctrl(0)(3 downto 0) = "1000" then
                rx_frame <= '1';
              end if; 
            end if;
          end if;
        end process prs_rx_frame;
      end generate gen_rx_4byte;

      ins_rx_fifo: entity desy.fifo_ultrascale(rtl) --! single FIFO18E2
        generic map (
          G_FIFO_LAYER_NUM  => 1,
          G_FIFO18_NUM      => 1,
          G_FIFO36_NUM      => 0,
          G_FIFO36_WIDTH    => 72,
          G_FIFO_WIDTH      => 36,
          G_FIFO_DEPTH      => 512,
          G_FIFO_FWFT       => 1
        )
        port map (
          pi_reset    => rx_reset,
          pi_int_clk  => rx_clock,

          pi_wr_clk     => rx_clock,
          po_full       => rx_fifo_full,
          po_prog_full  => open,
          pi_wr_ena     => rx_fifo_we,
          pi_data       => rx_fifo_data,

          pi_rd_clk             => pi_m_axi4s_aclk,
          po_empty              => rx_fifo_empty,
          po_prog_empty         => open,
          pi_rd_ena             => rx_fifo_re,
          po_data(35 downto 34) => po_m_axi4s.tuser(3 downto 2),
          po_data(17 downto 16) => po_m_axi4s.tuser(1 downto 0),
          po_data(33 downto 18) => po_m_axi4s.tdata(31 downto 16),
          po_data(15 downto 0)  => po_m_axi4s.tdata(15 downto 0)
        );

      rx_fifo_re <= not rx_fifo_empty and pi_m_axi4s.tready;
      po_m_axi4s.tvalid <= not rx_fifo_empty;

    end block blk_rx;

    blk_tx: block

      signal tx_comma       : std_logic;
      signal tx_comma_timer : std_logic_vector(C_TX_COMMA_TIMEOUT+1 downto 0);
      signal tx_frame       : std_logic;
      signal tx_fifo_full   : std_logic;
      signal tx_fifo_empty  : std_logic;
      signal tx_fifo_we     : std_logic;
      signal tx_fifo_re     : std_logic;
      signal tx_fifo_data   : std_logic_vector(35 downto 0);
      signal l_reset        : std_logic_vector(C_SYNC_FF-1 downto 0);

      attribute ASYNC_REG : string;
      attribute ASYNC_REG of l_reset  : signal is "TRUE";

    begin

      tx_areset <= not tx_pma_reset_done;

      prs_tx_reset: process(tx_clock, tx_areset)
      begin
        if tx_areset = '1' then
          tx_reset <= '1';  --! asynchronous assertion
        elsif rising_edge(tx_clock) then
          if tx_ce = '1' then
            tx_reset <= '0';  --! synchronous deassertion
          end if;
        end if;
      end process prs_tx_reset;

      prs_tx_comma: process(tx_clock, tx_reset)
      begin
        if tx_reset = '1' then
          tx_comma_timer <= (C_TX_COMMA_TIMEOUT => '1', others => '0');
        elsif rising_edge(tx_clock) then
          if tx_fifo_empty = '1' or ((tx_comma_timer(C_TX_COMMA_TIMEOUT + 1) = '1') and (tx_comma_timer(2) = '0')) then
            tx_comma_timer <= (C_TX_COMMA_TIMEOUT => '1', others => '0');
          else
            tx_comma_timer <= std_logic_vector(signed(tx_comma_timer) - 1);
          end if;
        end if;
      end process prs_tx_comma;

      tx_comma <= tx_fifo_empty or tx_comma_timer(C_TX_COMMA_TIMEOUT + 1);

      tx_fifo_re <= not tx_comma and not tx_frame;

      --! reset syncrhonization to the write clock domain
      l_reset <= tx_reset & l_reset(C_SYNC_FF-1 downto 1) when rising_edge(pi_s_axi4s_aclk);

      ins_tx_fifo: entity desy.fifo_ultrascale(rtl) --! single FIFO18E2
        generic map (
          G_FIFO_LAYER_NUM  => 1,
          G_FIFO18_NUM      => 1,
          G_FIFO36_NUM      => 0,
          G_FIFO36_WIDTH    => 72,
          G_FIFO_WIDTH      => 36,
          G_FIFO_DEPTH      => 512,
          G_FIFO_FWFT       => 1
        )
        port map (
          pi_reset    => l_reset(0),
          pi_int_clk  => tx_clock,

          pi_wr_clk     => pi_s_axi4s_aclk,
          po_full       => tx_fifo_full,
          po_prog_full  => open,
          pi_wr_ena     => tx_fifo_we,
          pi_data(35 downto 34) => pi_s_axi4s.tuser(3 downto 2),
          pi_data(17 downto 16) => pi_s_axi4s.tuser(1 downto 0),
          pi_data(33 downto 18) => pi_s_axi4s.tdata(31 downto 16),
          pi_data(15 downto 0)  => pi_s_axi4s.tdata(15 downto 0),

          pi_rd_clk     => tx_clock,
          po_empty      => tx_fifo_empty,
          po_prog_empty => open,
          pi_rd_ena     => tx_fifo_re,
          po_data       => tx_fifo_data
        );

      tx_fifo_we <= not tx_fifo_full and pi_s_axi4s.tvalid;
      po_s_axi4s.tready <= not tx_fifo_full;

      gen_tx_2byte: if G_DATA_BYTE = 2 generate

        signal tx_ctrl_buf  : std_logic_vector(1 downto 0);
        signal tx_data_buf  : std_logic_vector(15 downto 0);

      begin

        --! TODO: Add different write/read port width support to desy.fifo_ultrascale(rtl)
        prs_tx_frame: process(tx_clock, tx_reset)
        begin
          if tx_reset = '1' then
            tx_frame <= '1';
          elsif rising_edge(tx_clock) then
            tx_frame <= tx_fifo_re or (tx_frame and tx_comma);
          end if;
        end process prs_tx_frame;

        tx_ctrl_buf <= tx_fifo_data(35 downto 34) when tx_frame = '1' else tx_fifo_data(17 downto 16);
        tx_ctrl(2)(1 downto 0) <= "01" when tx_comma = '1' else tx_ctrl_buf;
        tx_data_buf <= tx_fifo_data(33 downto 18) when tx_frame = '1' else tx_fifo_data(15 downto 0);
        tx_data(15 downto 0) <= x"00BC" when tx_comma = '1' else tx_data_buf;

      end generate gen_tx_2byte;

      gen_tx_4byte: if G_DATA_BYTE = 4 generate
        tx_frame <= '0';
        tx_ctrl(2)(3 downto 0) <= "0001" when tx_comma = '1' else tx_fifo_data(35 downto 34) & tx_fifo_data(17 downto 16);
        tx_data <= x"000000BC" when tx_comma = '1' else tx_fifo_data(33 downto 18) & tx_fifo_data(15 downto 0);
      end generate gen_tx_4byte;

    end block blk_tx;

  end block blk_lsv;

end architecture ultrascale;

architecture series7 of lll is
begin
  -- ins_mgt
  -- blk_lsv
end architecture series7;
