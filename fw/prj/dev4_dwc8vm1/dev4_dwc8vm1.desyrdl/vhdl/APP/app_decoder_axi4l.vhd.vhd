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

entity app_decoder_axi4l is
  generic (
    G_ADDR_WIDTH    : integer := 32;
    G_DATA_WIDTH    : integer := 32
  );
  port (
    pi_clock  : in std_logic;
    pi_reset  : in std_logic;
    --
    po_reg_rd_stb  : out std_logic_vector(58-1 downto 0);
    po_reg_wr_stb  : out std_logic_vector(58-1 downto 0);
    po_reg_data    : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    pi_reg_data    : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    --
    --
    --
    po_mem_stb     : out std_logic_vector(4-1 downto 0);
    po_mem_we      : out std_logic;
    po_mem_addr    : out std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    po_mem_data    : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    pi_mem_data    : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    pi_mem_ack     : in  std_logic;
    --
    --
    pi_ext    : in  t_axi4l_s2m_array(4-1 downto 0);
    po_ext    : out t_axi4l_m2s_array(4-1 downto 0);
    --
    pi_s_reset : in std_logic;
    pi_s_top   : in  t_axi4l_m2s ;
    po_s_top   : out t_axi4l_s2m
);
end entity app_decoder_axi4l;

architecture arch of app_decoder_axi4l is

  type t_target is (REG, MEM, EXT,  NONE );

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
    ST_READ_MEM_BUSY,
    ST_READ_EXT_ADDR,
    ST_READ_EXT_BUSY,
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
    ST_WRITE_MEM_BUSY,
    ST_WRITE_EXT_BUSY,
    ST_WRITE_RESP
  );
  signal state_write : t_state_write;

  signal wdata     : std_logic_vector(G_DATA_WIDTH-1 downto 0) := (others => '0');
  signal wstrb     : std_logic_vector(G_DATA_WIDTH/8-1 downto 0) := (others => '0');
  signal waddr     : std_logic_vector(G_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal waddr_int : integer;

  -----------------------------------------------------------
  signal reg_rd_stb  : std_logic_vector(58-1 downto 0) := (others => '0');
  signal reg_wr_stb  : std_logic_vector(58-1 downto 0) := (others => '0');

  -- external bus
  signal ext_rd_stb  : std_logic_vector(4-1 downto 0) := (others => '0');
  signal ext_wr_stb  : std_logic_vector(4-1 downto 0) := (others => '0');
  signal ext_arvalid : std_logic := '0';
  signal ext_arready : std_logic := '0';
  signal ext_rready  : std_logic := '0';
  signal ext_rvalid  : std_logic := '0';
  signal ext_awvalid : std_logic := '0';
  signal ext_awready : std_logic := '0';
  signal ext_wvalid  : std_logic := '0';
  signal ext_wready  : std_logic := '0';
  signal ext_bvalid  : std_logic := '0';
  signal ext_bready  : std_logic := '0';
  signal mem_rd_stb  : std_logic_vector(4-1 downto 0) := (others => '0');
  signal mem_rd_req  : std_logic := '0';
  signal mem_rd_ack  : std_logic := '0';
  signal mem_wr_stb  : std_logic_vector(4-1 downto 0) := (others => '0');
  signal mem_wr_req  : std_logic := '0';
  signal mem_wr_ack  : std_logic := '0';

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
        ext_arvalid <= '0'; -- TODO axi ext move to separate process
        read_time_cnt <= 0;
        invalid_rdata <= '0';
      else
        case state_read is
          when ST_READ_IDLE =>

            if pi_s_top.arvalid = '1' then
              state_read <= ST_READ_SELECT;
            end if;
            ext_arvalid   <= '0';
            read_time_cnt <= 0;
            invalid_rdata <= '0';
          when ST_READ_SELECT =>
            case rtarget is
              when REG =>
                state_read <= ST_READ_VALID;
              when MEM =>
                state_read <= ST_READ_MEM_BUSY;
              when EXT =>
                ext_arvalid <= '1';
                state_read  <= ST_READ_EXT_ADDR;
              when others =>
                state_read <= ST_READ_REG_BUSY;
            end case;

          when ST_READ_REG_BUSY =>
            state_read <= ST_READ_VALID;

          when ST_READ_MEM_BUSY =>
            read_time_cnt <= read_time_cnt + 1;
            if mem_rd_ack = '1' then
               state_read <= ST_READ_VALID;
            elsif read_time_cnt >= read_timeout then
              invalid_rdata <= '1';
              state_read <= ST_READ_VALID;
            end if;
          when ST_READ_EXT_ADDR =>
            read_time_cnt <= read_time_cnt + 1;

            if ext_arready = '1' then
              ext_arvalid  <= '0';
              read_time_cnt <= 0;
              state_read <= ST_READ_EXT_BUSY ;
            elsif read_time_cnt >= read_timeout then
              invalid_rdata <= '1';
              state_read <= ST_READ_VALID;
            end if;

          when ST_READ_EXT_BUSY =>
            read_time_cnt <= read_time_cnt + 1;

            if ext_rvalid = '1' and pi_s_top.rready = '1' then
              state_read <= ST_READ_DONE;
            elsif read_time_cnt >= read_timeout then
              invalid_rdata <= '1';
              state_read <= ST_READ_VALID;
            end if;

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
  ext_rready <= pi_s_top.rready;
  po_s_top.rresp <= "00";
  ------------------------------------------------------------------------------
  -- read data mux
  prs_rdata_mux: process(rtarget,rdata_reg,rdata_mem,rdata_ext,invalid_rdata)
  begin
    if invalid_rdata = '1' then
      po_s_top.rdata <= (others => '0' ) ;
    elsif rtarget = REG then
      po_s_top.rdata <= rdata_reg ;
    elsif rtarget = MEM then
      po_s_top.rdata <= rdata_mem ;
    elsif rtarget = EXT then
      po_s_top.rdata <= rdata_ext ;
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
      ext_rvalid,
      state_read)
  begin
    case state_read is
      when ST_READ_EXT_BUSY =>
        po_s_top.rvalid <= ext_rvalid;
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
        raddr      <= pi_s_top.araddr(G_ADDR_WIDTH-1 downto 0);
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
          when 4096 to 8191 =>
             rtarget  <= MEM;
             mem_rd_stb(0) <= '1';
             mem_rd_req <= '1';
          when 8192 to 12287 =>
             rtarget  <= MEM;
             mem_rd_stb(1) <= '1';
             mem_rd_req <= '1';
          when 12288 to 16383 =>
             rtarget  <= MEM;
             mem_rd_stb(2) <= '1';
             mem_rd_req <= '1';
          when 16384 to 20479 =>
             rtarget  <= MEM;
             mem_rd_stb(3) <= '1';
             mem_rd_req <= '1';
          when 20480 to 20599 =>
             rtarget  <= EXT;
             ext_rd_stb(0) <= '1';
          when 32768 to 49151 =>
             rtarget  <= EXT;
             ext_rd_stb(1) <= '1';
          when 49152 to 49159 =>
             rtarget  <= EXT;
             ext_rd_stb(2) <= '1';
          when 49280 to 49359 =>
             rtarget  <= EXT;
             ext_rd_stb(3) <= '1';
          when others =>
             rtarget    <= NONE;
        end case;

      elsif state_read = ST_READ_DONE then
        reg_rd_stb <= (others => '0');
        ext_rd_stb <= (others => '0');
        mem_rd_stb <= (others => '0');
        mem_rd_req <= '0';

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
        ext_awvalid <= '0'; -- TODO move axi ext to separate process
        ext_wvalid  <= '0';
        ext_bready  <= '0';
        write_time_cnt <= 0;
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

            ext_awvalid <= '0';
            ext_wvalid  <= '0';
            ext_bready  <= '0';
            write_time_cnt <= 0;
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
              when MEM =>
                state_write <= ST_WRITE_MEM_BUSY;
              when EXT =>
                ext_awvalid <= '1';
                ext_wvalid  <= '1';
                ext_bready  <= '1';
                state_write <= ST_WRITE_EXT_BUSY;
              when others =>
                state_write <= ST_WRITE_RESP; -- every write transaction must end with response
            end case;

          when ST_WRITE_MEM_BUSY =>
            write_time_cnt <= write_time_cnt + 1;

            if mem_wr_ack = '1' then
              state_write <= ST_WRITE_RESP;
            elsif write_time_cnt >= write_timeout then
              state_write <= ST_WRITE_RESP;
            end if;
          when ST_WRITE_EXT_BUSY =>
            write_time_cnt <= write_time_cnt + 1;

            if ext_awready = '1' then
              ext_awvalid  <= '0';
            end if;

            if ext_wready = '1' then
              ext_wvalid <= '0';
            end if;

            if ext_bvalid = '1' then
              ext_bready <= '0';
              state_write <= ST_WRITE_RESP;
            elsif write_time_cnt >= write_timeout then
              state_write <= ST_WRITE_RESP;
            end if;
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
        waddr      <= pi_s_top.awaddr(G_ADDR_WIDTH-1 downto 0) ;
        reg_wr_stb <= (others => '0');
        case waddr_int is
          when 192 =>
             wtarget  <= REG;
             reg_wr_stb(48) <= '1';
          when 200 =>
             wtarget  <= REG;
             reg_wr_stb(50) <= '1';
          when 204 =>
             wtarget  <= REG;
             reg_wr_stb(51) <= '1';
          when 224 =>
             wtarget  <= REG;
             reg_wr_stb(56) <= '1';
          when 228 =>
             wtarget  <= REG;
             reg_wr_stb(57) <= '1';
          when 4096 to 8191 =>
             wtarget  <= MEM;
             mem_wr_stb(0) <= '1';
             mem_wr_req <= '1';
          when 8192 to 12287 =>
             wtarget  <= MEM;
             mem_wr_stb(1) <= '1';
             mem_wr_req <= '1';
          when 12288 to 16383 =>
             wtarget  <= MEM;
             mem_wr_stb(2) <= '1';
             mem_wr_req <= '1';
          when 16384 to 20479 =>
             wtarget  <= MEM;
             mem_wr_stb(3) <= '1';
             mem_wr_req <= '1';
          when 20480 to 20599 =>
             wtarget  <= EXT;
             ext_wr_stb(0) <= '1';
          when 32768 to 49151 =>
             wtarget  <= EXT;
             ext_wr_stb(1) <= '1';
          when 49152 to 49159 =>
             wtarget  <= EXT;
             ext_wr_stb(2) <= '1';
          when 49280 to 49359 =>
             wtarget  <= EXT;
             ext_wr_stb(3) <= '1';
          when others =>
             wtarget    <= NONE;
        end case;

      elsif state_write = ST_WRITE_RESP then
        reg_wr_stb <= (others => '0');
        ext_wr_stb <= (others => '0');
        mem_wr_stb <= (others => '0');
        mem_wr_req <= '0';
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
        wstrb <= pi_s_top.wstrb;
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
  -- ===========================================================================
  -- Dual-port memories
  --
  -- AXI address is addressing bytes
  -- DPM address is addressing the memory data width (up to 4 bytes)
  -- DPM data width is the same as the AXI data width
  -- currently only DPM interface supported with read/write arbiter
  -- write afer read
  ------------------------------------------------------------------------------
  blk_mem : block
    signal l_rd_stb : std_logic_vector(4-1 downto 0) := (others => '0');
    signal l_wr_stb : std_logic_vector(4-1 downto 0) := (others => '0');
    signal l_wr_trn : std_logic := '0';
    signal l_rd_ack : std_logic := '0';
    signal l_wr_ack : std_logic := '0';
  begin

    prs_rdwr_arb: process(pi_clock)
    begin
      if rising_edge(pi_clock) then

        -- write transaction indicate
        if mem_wr_req = '1' and mem_rd_req = '0' then
          l_wr_trn <= '1';
          po_mem_stb <= mem_wr_stb;
          po_mem_we  <= '1';
        elsif mem_wr_req = '0' then
          l_wr_trn <= '0';
          po_mem_stb <= mem_rd_stb;
          po_mem_we  <= '0';
        end if;

        -- read has higher priority, but do not disturb pending write transaction
        -- mem_rd_req goes to 0 for 1 clock cycle after each read transaction - write grant
        if mem_rd_req = '1' and l_wr_trn = '0' and l_rd_ack = '0' then
          if  mem_rd_stb(0) = '1' then
            po_mem_addr(12-3 downto 0) <= raddr(12-1 downto 2);
            po_mem_addr(G_ADDR_WIDTH-1 downto 12-2) <= (others => '0');
          end if;
          if  mem_rd_stb(1) = '1' then
            po_mem_addr(12-3 downto 0) <= raddr(12-1 downto 2);
            po_mem_addr(G_ADDR_WIDTH-1 downto 12-2) <= (others => '0');
          end if;
          if  mem_rd_stb(2) = '1' then
            po_mem_addr(12-3 downto 0) <= raddr(12-1 downto 2);
            po_mem_addr(G_ADDR_WIDTH-1 downto 12-2) <= (others => '0');
          end if;
          if  mem_rd_stb(3) = '1' then
            po_mem_addr(12-3 downto 0) <= raddr(12-1 downto 2);
            po_mem_addr(G_ADDR_WIDTH-1 downto 12-2) <= (others => '0');
          end if;
          l_rd_ack   <= pi_mem_ack;

        elsif mem_wr_req = '1'  and l_wr_ack = '0' then
          if  mem_wr_stb(0) = '1' then
            po_mem_addr(12-3 downto 0) <= waddr(12-1 downto 2);
            po_mem_addr(G_ADDR_WIDTH-1 downto 12-2) <= (others => '0');
          end if;
          if  mem_wr_stb(1) = '1' then
            po_mem_addr(12-3 downto 0) <= waddr(12-1 downto 2);
            po_mem_addr(G_ADDR_WIDTH-1 downto 12-2) <= (others => '0');
          end if;
          if  mem_wr_stb(2) = '1' then
            po_mem_addr(12-3 downto 0) <= waddr(12-1 downto 2);
            po_mem_addr(G_ADDR_WIDTH-1 downto 12-2) <= (others => '0');
          end if;
          if  mem_wr_stb(3) = '1' then
            po_mem_addr(12-3 downto 0) <= waddr(12-1 downto 2);
            po_mem_addr(G_ADDR_WIDTH-1 downto 12-2) <= (others => '0');
          end if;
          l_wr_ack   <= pi_mem_ack;

        elsif mem_rd_req = '0' and mem_wr_req = '0' then
          l_rd_ack   <= '0';
          l_wr_ack   <= '0';
        end if;
      end if;
    end process prs_rdwr_arb;

    mem_wr_ack <= l_wr_ack;
    mem_rd_ack <= l_rd_ack when rising_edge(pi_clock);
    -- delay read ack due to synch process of po_mem_addr and po_mem_stb,
    -- read requires one more clock cycle to get data back from memory
    -- possible in future: change of interface to use pi_mem_ack
    po_mem_data <= wdata ;
    rdata_mem   <= pi_mem_data ;

  end block;
  -- ===========================================================================
  -- external buses -- the same type as upstream bus: axi4l
  ------------------------------------------------------------------------------
  ----------------------------
    po_ext(0).arvalid                                  <= ext_arvalid and ext_rd_stb(0);
    po_ext(0).araddr(7 - 1 downto 0)   <= raddr(7 - 1 downto 0);
    po_ext(0).araddr(po_ext(0).araddr'left downto 7) <= (others => '0');
    po_ext(0).arprot                                   <= (others => '0');
    po_ext(0).rready                                   <= ext_rready; -- and ext_rd_stb(0);
    -- po_ext(0).rready                                <= pi_s_top.rready and ext_rd_stb(0);
    po_ext(0).awvalid                                  <= ext_awvalid and ext_wr_stb(0);
    po_ext(0).awaddr(7 - 1 downto 0)   <= waddr(7 - 1 downto 0);
    po_ext(0).awaddr(po_ext(0).awaddr'left downto 7) <= (others => '0');
    po_ext(0).awprot                                   <= (others => '0');
    po_ext(0).wvalid                                   <= ext_wvalid and ext_wr_stb(0);
    po_ext(0).wdata(31 downto 0)                       <= wdata;
    po_ext(0).wstrb(3 downto 0)                        <= wstrb;
    po_ext(0).bready                                   <= ext_bready;-- and ext_wr_stb(idx);
  -----------------------------
    po_ext(1).arvalid                                  <= ext_arvalid and ext_rd_stb(1);
    po_ext(1).araddr(14 - 1 downto 0)   <= raddr(14 - 1 downto 0);
    po_ext(1).araddr(po_ext(1).araddr'left downto 14) <= (others => '0');
    po_ext(1).arprot                                   <= (others => '0');
    po_ext(1).rready                                   <= ext_rready; -- and ext_rd_stb(1);
    -- po_ext(1).rready                                <= pi_s_top.rready and ext_rd_stb(1);
    po_ext(1).awvalid                                  <= ext_awvalid and ext_wr_stb(1);
    po_ext(1).awaddr(14 - 1 downto 0)   <= waddr(14 - 1 downto 0);
    po_ext(1).awaddr(po_ext(1).awaddr'left downto 14) <= (others => '0');
    po_ext(1).awprot                                   <= (others => '0');
    po_ext(1).wvalid                                   <= ext_wvalid and ext_wr_stb(1);
    po_ext(1).wdata(31 downto 0)                       <= wdata;
    po_ext(1).wstrb(3 downto 0)                        <= wstrb;
    po_ext(1).bready                                   <= ext_bready;-- and ext_wr_stb(idx);
  -----------------------------
    po_ext(2).arvalid                                  <= ext_arvalid and ext_rd_stb(2);
    po_ext(2).araddr(3 - 1 downto 0)   <= raddr(3 - 1 downto 0);
    po_ext(2).araddr(po_ext(2).araddr'left downto 3) <= (others => '0');
    po_ext(2).arprot                                   <= (others => '0');
    po_ext(2).rready                                   <= ext_rready; -- and ext_rd_stb(2);
    -- po_ext(2).rready                                <= pi_s_top.rready and ext_rd_stb(2);
    po_ext(2).awvalid                                  <= ext_awvalid and ext_wr_stb(2);
    po_ext(2).awaddr(3 - 1 downto 0)   <= waddr(3 - 1 downto 0);
    po_ext(2).awaddr(po_ext(2).awaddr'left downto 3) <= (others => '0');
    po_ext(2).awprot                                   <= (others => '0');
    po_ext(2).wvalid                                   <= ext_wvalid and ext_wr_stb(2);
    po_ext(2).wdata(31 downto 0)                       <= wdata;
    po_ext(2).wstrb(3 downto 0)                        <= wstrb;
    po_ext(2).bready                                   <= ext_bready;-- and ext_wr_stb(idx);
  -----------------------------
    po_ext(3).arvalid                                  <= ext_arvalid and ext_rd_stb(3);
    po_ext(3).araddr(7 - 1 downto 0)   <= raddr(7 - 1 downto 0);
    po_ext(3).araddr(po_ext(3).araddr'left downto 7) <= (others => '0');
    po_ext(3).arprot                                   <= (others => '0');
    po_ext(3).rready                                   <= ext_rready; -- and ext_rd_stb(3);
    -- po_ext(3).rready                                <= pi_s_top.rready and ext_rd_stb(3);
    po_ext(3).awvalid                                  <= ext_awvalid and ext_wr_stb(3);
    po_ext(3).awaddr(7 - 1 downto 0)   <= waddr(7 - 1 downto 0);
    po_ext(3).awaddr(po_ext(3).awaddr'left downto 7) <= (others => '0');
    po_ext(3).awprot                                   <= (others => '0');
    po_ext(3).wvalid                                   <= ext_wvalid and ext_wr_stb(3);
    po_ext(3).wdata(31 downto 0)                       <= wdata;
    po_ext(3).wstrb(3 downto 0)                        <= wstrb;
    po_ext(3).bready                                   <= ext_bready;-- and ext_wr_stb(idx);
  -----------------------------

  prs_ext_rd_mux: process(ext_rd_stb,pi_ext)
  begin
    ext_arready <= '0';
    ext_rvalid  <= '0';
    rdata_ext   <= (others => '0');
    if ext_rd_stb(0) = '1' then
      ext_arready <= pi_ext(0).arready;
      ext_rvalid  <= pi_ext(0).rvalid;
      rdata_ext   <= pi_ext(0).rdata;
    end if;
    if ext_rd_stb(1) = '1' then
      ext_arready <= pi_ext(1).arready;
      ext_rvalid  <= pi_ext(1).rvalid;
      rdata_ext   <= pi_ext(1).rdata;
    end if;
    if ext_rd_stb(2) = '1' then
      ext_arready <= pi_ext(2).arready;
      ext_rvalid  <= pi_ext(2).rvalid;
      rdata_ext   <= pi_ext(2).rdata;
    end if;
    if ext_rd_stb(3) = '1' then
      ext_arready <= pi_ext(3).arready;
      ext_rvalid  <= pi_ext(3).rvalid;
      rdata_ext   <= pi_ext(3).rdata;
    end if;
  end process prs_ext_rd_mux;

  prs_ext_wr_mux: process(ext_wr_stb,pi_ext)
  begin
    ext_awready <= '0';
    ext_wready  <= '0';
    ext_bvalid  <= '0';
    if ext_wr_stb(0) = '1' then
      ext_awready <= pi_ext(0).awready;
      ext_wready  <= pi_ext(0).wready;
      ext_bvalid  <= pi_ext(0).bvalid;
    end if;
    if ext_wr_stb(1) = '1' then
      ext_awready <= pi_ext(1).awready;
      ext_wready  <= pi_ext(1).wready;
      ext_bvalid  <= pi_ext(1).bvalid;
    end if;
    if ext_wr_stb(2) = '1' then
      ext_awready <= pi_ext(2).awready;
      ext_wready  <= pi_ext(2).wready;
      ext_bvalid  <= pi_ext(2).bvalid;
    end if;
    if ext_wr_stb(3) = '1' then
      ext_awready <= pi_ext(3).awready;
      ext_wready  <= pi_ext(3).wready;
      ext_bvalid  <= pi_ext(3).bvalid;
    end if;
  end process prs_ext_wr_mux;

end architecture arch;
