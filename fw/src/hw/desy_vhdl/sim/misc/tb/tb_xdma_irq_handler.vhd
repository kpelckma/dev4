------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2021-2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 24.02.2023
--! @author Cagil Gumus  <cagil.gumus@desy.de>
------------------------------------------------------------------------------
--! @brief
--! Testbench for the xdma_irq_handler entity.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library desy;
use desy.common_types.all;

entity tb_xdma_irq_handler is
end entity tb_xdma_irq_handler;

architecture sim of tb_xdma_irq_handler is

  -- DUT Generics
  constant G_IRQ_CNT     : natural := 16;
  constant G_TIMEOUT_CNT : natural := 100;
  -- Simulation Settings
  constant C_IRQ_REQ_DIV : natural := 5;

  signal pi_user_clk            : std_logic := '0';
  signal pi_user_irq_req        : std_logic_vector(G_IRQ_CNT-1 downto 0):= (others =>'0'); -- pi_user_clk domain
  signal pi_xdma_clk            : std_logic := '0';
  signal pi_xdma_irq_ena        : std_logic_vector(G_IRQ_CNT-1 downto 0) := (others =>'1'); -- Enable/Activate po_xdma_irq_req
  signal po_xdma_irq_req        : std_logic_vector(G_IRQ_CNT-1 downto 0);  -- pi_xdma_clock domain
  signal pi_xdma_irq_ack        : std_logic_vector(G_IRQ_CNT-1 downto 0) := (others =>'0'); -- Ack. coming from xDMA IP
  signal po_irq_ack_timeout_cnt : t_32b_slv_vector(G_IRQ_CNT-1 downto 0) := (others => (others =>'0'));
  signal counter                : natural := 0;
  signal xdma_responsive        : std_logic := '1';

begin

  DUT: entity work.xdma_irq_handler
  generic map (
    G_IRQ_CNT => G_IRQ_CNT,
    G_TIMEOUT_CNT => G_TIMEOUT_CNT
  )
  port map (
    pi_user_clk            => pi_user_clk,
    pi_user_irq_req        => pi_user_irq_req,
    pi_xdma_clk            => pi_xdma_clk,
    pi_xdma_irq_ena        => pi_xdma_irq_ena,
    po_xdma_irq_req        => po_xdma_irq_req,
    pi_xdma_irq_ack        => pi_xdma_irq_ack,
    po_irq_ack_timeout_cnt => po_irq_ack_timeout_cnt
  );

  -- clock generation
  pi_user_clk <= not pi_user_clk  after 5 ns;
  pi_xdma_clk <= not pi_xdma_clk after 8 ns;

  -- Application IRQ Request Generation
  process(pi_user_clk)
    variable v_counter : natural := 0;
  begin
    if rising_edge(pi_user_clk) then
      if v_counter >= C_IRQ_REQ_DIV then
        v_counter := 0;
        pi_user_irq_req <= (others =>'1');
      else
        v_counter := v_counter + 1;
        pi_user_irq_req <= (others =>'0');
      end if;
    end if;
  end process;

  -- xDMA IRQ Ack Generation
  gen_loop : for i in 0 to G_IRQ_CNT-1 generate
    process begin
      if xdma_responsive = '1' then
        wait until po_xdma_irq_req(i) = '1';
        report "IRQ Request received by xDMA";
        wait for 100 ns; -- Rough Estimation on how quick xDMA asserts ACK high
        wait until rising_edge(pi_xdma_clk);
        report "Asserting ACK";
        pi_xdma_irq_ack(i) <= '1';
        wait for 50 ns; -- Rough Estimation on how long xDMA keeps ACK high
        report "Deasserting ACK";
        pi_xdma_irq_ack(i) <= '0';
      else
        wait for 1 ns;
      end if;
    end process;
  end generate gen_loop;


  proc_stimuli: process begin
    xdma_responsive <= '1';
    wait for 1 us;
    xdma_responsive <= '0'; -- Test the timeout functionality
    wait;
  end process proc_stimuli;

end architecture sim;
