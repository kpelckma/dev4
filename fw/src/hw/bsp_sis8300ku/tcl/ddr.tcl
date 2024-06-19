
puts "\n# Generating MIG IP core..."

set custom_part $::fwfwk::SrcPath/bsp_sis8300ku/misc/custom_parts_ddr4.csv
puts $custom_part

set mig_ip_config [ concat \
CONFIG.C0.DDR4_TimePeriod {1250} \
CONFIG.C0.DDR4_InputClockPeriod {8000} \
CONFIG.C0.DDR4_Specify_MandD {false} \
CONFIG.C0.DDR4_DataWidth {64} \
CONFIG.C0.DDR4_AxiSelection {true} \
CONFIG.C0.DDR4_CasLatency {11} \
CONFIG.C0.DDR4_CasWriteLatency {11} \
CONFIG.C0.DDR4_AxiDataWidth {256} \
CONFIG.C0.DDR4_AxiAddressWidth {31} \
CONFIG.C0.DDR4_AxiArbitrationScheme {ROUND_ROBIN} \
CONFIG.C0.DDR4_AxiIDWidth {8} \
CONFIG.C0.DDR4_CustomParts $custom_part \
CONFIG.C0.DDR4_MemoryPart {H5AN4G6NAFR} \
CONFIG.C0.DDR4_isCustom {true} \
CONFIG.System_Clock {No_Buffer} \
]

puts $mig_ip_config

create_ip -name ddr4 -vendor xilinx.com -library ip -module_name ddr4_0

set_property -dict $mig_ip_config [get_ips ddr4_0]
