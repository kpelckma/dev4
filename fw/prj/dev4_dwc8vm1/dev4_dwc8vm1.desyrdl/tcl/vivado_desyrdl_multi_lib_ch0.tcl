
variable desyrdl_Sources
lappend desyrdl_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/desyrdl/pkg_desyrdl_common.vhd
add_files $desyrdl_Sources
set_property LIBRARY "desyrdl" [get_files $desyrdl_Sources]

variable FCM_Sources
lappend FCM_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/FCM/pkg_fpga_config_manager.vhd
lappend FCM_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/FCM/fpga_config_manager_decoder_axi4l.vhd.vhd
lappend FCM_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/FCM/fpga_config_manager.vhd
add_files $FCM_Sources
set_property LIBRARY "FCM" [get_files $FCM_Sources]

variable AREA_SPI_DIV_Sources
lappend AREA_SPI_DIV_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_DIV/pkg_spi_ad9510.vhd
lappend AREA_SPI_DIV_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_DIV/spi_ad9510_decoder_axi4l.vhd.vhd
lappend AREA_SPI_DIV_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_DIV/spi_ad9510.vhd
add_files $AREA_SPI_DIV_Sources
set_property LIBRARY "AREA_SPI_DIV" [get_files $AREA_SPI_DIV_Sources]

variable AREA_SPI_ADC_Sources
lappend AREA_SPI_ADC_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_ADC/pkg_spi_ad9268.vhd
lappend AREA_SPI_ADC_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_ADC/spi_ad9268_decoder_axi4l.vhd.vhd
lappend AREA_SPI_ADC_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_ADC/spi_ad9268.vhd
add_files $AREA_SPI_ADC_Sources
set_property LIBRARY "AREA_SPI_ADC" [get_files $AREA_SPI_ADC_Sources]

variable BSP_Sources
lappend BSP_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/BSP/pkg_sis8300ku_bsp_logic.vhd
lappend BSP_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/BSP/sis8300ku_bsp_logic_decoder_axi4l.vhd.vhd
lappend BSP_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/BSP/sis8300ku_bsp_logic.vhd
add_files $BSP_Sources
set_property LIBRARY "BSP" [get_files $BSP_Sources]

variable TIMING_Sources
lappend TIMING_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/TIMING/pkg_timing.vhd
lappend TIMING_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/TIMING/timing_decoder_axi4l.vhd.vhd
lappend TIMING_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/TIMING/timing.vhd
add_files $TIMING_Sources
set_property LIBRARY "TIMING" [get_files $TIMING_Sources]

variable DAQ_Sources
lappend DAQ_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/DAQ/pkg_daq.vhd
lappend DAQ_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/DAQ/daq_decoder_axi4l.vhd.vhd
lappend DAQ_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/DAQ/daq.vhd
add_files $DAQ_Sources
set_property LIBRARY "DAQ" [get_files $DAQ_Sources]

variable MIMO_Sources
lappend MIMO_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/MIMO/pkg_mimo.vhd
lappend MIMO_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/MIMO/mimo_decoder_axi4l.vhd.vhd
lappend MIMO_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/MIMO/mimo.vhd
add_files $MIMO_Sources
set_property LIBRARY "MIMO" [get_files $MIMO_Sources]

variable RTM_Sources
lappend RTM_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/RTM/pkg_rtm.vhd
lappend RTM_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/RTM/rtm_decoder_axi4l.vhd.vhd
lappend RTM_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/RTM/rtm.vhd
add_files $RTM_Sources
set_property LIBRARY "RTM" [get_files $RTM_Sources]

variable APP_Sources
lappend APP_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/APP/pkg_app.vhd
lappend APP_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/APP/app_decoder_axi4l.vhd.vhd
lappend APP_Sources /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/APP/app.vhd
add_files $APP_Sources
set_property LIBRARY "APP" [get_files $APP_Sources]
