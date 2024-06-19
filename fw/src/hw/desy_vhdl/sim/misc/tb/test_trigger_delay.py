#!/usr/bin/env python3

# use like this:
# make -f Makefile.xxx SIM=modelsim
# make -f Makefile.xxx SIM=modelsim GUI=1

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly

COUNT_DELAYED_TRG = int(cocotb.top.G_COUNT_DELAYED_TRG)

@cocotb.test()
async def test_trigger_delay(dut):

    cocotb.start_soon(Clock(dut.pi_clock, 10, units="ns").start())

    for i in range(COUNT_DELAYED_TRG):
        dut.pi_delay_val[i].value = i
        dut.pi_delay_val[i]._log.info(f"Trigger delay set to {i}")

    # trigger everything
    dut.pi_main_trigger.value = 0
    for _ in range(3):
        await RisingEdge(dut.pi_clock)
    dut.pi_main_trigger.value = 1
    dut.pi_main_trigger._log.info("Triggering now")

    for i in range(COUNT_DELAYED_TRG):
        # check before waiting for another clock (minimum delay is 0)
        await ReadOnly()
        dut.po_delayed_trigger._log.info(f"Trigger out {i} = {dut.po_delayed_trigger[i].value}")

        # check all trigger outputs - only one must be set, the others must be 0
        for j in range(COUNT_DELAYED_TRG):
            if i==j:
                assert dut.po_delayed_trigger[j].value == 1
            else:
                assert dut.po_delayed_trigger[j].value == 0
        await RisingEdge(dut.pi_clock)
        dut.pi_main_trigger.value = 0
