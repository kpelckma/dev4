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
--! @date 2021-09-14
--! @author Michael Buechler  <michael.buechler@desy.de>
------------------------------------------------------------------------------
--! @brief
--! When a timestamp for a buffer start is available, write that to the memory
--! connected at the output. This takes two cycles (2x32 bit).
--! Otherwise, write trigger times (1x32bit) to the same memory.
--! Since both kinds of timestamps can collide at the input, have a FIFO to
--! hold trigger timestamps while writing buffer start timestamnps.
--!
--! The memory is separated into two regions to store timestamps from both
--! buffers independently.
--!
--! Memory layout at the target:
--!                 ________________
--! Buf0 trigger 0 |0x0000          |
--!      trigger 1 |0x0001          |
--!                |.               |
--!                |.               |
--!                |.               |
--!                |.               |
--!                |.               |
--! Buf0 Start_high|BUF1_OFFSET-2   |
--! Buf0 Start_low |BUF1_OFFSET-1   |
--! BUF1_OFFSET    |=============== |
--! Buf1 trigger 0 |C_BUF1_OFFSET |
--! Buf1 trigger 1 |  +0x01         |
--!                |.               |
--!                |.               |
--!                |.               |
--!                |.               |
--!                |.               |
--! Buf1 Start_high|LAST_ADDRESS-1  |
--! Buf1 Start_low |LAST_ADDRESS    |
--!                |________________|
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library desy;
use desy.common_types.all;

entity daq_timestamps_to_mem is
  generic (
            G_TIMESTAMP_WIDTH : natural := 64;
            G_OFFSET_WIDTH    : natural := 32;
            G_TRG_CNT_MAX     : natural := 1022;
            G_DATA_WIDTH      : natural := 32;  -- output width
            G_ADDR_WIDTH      : natural := 10   -- memory width at output
          );
  port (
         pi_clock : in std_logic;
         pi_reset : in std_logic;

         pi_buf_start    : in std_logic;

         pi_start_time   : in std_logic_vector(G_TIMESTAMP_WIDTH-1 downto 0);
         pi_start_rdy    : in std_logic;
         pi_trigger_time : in std_logic_vector(G_OFFSET_WIDTH-1 downto 0);
         pi_trigger_rdy  : in std_logic;
         pi_buf_in_use   : in std_logic;

         po_en   : out std_logic;
         po_data : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
         po_addr : out std_logic_vector(G_ADDR_WIDTH-1 downto 0);

         po_trg_cnt_buf0 : out std_logic_vector(16-1 downto 0);
         po_trg_cnt_buf1 : out std_logic_vector(16-1 downto 0)
       );
end entity daq_timestamps_to_mem;

architecture arch of daq_timestamps_to_mem is
  constant C_START_H_OFFSET : natural := 2**(G_ADDR_WIDTH-1) - 2;
  constant C_START_L_OFFSET : natural := 2**(G_ADDR_WIDTH-1) - 1;
  constant C_BUF1_OFFSET : natural := 2**(G_ADDR_WIDTH-1);

  signal start_time_q : std_logic_vector(64-1 downto 0); --! To IBUS: timestamp at first sample in a buffer
  signal trg_cnt_q    : std_logic_vector(16-1 downto 0); --! number of triggers in buffer
  signal trg_cnt_buf0 : std_logic_vector(16-1 downto 0);
  signal trg_cnt_buf1 : std_logic_vector(16-1 downto 0);

  -- choose to either write the start time [h,l] or a trigger time offset
  type t_OUTPUT_SOURCE is (ST_START_H, ST_START_L, ST_TRIGGER);
  signal w_sel : t_OUTPUT_SOURCE;

  signal start_addr_base      : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal trigger_addr_base    : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal addr_out_base        : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal addr_out_offset      : std_logic_vector(G_ADDR_WIDTH-1 downto 0);

  signal start_time_h     : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal start_time_l     : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal trigger_time_out : std_logic_vector(G_DATA_WIDTH-1 downto 0);

  signal trigger_pos_out : std_logic_vector(16-1 downto 0);
  signal trigger_buf_num_out : std_logic;

  signal trigger_rd_ena : std_logic;
  signal trigger_rd_ena_and : std_logic;
  signal trigger_wr_ena : std_logic;
  signal trigger_wr_ena_and : std_logic;
  signal trigger_fifo_full : std_logic;
  signal trigger_fifo_empty : std_logic;

  -- width=32+16+1=49
  constant C_TRIGGER_FIFO_WIDTH : natural := G_OFFSET_WIDTH+16+1;
  signal trigger_fifo_in : std_logic_vector(C_TRIGGER_FIFO_WIDTH-1 downto 0);
  signal trigger_fifo_out : std_logic_vector(C_TRIGGER_FIFO_WIDTH-1 downto 0);

