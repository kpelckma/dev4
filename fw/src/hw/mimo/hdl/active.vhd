library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ===================================================
--
--
-- ====================================================


entity active is
  generic(
     G_len_active:    positive := 1024 -- Number of clock cycles to stay active after pulse_start
     );
  port(
    reset  : in std_logic;
    clock  : in std_logic;

    pi_pulse_start : in  std_logic; -- trigger signal pulsing '1' when RF pulse starts
    po_active      : out std_logic  -- active = '1' G_len_active after pulse_start
    );
   end active;



architecture rtl of active is
  signal ctr2: unsigned(15 downto 0) := (others=> '0');
  signal active : std_logic := '0';
begin

  po_active <= active;

  process(clock)
  begin
      if rising_edge(clock) then
        if reset ='1' then
          active <= '0';        -- reset to inactive (active='0')
          ctr2   <= (others => '0'); -- reset ctr to 0
        elsif ctr2>G_len_active then
          active <= '0';        -- reset to inactive (active='0')
          ctr2   <= (others => '0'); -- reset ctr to 0
        elsif ctr2>0 then
          active <= '1';
          ctr2   <= ctr2 + 1;
        elsif pi_pulse_start='1' then
          ctr2   <= X"0001";
        end if;
      end if;
  end process;

end rtl;

