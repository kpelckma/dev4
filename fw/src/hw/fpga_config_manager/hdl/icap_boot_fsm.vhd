------------------------------------------------------------------------------
--          ____  _____________  __                                         --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
--        / / / / __/  \__ \  \  /                 / \ / \ / \              --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
--                                                                          --
------------------------------------------------------------------------------
--! @copyright Copyright 2018-2022 DESY
--! SPDX-License-Identifier: CERN-OHL-W-2.0
------------------------------------------------------------------------------
--! @date 2018-10-25/2022-08-10
--! @author Dariusz Makowski
--! @author Grzegorz Jablonski
--! @author Konrad Przygoda
--! @author Lukasz Butkowski <lukasz.butkowski@desy.de>
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! FSM to send packets to ICAP for multiboot operation
------------------------------------------------------------------------------


library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity icap_boot_fsm is
  generic (
    g_arch           : string := ""; --! Allowed values: VIRTEX5,VIRTEX6,SPARTAN6,7SERIES,ULTRASCALE
    g_icap_clk_div   : natural := 0;
    g_mem_addr_width : natural := 23
  );
  port(
    pi_clock        : in  std_logic;                      --! Clock input
    pi_switch       : in  std_logic_vector(31 downto 0);  --! Switch key
    pi_prog_sel     : in  std_logic_vector(g_mem_addr_width-22 downto 0);
    po_icap_clock   : out std_logic;                      --! Clock to ICAP primitive
    po_din          : out std_logic_vector(31 downto 0);  --! Input data to ICAP
    pi_dout         : in  std_logic_vector(31 downto 0);  --! Output data from ICAP
    pi_busy         : in  std_logic;                      --! ICAP Busy Flag
    po_enable_n     : out std_logic;                      --! Enable ICAP output
    po_wr_n         : out std_logic                       --! Read/Write Sel
  );
end icap_boot_fsm;

architecture arch of icap_boot_fsm is

  constant MAGIC_WORD : std_logic_vector(27 downto 0) := x"2eb0070";

  type t_state_type  is (IDLE, SYNC_H, SYNC_L, NUL_H,SYNC_LM, NUL_HM, SYNC_LM2, NUL_HM2, NUL_L, RBT_H, RBT_L, NOOP_0, NOOP_1, NOOP_2, NOOP_3 );

  signal icap_clk                  : std_logic;
  signal icap_clk_prev             : std_logic;
  signal icap_busy                 : std_logic;
  signal icap_dout                 : std_logic_vector(31 downto 0);
  signal icap_ce_n                 : std_logic;
  signal icap_din_reversed         : std_logic_vector(31 downto 0);
  signal icap_din16                : std_logic_vector(15 downto 0);
  signal icap_din                  : std_logic_vector(31 downto 0);
  signal multiboot_image_address   : std_logic_vector(31 downto 0) := (others => '0');
  signal icap_wr_n                 : std_logic;
  signal icap_ok                   : std_logic;
  signal sync_in                   : std_logic_vector(7 downto 0);
  signal sync_out                  : std_logic_vector(23 downto 0);
  signal clk_en                    : std_logic;
  signal prog1                     : std_logic;
  signal prog2                     : std_logic;

  attribute KEEP                     : string;
  attribute KEEP of icap_clk         : signal is "true";

