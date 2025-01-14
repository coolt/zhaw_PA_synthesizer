# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: MIDI_Interface.tcl
# Generated on: Tue Feb 11 14:23:49 2014

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "MIDI_Interface"]} {
		puts "Project MIDI_Interface is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists MIDI_Interface]} {
		project_open -revision MIDI_Interface MIDI_Interface
	} else {
		project_new -revision MIDI_Interface MIDI_Interface
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone IV E"
	set_global_assignment -name DEVICE EP4CE115F29C7
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION "13.0 SP1"
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "08:32:41  FEBRUAR 11, 2014"
	set_global_assignment -name LAST_QUARTUS_VERSION "13.0 SP1"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
	set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name VHDL_FILE ../source/IO/IO.vhd
	set_global_assignment -name VHDL_FILE ../source/Note_to_Parallel/Note_to_Parallel.vhd
	set_global_assignment -name VHDL_FILE ../source/MIDI_Decoder/MIDI_Decoder.vhd
	set_global_assignment -name VHDL_FILE ../source/UART/UART_RX.vhd
	set_global_assignment -name VHDL_FILE ../source/UART/Tick_Generator.vhd
	set_global_assignment -name VHDL_FILE ../source/UART/Flanken_Det.vhd
	set_global_assignment -name VHDL_FILE ../source/UART/Abtaster.vhd
	set_global_assignment -name VHDL_FILE ../source/MIDI_Interface_top.vhd
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "2.5 V"
	set_location_assignment PIN_AE25 -to serial_in
	set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to serial_in
	set_location_assignment PIN_M23 -to button_n
	set_location_assignment PIN_Y3 -to clk
	set_location_assignment PIN_G19 -to parallelNote[0]
	set_location_assignment PIN_F19 -to parallelNote[1]
	set_location_assignment PIN_E19 -to parallelNote[2]
	set_location_assignment PIN_F18 -to parallelNote[4]
	set_location_assignment PIN_E18 -to parallelNote[5]
	set_location_assignment PIN_F21 -to parallelNote[3]
	set_location_assignment PIN_J19 -to parallelNote[6]
	set_location_assignment PIN_H19 -to parallelNote[7]
	set_location_assignment PIN_J17 -to parallelNote[8]
	set_location_assignment PIN_G17 -to parallelNote[9]
	set_location_assignment PIN_J15 -to parallelNote[10]
	set_location_assignment PIN_H16 -to parallelNote[11]
	set_location_assignment PIN_J16 -to parallelNote[12]
	set_location_assignment PIN_H17 -to parallelNote[13]
	set_location_assignment PIN_F15 -to parallelNote[14]
	set_location_assignment PIN_G15 -to parallelNote[15]
	set_location_assignment PIN_G16 -to parallelNote[16]
	set_location_assignment PIN_H15 -to parallelNote[17]
	set_location_assignment PIN_E21 -to parallelNote[18]
	set_location_assignment PIN_E22 -to parallelNote[19]
	set_location_assignment PIN_E25 -to parallelNote[20]
	set_location_assignment PIN_E24 -to parallelNote[21]
	set_location_assignment PIN_H21 -to parallelNote[22]
	set_location_assignment PIN_G20 -to parallelNote[23]
	set_location_assignment PIN_G22 -to parallelNote[24]
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
