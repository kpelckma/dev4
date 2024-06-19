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
--! First In First Out buffer, VIRTEX BRAM
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

library unimacro;
use unimacro.vcomponents.all;

library desy;

entity fifo_virtex is
  generic (
    G_FIFO_LAYER_NUM         : natural  := 1;        -- number of layers in cascade
    G_FIFO18_NUM             : natural  := 0;
    G_FIFO36_NUM             : natural  := 4;
    G_FIFO36_WIDTH           : positive := 18;       -- FIFO BLOCK WIDTH FIFO16=FIFO32/2 to match depths
    G_FIFO_WIDTH             : positive := 18*2+9*0; -- WIDTH of the i/O
    G_FIFO_DEPTH             : positive := 2048;     -- Depth of the layer
    G_FIFO_FWFT              : natural  := 1;        -- First Word Fall Througth
    G_FIFO_PROG_FULL_OFFSET  : natural  := 128;
    G_FIFO_PROG_EMPTY_OFFSET : natural  := 128;
    G_FIFO_TYPE              : string   := "VIRTEX6";
    G_FIFO_ENABLE_ECC        : boolean  := FALSE     -- With ECC only FIFO36 are permitted. Maximum data width is 64
    );   
  port (
    pi_reset      : in  std_logic;                                  -- async reset
    pi_wr_clk     : in  std_logic;                                  -- write clock
    pi_rd_clk     : in  std_logic;                                  -- read clock
    pi_int_clk    : in  std_logic;                                  -- clock for internal layers
    pi_data       : in  std_logic_vector(G_FIFO_WIDTH-1 downto 0);  -- write port
    pi_wr_ena     : in  std_logic;                                  -- write request
    pi_rd_ena     : in  std_logic;                                  -- read request
    po_data       : out std_logic_vector(G_FIFO_WIDTH-1 downto 0);  -- read port
    po_full       : out std_logic;                                  -- FIFO full
    po_empty      : out std_logic;                                  -- FIFO empty
    po_prog_full  : out std_logic;                                  -- Programmable full
    po_prog_empty : out std_logic                                   -- Programmable empty
  );    
end entity fifo_virtex;

