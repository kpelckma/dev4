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
--! @date 2019-05-02
--! @author Lukasz Butkowski  <lukasz.butkowski@desy.de>
--! @brief
--! AXI4 buffer single channel handshaking
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi4_buf_sch is
  generic (
    G_DATA_WIDTH : natural := 32
  );
  port (
    pi_aclk    : in std_logic;

    po_m_ready : out std_logic;
    pi_m_valid : in std_logic;
    pi_m_data  : in std_logic_vector(g_data_width-1 downto 0);

    pi_s_ready : in std_logic ;
    po_s_valid : out std_logic ;
    po_s_data  : out std_logic_vector(g_data_width-1 downto 0)
 );
end entity axi4_buf_sch;


architecture arch of axi4_buf_sch is

  signal wena    : std_logic := '0';
  signal rena    : std_logic := '0';

  signal ready   : std_logic := '0';
  signal valid   : std_logic := '0';

  signal data_0  : std_logic_vector(G_DATA_WIDTH-1 downto 0):= (others => '0');
  signal data_1  : std_logic_vector(G_DATA_WIDTH-1 downto 0):= (others => '0');

  signal wr_st   : std_logic_vector(1 downto 0) := "00" ;
  signal rd_st   : std_logic := '0' ;

begin

  ready      <= '0' when wr_st = "11" or rd_st = '1' else '1';
  wena       <= ready and pi_m_valid;
  po_m_ready <= ready;

  valid      <= '0' when wr_st = "00" else '1';
  rena       <= valid and pi_s_ready;
  po_s_valid <= valid;

  po_s_data  <= data_1 when rd_st = '1' else data_0 ;

  -- write process
  prc_write : process (pi_aclk)
  begin
    if rising_edge(pi_aclk) then
      if wena = '1' and wr_st = "00" then
        data_0 <= pi_m_data ;
        wr_st  <= "01";

      elsif wena = '1' and wr_st = "01" and rena ='1' then
        data_0 <= pi_m_data ;
        wr_st  <= "01";

      elsif wena = '1' and wr_st = "01" and rena ='0' and rd_st = '0' then
        data_1 <= pi_m_data ;
        wr_st  <= "11";

      elsif wena = '1' and wr_st = "11" and rena ='1' then
        data_0 <= pi_m_data ;
        wr_st  <= "01";

      elsif wena = '0' and wr_st = "11" and rena ='1' then
        wr_st  <= "01";

      elsif wena = '0' and wr_st = "01" and rena ='1' then
        wr_st  <= "00";

      end if;
    end if;
  end process;

  -- read frpag change
  prc_read : process (pi_aclk)
  begin
    if rising_edge(pi_aclk) then
      if wr_st = "01" and rena = '1' then
        rd_st <= '0';
      elsif wr_st = "11" and rena = '1' then
        rd_st <= '1';
      end if;
    end if;
  end process;

end architecture arch;
