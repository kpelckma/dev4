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
--! @date 24.02.2023
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! xDMA IRQ input has to stay HIGH long enough such that xDMA driver can understand which event_x
--! file to toggle. In order to avoid additional irq_clear register, it is decided to
--! have 'auto-clear' functionality. This entity latches the interrupt requests (irq_req)
--! until a new irq_req comes (and if xDMA has acknowledged).
--! It has a timeout counting feature: if Acknowledgement doesn't arrive in time (G_TIMEOUT_CNT)
--! it then increments a error counter for debug purposes
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

entity xdma_irq_handler is
  generic(
    G_IRQ_CNT     : natural := 16;      -- Number of interrupt channels
    G_TIMEOUT_CNT : natural := 100_000  -- Maximum clock cycles between REQ assertion and ACK assertion for error
  );
  port (
    pi_user_clk            : in  std_logic;
    pi_user_irq_req        : in  std_logic_vector(G_IRQ_CNT-1 downto 0);  -- pi_user_clk domain
    pi_xdma_clk            : in  std_logic;
    pi_xdma_irq_ack        : in  std_logic_vector(G_IRQ_CNT-1 downto 0);  -- pi_xdma_clock domain
    pi_xdma_irq_ena        : in  std_logic_vector(G_IRQ_CNT-1 downto 0);  -- Enable/Activate po_xdma_irq_req /  pi_xdma_clock domain
    po_xdma_irq_req        : out std_logic_vector(G_IRQ_CNT-1 downto 0) := (others => '0');  -- pi_xdma_clock domain
    po_irq_ack_timeout_cnt : out t_32b_slv_vector(G_IRQ_CNT-1 downto 0) := (others => (others => '0'))
  );
end entity xdma_irq_handler;

architecture rtl of xdma_irq_handler is

  constant C_IRQ_ELONG_STAGE : natural := 2; -- Make IRQ request flag longer (Application clock can be upto 300MHz and INTC can still capture)

  type t_irq_long is array (G_IRQ_CNT-1 downto 0) of std_logic_vector(C_IRQ_ELONG_STAGE-1 downto 0);
  type t_state_irq is (ST_IDLE, ST_GO_LOW, ST_GO_HIGH);
  type t_state_irq_vector is array (G_IRQ_CNT-1 downto 0) of t_state_irq;

  signal state_irq            : t_state_irq_vector;
  signal irq_req_long         : t_irq_long;
  signal irq_req_long_q       : std_logic_vector(G_IRQ_CNT-1 downto 0);
  signal irq_req_long_qq      : std_logic_vector(G_IRQ_CNT-1 downto 0);
  signal irq_req_long_qqq     : std_logic_vector(G_IRQ_CNT-1 downto 0);
  signal xdma_irq_req         : std_logic_vector(G_IRQ_CNT-1 downto 0);
  signal irq_ack_q            : std_logic_vector(G_IRQ_CNT-1 downto 0);
  signal irq_req_rising       : std_logic_vector(G_IRQ_CNT-1 downto 0);
  signal irq_ack_rising       : std_logic_vector(G_IRQ_CNT-1 downto 0);
  signal ack_arrived          : std_logic_vector(G_IRQ_CNT-1 downto 0);
  signal timeout_cnt          : t_32b_unsigned_vector(G_IRQ_CNT-1 downto 0) := (others => (others=>'0'));
  signal irq_ack_err_cnt      : t_32b_unsigned_vector(G_IRQ_CNT-1 downto 0) := (others => (others=>'0'));

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of irq_req_long_q: signal is "TRUE";
  attribute ASYNC_REG of irq_req_long_qq: signal is "TRUE";

