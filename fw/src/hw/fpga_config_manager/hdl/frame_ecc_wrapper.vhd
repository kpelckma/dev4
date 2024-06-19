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
--! @date 2018-10-25
--! @author Rahat Ibna Kamal
--! @author Cagil Gumus <cagil.guemues@desy.de>
------------------------------------------------------------------------------
--! @brief
--! FRAME ECC primitive wrapper
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity frame_ecc_wrapper is
  generic (
    g_arch              : string := "VIRTEX6" --! Allowed "7SERIES","VIRTEX6","SPARTAN6"
  );
  port (
    pi_clock            : in  std_logic;
    pi_reset            : in  std_logic;
    po_crc_error        : out std_logic;
    po_ecc_error        : out std_logic;
    po_ecc_error_single : out std_logic;
    po_far_register     : out std_logic_vector(25 downto 0);
    po_syn_bit          : out std_logic_vector (4 downto 0);
    po_syndrome_value   : out std_logic_vector (12 downto 0);
    po_syndrome_vld     : out std_logic;
    po_syn_word         : out std_logic_vector (6 downto 0);
    po_crc_error_cnt    : out std_logic_vector (31 downto 0);
    po_ecc_error_cnt    : out std_logic_vector (31 downto 0)
  );
end frame_ecc_wrapper;

architecture Behavioral of frame_ecc_wrapper is

  signal crc_error        : std_logic;
  signal ecc_error        : std_logic;
  signal ecc_error_single : std_logic;
  signal far_register     : std_logic_vector(25 downto 0);
  signal syn_bit          : std_logic_vector(4 downto 0);
  signal syndrome_value   : std_logic_vector(12 downto 0);
  signal syndrome_vld     : std_logic;
  signal syn_word         : std_logic_vector(6 downto 0);

  signal ecc_error_q      : std_logic ;
  signal crc_error_q      : std_logic ;
  signal ecc_error_qq     : std_logic ;
  signal crc_error_qq     : std_logic ;

  signal crc_error_cnt    : std_logic_vector(31 downto 0) := x"00000000";
  signal ecc_error_cnt    : std_logic_vector(31 downto 0) := x"00000000";

begin

  gen_arch_check: if not (g_arch = "VIRTEX6" or g_arch = "7SERIES" or g_arch = "SPARTAN6") generate
    assert 0=1 report "ECC Feature (currently) only available on Virtex6, 7Series and Spartan6 FPGAs" severity failure;
  end generate gen_arch_check;

  po_crc_error        <= crc_error;
  po_ecc_error        <= ecc_error;
  po_ecc_error_single <= ecc_error_single;
  po_far_register     <= far_register;
  po_syn_bit          <= syn_bit;
  po_syndrome_value   <= syndrome_value;
  po_syndrome_vld     <= syndrome_vld;
  po_syn_word         <= syn_word;
  po_crc_error_cnt    <= crc_error_cnt;
  po_ecc_error_cnt    <= ecc_error_cnt;

  ---------------------------------------------------------------
  --! Frame ecc  primitive instantiate for virtex 7,6
  --!                  and sparten 6
  ---------------------------------------------------------------
  gen_v6 : if g_arch = "VIRTEX6" generate
   component FRAME_ECC_VIRTEX6 is
   generic (
     FARSRC : string := "EFAR";                -- Determines if the output of FAR[23:0] configuration register points
     FRAME_RBT_IN_FILENAME : string :=  "NONE"  -- This file is output by the ICAP_VIRTEX6 model and it contains Frame
   );
   port (
     CRCERROR       : out std_logic;                     -- 1-bit output: Output indicating a CRC error
     ECCERROR       : out std_logic;                     -- 1-bit output: Output indicating an ECC error
     ECCERRORSINGLE : out std_logic;                     -- 1-bit output: Output Indicating single-bit Frame ECC error detected.
     FAR            : out std_logic_vector(23 downto 0); -- 24-bit output: Frame Address Register Value output
     SYNBIT         : out std_logic_vector(4 downto 0);  -- 5-bit output: Output bit address of error
     SYNDROME       : out std_logic_vector(12 downto 0); -- 13-bit output: Output location of erroneous bit
     SYNDROMEVALID  : out std_logic;                     -- 1-bit output: Frame ECC output indicating the SYNDROME output is valid.
     SYNWORD        : out std_logic_vector(6 downto 0)   -- 7-bit output: Word output in the frame where an ECC error has been detected
   );
   end component;
  begin
    ins_frame_ecc_virtex6 : FRAME_ECC_VIRTEX6
    generic map (
      FARSRC => "EFAR"
    )
    port map (
      CRCERROR       => crc_error,
      ECCERROR       => ecc_error,
      ECCERRORSINGLE => ecc_error_single,
      FAR            => far_register(23 downto 0),
      SYNBIT         => syn_bit,
      SYNDROME       => syndrome_value,
      SYNDROMEVALID  => syndrome_vld,
      SYNWORD        => syn_word
    );

  end generate;

  --=============================================================
  gen_s6 : if g_arch = "SPARTAN6" generate
    component POST_CRC_INTERNAL is
      port(
        CRCERROR : out std_logic
      );
    end component;
  begin
    ins_post_crc_internal_spartan6 : POST_CRC_INTERNAL
    port map (
      CRCERROR => crc_error       -- 1-bit Post-configuration CRC error
    );
  end generate;

  --=============================================================
  gen_7s : if g_arch = "7SERIES" generate
    ins_frame_ecc_virtex7 : FRAME_ECCE2
    generic map (
      FARSRC                => "EFAR",
      FRAME_RBT_IN_FILENAME => "NONE"
    )
    port map (
      CRCERROR       => crc_error,
      ECCERROR       => ecc_error,
      ECCERRORSINGLE => ecc_error_single,
      FAR            => far_register,
      SYNBIT         => syn_bit,
      SYNDROME       => syndrome_value,
      SYNDROMEVALID  => syndrome_vld,
      SYNWORD        => syn_word
    );
  end generate;
  ------------------------------------------------------------
  --! pulse detector to synchronize the pulse with clock
  ------------------------------------------------------------
  prs_synchronize_clk:
  process (pi_clock)
  begin
    if rising_edge(Pi_clock) then
      crc_error_q  <= crc_error;
      crc_error_qq <= crc_error_q;
      ecc_error_q  <= ecc_error;
      ecc_error_qq <= ecc_error_q;
    end if;
  end process;
  -----------------------------------------------------------
  --! counter for crc error pulse
  -----------------------------------------------------------
  prs_crc_cnt:
  process(pi_clock)is
  begin
    if rising_edge(pi_clock) then
      if (pi_reset = '1') then
        crc_error_cnt <= x"00000000";

      -- count when rising edge of CRC error
      elsif crc_error_qq = '0' and crc_error_q = '1' then
        crc_error_cnt <= std_logic_vector(unsigned(crc_error_cnt) + 1);
      end if;
    end if;
  end process;
  ------------------------------------------------------------
  --! counter for ecc error pulse
  ------------------------------------------------------------
  prs_ecc_cnt:
  process(pi_clock)is
  begin
    if rising_edge(pi_clock) then
      if (pi_reset = '1') then
        ecc_error_cnt <= x"00000000";

      -- count when rising edge of ECC error
      elsif ecc_error_qq = '0' and ecc_error_q = '1' then
        ecc_error_cnt <= std_logic_vector(unsigned(ecc_error_cnt) + 1);
      end if;
    end if;
  end process;

end Behavioral;
