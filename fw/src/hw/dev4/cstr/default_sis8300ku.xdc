# ------------------------------------------------------------------------------
# --          ____  _____________  __                                         --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _               --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \              --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=            --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/              --
# --                                                                          --
# ------------------------------------------------------------------------------
# --! @copyright Copyright 2021 DESY
# --! SPDX-License-Identifier: CERN-OHL-W-2.0
# ------------------------------------------------------------------------------
# --! @date 2021-09-16
# --! @author Cagil Gumus  <cagil.guemues@desy.de>
# ------------------------------------------------------------------------------
# --! @brief
# --! Application Constraints for the app_example
# ------------------------------------------------------------------------------
#

#-----------------------------------------------------------------------------
#! RTM constraints IOSTANDARD definitions
#-----------------------------------------------------------------------------
set_property IOSTANDARD LVCMOS18 [get_ports {pio_rtm_io_n[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {pio_rtm_io_p[3]}]

# Bank 66 1.8V
set_property IOSTANDARD LVDS [get_ports {pio_rtm_io_n[4]}]
set_property IOSTANDARD LVDS [get_ports {pio_rtm_io_p[4]}]

# DAQ timing exceptions
set_false_path -to [get_pins {ins_payload/ins_app_top/blk_daq.inst_daq_top/areset_v_reg[*]/PRE}]
#set_false_path -to [get_pins -hierarchical -filter { NAME =~ "ins_payload/INST_APP_TOP/BLK_DAQ.INST_DAQ_TOP/BLK_DAQ_TO_AXI.GEN_DAQ_MUX_BURST*.ins_axi_interfacor/ins_*_fifo*/RST" && DIRECTION == "IN" && PARENT_CELL =~  "*FIFO*" }]
set_false_path -from [get_pins {ins_payload/ins_app_top/blk_daq.inst_daq_top/BLK_DAQ_TO_AXI.GEN_DAQ_MUX_BURST[*].ins_daq_to_axi/gen_burst_len0.sent_burst_cnt_reg[*]/C}] -to [get_pins {ins_payload/ins_app_top/blk_daq.inst_daq_top/BLK_DAQ_TO_AXI.GEN_DAQ_MUX_BURST[*].ins_daq_to_axi/po_sent_burst_cnt_reg[*]/D}]


