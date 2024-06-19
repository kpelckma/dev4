import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()

async def test_0(dut):

  cocotb.start_soon(Clock(dut.pi_clock, 10, units="ns").start())

  await RisingEdge(dut.pi_clock)
  dut.pi_reset.value = 1
  dut.pi_ready.value = 0
  dut.pi_valid.value = 0
  dut.pi_numerator.value = 0
  dut.pi_denominator.value = 0

  for _ in range(0, 10):
    await RisingEdge(dut.pi_clock)
  dut.pi_reset.value = 0

  for _ in range(0, 10):
    await RisingEdge(dut.pi_clock)
  dut.pi_numerator.value = 653504
  dut.pi_denominator.value = 743
  dut.pi_valid.value = 1
  await RisingEdge(dut.pi_clock)
  dut.pi_valid.value = 0

  for _ in range(0, 20):
    await RisingEdge(dut.pi_clock)
  dut.pi_ready.value = 1

  while dut.po_valid.value == 0:
    await RisingEdge(dut.pi_clock)

  dut.pi_numerator.value = 3653504
  dut.pi_denominator.value = 43
  dut.pi_valid.value = 1
  await RisingEdge(dut.pi_clock)
  dut.pi_valid.value = 0

  for _ in range(0, 3):
    await RisingEdge(dut.pi_clock)
  dut.pi_numerator.value = 2436504
  dut.pi_denominator.value = 5756
  dut.pi_valid.value = 1

  while dut.po_valid.value == 0:
    await RisingEdge(dut.pi_clock)

  await RisingEdge(dut.pi_clock)
  dut.pi_valid.value = 0

  for _ in range(0, 20):
    await RisingEdge(dut.pi_clock)
  dut.pi_ready.value = 0
  for _ in range(0, 100):
    await RisingEdge(dut.pi_clock)
  dut.pi_ready.value = 1

  while dut.po_valid.value == 0:
    await RisingEdge(dut.pi_clock)

  for _ in range(0, 50):
    await RisingEdge(dut.pi_clock)
  dut.pi_numerator.value = 87248503
  dut.pi_denominator.value = 694
  dut.pi_valid.value = 1
  await RisingEdge(dut.pi_clock)
  dut.pi_valid.value = 0
  for _ in range(0, 70):
    await RisingEdge(dut.pi_clock)

  dut.pi_reset.value = 1
  for _ in range(0, 10):
    await RisingEdge(dut.pi_clock)
