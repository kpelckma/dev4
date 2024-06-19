import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

import numpy as np

TESTS = 1000
OUTPUT_BITS = 17
MAX_VALUE = 2**17 - 1
RANDOM_DELAY = 5


@cocotb.test()
async def test_value_over_value(dut):
    '''
        Test val1 / val2
    '''

    cocotb.start_soon(Clock(dut.pi_clk, 10, units="ns").start())

    ST_SAT_OK = 0 
    ST_SAT_OVERFLOWN = 1
    ST_SAT_UNDERFLOWN = 2

    def divide(numerator, denominator):
        '''
            model of fractional_divider_signed
        '''
        sign = (numerator >= 0) ^ (denominator >= 0)

        if abs(numerator) >= abs(denominator):
            if sign:
                return (ST_SAT_UNDERFLOWN, 0)
            else:
                return (ST_SAT_OVERFLOWN, 0)
        else:
            quotient = abs(numerator * (2 ** OUTPUT_BITS)) // abs(denominator)
            if sign:
                return (ST_SAT_OK, - quotient)
            else:
                return (ST_SAT_OK, quotient)

    dut.pi_rst.value = 1

    # resetting the DUT
    await RisingEdge(dut.pi_clk)
    dut.pi_rst.value = 0
    await RisingEdge(dut.pi_clk)

    # random numerators
    input_numerators = np.random.randint(- MAX_VALUE - 1, MAX_VALUE, TESTS)
    input_denominators = np.random.randint(- MAX_VALUE - 1, MAX_VALUE, TESTS)

    for input_numerator, input_denominator in zip(input_numerators,
                                                  input_denominators):
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

        (exp_saturation, exp_quotient) = divide(input_numerator,
                                                input_denominator)

        if exp_saturation:
            error_str = ("po_saturated should be " + str(exp_saturation) +
                         " not " + str(dut.po_saturated.value))
            assert dut.po_saturated.value == exp_saturation, error_str
        else:
            assert dut.po_saturated.value == 0, ("po_saturated" +
                                                 "should be ST_SAT_OK")
            output_quotient = dut.po_quotient.value.signed_integer
            assert output_quotient == exp_quotient, (str(input_numerator) +
                                                     "/" +
                                                     str(input_denominator) +
                                                     " should be " +
                                                     str(exp_quotient) +
                                                     " not " +
                                                     str(output_quotient))

        for _ in range(np.random.randint(0, RANDOM_DELAY)):
            await RisingEdge(dut.pi_clk)
