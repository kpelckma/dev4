-------------------------------------------------------------------------------
--          ____  _____________  __                                          --
--         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
--        / / / / __/  \__ \  \  /                 / \ / \ / \               --
--       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
--      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
--                                                                           --
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.common_types.all;
-------------------------------------------------------------------------------

package peripheral_i2c is

  component hdc1000 is
    generic (
      g_clk_freq    : natural                      := 50_000_000;
      g_i2c_addr    : std_logic_vector(7 downto 0) := x"FF"
      );
    port (
      pi_clock : in  std_logic;
      pi_reset : in  std_logic;
      -- Arbiter Interface
      po_req   : out std_logic;
      pi_grant : in  std_logic;
      -- i2c_controler interface
      pi_i2c_data       : in  std_logic_vector(31 downto 0);
      pi_i2c_done       : in  std_logic;
      po_i2c_str        : out std_logic;
      po_i2c_write_ena  : out std_logic;
      po_i2c_rep        : out std_logic;
      po_i2c_data_width : out std_logic_vector(1 downto 0);
      po_i2c_data       : out std_logic_vector(31 downto 0);
      po_i2c_addr       : out std_logic_vector(7 downto 0);
        -- User interface
      pi_trg            : in std_logic;
      po_data_vld       : out std_logic;                -- one clock cycle high
      po_humidity       : out std_logic_vector(13 downto 0);
      po_temperature    : out std_logic_vector(13 downto 0);
      po_busy           : out  std_logic
      );
    end component hdc1000;

    component i2c_control_arbiter is
      generic (
        G_PORTS_NUM   : natural := 3;   --! number of ports
        G_I2C_CLK_DIV : integer := 800 --! clock divider for I2C
      );
      port (
        pi_clock      : in    std_logic;
        pi_reset      : in    std_logic;
        -- Arbiter Interface
        pi_i2c_req    : in    std_logic_vector(G_PORTS_NUM - 1 downto 0);
        po_i2c_grant  : out   std_logic_vector(G_PORTS_NUM - 1 downto 0);
        -- i2c_controler interface
        pi_str        : in    std_logic_vector(G_PORTS_NUM - 1 downto 0);
        pi_wr         : in    std_logic_vector(G_PORTS_NUM - 1 downto 0);
        pi_rep        : in    std_logic_vector(G_PORTS_NUM - 1 downto 0);
        pi_data_width : in    t_2b_slv_vector(G_PORTS_NUM - 1 downto 0);
        pi_data       : in    t_32b_slv_vector(G_PORTS_NUM - 1 downto 0);
        pi_addr       : in    t_8b_slv_vector(G_PORTS_NUM - 1 downto 0);
        po_data       : out   std_logic_vector(31 downto 0);
        po_done       : out   std_logic_vector(G_PORTS_NUM - 1 downto 0);
        po_busy       : out   std_logic_vector(G_PORTS_NUM - 1 downto 0);
        po_dry        : out   std_logic_vector(G_PORTS_NUM - 1 downto 0);
        --! I2C interface
        pi_sdi        : in    std_logic;  --! data input
        po_sdo        : out   std_logic;  --! data output
        po_sdt        : out   std_logic;  --! data direction
        pi_sci        : in    std_logic;  --! clock input
        po_sco        : out   std_logic;  --! clock output
        po_sct        : out   std_logic   --! clock direction
      );
    end component i2c_control_arbiter;

    component i2c_controller is
      generic (
        G_DIVIDER : natural := 25 --! FREQ_CLK_SPI=FREQ_I_CLK/G_DIVIDER
      );
      port (
        p_i_clk        : in    std_logic;
        pi_reset       : in    std_logic;
        -- i2c_controler interface
        pi_str         : in    std_logic;
        pi_wr          : in    std_logic;
        pi_rep         : in    std_logic; --! don't send stop bit (for repeated start)
        pi_data_width  : in    std_logic_vector(1 downto 0);
        pi_data        : in    std_logic_vector(31 downto 0);
        po_data        : out   std_logic_vector(31 downto 0);
        po_data_dry    : out   std_logic;
        pi_addr        : in    std_logic_vector(6 downto 0);
        po_done        : out   std_logic;
        po_busy        : out   std_logic;
        --! I2C interface
        pi_sdi         : in    std_logic; -- data input
        po_sdo         : out   std_logic; -- data output
        po_sdt         : out   std_logic; -- data direction, 0: high impedance
        pi_sci         : in    std_logic;
        po_sco         : out   std_logic;
        po_sct         : out   std_logic
      );
    end component i2c_controller;

  component ltc2495 is
  generic (
    g_i2c_addr  : std_logic_vector(7 downto 0) := "00110100";
    g_clk_freq  : natural := 125_000_000 -- in Hz
    );
  port (
    pi_clock    : in  std_logic;
    pi_reset    : in  std_logic;  
    -- Arbiter Interface
    po_req      : out std_logic;
    pi_grant    : in  std_logic;
    -- i2c_controler interface
    pi_i2c_data       : in  std_logic_vector(31 downto 0);
    pi_i2c_done       : in  std_logic;
    po_i2c_str        : out std_logic;
    po_i2c_write_ena  : out std_logic;
    po_i2c_rep        : out std_logic;
    po_i2c_data_width : out std_logic_vector(1 downto 0);
    po_i2c_data       : out std_logic_vector(31 downto 0);
    po_i2c_addr       : out std_logic_vector(7 downto 0);
  -- User interface
    pi_trg            : in  std_logic;
    po_busy           : out std_logic;
    po_data_vld       : out std_logic;
    po_data           : out t_17b_slv_vector(16 downto 0);  --! 17th channel = internal Tmperature
    pi_ch_ena         : in  std_logic_vector(16 downto 0);  --! 17th channel = internal Tmperature
    pi_ch_cfg_sgl_ena : in  std_logic_vector(15 downto 0);  --! b'1': channel is set as single ended, '0':don't care
    pi_ch_cfg_diff_ena: in  std_logic_vector(15 downto 0);  --! b'1': channel is set as differntial, '0':don't care
    pi_ch_cfg_reject  : in  t_2b_slv_vector(16 downto 0);   --! b"00" Simultaneous 50/60 Hz Rejection
                                                            --! b"01" 50 Hz Rejection
                                                            --! b"10" 60 Hz Rejection
                                                            --! b"11" reserved, do not use
    pi_ch_cfg_speed   : in  std_logic_vector(15 downto 0);  --! b'0' Normal speed, Auto-Calbration enabled
                                                            --! b'1' 2x speed, Auto-Calbration disabled 
    pi_ch_cfg_gain    : in  t_3b_slv_vector(15 downto 0)    --! g = 2^"cfg_gain
    );
  end component ltc2495;

  component ltc2945 is
    generic(
      g_clk_freq      : natural := 125_000_000; -- in Hz
      g_i2c_addr      : std_logic_vector(7 downto 0) := x"DE"
      );
    port (
      pi_clock          : in  std_logic;
      pi_reset          : in  std_logic;
      -- Arbiter interface
      po_req            : out std_logic;
      pi_grant          : in  std_logic;
      po_i2c_rep        : out std_logic;
      -- i2c_controler interface
      pi_i2c_data       : in  std_logic_vector(31 downto 0);
      pi_i2c_done       : in  std_logic;
      po_i2c_str        : out std_logic;
      po_i2c_write_ena  : out std_logic;
      po_i2c_data_width : out std_logic_vector(1 downto 0);
      po_i2c_data       : out std_logic_vector(31 downto 0);
      po_i2c_addr       : out std_logic_vector(7 downto 0);
      -- User interface
      pi_trg            : in std_logic;
      po_data_vld     : out std_logic;                      -- one clock cycle high
      po_current        : out std_logic_vector(15 downto 0);
      po_voltage        : out std_logic_vector(15 downto 0);
      po_busy           : out  std_logic
      );
    end component ltc2945;
  
  component mcp23017 is 
  generic(  
    g_clk_freq  : natural                       := 125_000_000; -- in Hz
    g_i2c_addr  : std_logic_vector(7 downto 0)  := x"40"
    );
  port (
    pi_clock      : in  std_logic;
    pi_reset      : in  std_logic;
    -- Arbiter interface
    po_req        : out std_logic;
    pi_grant      : in  std_logic;
    -- i2c_controler interface
    pi_i2c_data       : in  std_logic_vector(31 downto 0);
    pi_i2c_done       : in  std_logic;
    po_i2c_str        : out std_logic;
    po_i2c_write_ena  : out std_logic;
    po_i2c_rep        : out std_logic;
    po_i2c_data_width : out std_logic_vector(1 downto 0);
    po_i2c_data       : out std_logic_vector(31 downto 0); 
    po_i2c_addr       : out std_logic_vector(7 downto 0);
    -- User configuration interface
    pi_trg        : in  std_logic;
    po_data_a     : out std_logic_vector(7 downto 0); -- GPIO_A intput, read
    po_data_b     : out std_logic_vector(7 downto 0); -- GPIO_B intput, read
    po_data_vld   : out std_logic;
    po_busy       : out std_logic 
    );
  end component mcp23017; 




  component pca9536 is
    generic(  
      g_clk_freq  : natural := 125_000_000 -- in Hz
      );
    port (
      pi_clock          : in  std_logic;
      pi_reset          : in  std_logic;
      -- Arbiter interface
      po_req            : out std_logic;
      pi_grant          : in  std_logic;
      -- I2C_CONTROLER interface
      po_i2c_str        : out std_logic;
      po_i2c_write_ena  : out std_logic;
      po_i2c_rep        : out std_logic;
      po_i2c_data_width : out std_logic_vector(1 downto 0);
      po_i2c_data       : out std_logic_vector(31 downto 0);
      po_i2c_addr       : out std_logic_vector(7 downto 0);
      pi_i2c_done       : in  std_logic;
      pi_i2c_data       : in  std_logic_vector(31 downto 0); 
      -- User interface
      pi_trg            : in  std_logic;
      pi_data           : in std_logic_vector(3 downto 0); --  output, send data
      po_data_vld       : out std_logic;
      po_busy           : out std_logic
      );
    end component pca9536;
  
  component pca9542 is  
  generic(
    g_i2c_addr        : std_logic_vector(7 downto 0) := x"E0";  -- first byte always "1110" preamble
    g_cfg_pi_addr_ena : std_logic := '0'                        --'0' fixed g_i2c_addr, '1' port pi_i2c_addr
  );
  port(
    pi_clock          : in  std_logic;
    pi_reset          : in  std_logic;
    -- Arbiter interface
    po_req            : out std_logic;
    pi_grant          : in  std_logic;
    -- I2C_CONTROLER interface
    po_i2c_str        : out std_logic;
    po_i2c_write_ena  : out std_logic;
    po_i2c_rep        : out std_logic;
    po_i2c_data_width : out std_logic_vector(1 downto 0);
    po_i2c_data       : out std_logic_vector(31 downto 0);
    po_i2c_addr       : out std_logic_vector(7 downto 0);
    pi_i2c_done       : in  std_logic;
    pi_i2c_data       : in  std_logic_vector(31 downto 0);
    -- User Interface
    pi_trg            : in  std_logic;
    pi_cfg_addr       : in  std_logic_vector(7 downto 0);
    pi_cfg_ch_ena     : in  std_logic:='0'; -- '0' ch0 enabled, '1' ch1 enable
    pi_cfg_switch_ena : in  std_logic:='0'; -- '0' disable complete switch
                                            -- '1' enable selected ch !!should be used when g_cfg_device_addr_ena is '1'
    po_cfg_done       : out std_logic;
    po_busy           : out std_logic
  );
  end component pca9542;


 

 


  component tca9539 is
  generic(  
    G_CLK_FREQ  : natural                       := 125_000_000; -- in Hz
    G_I2C_ADDR  : std_logic_vector(7 downto 0)  := '0'&"1110101"
    );
  port (
    pi_clock          : in  std_logic;
    pi_reset          : in  std_logic;
    -- Arbiter interface
    po_req            : out std_logic;
    pi_grant          : in  std_logic;
    -- i2c_controler interface
    pi_i2c_data       : in  std_logic_vector(31 downto 0);
    pi_i2c_done       : in  std_logic;
    po_i2c_str        : out std_logic;
    po_i2c_write_ena  : out std_logic;
    po_i2c_rep        : out std_logic;
    po_i2c_data_width : out std_logic_vector(1 downto 0);
    po_i2c_data       : out std_logic_vector(31 downto 0);
    po_i2c_addr       : out std_logic_vector(7 downto 0);
    -- User configuration interface
    pi_trg        : in  std_logic;
    pi_data_p0    : in std_logic_vector(7 downto 0);  -- Output write P07 ... P00
    pi_data_p1    : in std_logic_vector(7 downto 0);  -- Output write P17 ... P10
    po_done       : out std_logic;
    po_busy       : out std_logic 
    );
  end component tca9539;
  
end package peripheral_i2c;