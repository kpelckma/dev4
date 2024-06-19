#!/usr/bin/python3
import mtca4u
import numpy as np
import time
import datetime
import os

# outdated version: active one on the COMex

class dev4:
    def __init__(self):

        # creat .dmap file
        if not os.path.exists("./include/mapfile.dmap"):
            os.mknod("./include/mapfile.dmap")
            with open("./include/mapfile.dmap", "w") as dmap_file:
              dmap_file.write("device_reg" + " (xdma:xdma/slot" + str(6) + "?map=./include/ch13.mapp" + ")\n")

        # Creating device entry using the mtca4u library
        # based on DESY's ChimeraTK (see: https://chimeratk.github.io/DeviceAccess-PythonBindings/).
        mtca4u.set_dmap_location("./include/mapfile.dmap")
        self.device = mtca4u.Device("device_reg")

        self.app_clk_freq = 125_000_000
        self.trigger_rate = 0.1
        self.rtm_name = "DWC8VM1"
        self.dma_length = 16384
        self.ad9510_input = 0  # '1' for internal quarz, '2' for external clock
        self.ad9510_division = 1
        self.daq_strobe_div = 1


    #  Initialize modules BSP, RTM, TIMING, DAQ, APP by writing registers
    #
    # For a complete description of the set options, see
    # the accompagnying documentation (file: FWK_documentation_desy_march2022.pdf, chapter 6).
    def init_board(self):

        # ---- Set stage ----------------------------
        self.device_write("BSP", "CLK_SEL", 0) # just for initial stage
        self.device_write("BSP", "RESET_N", 0) # reset BSP
        self.device_write("BSP", "RESET_N", 1) # power on again

        # ---- Initialize RTM --------------------------
        self.device_write("RTM", "RF_PERMIT", 1)   # namechange in v2.0.0!
        #self.device_write("RTM", "DACAB", 870)     # namechange in v2.0.0!
        self.device_write("RTM", "DACAB", 570)     # namechange in v2.0.0!
        self.device_write("BSP", "ADC_REVERT_CLK", 0x18)
        #self.device_write("BSP", "ADC_REVERT_CLK", 0x10)
        #### changes according to CLK input

        # ---- Reset and Program AD9510s ('Clock dividers' driving ADCs) -----------------
        # see Datasheet AD9510, pp. 44 for the meaning of the registers
        #
        self.device_write("BSP", "AREA_SPI_DIV", 0x00, 0x58) # register 0x58 to 0x00
        self.device_write("BSP", "AREA_SPI_DIV", 0x01, 0x5A) # update all

        # ---- Reset SIS8300ku -----------------------------
        self.device_write("BSP", "CLK_RST", 1) # reset
        self.device_write("BSP", "CLK_RST", 0) # power on again



        # ---- Set MUX clock to RTM(CLK2) -------------------------------
        #        self.device_write("BSP", "CLK_MUX", [3, 3, 0, 0, 0, 0]) # on-board 125MHz Quartz
        self.device_write("BSP", "CLK_MUX", [0, 0, 0, 0, 0, 0]) # on-board 125MHz Quartz
        # self.device_write("BSP", "CLK_MUX", [0, 0, 1, 1, 1, 0]) # external R&S via SMA on faceplate sis8300ku

        self.device_write("BSP", "AREA_SPI_DIV", self.ad9510_input, 0x45)
                            # Selecting which CLK input will be used to distribute
                            # 0 -> PLL uses clock coming from RTM(CLK2)    1 -> PLL uses clock coming from Muxes(CLK1)
        self.device_write("BSP", "AREA_SPI_DIV", 0x43, 0x0A)
                            # set N divider to 0x43 = bit: 0100 0011

        # All output voltage levels (LVPECL) are set to 660mV
        # 0x0c = bit: 0000 1100
        self.device_write("BSP", "AREA_SPI_DIV", 0x0C, 0x3C)
        self.device_write("BSP", "AREA_SPI_DIV", 0x0C, 0x3D)
        self.device_write("BSP", "AREA_SPI_DIV", 0x0C, 0x3E)
        self.device_write("BSP", "AREA_SPI_DIV", 0x0C, 0x3F)

        # Output Current Level = 3.5mA Termination 100ohms Output Type = LVDS
        # 0x02 = bit: 0000 0010
        self.device_write("BSP", "AREA_SPI_DIV", 2, 0x40)
        self.device_write("BSP", "AREA_SPI_DIV", 2, 0x41)
        self.device_write("BSP", "AREA_SPI_DIV", 2, 0x42)
        self.device_write("BSP", "AREA_SPI_DIV", 2, 0x43)

        # Bypass and power down divider logic; route clock directly to output
        # We have that  ad9510_division = 2
        self.device_write("BSP", "AREA_SPI_DIV", 0x00, 0x49)
        self.device_write("BSP", "AREA_SPI_DIV", 0x00, 0x4B)
        self.device_write("BSP", "AREA_SPI_DIV", 0x00, 0x4D)
        self.device_write("BSP", "AREA_SPI_DIV", 0x00, 0x4F)
        self.device_write("BSP", "AREA_SPI_DIV", 0x00, 0x51)
        self.device_write("BSP", "AREA_SPI_DIV", 0x00, 0x53)
        self.device_write("BSP", "AREA_SPI_DIV", 0x00, 0x55)
        self.device_write("BSP", "AREA_SPI_DIV", 0x00, 0x57)

        self.device_write("BSP", "AREA_SPI_DIV", 0x20, 0x58) # registeer 0x58 to 0x20
        self.device_write("BSP", "AREA_SPI_DIV", 1, 0x5A) # update all
        time.sleep(1)

        # -------------------------------------------------------
        self.device_write("BSP", "CLK_RST", 1) # reset clock
        self.device_write("BSP", "CLK_RST", 0) # power-on again

        self.check_clk()


        # ---- Enable CLKs again ----------------------------------
        self.device_write("BSP", "CLK_SEL", 1) # 1: 125MHz internal crystal 0:CLK05 extern clock
        self.device_write("BSP", "RESET_N", 0)
        self.device_write("BSP", "RESET_N", 1)


        # ---- Initialise ADCs -------------------------------------
        # See address map of ADC (AD9268 chip),
        # manual AD9268, p. 37
        self.device_write("BSP", "ADC_REVERT_CLK", 0x18)

        self.device_write("BSP", "AREA_SPI_ADC", 0x3C, 0x00) # 0x3c = bits: 0011 1100
        self.device_write("BSP", "AREA_SPI_ADC", 0x41, 0x14) # 0x41 = bits: 0100 0001
        self.device_write("BSP", "AREA_SPI_ADC", 0x00, 0x0D) # 0x00 = bits: 0000 0000
        self.device_write("BSP", "AREA_SPI_ADC", 0x01, 0xFF) #  setting transfer bit

        self.device_write("BSP", "ADC_ENA", 0) # power off
        self.device_write("BSP", "ADC_ENA", 1) # power on
        self.device_write("BSP", "DAC_ENA", 1)


        # ---- Initialize trigger channels Ch0 & Ch1 -------------------------------
        self.device_write("TIMING", "SOURCE_SEL", 0, 0)  # DAQ trigger will be sourced from application clock (125MHz)
        self.device_write("TIMING", "SOURCE_SEL", 0, 1)  # DPM DAC Table strobe will be sourced from application clock (125MHz)
        self.device_write("TIMING", "SOURCE_SEL", 10, 2)  

        self.device_write("TIMING", "SYNC_SEL", 1, 1)    # DPM DAC Table strobe will be synced with DAQ Trigger
        self.device_write("TIMING", "DIVIDER_VALUE", self.app_clk_freq * self.trigger_rate - 1, 0)
        self.device_write("TIMING", "DIVIDER_VALUE", 0, 1)

        self.device_write("TIMING", "ENABLE", 7)  # Enable Trigger Channel

        self.device_write("APP", "DPM_MODE", 1)
        self.device_write("APP", "MLVDS_OE", 0x60)  # Output Enable
        self.device_write("APP", "MLVDS_O", 0x60)   # Output Value

        # Initialise the strobe signal of the DAQ
        self.device_write("DAQ", "SAMPLES", self.dma_length, 0)
        self.device_write("DAQ", "STROBE_DIV", self.daq_strobe_div-1, 0)   # strobe DAQ = clk / xxx # originally set to 99
        self.device_write("DAQ", "TAB_SEL", 0, 0)      # Choose raw adc signals on mux
        self.device_write("DAQ", "DOUBLE_BUF_ENA", 1, 0)  # Enable double buffering for Region 0
        self.device_write("DAQ", "ENABLE", 1, 0)       # Enable DAQ1 for now.

        # ---- Initialise attenuators on the RTM ----------------
        self.device_write("RTM", "ATT_SEL", 255)
        self.device_write("RTM", "ATT_VAL", 63)
        ############ The end ####################################



        compilation_unix_time = self.device.read("BSP", "PRJ_TIMESTAMP")
        print(
            "This firmware was compiled on:",
            datetime.datetime.fromtimestamp(int(compilation_unix_time)).strftime(
                "%d-%B-%Y %H:%M:%S"
            ),
        )

    # simple relay function with an extra sleep command to ensure that the register is written when done
    def device_write(self, module, register, value, idx=0):
        # print(module+'/'+register+'('+str(idx)+')'+'='+str(value))
        self.device.write(module, register, value, idx)
        time.sleep(0.01)


    # Read the currently used DAQ buffer
    def read_daq(self):
        self.device_write("DAQ","DOUBLE_BUF_ENA",0, 0) # switch dubble buffer off
        buf_to_read = int(not(self.device.read("DAQ", "ACTIVE_BUF",1,0)))
        daq0_data = self.device.read_sequences("DAQBUF","DAQ_CTRL_BUF{}".format(buf_to_read))
        self.device_write("DAQ","DOUBLE_BUF_ENA", 1, 0) # switch dubble buffer on again
        return daq0_data

    # write in the reference tables
    def update_ref_table(self, ref_i, ref_q):
        for i in range(1024):
            self.device.write("APP", "REF_I", ref_i[i], i)
            self.device.write("APP", "REF_Q", ref_q[i], i)
        time.sleep(2)

    # write in the Feedfoward (FFD) tables
    def update_ffd_table(self, ffd_i, ffd_q):
        for i in range(1024):
            self.device.write("APP", "FFD_I", ffd_i[i], i)
            self.device.write("APP", "FFD_Q", ffd_q[i], i)
        time.sleep(1)

    def enable_irq(self, enable, channel):
        """Enables the particular PCIe IRQ channel

        :param enable: 1 -> Enable, 0 -> Disable
        :type enable: int
        :param channel: Choose which xDMA IRQ channel to enable/disable
        """
        self.device.write("BSP", "PCIE_IRQ_ENA", enable, channel)


    #
    def check_clk(self):
      clockFrequency = self.device.read("BSP", "CLK_FREQ", 1, 1)
      print("*** CLK frequency:", str(clockFrequency))
