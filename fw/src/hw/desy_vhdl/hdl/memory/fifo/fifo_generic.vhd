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
--! @author Radoslaw Rybaniec
------------------------------------------------------------------------------
--! @brief
--! First In First Out buffer, generic implementation
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

library desy;

entity fifo_generic is
  generic (
    G_FIFO_DEPTH        : positive := 32;         -- FIFO Depth (write words)
    G_FIFO_WIDTH        : positive := 64;         -- FIFO WRITE PORT WIDTH
    G_PROG_FULL_OFFSET  : natural  := 16;
    G_PROG_EMPTY_OFFSET : natural  := 16;
    G_FIFO_TYPE         : string   := "GENERIC";   -- Generic Fifo Type
    G_FIFO_FWFT         : natural  := 1);       -- First Word Fall Througth
  port (
    pi_reset      : in  std_logic;     -- async reset
    pi_wr_clk     : in  std_logic;     -- write clock
    pi_rd_clk     : in  std_logic;     -- read clock
    pi_int_clk    : in  std_logic;     -- clock for internal control circuits
    pi_data       : in  std_logic_vector(G_FIFO_WIDTH-1 downto 0);  -- write port
    pi_wr_ena     : in  std_logic;     -- write request
    pi_rd_ena     : in  std_logic;     -- read request
    po_data       : out std_logic_vector(G_FIFO_WIDTH-1 downto 0);  -- read port
    po_full       : out std_logic;     -- FIFO full
    po_empty      : out std_logic;     -- FIFO empty
    po_prog_full  : out std_logic;     -- Programmable full
    po_prog_empty : out std_logic := '1'
  );
end entity fifo_generic;

