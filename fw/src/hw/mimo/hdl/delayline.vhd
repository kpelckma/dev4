library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


---------------------------------------------
--  delayline
----------------------------------------------

entity delayline is
  generic(
     G_Delay: natural -- this entity implements a delay of 'number of clock cycles'
  );
  port(
    rst  : in std_logic;
    clk  : in std_logic;

    pi_s  : in  std_logic_vector(15 downto 0);
    po_ds : out std_logic_vector(15 downto 0)
    );
  end delayline;



architecture rtl of delayline is

  type   T_dl is array(G_Delay-1 downto 0) of std_logic_vector(15 downto 0);
  signal l_dl : T_dl;

begin



  process (clk) is
  begin
      if falling_edge(clk) then
        if rst = '1' then
          l_dl <= (others => (others => '0'));
        else
          for i in 0 to G_Delay - 2 loop
              l_dl(i+1) <= l_dl(i);
          end loop;
          l_dl(0) <= pi_s;
        end if;
    end if;
  end process;

end rtl;
