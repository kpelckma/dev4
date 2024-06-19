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

entity spi_ad9268_decoder_axi4l is
  generic (
    G_ADDR_WIDTH    : integer := 32;
    G_DATA_WIDTH    : integer := 32
  );
  port (
    pi_clock  : in std_logic;
    pi_reset  : in std_logic;
    --
    po_reg_rd_stb  : out std_logic_vector(257-1 downto 0);
    po_reg_wr_stb  : out std_logic_vector(257-1 downto 0);
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
end entity spi_ad9268_decoder_axi4l;

architecture arch of spi_ad9268_decoder_axi4l is

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
  signal reg_rd_stb  : std_logic_vector(257-1 downto 0) := (others => '0');
  signal reg_wr_stb  : std_logic_vector(257-1 downto 0) := (others => '0');

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
          when 364 =>
             rtarget  <= REG;
             reg_rd_stb(91) <= '1';
          when 368 =>
             rtarget  <= REG;
             reg_rd_stb(92) <= '1';
          when 372 =>
             rtarget  <= REG;
             reg_rd_stb(93) <= '1';
          when 376 =>
             rtarget  <= REG;
             reg_rd_stb(94) <= '1';
          when 380 =>
             rtarget  <= REG;
             reg_rd_stb(95) <= '1';
          when 384 =>
             rtarget  <= REG;
             reg_rd_stb(96) <= '1';
          when 388 =>
             rtarget  <= REG;
             reg_rd_stb(97) <= '1';
          when 392 =>
             rtarget  <= REG;
             reg_rd_stb(98) <= '1';
          when 396 =>
             rtarget  <= REG;
             reg_rd_stb(99) <= '1';
          when 400 =>
             rtarget  <= REG;
             reg_rd_stb(100) <= '1';
          when 404 =>
             rtarget  <= REG;
             reg_rd_stb(101) <= '1';
          when 408 =>
             rtarget  <= REG;
             reg_rd_stb(102) <= '1';
          when 412 =>
             rtarget  <= REG;
             reg_rd_stb(103) <= '1';
          when 416 =>
             rtarget  <= REG;
             reg_rd_stb(104) <= '1';
          when 420 =>
             rtarget  <= REG;
             reg_rd_stb(105) <= '1';
          when 424 =>
             rtarget  <= REG;
             reg_rd_stb(106) <= '1';
          when 428 =>
             rtarget  <= REG;
             reg_rd_stb(107) <= '1';
          when 432 =>
             rtarget  <= REG;
             reg_rd_stb(108) <= '1';
          when 436 =>
             rtarget  <= REG;
             reg_rd_stb(109) <= '1';
          when 440 =>
             rtarget  <= REG;
             reg_rd_stb(110) <= '1';
          when 444 =>
             rtarget  <= REG;
             reg_rd_stb(111) <= '1';
          when 448 =>
             rtarget  <= REG;
             reg_rd_stb(112) <= '1';
          when 452 =>
             rtarget  <= REG;
             reg_rd_stb(113) <= '1';
          when 456 =>
             rtarget  <= REG;
             reg_rd_stb(114) <= '1';
          when 460 =>
             rtarget  <= REG;
             reg_rd_stb(115) <= '1';
          when 464 =>
             rtarget  <= REG;
             reg_rd_stb(116) <= '1';
          when 468 =>
             rtarget  <= REG;
             reg_rd_stb(117) <= '1';
          when 472 =>
             rtarget  <= REG;
             reg_rd_stb(118) <= '1';
          when 476 =>
             rtarget  <= REG;
             reg_rd_stb(119) <= '1';
          when 480 =>
             rtarget  <= REG;
             reg_rd_stb(120) <= '1';
          when 484 =>
             rtarget  <= REG;
             reg_rd_stb(121) <= '1';
          when 488 =>
             rtarget  <= REG;
             reg_rd_stb(122) <= '1';
          when 492 =>
             rtarget  <= REG;
             reg_rd_stb(123) <= '1';
          when 496 =>
             rtarget  <= REG;
             reg_rd_stb(124) <= '1';
          when 500 =>
             rtarget  <= REG;
             reg_rd_stb(125) <= '1';
          when 504 =>
             rtarget  <= REG;
             reg_rd_stb(126) <= '1';
          when 508 =>
             rtarget  <= REG;
             reg_rd_stb(127) <= '1';
          when 512 =>
             rtarget  <= REG;
             reg_rd_stb(128) <= '1';
          when 516 =>
             rtarget  <= REG;
             reg_rd_stb(129) <= '1';
          when 520 =>
             rtarget  <= REG;
             reg_rd_stb(130) <= '1';
          when 524 =>
             rtarget  <= REG;
             reg_rd_stb(131) <= '1';
          when 528 =>
             rtarget  <= REG;
             reg_rd_stb(132) <= '1';
          when 532 =>
             rtarget  <= REG;
             reg_rd_stb(133) <= '1';
          when 536 =>
             rtarget  <= REG;
             reg_rd_stb(134) <= '1';
          when 540 =>
             rtarget  <= REG;
             reg_rd_stb(135) <= '1';
          when 544 =>
             rtarget  <= REG;
             reg_rd_stb(136) <= '1';
          when 548 =>
             rtarget  <= REG;
             reg_rd_stb(137) <= '1';
          when 552 =>
             rtarget  <= REG;
             reg_rd_stb(138) <= '1';
          when 556 =>
             rtarget  <= REG;
             reg_rd_stb(139) <= '1';
          when 560 =>
             rtarget  <= REG;
             reg_rd_stb(140) <= '1';
          when 564 =>
             rtarget  <= REG;
             reg_rd_stb(141) <= '1';
          when 568 =>
             rtarget  <= REG;
             reg_rd_stb(142) <= '1';
          when 572 =>
             rtarget  <= REG;
             reg_rd_stb(143) <= '1';
          when 576 =>
             rtarget  <= REG;
             reg_rd_stb(144) <= '1';
          when 580 =>
             rtarget  <= REG;
             reg_rd_stb(145) <= '1';
          when 584 =>
             rtarget  <= REG;
             reg_rd_stb(146) <= '1';
          when 588 =>
             rtarget  <= REG;
             reg_rd_stb(147) <= '1';
          when 592 =>
             rtarget  <= REG;
             reg_rd_stb(148) <= '1';
          when 596 =>
             rtarget  <= REG;
             reg_rd_stb(149) <= '1';
          when 600 =>
             rtarget  <= REG;
             reg_rd_stb(150) <= '1';
          when 604 =>
             rtarget  <= REG;
             reg_rd_stb(151) <= '1';
          when 608 =>
             rtarget  <= REG;
             reg_rd_stb(152) <= '1';
          when 612 =>
             rtarget  <= REG;
             reg_rd_stb(153) <= '1';
          when 616 =>
             rtarget  <= REG;
             reg_rd_stb(154) <= '1';
          when 620 =>
             rtarget  <= REG;
             reg_rd_stb(155) <= '1';
          when 624 =>
             rtarget  <= REG;
             reg_rd_stb(156) <= '1';
          when 628 =>
             rtarget  <= REG;
             reg_rd_stb(157) <= '1';
          when 632 =>
             rtarget  <= REG;
             reg_rd_stb(158) <= '1';
          when 636 =>
             rtarget  <= REG;
             reg_rd_stb(159) <= '1';
          when 640 =>
             rtarget  <= REG;
             reg_rd_stb(160) <= '1';
          when 644 =>
             rtarget  <= REG;
             reg_rd_stb(161) <= '1';
          when 648 =>
             rtarget  <= REG;
             reg_rd_stb(162) <= '1';
          when 652 =>
             rtarget  <= REG;
             reg_rd_stb(163) <= '1';
          when 656 =>
             rtarget  <= REG;
             reg_rd_stb(164) <= '1';
          when 660 =>
             rtarget  <= REG;
             reg_rd_stb(165) <= '1';
          when 664 =>
             rtarget  <= REG;
             reg_rd_stb(166) <= '1';
          when 668 =>
             rtarget  <= REG;
             reg_rd_stb(167) <= '1';
          when 672 =>
             rtarget  <= REG;
             reg_rd_stb(168) <= '1';
          when 676 =>
             rtarget  <= REG;
             reg_rd_stb(169) <= '1';
          when 680 =>
             rtarget  <= REG;
             reg_rd_stb(170) <= '1';
          when 684 =>
             rtarget  <= REG;
             reg_rd_stb(171) <= '1';
          when 688 =>
             rtarget  <= REG;
             reg_rd_stb(172) <= '1';
          when 692 =>
             rtarget  <= REG;
             reg_rd_stb(173) <= '1';
          when 696 =>
             rtarget  <= REG;
             reg_rd_stb(174) <= '1';
          when 700 =>
             rtarget  <= REG;
             reg_rd_stb(175) <= '1';
          when 704 =>
             rtarget  <= REG;
             reg_rd_stb(176) <= '1';
          when 708 =>
             rtarget  <= REG;
             reg_rd_stb(177) <= '1';
          when 712 =>
             rtarget  <= REG;
             reg_rd_stb(178) <= '1';
          when 716 =>
             rtarget  <= REG;
             reg_rd_stb(179) <= '1';
          when 720 =>
             rtarget  <= REG;
             reg_rd_stb(180) <= '1';
          when 724 =>
             rtarget  <= REG;
             reg_rd_stb(181) <= '1';
          when 728 =>
             rtarget  <= REG;
             reg_rd_stb(182) <= '1';
          when 732 =>
             rtarget  <= REG;
             reg_rd_stb(183) <= '1';
          when 736 =>
             rtarget  <= REG;
             reg_rd_stb(184) <= '1';
          when 740 =>
             rtarget  <= REG;
             reg_rd_stb(185) <= '1';
          when 744 =>
             rtarget  <= REG;
             reg_rd_stb(186) <= '1';
          when 748 =>
             rtarget  <= REG;
             reg_rd_stb(187) <= '1';
          when 752 =>
             rtarget  <= REG;
             reg_rd_stb(188) <= '1';
          when 756 =>
             rtarget  <= REG;
             reg_rd_stb(189) <= '1';
          when 760 =>
             rtarget  <= REG;
             reg_rd_stb(190) <= '1';
          when 764 =>
             rtarget  <= REG;
             reg_rd_stb(191) <= '1';
          when 768 =>
             rtarget  <= REG;
             reg_rd_stb(192) <= '1';
          when 772 =>
             rtarget  <= REG;
             reg_rd_stb(193) <= '1';
          when 776 =>
             rtarget  <= REG;
             reg_rd_stb(194) <= '1';
          when 780 =>
             rtarget  <= REG;
             reg_rd_stb(195) <= '1';
          when 784 =>
             rtarget  <= REG;
             reg_rd_stb(196) <= '1';
          when 788 =>
             rtarget  <= REG;
             reg_rd_stb(197) <= '1';
          when 792 =>
             rtarget  <= REG;
             reg_rd_stb(198) <= '1';
          when 796 =>
             rtarget  <= REG;
             reg_rd_stb(199) <= '1';
          when 800 =>
             rtarget  <= REG;
             reg_rd_stb(200) <= '1';
          when 804 =>
             rtarget  <= REG;
             reg_rd_stb(201) <= '1';
          when 808 =>
             rtarget  <= REG;
             reg_rd_stb(202) <= '1';
          when 812 =>
             rtarget  <= REG;
             reg_rd_stb(203) <= '1';
          when 816 =>
             rtarget  <= REG;
             reg_rd_stb(204) <= '1';
          when 820 =>
             rtarget  <= REG;
             reg_rd_stb(205) <= '1';
          when 824 =>
             rtarget  <= REG;
             reg_rd_stb(206) <= '1';
          when 828 =>
             rtarget  <= REG;
             reg_rd_stb(207) <= '1';
          when 832 =>
             rtarget  <= REG;
             reg_rd_stb(208) <= '1';
          when 836 =>
             rtarget  <= REG;
             reg_rd_stb(209) <= '1';
          when 840 =>
             rtarget  <= REG;
             reg_rd_stb(210) <= '1';
          when 844 =>
             rtarget  <= REG;
             reg_rd_stb(211) <= '1';
          when 848 =>
             rtarget  <= REG;
             reg_rd_stb(212) <= '1';
          when 852 =>
             rtarget  <= REG;
             reg_rd_stb(213) <= '1';
          when 856 =>
             rtarget  <= REG;
             reg_rd_stb(214) <= '1';
          when 860 =>
             rtarget  <= REG;
             reg_rd_stb(215) <= '1';
          when 864 =>
             rtarget  <= REG;
             reg_rd_stb(216) <= '1';
          when 868 =>
             rtarget  <= REG;
             reg_rd_stb(217) <= '1';
          when 872 =>
             rtarget  <= REG;
             reg_rd_stb(218) <= '1';
          when 876 =>
             rtarget  <= REG;
             reg_rd_stb(219) <= '1';
          when 880 =>
             rtarget  <= REG;
             reg_rd_stb(220) <= '1';
          when 884 =>
             rtarget  <= REG;
             reg_rd_stb(221) <= '1';
          when 888 =>
             rtarget  <= REG;
             reg_rd_stb(222) <= '1';
          when 892 =>
             rtarget  <= REG;
             reg_rd_stb(223) <= '1';
          when 896 =>
             rtarget  <= REG;
             reg_rd_stb(224) <= '1';
          when 900 =>
             rtarget  <= REG;
             reg_rd_stb(225) <= '1';
          when 904 =>
             rtarget  <= REG;
             reg_rd_stb(226) <= '1';
          when 908 =>
             rtarget  <= REG;
             reg_rd_stb(227) <= '1';
          when 912 =>
             rtarget  <= REG;
             reg_rd_stb(228) <= '1';
          when 916 =>
             rtarget  <= REG;
             reg_rd_stb(229) <= '1';
          when 920 =>
             rtarget  <= REG;
             reg_rd_stb(230) <= '1';
          when 924 =>
             rtarget  <= REG;
             reg_rd_stb(231) <= '1';
          when 928 =>
             rtarget  <= REG;
             reg_rd_stb(232) <= '1';
          when 932 =>
             rtarget  <= REG;
             reg_rd_stb(233) <= '1';
          when 936 =>
             rtarget  <= REG;
             reg_rd_stb(234) <= '1';
          when 940 =>
             rtarget  <= REG;
             reg_rd_stb(235) <= '1';
          when 944 =>
             rtarget  <= REG;
             reg_rd_stb(236) <= '1';
          when 948 =>
             rtarget  <= REG;
             reg_rd_stb(237) <= '1';
          when 952 =>
             rtarget  <= REG;
             reg_rd_stb(238) <= '1';
          when 956 =>
             rtarget  <= REG;
             reg_rd_stb(239) <= '1';
          when 960 =>
             rtarget  <= REG;
             reg_rd_stb(240) <= '1';
          when 964 =>
             rtarget  <= REG;
             reg_rd_stb(241) <= '1';
          when 968 =>
             rtarget  <= REG;
             reg_rd_stb(242) <= '1';
          when 972 =>
             rtarget  <= REG;
             reg_rd_stb(243) <= '1';
          when 976 =>
             rtarget  <= REG;
             reg_rd_stb(244) <= '1';
          when 980 =>
             rtarget  <= REG;
             reg_rd_stb(245) <= '1';
          when 984 =>
             rtarget  <= REG;
             reg_rd_stb(246) <= '1';
          when 988 =>
             rtarget  <= REG;
             reg_rd_stb(247) <= '1';
          when 992 =>
             rtarget  <= REG;
             reg_rd_stb(248) <= '1';
          when 996 =>
             rtarget  <= REG;
             reg_rd_stb(249) <= '1';
          when 1000 =>
             rtarget  <= REG;
             reg_rd_stb(250) <= '1';
          when 1004 =>
             rtarget  <= REG;
             reg_rd_stb(251) <= '1';
          when 1008 =>
             rtarget  <= REG;
             reg_rd_stb(252) <= '1';
          when 1012 =>
             rtarget  <= REG;
             reg_rd_stb(253) <= '1';
          when 1016 =>
             rtarget  <= REG;
             reg_rd_stb(254) <= '1';
          when 1020 =>
             rtarget  <= REG;
             reg_rd_stb(255) <= '1';
          when 1024 =>
             rtarget  <= REG;
             reg_rd_stb(256) <= '1';
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
          when 364 =>
             wtarget  <= REG;
             reg_wr_stb(91) <= '1';
          when 368 =>
             wtarget  <= REG;
             reg_wr_stb(92) <= '1';
          when 372 =>
             wtarget  <= REG;
             reg_wr_stb(93) <= '1';
          when 376 =>
             wtarget  <= REG;
             reg_wr_stb(94) <= '1';
          when 380 =>
             wtarget  <= REG;
             reg_wr_stb(95) <= '1';
          when 384 =>
             wtarget  <= REG;
             reg_wr_stb(96) <= '1';
          when 388 =>
             wtarget  <= REG;
             reg_wr_stb(97) <= '1';
          when 392 =>
             wtarget  <= REG;
             reg_wr_stb(98) <= '1';
          when 396 =>
             wtarget  <= REG;
             reg_wr_stb(99) <= '1';
          when 400 =>
             wtarget  <= REG;
             reg_wr_stb(100) <= '1';
          when 404 =>
             wtarget  <= REG;
             reg_wr_stb(101) <= '1';
          when 408 =>
             wtarget  <= REG;
             reg_wr_stb(102) <= '1';
          when 412 =>
             wtarget  <= REG;
             reg_wr_stb(103) <= '1';
          when 416 =>
             wtarget  <= REG;
             reg_wr_stb(104) <= '1';
          when 420 =>
             wtarget  <= REG;
             reg_wr_stb(105) <= '1';
          when 424 =>
             wtarget  <= REG;
             reg_wr_stb(106) <= '1';
          when 428 =>
             wtarget  <= REG;
             reg_wr_stb(107) <= '1';
          when 432 =>
             wtarget  <= REG;
             reg_wr_stb(108) <= '1';
          when 436 =>
             wtarget  <= REG;
             reg_wr_stb(109) <= '1';
          when 440 =>
             wtarget  <= REG;
             reg_wr_stb(110) <= '1';
          when 444 =>
             wtarget  <= REG;
             reg_wr_stb(111) <= '1';
          when 448 =>
             wtarget  <= REG;
             reg_wr_stb(112) <= '1';
          when 452 =>
             wtarget  <= REG;
             reg_wr_stb(113) <= '1';
          when 456 =>
             wtarget  <= REG;
             reg_wr_stb(114) <= '1';
          when 460 =>
             wtarget  <= REG;
             reg_wr_stb(115) <= '1';
          when 464 =>
             wtarget  <= REG;
             reg_wr_stb(116) <= '1';
          when 468 =>
             wtarget  <= REG;
             reg_wr_stb(117) <= '1';
          when 472 =>
             wtarget  <= REG;
             reg_wr_stb(118) <= '1';
          when 476 =>
             wtarget  <= REG;
             reg_wr_stb(119) <= '1';
          when 480 =>
             wtarget  <= REG;
             reg_wr_stb(120) <= '1';
          when 484 =>
             wtarget  <= REG;
             reg_wr_stb(121) <= '1';
          when 488 =>
             wtarget  <= REG;
             reg_wr_stb(122) <= '1';
          when 492 =>
             wtarget  <= REG;
             reg_wr_stb(123) <= '1';
          when 496 =>
             wtarget  <= REG;
             reg_wr_stb(124) <= '1';
          when 500 =>
             wtarget  <= REG;
             reg_wr_stb(125) <= '1';
          when 504 =>
             wtarget  <= REG;
             reg_wr_stb(126) <= '1';
          when 508 =>
             wtarget  <= REG;
             reg_wr_stb(127) <= '1';
          when 512 =>
             wtarget  <= REG;
             reg_wr_stb(128) <= '1';
          when 516 =>
             wtarget  <= REG;
             reg_wr_stb(129) <= '1';
          when 520 =>
             wtarget  <= REG;
             reg_wr_stb(130) <= '1';
          when 524 =>
             wtarget  <= REG;
             reg_wr_stb(131) <= '1';
          when 528 =>
             wtarget  <= REG;
             reg_wr_stb(132) <= '1';
          when 532 =>
             wtarget  <= REG;
             reg_wr_stb(133) <= '1';
          when 536 =>
             wtarget  <= REG;
             reg_wr_stb(134) <= '1';
          when 540 =>
             wtarget  <= REG;
             reg_wr_stb(135) <= '1';
          when 544 =>
             wtarget  <= REG;
             reg_wr_stb(136) <= '1';
          when 548 =>
             wtarget  <= REG;
             reg_wr_stb(137) <= '1';
          when 552 =>
             wtarget  <= REG;
             reg_wr_stb(138) <= '1';
          when 556 =>
             wtarget  <= REG;
             reg_wr_stb(139) <= '1';
          when 560 =>
             wtarget  <= REG;
             reg_wr_stb(140) <= '1';
          when 564 =>
             wtarget  <= REG;
             reg_wr_stb(141) <= '1';
          when 568 =>
             wtarget  <= REG;
             reg_wr_stb(142) <= '1';
          when 572 =>
             wtarget  <= REG;
             reg_wr_stb(143) <= '1';
          when 576 =>
             wtarget  <= REG;
             reg_wr_stb(144) <= '1';
          when 580 =>
             wtarget  <= REG;
             reg_wr_stb(145) <= '1';
          when 584 =>
             wtarget  <= REG;
             reg_wr_stb(146) <= '1';
          when 588 =>
             wtarget  <= REG;
             reg_wr_stb(147) <= '1';
          when 592 =>
             wtarget  <= REG;
             reg_wr_stb(148) <= '1';
          when 596 =>
             wtarget  <= REG;
             reg_wr_stb(149) <= '1';
          when 600 =>
             wtarget  <= REG;
             reg_wr_stb(150) <= '1';
          when 604 =>
             wtarget  <= REG;
             reg_wr_stb(151) <= '1';
          when 608 =>
             wtarget  <= REG;
             reg_wr_stb(152) <= '1';
          when 612 =>
             wtarget  <= REG;
             reg_wr_stb(153) <= '1';
          when 616 =>
             wtarget  <= REG;
             reg_wr_stb(154) <= '1';
          when 620 =>
             wtarget  <= REG;
             reg_wr_stb(155) <= '1';
          when 624 =>
             wtarget  <= REG;
             reg_wr_stb(156) <= '1';
          when 628 =>
             wtarget  <= REG;
             reg_wr_stb(157) <= '1';
          when 632 =>
             wtarget  <= REG;
             reg_wr_stb(158) <= '1';
          when 636 =>
             wtarget  <= REG;
             reg_wr_stb(159) <= '1';
          when 640 =>
             wtarget  <= REG;
             reg_wr_stb(160) <= '1';
          when 644 =>
             wtarget  <= REG;
             reg_wr_stb(161) <= '1';
          when 648 =>
             wtarget  <= REG;
             reg_wr_stb(162) <= '1';
          when 652 =>
             wtarget  <= REG;
             reg_wr_stb(163) <= '1';
          when 656 =>
             wtarget  <= REG;
             reg_wr_stb(164) <= '1';
          when 660 =>
             wtarget  <= REG;
             reg_wr_stb(165) <= '1';
          when 664 =>
             wtarget  <= REG;
             reg_wr_stb(166) <= '1';
          when 668 =>
             wtarget  <= REG;
             reg_wr_stb(167) <= '1';
          when 672 =>
             wtarget  <= REG;
             reg_wr_stb(168) <= '1';
          when 676 =>
             wtarget  <= REG;
             reg_wr_stb(169) <= '1';
          when 680 =>
             wtarget  <= REG;
             reg_wr_stb(170) <= '1';
          when 684 =>
             wtarget  <= REG;
             reg_wr_stb(171) <= '1';
          when 688 =>
             wtarget  <= REG;
             reg_wr_stb(172) <= '1';
          when 692 =>
             wtarget  <= REG;
             reg_wr_stb(173) <= '1';
          when 696 =>
             wtarget  <= REG;
             reg_wr_stb(174) <= '1';
          when 700 =>
             wtarget  <= REG;
             reg_wr_stb(175) <= '1';
          when 704 =>
             wtarget  <= REG;
             reg_wr_stb(176) <= '1';
          when 708 =>
             wtarget  <= REG;
             reg_wr_stb(177) <= '1';
          when 712 =>
             wtarget  <= REG;
             reg_wr_stb(178) <= '1';
          when 716 =>
             wtarget  <= REG;
             reg_wr_stb(179) <= '1';
          when 720 =>
             wtarget  <= REG;
             reg_wr_stb(180) <= '1';
          when 724 =>
             wtarget  <= REG;
             reg_wr_stb(181) <= '1';
          when 728 =>
             wtarget  <= REG;
             reg_wr_stb(182) <= '1';
          when 732 =>
             wtarget  <= REG;
             reg_wr_stb(183) <= '1';
          when 736 =>
             wtarget  <= REG;
             reg_wr_stb(184) <= '1';
          when 740 =>
             wtarget  <= REG;
             reg_wr_stb(185) <= '1';
          when 744 =>
             wtarget  <= REG;
             reg_wr_stb(186) <= '1';
          when 748 =>
             wtarget  <= REG;
             reg_wr_stb(187) <= '1';
          when 752 =>
             wtarget  <= REG;
             reg_wr_stb(188) <= '1';
          when 756 =>
             wtarget  <= REG;
             reg_wr_stb(189) <= '1';
          when 760 =>
             wtarget  <= REG;
             reg_wr_stb(190) <= '1';
          when 764 =>
             wtarget  <= REG;
             reg_wr_stb(191) <= '1';
          when 768 =>
             wtarget  <= REG;
             reg_wr_stb(192) <= '1';
          when 772 =>
             wtarget  <= REG;
             reg_wr_stb(193) <= '1';
          when 776 =>
             wtarget  <= REG;
             reg_wr_stb(194) <= '1';
          when 780 =>
             wtarget  <= REG;
             reg_wr_stb(195) <= '1';
          when 784 =>
             wtarget  <= REG;
             reg_wr_stb(196) <= '1';
          when 788 =>
             wtarget  <= REG;
             reg_wr_stb(197) <= '1';
          when 792 =>
             wtarget  <= REG;
             reg_wr_stb(198) <= '1';
          when 796 =>
             wtarget  <= REG;
             reg_wr_stb(199) <= '1';
          when 800 =>
             wtarget  <= REG;
             reg_wr_stb(200) <= '1';
          when 804 =>
             wtarget  <= REG;
             reg_wr_stb(201) <= '1';
          when 808 =>
             wtarget  <= REG;
             reg_wr_stb(202) <= '1';
          when 812 =>
             wtarget  <= REG;
             reg_wr_stb(203) <= '1';
          when 816 =>
             wtarget  <= REG;
             reg_wr_stb(204) <= '1';
          when 820 =>
             wtarget  <= REG;
             reg_wr_stb(205) <= '1';
          when 824 =>
             wtarget  <= REG;
             reg_wr_stb(206) <= '1';
          when 828 =>
             wtarget  <= REG;
             reg_wr_stb(207) <= '1';
          when 832 =>
             wtarget  <= REG;
             reg_wr_stb(208) <= '1';
          when 836 =>
             wtarget  <= REG;
             reg_wr_stb(209) <= '1';
          when 840 =>
             wtarget  <= REG;
             reg_wr_stb(210) <= '1';
          when 844 =>
             wtarget  <= REG;
             reg_wr_stb(211) <= '1';
          when 848 =>
             wtarget  <= REG;
             reg_wr_stb(212) <= '1';
          when 852 =>
             wtarget  <= REG;
             reg_wr_stb(213) <= '1';
          when 856 =>
             wtarget  <= REG;
             reg_wr_stb(214) <= '1';
          when 860 =>
             wtarget  <= REG;
             reg_wr_stb(215) <= '1';
          when 864 =>
             wtarget  <= REG;
             reg_wr_stb(216) <= '1';
          when 868 =>
             wtarget  <= REG;
             reg_wr_stb(217) <= '1';
          when 872 =>
             wtarget  <= REG;
             reg_wr_stb(218) <= '1';
          when 876 =>
             wtarget  <= REG;
             reg_wr_stb(219) <= '1';
          when 880 =>
             wtarget  <= REG;
             reg_wr_stb(220) <= '1';
          when 884 =>
             wtarget  <= REG;
             reg_wr_stb(221) <= '1';
          when 888 =>
             wtarget  <= REG;
             reg_wr_stb(222) <= '1';
          when 892 =>
             wtarget  <= REG;
             reg_wr_stb(223) <= '1';
          when 896 =>
             wtarget  <= REG;
             reg_wr_stb(224) <= '1';
          when 900 =>
             wtarget  <= REG;
             reg_wr_stb(225) <= '1';
          when 904 =>
             wtarget  <= REG;
             reg_wr_stb(226) <= '1';
          when 908 =>
             wtarget  <= REG;
             reg_wr_stb(227) <= '1';
          when 912 =>
             wtarget  <= REG;
             reg_wr_stb(228) <= '1';
          when 916 =>
             wtarget  <= REG;
             reg_wr_stb(229) <= '1';
          when 920 =>
             wtarget  <= REG;
             reg_wr_stb(230) <= '1';
          when 924 =>
             wtarget  <= REG;
             reg_wr_stb(231) <= '1';
          when 928 =>
             wtarget  <= REG;
             reg_wr_stb(232) <= '1';
          when 932 =>
             wtarget  <= REG;
             reg_wr_stb(233) <= '1';
          when 936 =>
             wtarget  <= REG;
             reg_wr_stb(234) <= '1';
          when 940 =>
             wtarget  <= REG;
             reg_wr_stb(235) <= '1';
          when 944 =>
             wtarget  <= REG;
             reg_wr_stb(236) <= '1';
          when 948 =>
             wtarget  <= REG;
             reg_wr_stb(237) <= '1';
          when 952 =>
             wtarget  <= REG;
             reg_wr_stb(238) <= '1';
          when 956 =>
             wtarget  <= REG;
             reg_wr_stb(239) <= '1';
          when 960 =>
             wtarget  <= REG;
             reg_wr_stb(240) <= '1';
          when 964 =>
             wtarget  <= REG;
             reg_wr_stb(241) <= '1';
          when 968 =>
             wtarget  <= REG;
             reg_wr_stb(242) <= '1';
          when 972 =>
             wtarget  <= REG;
             reg_wr_stb(243) <= '1';
          when 976 =>
             wtarget  <= REG;
             reg_wr_stb(244) <= '1';
          when 980 =>
             wtarget  <= REG;
             reg_wr_stb(245) <= '1';
          when 984 =>
             wtarget  <= REG;
             reg_wr_stb(246) <= '1';
          when 988 =>
             wtarget  <= REG;
             reg_wr_stb(247) <= '1';
          when 992 =>
             wtarget  <= REG;
             reg_wr_stb(248) <= '1';
          when 996 =>
             wtarget  <= REG;
             reg_wr_stb(249) <= '1';
          when 1000 =>
             wtarget  <= REG;
             reg_wr_stb(250) <= '1';
          when 1004 =>
             wtarget  <= REG;
             reg_wr_stb(251) <= '1';
          when 1008 =>
             wtarget  <= REG;
             reg_wr_stb(252) <= '1';
          when 1012 =>
             wtarget  <= REG;
             reg_wr_stb(253) <= '1';
          when 1016 =>
             wtarget  <= REG;
             reg_wr_stb(254) <= '1';
          when 1020 =>
             wtarget  <= REG;
             reg_wr_stb(255) <= '1';
          when 1024 =>
             wtarget  <= REG;
             reg_wr_stb(256) <= '1';
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
