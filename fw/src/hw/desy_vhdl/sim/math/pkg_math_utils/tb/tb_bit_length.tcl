set designLibrary {}
set desy {}

set topLevel "tb_bit_length"

lappend designLibrary "tb_bit_length.vhd"
lappend desy "../../../../hdl/math/pkg_math_utils.vhd"

vlib desy

foreach file $desy {
  vcom -93 -work desy $file
}

foreach file $designLibrary {
  vcom -93 $file
}

eval vsim -voptargs="+acc" work.$topLevel

add wave /*

run -all