begin

  po_icap_clock <= icap_clk; --! sending clock to ICAP
  po_din        <= icap_din;
  icap_dout     <= pi_dout;
  icap_busy     <= pi_busy;
  po_enable_n   <= icap_ce_n;
  po_wr_n       <= icap_wr_n;

  process(pi_clock)
  begin
    if rising_edge(pi_clock) then
      if pi_switch(31 downto 4) = MAGIC_WORD then  --! Magic keyword to do the switching
        prog1 <= pi_switch(0);
        prog2 <= pi_switch(1);
      else
        prog1 <= '0';
        prog2 <= '0';
      end if;
    end if;
  end process;

  -------------------------------------------------------------------
  --! Clock divider, needed for spartan6 if clock faster than 20Mhz
  -------------------------------------------------------------------
  gen_div_clk: if g_icap_clk_div > 1 generate
  begin
    process(pi_clock)
      variable v_cnt  : natural;
    begin
      if rising_edge(pi_clock) then
        if v_cnt < (g_icap_clk_div / 2 ) -1 then
          v_cnt := v_cnt + 1;
        else
          v_cnt        := 0;
          icap_clk <= not icap_clk;
        end if;
        icap_clk_prev <= icap_clk ;
      end if;
    end process;
    clk_en <= '1' when icap_clk_prev = '0' and  icap_clk = '1' else '0';
  end generate;

  gen_no_div_clk: if g_icap_clk_div <= 1 generate
    icap_clk <= pi_clock;
    clk_en  <= '1';
  end generate;

  gen_fsm_s6: if g_arch = "SPARTAN6" generate
    process(pi_clock)
      variable v_bit_cnt : natural;
      variable v_state   : t_state_type;
    begin
      if rising_edge(pi_clock) then
        if clk_en  = '1'  then  -- clock enable
          case(v_state) is
            when IDLE =>
              if prog1 = '1' then
                v_state        := SYNC_H;
                icap_ok    <= '1';
                sync_in    <= "00000001";
                icap_ce_n  <= '0';
                icap_wr_n  <= '0';
                icap_din16 <= x"AA99";  -- Sync word part 1
                multiboot_image_address <= (others => '0');--x"000000";   -- multiboot image 1 address

              elsif prog2 = '1' then
                v_state        := SYNC_H;
                icap_ok    <= '1';
                sync_in    <= "00000001";
                icap_ce_n  <= '0';
                icap_wr_n  <= '0';
                icap_din16 <= x"AA99";  -- Sync word part 1
                --multiboot_image_address<=x"400000"; -- multiboot image 2 address
                multiboot_image_address(g_mem_addr_width-1 downto 21) <= pi_prog_sel;
              else
                v_state        := IDLE;
                icap_ok    <= '0';
                sync_in    <= "00000010";
                icap_ce_n  <= '1';
                icap_wr_n  <= '1';
                icap_din16 <= x"FFFF";  -- NULL Data
              end if;

            when SYNC_H =>
              v_state           := SYNC_LM2;
              icap_ok        <= '1';
              sync_in        <= "00000011";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"5566";  -- Sync word part 2

            when SYNC_LM2 =>
              v_state           := NUL_HM2;
              icap_ok        <= '1';
              sync_in        <= "00000100";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"3261";  -- Write Multiboot image location....

            when NUL_HM2 =>
              v_state           := SYNC_LM;
              icap_ok        <= '1';
              sync_in        <= "00000101";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
                  --icap_din16     <= x"A79D";  -- address[15:0]
              icap_din16     <= multiboot_image_address (15 downto 0);
            when SYNC_LM =>
              v_state           := NUL_HM;
              icap_ok        <= '1';
              sync_in        <= "00000100";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"3281";  -- Write Multiboot image location ... ....
            when NUL_HM =>
              v_state           := SYNC_L;
              icap_ok        <= '1';
              sync_in        <= "00000101";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              --icap_din16     <= x"0330";  -- 0x03 command ... address[23:16]
              icap_din16     <= multiboot_image_address (31 downto 16);
         --------------------------------------------------------------------
         --------------------------------------------------------------------
            when SYNC_L =>
              v_state           := NUL_H;
              icap_ok        <= '1';
              sync_in        <= "00000100";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"30A1";  -- Write to Command Register....

            when NUL_H =>
              v_state           := NUL_L;
              icap_ok        <= '1';
              sync_in        <= "00000101";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"0000";  -- Null Command issued....  value = 0x0000
         --------------------------------------------------------------------
            when NUL_L =>
              v_state           := RBT_H;
              icap_ok        <= '1';
              sync_in        <= "00000110";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"30A1";  --  Write to Command Register....

            when RBT_H =>
              v_state           := RBT_L;
              icap_ok        <= '1';
              sync_in        <= "00000111";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"000E";  --  REBOOT Command issued....  value = 0x000E
         --------------------------------------------------------------------
            when RBT_L =>
              v_state           := NOOP_0;
              icap_ok        <= '1';
              sync_in        <= "00001000";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"2000";  --  NOOP

            when NOOP_0 =>
              v_state           := NOOP_1;
              icap_ok        <= '1';
              sync_in        <= "00001001";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"2000";  --  NOOP

            when NOOP_1 =>
              v_state           := NOOP_2;
              icap_ok        <= '1';
              sync_in        <= "00001010";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"2000";  --  NOOP

            when NOOP_2 =>
              v_state           := NOOP_3;
              icap_ok        <= '1';
              sync_in        <= "00001011";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"2000";  --  NOOP

            when NOOP_3 =>
              v_state           := IDLE;
              icap_ok        <= '1';

              sync_in        <= "00001100";
              icap_ce_n      <= '0';
              icap_wr_n      <= '0';
              icap_din16     <= x"1111";  --  NULL value

            when others =>
              v_state           := IDLE;
              icap_ok        <= '1';
              icap_ce_n      <= '1';
              icap_wr_n      <= '1';
              icap_din16     <= x"1111";  --  NULL value

          end case;
        end if;
      end if;
    end process;

    icap_din(15 downto 0) <= icap_din16;

  end generate;

  gen_fsm: if g_arch = "VIRTEX5" generate
    process(pi_clock)
      variable v_bit_cnt : natural;
      variable v_state   : t_state_type;
    begin
      if rising_edge(pi_clock) then
        if clk_en  = '1'  then  -- clock enable
          case(v_state) is
            when IDLE =>
              icap_ce_n  <= '1';
              icap_wr_n  <= '1';
              icap_din   <= x"FFFFFFFF";  -- NULL Data

              if prog1 = '1' then
                v_state        := SYNC_H;
                icap_ce_n  <= '0';
                icap_wr_n  <= '0';
                multiboot_image_address <= (others => '0');--x"000000";   -- multiboot image 1 address
              elsif prog2 = '1' then
                v_state        := SYNC_H;
                icap_ce_n  <= '0';
                icap_wr_n  <= '0';
                multiboot_image_address(g_mem_addr_width-1 downto 21) <= pi_prog_sel;
              end if;

            when SYNC_H =>
              v_state        := NOOP_0;
              icap_ce_n  <= '0';
              icap_wr_n  <= '0';
              icap_din   <= x"AA995566";  -- Sync word

            when NOOP_0 =>
              v_state        := SYNC_LM;
              icap_ce_n  <= '0';
              icap_wr_n  <= '0';
              icap_din   <= x"20000000";  -- Type 1 NO OP

            when SYNC_LM =>
              v_state        := NUL_HM;
              icap_ce_n  <= '0';
              icap_wr_n  <= '0';
              icap_din   <= x"30020001";  -- Type 1 Write 1 Words to WBSTAR

            when NUL_HM =>
              v_state        := SYNC_LM2;
              icap_ce_n  <= '0';
              icap_wr_n  <= '0';
              icap_din   <= multiboot_image_address;  -- Warm Boot Start Address

            when SYNC_LM2 =>
              v_state        := RBT_H;
              icap_ce_n  <= '0';
              icap_wr_n  <= '0';
              icap_din   <= x"30008001";  -- Type 1 Write 1 Words to CMD

            when RBT_H =>
              v_state        := NOOP_1;
              icap_ce_n  <= '0';
              icap_wr_n  <= '0';
              icap_din   <= x"0000000F";  -- IPROG Command

            when NOOP_1 =>
              v_state        := IDLE;
              icap_ce_n  <= '0';
              icap_wr_n  <= '0';
              icap_din   <= x"20000000";  -- Type 1 NO OP
            when others =>
              v_state := IDLE ;
              icap_ce_n  <= '1';
              icap_wr_n  <= '1';
          end case ;
        end if ;
      end if;
    end process;
  end generate;

  gen_fsm_7: if g_arch = "7SERIES" or g_arch = "VIRTEX6" or g_arch = "ULTRASCALE"  generate
    type t_table is array (natural range<>) of std_logic_vector(31 downto 0);
    constant C_ICAP_SEQUENCE : t_table(0 to 10) := (
    x"FFFFFFFF", -- Dummy Word
    x"000000bb", -- Bus Width Sync Word
    x"11220044", -- Bus Width Detect
    x"FFFFFFFF", -- Dummy Word
    x"AA995566",  -- Sync word
    x"20000000",  -- Type 1 NO OP
    x"30020001",  -- Type 1 Write 1 Words to WBSTAR
    x"00000000",  -- Warm Boot Start Address
    x"30008001",  -- Type 1 Write 1 Words to CMD
    x"0000000F",  -- IPROG Command
    x"20000000"   -- Type 1 NO OP
    );
    signal l_seq_cnt : natural := 0;
    signal l_state   : natural := 0;
  begin
    process(pi_clock)
    begin
      if rising_edge(pi_clock) then
        if clk_en  = '1'  then  -- clock enable
          case(l_state) is
            when 0 =>
              icap_ce_n  <= '1';
              icap_wr_n  <= '1';
              icap_din   <= x"FFFFFFFF";  -- NULL Data
              l_seq_cnt    <= 0;
              if prog1 = '1' then
                l_state <= 1;
                multiboot_image_address <= (others => '0');--x"000000";   -- multiboot image 1 address
              elsif prog2 = '1' then
                l_state <= 1;
                multiboot_image_address(g_mem_addr_width-1 downto 21) <= pi_prog_sel;
              end if;
            when 1 =>
              icap_din  <= C_ICAP_SEQUENCE(l_seq_cnt);
              icap_ce_n <= '0';
              icap_wr_n <= '0';
              if l_seq_cnt = 6 then
                l_state <= 2; -- set boot address from signal
              elsif l_seq_cnt >= 10 then
                l_state <= 0;
              end if;
              l_seq_cnt <= l_seq_cnt + 1;
            when 2 => -- boot address
              icap_din  <= multiboot_image_address;
              icap_ce_n <= '0';
              icap_wr_n <= '0';
              l_state   <= 1;
              l_seq_cnt <= l_seq_cnt + 1;
            when others =>
              l_state <= 0 ;
              icap_ce_n  <= '1';
              icap_wr_n  <= '1';
          end case ;
        end if ;
      end if;
    end process;
  end generate;

end arch;