architecture rtl of fifo_virtex is

  function fun_ind (constant LAYER, INDEX : natural) return natural is
  begin
    return (LAYER-1)*(G_FIFO36_NUM+G_FIFO18_NUM)+INDEX;
  end function fun_ind;

  signal wr_clk : std_logic_vector(1 to G_FIFO_LAYER_NUM*(G_FIFO18_NUM+G_FIFO36_NUM));
  signal rd_clk : std_logic_vector(1 to G_FIFO_LAYER_NUM*(G_FIFO18_NUM+G_FIFO36_NUM));

  signal data_i     : std_logic_vector(G_FIFO_LAYER_NUM*G_FIFO_WIDTH-1 downto 0);
  signal wr_ena     : std_logic_vector(1 to G_FIFO_LAYER_NUM*(G_FIFO18_NUM+G_FIFO36_NUM));
  signal rd_ena     : std_logic_vector(1 to G_FIFO_LAYER_NUM*(G_FIFO18_NUM+G_FIFO36_NUM));
  signal data_o     : std_logic_vector(G_FIFO_LAYER_NUM*G_FIFO_WIDTH-1 downto 0);
  signal full       : std_logic_vector(1 to G_FIFO_LAYER_NUM*(G_FIFO18_NUM+G_FIFO36_NUM));
  signal empty      : std_logic_vector(1 to G_FIFO_LAYER_NUM*(G_FIFO18_NUM+G_FIFO36_NUM));
  signal prog_full  : std_logic_vector(1 to G_FIFO_LAYER_NUM*(G_FIFO18_NUM+G_FIFO36_NUM));
  signal prog_empty : std_logic_vector(1 to G_FIFO_LAYER_NUM*(G_FIFO18_NUM+G_FIFO36_NUM));

  signal master_rd_ena : std_logic;
  signal master_wr_ena : std_logic;

  constant C_FIFO_DEPTH_SIZE : natural := integer(ceil(log2(real(G_FIFO_DEPTH))));

  signal rd_counter : std_logic_vector(G_FIFO_LAYER_NUM*C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM)-1 downto 0);
  signal wr_counter : std_logic_vector(G_FIFO_LAYER_NUM*C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM)-1 downto 0);

  function fun_get_empty_offset return integer is
    variable empty_offset : integer;
  begin
    if G_FIFO_PROG_EMPTY_OFFSET = 0 then
      empty_offset := G_FIFO_DEPTH/2;
    else
      empty_offset := G_FIFO_PROG_EMPTY_OFFSET ;
    end if;
    return empty_offset;
  end function;
  
  function fun_get_full_offset return integer is
    variable full_offset : integer;
  begin
    if G_FIFO_PROG_FULL_OFFSET = 0 then
      full_offset := G_FIFO_DEPTH/2;
    else
      full_offset := G_FIFO_DEPTH-G_FIFO_PROG_FULL_OFFSET;
    end if;
    return full_offset;
  end function;    

  constant C_FIFO_PROG_EMPTY_OFFSET : integer := fun_get_empty_offset;
  constant C_FIFO_PROG_FULL_OFFSET  : integer := fun_get_full_offset;

  function fun_chk_offsets return boolean is
  begin
    if  (C_FIFO_PROG_FULL_OFFSET  >= G_FIFO_DEPTH or C_FIFO_PROG_FULL_OFFSET < 0) then
      report "G_FIFO_PROG_FULL_OFFSET value is wrong for selected LAYER depth" severity FAILURE;
    end if;
    if  (C_FIFO_PROG_EMPTY_OFFSET >= G_FIFO_DEPTH or C_FIFO_PROG_EMPTY_OFFSET < 0) then
      report "G_FIFO_PROG_EMPTY_OFFSET value is wrong for selected LAYER depth" severity FAILURE;  
    end if;
    return true;
  end function;

  constant C_OFFSETS_OK : boolean := fun_chk_offsets;

  function fun_natural_to_bool (
    constant X : natural)
    return boolean is
  begin
    if X /= 0 then
      return true;
    end if;
    return false;
  end function;

  constant C_FIFO_FWFT : boolean := fun_natural_to_bool(G_FIFO_FWFT);
  
