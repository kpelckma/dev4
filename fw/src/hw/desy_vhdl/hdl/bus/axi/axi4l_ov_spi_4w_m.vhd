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
--! @date 2023-01-31
--! @author Katharina Schulz <katharina.schulz@desy.de>
--! Lukasz Butkowski <lukasz.butkowski@desy.de>
--------------------------------------------------------------------------------
--! @brief SPI subordinate with m_axi4l IF and custoum modification
--! TO DO: Define Protocol
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_types.all;
use desy.common_axi.all;

entity axi4l_ov_spi_4w_m is
  generic (
    G_TIMEOUT     : natural := 256;
    G_CPOL        : natural := 0;
    G_AXI4L_ADDR_WIDTH : natural := 32;
    G_AXI4L_DATA_WIDTH : natural := 32
  );
  port (
    pi_clock      : in    std_logic;
    pi_reset      : in    std_logic;
    -- AXI4 Subordinate Interface
    pi_s_axi4l    : in    t_axi4l_m2s := C_AXI4L_M2S_DEFAULT;
    po_s_axi4l    : out   t_axi4l_s2m := C_AXI4L_S2M_DEFAULT;
    -- SPI Manager Interface
    po_m_sclk     : out   std_logic; -- serial clock
    po_m_cs_n     : out   std_logic; -- chip select low activ
    po_m_mosi     : out   std_logic; -- serial data output
    pi_m_miso     : in    std_logic  -- serial data input
  );

  -- preserve synthesis optimization which brakes handshaking functionality
  attribute keep_hierarchy : string;
  attribute keep_hierarchy of axi4l_ov_spi_4w_m : entity is "YES";
end entity axi4l_ov_spi_4w_m;

