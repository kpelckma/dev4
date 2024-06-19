onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_daq_burst_timestamps/clock
add wave -noupdate /tb_daq_burst_timestamps/areset
add wave -noupdate /tb_daq_burst_timestamps/clock_en
add wave -noupdate /tb_daq_burst_timestamps/daq_enable
add wave -noupdate /tb_daq_burst_timestamps/daq_enable_q
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/data
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/data_q
add wave -noupdate /tb_daq_burst_timestamps/strobe
add wave -noupdate /tb_daq_burst_timestamps/strobe_q
add wave -noupdate /tb_daq_burst_timestamps/buffer_start
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/trg_divcnt
add wave -noupdate /tb_daq_burst_timestamps/trg
add wave -noupdate /tb_daq_burst_timestamps/trg_q
add wave -noupdate /tb_daq_burst_timestamps/trigger_rdy
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/trigger_time
add wave -noupdate /tb_daq_burst_timestamps/start_rdy
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/start_time
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/time_tb
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/trigger_time_tb
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/strobe_div
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/strobe_trigger_cnt
add wave -noupdate /tb_daq_burst_timestamps/fifo_status
add wave -noupdate /tb_daq_burst_timestamps/data_out
add wave -noupdate /tb_daq_burst_timestamps/strobe_out
add wave -noupdate /tb_daq_burst_timestamps/addr_out
add wave -noupdate /tb_daq_burst_timestamps/addr_strobe_out
add wave -noupdate /tb_daq_burst_timestamps/buff_in_use
add wave -noupdate /tb_daq_burst_timestamps/dub_buf_ena
add wave -noupdate /tb_daq_burst_timestamps/wlast
add wave -noupdate /tb_daq_burst_timestamps/read_active
add wave -noupdate /tb_daq_burst_timestamps/read_buffer
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/read_time
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/read_duration
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/C_READ_TIME_MAX
add wave -noupdate -divider {burst generator}
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/INST_BURST_GENERATOR/C_BURSTS_PER_BUF
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/SIG_STATE
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/INST_BURST_GENERATOR/SIG_SAMPLE_CNT
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/SIG_FIRST_SAMPLE_DONE
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/SIG_BUF_START
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/INST_BURST_GENERATOR/SIG_BURST_CNT
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/SIG_TRANSACTION_BEGIN
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/SIG_TRANSACTION_END
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/SIG_BUF_IN_USE
add wave -noupdate -radix hexadecimal /tb_daq_burst_timestamps/INST_BURST_GENERATOR/SIG_START_ADDR
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/INST_BURST_GENERATOR/P_O_DATA
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/P_O_DATA_STR
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/P_O_ADDR
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/P_O_ADDR_STR
add wave -noupdate /tb_daq_burst_timestamps/INST_BURST_GENERATOR/P_O_WLAST
add wave -noupdate -divider daq_timestamps
add wave -noupdate /tb_daq_burst_timestamps/ins_daq_timestamps/pi_data_str
add wave -noupdate /tb_daq_burst_timestamps/ins_daq_timestamps/pi_buf_start
add wave -noupdate /tb_daq_burst_timestamps/ins_daq_timestamps/pi_trg
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_daq_timestamps/time_cnt
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_daq_timestamps/sample_time
add wave -noupdate /tb_daq_burst_timestamps/ins_daq_timestamps/start_rdy
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_daq_timestamps/start_time
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_daq_timestamps/offset_time
add wave -noupdate /tb_daq_burst_timestamps/ins_daq_timestamps/trigger_rdy
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_daq_timestamps/trigger_time
add wave -noupdate -divider timestamps_to_mem
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/pi_buf_start
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/pi_buf_in_use
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/pi_start_rdy
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/pi_trigger_rdy
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/start_time_q
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/trg_cnt_q
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/w_sel
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/start_time_h
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/start_time_l
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_fifo_in
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_time_out
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_pos_out
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_buf_num_out
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_rd_ena
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_rd_ena_and
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_wr_ena
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_wr_ena_and
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_fifo_full
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/trigger_fifo_empty
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/po_en
add wave -noupdate /tb_daq_burst_timestamps/ins_timestamps_to_mem/addr_out_base
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/addr_out_offset
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/po_addr
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/po_data
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/po_trg_cnt_buf0
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/ins_timestamps_to_mem/po_trg_cnt_buf1
add wave -noupdate /tb_daq_burst_timestamps/SIG_DAQ_MEM_II_DATA
add wave -noupdate /tb_daq_burst_timestamps/SIG_LOC_MEM_WEN
add wave -noupdate -radix unsigned /tb_daq_burst_timestamps/SIG_LOC_MEM_WDATA
add wave -noupdate /tb_daq_burst_timestamps/SIG_LOC_MEM_POS
add wave -noupdate -divider timestamp_ram
add wave -noupdate -childformat {{/tb_daq_burst_timestamps/INST_TIMESTAMP_RAM/ram_data(254) -radix unsigned}} -subitemconfig {/tb_daq_burst_timestamps/INST_TIMESTAMP_RAM/ram_data(254) {-height 17 -radix unsigned}} /tb_daq_burst_timestamps/INST_TIMESTAMP_RAM/ram_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {264 ns} 0} {{Cursor 2} {8258730 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 530
configure wave -valuecolwidth 174
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {21 ns} {281 ns}
