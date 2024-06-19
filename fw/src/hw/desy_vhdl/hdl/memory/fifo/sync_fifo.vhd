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
--! 
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity sync_fifo is
  generic (
    G_FIFO_DEPTH : positive := 1024;    --! FIFO Depth (write words)
    G_FIFO_WIDTH : positive := 256;     --! FIFO PORT WIDTH
    G_FIFO_FWFT  : natural  := 1        --! First Word Fall Througth
  );  
  port (
    pi_reset : in std_logic;          --! sync reset
    pi_clock : in std_logic;          --! clock

    pi_data   : in  std_logic_vector(G_FIFO_WIDTH-1 downto 0);  --! write port
    pi_wr_ena : in  std_logic;                                  --! write request
    pi_rd_ena : in  std_logic;                                  --! read request
    po_data   : out std_logic_vector(G_FIFO_WIDTH-1 downto 0);  --! read port
    po_full   : out std_logic;                                  --! FIFO full
    po_empty  : out std_logic                                   --! FIFO empty
  );
end entity sync_fifo;

architecture Behavioral of sync_fifo is

begin

  -- Memory Pointer Process
  proc_fifo : process (pi_clock)
    type t_fifo is array (G_FIFO_DEPTH-1 downto 0) of std_logic_vector(G_FIFO_WIDTH-1 downto 0);
    variable v_fifo : t_fifo;
    
    variable v_head   : natural range 0 to G_FIFO_DEPTH - 1;
    variable v_tail   : natural range 0 to G_FIFO_DEPTH - 1;
    variable v_looped : std_logic;
    
  begin
    if rising_edge(pi_clock) then
      if pi_reset = '1' then
        v_head := 0;
        v_tail := 0;
        
        v_looped := '0';
        
        po_full  <= '0';
        po_empty <= '1';
      else
        

        if (pi_rd_ena = '1') then
          if ((v_looped = '1') or (v_head /= v_tail)) then
           if G_FIFO_FWFT = 0 then
             po_data <= v_fifo(v_tail);  -- Update data output no FWFT                    
           end if;
                                        -- Update V_TAIL pointer as needed
            if (v_tail = G_FIFO_DEPTH - 1) then
              v_tail := 0;
              
              v_looped := '0';
            else
              v_tail := v_tail + 1;
            end if;
            
            
          end if;
        end if;
        
        if (pi_wr_ena = '1') then
          if ((v_looped = '0') or (v_head /= v_tail)) then
                                        -- write data to v_fifo
            v_fifo(v_head) := pi_data;
            
                                        -- increment v_head pointer as needed
            if (v_head = G_FIFO_DEPTH - 1) then
              v_head := 0;
              
              v_looped := '1';
            else
              v_head := v_head + 1;
            end if;
          end if;
        end if;

        -- Update data output FWFT
        if G_FIFO_FWFT /= 0 then
          po_data <= v_fifo(v_tail);
        end if;
        
        -- Update po_empty and po_full flags
        if (v_head = v_tail) then
          if v_looped = '1' then
            po_full <= '1';
          else
            po_empty <= '1';
          end if;
        else
          po_empty <= '0';
          po_full  <= '0';
        end if;

      end if;
    end if;
  end process;

end Behavioral;
