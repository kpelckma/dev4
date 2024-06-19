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
--! @date 2022-02-08
--! @author Holger Kay <holger.kay@desy.de>
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! AXI.4 Interconnect (Multiple AXI.4 Managers connecting to a a single AXI Subordinate )
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

library desy;
use desy.common_axi.all;

entity axi4_mux is
  generic (
    G_DATA_WIDTH        : natural := 32; -- number of bits of the data port
    G_S_PORT_NUM        : natural := 4;  -- number of AXI4 slave ports
    G_S_PORT_ID_WIDTH   : natural := 8;
    -- G_S_PORT_ID_WIDTH: number of ID bits used on the slave ports (ARID, AWID, RID) ,
    -- should be smaler then ID width of master port, master ID width > G_S_PORT_ID_WIDTH + CEIL(LOG2(G_S_PORT_NUM))
    G_M_PORT_ADD_BUF    : natural := 1  -- add 2 register buffer on master port
  );
  port (
    pi_aclk     : in  std_logic;
    pi_areset_n : in  std_logic;

    -- Manager port     (Bus Outputs)
    po_m_axi4          : out t_axi4_m2s;
    pi_m_axi4          : in  t_axi4_s2m;
    po_m_axi4_aclk     : out std_logic;
    po_m_axi4_areset_n : out std_logic;

    -- Subordinate ports (Bus Inputs)
    pi_s_axi4   : in t_axi4_m2s_vector(G_S_PORT_NUM-1 downto 0);
    po_s_axi4   : out t_axi4_s2m_vector(G_S_PORT_NUM-1 downto 0)
  );
-- preserve synthesis optimization which brakes handshaking functionality
-- attribute KEEP_HIERARCHY : string;
-- attribute KEEP_HIERARCHY of axi4_mux : entity is "yes";
end axi4_mux;

architecture rtl of axi4_mux is

  constant C_ADD_ID_LEN : natural := integer(ceil(log2(real(G_S_PORT_NUM))));

  signal  r_m2s_p_m : t_axi4_m2s := C_AXI4_M2S_DEFAULT;
  signal  r_s2m_p_m : t_axi4_s2m;
  signal  r_m2s_m   : t_axi4_m2s := C_AXI4_M2S_DEFAULT;
  signal  r_s2m_m   : t_axi4_s2m;
  signal  r_m2s_s   : t_axi4_m2s_vector(G_S_PORT_NUM-1 downto 0);
  signal  r_s2m_s   : t_axi4_s2m_vector(G_S_PORT_NUM-1 downto 0) := (others => C_AXI4_S2M_DEFAULT);

