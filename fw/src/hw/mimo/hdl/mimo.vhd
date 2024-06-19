library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library desy;
use desy.common_types.all;


-- ===================================================
-- implementation of the MIMO controller:
--
--                                   ffd
--                                    |
--  --r--- (-) ---e--- |C| -- cy --  (+) -- u  --- |P| ---y-------->
--          |               -                             |
--          |_____z____|F|__________y_____________________|
--
-- with:
--   C the MIMO controller as implemented in this entity
--   P the plant or system under control
--   F the sensor describing how the measurements y are related to the reference
--
-- r: (dimension G_len_reference) reference signal
-- u: (dimension G_len_input)     input signal to the plant P, result of the controller (the 'drive' signal)
-- y: (dimension G_len_output)    output signal of the plant, fed into the sensor F
-- z: (dimension G_len_reference) sensor signal outpout of the sensor F when fed with y
-- e: (dimension G_len_reference) error signal (e = r-z), serving as input to the controller
--
-- This entity also returns G_len_intern auxiliary signals, used to test operation
-- by exposing some relevant auxiliary signals to the caller. Those signals are displayed
-- by the GUI as to monitor operation. Those signals are derived from the internals
-- of the controller, and defined in an ad-hoc way.
--
-- ====================================================


entity mimo is
  generic(
     G_len_input:     positive := 2; -- Number of signals fed into the plant P (i.e. result of C)
     G_len_output:    positive := 8; -- Number of signals resulting from the plant P (fed into the controller C)
     G_len_reference: positive := 2; -- Number of referebnce signals
     G_len_intern:    positive := 2; -- Number of intern  signals shown to the external world.
     G_order:         positive := 4  -- Order of the system (number of internal states)
  );
  port(
    reset  : in std_logic;
    clock  : in std_logic;

    pi_base : std_logic_vector(15 downto 0); 
    pi_raw  : std_logic_vector(15 downto 0);

    po_u    : out t_16b_slv_vector(G_len_input-1 downto 0);     -- 16b signals fed into the plant (the *drive* signal)
    pi_r    : in  t_16b_slv_vector(G_len_reference-1 downto 0); -- 16b reference signals
    pi_y    : in  t_16b_slv_vector(G_len_output-1 downto 0);    -- 16b output measurements of the plant, fed into the controller
    po_int  : out t_16b_slv_vector(G_len_intern-1 downto 0);    -- 16b auxiliary signals exposed to the external world
    pi_ffd  : in  t_16b_slv_vector(G_len_input-1 downto 0);     -- 16b signal used for feedforward ('ffd')

    pi_K : in t_16b_slv_vector(G_len_input*G_order-1 downto 0);
    pi_rotation : in std_logic_vector(15 downto 0) := X"0000"; -- rotation of the REF signal
    pi_active : in std_logic; --  when '1' activate the controller, when '0' the drive = 0
    pi_fb_switch: in std_logic -- on/off switch of feedback: if ='0', only feedforward is put on the drive 
   );
   end mimo;


------------------- implementation -----------------------
architecture rtl of mimo is

  -- sin and cosine wave used as basis for IQ
  signal l_sin : std_logic_vector(15 downto 0) := X"0000";
  signal l_cos : std_logic_vector(15 downto 0) := X"0000"; 

  -- relevant output signal
  constant C_OUTPUT : integer := 0; -- defines which signal/channel of the ADC is used for the SISO feedback

  -- main signals of the control loop
  signal z  : t_16b_slv_vector(G_len_reference-1 downto 0);
  signal e  : t_16b_slv_vector(G_len_reference-1 downto 0);
  signal cy : t_16b_slv_vector(G_len_input-1 downto 0);
  signal u  : t_16b_slv_vector(G_len_input-1 downto 0);  
  
  -- local copies of pi signals: WHY?
  signal active : std_logic := '0';
  signal fb_switch : std_logic;
  
  -- auxiliary signals
  signal ctr : unsigned(15 downto 0) := (others => '0');
  signal reconstructed : std_logic_vector(15 downto 0) := (others => '0');
  
  signal x1x2: std_logic_vector(31 downto 0) := (others => '0');

  signal ev: t_16b_slv_vector(G_order * G_len_output -1 downto 0) := (others => (others => '0')); -- delay line
  signal fb_signal: t_16b_slv_vector(1 downto 0) := (X"0000", X"0000");