begin

      
  gen_int_signals : for i in 1 to G_FIFO18_NUM+G_FIFO36_NUM generate
    GEN_SIGNAL_LAYERS : for LAYER in 2 to G_FIFO_LAYER_NUM-1 generate
      rd_ena(fun_ind(LAYER, i)) <= empty(fun_ind(LAYER, i)) nor full(fun_ind(LAYER+1, i));
      wr_ena(fun_ind(LAYER, i)) <= empty(fun_ind(LAYER-1, i)) nor full(fun_ind(LAYER, i));
      wr_clk(fun_ind(LAYER, i)) <= pi_int_clk;
      rd_clk(fun_ind(LAYER, i)) <= pi_int_clk;
    end generate GEN_SIGNAL_LAYERS;

    GEN_LAYER1_SIGNALS : if G_FIFO_LAYER_NUM = 1 generate
      rd_ena(fun_ind(1, i)) <= master_rd_ena;
      rd_clk(fun_ind(1, i)) <= pi_rd_clk;
      wr_clk(fun_ind(1, i)) <= pi_wr_clk;
      wr_ena(fun_ind(1, i)) <= master_wr_ena;
    end generate GEN_LAYER1_SIGNALS;

    GEN_LAYERN_SIGNALS : if G_FIFO_LAYER_NUM > 1 generate
      rd_ena(fun_ind(1, i)) <= empty(fun_ind(1, i)) nor full(fun_ind(2, i));
      rd_clk(fun_ind(1, i)) <= pi_int_clk;
      wr_clk(fun_ind(1, i)) <= pi_wr_clk;
      wr_ena(fun_ind(1, i)) <= master_wr_ena;

      rd_ena(fun_ind(G_FIFO_LAYER_NUM, i)) <= master_rd_ena;
      rd_clk(fun_ind(G_FIFO_LAYER_NUM, i)) <= pi_rd_clk;
      wr_ena(fun_ind(G_FIFO_LAYER_NUM, i)) <= full(fun_ind(G_FIFO_LAYER_NUM, i)) nor empty(fun_ind(G_FIFO_LAYER_NUM-1, i));
      wr_clk(fun_ind(G_FIFO_LAYER_NUM, i)) <= pi_int_clk;
      
    end generate gen_layern_signals;
  end generate gen_int_signals;


  master_wr_ena <= pi_wr_ena;-- and not OR_REDUCE(full(fun_ind(1, 1) to fun_ind(1, G_FIFO36_NUM+G_FIFO18_NUM)));
  master_rd_ena <= pi_rd_ena;-- and not OR_REDUCE(empty(fun_ind(G_FIFO_LAYER_NUM, 1) to fun_ind(G_FIFO_LAYER_NUM, G_FIFO36_NUM+G_FIFO18_NUM)));

  
  po_full       <= or_reduce(full(fun_ind(1, 1) to fun_ind(1, G_FIFO36_NUM+G_FIFO18_NUM)));
  po_empty      <= or_reduce(empty(fun_ind(G_FIFO_LAYER_NUM, 1) to fun_ind(g_fifo_layer_num, G_FIFO36_NUM+G_FIFO18_NUM)));

  -- po_prog_full  <= or_reduce(prog_full(fun_ind(1, 1) to fun_ind(1, g_fifo36_num+g_fifo18_num)));
  -- only last layer used for prog_full

  gen_prog_full: if G_FIFO_PROG_FULL_OFFSET /= 0 generate
    po_prog_full  <= or_reduce(prog_full(fun_ind(1, 1) to fun_ind(1, G_FIFO36_NUM+G_FIFO18_NUM)));
  end generate gen_prog_full;

  gen_no_prog_full: if G_FIFO_PROG_FULL_OFFSET = 0 generate
    po_prog_full       <= or_reduce(full(fun_ind(1, 1) to fun_ind(1, G_FIFO36_NUM+G_FIFO18_NUM)));  -- same as po_full
  end generate gen_no_prog_full;

  gen_prog_empty: if G_FIFO_PROG_EMPTY_OFFSET /= 0 generate
    po_prog_empty <= or_reduce(prog_empty(fun_ind(G_FIFO_LAYER_NUM, 1) to fun_ind(G_FIFO_LAYER_NUM, G_FIFO36_NUM+G_FIFO18_NUM)));
  end generate gen_prog_empty;
    
  gen_no_prog_empty: if G_FIFO_PROG_EMPTY_OFFSET = 0 generate
     po_prog_empty      <= OR_REDUCE(empty(fun_ind(G_FIFO_LAYER_NUM, 1) to fun_ind(G_FIFO_LAYER_NUM, G_FIFO36_NUM+G_FIFO18_NUM)));
  end generate gen_no_prog_empty;
  
  po_data   <= data_o(G_FIFO_LAYER_NUM*G_FIFO_WIDTH-1 downto (G_FIFO_LAYER_NUM-1)*G_FIFO_WIDTH);
  data_i(G_FIFO_WIDTH-1 downto 0) <= pi_data;

  gen_fifo_data_signals: for LAYER in 2 to G_FIFO_LAYER_NUM generate
    data_i(LAYER*G_FIFO_WIDTH-1 downto (LAYER-1)*G_FIFO_WIDTH) <= data_o((LAYER-1)*G_FIFO_WIDTH-1 downto (LAYER-2)*G_FIFO_WIDTH);
  end generate gen_fifo_data_signals;

  gen_fifo_virtex5 : if G_FIFO_TYPE = "VIRTEX5" generate
    --FWFT for all but last layer
    gen_fifo_layers : for LAYER in 1 to G_FIFO_LAYER_NUM-1 generate
      gen_fifo36 : for i in 1 to G_FIFO36_NUM generate
        ins_fifo_dualclock_macro36 : fifo_dualclock_macro
          generic map (
            DEVICE                  => G_FIFO_TYPE ,  -- Target Device: "VIRTEX5", "VIRTEX6"
            ALMOST_FULL_OFFSET      => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_FULL_OFFSET,14))),  -- Sets almost full threshold
            ALMOST_EMPTY_OFFSET     => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_EMPTY_OFFSET,14))),  -- Sets the almost empty threshold
            DATA_WIDTH              => G_FIFO36_WIDTH,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE               => "36Kb",   -- Target BRAM, "18Kb" or "36Kb"
            FIRST_WORD_FALL_THROUGH => true     -- Sets the FIFO FWFT to TRUE or FALSE
            -- SIM_MODE                => "SAFE")   -- Simulation "SAFE" vs "FAST" (only valid for VIRTEX5)
          )
          port map (
            almostempty => prog_empty(fun_ind(LAYER, i)),  -- Output almost empty
            almostfull  => prog_full(fun_ind(LAYER, i)),  -- Output almost full
            do          => data_o((LAYER-1)*G_FIFO_WIDTH+i*G_FIFO36_WIDTH-1 downto (LAYER-1)*G_FIFO_WIDTH+(i-1)*G_FIFO36_WIDTH),  -- Output data
            empty       => empty(fun_ind(LAYER, i)),   -- Output empty
            full        => full(fun_ind(LAYER, i)),    -- Output full
            rdcount     => rd_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+i*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i-1)*C_FIFO_DEPTH_SIZE),  -- Output read count
            rderr       => open,          -- Output read error
            wrcount     => wr_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+i*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i-1)*C_FIFO_DEPTH_SIZE),  -- Output write count
            wrerr       => open,          -- Output write error
            di          => data_i((LAYER-1)*G_FIFO_WIDTH+i*G_FIFO36_WIDTH-1 downto (LAYER-1)*G_FIFO_WIDTH+(i-1)*G_FIFO36_WIDTH),  -- Input data
            rdclk       => rd_clk(fun_ind(LAYER, i)),  -- Input read clock
            rden        => rd_ena(fun_ind(LAYER, i)),  -- Input read enable
            rst         => pi_reset,       -- Input reset
            wrclk       => wr_clk(fun_ind(LAYER, i)),  -- Input write clock
            wren        => wr_ena(fun_ind(LAYER, i))   -- Input write enable
            );
      end generate gen_fifo36;

      gen_fifo18 : for i in 1 to G_FIFO18_NUM generate
        ins_fifo_dualclock_macro18 : fifo_dualclock_macro
          generic map (
            DEVICE                  => G_FIFO_TYPE,  -- Target Device: "VIRTEX5", "VIRTEX6"
            ALMOST_FULL_OFFSET      => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_FULL_OFFSET,14))),  -- Sets almost full threshold
            ALMOST_EMPTY_OFFSET     => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_EMPTY_OFFSET,14))),  -- Sets the almost empty threshold
            DATA_WIDTH              => G_FIFO36_WIDTH/2,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE               => "18Kb",   -- Target BRAM, "18Kb" or "36Kb"
            FIRST_WORD_FALL_THROUGH => true  -- Sets the FIFO FWFT to TRUE or FALSE
            -- SIM_MODE                => "SAFE")   -- Simulation "SAFE" vs "FAST" (only valid for VIRTEX5)
          )
          port map (
            almostempty => prog_empty(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output almost empty
            almostfull  => prog_full(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output almost full
            do          => data_o((LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+i*G_FIFO36_WIDTH/2-1 downto
                                      (LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+(i-1)*G_FIFO36_WIDTH/2),  -- Output data
            empty       => empty(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output empty
            full        => full(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output full
            rdcount     => rd_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM)*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM-1)*C_FIFO_DEPTH_SIZE),  -- Output read count
            rderr       => open,          -- Output read error
            wrcount     => wr_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM)*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM-1)*C_FIFO_DEPTH_SIZE),  -- Output write count
            wrerr       => open,          -- Output write error
            di          => data_i((LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+i*G_FIFO36_WIDTH/2-1 downto
                                      (LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+(i-1)*G_FIFO36_WIDTH/2),  -- Input data
            rdclk       => rd_clk(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input read clock
            rden        => rd_ena(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input read enable
            rst         => pi_reset,       -- Input reset
            wrclk       => wr_clk(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input write clock
            wren        => wr_ena(fun_ind(LAYER, i+G_FIFO36_NUM))  -- Input write enable
            );
      end generate gen_fifo18;
    end generate gen_fifo_layers;


    -- LAST LAYER
    gen_fifo_last_layer : for LAYER in G_FIFO_LAYER_NUM to G_FIFO_LAYER_NUM generate
      gen_fifo36 : for i in 1 to G_FIFO36_NUM generate
        ins_fifo_dualclock_macro36 : fifo_dualclock_macro
          generic map (
            DEVICE                  => G_FIFO_TYPE,  -- Target Device: "VIRTEX5", "VIRTEX6"
            ALMOST_FULL_OFFSET      => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_FULL_OFFSET,14))),  -- Sets almost full threshold
            ALMOST_EMPTY_OFFSET     => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_EMPTY_OFFSET,14))),  -- Sets the almost empty threshold
            DATA_WIDTH              => G_FIFO36_WIDTH,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE               => "36Kb",   -- Target BRAM, "18Kb" or "36Kb"
            FIRST_WORD_FALL_THROUGH => C_FIFO_FWFT  -- Sets the FIFO FWFT to TRUE or FALSE
            -- SIM_MODE                => "SAFE")   -- Simulation "SAFE" vs "FAST",
          )
          port map (
            almostempty => prog_empty(fun_ind(LAYER, i)),  -- Output almost empty
            almostfull  => prog_full(fun_ind(LAYER, i)),  -- Output almost full
            do          => data_o((LAYER-1)*G_FIFO_WIDTH+i*G_FIFO36_WIDTH-1 downto (LAYER-1)*G_FIFO_WIDTH+(i-1)*G_FIFO36_WIDTH),  -- Output data
            empty       => empty(fun_ind(LAYER, i)),   -- Output empty
            full        => full(fun_ind(LAYER, i)),    -- Output full
            rdcount     => rd_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+i*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i-1)*C_FIFO_DEPTH_SIZE),  -- Output read count
            rderr       => open,          -- Output read error
            wrcount     => wr_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+i*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i-1)*C_FIFO_DEPTH_SIZE),  -- Output write count
            wrerr       => open,          -- Output write error
            di          => data_i((LAYER-1)*G_FIFO_WIDTH+i*G_FIFO36_WIDTH-1 downto (LAYER-1)*G_FIFO_WIDTH+(i-1)*G_FIFO36_WIDTH),  -- Input data
            rdclk       => rd_clk(fun_ind(LAYER, i)),  -- Input read clock
            rden        => rd_ena(fun_ind(LAYER, i)),  -- Input read enable
            rst         => pi_reset,       -- Input reset
            wrclk       => wr_clk(fun_ind(LAYER, i)),  -- Input write clock
            wren        => wr_ena(fun_ind(LAYER, i))   -- Input write enable
            );
      end generate gen_fifo36;

      

      gen_fifo18 : for i in 1 to G_FIFO18_NUM generate
        
        ins_fifo_dualclock_macro18 : fifo_dualclock_macro
          generic map (
            DEVICE                  => G_FIFO_TYPE,  -- Target Device: "VIRTEX5", "VIRTEX6"
            ALMOST_FULL_OFFSET      => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_FULL_OFFSET,14))),  -- Sets almost full threshold
            ALMOST_EMPTY_OFFSET     => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_EMPTY_OFFSET,14))),  -- Sets the almost empty threshold
            DATA_WIDTH              => G_FIFO36_WIDTH/2,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE               => "18Kb",   -- Target BRAM, "18Kb" or "36Kb"
            FIRST_WORD_FALL_THROUGH => C_FIFO_FWFT--,  -- Sets the FIFO FWFT to TRUE or FALSE
            -- SIM_MODE                => "SAFE")   -- Simulation "SAFE" vs "FAST",
          )
          port map (
            almostempty => prog_empty(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output almost empty
            almostfull  => prog_full(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output almost full
            do          => data_o((LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+i*G_FIFO36_WIDTH/2-1 downto
                                      (LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+(i-1)*G_FIFO36_WIDTH/2),  -- Output data
            empty       => empty(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output empty
            full        => full(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output full
            rdcount     => rd_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM)*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM-1)*C_FIFO_DEPTH_SIZE),  -- Output read count
            rderr       => open,          -- Output read error
            wrcount     => wr_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM)*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM-1)*C_FIFO_DEPTH_SIZE),  -- Output write count
            wrerr       => open,          -- Output write error
            di          => data_i((LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+i*G_FIFO36_WIDTH/2-1 downto
                                      (LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+(i-1)*G_FIFO36_WIDTH/2),  -- Input data
            rdclk       => rd_clk(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input read clock
            rden        => rd_ena(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input read enable
            rst         => pi_reset,       -- Input reset
            wrclk       => wr_clk(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input write clock
            wren        => wr_ena(fun_ind(LAYER, i+G_FIFO36_NUM))  -- Input write enable
          );
      end generate gen_fifo18;
    end generate gen_fifo_last_layer;
  end generate gen_fifo_virtex5;

    
  gen_fifo_virtex6_7series : if G_FIFO_TYPE = "VIRTEX6" or G_FIFO_TYPE = "7SERIES" generate
    --FWFT for all but last layer
    gen_fifo_layers : for LAYER in 1 to G_FIFO_LAYER_NUM-1 generate
      gen_fifo36 : for i in 1 to G_FIFO36_NUM generate
        ins_fifo_dualclock_macro36 : entity desy.fifo_dualclock_macro
          generic map (
            DEVICE                  => G_FIFO_TYPE ,  -- Target Device: "VIRTEX5", "VIRTEX6"
            ALMOST_FULL_OFFSET      => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_FULL_OFFSET,14))),  -- Sets almost full threshold
            ALMOST_EMPTY_OFFSET     => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_EMPTY_OFFSET,14))),  -- Sets the almost empty threshold
            DATA_WIDTH              => G_FIFO36_WIDTH,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE               => "36Kb",   -- Target BRAM, "18Kb" or "36Kb"
            FIRST_WORD_FALL_THROUGH => true,     -- Sets the FIFO FWFT to TRUE or FALSE
            -- SIM_MODE                => "SAFE")   -- Simulation "SAFE" vs "FAST" (only valid for VIRTEX5)
            ENABLE_ECC              => G_FIFO_ENABLE_ECC
          )
          port map (
            almostempty => prog_empty(fun_ind(LAYER, i)),  -- Output almost empty
            almostfull  => prog_full(fun_ind(LAYER, i)),  -- Output almost full
            do          => data_o((LAYER-1)*G_FIFO_WIDTH+i*G_FIFO36_WIDTH-1 downto (LAYER-1)*G_FIFO_WIDTH+(i-1)*G_FIFO36_WIDTH),  -- Output data
            empty       => empty(fun_ind(LAYER, i)),   -- Output empty
            full        => full(fun_ind(LAYER, i)),    -- Output full
            rdcount     => rd_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+i*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i-1)*C_FIFO_DEPTH_SIZE),  -- Output read count
            rderr       => open,          -- Output read error
            wrcount     => wr_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+i*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i-1)*C_FIFO_DEPTH_SIZE),  -- Output write count
            wrerr       => open,          -- Output write error
            di          => data_i((LAYER-1)*G_FIFO_WIDTH+i*G_FIFO36_WIDTH-1 downto (LAYER-1)*G_FIFO_WIDTH+(i-1)*G_FIFO36_WIDTH),  -- Input data
            rdclk       => rd_clk(fun_ind(LAYER, i)),  -- Input read clock
            rden        => rd_ena(fun_ind(LAYER, i)),  -- Input read enable
            rst         => pi_reset,       -- Input reset
            wrclk       => wr_clk(fun_ind(LAYER, i)),  -- Input write clock
            wren        => wr_ena(fun_ind(LAYER, i))   -- Input write enable
          );
      end generate gen_fifo36;

      gen_fifo18 : for i in 1 to G_FIFO18_NUM generate
        inst_fifo_dualclock_macro18 : entity desy.fifo_dualclock_macro
          generic map (
            DEVICE                  => G_FIFO_TYPE,  -- Target Device: "VIRTEX5", "VIRTEX6"
            ALMOST_FULL_OFFSET      => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_FULL_OFFSET,14))),  -- Sets almost full threshold
            ALMOST_EMPTY_OFFSET     => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_EMPTY_OFFSET,14))),  -- Sets the almost empty threshold
            DATA_WIDTH              => G_FIFO36_WIDTH/2,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE               => "18Kb",   -- Target BRAM, "18Kb" or "36Kb"
            FIRST_WORD_FALL_THROUGH => true,  -- Sets the FIFO FWFT to TRUE or FALSE
            -- SIM_MODE                => "SAFE")   -- Simulation "SAFE" vs "FAST" (only valid for VIRTEX5)
            ENABLE_ECC              => G_FIFO_ENABLE_ECC
          )
          port map (
            almostempty => prog_empty(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output almost empty
            almostfull  => prog_full(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output almost full
            do          => data_o((LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+i*G_FIFO36_WIDTH/2-1 downto
                                      (LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+(i-1)*G_FIFO36_WIDTH/2),  -- Output data
            empty       => empty(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output empty
            full        => full(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output full
            rdcount     => rd_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM)*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM-1)*C_FIFO_DEPTH_SIZE),  -- Output read count
            rderr       => open,          -- Output read error
            wrcount     => wr_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM)*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM-1)*C_FIFO_DEPTH_SIZE),  -- Output write count
            wrerr       => open,          -- Output write error
            di          => data_i((LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+i*G_FIFO36_WIDTH/2-1 downto
                                      (LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+(i-1)*G_FIFO36_WIDTH/2),  -- Input data
            rdclk       => rd_clk(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input read clock
            rden        => rd_ena(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input read enable
            rst         => pi_reset,       -- Input reset
            wrclk       => wr_clk(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input write clock
            wren        => wr_ena(fun_ind(LAYER, i+G_FIFO36_NUM))  -- Input write enable
          );
      end generate gen_fifo18;
    end generate gen_fifo_layers;


    -- LAST LAYER
    gen_fifo_last_layer : for LAYER in G_FIFO_LAYER_NUM to G_FIFO_LAYER_NUM generate
      gen_fifo36 : for i in 1 to G_FIFO36_NUM generate
        ins_fifo_dualclock_macro36 : entity desy.fifo_dualclock_macro
          generic map (
            DEVICE                  => G_FIFO_TYPE,  -- Target Device: "VIRTEX5", "VIRTEX6"
            ALMOST_FULL_OFFSET      => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_FULL_OFFSET,14))),  -- Sets almost full threshold
            ALMOST_EMPTY_OFFSET     => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_EMPTY_OFFSET,14))),  -- Sets the almost empty threshold
            DATA_WIDTH              => G_FIFO36_WIDTH,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE               => "36Kb",   -- Target BRAM, "18Kb" or "36Kb"
            FIRST_WORD_FALL_THROUGH => C_FIFO_FWFT,  -- Sets the FIFO FWFT to TRUE or FALSE
            -- SIM_MODE                => "SAFE")   -- Simulation "SAFE" vs "FAST",
            ENABLE_ECC              => G_FIFO_ENABLE_ECC
          )
          port map (
            almostempty => prog_empty(fun_ind(LAYER, i)),  -- Output almost empty
            almostfull  => prog_full(fun_ind(LAYER, i)),  -- Output almost full
            do          => data_o((LAYER-1)*G_FIFO_WIDTH+i*G_FIFO36_WIDTH-1 downto (LAYER-1)*G_FIFO_WIDTH+(i-1)*G_FIFO36_WIDTH),  -- Output data
            empty       => empty(fun_ind(LAYER, i)),   -- Output empty
            full        => full(fun_ind(LAYER, i)),    -- Output full
            rdcount     => rd_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+i*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i-1)*C_FIFO_DEPTH_SIZE),  -- Output read count
            rderr       => open,          -- Output read error
            wrcount     => wr_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+i*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i-1)*C_FIFO_DEPTH_SIZE),  -- Output write count
            wrerr       => open,          -- Output write error
            di          => data_i((LAYER-1)*G_FIFO_WIDTH+i*G_FIFO36_WIDTH-1 downto (LAYER-1)*G_FIFO_WIDTH+(i-1)*G_FIFO36_WIDTH),  -- Input data
            rdclk       => rd_clk(fun_ind(LAYER, i)),  -- Input read clock
            rden        => rd_ena(fun_ind(LAYER, i)),  -- Input read enable
            rst         => pi_reset,       -- Input reset
            wrclk       => wr_clk(fun_ind(LAYER, i)),  -- Input write clock
            wren        => wr_ena(fun_ind(LAYER, i))   -- Input write enable
          );
      end generate gen_fifo36;
      
      gen_fifo18 : for i in 1 to G_FIFO18_NUM generate
        ins_fifo_dualclock_macro18 : entity desy.fifo_dualclock_macro
          generic map (
            DEVICE                  => G_FIFO_TYPE,  -- Target Device: "VIRTEX5", "VIRTEX6"
            ALMOST_FULL_OFFSET      => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_FULL_OFFSET,14))),  -- Sets almost full threshold
            ALMOST_EMPTY_OFFSET     => to_bitvector(std_logic_vector(to_unsigned(C_FIFO_PROG_EMPTY_OFFSET,14))),  -- Sets the almost empty threshold
            DATA_WIDTH              => G_FIFO36_WIDTH/2,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE               => "18Kb",   -- Target BRAM, "18Kb" or "36Kb"
            FIRST_WORD_FALL_THROUGH => C_FIFO_FWFT,  -- Sets the FIFO FWFT to TRUE or FALSE
            -- SIM_MODE                => "SAFE")   -- Simulation "SAFE" vs "FAST",
            ENABLE_ECC              => G_FIFO_ENABLE_ECC
          )
          port map (
            almostempty => prog_empty(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output almost empty
            almostfull  => prog_full(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output almost full
            do          => data_o((LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+i*G_FIFO36_WIDTH/2-1 downto
                                      (LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+(i-1)*G_FIFO36_WIDTH/2),  -- Output data
            empty       => empty(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output empty
            full        => full(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Output full
            rdcount     => rd_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM)*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM-1)*C_FIFO_DEPTH_SIZE),  -- Output read count
            rderr       => open,          -- Output read error
            wrcount     => wr_counter((LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM)*C_FIFO_DEPTH_SIZE-1 downto
                                          (LAYER-1)*(C_FIFO_DEPTH_SIZE*(G_FIFO36_NUM+G_FIFO18_NUM))+(i+G_FIFO36_NUM-1)*C_FIFO_DEPTH_SIZE),  -- Output write count
            wrerr       => open,          -- Output write error
            di          => data_i((LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+i*G_FIFO36_WIDTH/2-1 downto
                                      (LAYER-1)*G_FIFO_WIDTH+G_FIFO36_NUM*G_FIFO36_WIDTH+(i-1)*G_FIFO36_WIDTH/2),  -- Input data
            rdclk       => rd_clk(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input read clock
            rden        => rd_ena(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input read enable
            rst         => pi_reset,       -- Input reset
            wrclk       => wr_clk(fun_ind(LAYER, i+G_FIFO36_NUM)),  -- Input write clock
            wren        => wr_ena(fun_ind(LAYER, i+G_FIFO36_NUM))  -- Input write enable
          );
      end generate gen_fifo18;
    end generate gen_fifo_last_layer;
  end generate gen_fifo_virtex6_7series;
  
end architecture rtl;
