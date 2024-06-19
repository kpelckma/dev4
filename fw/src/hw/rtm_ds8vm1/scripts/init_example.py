#!/usr/bin/python3

from rtm_ds8vm1 import rtm_ds8vm1

my_device = rtm_ds8vm1(dmap_location="example.dmap", device_name="sis8300ku_slot4")

print(my_device.get_version())
