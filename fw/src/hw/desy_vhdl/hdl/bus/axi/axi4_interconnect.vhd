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
--! @date 2021-10-03
--! @author Holger Kay <holger.kay@desy.de>
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! AXI4 interconnect
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library desy;
use desy.common_types.all;
use desy.common_axi.all;
use desy.pkg_fifo.all;

entity axi4_interconnect is
  generic (
    G_M_PORT_NUM      : natural := 2;                 -- number of master ports
    G_M_PORT_FIFO_ENA : t_natural_vector := (0 => 1); -- enable FIFO buffer on master ports
    G_ARCH_TYPE       : string  := "VIRTEX6";         -- "VIRTEX6","VIRTEX5","7SERIES","GENERIC",
    G_DATA_WIDTH      : natural := 32;                -- number of bits of the data port
    G_ID_WIDTH        : natural := 8;                 -- number of ID bits (ARID, AWID, RID)
    -- divides address
    G_ARB_ADDR_LOW      : t_32b_slv_vector := (0 => x"10000000");
    G_ARB_ADDR_HIGH     : t_32b_slv_vector := (0 => x"1FFFFFFF");
    G_ADDR_MASK_SIMPLE  : natural :=  0;  -- enable simple address masking, truncate MSB bits in G_ADDR_MASK_BITS size
    G_ADDR_MASK_BITS    : natural := 24   -- ADDR_M(G_ADDR_MASK_BITS-1 downto 0) <= ADDR_S(G_ADDR_MASK_BITS-1 downto 0)
  );
  port (
    pi_areset_n : in  std_logic;
    -- Subordinate port
    pi_s_axi4_aclk : in  std_logic;
    pi_s_axi4      : in  t_axi4_m2s;
    po_s_axi4      : out t_axi4_s2m;
    -- Manager ports
    pi_m_axi4_aclk : in  std_logic_vector(G_MASTER_NUM-1 downto 0);
    po_m_axi4      : out t_axi4_m2s_vector(G_MASTER_NUM-1 downto 0);
    pi_m_axi4      : in  t_axi4_s2m_vector(G_MASTER_NUM-1 downto 0);

    po_debug : out std_logic_vector(255 downto 0)
  );

  -- preserve synthesis optimization which brakes handshaking functionality
  attribute KEEP_HIERARCHY : string;
  attribute KEEP_HIERARCHY of axi4_interconnect : entity is "YES";

end axi4_interconnect;

architecture rtl of axi4_interconnect is

  constant C_WSTRB_WIDTH    : natural := (G_DATA_WIDTH / 8);
  constant C_W_FIFO_WIDTH   : natural := G_DATA_WIDTH + C_WSTRB_WIDTH +1;
  constant C_R_FIFO_WIDTH   : natural := G_ID_WIDTH + G_DATA_WIDTH + 1;
  constant C_AR_FIFO_WIDTH  : natural := G_ID_WIDTH + 45;
  constant C_AW_FIFO_WIDTH  : natural := G_ID_WIDTH + 45;

  type t_r_dout_array is array (natural range<>) of std_logic_vector(C_R_FIFO_WIDTH-1 downto 0) ;

  signal reset     : std_logic := '1' ;
  signal rst_del_n : std_logic_vector(7 downto 0) := (others => '1');

  signal s2m_arready_vec : std_logic_vector(G_MASTER_NUM downto 0) := (others => '0') ;

  signal r_data         : t_r_dout_array(G_MASTER_NUM downto 0)   := (others => (others => '0')) ;
  signal s2m_rvalid_vec : std_logic_vector(G_MASTER_NUM downto 0) := (others => '0');
  signal ar_arb         : natural range 0 to G_MASTER_NUM := G_MASTER_NUM;
  signal r_arb          : natural range 0 to G_MASTER_NUM := G_MASTER_NUM;

  signal s2m_awready_vec : std_logic_vector(G_MASTER_NUM downto 0) := (others => '0') ;

  signal s2m_wready_vec : std_logic_vector(G_MASTER_NUM downto 0) := (others => '0') ;
  signal aw_arb         : natural range 0 to G_MASTER_NUM := G_MASTER_NUM;
  signal w_arb          : natural range 0 to G_MASTER_NUM := G_MASTER_NUM;

  signal r_m2s_s : t_axi4_m2s := C_AXI4_M2S_DEFAULT;
  signal r_s2m_s : t_axi4_s2m := C_AXI4_S2M_DEFAULT;

  signal r_m2s_m_vec : t_axi4_m2s_vector(G_MASTER_NUM-1 downto 0) := (others => C_AXI4_M2S_DEFAULT);
  signal r_s2m_m_vec : t_axi4_s2m_vector(G_MASTER_NUM-1 downto 0) := (others => C_AXI4_S2M_DEFAULT);

  signal araddr : std_logic_vector(31 downto 0):= (others => '0') ;
  signal awaddr : std_logic_vector(31 downto 0):= (others => '0') ;

  type t_rd_arb_state is (ST_DECODE_ADDR,
                            ST_READ_ADDR,
                            ST_READ_DATA,
                            ST_ADDR_NOT_KNOWN);

  type t_wr_arb_state is (ST_DECODE_ADDR,
                            ST_READ_ADDR,
                            ST_READ_DATA,
                            ST_ADDR_NOT_KNOWN,
                            ST_ADDR_NOT_KNOWN_DROP_DATA);

  signal rd_arb_state : t_rd_arb_state := ST_DECODE_ADDR;
  signal wr_arb_state : t_wr_arb_state := ST_DECODE_ADDR;