begin

  -- do mkae the sin and cos base signals basis of the IQ demodulator
  l_sin <=   pi_base;
  ins_delayline : entity work.delayline
    generic map (
      G_Delay => 7
    )
    port map(
      rst => reset,
      clk => clock,
      pi_s => pi_base,
      po_ds => l_cos
    );

  -- sensor signal; y -> z
  ins_iq2: entity work.iq
    generic map(
      G_Ratio => 25,
      G_mag => 14
      )
    port map(
      rst => reset,
      clk => clock,
      pi_s => pi_y(C_OUTPUT),
      po_i   => z(0),
      po_q   => z(1),
      pi_sin => l_sin,
      pi_cos => l_cos,
      pi_rotation => pi_rotation,
      po_result   => reconstructed
    );
    
    
    
    
  -- ILC module
  ins_ILC16: entity work.ilc16
    generic map(
      G_len_input  => 10, -- Number of signals fed into the plant P (i.e. result of C)
      G_len_output => 10, -- Number of signals resulting from the plant P (fed into the controller C)
      G_repetition_rate=> 10  -- Repetions per second - default 10Hz
    )
    port map(
      reset => reset,
      clock => clock,
      pi_y   => pi_y(0),
      pi_r   => X"0000",
      po_u   => open
    );
  

  -- main discrete time control loop
  --   y ->- z ->- e ->- u
  po_u <= u;
  active <= pi_active;
  fb_switch <= pi_fb_switch;
  process(clock)
    variable fb: signed(31 downto 0) := (others => '0');  
    begin
      if rising_edge(clock) then
        ctr  <= ctr + 1;  -- increment activity counter (ctr)
        if reset = '1' then
          u  <= (others =>(others => '0')); -- default to 0
          ev <= (others =>(others => '0'));
          ctr  <= (others => '0');          -- reset counter
        elsif active = '0' then
          u <= (others=>(others=> '0')); -- default to 0
          ev <= (others =>(others => '0'));
          ctr  <= (others => '0');          -- reset counter
        else

         for i in G_len_input-1 downto 0 loop
            -- compute  new error
            e(i) <= std_logic_vector(signed(pi_r(i)) - signed(z(i)));
            
            -- shift delay line by +1 unit
            for j in G_order-2 downto 0 loop
                ev(i*G_order +j+1) <= ev(i*G_order + j);
            end loop;
            ev(i*G_order) <= e(i);
            
            -- synthesize discrete PID control (do the cumsum)
            fb := signed(pi_K(i*G_order)) * signed(ev(i*G_order));
            for j in G_order-1 downto 1 loop
              fb := fb + signed(pi_K(i*G_order + j)) * signed(ev(i*G_order+j));
            end loop;
            cy(i) <= std_logic_vector( signed(u(i)) + resize(fb, 16));
            fb_signal(i) <= std_logic_vector(resize(fb, 16));
            
            -- cy(i) <= X"0000";
            if fb_switch = '1' then
              u(i) <= std_logic_vector(signed(pi_ffd(i)) + signed(cy(i)) );
            else
              u(i) <= std_logic_vector(signed(pi_ffd(i)) );
            end if;
            end loop;
        end if;
      end if;
  end process;


  -- define internal signals exposed to the (DAQ) GUI 
  po_int(0) <= pi_r(0);
  po_int(1) <= pi_r(1);
  
  po_int(2) <= z(0); -- pi_y(C_OUTPUT);
  po_int(3) <= z(1); -- z(1); -- reconstructed;
                     
  po_int(4) <= e(0); -- z(0); --
  po_int(5) <= e(1); -- fb_signal(0); -- z(1); -- 
  
  po_int(6) <= reconstructed;
  po_int(7) <= pi_y(C_OUTPUT);
end rtl;
