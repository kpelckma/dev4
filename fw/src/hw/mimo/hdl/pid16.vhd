library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------------
-- A discrete PID control loop given as
--
--   u[k] = u[k-1] + P0 * e[k] + P1 * e[k-1] + P2 * e[k-2]
--
--   with
--
--   e[k] = r(t) - y(t)
--
--
-- where the parameters P0, P1, P2 are related to Kp, Ki, Ki in a
-- continuous time PID control loop (see any textbook, or wikipedia).
-- Since they have to be tuned anyway, transformations are immaterial
-- (and hence not implemented).
-- In case P2=0, then there is no derivative term.
--
-- The continuous PID control loop is given as
--
--   u(t) = Kp * e(t) + Ki * \int e(t)dt + Kd * e'(t)
--
-- or
--
--   u'(t) = Kp * e'(t) + Ki * e(t) + Kd * e''(t)
--
-- using the approximations:
--
--   e(t)         +-= e[kT]
--                  = y[kT] - r[kT]
--   \int e(t)dt  +-= sum_{i=1}^k e[i]
--   e'(t)        +-= (e[k]-e[k-1])/T
--   e''(t)       +-= (e[k]-2e[k-1]+e[k-2])/T
--
-- where  T is the sampling time
-- (for 125 MSPS -> T=8ns)
----------------------------------------------------------------------

entity pid16 is
  port(
    rst : in std_logic;
    clk : in std_logic;
    y   : in std_logic_vector(15 downto 0);
    r   : in std_logic_vector(15 downto 0);
    u   : out std_logic_vector(15 downto 0)
  );
end pid16;

architecture rtl of pid16 is
  constant P : signed(15 downto 0) :=X"0001";
  constant I : signed(15 downto 0) :=X"0000";
  constant D : signed(15 downto 0) :=X"0000";
  
    signal e  : signed(15 downto 0) := X"0000";
    signal ie : signed(15 downto 0) := X"0000";
    signal de : signed(15 downto 0) := X"0000";
    signal oe : signed(15 downto 0) := X"0000";
    signal ff : signed(35 downto 0) := (others => '0');
begin
  u  <= std_logic_vector(resize(ff, 16));
 
  process(clk) is
  begin
      if rising_edge(clk) then
        oe <= e;
        e  <= signed(r) - signed(y);
        de <= e - oe;
        ie <= ie + e;
        
        -- PID term
        ff <= P * e  +  I * ie  +  D * de;
      end if;
 end process;
end rtl;
