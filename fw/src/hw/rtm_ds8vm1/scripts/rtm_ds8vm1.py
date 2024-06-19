#!/usr/bin/python3
import mtca4u
import time
import sys
import datetime
import numpy as np

class rtm_ds8vm1():
  def __init__(self, dmap_location, device_name):
    self.dmap_location = dmap_location
    self.device_name = device_name

    mtca4u.set_dmap_location(self.dmap_location)
    self.device = mtca4u.Device(self.device_name)
    self.check_pcie_connection()

  def get_version(self):
    return self.device.read("DS8VM1", "WORD_VERSION")

  def set_rf_permit(self, rf_permit):
    self.device.write("DS8VM1", "WORD_RF_PERMIT", rf_permit)

  def check_pcie_connection(self):
    # Simple check by reading a register.
    if self.device.read("BSP", "WORD_USER") == -1:
      print("*****************************************************")
      print("  WORD_USER returns -1")
      print("  This could be a possible PCIe communication problem!")
      print("  Solution: Reboot the PCIe root complex")
      print("*****************************************************")
      sys.exit(1)
    else:
      magic_number = 666
      print("PCIe communication is working")
      self.device.write("BSP", "WORD_USER", magic_number)
      if self.device.read("BSP", "WORD_USER") == magic_number:
        print("Map file sanity check passed!")
        return True
      else:
        print("Map file sanity check FAILED! \n \
        Are you sure you are using the right map file?")
        return False

    


