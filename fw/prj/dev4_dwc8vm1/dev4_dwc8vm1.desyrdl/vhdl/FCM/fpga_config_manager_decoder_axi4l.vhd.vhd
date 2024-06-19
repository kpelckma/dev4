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

entity fpga_config_manager_decoder_axi4l is
  generic (
    G_ADDR_WIDTH    : integer := 32;
    G_DATA_WIDTH    : integer := 32
  );
  port (
    pi_clock  : in std_logic;
    pi_reset  : in std_logic;
    --
    po_reg_rd_stb  : out std_logic_vector(17-1 downto 0);
    po_reg_wr_stb  : out std_logic_vector(17-1 downto 0);
    po_reg_data    : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    pi_reg_data    : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    --
    --
    --
    po_mem_stb     : out std_logic_vector(2-1 downto 0);
    po_mem_we      : out std_logic;
    po_mem_addr    : out std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    po_mem_data    : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    pi_mem_data    : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    pi_mem_ack     : in  std_logic;
    --
    --
    pi_s_reset : in std_logic;
    pi_s_top   : in  t_axi4l_m2s ;
    po_s_top   : out t_axi4l_s2m
);
end entity fpga_config_manager_decoder_axi4l;

architecture arch of fpga_config_manager_decoder_axi4l is

  type t_target is (REG, MEM,  NONE );

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
    ST_WRITE_RESP
  );
  signal state_write : t_state_write;

  signal wdata     : std_logic_vector(G_DATA_WIDTH-1 downto 0) := (others => '0');
  signal wstrb     : std_logic_vector(G_DATA_WIDTH/8-1 downto 0) := (others => '0');
  signal waddr     : std_logic_vector(G_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal waddr_int : integer;

  -----------------------------------------------------------
  signal reg_rd_stb  : std_logic_vector(17-1 downto 0) := (others => '0');
  signal reg_wr_stb  : std_logic_vector(17-1 downto 0) := (others => '0');

  -- external bus
  signal mem_rd_stb  : std_logic_vector(2-1 downto 0) := (others => '0');
  signal mem_rd_req  : std_logic := '0';
  signal mem_rd_ack  : std_logic := '0';
  signal mem_wr_stb  : std_logic_vector(2-1 downto 0) := (others => '0');
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
        read_time_cnt <= 0;
        invalid_rdata <= '0';
      else
        case state_read is
          when ST_READ_IDLE =>

            if pi_s_top.arvalid = '1' then
              state_read <= ST_READ_SELECT;
            end if;
            read_time_cnt <= 0;
            invalid_rdata <= '0';
          when ST_READ_SELECT =>
            case rtarget is
              when REG =>
                state_read <= ST_READ_VALID;
              when MEM =>
                state_read <= ST_READ_MEM_BUSY;
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
  prs_rdata_mux: process(rtarget,rdata_reg,rdata_mem,invalid_rdata)
  begin
    if invalid_rdata = '1' then
      po_s_top.rdata <= (others => '0' ) ;
    elsif rtarget = REG then
      po_s_top.rdata <= rdata_reg ;
    elsif rtarget = MEM then
      po_s_top.rdata <= rdata_mem ;
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
        raddr      <= pi_s_top.araddr(G_ADDR_WIDTH-1 downto 0);
        reg_rd_stb <= (others => '0');
        case raddr_int is
          when 8192 =>
             rtarget  <= REG;
             reg_rd_stb(0) <= '1';
          when 8204 =>
             rtarget  <= REG;
             reg_rd_stb(1) <= '1';
          when 8208 =>
             rtarget  <= REG;
             reg_rd_stb(2) <= '1';
          when 8212 =>
             rtarget  <= REG;
             reg_rd_stb(3) <= '1';
          when 8216 =>
             rtarget  <= REG;
             reg_rd_stb(4) <= '1';
          when 8220 =>
             rtarget  <= REG;
             reg_rd_stb(5) <= '1';
          when 8224 =>
             rtarget  <= REG;
             reg_rd_stb(6) <= '1';
          when 8228 =>
             rtarget  <= REG;
             reg_rd_stb(7) <= '1';
          when 8248 =>
             rtarget  <= REG;
             reg_rd_stb(8) <= '1';
          when 8252 =>
             rtarget  <= REG;
             reg_rd_stb(9) <= '1';
          when 8256 =>
             rtarget  <= REG;
             reg_rd_stb(10) <= '1';
          when 8260 =>
             rtarget  <= REG;
             reg_rd_stb(11) <= '1';
          when 8264 =>
             rtarget  <= REG;
             reg_rd_stb(12) <= '1';
          when 8268 =>
             rtarget  <= REG;
             reg_rd_stb(13) <= '1';
          when 8288 =>
             rtarget  <= REG;
             reg_rd_stb(14) <= '1';
          when 8304 =>
             rtarget  <= REG;
             reg_rd_stb(15) <= '1';
          when 8308 =>
             rtarget  <= REG;
             reg_rd_stb(16) <= '1';
          when 0 to 4095 =>
             rtarget  <= MEM;
             mem_rd_stb(0) <= '1';
             mem_rd_req <= '1';
          when 4096 to 8191 =>
             rtarget  <= MEM;
             mem_rd_stb(1) <= '1';
             mem_rd_req <= '1';
          when others =>
             rtarget    <= NONE;
        end case;

      elsif state_read = ST_READ_DONE then
        reg_rd_stb <= (others => '0');
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
          when 8192 =>
             wtarget  <= REG;
             reg_wr_stb(0) <= '1';
          when 8204 =>
             wtarget  <= REG;
             reg_wr_stb(1) <= '1';
          when 8208 =>
             wtarget  <= REG;
             reg_wr_stb(2) <= '1';
          when 8212 =>
             wtarget  <= REG;
             reg_wr_stb(3) <= '1';
          when 8216 =>
             wtarget  <= REG;
             reg_wr_stb(4) <= '1';
          when 8220 =>
             wtarget  <= REG;
             reg_wr_stb(5) <= '1';
          when 8224 =>
             wtarget  <= REG;
             reg_wr_stb(6) <= '1';
          when 8252 =>
             wtarget  <= REG;
             reg_wr_stb(9) <= '1';
          when 8256 =>
             wtarget  <= REG;
             reg_wr_stb(10) <= '1';
          when 0 to 4095 =>
             wtarget  <= MEM;
             mem_wr_stb(0) <= '1';
             mem_wr_req <= '1';
          when 4096 to 8191 =>
             wtarget  <= MEM;
             mem_wr_stb(1) <= '1';
             mem_wr_req <= '1';
          when others =>
             wtarget    <= NONE;
        end case;

      elsif state_write = ST_WRITE_RESP then
        reg_wr_stb <= (others => '0');
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
    signal l_rd_stb : std_logic_vector(2-1 downto 0) := (others => '0');
    signal l_wr_stb : std_logic_vector(2-1 downto 0) := (others => '0');
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

end architecture arch;
