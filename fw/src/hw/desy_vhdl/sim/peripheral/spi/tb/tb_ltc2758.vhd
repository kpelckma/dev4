library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity tb_ltc2758 is
end tb_ltc2758;
 
architecture behavior of tb_ltc2758 is 
 
--  -- UNIT UNDER TEST (UUT) 
--  component dac_ltc2758
--  generic  (
--    g_arch : string := ""; -- Choose ODDR Type (for SPARTAN6 -> ODDR2  others -> ODDR)
--    g_clock_div_ena : natural := 1;
--    g_clock_div : natural := 0
--  );
--  port( 
--    pi_clock    : in std_logic;
--    pi_reset    : in std_logic;

--    --! User Interface    
--    po_busy : out std_logic;
--    po_done : out std_logic;
--    pi_data_vld : in std_logic;
--    pi_data : in std_logic_vector (17 downto 0);
--    po_readback_data : out std_logic_vector(31 downto 0); --! Readback from the IC
--    pi_command : in std_logic_vector(3 downto 0); --! Write/Configure/Update etc.
--    pi_address : in std_logic_vector(3 downto 0); --! Choose DACA or DACB or both
--    pi_span : in std_logic_vector(3 downto 0); --! Span Codes
--    pi_mode : in std_logic; --! 0 -> Send DAC Value 1-> Configuration Mode (send span codes via SPI)       
--    -- SPI Interface
--    pi_spi_sro  : in std_logic;
--    po_spi_sdi  : out std_logic;
--    po_spi_ldac : out std_logic;
--    po_spi_cs_n : out std_logic;
--    po_spi_sck  : out std_logic
--  );
--  end component;

  -- Clock period definitions
  constant pi_clock_period  : time := 32 ns;  -- 40 MHz is the max for this DAC
  
  --! Inputs to the DUT
  signal pi_clock : std_logic;
  signal pi_reset : std_logic;

  signal pi_data : std_logic_vector(17 downto 0);
  signal pi_data_vld : std_logic;
  signal pi_command : std_logic_vector(3 downto 0) := "0101";
  signal pi_address : std_logic_vector(3 downto 0) := "0001";
  signal pi_span : std_logic_vector(3 downto 0):= "1111";
  signal pi_mode : std_logic:= '1';
  signal pi_spi_sro : std_logic := '1'; 
  
  -- Outputs from the DUT
  signal po_dac_busy : std_logic;
  signal po_dac_done : std_logic;
  signal po_dac_data_rb : std_logic_vector(31 downto 0);
   
  --SPI
  signal po_spi_sck : std_logic;                                
  signal po_spi_sdi : std_logic;
  signal po_spi_ldac : std_logic;
  signal po_spi_cs_n : std_logic;
  
begin

    ins_dac : entity work.dac_ltc2758
    generic map(
      g_arch => "ULTRASCALE")
    port map(
      pi_clock => pi_clock,
      pi_reset => pi_reset,

      --! User Interface
      po_busy => po_dac_busy,
      po_done => po_dac_done,
      pi_data_strobe => pi_data_vld,
      pi_data => pi_data,
      po_readback_data => po_dac_data_rb,
      pi_command => pi_command,
      pi_address => pi_address,
      pi_span => pi_span,
      pi_mode => pi_mode,

      -- SPI Interface 
      pi_spi_sro  => pi_spi_sro,
      po_spi_sdi  => po_spi_sdi,
      po_spi_ldac => po_spi_ldac,
      po_spi_cs_n => po_spi_cs_n,
      po_spi_sck  => po_spi_sck
    );

  -- Clock process definitions
  pi_clk_process :process
  begin
    pi_clock <= '0';
    wait for pi_clock_period/2;
    pi_clock <= '1';
    wait for pi_clock_period/2;
  end process;

 -- stimulus process
 stim_proc: process
 begin        
    pi_reset <= '1';
    report "Hard reseted all" severity note;
    wait for 100 ns;   -- hold reset state for 100 ns.
    pi_reset     <= '0';
    wait until rising_edge(pi_clock);
    pi_data <= (others =>'1');
    pi_data_vld <= '1';

    wait;
 end process;

end;
