------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2020-2022 DESY
--! SPDX-License-Identifier: Apache-2.0
------------------------------------------------------------------------------
--! @date 2020-05-25/2021-10-12
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Michael Büchler <michael.buechler@desy.de>
------------------------------------------------------------------------------
--! @brief
--! ax4-lite address decoder for DesyRdl
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desyrdl;
use desyrdl.common.all;

entity spi_ad9510_decoder_axi4l is
  generic (
    G_ADDR_WIDTH    : integer := 32;
    G_DATA_WIDTH    : integer := 32
  );
  port (
    pi_clock  : in std_logic;
    pi_reset  : in std_logic;
    --
    po_reg_rd_stb  : out std_logic_vector(91-1 downto 0);
    po_reg_wr_stb  : out std_logic_vector(91-1 downto 0);
    po_reg_data    : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    pi_reg_data    : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    --
    --
    --
    --
    pi_s_reset : in std_logic;
    pi_s_top   : in  t_axi4l_m2s ;
    po_s_top   : out t_axi4l_s2m
);
end entity spi_ad9510_decoder_axi4l;

architecture arch of spi_ad9510_decoder_axi4l is

  type t_target is (REG,  NONE );

  signal rtarget, wtarget  : t_target := NONE;

  -- Standard  statements

-- INLINE statement with -- #
  ----------------------------------------------------------
  -- read
  type t_state_read is (
    ST_READ_IDLE,
    ST_READ_SELECT,
    ST_READ_VALID,
    ST_READ_REG_BUSY, -- when no address hit, dummy reg
    ST_READ_DONE
  );
  signal state_read : t_state_read;

  signal rdata_reg : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal rdata_rgf : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal rdata_mem : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal rdata_ext : std_logic_vector(G_DATA_WIDTH-1 downto 0);

  signal rdata     : std_logic_vector(G_DATA_WIDTH-1 downto 0) := (others => '0');
  signal raddr     : std_logic_vector(G_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal raddr_int : integer;

  ----------------------------------------------------------
  -- write
  type t_state_write is (
    ST_WRITE_IDLE,
    ST_WRITE_WAIT_DATA,
    ST_WRITE_WAIT_ADDR,
    ST_WRITE_SELECT,
    ST_WRITE_RESP
  );
  signal state_write : t_state_write;

  signal wdata     : std_logic_vector(G_DATA_WIDTH-1 downto 0) := (others => '0');
  signal wstrb     : std_logic_vector(G_DATA_WIDTH/8-1 downto 0) := (others => '0');
  signal waddr     : std_logic_vector(G_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal waddr_int : integer;

  -----------------------------------------------------------
  signal reg_rd_stb  : std_logic_vector(91-1 downto 0) := (others => '0');
  signal reg_wr_stb  : std_logic_vector(91-1 downto 0) := (others => '0');

  -- external bus

  constant read_timeout  : natural := 8191;
  constant write_timeout : natural := 8191;
  signal read_time_cnt   : natural := 0;
  signal write_time_cnt  : natural := 0;
  signal invalid_rdata   : std_logic ;

  signal reset : std_logic;
begin

  -- main reset - global or bus reset
  reset <= pi_reset or pi_s_reset;

  -- ===========================================================================
  -- ### read logic
  ------------------------------------------------------------------------------
  -- read channel state machine
  ------------------------------------------------------------------------------
  prs_state_read: process (pi_clock)
  begin
    if rising_edge(pi_clock) then
      if reset = '1' then
        state_read <= ST_READ_IDLE;
        invalid_rdata <= '0';
      else
        case state_read is
          when ST_READ_IDLE =>

            if pi_s_top.arvalid = '1' then
              state_read <= ST_READ_SELECT;
            end if;
            invalid_rdata <= '0';
          when ST_READ_SELECT =>
            case rtarget is
              when REG =>
                state_read <= ST_READ_VALID;
              when others =>
                state_read <= ST_READ_REG_BUSY;
            end case;

          when ST_READ_REG_BUSY =>
            state_read <= ST_READ_VALID;

          when ST_READ_VALID =>
            if pi_s_top.rready = '1' then
              state_read <= ST_READ_DONE;
            end if;

          when ST_READ_DONE =>
              state_read <= ST_READ_IDLE;

          when others =>
            state_read <= ST_READ_IDLE;

        end case;

      end if;
    end if;
  end process;
  po_s_top.rresp <= "00";
  ------------------------------------------------------------------------------
  -- read data mux
  prs_rdata_mux: process(rtarget,rdata_reg,invalid_rdata)
  begin
    if invalid_rdata = '1' then
      po_s_top.rdata <= (others => '0' ) ;
    elsif rtarget = REG then
      po_s_top.rdata <= rdata_reg ;
    else
      po_s_top.rdata <= (others => '0' ) ;
    end if;
  end process prs_rdata_mux;

  ------------------------------------------------------------------------------
  -- ARREADY flag handling
  prs_axi_arready: process (state_read)
  begin
    case state_read is
      when ST_READ_IDLE =>
        po_s_top.arready <= '1';
      when others =>
        po_s_top.arready <= '0';
    end case;
  end process;

  -- RVALID flag handling
  prs_axi_rvalid: process (
      state_read)
  begin
    case state_read is
      when ST_READ_VALID =>
        po_s_top.rvalid <= '1';
      when others =>
        po_s_top.rvalid <= '0';
    end case;
  end process;

  ------------------------------------------------------------------------------
  -- Address decoder
  ------------------------------------------------------------------------------
  raddr_int <= to_integer(unsigned(pi_s_top.araddr(G_ADDR_WIDTH-1 downto 0)));

  prs_raddr_decoder: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if state_read = ST_READ_IDLE and pi_s_top.arvalid = '1' then
        reg_rd_stb <= (others => '0');
        case raddr_int is
          when 0 =>
             rtarget  <= REG;
             reg_rd_stb(0) <= '1';
          when 4 =>
             rtarget  <= REG;
             reg_rd_stb(1) <= '1';
          when 8 =>
             rtarget  <= REG;
             reg_rd_stb(2) <= '1';
          when 12 =>
             rtarget  <= REG;
             reg_rd_stb(3) <= '1';
          when 16 =>
             rtarget  <= REG;
             reg_rd_stb(4) <= '1';
          when 20 =>
             rtarget  <= REG;
             reg_rd_stb(5) <= '1';
          when 24 =>
             rtarget  <= REG;
             reg_rd_stb(6) <= '1';
          when 28 =>
             rtarget  <= REG;
             reg_rd_stb(7) <= '1';
          when 32 =>
             rtarget  <= REG;
             reg_rd_stb(8) <= '1';
          when 36 =>
             rtarget  <= REG;
             reg_rd_stb(9) <= '1';
          when 40 =>
             rtarget  <= REG;
             reg_rd_stb(10) <= '1';
          when 44 =>
             rtarget  <= REG;
             reg_rd_stb(11) <= '1';
          when 48 =>
             rtarget  <= REG;
             reg_rd_stb(12) <= '1';
          when 52 =>
             rtarget  <= REG;
             reg_rd_stb(13) <= '1';
          when 56 =>
             rtarget  <= REG;
             reg_rd_stb(14) <= '1';
          when 60 =>
             rtarget  <= REG;
             reg_rd_stb(15) <= '1';
          when 64 =>
             rtarget  <= REG;
             reg_rd_stb(16) <= '1';
          when 68 =>
             rtarget  <= REG;
             reg_rd_stb(17) <= '1';
          when 72 =>
             rtarget  <= REG;
             reg_rd_stb(18) <= '1';
          when 76 =>
             rtarget  <= REG;
             reg_rd_stb(19) <= '1';
          when 80 =>
             rtarget  <= REG;
             reg_rd_stb(20) <= '1';
          when 84 =>
             rtarget  <= REG;
             reg_rd_stb(21) <= '1';
          when 88 =>
             rtarget  <= REG;
             reg_rd_stb(22) <= '1';
          when 92 =>
             rtarget  <= REG;
             reg_rd_stb(23) <= '1';
          when 96 =>
             rtarget  <= REG;
             reg_rd_stb(24) <= '1';
          when 100 =>
             rtarget  <= REG;
             reg_rd_stb(25) <= '1';
          when 104 =>
             rtarget  <= REG;
             reg_rd_stb(26) <= '1';
          when 108 =>
             rtarget  <= REG;
             reg_rd_stb(27) <= '1';
          when 112 =>
             rtarget  <= REG;
             reg_rd_stb(28) <= '1';
          when 116 =>
             rtarget  <= REG;
             reg_rd_stb(29) <= '1';
          when 120 =>
             rtarget  <= REG;
             reg_rd_stb(30) <= '1';
          when 124 =>
             rtarget  <= REG;
             reg_rd_stb(31) <= '1';
          when 128 =>
             rtarget  <= REG;
             reg_rd_stb(32) <= '1';
          when 132 =>
             rtarget  <= REG;
             reg_rd_stb(33) <= '1';
          when 136 =>
             rtarget  <= REG;
             reg_rd_stb(34) <= '1';
          when 140 =>
             rtarget  <= REG;
             reg_rd_stb(35) <= '1';
          when 144 =>
             rtarget  <= REG;
             reg_rd_stb(36) <= '1';
          when 148 =>
             rtarget  <= REG;
             reg_rd_stb(37) <= '1';
          when 152 =>
             rtarget  <= REG;
             reg_rd_stb(38) <= '1';
          when 156 =>
             rtarget  <= REG;
             reg_rd_stb(39) <= '1';
          when 160 =>
             rtarget  <= REG;
             reg_rd_stb(40) <= '1';
          when 164 =>
             rtarget  <= REG;
             reg_rd_stb(41) <= '1';
          when 168 =>
             rtarget  <= REG;
             reg_rd_stb(42) <= '1';
          when 172 =>
             rtarget  <= REG;
             reg_rd_stb(43) <= '1';
          when 176 =>
             rtarget  <= REG;
             reg_rd_stb(44) <= '1';
          when 180 =>
             rtarget  <= REG;
             reg_rd_stb(45) <= '1';
          when 184 =>
             rtarget  <= REG;
             reg_rd_stb(46) <= '1';
          when 188 =>
             rtarget  <= REG;
             reg_rd_stb(47) <= '1';
          when 192 =>
             rtarget  <= REG;
             reg_rd_stb(48) <= '1';
          when 196 =>
             rtarget  <= REG;
             reg_rd_stb(49) <= '1';
          when 200 =>
             rtarget  <= REG;
             reg_rd_stb(50) <= '1';
          when 204 =>
             rtarget  <= REG;
             reg_rd_stb(51) <= '1';
          when 208 =>
             rtarget  <= REG;
             reg_rd_stb(52) <= '1';
          when 212 =>
             rtarget  <= REG;
             reg_rd_stb(53) <= '1';
          when 216 =>
             rtarget  <= REG;
             reg_rd_stb(54) <= '1';
          when 220 =>
             rtarget  <= REG;
             reg_rd_stb(55) <= '1';
          when 224 =>
             rtarget  <= REG;
             reg_rd_stb(56) <= '1';
          when 228 =>
             rtarget  <= REG;
             reg_rd_stb(57) <= '1';
          when 232 =>
             rtarget  <= REG;
             reg_rd_stb(58) <= '1';
          when 236 =>
             rtarget  <= REG;
             reg_rd_stb(59) <= '1';
          when 240 =>
             rtarget  <= REG;
             reg_rd_stb(60) <= '1';
          when 244 =>
             rtarget  <= REG;
             reg_rd_stb(61) <= '1';
          when 248 =>
             rtarget  <= REG;
             reg_rd_stb(62) <= '1';
          when 252 =>
             rtarget  <= REG;
             reg_rd_stb(63) <= '1';
          when 256 =>
             rtarget  <= REG;
             reg_rd_stb(64) <= '1';
          when 260 =>
             rtarget  <= REG;
             reg_rd_stb(65) <= '1';
          when 264 =>
             rtarget  <= REG;
             reg_rd_stb(66) <= '1';
          when 268 =>
             rtarget  <= REG;
             reg_rd_stb(67) <= '1';
          when 272 =>
             rtarget  <= REG;
             reg_rd_stb(68) <= '1';
          when 276 =>
             rtarget  <= REG;
             reg_rd_stb(69) <= '1';
          when 280 =>
             rtarget  <= REG;
             reg_rd_stb(70) <= '1';
          when 284 =>
             rtarget  <= REG;
             reg_rd_stb(71) <= '1';
          when 288 =>
             rtarget  <= REG;
             reg_rd_stb(72) <= '1';
          when 292 =>
             rtarget  <= REG;
             reg_rd_stb(73) <= '1';
          when 296 =>
             rtarget  <= REG;
             reg_rd_stb(74) <= '1';
          when 300 =>
             rtarget  <= REG;
             reg_rd_stb(75) <= '1';
          when 304 =>
             rtarget  <= REG;
             reg_rd_stb(76) <= '1';
          when 308 =>
             rtarget  <= REG;
             reg_rd_stb(77) <= '1';
          when 312 =>
             rtarget  <= REG;
             reg_rd_stb(78) <= '1';
          when 316 =>
             rtarget  <= REG;
             reg_rd_stb(79) <= '1';
          when 320 =>
             rtarget  <= REG;
             reg_rd_stb(80) <= '1';
          when 324 =>
             rtarget  <= REG;
             reg_rd_stb(81) <= '1';
          when 328 =>
             rtarget  <= REG;
             reg_rd_stb(82) <= '1';
          when 332 =>
             rtarget  <= REG;
             reg_rd_stb(83) <= '1';
          when 336 =>
             rtarget  <= REG;
             reg_rd_stb(84) <= '1';
          when 340 =>
             rtarget  <= REG;
             reg_rd_stb(85) <= '1';
          when 344 =>
             rtarget  <= REG;
             reg_rd_stb(86) <= '1';
          when 348 =>
             rtarget  <= REG;
             reg_rd_stb(87) <= '1';
          when 352 =>
             rtarget  <= REG;
             reg_rd_stb(88) <= '1';
          when 356 =>
             rtarget  <= REG;
             reg_rd_stb(89) <= '1';
          when 360 =>
             rtarget  <= REG;
             reg_rd_stb(90) <= '1';
          when others =>
             rtarget    <= NONE;
        end case;

      elsif state_read = ST_READ_DONE then
        reg_rd_stb <= (others => '0');

      end if;
    end if;
  end process prs_raddr_decoder;
  ----------------------------------------------------------
  --

  -- ===========================================================================
  -- ### write logic
  ------------------------------------------------------------------------------
  -- Write channel state machine
  ------------------------------------------------------------------------------
  prs_state_write: process (pi_clock)
  begin
    if rising_edge (pi_clock) then
      if reset = '1' then
        state_write <= ST_WRITE_IDLE;
      else
        case state_write is
          when ST_WRITE_IDLE =>

            if pi_s_top.awvalid = '1' and pi_s_top.wvalid = '1' then
              state_write <= ST_WRITE_SELECT;
            elsif pi_s_top.awvalid = '1' and pi_s_top.wvalid = '0' then
              state_write <= ST_WRITE_WAIT_DATA;
            elsif pi_s_top.awvalid = '0' and pi_s_top.wvalid = '1' then
              state_write <= ST_WRITE_WAIT_ADDR;
            end if;

          when ST_WRITE_WAIT_DATA =>
            if pi_s_top.wvalid = '1' then
              state_write <= ST_WRITE_SELECT;
            end if;

          when ST_WRITE_WAIT_ADDR =>
            if pi_s_top.awvalid = '1' then
              state_write <= ST_WRITE_SELECT;
            end if;

          when ST_WRITE_SELECT =>
            case wtarget is
              when REG =>
                state_write <= ST_WRITE_RESP;
              when others =>
                state_write <= ST_WRITE_RESP; -- every write transaction must end with response
            end case;

          when ST_WRITE_RESP =>
            if pi_s_top.bready = '1' then
              state_write <= ST_WRITE_IDLE;
            end if;

          when others =>
            state_write <= ST_WRITE_IDLE;

        end case;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- WRITE AXI handshaking
  po_s_top.bresp <= "00";

  prs_axi_bvalid: process (state_write)
  begin
    case state_write is
      when ST_WRITE_RESP =>
        po_s_top.bvalid <= '1';
      when others =>
        po_s_top.bvalid <= '0';
    end case;
  end process;

  prs_axi_awready: process (state_write)
  begin
    case state_write is
      when ST_WRITE_IDLE | ST_WRITE_WAIT_ADDR =>
        po_s_top.awready <= '1';
      when others =>
        po_s_top.awready <= '0';
    end case;
  end process;

  prs_axi_wready: process (state_write)
  begin
    case state_write is
      when ST_WRITE_IDLE | ST_WRITE_WAIT_DATA =>
        po_s_top.wready <= '1';
      when others =>
        po_s_top.wready <= '0';
    end case;
  end process;

  ------------------------------------------------------------------------------
  -- write Address decoder
  ------------------------------------------------------------------------------
  waddr_int <= to_integer(unsigned(pi_s_top.awaddr(G_ADDR_WIDTH-1 downto 0)));

  prs_waddr_decoder: process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if (state_write = ST_WRITE_IDLE or state_write = ST_WRITE_WAIT_ADDR ) and pi_s_top.awvalid = '1' then
        reg_wr_stb <= (others => '0');
        case waddr_int is
          when 0 =>
             wtarget  <= REG;
             reg_wr_stb(0) <= '1';
          when 4 =>
             wtarget  <= REG;
             reg_wr_stb(1) <= '1';
          when 8 =>
             wtarget  <= REG;
             reg_wr_stb(2) <= '1';
          when 12 =>
             wtarget  <= REG;
             reg_wr_stb(3) <= '1';
          when 16 =>
             wtarget  <= REG;
             reg_wr_stb(4) <= '1';
          when 20 =>
             wtarget  <= REG;
             reg_wr_stb(5) <= '1';
          when 24 =>
             wtarget  <= REG;
             reg_wr_stb(6) <= '1';
          when 28 =>
             wtarget  <= REG;
             reg_wr_stb(7) <= '1';
          when 32 =>
             wtarget  <= REG;
             reg_wr_stb(8) <= '1';
          when 36 =>
             wtarget  <= REG;
             reg_wr_stb(9) <= '1';
          when 40 =>
             wtarget  <= REG;
             reg_wr_stb(10) <= '1';
          when 44 =>
             wtarget  <= REG;
             reg_wr_stb(11) <= '1';
          when 48 =>
             wtarget  <= REG;
             reg_wr_stb(12) <= '1';
          when 52 =>
             wtarget  <= REG;
             reg_wr_stb(13) <= '1';
          when 56 =>
             wtarget  <= REG;
             reg_wr_stb(14) <= '1';
          when 60 =>
             wtarget  <= REG;
             reg_wr_stb(15) <= '1';
          when 64 =>
             wtarget  <= REG;
             reg_wr_stb(16) <= '1';
          when 68 =>
             wtarget  <= REG;
             reg_wr_stb(17) <= '1';
          when 72 =>
             wtarget  <= REG;
             reg_wr_stb(18) <= '1';
          when 76 =>
             wtarget  <= REG;
             reg_wr_stb(19) <= '1';
          when 80 =>
             wtarget  <= REG;
             reg_wr_stb(20) <= '1';
          when 84 =>
             wtarget  <= REG;
             reg_wr_stb(21) <= '1';
          when 88 =>
             wtarget  <= REG;
             reg_wr_stb(22) <= '1';
          when 92 =>
             wtarget  <= REG;
             reg_wr_stb(23) <= '1';
          when 96 =>
             wtarget  <= REG;
             reg_wr_stb(24) <= '1';
          when 100 =>
             wtarget  <= REG;
             reg_wr_stb(25) <= '1';
          when 104 =>
             wtarget  <= REG;
             reg_wr_stb(26) <= '1';
          when 108 =>
             wtarget  <= REG;
             reg_wr_stb(27) <= '1';
          when 112 =>
             wtarget  <= REG;
             reg_wr_stb(28) <= '1';
          when 116 =>
             wtarget  <= REG;
             reg_wr_stb(29) <= '1';
          when 120 =>
             wtarget  <= REG;
             reg_wr_stb(30) <= '1';
          when 124 =>
             wtarget  <= REG;
             reg_wr_stb(31) <= '1';
          when 128 =>
             wtarget  <= REG;
             reg_wr_stb(32) <= '1';
          when 132 =>
             wtarget  <= REG;
             reg_wr_stb(33) <= '1';
          when 136 =>
             wtarget  <= REG;
             reg_wr_stb(34) <= '1';
          when 140 =>
             wtarget  <= REG;
             reg_wr_stb(35) <= '1';
          when 144 =>
             wtarget  <= REG;
             reg_wr_stb(36) <= '1';
          when 148 =>
             wtarget  <= REG;
             reg_wr_stb(37) <= '1';
          when 152 =>
             wtarget  <= REG;
             reg_wr_stb(38) <= '1';
          when 156 =>
             wtarget  <= REG;
             reg_wr_stb(39) <= '1';
          when 160 =>
             wtarget  <= REG;
             reg_wr_stb(40) <= '1';
          when 164 =>
             wtarget  <= REG;
             reg_wr_stb(41) <= '1';
          when 168 =>
             wtarget  <= REG;
             reg_wr_stb(42) <= '1';
          when 172 =>
             wtarget  <= REG;
             reg_wr_stb(43) <= '1';
          when 176 =>
             wtarget  <= REG;
             reg_wr_stb(44) <= '1';
          when 180 =>
             wtarget  <= REG;
             reg_wr_stb(45) <= '1';
          when 184 =>
             wtarget  <= REG;
             reg_wr_stb(46) <= '1';
          when 188 =>
             wtarget  <= REG;
             reg_wr_stb(47) <= '1';
          when 192 =>
             wtarget  <= REG;
             reg_wr_stb(48) <= '1';
          when 196 =>
             wtarget  <= REG;
             reg_wr_stb(49) <= '1';
          when 200 =>
             wtarget  <= REG;
             reg_wr_stb(50) <= '1';
          when 204 =>
             wtarget  <= REG;
             reg_wr_stb(51) <= '1';
          when 208 =>
             wtarget  <= REG;
             reg_wr_stb(52) <= '1';
          when 212 =>
             wtarget  <= REG;
             reg_wr_stb(53) <= '1';
          when 216 =>
             wtarget  <= REG;
             reg_wr_stb(54) <= '1';
          when 220 =>
             wtarget  <= REG;
             reg_wr_stb(55) <= '1';
          when 224 =>
             wtarget  <= REG;
             reg_wr_stb(56) <= '1';
          when 228 =>
             wtarget  <= REG;
             reg_wr_stb(57) <= '1';
          when 232 =>
             wtarget  <= REG;
             reg_wr_stb(58) <= '1';
          when 236 =>
             wtarget  <= REG;
             reg_wr_stb(59) <= '1';
          when 240 =>
             wtarget  <= REG;
             reg_wr_stb(60) <= '1';
          when 244 =>
             wtarget  <= REG;
             reg_wr_stb(61) <= '1';
          when 248 =>
             wtarget  <= REG;
             reg_wr_stb(62) <= '1';
          when 252 =>
             wtarget  <= REG;
             reg_wr_stb(63) <= '1';
          when 256 =>
             wtarget  <= REG;
             reg_wr_stb(64) <= '1';
          when 260 =>
             wtarget  <= REG;
             reg_wr_stb(65) <= '1';
          when 264 =>
             wtarget  <= REG;
             reg_wr_stb(66) <= '1';
          when 268 =>
             wtarget  <= REG;
             reg_wr_stb(67) <= '1';
          when 272 =>
             wtarget  <= REG;
             reg_wr_stb(68) <= '1';
          when 276 =>
             wtarget  <= REG;
             reg_wr_stb(69) <= '1';
          when 280 =>
             wtarget  <= REG;
             reg_wr_stb(70) <= '1';
          when 284 =>
             wtarget  <= REG;
             reg_wr_stb(71) <= '1';
          when 288 =>
             wtarget  <= REG;
             reg_wr_stb(72) <= '1';
          when 292 =>
             wtarget  <= REG;
             reg_wr_stb(73) <= '1';
          when 296 =>
             wtarget  <= REG;
             reg_wr_stb(74) <= '1';
          when 300 =>
             wtarget  <= REG;
             reg_wr_stb(75) <= '1';
          when 304 =>
             wtarget  <= REG;
             reg_wr_stb(76) <= '1';
          when 308 =>
             wtarget  <= REG;
             reg_wr_stb(77) <= '1';
          when 312 =>
             wtarget  <= REG;
             reg_wr_stb(78) <= '1';
          when 316 =>
             wtarget  <= REG;
             reg_wr_stb(79) <= '1';
          when 320 =>
             wtarget  <= REG;
             reg_wr_stb(80) <= '1';
          when 324 =>
             wtarget  <= REG;
             reg_wr_stb(81) <= '1';
          when 328 =>
             wtarget  <= REG;
             reg_wr_stb(82) <= '1';
          when 332 =>
             wtarget  <= REG;
             reg_wr_stb(83) <= '1';
          when 336 =>
             wtarget  <= REG;
             reg_wr_stb(84) <= '1';
          when 340 =>
             wtarget  <= REG;
             reg_wr_stb(85) <= '1';
          when 344 =>
             wtarget  <= REG;
             reg_wr_stb(86) <= '1';
          when 348 =>
             wtarget  <= REG;
             reg_wr_stb(87) <= '1';
          when 352 =>
             wtarget  <= REG;
             reg_wr_stb(88) <= '1';
          when 356 =>
             wtarget  <= REG;
             reg_wr_stb(89) <= '1';
          when 360 =>
             wtarget  <= REG;
             reg_wr_stb(90) <= '1';
          when others =>
             wtarget    <= NONE;
        end case;

      elsif state_write = ST_WRITE_RESP then
        reg_wr_stb <= (others => '0');
      end if;
    end if;
  end process prs_waddr_decoder;
  ----------------------------------------------------------
  --

  prs_wdata_reg : process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if state_write  = ST_WRITE_IDLE or state_write = ST_WRITE_WAIT_DATA then
        wdata <= pi_s_top.wdata;
      end if;
    end if;
  end process prs_wdata_reg ;

  -- ===========================================================================
  -- OUTPUT
  -- ===========================================================================
  -- registers
  ------------------------------------------------------------------------------
  po_reg_rd_stb <= reg_rd_stb;
  po_reg_wr_stb <= reg_wr_stb;
  po_reg_data   <= wdata;
  rdata_reg     <= pi_reg_data ;

end architecture arch;
