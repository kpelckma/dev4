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
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
------------------------------------------------------------------------------
--! @brief
--! 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

-- library xpm;
-- use xpm.vcomponents.all;
library unisim;
use unisim.vcomponents.all;

entity fifo_xpm is
  generic (
    G_FIFO_WRITE_WIDTH      : positive := 18;      -- WIDTH of the I/O
    G_FIFO_READ_WIDTH       : positive := 18;      -- WIDTH of the I/O
    G_FIFO_DEPTH            : positive := 2048;    -- Depth of the layer
    G_FIFO_FWFT             : natural  := 1;       -- First Word Fall Througth
    G_RELATED_CLOCKS        : natural  := 0;       --
    G_CDC_SYNC_STAGES       : positive := 2;       --
    G_FIFO_PROG_FULL_OFFSET : natural  := 128;
    G_FIFO_PROG_EMPTY_OFFSET: natural  := 128
  );
  port (
    pi_reset         : in  std_logic;                                     -- async reset

    pi_wr_clk      : in  std_logic;                                       -- write clock
    pi_wr_ena      : in  std_logic;                                       -- write request
    pi_data        : in  std_logic_vector(G_FIFO_WRITE_WIDTH-1 downto 0); -- write port
    po_full        : out std_logic;                                       -- FIFO full
    po_prog_full   : out std_logic;                                       -- Programmable full
    po_wr_rst_busy : out std_logic;                                       -- Write reset busy

    pi_rd_clk      : in  std_logic;                                       -- read clock
    pi_rd_ena      : in  std_logic;                                       -- read request
    po_data        : out std_logic_vector(G_FIFO_READ_WIDTH-1 downto 0);  -- read port
    po_empty       : out std_logic;                                       -- FIFO empty
    po_prog_empty  : out std_logic;                                       -- Programmable empty
    po_rd_rst_busy : out std_logic                                        -- read reset busy
  );
end entity fifo_xpm;

architecture rtl of fifo_xpm is

  function FUN_READ_LATENCY  return natural is
  begin
    if G_FIFO_FWFT = 1 then
      return 0;
    else
      return 1;
    end if;
  end function ;

  function FUN_FIFO_FWFT  return string is
  begin
    if G_FIFO_FWFT = 1 then
      return "fwft";
    else
      return "std";
    end if;
  end function ;

  constant C_READ_LATENCY : natural :=  FUN_READ_LATENCY;
  constant C_FIFO_FWFT    : string := FUN_FIFO_FWFT;

  constant C_FIFO_WR_CNT_SIZE : natural := integer(CEIL(LOG2(real(G_FIFO_DEPTH))));
  constant C_FIFO_RD_CNT_SIZE : natural := integer(CEIL(LOG2(real(G_FIFO_DEPTH*G_FIFO_WRITE_WIDTH/G_FIFO_READ_WIDTH))));

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
      full_offset := G_FIFO_DEPTH/2+1;
    else
      full_offset := G_FIFO_PROG_FULL_OFFSET;
    end if;
    return full_offset;
  end function;

  constant C_FIFO_PROG_EMPTY_OFFSET : integer := fun_get_empty_offset;
  constant C_FIFO_PROG_FULL_OFFSET  : integer := fun_get_full_offset;

  component xpm_fifo_async
    generic (

      -- Common module generics
      FIFO_MEMORY_TYPE         : string   := "auto";
      FIFO_WRITE_DEPTH         : integer  := 2048;
      CASCADE_HEIGHT           : integer  := 0;
      RELATED_CLOCKS           : integer  := 0;
      WRITE_DATA_WIDTH         : integer  := 32;
      READ_MODE                : string   :="std";
      FIFO_READ_LATENCY        : integer  := 1;
      FULL_RESET_VALUE         : integer  := 0;
      USE_ADV_FEATURES         : string   :="0707";
      READ_DATA_WIDTH          : integer  := 32;
      CDC_SYNC_STAGES          : integer  := 2;
      WR_DATA_COUNT_WIDTH      : integer  := 1;
      PROG_FULL_THRESH         : integer  := 10;
      RD_DATA_COUNT_WIDTH      : integer  := 1;
      PROG_EMPTY_THRESH        : integer  := 10;
      DOUT_RESET_VALUE         : string   := "0";
      ECC_MODE                 : string   :="no_ecc";
      SIM_ASSERT_CHK           : integer := 0    ;
      WAKEUP_TIME              : integer  := 0
    );
    port (

      sleep          : in std_logic;
      rst            : in std_logic;
      wr_clk         : in std_logic;
      wr_en          : in std_logic;
      din            : in std_logic_vector(WRITE_DATA_WIDTH-1 downto 0);
      full           : out std_logic;
      prog_full      : out std_logic;
      wr_data_count  : out std_logic_vector(WR_DATA_COUNT_WIDTH-1 downto 0);
      overflow       : out std_logic;
      wr_rst_busy    : out std_logic;
      almost_full    : out std_logic;
      wr_ack         : out std_logic;
      rd_clk         : in std_logic;
      rd_en          : in std_logic;
      dout           : out std_logic_vector(READ_DATA_WIDTH-1 downto 0);
      empty          : out std_logic;
      prog_empty     : out std_logic;
      rd_data_count  : out std_logic_vector(RD_DATA_COUNT_WIDTH-1 downto 0);
      underflow      : out std_logic;
      rd_rst_busy    : out std_logic;
      almost_empty   : out std_logic;
      data_valid     : out std_logic;
      injectsbiterr  : in std_logic;
      injectdbiterr  : in std_logic;
      sbiterr        : out std_logic;
      dbiterr        : out std_logic
    );
  end component;

