# create work library
vlib work

# compile project files
vcom -2008 -explicit -work work ../../source/debug_pkg.vhd
vcom -2008 -explicit -work work ../../source/testbench_einfach_schaltung.vhd
vcom -2008 -explicit -work work ../../source/einfach_schaltung.vhd


# run the simulation
vsim -t 1ns -lib work work.testbench_einfach_schaltung
do ../scripts/wave.do
run 30.0 us 