------------------------------------------------------------------------------
  -- attribute KEEP                        : string;
  -- attribute EQUIVALENT_REGISTER_REMOVAL : string;

  -- attribute KEEP of reset                         : signal is "TRUE";
  -- attribute EQUIVALENT_REGISTER_REMOVAL of reset  : signal is "NO";
------------------------------------------------------------------------------
begin

   -- po_debug(10 downto 8) <= SIG_AR_FIFO_WREN(2 downto 0) ;

  -- po_debug(27 downto 24) <= std_logic_vector(to_unsigned(w_arb,4)) ;
  -- po_debug(31 downto 28) <= std_logic_vector(to_unsigned(r_arb,4)) ;

  -- po_debug(0 ) <= R_S2M_S.ARREADY ;
  -- po_debug(1 ) <= R_S2M_S.AWREADY ;
  -- po_debug(2 ) <= R_S2M_S.WREADY  ;
  -- po_debug(3 ) <= R_S2M_S.RVALID  ;
  -- po_debug(4 ) <= r_m2s_s.ARVALID ;
  -- po_debug(5 ) <= r_m2s_s.AWVALID ;
  -- po_debug(6 ) <= r_m2s_s.WVALID  ;
  -- po_debug(7 ) <= r_m2s_s.RREADY ;
  -- po_debug(8 ) <= R_M2S_M_VEC(0).ARVALID ;
  -- po_debug(9 ) <= R_M2S_M_VEC(1).ARVALID ;
  -- po_debug(10) <= R_S2M_M_VEC(0).ARREADY ;
  -- po_debug(11) <= R_S2M_M_VEC(1).ARREADY ;
  -- po_debug(12) <= R_M2S_M_VEC(0).AWVALID ;
  -- po_debug(13) <= R_M2S_M_VEC(1).AWVALID ;
  -- po_debug(14) <= R_S2M_M_VEC(0).AWREADY ;
  -- po_debug(15) <= R_S2M_M_VEC(1).AWREADY ;
  -- po_debug(16) <= R_M2S_M_VEC(0).WVALID ;
  -- po_debug(17) <= R_M2S_M_VEC(1).WVALID ;
  -- po_debug(18) <= R_S2M_M_VEC(0).WREADY ;
  -- po_debug(19) <= R_S2M_M_VEC(1).WREADY ;
  -- po_debug(20) <= R_S2M_M_VEC(0).RVALID ;
  -- po_debug(21) <= R_S2M_M_VEC(1).RVALID ;
  -- po_debug(22) <= R_M2S_M_VEC(0).RREADY ;
  -- po_debug(23) <= R_M2S_M_VEC(1).RREADY ;

  -- po_debug(255 downto 224) <= r_m2s_s.ARADDR ;
  -- po_debug(223 downto 192) <= r_m2s_s.AWADDR ;


  -- AXI ports
  po_s_axi4 <= r_s2m_s;
  r_m2s_s   <= pi_s_axi4;

  po_m_axi4   <= r_m2s_m_vec;
  r_s2m_m_vec <= pi_m_axi4;

  --===========================================================================
  --! generate sychronous reset signal

  -- areset_n <= pi_areset_n ;

  process(pi_axi4_s_aclk,pi_areset_n)
  begin
      if (pi_areset_n = '0') then
        rst_del_n <= (others => '0');
      elsif (rising_edge(pi_axi4_s_aclk)) then
        rst_del_n       <= '1' & rst_del_n(7 downto 1);
        -- reset         <= SIG_RST_DEL(0);
      end if;
  end process;

  r_s2m_s.areset_n  <= rst_del_n(0) when rising_edge(pi_axi4_s_aclk);
  reset <= not rst_del_n(0) when rising_edge(pi_axi4_s_aclk);

  r_s2m_s.aclk      <=  pi_axi4_s_aclk;

  --===========================================================================
  --! BRESP and RRESP are optional and not completely supported in this implementation
  r_s2m_s.rresp <= C_AXI4_RESP_OKAY;
  r_s2m_s.bresp <= C_AXI4_RESP_OKAY;

  process(pi_axi4_s_aclk) -- generate BID and BVALID
  begin
      if rising_edge(pi_axi4_s_aclk) then

        if (r_m2s_s.awvalid = '1' and r_s2m_s.awready = '1') then
            r_s2m_s.bid <= r_m2s_s.awid;
        end if;

        if (reset = '1') then
            r_s2m_s.bvalid <= '0';
        elsif (r_s2m_s.bvalid = '0' and r_m2s_s.wvalid = '1' and r_s2m_s.wready = '1') then
            r_s2m_s.bvalid <= '1';
        elsif (r_s2m_s.bvalid = '1' and r_m2s_s.bready = '1') then
            r_s2m_s.bvalid <= '0';
        end if;

      end if;
  end process;

  --===========================================================================
  --! Address mask
  gen_simple_addr_mask: if G_ADDR_MASK_SIMPLE = 1 generate
    araddr(G_ADDR_MASK_BITS-1 downto 0) <= r_m2s_s.araddr(G_ADDR_MASK_BITS-1 downto 0);-- when rising_edge(pi_axi4_s_aclk);
    awaddr(G_ADDR_MASK_BITS-1 downto 0) <= r_m2s_s.awaddr(G_ADDR_MASK_BITS-1 downto 0);-- when rising_edge(pi_axi4_s_aclk);
  end generate;

  gen_addr_mask: if G_ADDR_MASK_SIMPLE = 0 generate
    process(pi_axi4_s_aclk)
    begin
      if rising_edge(pi_axi4_s_aclk) then
        for I in 0 to G_MASTER_NUM-1 loop
          if r_m2s_s.araddr >= G_ARB_ADDR_LOW(I) and G_ARB_ADDR_HIGH(I) >= r_m2s_s.araddr and r_m2s_s.arvalid = '1' then
            araddr <= r_m2s_s.araddr and (G_ARB_ADDR_HIGH(I) xor G_ARB_ADDR_LOW(I));
          end if;
        end loop;
      end if;
    end process;

    process(pi_axi4_s_aclk)
    begin
      if rising_edge(pi_axi4_s_aclk) then
        for I in 0 to G_MASTER_NUM-1 loop
          if r_m2s_s.awaddr >= G_ARB_ADDR_LOW(I) and G_ARB_ADDR_HIGH(I) >= r_m2s_s.awaddr and r_m2s_s.awvalid = '1' then
            awaddr <= r_m2s_s.awaddr and (G_ARB_ADDR_HIGH(I) xor G_ARB_ADDR_LOW(I));
          end if;
        end loop;
      end if;
    end process;

  end generate;

  --===========================================================================
  --!- Read Channel Arbiter
  blk_rd_arb : block
  begin

    process(pi_axi4_s_aclk, r_s2m_s.areset_n)
    begin
        if r_s2m_s.areset_n = '0' then
          rd_arb_state <= ST_DECODE_ADDR;
          ar_arb       <= G_MASTER_NUM;
          r_arb        <= G_MASTER_NUM;
        elsif rising_edge(pi_axi4_s_aclk) then

          case rd_arb_state is
            ---------------------------------------
            when ST_DECODE_ADDR =>

              r_arb  <= G_MASTER_NUM;
              ar_arb <= G_MASTER_NUM;
              for i in 0 to G_MASTER_NUM-1 loop
                if r_m2s_s.araddr >= G_ARB_ADDR_LOW(i) and G_ARB_ADDR_HIGH(i) >= r_m2s_s.araddr and r_m2s_s.ARVALID = '1' then
                  ar_arb        <= i;
                  rd_arb_state  <= ST_READ_ADDR;
                -- elsif r_m2s_s.ARVALID = '1' then
                  -- rd_arb_state  <= ST_ADDR_NOT_KNOWN ;
                -- else
                  -- r_arb <= G_MASTER_NUM;
                end if;
              end loop;

            ---------------------------------------
            when ST_READ_ADDR =>

              if s2m_arready_vec(ar_arb) = '1' then
                r_arb         <= ar_arb ;
                ar_arb        <= G_MASTER_NUM;
                rd_arb_state  <= ST_READ_DATA ;
              end if;

            ---------------------------------------
            when ST_READ_DATA =>
              if R_s2m_s.rlast = '1' and r_s2m_s.rvalid = '1' and r_m2s_s.rready = '1' then
                r_arb         <= G_MASTER_NUM;
                rd_arb_state  <= ST_DECODE_ADDR ;
              end if;

            ---------------------------------------
            ---------------------------------------
            -- when ST_ADDR_NOT_KNOWN =>

              -- r_arb         <= G_MASTER_NUM;
              -- rd_arb_state  <= ST_DECODE_ADDR ;

            when others =>
              rd_arb_state <= ST_DECODE_ADDR;
          end case;
        -- end if;
      end if;
    end process;

    r_s2m_s.arready <=  s2m_arready_vec(ar_arb);
    r_s2m_s.rvalid  <=  s2m_rvalid_vec(r_arb);

    -- R_S2M_S.ARREADY <=  s2m_arready_vec(r_arb) when rd_arb_state = ST_READ_ADDR else
                        -- '1' when rd_arb_state = ST_ADDR_NOT_KNOWN else
                        -- '0' ;


    -- R_S2M_S.RVALID  <=  s2m_rvalid_vec(r_arb)  when rd_arb_state = ST_READ_DATA else
                        -- '0' ;

    r_s2m_s.rdata(G_DATA_WIDTH-1 downto 0) <= r_data(r_arb)(G_ID_WIDTH+G_DATA_WIDTH downto G_ID_WIDTH+1);
    r_s2m_s.rid(G_ID_WIDTH-1 downto 0)     <= r_data(r_arb)(G_ID_WIDTH downto 1);
    r_s2m_s.rlast                          <= r_data(r_arb)(0);

  end block;

  --===========================================================================
  --! Write Channel Arbiter
  blk_wr_arb : block
  begin

    process(pi_axi4_s_aclk, R_S2M_S.ARESET_N)
    begin
      if r_s2m_s.areset_n = '0'  then
          wr_arb_state <= ST_DECODE_ADDR ;
          aw_arb       <= G_MASTER_NUM;
          w_arb        <= G_MASTER_NUM;

      elsif rising_edge(pi_axi4_s_aclk) then

          case wr_arb_state is
            ---------------------------------------
            when ST_DECODE_ADDR =>

              w_arb  <= G_MASTER_NUM;
              aw_arb <= G_MASTER_NUM;
              for i in 0 to G_MASTER_NUM-1 loop
                if r_m2s_s.awaddr >= G_ARB_ADDR_LOW(i) and G_ARB_ADDR_HIGH(i) >= r_m2s_s.awaddr and r_m2s_s.awvalid = '1' then
                  aw_arb        <= i;
                  wr_arb_state  <= ST_READ_ADDR ;
                -- elsif r_m2s_s.AWVALID = '1' then
                  -- w_arb         <= G_MASTER_NUM;
                  -- wr_arb_state  <= ST_ADDR_NOT_KNOWN ;
                -- else
                  -- w_arb <= G_MASTER_NUM;
                end if;
              end loop;

            ---------------------------------------
            when ST_READ_ADDR =>

              if s2m_awready_vec(aw_arb) = '1' then
                w_arb         <= aw_arb ;
                aw_arb        <= G_MASTER_NUM;
                wr_arb_state  <= ST_READ_DATA ;
              end if;

            ---------------------------------------
            when ST_READ_DATA =>
              if r_m2s_s.wlast = '1' and r_m2s_s.wvalid = '1' and r_s2m_s.wready = '1' then
                w_arb         <= G_MASTER_NUM;
                wr_arb_state  <= ST_DECODE_ADDR ;
              end if;

            ---------------------------------------
            ---------------------------------------
            -- when ST_ADDR_NOT_KNOWN =>

              -- if r_m2s_s.WLAST = '1' and r_m2s_s.WVALID = '1' and R_S2M_S.WREADY = '1'  then
                -- w_arb         <= G_MASTER_NUM;
                -- wr_arb_state  <= ST_DECODE_ADDR ;
              -- else
                -- wr_arb_state  <= ST_READ_DATA ;
              -- end if;

            -- ---------------------------------------
            -- when ST_ADDR_NOT_KNOWN_DROP_DATA =>
              -- if r_m2s_s.WLAST = '1' and r_m2s_s.WVALID = '1' and R_S2M_S.WREADY = '1' then
                -- w_arb         <= G_MASTER_NUM;
                -- wr_arb_state  <= ST_DECODE_ADDR ;
              -- end if;

            when others =>
              wr_arb_state <= ST_DECODE_ADDR;
          end case;
        -- end if;
      end if;
    end process;

    -- R_S2M_S.WREADY  <=  --s2m_wready_vec(w_arb)  when wr_arb_state = ST_READ_ADDR else
                        -- s2m_wready_vec(w_arb)  when wr_arb_state = ST_READ_DATA else
                        -- '1'  when wr_arb_state = ST_ADDR_NOT_KNOWN else
                        -- '1'  when wr_arb_state = ST_ADDR_NOT_KNOWN_DROP_DATA else
                        -- '0' ;

    -- R_S2M_S.AWREADY <=  s2m_awready_vec(w_arb) when wr_arb_state = ST_READ_ADDR else
                        -- '1' when wr_arb_state = ST_ADDR_NOT_KNOWN else
                        -- '0' ;
    r_s2m_s.wready  <= s2m_wready_vec(w_arb) ;
    r_s2m_s.awready <= s2m_awready_vec(aw_arb) ;

  end block;

  --===========================================================================
  -------- generate FiFo's and arbiters for each master port --------
  gen_master : for i in 0 to G_MASTER_NUM - 1 generate
  begin

    gen_fifo: if G_MASTER_FIFO_ENA(I) = 1 generate
      signal  l_ar_data_i   : std_logic_vector(C_AR_FIFO_WIDTH-1 downto 0);
      signal  l_ar_data_o   : std_logic_vector(C_AR_FIFO_WIDTH-1 downto 0);
      signal  l_ar_rd_clk   : std_logic := '0' ;
      signal  l_ar_wr_clk   : std_logic := '0' ;
      signal  l_ar_wr_ena   : std_logic := '0' ;
      signal  l_ar_rd_ena   : std_logic := '0' ;
      signal  l_ar_empty    : std_logic := '0' ;
      signal  l_ar_full     : std_logic := '0' ;

      signal  l_aw_data_i   : std_logic_vector(C_AW_FIFO_WIDTH-1 downto 0);
      signal  l_aw_data_o   : std_logic_vector(C_AW_FIFO_WIDTH-1 downto 0);
      signal  l_aw_rd_clk   : std_logic := '0' ;
      signal  l_aw_wr_clk   : std_logic := '0' ;
      signal  l_aw_wr_ena   : std_logic := '0' ;
      signal  l_aw_rd_ena   : std_logic := '0' ;
      signal  l_aw_empty    : std_logic := '0' ;
      signal  l_aw_full     : std_logic := '0' ;

      signal  l_w_data_i    : std_logic_vector(C_W_FIFO_WIDTH-1 downto 0);
      signal  l_w_data_o    : std_logic_vector(C_W_FIFO_WIDTH-1 downto 0);
      signal  l_w_rd_clk    : std_logic := '0' ;
      signal  l_w_wr_clk    : std_logic := '0' ;
      signal  l_w_wr_ena    : std_logic := '0' ;
      signal  l_w_rd_ena    : std_logic := '0' ;
      signal  l_w_empty     : std_logic := '0' ;
      signal  l_w_full      : std_logic := '0' ;

      signal  l_r_data_i    : std_logic_vector(C_R_FIFO_WIDTH-1 downto 0);
      signal  l_r_data_o    : std_logic_vector(C_R_FIFO_WIDTH-1 downto 0);
      signal  l_r_rd_clk    : std_logic := '0' ;
      signal  l_r_wr_clk    : std_logic := '0' ;
      signal  l_r_wr_ena    : std_logic := '0' ;
      signal  l_r_rd_ena    : std_logic := '0' ;
      signal  l_r_empty     : std_logic := '0' ;
      signal  l_r_full      : std_logic := '0' ;

    begin

      r_m2s_m_vec(i).bready <= '1' ;-- ready to receive response (bresp)

      r_m2s_m_vec(i).aclk <= pi_axi4_m_aclk(i);

      r_m2s_m_vec(i).areset_n <= '0' when (reset = '1') else '1' when rising_edge(pi_axi4_m_aclk(i));

      ------------- Data Read fifo for each master port -------------
        ins_r_fifo: entity desy.fifo
          generic map (
            G_FIFO_DEPTH               => 32,
            G_FIFO_WIDTH               => C_R_FIFO_WIDTH,
            G_FIFO_READ_WIDTH          => C_R_FIFO_WIDTH,
            G_FIFO_WRITE_WIDTH         => C_R_FIFO_WIDTH,
            G_FIFO_TYPE                => G_ARCH_TYPE,
            G_FIFO_FWFT                => 1,
            G_FIFO_PROG_FULL_OFFSET    => 26,
            G_FIFO_PROG_EMPTY_OFFSET   => 0
          )
          port map (
            pi_reset   => reset,
            pi_int_clk => '0',--pi_axi4_s_aclk, --internal clock not used, small FIFO, one LAYER

            pi_wr_clk => l_r_wr_clk,
            pi_wr_ena => l_r_wr_ena,
            pi_data   => l_r_data_i,
            po_full   => l_r_full,

            pi_rd_clk => l_r_rd_clk,
            pi_rd_ena => l_r_rd_ena,
            po_data   => l_r_data_o,
            po_empty  => l_r_empty
          );

      l_r_wr_clk <= pi_axi4_m_aclk(i);
      l_r_wr_ena <= r_s2m_m_vec(i).rvalid and r_m2s_m_vec(i).rready;
      l_r_data_i(G_ID_WIDTH+G_DATA_WIDTH downto G_ID_WIDTH+1) <= r_s2m_m_vec(i).rdata(G_DATA_WIDTH-1 downto 0);
      l_r_data_i(G_ID_WIDTH downto 1) <= r_s2m_m_vec(i).rid(G_ID_WIDTH-1 downto 0);
      l_r_data_i(0) <= r_s2m_m_vec(i).rlast;

      l_r_rd_clk <= pi_axi4_s_aclk;
      r_data(I) <= l_r_data_o ;
      l_r_rd_ena <= (r_m2s_s.RREADY and not l_r_empty ) when (r_arb = I) else '0';
      -- l_r_rd_ena      <= SIG_R_FIFO_RDEN(I);
      s2m_rvalid_vec(I) <= not l_r_empty; --when (r_arb = I) else '0' ;
      r_m2s_m_vec(i).rready <= not l_r_full;

      ------------- Address Read fifo for each master port -------------
        ins_ar_fifo: entity desy.fifo
          generic map (
            G_FIFO_DEPTH             => 32,
            G_FIFO_WIDTH             => C_AR_FIFO_WIDTH,
            G_FIFO_READ_WIDTH        => C_AR_FIFO_WIDTH,
            G_FIFO_WRITE_WIDTH       => C_AR_FIFO_WIDTH,
            G_FIFO_TYPE              => G_ARCH_TYPE,
            G_FIFO_FWFT              => 1,
            G_FIFO_PROG_FULL_OFFSET  => 26,
            G_FIFO_PROG_EMPTY_OFFSET => 0
          )
          port map (
            pi_reset   => reset,
            pi_int_clk => '0',--pi_axi4_s_aclk, --internal clock not used, small FIFO, one LAYER

            pi_wr_clk => l_ar_wr_clk,
            pi_wr_ena => l_ar_wr_ena,
            pi_data   => l_ar_data_i,
            po_full   => l_ar_full,

            pi_rd_clk => l_ar_rd_clk,
            pi_rd_ena => l_ar_rd_ena,
            po_data   => l_ar_data_o,
            po_empty  => l_ar_empty
          );

      -- fifo out to master port
      l_ar_rd_clk <= pi_axi4_m_aclk(I);

      l_ar_rd_ena <= r_s2m_m_vec(i).arready and not l_ar_empty;

      l_ar_data_i(G_ID_WIDTH+44 downto 45) <= r_m2s_s.arid(G_ID_WIDTH-1 downto 0);
      l_ar_data_i(44 downto 42)            <= r_m2s_s.arsize;
      l_ar_data_i(41 downto 40)            <= r_m2s_s.arburst;
      l_ar_data_i(39 downto 32)            <= r_m2s_s.arlen;
      l_ar_data_i(31 downto 0)             <= araddr;

      r_m2s_m_vec(i).arid(G_ID_WIDTH-1 downto 0) <= l_ar_data_o(G_ID_WIDTH+44 downto 45);
      r_m2s_m_vec(i).arsize                      <= l_ar_data_o(44 downto 42);
      r_m2s_m_vec(i).arburst                     <= l_ar_data_o(41 downto 40);
      r_m2s_m_vec(i).arlen                       <= l_ar_data_o(39 downto 32);
      r_m2s_m_vec(i).araddr                      <= l_ar_data_o(31 downto 0);
      r_m2s_m_vec(i).arvalid                     <= not l_ar_empty;

      l_ar_wr_clk <= pi_axi4_s_aclk ;
      l_ar_wr_ena <= (r_m2s_s.ARVALID and not l_ar_full) when (ar_arb = I) else '0';

      s2m_arready_vec(I) <= not l_ar_full ;--when (r_arb = I) else '0';
      -- SIG_AR_FIFO_FULL(I) <= l_ar_full;

      ------------- Address Write fifo for each master port -------------
        ins_aw_fifo: entity work.fifo
          generic map (
            G_FIFO_DEPTH             => 32,
            G_FIFO_WIDTH             => C_AW_FIFO_WIDTH,
            G_FIFO_READ_WIDTH        => C_AW_FIFO_WIDTH,
            G_FIFO_WRITE_WIDTH       => C_AW_FIFO_WIDTH,
            G_FIFO_TYPE              => G_ARCH_TYPE,
            G_FIFO_FWFT              => 1,
            G_FIFO_PROG_FULL_OFFSET  => 26,
            G_FIFO_PROG_EMPTY_OFFSET => 0
          )
          port map (
            pi_reset   => reset,
            pi_int_clk => '0',--pi_axi4_s_aclk,--internal clock not used, small FIFO, one LAYER

            pi_wr_clk => l_aw_wr_clk,
            pi_wr_ena => l_aw_wr_ena,
            pi_data   => l_aw_data_i,
            po_full   => l_aw_full,

            pi_rd_clk => l_aw_rd_clk,
            pi_rd_ena => l_aw_rd_ena,
            po_data   => l_aw_data_o,
            po_empty  => l_aw_empty
          );

      -- fifo out to master port
      l_aw_rd_clk <= pi_axi4_m_aclk(i);
      l_aw_rd_ena <= r_s2m_m_vec(i).awready and r_m2s_m_vec(i).awvalid;

      l_aw_data_i(G_ID_WIDTH+44 downto 45) <= r_m2s_s.awid(G_ID_WIDTH-1 downto 0);
      l_aw_data_i(44 downto 42)            <= r_m2s_s.awsize;
      l_aw_data_i(41 downto 40)            <= r_m2s_s.awburst;
      l_aw_data_i(39 downto 32)            <= r_m2s_s.awlen;
      l_aw_data_i(31 downto 0)             <= awaddr;

      r_m2s_m_vec(i).awid(G_ID_WIDTH-1 downto 0) <= l_aw_data_o(G_ID_WIDTH+44 downto 45);
      r_m2s_m_vec(i).awsize                      <= l_aw_data_o(44 downto 42);
      r_m2s_m_vec(i).awburst                     <= l_aw_data_o(41 downto 40);
      r_m2s_m_vec(i).awlen                       <= l_aw_data_o(39 downto 32);
      r_m2s_m_vec(i).awaddr                      <= l_aw_data_o(31 downto 0);
      r_m2s_m_vec(i).awvalid <= not l_aw_empty;

      l_aw_wr_clk <= pi_axi4_s_aclk;
      l_aw_wr_ena <= (r_m2s_s.awvalid and not l_aw_full) when (aw_arb = I) else '0';

      s2m_awready_vec(I) <= not l_aw_full;-- when (w_arb = I) else '0';
      -- SIG_AW_FIFO_FULL(I) <= l_aw_full ;

      ------------- Data Write fifo for each master port -------------
        ins_w_fifo: entity desy.fifo
          generic map (
            G_FIFO_DEPTH               => 32,
            G_FIFO_WIDTH               => C_W_FIFO_WIDTH,
            G_FIFO_READ_WIDTH          => C_W_FIFO_WIDTH,
            G_FIFO_WRITE_WIDTH         => C_W_FIFO_WIDTH,
            G_FIFO_TYPE                => G_ARCH_TYPE,
            G_FIFO_FWFT                => 1,
            G_FIFO_PROG_FULL_OFFSET    => 26,
            G_FIFO_PROG_EMPTY_OFFSET   => 0
          )
          port map (
            pi_reset  => reset,
            pi_int_clk => '0',--pi_axi4_s_aclk,--internal clock not used, small FIFO, one LAYER

            pi_wr_clk  => l_w_wr_clk,
            pi_wr_ena  => l_w_wr_ena,
            pi_data    => l_w_data_i,
            po_full    => l_w_full,

            pi_rd_clk  => l_w_rd_clk,
            pi_rd_ena  => l_w_rd_ena,
            po_data    => l_w_data_o,
            po_empty   => l_w_empty
          );

      -- fifo out to master port
      l_w_rd_clk <= pi_axi4_m_aclk(I);
      l_w_rd_ena <= r_s2m_m_vec(i).wready and r_m2s_m_vec(i).wvalid;

      l_w_data_i(G_DATA_WIDTH+C_WSTRB_WIDTH downto G_DATA_WIDTH+1) <= r_m2s_s.wstrb(C_WSTRB_WIDTH-1 downto 0);
      l_w_data_i(G_DATA_WIDTH downto 1)                            <= r_m2s_s.wdata(G_DATA_WIDTH-1 downto 0);
      l_w_data_i(0)                                                <= r_m2s_s.wlast;

      r_m2s_m_vec(i).wstrb(C_WSTRB_WIDTH-1 downto 0) <= l_w_data_o(G_DATA_WIDTH+C_WSTRB_WIDTH downto G_DATA_WIDTH+1);
      r_m2s_m_vec(i).wdata(G_DATA_WIDTH-1 downto 0)  <= l_w_data_o(G_DATA_WIDTH downto 1);
      r_m2s_m_vec(i).wlast                           <= l_w_data_o(0);
      r_m2s_m_vec(i).wvalid                          <= not l_w_empty;

      l_w_wr_clk <= pi_axi4_s_aclk;
      l_w_wr_ena <= (r_m2s_s.wvalid and not l_w_full ) when (w_arb = i) else '0';

      s2m_wready_vec(I) <= not l_w_full; -- when (w_arb = I) else '0';

    end generate;
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    gen_no_fifo: if G_MASTER_FIFO_ENA(I) = 0 generate

      r_m2s_m_vec(i).bready <= '1' ;-- ready to receive response (bresp)

      r_m2s_m_vec(i).aclk <= pi_axi4_m_aclk(i);

      r_m2s_m_vec(i).areset_n <= '0' when (reset = '1') else '1' when rising_edge(pi_axi4_m_aclk(i));

      -- R
      r_data(I)(G_ID_WIDTH+G_DATA_WIDTH downto G_ID_WIDTH+1) <= r_s2m_m_vec(i).rdata(G_DATA_WIDTH-1 downto 0);
      r_data(I)(G_ID_WIDTH downto 1)                         <= r_s2m_m_vec(i).rid(G_ID_WIDTH-1 downto 0);
      r_data(I)(0)                                           <= r_s2m_m_vec(i).rlast;
      s2m_rvalid_vec(i)                                      <= r_s2m_m_vec(i).rvalid ;-- when (r_arb = i) else '0' ;
      r_m2s_m_vec(i).rready                                  <= r_m2s_s.rready when (r_arb = i) else '0';

      --- AR
      r_m2s_m_vec(i).arid(G_ID_WIDTH-1 downto 0) <= r_m2s_s.arid(G_ID_WIDTH-1 downto 0);
      r_m2s_m_vec(i).arsize                      <= r_m2s_s.arsize;
      r_m2s_m_vec(i).arburst                     <= r_m2s_s.arburst;
      r_m2s_m_vec(i).arlen                       <= r_m2s_s.arlen;
      r_m2s_m_vec(i).araddr                      <= araddr;
      r_m2s_m_vec(i).arvalid                     <= r_m2s_s.arvalid when (ar_arb = i) else '0';
      s2m_arready_vec(i)                         <= r_s2m_m_vec(i).arready;-- when (r_arb = i) else '0';

      -- AW
      r_m2s_m_vec(i).awid(G_ID_WIDTH-1 downto 0) <= r_m2s_s.awid(G_ID_WIDTH-1 downto 0);
      r_m2s_m_vec(i).awsize                      <= r_m2s_s.awsize;
      r_m2s_m_vec(i).awburst                     <= r_m2s_s.awburst;
      r_m2s_m_vec(i).awlen                       <= r_m2s_s.awlen;
      r_m2s_m_vec(i).awaddr                      <= awaddr;
      r_m2s_m_vec(i).awvalid                     <= r_m2s_s.awvalid when (aw_arb = i) else '0';
      s2m_awready_vec(i)                         <= r_s2m_m_vec(i).awready;-- when (w_arb = i) else '0';

      -- W
      r_m2s_m_vec(i).wstrb(C_WSTRB_WIDTH-1 downto 0) <= r_m2s_s.wstrb(C_WSTRB_WIDTH-1 downto 0);
      r_m2s_m_vec(i).wdata(G_DATA_WIDTH-1 downto 0)  <= r_m2s_s.wdata(G_DATA_WIDTH-1 downto 0);
      r_m2s_m_vec(i).wlast                           <= r_m2s_s.wlast;
      r_m2s_m_vec(i).wvalid                          <= r_m2s_s.WVALID when (w_arb = I) else '0';
      s2m_wready_vec(I)                              <= r_s2m_m_vec(i).wready;-- when (w_arb = i) else '0';

    end generate;

  end generate;

end rtl;