begin

  -- xpm_fifo_async: Asynchronous FIFO
  -- Xilinx Parameterized Macro, Version 2017.3

  ins_xpm_fifo : xpm_fifo_async
    generic map (
      FIFO_MEMORY_TYPE    => "block",                    --string; "auto", "block", or "distributed";
      ECC_MODE            => "no_ecc",                   --string; "no_ecc" or "en_ecc";
      RELATED_CLOCKS      => G_RELATED_CLOCKS,           --positive integer; 0 or 1
      FIFO_WRITE_DEPTH    => G_FIFO_DEPTH,               --positive integer
      WRITE_DATA_WIDTH    => G_FIFO_WRITE_WIDTH,         --positive integer
      WR_DATA_COUNT_WIDTH => C_FIFO_WR_CNT_SIZE,         --positive integer
      PROG_FULL_THRESH    => C_FIFO_PROG_FULL_OFFSET,    --positive integer
      FULL_RESET_VALUE    => 0,                          --positive integer; 0 or 1;
      USE_ADV_FEATURES    => "0707",                     --string; "0000" to "1F1F";
      READ_MODE           => C_FIFO_FWFT,                --string; "std" or "fwft";
      FIFO_READ_LATENCY   => C_READ_LATENCY,             --positive integer;
      READ_DATA_WIDTH     => G_FIFO_READ_WIDTH,          --positive integer
      RD_DATA_COUNT_WIDTH => C_FIFO_RD_CNT_SIZE,         --positive integer
      PROG_EMPTY_THRESH   => C_FIFO_PROG_EMPTY_OFFSET,   --positive integer
      DOUT_RESET_VALUE    => "0",                        --string
      CDC_SYNC_STAGES     => G_CDC_SYNC_STAGES,          --positive integer
      WAKEUP_TIME         => 0                           --positive integer; 0 or 2;
    )
    port map (
      sleep         => '0',
      rst           => pi_reset,
      wr_clk        => pi_wr_clk,
      wr_en         => pi_wr_ena,
      din           => pi_data,
      full          => po_full,
      overflow      => open,
      wr_rst_busy   => po_wr_rst_busy,
      prog_full     => po_prog_full,
      wr_data_count => open,
      almost_full   => open,
      wr_ack        => open,
      rd_clk        => pi_rd_clk,
      rd_en         => pi_rd_ena,
      dout          => po_data,
      empty         => po_empty,
      underflow     => open,
      rd_rst_busy   => po_rd_rst_busy,
      prog_empty    => po_prog_empty,
      rd_data_count => open,
      almost_empty  => open,
      data_valid    => open,
      injectsbiterr => '0',
      injectdbiterr => '0',
      sbiterr       => open,
      dbiterr       => open
    );
  -- End of xpm_fifo_async_inst instance declaration

end architecture rtl;
