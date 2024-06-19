library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


---------------------------------------------
--  IQ demodulation module
--
-- ex.:
--   sampling at 125 MSPS (1 sample per 8 nano second)
--   clock at 125 MHz
--   s carrier frequency at 31.25 MHz
----------------------------------------------

entity iq is
  generic(
     G_Ratio : natural; -- samples per cycle of the IF signal. If = 4, then we do full IQ
     G_mag   : natural  -- how much is the REF magnified from [-1..1] (in number of bits)? 
  );
  port(
    rst  : in std_logic;
    clk  : in std_logic;
     
    pi_s    : in  std_logic_vector(15 downto 0);
    po_i    : out std_logic_vector(15 downto 0);
    po_q    : out std_logic_vector(15 downto 0);
    
    pi_sin : in std_logic_vector(15 downto 0);
    pi_cos : in std_logic_vector(15 downto 0);
    pi_rotation : in std_logic_vector(15 downto 0);

    po_result   : out std_logic_vector(15 downto 0)
    );
  end iq;
  
  

architecture rtl of iq is
  constant C : real := 32767.0; -- 2^14 = 16383.0; 

  signal l_sin   : std_logic_vector(15 downto 0) := X"0000"; -- rotated SIN 
  signal l_cos   : std_logic_vector(15 downto 0) := X"0000"; -- rotated COS  
  
  signal d_s     : std_logic_vector(15 downto 0) := X"0000"; -- delayed signal s
  signal d_sin   : std_logic_vector(15 downto 0) := X"0000"; -- delayed SIN 
  signal d_cos   : std_logic_vector(15 downto 0) := X"0000"; -- delayed COS 
  signal l_i     : std_logic_vector(15 downto 0) := X"0000"; -- local I(s)
  signal l_q     : std_logic_vector(15 downto 0) := X"0000"; -- local Q(s) 


begin

  l_sin <= pi_sin;
  l_cos <= pi_cos;
  po_i  <= l_i;
  po_q  <= l_q;
  
  process (clk) is
  begin
      if falling_edge(clk) then
        if rst = '1' then
          l_i <= (others => '0');
          l_q <= (others => '0');
          
        else
          
          -- two sample reconstruction: s, l_s2 --> i,q
          l_i  <= std_logic_vector(resize(shift_right(signed(l_sin) * signed(d_s) - signed(d_sin) * signed(pi_s),   G_mag), 16) ); -- put in 16b format
          l_q  <= std_logic_vector(resize(shift_right(signed(d_cos) * signed(pi_s)   - signed(l_cos) * signed(d_s), G_mag), 16) ); -- put in 16b format
        
          -- full IQ reconstruction
          -- l_i <= x"0001";
          -- l_q <= x"0000";
          
          -- reconstruction of the signal s.
          po_result <= std_logic_vector(resize( (signed(pi_sin)*signed(l_i) + signed(pi_cos)*signed(l_q)), 16));

          -- unit delay
          d_s   <= pi_s;
          d_cos <= l_cos;
          d_sin <= l_sin;
        end if;
    end if;
  end process;

end rtl;
