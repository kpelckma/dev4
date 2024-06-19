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
--! @author MSK FPGA Team
------------------------------------------------------------------------------
--! @brief
--!
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library std;
use std.textio.all;

entity fifo_dualclock_macro is
  generic(
    ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    ALMOST_EMPTY_OFFSET     : bit_vector := X"0080";
    DATA_WIDTH              : integer    := 4;
    DEVICE                  : string     := "VIRTEX6";
    FIFO_SIZE               : string     := "18Kb";
    FIRST_WORD_FALL_THROUGH : boolean    := false;
    INIT                    : bit_vector := X"000000000000000000";  -- This parameter is valid only for Virtex6
    SRVAL                   : bit_vector := X"000000000000000000";  -- This parameter is valid only for Virtex6
    SIM_MODE                : string     := "SAFE";                 -- This parameter is valid only for Virtex5
    ENABLE_ECC              : boolean    := false
  );
  port(
    almostempty : out std_logic;
    almostfull  : out std_logic;
    do          : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    empty       : out std_logic;
    full        : out std_logic;
    rdcount     : out std_logic_vector;
    rderr       : out std_logic;
    wrcount     : out std_logic_vector;
    wrerr       : out std_logic;
    sbiterr     : out std_logic;
    dbiterr     : out std_logic;
    di          : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    rdclk       : in  std_logic;
    rden        : in  std_logic;
    rst         : in  std_logic;
    wrclk       : in  std_logic;
    wren        : in  std_logic
  );

end entity fifo_dualclock_macro;

