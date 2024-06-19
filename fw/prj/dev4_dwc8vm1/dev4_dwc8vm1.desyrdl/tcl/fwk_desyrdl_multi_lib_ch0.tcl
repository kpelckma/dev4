# ==============================================================================
proc init {} {
}

# ==============================================================================
proc setSources {} {
  variable Sources
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/desyrdl/pkg_desyrdl_common.vhd "VHDL" "desyrdl"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/FCM/pkg_fpga_config_manager.vhd "VHDL" "FCM"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/FCM/fpga_config_manager_decoder_axi4l.vhd.vhd "VHDL" "FCM"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/FCM/fpga_config_manager.vhd "VHDL" "FCM"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_DIV/pkg_spi_ad9510.vhd "VHDL" "AREA_SPI_DIV"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_DIV/spi_ad9510_decoder_axi4l.vhd.vhd "VHDL" "AREA_SPI_DIV"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_DIV/spi_ad9510.vhd "VHDL" "AREA_SPI_DIV"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_ADC/pkg_spi_ad9268.vhd "VHDL" "AREA_SPI_ADC"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_ADC/spi_ad9268_decoder_axi4l.vhd.vhd "VHDL" "AREA_SPI_ADC"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/AREA_SPI_ADC/spi_ad9268.vhd "VHDL" "AREA_SPI_ADC"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/BSP/pkg_sis8300ku_bsp_logic.vhd "VHDL" "BSP"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/BSP/sis8300ku_bsp_logic_decoder_axi4l.vhd.vhd "VHDL" "BSP"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/BSP/sis8300ku_bsp_logic.vhd "VHDL" "BSP"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/TIMING/pkg_timing.vhd "VHDL" "TIMING"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/TIMING/timing_decoder_axi4l.vhd.vhd "VHDL" "TIMING"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/TIMING/timing.vhd "VHDL" "TIMING"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/DAQ/pkg_daq.vhd "VHDL" "DAQ"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/DAQ/daq_decoder_axi4l.vhd.vhd "VHDL" "DAQ"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/DAQ/daq.vhd "VHDL" "DAQ"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/MIMO/pkg_mimo.vhd "VHDL" "MIMO"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/MIMO/mimo_decoder_axi4l.vhd.vhd "VHDL" "MIMO"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/MIMO/mimo.vhd "VHDL" "MIMO"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/RTM/pkg_rtm.vhd "VHDL" "RTM"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/RTM/rtm_decoder_axi4l.vhd.vhd "VHDL" "RTM"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/RTM/rtm.vhd "VHDL" "RTM"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/APP/pkg_app.vhd "VHDL" "APP"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/APP/app_decoder_axi4l.vhd.vhd "VHDL" "APP"]
  lappend Sources [list /home/kristiaanpelckmans/Downloads/dev4/fw/prj/dev4_dwc8vm1/dev4_dwc8vm1.desyrdl/vhdl/APP/app.vhd "VHDL" "APP"]
}

# ==============================================================================
proc setAddressSpace {} {
}

# ==============================================================================
proc doOnCreate {} {
  variable Sources
  addSources "Sources"
}

# ==============================================================================
proc doOnBuild {} {
}

# ==============================================================================
proc setSim {} {
}