begin

  --===========================================================================
  -- AXI ports

  po_s_axi4 <= r_s2m_s;
  r_m2s_s <= pi_s_axi4;

  po_m_axi4_aclk     <= pi_aclk;
  po_m_axi4_areset_n <= pi_areset_n;

  r_m2s_m.bready <= pi_areset_n;

  --===========================================================================
  --! register master port, 1 register buffer, make out sync
  --===========================================================================
  blk_m_buf: if G_M_PORT_ADD_BUF = 1 generate
  begin

    ins_axi4_buf: entity desy.axi4_buf
      generic map (
        G_DATA_WIDTH => G_DATA_WIDTH,
        G_ID_WIDTH   => C_ADD_ID_LEN+G_S_PORT_ID_WIDTH
      )
      port map (
        pi_areset_n   => pi_areset_n,
        pi_aclk       => pi_aclk,

        po_m_axi4 => r_m2s_p_m,
        pi_m_axi4 => r_s2m_p_m,
        pi_s_axi4 => r_m2s_m,
        po_s_axi4 => r_s2m_m
      );

    po_m_axi4 <=  R_M2S_P_M;
    R_S2M_P_M <=  pi_m_axi4;

  end generate;

  blk_m_nobuf: if G_M_PORT_ADD_BUF = 0 generate
  begin
    po_m_axi4 <= R_M2S_M;
    r_s2m_m   <= pi_m_axi4;
  end generate;

  --===========================================================================
  --! Write Channel Arbier
  --===========================================================================
  blk_wr_arb : block
    signal aw_strb    : std_logic_vector(G_S_PORT_NUM-1 downto 0) := ( others => '0' );
    signal w_strb     : std_logic_vector(G_S_PORT_NUM-1 downto 0) := ( others => '0' );
    signal l_awready  : std_logic_vector(G_S_PORT_NUM-1 downto 0) := ( others => '0' );
    signal l_wready   : std_logic_vector(G_S_PORT_NUM-1 downto 0) := ( others => '0' );
    signal l_req      : std_logic_vector(G_S_PORT_NUM-1 downto 0) := ( others => '0' );
    signal l_grant    : std_logic_vector(G_S_PORT_NUM-1 downto 0) := ( others => '0' );
    signal l_ack      : std_logic := '0' ;
    signal l_reset    : std_logic := '0' ;
  begin

    l_reset <= not pi_areset_n;

    ins_arbiter:  entity desy.arbiter_round_robin
      generic map (
        G_NUM => G_S_PORT_NUM
      )
      port  map (
        pi_clock => pi_aclk,
        pi_reset => l_reset,
        pi_req   => l_req,
        pi_ack   => l_ack,
        po_grant => l_grant
      );

    gen_loc_signals: for i in 0 to G_S_PORT_NUM-1 generate
      -- l_req(i)     <= r_m2s_s(i).awvalid or r_m2s_s(i).wvalid;
      r_s2m_s(i).awready <= l_awready(i);
      r_s2m_s(i).wready  <= l_wready(i) ;

      process(pi_aclk,pi_areset_n)
      begin
          if (pi_areset_n = '0') then
            aw_strb(I) <= '0';
            w_strb(I)  <= '0';
            l_req(I) <= '0' ;
          elsif rising_edge(pi_aclk) then

            -- request access when there is AW address valid and write data valid
            -- if (aw_strb(I) = '0' and w_strb(I) = '0' and  R_M2S_S(I).AWVALID = '1' and  R_M2S_S(I).WVALID = '1' ) then
            -- request when there is aw ready
            if (aw_strb(i) = '0' and w_strb(i) = '0' and  r_m2s_s(i).awvalid = '1' ) then
              -- if r_m2s_s(i).awvalid = '1' then
              w_strb(i)  <= '1';
              aw_strb(i) <= '1';
              l_req(i) <= '1' ;
              -- end if;
            else
              if r_m2s_s(i).awvalid = '1' and l_awready(i) = '1' then
                aw_strb(i) <= '0';
                -- w_strb(i)  <= '1';
              else
                aw_strb(i) <= aw_strb(i);
              end if;

              if r_m2s_s(i).wlast = '1'  and r_m2s_s(i).wvalid = '1'  and l_wready(i) = '1' then
                w_strb(i)  <= '0';
                l_req(i) <= '0' ;
              else
                w_strb(i)  <= w_strb(i)  ;
                l_req(i) <= l_req(i) ;
              end if;
            end if;
          -- end if;
        end if;
      end process;
    end generate;

    proc_mux_aw : process(l_grant,r_m2s_s,r_s2m_m,aw_strb)
    begin
      -- default
      r_m2s_m.awid      <= ( others => '0' ) ;
      r_m2s_m.awaddr    <= ( others => '0' ) ;
      r_m2s_m.awlen     <= ( others => '0' ) ;
      r_m2s_m.awsize    <= ( others => '0' ) ;
      r_m2s_m.awburst   <= ( others => '0' ) ;
      r_m2s_m.awvalid   <= '0' ;
      l_awready   <= ( others => '0' ) ;

      -- dependency on grant
      for i in 0 to G_S_PORT_NUM-1 loop
        -- if l_grant(I) = '1' and aw_strb(I) = '1' then
        if l_grant(I) = '1' then
          r_m2s_m.awid(C_ADD_ID_LEN+G_S_PORT_ID_WIDTH-1 downto 0) <= std_logic_vector(to_unsigned(i,C_ADD_ID_LEN)) & r_m2s_s(i).awid(G_S_PORT_ID_WIDTH-1 downto 0);
          r_m2s_m.awaddr      <= r_m2s_s(i).awaddr;
          r_m2s_m.awlen       <= r_m2s_s(i).awlen;
          r_m2s_m.awsize      <= r_m2s_s(i).awsize;
          r_m2s_m.awburst     <= r_m2s_s(i).awburst;
          r_m2s_m.awvalid     <= r_m2s_s(i).awvalid and aw_strb(i) ;
          l_awready(i)        <= r_s2m_m.awready and aw_strb(i) ;
        end if;
      end loop;
    end process;

    proc_mux_w : process(l_grant,r_m2s_s,r_s2m_m,w_strb)
    begin
      r_m2s_m.wdata  <= ( others => '0' ) ;
      r_m2s_m.wstrb  <= ( others => '0' ) ;
      r_m2s_m.wlast  <= '0' ;
      r_m2s_m.wvalid <= '0' ;
      l_wready       <= ( others => '0' ) ;
      l_ack          <= '0' ;

      for i in 0 to G_S_PORT_NUM-1 loop
        -- if l_grant(I) = '1' and w_strb(I) = '1' then
        if l_grant(i) = '1' then
          r_m2s_m.wdata       <= r_m2s_s(i).wdata;
          r_m2s_m.wstrb       <= r_m2s_s(i).wstrb;
          r_m2s_m.wlast       <= r_m2s_s(i).wlast;
          r_m2s_m.wvalid      <= r_m2s_s(i).wvalid and w_strb(i);
          l_wready(i)   <= r_s2m_m.wready and w_strb(i);

          l_ack         <= r_m2s_s(i).wlast  and r_m2s_s(i).wvalid  and r_s2m_m.wready and w_strb(i) ;
        end if;

      end loop;
    end process;

  end block;
  --===========================================================================


  --===========================================================================
  --! Read Address Arbier
  --===========================================================================
  blk_ard_arb : block
    signal l_arready : std_logic_vector(G_S_PORT_NUM-1 downto 0);
    signal l_rready  : std_logic_vector(G_S_PORT_NUM-1 downto 0);
    signal l_req     : std_logic_vector(G_S_PORT_NUM-1 downto 0);
    signal l_grant   : std_logic_vector(G_S_PORT_NUM-1 downto 0);
    signal l_ack     : std_logic;
    signal l_reset   : std_logic;
  begin
    l_reset <= not pi_areset_n;

    ins_arbiter: entity desy.arbiter_round_robin
      generic map (
        G_NUM => G_S_PORT_NUM
      )
      port  map (
        pi_clock  => pi_aclk,
        pi_reset  => l_reset,
        pi_req    => l_req,
        pi_ack    => l_ack,
        po_grant  => l_grant
      );

    gen_loc_signals: for i in 0 to G_S_PORT_NUM-1 generate
      l_req(i)     <= r_m2s_s(i).arvalid ;
      r_s2m_s(i).arready <= l_arready(i);
    end generate;

    proc_mux : process(l_grant,r_m2s_s,r_s2m_m)
    begin
      -- defaults
      r_m2s_m.arid    <= (others => '0');
      r_m2s_m.araddr  <= (others => '0');
      r_m2s_m.arlen   <= (others => '0');
      r_m2s_m.arsize  <= (others => '0');
      r_m2s_m.arburst <= (others => '0');
      r_m2s_m.arvalid <= '0';
      l_arready       <= (others => '0');
      l_ack           <= '0';
      -- Dependency on grant
      for i in 0 to G_S_PORT_NUM-1 loop
        if l_grant(i) = '1' then
          r_m2s_m.arid(C_ADD_ID_LEN+G_S_PORT_ID_WIDTH-1 downto 0) <= std_logic_vector(to_unsigned(i,C_ADD_ID_LEN)) & r_m2s_s(i).arid(G_S_PORT_ID_WIDTH-1 downto 0);
          r_m2s_m.araddr  <= r_m2s_s(i).araddr;
          r_m2s_m.arlen   <= r_m2s_s(i).arlen;
          r_m2s_m.arsize  <= r_m2s_s(i).arsize;
          r_m2s_m.arburst <= r_m2s_s(i).arburst;
          r_m2s_m.arvalid <= r_m2s_s(i).arvalid;
          l_arready(i)    <= r_s2m_m.arready;
          l_ack           <= r_m2s_s(i).arvalid and r_s2m_m.arready;
        end if;
      end loop;
    end process;
  end block;


  --===========================================================================
  --! Read Data Channel Arbier
  --===========================================================================
  blk_rd_arb : block
    signal s2m_rready_vec  : std_logic_vector(G_S_PORT_NUM-1 downto 0);
    signal reg_r_arb           : natural range 0 to G_S_PORT_NUM := G_S_PORT_NUM;
  begin

    r_m2s_m.rready  <= or_reduce( s2m_rready_vec );

    process(pi_aclk)
    begin
      if rising_edge(pi_aclk) then
        if (reg_r_arb /= G_S_PORT_NUM and r_s2m_m.rlast = '1' and r_s2m_m.rvalid = '1' and r_m2s_m.rready = '1') or pi_areset_n = '0' then
          reg_r_arb <= G_S_PORT_NUM;
        else

          if (reg_r_arb = G_S_PORT_NUM and r_s2m_m.rvalid = '1') then
            reg_r_arb <= to_integer( unsigned(R_S2M_M.RID(C_ADD_ID_LEN + G_S_PORT_ID_WIDTH-1 downto G_S_PORT_ID_WIDTH )) );
          else
            reg_r_arb <= reg_r_arb;
          end if;
          -- elsif (REG_R_ARB /= G_S_PORT_NUM and R_S2M_M.RLAST = '1' and R_S2M_M.RVALID = '1' and R_M2S_M.RREADY = '1') then

            -- REG_R_ARB <= G_S_PORT_NUM;
          -- end if;

        end if;
      end if;
    end process;

    gen_r_s: for i in 0 to G_S_PORT_NUM-1 generate
      r_s2m_s(i).rid(G_S_PORT_ID_WIDTH-1 downto 0) <= r_s2m_m.rid(G_S_PORT_ID_WIDTH-1 downto 0) ;
      r_s2m_s(i).rdata  <= r_s2m_m.rdata  ;
      r_s2m_s(i).rlast  <= r_s2m_m.rlast  ;
      r_s2m_s(i).rresp  <= r_s2m_m.rresp  ;
      r_s2m_s(i).rvalid <= r_s2m_m.rvalid when (reg_r_arb = i) else '0';

      s2m_rready_vec(i) <= r_m2s_s(i).rready when (reg_r_arb = i) else '0';
    end generate;
  end block;

end rtl;
