library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.b32.all;
-----------------------------------------------------------------------
--
----------------------------------------------------------------------

entity ilc16 is
  generic(
    G_len_input:       positive := 10; -- Number of signals fed into the plant P (i.e. result of C)
    G_len_output:      positive := 10; -- Number of signals resulting from the plant P (fed into the controller C)
    G_repetition_rate: positive := 10  -- Repetions per second - default 10Hz
    );
  port(
    reset : in std_logic;
    clock : in std_logic;
    pi_y   : in  std_logic_vector(15 downto 0) := X"0000";
    pi_r   : in  std_logic_vector(15 downto 0) := X"0000";
    po_u   : out std_logic_vector(15 downto 0) := X"0000"
  );
end ilc16;

architecture rtl of ilc16 is

  constant P0 : t_b32v(1 downto 0) := (X"00000000", X"00000000");
  constant P1 : integer := 0;
  constant P2 : integer := 0;

  signal uff  : integer := 0;


begin

  -- convert to unit scale
  

end rtl;
