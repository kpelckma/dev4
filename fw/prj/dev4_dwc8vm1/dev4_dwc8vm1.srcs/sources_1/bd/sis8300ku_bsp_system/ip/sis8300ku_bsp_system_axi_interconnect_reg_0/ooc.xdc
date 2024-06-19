# aclk {FREQ_HZ 125000000 CLK_DOMAIN sis8300ku_bsp_system_xdma_0_0_axi_aclk PHASE 0.000} aclk1 {FREQ_HZ 125000000 CLK_DOMAIN sis8300ku_bsp_system_pi_m_axi4l_app_aclk PHASE 0.000}
# Clock Domain: sis8300ku_bsp_system_xdma_0_0_axi_aclk
create_clock -name aclk -period 8.000 [get_ports aclk]
# Clock Domain: sis8300ku_bsp_system_pi_m_axi4l_app_aclk
create_clock -name aclk1 -period 8.000 [get_ports aclk1]
# Generated clocks