architecture rtl of fifo_generic is
  
  function fun_bin_to_gray (constant input : std_logic_vector)  -- input
    return std_logic_vector is
    variable tmp : std_logic_vector(input'range);
    variable i   : natural;
  begin
    for i in input'right to input'left-1 loop
      tmp(i) := input(i) xor input(i+1);
    end loop;
    tmp(input'left) := input(input'left);
    return tmp;
  end fun_bin_to_gray;

  function fun_gray_to_bin (constant input : std_logic_vector)  -- input
    return std_logic_vector is
    variable tmp : std_logic_vector(input'range);
    variable i   : natural;
  begin
    tmp(input'left) := input(input'left);
    for i in input'left-1 downto input'right loop
      tmp(i) := input(i) xor tmp(i+1);
    end loop;
    return tmp;
  end fun_gray_to_bin;

  constant C_FIFO_DEPTH_SIZE : natural := integer(ceil(log2(real(G_FIFO_DEPTH))));
  
  signal read_counter     : unsigned(C_FIFO_DEPTH_SIZE-1 downto 0) := to_unsigned(1, C_FIFO_DEPTH_SIZE);  --           := (others => '0');  -- read counter
  signal read_pointer     : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');  -- read pointer
  signal read_counter_ena : std_logic := '1';

  signal write_counter     : unsigned(C_FIFO_DEPTH_SIZE-1 downto 0) := to_unsigned(1, C_FIFO_DEPTH_SIZE);  --           := (others => '0');  -- write counter
  signal write_pointer     : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');  -- write pointer
  signal write_counter_ena : std_logic := '1';

  signal empty : std_logic;
  signal full  : std_logic;

  signal dpram_data_o     : std_logic_vector(G_FIFO_WIDTH-1 downto 0);
  signal dpram_data_o_reg : std_logic_vector(G_FIFO_WIDTH-1 downto 0);

  -- PROG FLAGS
  signal read_pointer_sync1  : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');
  -- synced
  signal read_pointer_sync2  : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');

  signal write_pointer_sync1 : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');
  -- synced
  signal write_pointer_sync2 : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');

  signal full_diff              : unsigned (C_FIFO_DEPTH_SIZE-1 downto 0)         := (others => '0');
  signal empty_diff             : unsigned (C_FIFO_DEPTH_SIZE-1 downto 0)         := (others => '0');
  signal write_pointer_sync_bin : std_logic_vector (C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');

  signal read_pointer_sync_bin : std_logic_vector (C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');

  signal fifo_dir_latch          : std_logic                                         := '0';  -- 0 - fifo going empty
  signal fifo_dir_latch_rd_sync1 : std_logic                                         := '0';
  signal fifo_dir_latch_rd_sync2 : std_logic                                         := '0';
  signal fifo_dir_latch_wr_sync1 : std_logic                                         := '0';
  signal fifo_dir_latch_wr_sync2 : std_logic                                         := '0';
  signal write_pointer_delay1    : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');
  signal write_pointer_delay2    : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');
  signal read_pointer_delay1     : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');
  signal read_pointer_delay2     : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');
 -- signal SIG_READ_POINTER_DBG        : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');
 -- signal SIG_WRITE_POINTER_DBG       : std_logic_vector(C_FIFO_DEPTH_SIZE-1 downto 0) := (others => '0');
  
begin

  po_full  <= full;
 
  gen_nofwft : if G_FIFO_FWFT = 0 generate
    po_data   <= dpram_data_o_reg;
    po_empty  <= empty;
    
    -- ASK FIFO
    read_counter_ena  <= pi_rd_ena; -- and not empty;

    process (pi_rd_clk) is
    begin
      if pi_rd_clk'event and pi_rd_clk = '1' then  
        if empty = '0' and pi_rd_ena = '1' then
          dpram_data_o_reg <= dpram_data_o;
        end if;
      end if;
    end process;

  end generate gen_nofwft;

  gen_fwft : if G_FIFO_FWFT /= 0 generate
    signal l_empty  : std_logic := '1';  
  begin 
    po_data   <= dpram_data_o_reg;
    po_empty  <= l_empty;
    
    process (pi_rd_clk, pi_reset) is
    begin  
      if pi_reset = '1' then
        l_empty <= '1';
      elsif pi_rd_clk'event and pi_rd_clk = '1' then
        if l_empty = '1' then
          if empty = '0' then
            l_empty <= '0';
            dpram_data_o_reg <= dpram_data_o;
          end if;
        else                            -- l_empty = '0'
          if pi_rd_ena = '1' and empty = '0' then
            l_empty  <= '0';
            dpram_data_o_reg <= dpram_data_o;
          elsif pi_rd_ena = '1' and empty = '1' then
            l_empty <= '1';
            dpram_data_o_reg <= dpram_data_o;
          end if;                          -- no read request
        end if;
      end if;
    end process;

    -- FIFO READ ASKING MASCHINE
    process (empty, pi_rd_ena, l_empty) is
    begin
      read_counter_ena  <= '0';
      if l_empty = '1' and empty = '0' then
        -- ASK FIFO for new data
        read_counter_ena  <= '1';
      elsif pi_rd_ena = '1' and empty = '0' then
        -- ASK FIFO
        read_counter_ena  <= '1';
      end if;
    end process;
    
  end generate gen_fwft;


  ins_dpram : entity desy.fifo_dpram
    generic map (
      GEN_DATA_WIDTH => G_FIFO_WIDTH,
      GEN_SIZE       => G_FIFO_DEPTH)
    port map (
      pi_rd_clk   => pi_rd_clk,
      pi_rd_addr  => std_logic_vector(read_counter),  --read_pointer,--std_logic_vector(read_counter(read_pointer'left-0 downto 0)),
      po_rd_data  => dpram_data_o,
      pi_wr_clk   => pi_wr_clk,
      pi_wr_ena   => write_counter_ena,
      pi_wr_addr  => std_logic_vector(write_counter),  --write_pointer,--std_logic_vector(write_counter(write_pointer'left-0 downto 0)),
      pi_wr_data  => pi_data);

  -- Read Counter
  -- BINARY counter with GRAY encoding
  PROC_RC : process (pi_rd_clk, pi_reset) is
  begin  -- process PROC_RC      
    --  read_pointer <= (others => '1');
    if pi_reset = '1' then               -- asynchronous reset (active high)
      read_counter(read_counter'left downto 1) <= (others => '0');
      read_counter(0)                              <= '1';
      read_pointer                                 <= (others => '0');
    --   read_pointer <= (others => '0');
    elsif pi_rd_clk'event and pi_rd_clk = '1' then  -- rising clock edge
      
      if read_counter_ena = '1' then
        read_counter      <= read_counter + 1;
        --SIG_READ_COUNTER_NEXT <= std_logic_vector(read_counter + 1);
        read_pointer      <= FUN_BIN_TO_GRAY(std_logic_vector(read_counter(read_counter'left downto 0)));
        --SIG_READ_POINTER_DBG  <= std_logic_vector(read_counter);
      end if;
    end if;
  end process PROC_RC;



  -- Write Counter
  -- BINARY counter with GRAY encoding
  proc_wc : process (pi_wr_clk, pi_reset) is
  begin 
    if pi_reset = '1' then -- asynchronous reset (active high)
--        write_counter <= (others => '0');
      write_counter(write_counter'left downto 1) <= (others => '0');
      write_counter(0)                               <= '1';
      write_pointer <= (others => '0');
    -- write_pointer <= (others => '0');
    elsif pi_wr_clk'event and pi_wr_clk = '1' then  -- rising clock edge
      if write_counter_ena = '1' then
        write_counter      <= write_counter + 1;
        write_pointer      <= FUN_BIN_TO_GRAY(std_logic_vector(write_counter(write_counter'left downto 0)));
        --SIG_WRITE_POINTER_DBG  <= std_logic_vector(write_counter);
      end if;
    end if;
  end process proc_wc;
  

  -- read_counter_ena  <= pi_rd_ena and not empty;
  write_counter_ena <= pi_wr_ena ; --and not full;

  
  ---------------------------------------------------------------------------
  -- PROG FULL, PROG EMPTY FLAG GENERATOR

  -- Quadrant decoder latch
  -- Divide pointers to 4 quadrants (2MSB)
  -- if the wptr is one quadrant behind rptr
  -- than FIFO full is possible when they will become equal
  -- this state will be saved in latch

  proc_quadrant_latch : process(pi_int_clk) is
  begin  -- process PROC_QUADRANT_LATCH
    if rising_edge(pi_int_clk) then
      if (read_pointer(read_pointer'left) = write_pointer(write_pointer'left-1) and
                  read_pointer(read_pointer'left-1) /= write_pointer(write_pointer'left)) then
        fifo_dir_latch <= '1';        -- FIFO going full
      end if;
      if (read_pointer(read_pointer'left) /= write_pointer(write_pointer'left-1) and
           read_pointer(read_pointer'left-1) = write_pointer(write_pointer'left))  then
        fifo_dir_latch <= '0';        -- going empty
      end if;
    end if;
  end process proc_quadrant_latch;
  

  -- WRITEPTR synchroniser
  proc_writeptr_sync : process (pi_rd_clk, pi_reset) is
  begin  
    if pi_reset = '1' then               -- asynchronous reset (active high)
      write_pointer_sync1     <= (others => '0');--FUN_BIN_TO_GRAY(std_logic_vector(to_unsigned(1, C_FIFO_DEPTH_SIZE)));
      write_pointer_sync2     <= (others => '0');--FUN_BIN_TO_GRAY(std_logic_vector(to_unsigned(1, C_FIFO_DEPTH_SIZE)));
      fifo_dir_latch_rd_sync1 <= ('0');
      fifo_dir_latch_rd_sync2 <= ('0');
    elsif pi_rd_clk'event and pi_rd_clk = '1' then  -- rising clock edge
      write_pointer_sync1     <= write_pointer;
      write_pointer_sync2     <= write_pointer_sync1;
      fifo_dir_latch_rd_sync1 <= fifo_dir_latch;
      fifo_dir_latch_rd_sync2 <= fifo_dir_latch_rd_sync1;
    end if;
  end process proc_writeptr_sync;

  -- READPTR  synchroniser
  proc_readptr_sync : process (pi_wr_clk, pi_reset) is
  begin 
    if pi_reset = '1' then               -- asynchronous reset (active high)
      read_pointer_sync1      <= (others => '0'); --FUN_BIN_TO_GRAY(std_logic_vector(to_unsigned(1, C_FIFO_DEPTH_SIZE)));
      read_pointer_sync2      <= (others => '0'); --FUN_BIN_TO_GRAY(std_logic_vector(to_unsigned(1, C_FIFO_DEPTH_SIZE)));
      fifo_dir_latch_wr_sync1 <= ('0');
      fifo_dir_latch_wr_sync2 <= ('0');
    elsif pi_wr_clk'event and pi_wr_clk = '1' then  -- rising clock edge
      read_pointer_sync1      <= read_pointer;
      read_pointer_sync2      <= read_pointer_sync1;
      fifo_dir_latch_wr_sync1 <= fifo_dir_latch;
      fifo_dir_latch_wr_sync2 <= fifo_dir_latch_wr_sync1;
    end if;
  end process proc_readptr_sync;

  write_pointer_sync_bin <= FUN_GRAY_TO_BIN(write_pointer_sync2);
  read_pointer_delay1    <= FUN_GRAY_TO_BIN(read_pointer);
  read_pointer_delay2    <= read_pointer_delay1;
  
  
  GEN_PROG_EMPTY: if G_PROG_EMPTY_OFFSET /= 0 generate
    proc_prog_empty_flag : process (pi_rd_clk, pi_reset) is
      
    begin
      if pi_reset = '1' then -- asynchronous reset (active high)
        empty_diff          <= (others => '0');
        po_prog_empty          <= '1';
     --   read_pointer_delay1 <= (others => '0');
     --   read_pointer_delay2 <= (others => '0');
      elsif pi_rd_clk'event and pi_rd_clk = '1' then
        empty_diff             <= unsigned((write_pointer_sync_bin))-unsigned(read_pointer_delay2);
        if OR_REDUCE(std_logic_vector(empty_diff)) = '0' then
          if fifo_dir_latch_rd_sync2 = '0' then
            po_prog_empty <= '1';
          else
            po_prog_empty <= '0';
          end if;
        elsif empty_diff < G_PROG_EMPTY_OFFSET then
          po_prog_empty <= '1';
        else
          po_prog_empty <= '0';
        end if; 
      end if;
    end process proc_prog_empty_flag;
  end generate GEN_PROG_EMPTY;

  GEN_NOT_PROG_EMPTY: if G_PROG_EMPTY_OFFSET = 0 generate
    po_prog_empty <= empty;
  end generate GEN_NOT_PROG_EMPTY;

  proc_empty_flag : process (fifo_dir_latch_rd_sync2, read_pointer,
                             write_pointer_sync2) is
  begin
       if   (read_pointer = write_pointer_sync2) and fifo_dir_latch_rd_sync2 = '0' then
        empty <= '1';
      else
        empty <= '0';
      end if;
  end process proc_empty_flag;

  read_pointer_sync_bin <= FUN_GRAY_TO_BIN(read_pointer_sync2);
  write_pointer_delay1  <= FUN_GRAY_TO_BIN(write_pointer);
  write_pointer_delay2  <= write_pointer_delay1;
  
  
  gen_prog_full: if G_PROG_FULL_OFFSET /= 0 generate
    proc_prog_full_flag : process (pi_wr_clk, pi_reset) is
    begin
      if pi_reset = '1' then -- asynchronous reset (active high)
        full_diff            <= (others => '0');
        po_prog_full            <= '0';
      --  write_pointer_delay1 <= (others => '0');
     --   write_pointer_delay2 <= (others => '0');
      elsif pi_wr_clk'event and pi_wr_clk = '1' then

        full_diff <= unsigned(write_pointer_delay2)-unsigned((read_pointer_sync_bin));  --unsigned(FUN_GRAY_TO_BIN(write_pointer));
        if OR_REDUCE(std_logic_vector(full_diff)) = '0' then
          if fifo_dir_latch_wr_sync2 = '1' then
            po_prog_full <= '1';
          else
            po_prog_full <= '0';
          end if;
        elsif full_diff >= G_PROG_FULL_OFFSET then
          po_prog_full <= '1';
        else
          po_prog_full <= '0';
        end if;
      end if;
    end process proc_prog_full_flag;
  end generate gen_prog_full;

  GEN_NOT_PROG_FULL: if G_PROG_FULL_OFFSET = 0 generate
    po_prog_full <= full;
  end generate GEN_NOT_PROG_FULL;
  

  proc_full_flag : process (fifo_dir_latch_wr_sync2,
                            read_pointer_sync2, write_pointer) is
  begin
      if (write_pointer = read_pointer_sync2) and fifo_dir_latch_wr_sync2 = '1' then
        full <= '1';
      else
        full <= '0';
      end if;
  end process proc_full_flag;

end architecture rtl;


