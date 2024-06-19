'''
    Test of the CIC filter decimator with
    R=100
    N=2
    M=2
'''

import numpy as np
#import matplotlib.pyplot as plt

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge

R = 100
N = 2
M = 2
TRACE_LEN = 100000
DATA_LENGTH = 24
RANGE_AMPLITUDE = 2**(DATA_LENGTH)
PERIOD1 = 4.4
PERIOD2 = 10.3
PERIOD3 = 32.1
AMPLITUDE1 = RANGE_AMPLITUDE*0.05
AMPLITUDE2 = RANGE_AMPLITUDE*0.05
AMPLITUDE3 = RANGE_AMPLITUDE*0.04
NOISE_LEVEL = RANGE_AMPLITUDE*0.1
RANDOM_JITTER = 5
RESET_DURATION = 3
ERROR_SKIP_FIRST = 100
STD_MAX_ERROR = 0.2

@cocotb.test()
async def test_decimation(dut):
    """
        Test decimation
    """

    cic_gain = np.power(R * M,N)
    dut._log.info("CIC gain: " + str(cic_gain))

    bit_increase = np.ceil(np.log2(cic_gain))
    dut._log.info("Bit increase: " + str(bit_increase))

    gain_correction = 2**bit_increase / cic_gain
    dut._log.info("Gain correction: " + str(gain_correction))

    trace_x = np.linspace(0.0, 1.0, TRACE_LEN)
    trace_y_orig = np.zeros(TRACE_LEN)
    trace_y_orig += np.sin(2.0 * np.pi * trace_x * PERIOD1) * AMPLITUDE1
    trace_y_orig += np.sin(2.0 * np.pi * trace_x * PERIOD2) * AMPLITUDE2
    trace_y_orig += np.sin(2.0 * np.pi * trace_x * PERIOD3) * AMPLITUDE3

    trace_noise = (np.random.random(TRACE_LEN) * 2 - 1) * NOISE_LEVEL
    trace_y_input = trace_y_orig + trace_noise

    trace_x_decim = np.linspace(0.0, 1.0, int(TRACE_LEN/R))
    trace_y_decim = np.interp(trace_x_decim, trace_x, trace_y_orig)
    trace_y_cic = np.zeros(int(TRACE_LEN/R))
    trace_y_cic_idx = 0

    clock = Clock(dut.pi_clk, 10, units="us")
    cocotb.start_soon(clock.start())

    dut.pi_rst.value = 1
    dut.pi_stb.value = 0

    for _ in range(RESET_DURATION):
        await FallingEdge(dut.pi_clk)

    dut.pi_rst.value = 0

    for _ in range(RESET_DURATION):
        await FallingEdge(dut.pi_clk)
        assert dut.po_vld.value == 0, "po_vld should be '0'"

    dut._log.info("Trace input length " + str(len(trace_y_input)))

    for sample_y in trace_y_input:
        for _ in range(np.random.randint(1, RANDOM_JITTER)):
            await FallingEdge(dut.pi_clk)
            dut.pi_stb.value = 0
            if dut.po_vld.value == 1:
                y_cic = float(dut.po_data.value.signed_integer)
                trace_y_cic[trace_y_cic_idx] = y_cic
                trace_y_cic_idx += 1

        dut.pi_stb.value = 1
        dut.pi_data.value = int(sample_y)

    trace_y_cic *= gain_correction

    error_trace = (trace_y_cic[ERROR_SKIP_FIRST:trace_y_cic_idx] -
                   trace_y_decim[ERROR_SKIP_FIRST:trace_y_cic_idx])

    cic_error_max = np.max(np.abs(error_trace)) / NOISE_LEVEL
    cic_error_std = np.std(error_trace) / NOISE_LEVEL
    dut._log.info("CIC max error MAX: " + str(cic_error_max))
    dut._log.info("CIC max error STD: " + str(cic_error_std))

    assert cic_error_std < STD_MAX_ERROR, ("CIC standard error " +
                                           str(cic_error_max) +
                                           + " over " +
                                           str(STD_MAX_ERROR))

    #plt.figure()
    #plt.title("CIC filtering result")
    #plt.plot(trace_x, trace_y_input, label="Noisy input signal")
    #plt.plot(trace_x, trace_y_orig, label="Denoised input signal")
    #plt.plot(trace_x_decim, trace_y_decim, label="Decimated input signal")
    #plt.plot(trace_x_decim[:trace_y_cic_idx],
    #         trace_y_cic[:trace_y_cic_idx], label="CIC output")

    #plt.legend()

    #plt.figure()
    #plt.title("CIC error result")
    #plt.plot(trace_x_decim[ERROR_SKIP_FIRST:trace_y_cic_idx], error_trace)
    #plt.show()