begin

  gen_irq : for i in 0 to G_IRQ_CNT-1 generate

    -- IRQ Output Generation only happens when PCIE_IRQ_ENA=1
    po_xdma_irq_req(i) <= xdma_irq_req(i) when pi_xdma_irq_ena(i) = '1' else '0';
    po_irq_ack_timeout_cnt(i) <= std_logic_vector(irq_ack_err_cnt(i));

    -- Elongate the Application IRQ flag to cover cases
    -- where application clk freq is faster than xDMA clk domain
    process(pi_user_clk)
    begin
      if rising_edge(pi_user_clk) then
        if pi_user_irq_req(i) = '1' then
          irq_req_long(i) <= (others=>'1');
        else
          irq_req_long(i) <= irq_req_long(i)(C_IRQ_ELONG_STAGE-2 downto 0) & '0';
        end if;
      end if;
    end process;

    -- Switching to BSP Clock domain for the IRQ Req coming from application
    -- This elongation stage has a effect where if trigger is too fast, no triggers will be produced.
    process (pi_xdma_clk)
    begin
      if rising_edge(pi_xdma_clk) then
        irq_req_long_q(i)   <= irq_req_long(i)(C_IRQ_ELONG_STAGE-1);
        irq_req_long_qq(i)  <= irq_req_long_q(i);
        irq_req_long_qqq(i) <= irq_req_long_qq(i);
        irq_ack_q(i)        <= pi_xdma_irq_ack(i);
      end if;
    end process;

    -- Rising Edge Detection of IRQ Req and IRQ Ack (BSP Clock Domain Synchronous)
    irq_req_rising(i) <= not irq_req_long_qqq(i) and irq_req_long_qq(i) when pi_xdma_irq_ena(i) = '1' else '0';
    irq_ack_rising(i) <= not irq_ack_q(i) and pi_xdma_irq_ack(i);

    -- After Application sends a IRQ REQ, below process latches the IRQ-REQ going towards xDMA high
    -- This is done because we want to make sure xDMA driver 'senses' which lane was active
    -- This entity will not put po_xdma_irq_req to low until ACK comes from xDMA
    -- After ACK did arrive and if there is a new app_irq_req, po_xdma_irq_req will go low and high again
    -- xDMA IRQ Req input is edge triggered.
    process(pi_xdma_clk)
    begin
      if rising_edge(pi_xdma_clk) then
        case state_irq(i) is

        when ST_IDLE =>
          xdma_irq_req(i) <= '0';
          ack_arrived(i) <= '0';
          if irq_req_rising(i) = '1' and pi_xdma_irq_ack(i) = '0' then
            state_irq(i) <= ST_GO_HIGH;
          end if;

        when ST_GO_LOW =>
          xdma_irq_req(i) <= '0';
          ack_arrived(i) <= '0';
          if pi_xdma_irq_ack(i) = '0' then
            state_irq(i) <= ST_GO_HIGH;
          end if;

        when ST_GO_HIGH =>
          xdma_irq_req(i) <= '1';
          if irq_ack_rising(i) = '1' then -- Wait for rising_edge of ACK and latch
            ack_arrived(i) <= '1';
          end if;
          if irq_req_rising(i) = '1' and ack_arrived(i) = '1' then -- Do not forward further reqs until xDMA acknowledges
            state_irq(i) <= ST_GO_LOW;
          end if;

        when others => state_irq(i) <= ST_IDLE;

        end case;
      end if;
    end process;

    -- Acknowledgement arrival timeout counter
    process(pi_xdma_clk)
    begin
      if rising_edge(pi_xdma_clk) then
        if pi_xdma_irq_ena(i) = '1' and ack_arrived(i) = '0' and state_irq(i) = ST_GO_HIGH then
          if timeout_cnt(i) >= G_TIMEOUT_CNT then
            irq_ack_err_cnt(i) <= irq_ack_err_cnt(i) + 1;
            timeout_cnt(i) <= (others=>'0');
          elsif ack_arrived(i) = '1' then
            timeout_cnt(i) <= (others=>'0');
          else
            timeout_cnt(i) <= timeout_cnt(i) +1;
          end if;
        else
          timeout_cnt(i) <= (others=>'0');
        end if;
      end if;
    end process;

  end generate;
end architecture rtl;
