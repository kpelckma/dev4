# -------------------------------------------------------------------------------
# --          ____  _____________  __                                          --
# --         / __ \/ ____/ ___/\ \/ /                 _   _   _                --
# --        / / / / __/  \__ \  \  /                 / \ / \ / \               --
# --       / /_/ / /___ ___/ /  / /               = ( M | S | K )=             --
# --      /_____/_____//____/  /_/                   \_/ \_/ \_/               --
# --                                                                           --
# -------------------------------------------------------------------------------
# -- Copyright (c) 2020 DESY
# -------------------------------------------------------------------------------
# --! @brief   template for the version package for a particular module
# --! @created 2020-01-30
# -------------------------------------------------------------------------------
# --! Description:
# --! This template is used by fwk to inject Version and Timestamp information
# --! in to the module's register map
# -------------------------------------------------------------------------------

puts "\n# Generating  PCIe Endpoint IP core..."

set pcie3_ep_ip_config [ concat \
  CONFIG.pcie_blk_locn {X0Y1} \
  CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X4} \
  CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {5.0_GT/s} \
  CONFIG.pf0_dev_cap_max_payload {256_bytes} \
  CONFIG.pf0_base_class_menu {Data_acquisition_and_signal_processing_controllers} \
  CONFIG.pf0_sub_class_interface_menu {Other_data_acquisition/signal_processing_controllers} \
  CONFIG.pf0_bar0_scale {Megabytes} \
  CONFIG.pf0_bar0_size {16} \
  CONFIG.pf0_bar1_enabled {true} \
  CONFIG.pf0_bar1_scale {Megabytes} \
  CONFIG.pf0_bar1_size {16} \
  CONFIG.pf0_bar2_enabled {true} \
  CONFIG.pf0_bar2_size {16} \
  CONFIG.mode_selection {Advanced} \
  CONFIG.gtwiz_in_core {1} \
  CONFIG.en_pl_ifc {false} \
  CONFIG.Shared_Logic {1} \
  CONFIG.select_quad {GTH_Quad_227} \
  CONFIG.gen_x0y0 {false} \
  CONFIG.gen_x0y1 {true} \
  CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X4} \
  CONFIG.axisten_if_width {64_bit} \
  CONFIG.PF0_DEVICE_ID {0037} \
  CONFIG.pf0_class_code_base {11} \
  CONFIG.pf0_class_code_sub {80} \
  CONFIG.PF0_CLASS_CODE {118000} \
  CONFIG.PF1_DEVICE_ID {8011} \
  CONFIG.pf0_bar0_size {16} \
  CONFIG.pf0_bar1_type {Memory} \
  CONFIG.pf0_bar2_type {Memory} \
  CONFIG.PF0_MSIX_CAP_TABLE_BIR {BAR_0} \
  CONFIG.PF0_MSIX_CAP_PBA_BIR {BAR_0} \
  CONFIG.PF1_MSIX_CAP_TABLE_BIR {BAR_0} \
  CONFIG.PF1_MSIX_CAP_PBA_BIR {BAR_0} \
  CONFIG.axisten_freq {250} \
  CONFIG.aspm_support {No_ASPM} \
  CONFIG.dedicate_perst {false} \
  CONFIG.mcap_enablement {None} \
  CONFIG.coreclk_freq {250} \
  CONFIG.plltype {QPLL1}\
]


create_ip -name pcie3_ultrascale -vendor xilinx.com -library ip  -module_name pcie3_ultrascale_0
set_property -dict $pcie3_ep_ip_config [get_ips pcie3_ultrascale_0]