architecture fifo_V of fifo_dualclock_macro is

  function GetDWidth(
    d_width : in integer
  ) return integer is
    variable func_width : integer;
    variable Message    : line;
  begin
    if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      case d_width is
        when 0|1|2|3|4 => func_width := 4;
          if (d_width = 0) then
            write(Message, string'("Illegal value of Attribute DATA_WIDTH : "));
            write(Message, string'(". This attribute must atleast be equal to 1 . "));
            assert false report Message.all severity failure;
            DEALLOCATE(Message);
          end if;
        when 5|6|7|8|9 => func_width := 8;
        when 10 to 18  => func_width := 16;
        when 19 to 36  => func_width := 32;
        when 37 to 72 =>
          if (FIFO_SIZE = "18Kb") then
            write(Message, string'("Illegal value of Attribute DATA_WIDTH : "));
            write(Message, string'(". Legal values of this attribute for FIFO_SIZE 18Kb are "));
            write(Message, string'(" 1 to 36 "));
            assert false report Message.all severity failure;
            DEALLOCATE(Message);
          else
            func_width := 64;
          end if;
        when others => write(Message, string'("Illegal value of Attribute DATA_WIDTH : "));
                       write(Message, string'(". Legal values of this attribute are "));
                       write(Message, string'(" 1 to 36 for FIFO_SIZE of 18Kb and "));
                       write(Message, string'(" 1 to 72 for FIFO_SIZE of 36Kb ."));
                       assert false report Message.all severity failure;
                       DEALLOCATE(Message);
                       func_width := 64;
      end case;
    else
      func_width := 64;
    end if;
    return func_width;
  end;
  function GetD_Size(
    d_size : in integer
  ) return integer is
    variable func_width : integer;
  begin
    if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      case d_size is
        when 0|1|2|3|4 => func_width := 4;
        when 5|6|7|8|9 => func_width := 9;
        when 10 to 18  => func_width := 18;
        when 19 to 36  => func_width := 36;
        when 37 to 72  => func_width := 72;
        when others    => func_width := 1;
      end case;
    else
      func_width := 1;
    end if;
    return func_width;
  end;

  function GetDIPWidth(
    d_width : in integer
  ) return integer is
    variable func_width : integer;
  begin
    if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      case d_width is
        when 9      => func_width := 1;
        when 17     => func_width := 1;
        when 18     => func_width := 2;
        when 33     => func_width := 1;
        when 34     => func_width := 2;
        when 35     => func_width := 3;
        when 36     => func_width := 4;
        when 65     => func_width := 1;
        when 66     => func_width := 2;
        when 67     => func_width := 3;
        when 68     => func_width := 4;
        when 69     => func_width := 5;
        when 70     => func_width := 6;
        when 71     => func_width := 7;
        when 72     => func_width := 8;
        when others => func_width := 0;
      end case;
    else
      func_width := 0;
    end if;
    return func_width;
  end;
  function GetDOPWidth(
    d_width : in integer
  ) return integer is
    variable func_width : integer;
  begin
    if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      case d_width is
        when 9      => func_width := 1;
        when 17     => func_width := 1;
        when 18     => func_width := 2;
        when 33     => func_width := 1;
        when 34     => func_width := 2;
        when 35     => func_width := 3;
        when 36     => func_width := 4;
        when 65     => func_width := 1;
        when 66     => func_width := 2;
        when 67     => func_width := 3;
        when 68     => func_width := 4;
        when 69     => func_width := 5;
        when 70     => func_width := 6;
        when 71     => func_width := 7;
        when 72     => func_width := 8;
        when others => func_width := 1;
      end case;
    else
      func_width := 1;
    end if;
    return func_width;
  end;

  function GetCOUNTWidth(
    d_width : in integer
  ) return integer is
    variable func_width : integer;
  begin
    if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      if (FIFO_SIZE = "18Kb") then
        case d_width is
          when 0|1|2|3|4 => func_width := 12;
          when 5|6|7|8|9 => func_width := 11;
          when 10 to 18  => func_width := 10;
          when 19 to 36  => func_width := 9;
          when others    => func_width := 12;
        end case;
      elsif (FIFO_SIZE = "36Kb") then
        case d_width is
          when 0|1|2|3|4 => func_width := 13;
          when 5|6|7|8|9 => func_width := 12;
          when 10 to 18  => func_width := 11;
          when 19 to 36  => func_width := 10;
          when 37 to 72  => func_width := 9;
          when others    => func_width := 13;
        end case;
      end if;
    else
      func_width := 13;
    end if;
    return func_width;
  end;

  function GetMaxDWidth(
    d_width : in integer
  ) return integer is
    variable func_width : integer;
    variable Message    : line;
  begin
    if (DEVICE = "VIRTEX5") then
      if (FIFO_SIZE = "18Kb" and d_width <= 18) then
        func_width := 16;
      elsif (FIFO_SIZE = "18Kb" and d_width > 18 and d_width <= 36) then
        func_width := 32;
      elsif (FIFO_SIZE = "36Kb" and d_width <= 36) then
        func_width := 32;
      elsif (FIFO_SIZE = "36Kb" and d_width > 36 and d_width <= 72) then
        func_width := 64;
      else
        func_width := 64;
      end if;
    elsif (DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      if (FIFO_SIZE = "18Kb" and d_width <= 36) then
        func_width := 32;
      elsif (FIFO_SIZE = "36Kb" and d_width <= 72) then
        func_width := 64;
      else
        func_width := 64;
      end if;  -- end b1
    else
      func_width := 64;
    end if;
    return func_width;
  end;
  function GetMaxDPWidth(
    d_width : in integer
  ) return integer is
    variable func_width : integer;
    variable Message    : line;
  begin
    if (DEVICE = "VIRTEX5") then
      if (FIFO_SIZE = "18Kb" and d_width <= 18) then
        func_width := 2;
      elsif (FIFO_SIZE = "18Kb" and d_width > 18 and d_width <= 36) then
        func_width := 4;
      elsif (FIFO_SIZE = "36Kb" and d_width <= 36) then
        func_width := 4;
      elsif (FIFO_SIZE = "36Kb" and d_width > 36 and d_width <= 72) then
        func_width := 8;
      else
        func_width := 8;
      end if;
    elsif (DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      if (FIFO_SIZE = "18Kb" and d_width <= 36) then
        func_width := 4;
      elsif (FIFO_SIZE = "36Kb" and d_width <= 72) then
        func_width := 8;
      else
        func_width := 8;
      end if;  -- end b2

    else
      func_width := 8;
    end if;
    return func_width;
  end;
  function GetFinalWidth(
    d_width : in integer
  ) return integer is
    variable func_least_width : integer;
  begin
    if (d_width = 0) then
      func_least_width := 1;
    else
      func_least_width := d_width;
    end if;
    return func_least_width;
  end;
  function GetMaxCOUNTWidth(
    d_width : in integer
  ) return integer is
    variable func_width : integer;
  begin
    if (DEVICE = "VIRTEX5") then
      if (FIFO_SIZE = "18Kb" and d_width <= 18) then
        func_width := 12;
      elsif (FIFO_SIZE = "18Kb" and d_width > 18 and d_width <= 36) then
        func_width := 9;
      elsif (FIFO_SIZE = "36Kb" and d_width <= 36) then
        func_width := 13;
      elsif (FIFO_SIZE = "36Kb" and d_width > 36 and d_width <= 72) then
        func_width := 9;
      else
        func_width := 13;
      end if;
    elsif (DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      if (FIFO_SIZE = "18Kb" and d_width <= 36) then
        func_width := 12;
      elsif (FIFO_SIZE = "36Kb" and d_width <= 72) then
        func_width := 13;
      else
        func_width := 13;
      end if;  -- end b3
    else
      func_width := 13;
    end if;
    return func_width;
  end;

  function GetFIFOSize return boolean is
    variable fifo_val : boolean;
    variable Message  : line;
  begin
    if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      if FIFO_SIZE = "18Kb" or FIFO_SIZE = "36Kb" then
        fifo_val := true;
      else
        fifo_val := false;
        write(Message, string'("Illegal value of Attribute FIFO_SIZE : "));
        write(Message, FIFO_SIZE);
        write(Message, string'(". Legal values of this attribute are "));
        write(Message, string'(" 18Kb or 36Kb "));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
      end if;
    else
      fifo_val := false;
      write(Message, string'("Illegal value of Attribute DEVICE : "));
      write(Message, DEVICE);
      write(Message, string'(". Allowed values of this attribute are "));
      write(Message, string'(" VIRTEX5, VIRTEX6, 7SERIES. "));
      assert false report Message.all severity failure;
      DEALLOCATE(Message);
    end if;
    return fifo_val;
  end;

  function GetD_P(
    dw : in integer
  ) return boolean is
    variable dp : boolean;
  begin
    if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") then
      if dw = 9 or dw = 17 or dw = 18 or dw = 33 or dw = 34 or dw = 35 or dw = 36 or dw = 65 or dw = 66 or dw = 67 or dw = 68 or dw = 69 or dw = 70 or dw = 71 or dw = 72 then
        dp := true;
      else
        dp := false;
      end if;
    else
      dp := false;
    end if;
    return dp;
  end;

  function GetSIMDev return string is
  begin
    if (DEVICE = "VIRTEX6") then
      return "VIRTEX6";
    else
      return "7SERIES";
    end if;
  end;

  function CheckRDCount(
    d_width : in integer;
    rd_vec  : in integer
  ) return boolean is
    variable Message : line;
  begin
    if (FIFO_SIZE = "18Kb") then
      if ((d_width > 0 and d_width <= 4) and rd_vec /= 12) then
        write(Message, string'("rdcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .rdcount must be of width 12 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 4 and d_width <= 9) and rd_vec /= 11) then
        write(Message, string'("rdcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .rdcount must be of width 11 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width >= 10 and d_width <= 18) and rd_vec /= 10) then
        write(Message, string'("rdcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .rdcount must be of width 10 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 19 and d_width <= 36) and rd_vec /= 9) then
        write(Message, string'(" .rdcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .rdcount must be of width 9 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      else
        return true;
      end if;
    elsif (FIFO_SIZE = "36Kb") then
      if ((d_width > 0 and d_width <= 4) and rd_vec /= 13) then
        write(Message, string'("rdcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .rdcount must be of width 13 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 4 and d_width <= 9) and rd_vec /= 12) then
        write(Message, string'("rdcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .rdcount must be of width 12 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width >= 10 and d_width <= 18) and rd_vec /= 11) then
        write(Message, string'("rdcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .rdcount must be of width 11 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 18 and d_width <= 36) and rd_vec /= 10) then
        write(Message, string'("rdcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .rdcount must be of width 10 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 36 and d_width <= 72) and rd_vec /= 9) then
        write(Message, string'("rdcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .rdcount must be of width 9 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      else
        return true;
      end if;
    else
      return true;
    end if;
  end;

  function CheckWRCount(
    d_width : in integer;
    wr_vec  : in integer
  ) return boolean is
    variable Message : line;
  begin
    if (FIFO_SIZE = "18Kb") then
      if ((d_width > 0 and d_width <= 4) and wr_vec /= 12) then
        write(Message, string'("wrcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .wrcount must be of width 12 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 4 and d_width <= 9) and wr_vec /= 11) then
        write(Message, string'("wrcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .wrcount must be of width 11 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width >= 10 and d_width <= 18) and wr_vec /= 10) then
        write(Message, string'("wrcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .wrcount must be of width 10 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 19 and d_width <= 36) and wr_vec /= 9) then
        write(Message, string'("wrcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .wrcount must be of width 9 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      else
        return true;
      end if;
    elsif (FIFO_SIZE = "36Kb") then
      if ((d_width > 0 and d_width <= 4) and wr_vec /= 13) then
        write(Message, string'("wrcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .wrcount must be of width 13 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 4 and d_width <= 9) and wr_vec /= 12) then
        write(Message, string'("wrcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .wrcount must be of width 12 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width >= 10 and d_width <= 18) and wr_vec /= 11) then
        write(Message, string'("wrcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .wrcount must be of width 11 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 18 and d_width <= 36) and wr_vec /= 10) then
        write(Message, string'("wrcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .wrcount must be of width 10 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif ((d_width > 36 and d_width <= 72) and wr_vec /= 9) then
        write(Message, string'("wrcount port width incorrectly set for DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        write(Message, string'(" .wrcount must be of width 9 ."));
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      else
        return true;
      end if;
    else
      return true;
    end if;
  end;

  function CheckDataWidthECC(
    d_width : in integer
  ) return boolean is
    variable Message : line;
  begin
    if (ENABLE_ECC) then
      if (d_width > 64) then
        write(Message, string'("ECC constraints the data width to 64 bits. DATA_WIDTH : "));
        write(Message, DATA_WIDTH);
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      elsif (FIFO_SIZE = "18Kb") then
        write(Message, string'("ECC is supported only with FIFO_SIZE = 18Kb. FIFO_SIZE : "));
        write(Message, FIFO_SIZE);
        assert false report Message.all severity failure;
        DEALLOCATE(Message);
        return false;
      else
        return true;
      end if;
    else
      return true;
    end if;
  end;

  ------------------------------------------------------------------------------
  constant FIFO_SIZE_val        : boolean := GetFIFOSize;
  constant data_p               : boolean := GetD_P(DATA_WIDTH);
  constant count_width          : integer := GetCOUNTWidth(DATA_WIDTH);
  constant d_width              : integer := GetDWidth(DATA_WIDTH);
  constant d_size               : integer := GetD_Size(DATA_WIDTH);
  constant dip_width            : integer := GetDIPWidth(DATA_WIDTH);
  constant dop_width            : integer := GetDOPWidth(DATA_WIDTH);
  constant fin_width            : integer := GetFinalWidth(DATA_WIDTH);
  constant sim_device_dp        : string  := GetSIMDev;
  constant rdctleng             : integer := rdcount'length;
  constant wrctleng             : integer := wrcount'length;
  constant checkrdct            : boolean := CheckRDCount(DATA_WIDTH, rdctleng);
  constant checkwrct            : boolean := CheckWRCount(DATA_WIDTH, wrctleng);
  constant check_data_width_ecc : boolean := CheckDataWidthECC(DATA_WIDTH);

  constant max_data_width  : integer := GetMaxDWidth(DATA_WIDTH);
  constant max_datap_width : integer := GetMaxDPWidth(DATA_WIDTH);
  constant max_count_width : integer := GetMaxCOUNTWidth(DATA_WIDTH);

  signal di_pattern      : std_logic_vector(max_data_width - 1 downto 0)  := (others => '0');
  signal do_pattern      : std_logic_vector(max_data_width - 1 downto 0)  := (others => '0');
  signal dip_pattern     : std_logic_vector(max_datap_width - 1 downto 0) := (others => '0');
  signal dop_pattern     : std_logic_vector(max_datap_width - 1 downto 0) := (others => '0');
  signal rdcount_pattern : std_logic_vector(max_count_width - 1 downto 0) := (others => '0');
  signal wrcount_pattern : std_logic_vector(max_count_width - 1 downto 0) := (others => '0');

-- *****************************************************************************
begin


  di1v5 : if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") generate
    digen1 : if (data_p = true and ((FIFO_SIZE = "18Kb" and DATA_WIDTH <= 36) or (FIFO_SIZE = "36Kb" and DATA_WIDTH <= 72))) generate
    begin
      dip_pattern(dip_width - 1 downto 0) <= di(fin_width - 1 downto d_width);
      di_pattern(d_width - 1 downto 0)    <= di(d_width - 1 downto 0);
    end generate digen1;
  end generate di1v5;

  di2v5 : if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") generate
    digen2 : if (data_p = false and ((FIFO_SIZE = "18Kb" and DATA_WIDTH <= 36) or (FIFO_SIZE = "36Kb" and DATA_WIDTH <= 72))) generate
    begin
      di_pattern(fin_width - 1 downto 0) <= di(fin_width - 1 downto 0);
    end generate digen2;
  end generate di2v5;

  do1v5 : if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") generate
    dogen1 : if (data_p = true and ((FIFO_SIZE = "18Kb" and DATA_WIDTH <= 36) or (FIFO_SIZE = "36Kb" and DATA_WIDTH <= 72))) generate
    begin
      do <= (dop_pattern(dop_width - 1 downto 0) & do_pattern(d_width - 1 downto 0));
    end generate dogen1;
  end generate do1v5;

  do2v5 : if (DEVICE = "VIRTEX5" or DEVICE = "VIRTEX6" or DEVICE = "7SERIES") generate
    dogen2 : if (data_p = false and ((FIFO_SIZE = "18Kb" and DATA_WIDTH <= 36) or (FIFO_SIZE = "36Kb" and DATA_WIDTH <= 72))) generate
    begin
      do <= do_pattern(fin_width - 1 downto 0);
    end generate dogen2;
  end generate do2v5;

  rdcount <= rdcount_pattern(count_width - 1 downto 0);
  wrcount <= wrcount_pattern(count_width - 1 downto 0);

  -- ==========================================================================
  -- begin generate virtex5
  v5 : if (DEVICE = "VIRTEX5") generate
    ------------------------------------------------------------------------------
    component FIFO18 is
      generic (
        ALMOST_FULL_OFFSET      : bit_vector(11 downto 0);
        ALMOST_EMPTY_OFFSET     : bit_vector(11 downto 0);
        DATA_WIDTH              : natural;
        DO_REG                  : natural;
        EN_SYN                  : boolean;
        FIRST_WORD_FALL_THROUGH : boolean;
        SIM_MODE                : string
      );
      port (
        ALMOSTEMPTY : out std_logic;
        ALMOSTFULL  : out std_logic;
        DO          : out std_logic_vector(15 downto 0);
        DOP         : out std_logic_vector(1 downto 0);
        EMPTY       : out std_logic;
        FULL        : out std_logic;
        RDCOUNT     : out std_logic_vector(11 downto 0);
        RDERR       : out std_logic;
        WRCOUNT     : out std_logic_vector(11 downto 0);
        WRERR       : out std_logic;
        DI          : in  std_logic_vector(15 downto 0);
        DIP         : in  std_logic_vector(1 downto 0);
        RDCLK       : in  std_logic;
        RDEN        : in  std_logic;
        RST         : in  std_logic;
        WRCLK       : in  std_logic;
        WREN        : in  std_logic
      );
    end component;

    component FIFO18_36 is
      generic (
        ALMOST_FULL_OFFSET      : bit_vector := X"080";
        ALMOST_EMPTY_OFFSET     : bit_vector := X"080";
        DO_REG                  : integer    := 1;
        EN_SYN                  : boolean    := false;
        FIRST_WORD_FALL_THROUGH : boolean    := false;
        SIM_MODE                : string     := "SAFE"
      );
      port (
        ALMOSTEMPTY : out std_ulogic;
        ALMOSTFULL  : out std_ulogic;
        DO          : out std_logic_vector (31 downto 0);
        DOP         : out std_logic_vector (3 downto 0);
        EMPTY       : out std_ulogic;
        FULL        : out std_ulogic;
        RDCOUNT     : out std_logic_vector (8 downto 0);
        RDERR       : out std_ulogic;
        WRCOUNT     : out std_logic_vector (8 downto 0);
        WRERR       : out std_ulogic;
        DI          : in  std_logic_vector (31 downto 0);
        DIP         : in  std_logic_vector (3 downto 0);
        RDCLK       : in  std_ulogic;
        RDEN        : in  std_ulogic;
        RST         : in  std_ulogic;
        WRCLK       : in  std_ulogic;
        WREN        : in  std_ulogic
      );
    end component FIFO18_36;

    component FIFO36 is
      generic (
        ALMOST_FULL_OFFSET      : bit_vector(15 downto 0);
        ALMOST_EMPTY_OFFSET     : bit_vector(15 downto 0);
        DATA_WIDTH              : natural;
        DO_REG                  : natural;
        EN_SYN                  : boolean;
        FIRST_WORD_FALL_THROUGH : boolean;
        SIM_MODE                : string
      );
      port (
        ALMOSTEMPTY : out std_logic;
        ALMOSTFULL  : out std_logic;
        DO          : out std_logic_vector(31 downto 0);
        DOP         : out std_logic_vector(3 downto 0);
        EMPTY       : out std_logic;
        FULL        : out std_logic;
        RDCOUNT     : out std_logic_vector(12 downto 0);
        RDERR       : out std_logic;
        WRCOUNT     : out std_logic_vector(12 downto 0);
        WRERR       : out std_logic;
        DI          : in  std_logic_vector(31 downto 0);
        DIP         : in  std_logic_vector(3 downto 0);
        RDCLK       : in  std_logic;
        RDEN        : in  std_logic;
        RST         : in  std_logic;
        WRCLK       : in  std_logic;
        WREN        : in  std_logic
      );
    end component;

    component FIFO36_72 is
      generic (
        ALMOST_FULL_OFFSET      : bit_vector := X"080";
        ALMOST_EMPTY_OFFSET     : bit_vector := X"080";
        DO_REG                  : integer    := 1;
        EN_ECC_READ             : boolean    := false;
        EN_ECC_WRITE            : boolean    := false;
        EN_SYN                  : boolean    := false;
        FIRST_WORD_FALL_THROUGH : boolean    := false;
        SIM_MODE                : string     := "SAFE"
      );
      port (
        ALMOSTEMPTY : out std_ulogic;
        ALMOSTFULL  : out std_ulogic;
        DBITERR     : out std_ulogic;
        DO          : out std_logic_vector (63 downto 0);
        DOP         : out std_logic_vector (7 downto 0);
        ECCPARITY   : out std_logic_vector (7 downto 0);
        EMPTY       : out std_ulogic;
        FULL        : out std_ulogic;
        RDCOUNT     : out std_logic_vector (8 downto 0);
        RDERR       : out std_ulogic;
        SBITERR     : out std_ulogic;
        WRCOUNT     : out std_logic_vector (8 downto 0);
        WRERR       : out std_ulogic;
        DI          : in  std_logic_vector (63 downto 0);
        DIP         : in  std_logic_vector (7 downto 0);
        RDCLK       : in  std_ulogic;
        RDEN        : in  std_ulogic;
        RST         : in  std_ulogic;
        WRCLK       : in  std_ulogic;
        WREN        : in  std_ulogic
      );
    end component FIFO36_72;

  begin
    noecc : if (ENABLE_ECC = false) generate
      fifo_18_inst : if (FIFO_SIZE = "18Kb" and DATA_WIDTH <= 18) generate
      begin
        fifo_18_inst : FIFO18
        generic map(
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          DATA_WIDTH              => d_size,
          DO_REG                  => 1,
          EN_SYN                  => false,
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          SIM_MODE                => SIM_MODE
        )
        port map(
          almostempty => almostempty,
          almostfull  => almostfull,
          do          => do_pattern,
          dop         => dop_pattern,
          empty       => empty,
          full        => full,
          rdcount     => rdcount_pattern,
          rderr       => rderr,
          wrcount     => wrcount_pattern,
          wrerr       => wrerr,
          di          => di_pattern,
          dip         => dip_pattern,
          rdclk       => rdclk,
          rden        => rden,
          rst         => rst,
          wrclk       => wrclk,
          wren        => wren
        );
      end generate fifo_18_inst;

      fifo_18_36_inst : if (FIFO_SIZE = "18Kb" and DATA_WIDTH > 18 and DATA_WIDTH <= 36) generate
      begin
        fifo_18_36_inst : FIFO18_36
        generic map(
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          DO_REG                  => 1,
          EN_SYN                  => false,
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          SIM_MODE                => SIM_MODE
        )
        port map(
          almostempty => almostempty,
          almostfull  => almostfull,
          do          => do_pattern,
          dop         => dop_pattern,
          empty       => empty,
          full        => full,
          rdcount     => rdcount_pattern,
          rderr       => rderr,
          wrcount     => wrcount_pattern,
          wrerr       => wrerr,
          di          => di_pattern,
          dip         => dip_pattern,
          rdclk       => rdclk,
          rden        => rden,
          rst         => rst,
          wrclk       => wrclk,
          wren        => wren
        );
      end generate fifo_18_36_inst;

      fifo_36_inst : if (FIFO_SIZE = "36Kb" and DATA_WIDTH <= 36) generate
      begin
        fifo_36_inst : FIFO36
        generic map(
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          DATA_WIDTH              => d_size,
          DO_REG                  => 1,
          EN_SYN                  => false,
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          SIM_MODE                => SIM_MODE
        )
        port map(
          almostempty => almostempty,
          almostfull  => almostfull,
          do          => do_pattern,
          DOP         => dop_pattern,
          empty       => empty,
          full        => full,
          rdcount     => rdcount_pattern,
          rderr       => rderr,
          wrcount     => wrcount_pattern,
          wrerr       => wrerr,
          di          => di_pattern,
          DIP         => dip_pattern,
          rdclk       => rdclk,
          rden        => rden,
          rst         => rst,
          wrclk       => wrclk,
          wren        => wren
        );
      end generate fifo_36_inst;

      fifo_36_72_inst : if (FIFO_SIZE = "36Kb" and DATA_WIDTH > 36 and DATA_WIDTH <= 72) generate
      begin
        fifo_36_72_inst : fifo36_72
        generic map(
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          DO_REG                  => 1,
          EN_SYN                  => false,
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          SIM_MODE                => SIM_MODE
        )
        port map(
          almostempty => almostempty,
          almostfull  => almostfull,
          dbiterr     => open,
          do          => do_pattern,
          dop         => dop_pattern,
          eccparity   => open,
          empty       => empty,
          full        => full,
          rdcount     => rdcount_pattern,
          rderr       => rderr,
          sbiterr     => open,
          wrcount     => wrcount_pattern,
          wrerr       => wrerr,
          di          => di_pattern,
          dip         => dip_pattern,
          rdclk       => rdclk,
          rden        => rden,
          rst         => rst,
          wrclk       => wrclk,
          wren        => wren
        );
      end generate fifo_36_72_inst;
    end generate noecc;

    ecc : if (ENABLE_ECC) generate
      fifo_36_72_inst : if ((FIFO_SIZE = "36Kb" or FIFO_SIZE = "18Kb") and DATA_WIDTH <= 64) generate
      begin
        fifo_36_72_inst : fifo36_72
        generic map(
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          DO_REG                  => 1,
          EN_ECC_READ             => true,
          EN_ECC_WRITE            => true,
          EN_SYN                  => false,
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          SIM_MODE                => SIM_MODE
        )
        port map(
          almostempty => almostempty,
          almostfull  => almostfull,
          dbiterr     => dbiterr,
          do          => do_pattern,
          dop         => dop_pattern,
          eccparity   => open,
          empty       => empty,
          full        => full,
          rdcount     => rdcount_pattern,
          rderr       => rderr,
          sbiterr     => sbiterr,
          wrcount     => wrcount_pattern,
          wrerr       => wrerr,
          di          => di_pattern,
          dip         => dip_pattern,
          rdclk       => rdclk,
          rden        => rden,
          rst         => rst,
          wrclk       => wrclk,
          wren        => wren
        );
      end generate fifo_36_72_inst;
    end generate ecc;
  end generate v5;

  -- end generate virtex5

  -- ==========================================================================
  -- begin generate virtex6
  bl : if (DEVICE = "VIRTEX6" or DEVICE = "7SERIES") generate
    noecc : if (ENABLE_ECC = false) generate
      fifo_18_inst_bl : if (FIFO_SIZE = "18Kb" and DATA_WIDTH <= 18) generate
      begin
        fifo_18_bl : FIFO18E1
        generic map(
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          DATA_WIDTH              => d_size,
          DO_REG                  => 1,
          EN_SYN                  => false,
          FIFO_MODE               => "FIFO18",
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          INIT                    => INIT(0 to 35),
          SIM_DEVICE              => sim_device_dp,
          SRVAL                   => SRVAL(0 to 35)
        )
        port map(
          almostempty => almostempty,
          almostfull  => almostfull,
          do          => do_pattern,
          dop         => dop_pattern,
          empty       => empty,
          full        => full,
          rdcount     => rdcount_pattern,
          rderr       => rderr,
          wrcount     => wrcount_pattern,
          wrerr       => wrerr,
          di          => di_pattern,
          dip         => dip_pattern,
          rdclk       => rdclk,
          rden        => rden,
          regce       => '1',
          rst         => rst,
          rstreg      => '1',
          wrclk       => wrclk,
          wren        => wren
        );
      end generate fifo_18_inst_bl;
      fifo_18_inst_bl_1 : if (FIFO_SIZE = "18Kb" and DATA_WIDTH > 18 and DATA_WIDTH <= 36) generate
      begin
        fifo_18_bl_1 : FIFO18E1
        generic map(
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          DATA_WIDTH              => d_size,
          DO_REG                  => 1,
          EN_SYN                  => false,
          FIFO_MODE               => "FIFO18_36",
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          INIT                    => INIT(0 to 35),
          SIM_DEVICE              => sim_device_dp,
          SRVAL                   => SRVAL(0 to 35)
        )
        port map(
          almostempty => almostempty,
          almostfull  => almostfull,
          do          => do_pattern,
          dop         => dop_pattern,
          empty       => empty,
          full        => full,
          rdcount     => rdcount_pattern,
          rderr       => rderr,
          wrcount     => wrcount_pattern,
          wrerr       => wrerr,
          di          => di_pattern,
          dip         => dip_pattern,
          rdclk       => rdclk,
          rden        => rden,
          regce       => '1',
          rst         => rst,
          rstreg      => '1',
          wrclk       => wrclk,
          wren        => wren
        );
      end generate fifo_18_inst_bl_1;
      fifo_36_inst_bl : if (FIFO_SIZE = "36Kb" and DATA_WIDTH <= 36) generate
      begin
        fifo_36_bl : FIFO36E1
        generic map(
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          DATA_WIDTH              => d_size,
          DO_REG                  => 1,
          EN_SYN                  => false,
          FIFO_MODE               => "FIFO36",
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          INIT                    => INIT,
          SIM_DEVICE              => sim_device_dp,
          SRVAL                   => SRVAL
        )
        port map(
          almostempty   => almostempty,
          almostfull    => almostfull,
          dbiterr       => open,
          do            => do_pattern,
          dop           => dop_pattern,
          eccparity     => open,
          empty         => empty,
          full          => full,
          rdcount       => rdcount_pattern,
          rderr         => rderr,
          sbiterr       => open,
          wrcount       => wrcount_pattern,
          wrerr         => wrerr,
          di            => di_pattern,
          dip           => dip_pattern,
          injectdbiterr => '0',
          injectsbiterr => '0',
          rdclk         => rdclk,
          rden          => rden,
          regce         => '1',
          rst           => rst,
          rstreg        => '1',
          wrclk         => wrclk,
          wren          => wren
        );
      end generate fifo_36_inst_bl;
      fifo_36_inst_bl_1 : if (FIFO_SIZE = "36Kb" and DATA_WIDTH > 36 and DATA_WIDTH <= 72) generate
      begin
        fifo_36_bl_1 : FIFO36E1
        generic map(
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          DATA_WIDTH              => d_size,
          DO_REG                  => 1,
          EN_SYN                  => false,
          FIFO_MODE               => "FIFO36_72",
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          INIT                    => INIT,
          SIM_DEVICE              => sim_device_dp,
          SRVAL                   => SRVAL
        )
        port map(
          almostempty   => almostempty,
          almostfull    => almostfull,
          dbiterr       => open,
          do            => do_pattern,
          dop           => dop_pattern,
          eccparity     => open,
          empty         => empty,
          full          => full,
          rdcount       => rdcount_pattern,
          rderr         => rderr,
          sbiterr       => open,
          wrcount       => wrcount_pattern,
          wrerr         => wrerr,
          di            => di_pattern,
          dip           => dip_pattern,
          injectdbiterr => '0',
          injectsbiterr => '0',
          rdclk         => rdclk,
          rden          => rden,
          regce         => '1',
          rst           => rst,
          rstreg        => '1',
          wrclk         => wrclk,
          wren          => wren
        );
      end generate fifo_36_inst_bl_1;
    end generate noecc;
    ecc : if (ENABLE_ECC) generate
      fifo_36_inst_bl : if ((FIFO_SIZE = "36Kb" or FIFO_SIZE = "18Kb") and DATA_WIDTH <= 32) generate
      begin
        fifo_36_bl : FIFO36E1
        generic map(
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          DATA_WIDTH              => d_size,
          DO_REG                  => 1,
          EN_ECC_READ             => true,
          EN_ECC_WRITE            => true,
          EN_SYN                  => false,
          FIFO_MODE               => "FIFO36",
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          INIT                    => INIT,
          SIM_DEVICE              => sim_device_dp,
          SRVAL                   => SRVAL
        )
        port map(
          almostempty   => almostempty,
          almostfull    => almostfull,
          dbiterr       => dbiterr,
          do            => do_pattern,
          dop           => dop_pattern,
          eccparity     => open,
          empty         => empty,
          full          => full,
          rdcount       => rdcount_pattern,
          rderr         => rderr,
          sbiterr       => sbiterr,
          wrcount       => wrcount_pattern,
          wrerr         => wrerr,
          di            => di_pattern,
          dip           => dip_pattern,
          injectdbiterr => '0',
          injectsbiterr => '0',
          rdclk         => rdclk,
          rden          => rden,
          regce         => '1',
          rst           => rst,
          rstreg        => '1',
          wrclk         => wrclk,
          wren          => wren
        );
      end generate fifo_36_inst_bl;
      fifo_36_inst_bl_1 : if (FIFO_SIZE = "36Kb" and DATA_WIDTH > 32 and DATA_WIDTH <= 64) generate
      begin
        fifo_36_bl_1 : FIFO36E1
        generic map(
          ALMOST_EMPTY_OFFSET     => ALMOST_EMPTY_OFFSET,
          ALMOST_FULL_OFFSET      => ALMOST_FULL_OFFSET,
          DATA_WIDTH              => d_size,
          DO_REG                  => 1,
          EN_ECC_READ             => true,
          EN_ECC_WRITE            => true,
          EN_SYN                  => false,
          FIFO_MODE               => "FIFO36_72",
          FIRST_WORD_FALL_THROUGH => FIRST_WORD_FALL_THROUGH,
          INIT                    => INIT,
          SIM_DEVICE              => sim_device_dp,
          SRVAL                   => SRVAL
        )
        port map(
          almostempty   => almostempty,
          almostfull    => almostfull,
          dbiterr       => dbiterr,
          do            => do_pattern,
          dop           => dop_pattern,
          eccparity     => open,
          empty         => empty,
          full          => full,
          rdcount       => rdcount_pattern,
          rderr         => rderr,
          sbiterr       => sbiterr,
          wrcount       => wrcount_pattern,
          wrerr         => wrerr,
          di            => di_pattern,
          dip           => dip_pattern,
          injectdbiterr => '0',
          injectsbiterr => '0',
          rdclk         => rdclk,
          rden          => rden,
          regce         => '1',
          rst           => rst,
          rstreg        => '1',
          wrclk         => wrclk,
          wren          => wren
        );
      end generate fifo_36_inst_bl_1;
    end generate ecc;
  end generate bl;
  -- end generate virtex6

end fifo_V;
