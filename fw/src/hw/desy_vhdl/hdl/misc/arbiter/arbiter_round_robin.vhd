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
--! @author Lukasz Butkowski <lukasz.butkowski@desy/de>
------------------------------------------------------------------------------
--! @brief
--! Simple synch arbiter with round robin arbiter
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arbiter_round_robin is
  generic (
    G_NUM       : positive := 4;
    G_SYNC_MODE : natural  := 1
  );
  port  (
    pi_clock   : in std_logic;
    pi_reset : in std_logic;
    pi_req   : in  std_logic_vector(G_NUM-1 downto 0);
    pi_ack   : in std_logic;
    po_grant : out std_logic_vector(G_NUM-1 downto 0)
  );
end arbiter_round_robin;

architecture arch of arbiter_round_robin is

  signal req        : std_logic_vector(G_NUM-1 downto 0) := (others => '0');
  signal req_mask   : std_logic_vector(G_NUM-1 downto 0) := (others => '0');
  signal req_masked : std_logic_vector(G_NUM-1 downto 0) := (others => '0');
  signal req_grant  : std_logic_vector(G_NUM-1 downto 0) := (others => '0');
  signal grant      : std_logic_vector(G_NUM-1 downto 0) := (others => '0');
  signal grant_raw  : std_logic_vector(G_NUM-1 downto 0) := (others => '0');
  signal grant_mask : std_logic_vector(G_NUM-1 downto 0) := (others => '0');
  signal reg_win    : std_logic_vector(G_NUM-1 downto 0) := (others => '0');
  signal ack        : std_logic ;
  
begin
  
  po_grant <= req_grant;
  ack   <= pi_ack ;
  -----------------------------------------------------------------------------
  -- generate mask based on the previous winner
  req_mask <= std_logic_vector(shift_left(-signed(reg_win),1));
  -----------------------------------------------------------------------------
  -- masked request signal
  req_masked <= req and req_mask  ;
  
  grant <= grant_raw when unsigned(req_masked) = 0 else grant_mask;

  -----------------------------------------------------------------------------
  -- select arbiter and latch previous state, update output synchronous
  -- synchronous mode require one clock cycle after ack to aquire new grant
  gen_sync_out : if G_SYNC_MODE = 1 generate
    process(pi_clock)
    begin
      -- if pi_reset = '1' then
        -- req_grant <= (others => '0');
        -- reg_win   <= (others => '0');
        -- req   <= (others => '0');
      -- els
      if rising_edge(pi_clock) then 

        if unsigned(req_grant) = 0 or pi_reset = '1' then
          req_grant <= grant ;
          reg_win   <= grant ;
          req       <= pi_req  ;
        else
          if ack = '1'  then
            reg_win   <= req_grant ;
            req_grant <= (others => '0');
            req       <= pi_req ;
          elsif unsigned(pi_req) = 0 then
            reg_win   <= (others => '0');
            req_grant <= (others => '0');
            req       <= pi_req ;
          -- else
            -- req_grant <= grant ;
          end if;
        end if;
        
      end if;
    end process;
  end generate;
  -- GEN_SYNC_OUT : if G_SYNC_MODE = 1 generate
    -- process(pi_clock, pi_reset)
    -- begin
      -- if pi_reset = '1' then
        -- reg_win   <= (others => '0');
        -- grant <= (others => '0');
      -- elsif rising_edge(pi_clock) then 
        -- reg_win   <= reg_win ;
        -- grant <= grant ;
        
        -- if ack = '1' then
          -- reg_win   <= grant ;
          -- grant <= ( others => '0' ) ;
        -- -- end if;
        -- else
          -- if unsigned(req) = 0  then
            -- grant <= grant_raw ;
          -- else
            -- grant <= grant_mask ;
          -- end if;
        -- end if;
        
      -- end if;
    -- end process;
  -- end generate;

  -----------------------------------------------------------------------------
  -- select arbiter and latch previous state, update output synchronou
  gen_async_out : if G_SYNC_MODE = 0 generate
    -- grant <= grant_raw when unsigned(req) = 0 else grant_mask;
    req   <= pi_req   ;
    req_grant <= grant ;
    
    process(pi_clock, pi_reset)
    begin
      if pi_reset = '1' then
        reg_win   <= (others => '0');
      elsif rising_edge(pi_clock) then 
        reg_win <= reg_win ;
        if ack = '1' then
          reg_win  <= grant ;
        end if;
      end if;
    end process;
  end generate;

  -----------------------------------------------------------------------------
  -- priority arbieters for masked and not masked request
  grant_raw   <= pi_req and ( (std_logic_vector(unsigned(not pi_req) + 1) ));
  grant_mask  <= req_masked and ( (std_logic_vector(unsigned(not req_masked) + 1) ));
  
  
  -- process(pi_req, grant_raw)
  -- begin
    -- if unsigned(pi_req and grant_raw) = 0 then
      -- grant_raw <= (others => '0');
      -- for i in G_NUM-1 downto 0 loop
        -- if pi_req(i) = '1' then
          -- grant_raw    <= (others => '0');
          -- grant_raw(i) <= '1';
        -- end if;
      -- end loop;
    -- end if;
  -- end process;
  
  -- process(req, grant_mask)
  -- begin
    -- if unsigned(req and grant_mask) = 0 then
      -- grant_mask <= (others => '0');
      -- for i in G_NUM-1 downto 0 loop
        -- if req(i) = '1' then
          -- grant_mask    <= (others => '0');
          -- grant_mask(i) <= '1';
        -- end if;
      -- end loop;
    -- end if;
  -- end process;
  
  
end arch;


