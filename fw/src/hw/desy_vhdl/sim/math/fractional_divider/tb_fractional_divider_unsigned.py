import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

import numpy as np

TESTS = 1000
OUTPUT_BITS = 18
MAX_VALUE = 2**18-1
RANDOM_DELAY = 5

ST_SAT_OK = 0
ST_SAT_OVERFLOWN = 1
ST_SAT_UNDERFLOWN = 2

@cocotb.test()
async def test_zero_over_value(dut):
    '''
        Test 0 / val
    '''
    cocotb.start_soon(Clock(dut.pi_clk, 10, units="ns").start())

    dut.pi_rst.value = 1

    # resetting the DUT
    await RisingEdge(dut.pi_clk)
    dut.pi_rst.value = 0
    await RisingEdge(dut.pi_clk)

    # random values
    input_values = np.random.randint(1, MAX_VALUE+1, TESTS)

    for input_value in input_values:
        assert dut.po_rdy.value == 1, "po_rdy should be high"
        dut.pi_stb.value = 1
        dut.pi_numerator.value = 0
        dut.pi_denominator.value = int(input_value)

        await RisingEdge(dut.pi_clk)

        dut.pi_stb.value = 0
        await RisingEdge(dut.pi_clk)

        while dut.po_vld.value == 0:
            assert dut.po_rdy.value == 0, "po_rdy should be low"
            await RisingEdge(dut.pi_clk)

        assert dut.po_saturated.value == ST_SAT_OK, "po_saturated should be ST_SAT_OK"
        quotient = dut.po_quotient.value
        assert dut.po_quotient.value == 0, ("po_quotient should be 0, not " +
                                            str(quotient))

        for _ in range(np.random.randint(0, RANDOM_DELAY)):
            await RisingEdge(dut.pi_clk)


@cocotb.test()
async def test_value_over_zero(dut):
    '''
        Test val / 0
    '''
    cocotb.start_soon(Clock(dut.pi_clk, 10, units="ns").start())

    dut.pi_rst.value = 1

    # resetting the DUT
    await RisingEdge(dut.pi_clk)
    dut.pi_rst.value = 0
    await RisingEdge(dut.pi_clk)

    # random values
    input_values = np.random.randint(1, MAX_VALUE+1, TESTS)

    for input_value in input_values:
        assert dut.po_rdy.value == 1, "po_rdy should be high"
        dut.pi_stb.value = 1
        dut.pi_numerator.value = int(input_value)
        dut.pi_denominator.value = 0

        await RisingEdge(dut.pi_clk)

        dut.pi_stb.value = 0
        await RisingEdge(dut.pi_clk)

        while dut.po_vld.value == 0:
            assert dut.po_rdy.value == 0, "po_rdy should be low"
            await RisingEdge(dut.pi_clk)

        assert dut.po_saturated.value == ST_SAT_OVERFLOWN, "po_saturated should be ST_SAT_OVERFLOWN"

        for _ in range(np.random.randint(0, RANDOM_DELAY)):
            await RisingEdge(dut.pi_clk)


@cocotb.test()
async def test_zero_over_zero(dut):
    '''
        Test 0 / 0
    '''
    cocotb.start_soon(Clock(dut.pi_clk, 10, units="ns").start())

    dut.pi_rst.value = 1

    # resetting the DUT
    await RisingEdge(dut.pi_clk)
    dut.pi_rst.value = 0
    await RisingEdge(dut.pi_clk)

    assert dut.po_rdy.value == 1, "po_rdy should be high"
    dut.pi_stb.value = 1
    dut.pi_numerator.value = 0
    dut.pi_denominator.value = 0

    await RisingEdge(dut.pi_clk)

    dut.pi_stb.value = 0
    await RisingEdge(dut.pi_clk)

    while dut.po_vld.value == 0:
        assert dut.po_rdy.value == 0, "po_rdy should be low"
        await RisingEdge(dut.pi_clk)

    assert dut.po_saturated.value == ST_SAT_OVERFLOWN, "po_saturated should be ST_SAT_OVERFLOWN"

    for _ in range(np.random.randint(0, RANDOM_DELAY)):
        await RisingEdge(dut.pi_clk)


@cocotb.test()
async def test_value_over_value(dut):
    '''
        Test val1 / val2 with val1 < val2
    '''
    cocotb.start_soon(Clock(dut.pi_clk, 10, units="ns").start())

    dut.pi_rst.value = 1

    # resetting the DUT
    await RisingEdge(dut.pi_clk)
    dut.pi_rst.value = 0
    await RisingEdge(dut.pi_clk)

    # random numerators
    input_numerators = np.random.randint(1, MAX_VALUE, TESTS)

    for input_numerator in input_numerators:
        input_denominator = np.random.randint(input_numerator+1, MAX_VALUE+1)
        assert dut.po_rdy.value == 1, "po_rdy should be high"
        dut.pi_stb.value = 1
        dut.pi_numerator.value = int(input_numerator)
        dut.pi_denominator.value = int(input_denominator)

        await RisingEdge(dut.pi_clk)

        dut.pi_stb.value = 0
        await RisingEdge(dut.pi_clk)

        while dut.po_vld.value == 0:
            assert dut.po_rdy.value == 0, "po_rdy should be low"
            await RisingEdge(dut.pi_clk)

        assert dut.po_saturated.value == ST_SAT_OK, "po_saturated should be ST_SAT_OK"

        output_quotient = dut.po_quotient.value
        exp_quotient = (input_numerator * 2**OUTPUT_BITS) // input_denominator

        assert output_quotient == exp_quotient, (str(input_numerator) + "/" +
                                                 str(input_denominator) +
                                                 " should be " +
                                                 str(exp_quotient) + " not " +
                                                 str(int(output_quotient)))

        for _ in range(np.random.randint(0, RANDOM_DELAY)):
            await RisingEdge(dut.pi_clk)


@cocotb.test()
async def test_sat(dut):
    '''
        Test val1 / val2 with val1 >= val2
    '''
    cocotb.start_soon(Clock(dut.pi_clk, 10, units="ns").start())

    dut.pi_rst.value = 1

    # resetting the DUT
    await RisingEdge(dut.pi_clk)
    dut.pi_rst.value = 0
    await RisingEdge(dut.pi_clk)

    # random numerators
    input_numerators = np.random.randint(1, MAX_VALUE, TESTS)

    for input_numerator in input_numerators:
        input_denominator = np.random.randint(0, input_numerator+1)
        assert dut.po_rdy.value == 1, "po_rdy should be high"
        dut.pi_stb.value = 1
        dut.pi_numerator.value = int(input_numerator)
        dut.pi_denominator.value = int(input_denominator)

        await RisingEdge(dut.pi_clk)

        dut.pi_stb.value = 0
        await RisingEdge(dut.pi_clk)

        while dut.po_vld.value == 0:
            assert dut.po_rdy.value == 0, "po_rdy should be low"
            await RisingEdge(dut.pi_clk)

        assert dut.po_saturated.value == ST_SAT_OVERFLOWN, "po_saturated should ST_SAT_OVERFLOWN"

        for _ in range(np.random.randint(0, RANDOM_DELAY)):
            await RisingEdge(dut.pi_clk)