architecture rtl of axi4l_ov_spi_4w_m is

  type t_state is (
    ST_IDLE,
    ST_WAIT_WADDR,
    ST_WAIT_WDATA,
    ST_SHIFT,
    ST_READ_DATA,
    ST_WRITE_DATA,
    ST_WRITE_RESP,
    ST_READ_DATA_PUSH
  );

  signal state               : t_state := ST_IDLE;

  signal s2m                 : t_axi4l_s2m := C_AXI4L_S2M_DEFAULT;                         -- output data from spi IF

  signal timeout             : natural := 0;
  signal read_clk_cyc        : natural := 0;

  constant C_REG_SHIFT_WIDTH : natural     := G_AXI4L_ADDR_WIDTH + G_AXI4L_DATA_WIDTH; -- +1 bit for r/w indication
  signal   spi_reg_shift_out : std_logic_vector(C_REG_SHIFT_WIDTH downto 0) := (others => '0');
  signal   spi_reg_shift_in  : std_logic_vector(G_AXI4L_DATA_WIDTH downto 0) := (others => '0');

  signal read_not_write      : std_logic := '0';

  signal w_addr              : std_logic_vector(G_AXI4L_ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal w_data              : std_logic_vector(G_AXI4L_DATA_WIDTH - 1 downto 0) := (others => '0');
  signal aw_valid            : std_logic := '0';
  signal m_spi_awready       : std_logic := '1';
  signal m_spi_awvalid       : std_logic := '0';
  signal m_spi_wready        : std_logic := '1';
  signal m_spi_wvalid        : std_logic := '0';
  signal w_response          : std_logic_vector(C_AXI4_RESP_OKAY'length-1 downto 0) := C_AXI4_RESP_OKAY;
  signal b_valid             : std_logic := '0';

  signal r_addr              : std_logic_vector(G_AXI4L_ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal r_data              : std_logic_vector(G_AXI4L_DATA_WIDTH - 1 downto 0) := (others => '0');
  signal m_spi_arready       : std_logic := '1';
  signal m_spi_arvalid       : std_logic := '1';
  signal m_spi_rvalid        : std_logic := '0';

  signal mosi                : std_logic := '0';
  signal spi_clk_ena         : std_logic := '0';
  signal cs_n                : std_logic := '1';

begin

  -- unsed AXI4L Signals: m2s.AWPROT  m2s.WSTRB  m2s.ARPROT
  po_s_axi4l <= s2m;

  ------------------------------------------------------------------------------
  -- Write Address channel
  ------------------------------------------------------------------------------
  ins_axi_buf_aw : entity desy.axi4_buf_sch
    generic map (
      g_data_width => G_AXI4L_ADDR_WIDTH
    )
    port map (
      pi_aclk => pi_clock,

      po_m_ready => s2m.AWREADY,
      pi_m_valid => pi_s_axi4l.AWVALID,
      pi_m_data  => pi_s_axi4l.awaddr,

      pi_s_ready => m_spi_awready,
      po_s_valid => m_spi_awvalid,
      po_s_data  => w_addr
    );

  ------------------------------------------------------------------------------
  -- Read Address channel
  ------------------------------------------------------------------------------
  ins_axi_buf_ar : entity desy.axi4_buf_sch
    generic map (
      g_data_width => G_AXI4L_ADDR_WIDTH
    )
    port map (
      pi_aclk => pi_clock,

      po_m_ready => s2m.ARREADY,
      pi_m_valid => pi_s_axi4l.ARVALID,
      pi_m_data  => pi_s_axi4l.araddr,

      pi_s_ready => m_spi_arready,
      po_s_valid => m_spi_arvalid,
      po_s_data  => r_addr
    );

  ------------------------------------------------------------------------------
  -- Write Data Channel
  ------------------------------------------------------------------------------
  ins_axi_buf_w : entity desy.axi4_buf_sch
    generic map (
      g_data_width => G_AXI4L_DATA_WIDTH
    )
    port map (
      pi_aclk => pi_clock,

      po_m_ready => s2m.WREADY,
      pi_m_valid => pi_s_axi4l.WVALID,
      pi_m_data  => pi_s_axi4l.wdata,

      pi_s_ready => m_spi_wready,
      po_s_valid => m_spi_wvalid,
      po_s_data  => w_data
    );

  ------------------------------------------------------------------------------
  -- Write Response Data Channel
  ------------------------------------------------------------------------------
  ins_axi_buf_b : entity desy.axi4_buf_sch
    generic map (
      g_data_width => C_AXI4_RESP_OKAY'length
    )
    port map (
      pi_aclk => pi_clock,

      po_m_ready => open,
      pi_m_valid => b_valid,
      pi_m_data  => w_response,

      pi_s_ready => pi_s_axi4l.BREADY,
      po_s_valid => s2m.BVALID,
      po_s_data  => s2m.BRESP
    );

  ------------------------------------------------------------------------------
  -- Read Data channel
  ------------------------------------------------------------------------------
  ins_axi_buf_r : entity desy.axi4_buf_sch
    generic map (
      g_data_width => G_AXI4L_DATA_WIDTH
    )
    port map (
      pi_aclk => pi_clock,

      po_m_ready => open,
      pi_m_valid => m_spi_rvalid,
      pi_m_data  => r_data,

      pi_s_ready => pi_s_axi4l.RREADY,
      po_s_valid => s2m.RVALID,
      po_s_data  => s2m.RDATA
    );

  ------------------------------------------------------------------------------
  -- SPI Setting
  ------------------------------------------------------------------------------
  po_m_cs_n <= '0' when spi_clk_ena = '1' else '1';

  gen_cpol_0 : if G_CPOL = 0 generate

    prs_ena_clk : process (spi_clk_ena, pi_clock) is
    begin

      if (spi_clk_ena = '1') then
        po_m_sclk <= not pi_clock;
        po_m_mosi <= mosi;
      else
        po_m_sclk <= '0';
        po_m_mosi <= '0';
      end if;

    end process prs_ena_clk;

  end generate gen_cpol_0;

  gen_cpol_1 : if G_CPOL = 1 generate

    prs_ena_clk : process (spi_clk_ena, pi_clock) is
    begin

      if (spi_clk_ena = '1') then
        po_m_sclk <= pi_clock;
        po_m_mosi <= mosi;
      else
        po_m_sclk <= '1';
        po_m_mosi <= '0';
      end if;

    end process prs_ena_clk;

  end generate gen_cpol_1;

  ------------------------------------------------------------------------------
  -- FSM
  ------------------------------------------------------------------------------
  prs_fsm : process (pi_clock) is
  begin

    if rising_edge(pi_clock) then
      if (pi_reset = '1') then
        state             <= ST_IDLE;
        m_spi_awready     <= '1';
        m_spi_wready      <= '1';
        w_response        <= (others => '0');
        b_valid           <= '0';
        -- m_spi_arready     <= '1';
        m_spi_rvalid      <= '0';
        mosi              <= '0';
        spi_clk_ena       <= '0';
        -- cs_n              <= '1';
        timeout           <= 0;
        read_clk_cyc      <= 0;
        r_data            <= (others => '0');
        spi_reg_shift_out <= (others => '0');
        read_not_write    <= '0';
        spi_reg_shift_in  <= (others => '0');
      else

        case state is

          -------------------------------------
          when ST_IDLE =>
            -- m_spi_awready     <= '1';
            -- m_spi_wready      <= '1';
            w_response        <= (others => '0');
            b_valid           <= '0';
            -- m_spi_arready     <= '1';
            m_spi_rvalid      <= '0';
            mosi              <= '0';
            spi_clk_ena       <= '0';
            -- cs_n              <= '1';
            timeout           <= 0;
            read_clk_cyc      <= 0;
            r_data            <= (others => '0');
            spi_reg_shift_out <= (others => '0');
            read_not_write    <= '0';
            spi_reg_shift_in  <= (others => '0');

            if (m_spi_arvalid = '1') then
              m_spi_arready     <= '1';
              m_spi_awready     <= '0';
              m_spi_wready      <= '0';
              state             <= ST_SHIFT;
              spi_clk_ena      <= '1';
              read_not_write    <= '1';
              spi_reg_shift_out <= '0'& r_addr & C_AXI4L_S2M_DEFAULT.rdata;-- & '0';
              mosi              <= '1';--read_not_write;
              -- cs_n              <= '0';
            elsif (m_spi_awvalid  = '1' and m_spi_wvalid = '1') then
              m_spi_awready     <= '1';
              m_spi_wready      <= '1';
              m_spi_arready     <= '0';
              state             <= ST_SHIFT;
              read_not_write    <= '0';
              spi_clk_ena      <= '1';
              spi_reg_shift_out <= '0' & w_addr & C_AXI4L_M2S_DEFAULT.wdata;-- & '0';
              spi_reg_shift_out(G_AXI4L_DATA_WIDTH - 1 downto 0) <= w_data;
              mosi              <= '0'; --read_not_write;
              m_spi_arready     <= '0';
            
            elsif (m_spi_awvalid  = '1' and m_spi_wvalid = '0') then
              m_spi_awready     <= '1';
              m_spi_wready      <= '1';
              m_spi_arready     <= '0';
              state             <= ST_WAIT_WDATA;
              read_not_write    <= '0';
              spi_clk_ena      <= '1';
              spi_reg_shift_out <= w_addr & C_AXI4L_M2S_DEFAULT.wdata & '0';
              mosi              <= '0'; --read_not_write;
              m_spi_arready     <= '0';

            elsif (m_spi_awvalid  = '0' and m_spi_wvalid = '1') then
              m_spi_awready     <= '1';
              m_spi_wready      <= '1';
              m_spi_arready     <= '0';
              state             <= ST_WAIT_WADDR;
              read_not_write    <= '0';
              spi_clk_ena      <= '1';
              spi_reg_shift_out(G_AXI4L_DATA_WIDTH - 1 downto 0) <= w_data;
              mosi              <= '0'; --read_not_write;
              m_spi_arready     <= '0';
            end if;

          -------------------------------------
          when ST_WAIT_WDATA =>
              spi_reg_shift_out(G_AXI4L_DATA_WIDTH - 1 downto 0) <= w_data;
              state                                              <= ST_SHIFT;
              
              m_spi_wready      <= '0';

           -------------------------------------
           when ST_WAIT_WADDR =>
              spi_reg_shift_out <= w_addr & C_AXI4L_M2S_DEFAULT.wdata & '0';
               state                                              <= ST_SHIFT;
              m_spi_awready     <= '0';

          -------------------------------------
          when ST_SHIFT =>
            mosi             <= spi_reg_shift_out(C_REG_SHIFT_WIDTH);
            spi_reg_shift_out <= spi_reg_shift_out(C_REG_SHIFT_WIDTH-1 downto 0) & '0';

            spi_reg_shift_in <= spi_reg_shift_in(G_AXI4L_DATA_WIDTH - 1 downto 0) & pi_m_miso;

            if (pi_m_miso = '1') then                        -- ACK from subordinate
              
              if (read_not_write = '1') then
                read_clk_cyc <= 0;
                state        <= ST_READ_DATA;
              else
                state      <= ST_WRITE_RESP;
                w_response <= C_AXI4_RESP_OKAY;
                b_valid    <= '1';
                
              end if;
            elsif (timeout >= G_TIMEOUT) then                --! read ack timeout after G_TIMEOUT
              state      <= ST_WRITE_RESP;
              w_response <= C_AXI4_RESP_SLVERR;
              b_valid    <= '1';
            end if;

            timeout <= timeout + 1;
            m_spi_wready      <= '0';

          -------------------------------------
          when ST_WRITE_RESP =>
            mosi <= '0';
            state       <= ST_IDLE;
            b_valid     <= '0';
            spi_clk_ena <= '0';
            -- cs_n        <= '1';
            timeout     <= 0;


          -------------------------------------
          when ST_READ_DATA =>
            spi_reg_shift_in <= spi_reg_shift_in(G_AXI4L_DATA_WIDTH - 1 downto 0) & pi_m_miso;
            mosi <= '0';
            if (read_clk_cyc >= G_AXI4L_DATA_WIDTH - 1) then --! read data timeout after 32 clkcycles
              -- cs_n         <= '1';
              spi_clk_ena  <= '0';
              state        <= ST_READ_DATA_PUSH;
              read_clk_cyc <= 0;
            
            else 
            read_clk_cyc <= read_clk_cyc+1;
            end if;

          -------------------------------------
          when ST_READ_DATA_PUSH =>
            m_spi_rvalid <= '1';
            r_data       <= spi_reg_shift_in(G_AXI4L_DATA_WIDTH - 1 downto 0);
            state        <= ST_IDLE;

          -------------------------------------
          when others =>
            state <= ST_IDLE;

        end case;

      end if;
    end if;

  end process prs_fsm;

end architecture rtl;