begin

  -- make sure the maximum number of triggers doesn't exceed the RAM size
  assert G_TRG_CNT_MAX < 2**G_ADDR_WIDTH / 2 - 1
  report "With a timestamp RAM address width of "
  & integer'image(G_ADDR_WIDTH)
  & " there can only be (2^width)/2-2 = " 
  & integer'image(2**G_ADDR_WIDTH/2-2)
  & " triggers per buffer."
  severity failure;

  --! assign output ports

  po_trg_cnt_buf0 <= trg_cnt_buf0;
  po_trg_cnt_buf1 <= trg_cnt_buf1;

  start_time_h <= start_time_q(64-1 downto 32);
  start_time_l <= start_time_q(32-1 downto 0);

  --! output data selection
  with w_sel select po_data <=
  start_time_h when ST_START_H,
  start_time_l when ST_START_L,
  trigger_time_out when ST_TRIGGER;

  --! output address handling based on the current buffer
  with trigger_buf_num_out select trigger_addr_base <=
  std_logic_vector(to_unsigned(C_BUF1_OFFSET, G_ADDR_WIDTH)) when '1',
  (others => '0') when others;
  --
  with pi_buf_in_use select start_addr_base <=
  std_logic_vector(to_unsigned(C_BUF1_OFFSET, G_ADDR_WIDTH)) when '1',
  (others => '0') when others;

  --! output address selection, composed of base and offset
  with w_sel select addr_out_base <=
  start_addr_base when ST_START_H,
  start_addr_base when ST_START_L,
  trigger_addr_base when ST_TRIGGER;
  --
  with w_sel select addr_out_offset <=
  std_logic_vector(to_unsigned(C_START_H_OFFSET, G_ADDR_WIDTH)) when ST_START_H,
  std_logic_vector(to_unsigned(C_START_L_OFFSET, G_ADDR_WIDTH)) when ST_START_L,
  trigger_pos_out(G_ADDR_WIDTH-1 downto 0) when ST_TRIGGER;
  --! put together address base and offset
  po_addr <= addr_out_base or addr_out_offset;

  --
  --! FIFO for trigger timestamps
  --
  -- width=32+16+1=49
  trigger_fifo_in(48) <= pi_buf_in_use;
  trigger_fifo_in(48-1 downto 32) <= trg_cnt_q;
  trigger_fifo_in(32-1 downto 0)  <= pi_trigger_time;

  trigger_time_out    <= trigger_fifo_out(32-1 downto 0);
  trigger_pos_out     <= trigger_fifo_out(48-1 downto 32);
  trigger_buf_num_out <= trigger_fifo_out(48);

  trigger_wr_ena_and <= pi_trigger_rdy and not trigger_fifo_full
                        and trigger_wr_ena;
  trigger_rd_ena_and <= trigger_rd_ena and not trigger_fifo_empty;

  -- P_I_RD_ENA is a read request. Data is valid at the output on the
  -- following clock.
  ins_trigger_fifo: entity desy.fifo
  generic map (
                G_FIFO_TYPE => "GENERIC",
                G_FIFO_DEPTH => 4,
                G_FIFO_WIDTH => 49,
                G_FIFO_READ_WIDTH => 49,
                G_FIFO_WRITE_WIDTH => 49,

                G_FIFO_FWFT => 0
              )
  port map (
             pi_reset => pi_reset,
             pi_wr_clk => pi_clock,
             pi_rd_clk => pi_clock,
             pi_int_clk => pi_clock,

             pi_data => trigger_fifo_in,
             pi_wr_ena => trigger_wr_ena_and,
             pi_rd_ena => trigger_rd_ena_and,
             po_data => trigger_fifo_out,
             po_full => trigger_fifo_full,
             po_empty => trigger_fifo_empty,
             po_prog_full => open,
             po_prog_empty => open
           );

  --! Update the trigger count at the output.
  prs_trigger_num_out: process(pi_clock)
    variable v_trg_cnt_buf0 : integer;
    variable v_trg_cnt_buf1 : integer;
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        trg_cnt_buf0 <= (others => '0');
        trg_cnt_buf1 <= (others => '0');
      else
        v_trg_cnt_buf0 := to_integer(unsigned(trg_cnt_buf0));
        v_trg_cnt_buf1 := to_integer(unsigned(trg_cnt_buf1));

        -- The beginning of a buffer resets the count for that buffer
        if pi_start_rdy = '1' then
          if pi_buf_in_use = '1' then
            v_trg_cnt_buf1 := 0;
          else
            v_trg_cnt_buf0 := 0;
          end if;
        end if;
        -- The count is updated on each trigger. The same value is used that
        -- determines the write position in the memory (trg_cnt_q), plus one
        -- so it starts at 1.
        if pi_trigger_rdy = '1' then
          if pi_buf_in_use = '0' then
            v_trg_cnt_buf0 := to_integer(unsigned(trg_cnt_q))+1;
          else
            v_trg_cnt_buf1 := to_integer(unsigned(trg_cnt_q))+1;
          end if;
        end if;

        trg_cnt_buf0 <= std_logic_vector(to_unsigned(v_trg_cnt_buf0, trg_cnt_buf0'length));
        trg_cnt_buf1 <= std_logic_vector(to_unsigned(v_trg_cnt_buf1, trg_cnt_buf1'length));
      end if;
    end if;
  end process;

  prs_timestamps_to_mem: process(pi_clock)
    variable v_trg_cnt : integer range 0 to G_TRG_CNT_MAX-1;
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        start_time_q <= (others => '0');
        w_sel <= ST_TRIGGER;
        trigger_rd_ena <= '0';
        po_en <= '0';
        trg_cnt_q <= (others => '0');
        trigger_wr_ena <= '0';
      else
        v_trg_cnt := to_integer(unsigned(trg_cnt_q));

        -- writes must be prevented after the max number of triggers
        if v_trg_cnt = G_TRG_CNT_MAX-1 and pi_buf_start = '0' then
          trigger_wr_ena <= '0';
        else
          trigger_wr_ena <= '1';
        end if;

        --
        -- Input stage
        --
        -- Get timestamp from daq_timestamps module.
        if pi_start_rdy = '1' then
          start_time_q <= pi_start_time;
        else
          start_time_q <= start_time_q;
        end if;
        -- Trigger times come as single values and are indexed by their
        -- chronological occurrence within a buffer
        -- (first trigger: 0, second: 1, ..)
        if pi_buf_start = '1' then
          v_trg_cnt := 0;
        elsif pi_trigger_rdy = '1' and v_trg_cnt /= G_TRG_CNT_MAX-1 then
          v_trg_cnt := v_trg_cnt + 1;
        end if;

        --
        -- Output stage
        --
        -- Write either the start time or a trigger offset to the appropriate
        -- address within a memory, connected to this component's output.
        -- There are three possible sources: start_time_high, start_time_low,
        -- and a trigger.
        case w_sel is
          when ST_TRIGGER =>
            if pi_start_rdy = '1' then
              w_sel <= ST_START_H;
              trigger_rd_ena <= '0';
              po_en <= '1';
            else
              w_sel <= ST_TRIGGER;
              trigger_rd_ena <= '1';
              po_en <= trigger_rd_ena_and;
            end if;
          when ST_START_H =>
            w_sel <= ST_START_L;
            trigger_rd_ena <= '0';
            po_en <= '1';
          when ST_START_L =>
            w_sel <= ST_TRIGGER;
            trigger_rd_ena <= '1';
            po_en <= trigger_rd_ena_and;
          when others =>
            w_sel <= ST_TRIGGER;
            trigger_rd_ena <= '0';
            po_en <= trigger_rd_ena_and;
        end case;

        -- assign from variables
        trg_cnt_q(G_ADDR_WIDTH-1 downto 0) <= std_logic_vector(to_unsigned(v_trg_cnt, G_ADDR_WIDTH));
        trg_cnt_q(16-1 downto G_ADDR_WIDTH) <= (others => '0');

      end if;
    end if;
  end process;
end architecture;
