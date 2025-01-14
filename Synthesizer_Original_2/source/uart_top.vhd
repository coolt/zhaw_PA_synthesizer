-------------------------------------------
-- uart top
-------------------------------------------
-- copyright: weii (1. version)
-- commented: baek (2. version)
--
-- function:
-- changes serial midibit to parallel data
----------------------------------------------------------------------

LIBRARY		ieee;
USE			ieee.std_logic_1164.all;
USE			ieee.numeric_std.all;

ENTITY uart_top IS
	PORT(	serial_in, clk_12M5, reset_n		: IN std_logic;
			rx_data							: OUT std_logic_vector(7 DOWNTO 0);
			rx_data_valid					: OUT std_logic);
END uart_top;

ARCHITECTURE behav OF uart_top IS
	COMPONENT read_midi
		PORT(	clk_12M5, reset_n, bit_tick: IN  std_logic;
				data_start					: IN  std_logic;
				serial_in					: IN  std_logic;
				rx_data_valid				: OUT std_logic;
				rx_data						: OUT std_logic_vector(7 downto 0));
	END COMPONENT;
	
	COMPONENT edge_detector
		PORT (	serial_in,clk_12M5,reset_n	: IN    std_logic;
				edge        				: OUT   std_logic);
	END Component;
	
	COMPONENT bit_sampling_generator
		PORT(	edge, clk_12M5, reset_n		: IN  std_logic;
				bit_tick, data_start		: OUT std_logic);
	END Component;

SIGNAL edge, baude_tick, data_start	:std_logic;

BEGIN
	i_1: edge_detector
		PORT MAP(	clk_12M5 		=> clk_12M5,
					serial_in 	=> serial_in,
					reset_n 	=> reset_n,
					edge		=> edge);
	
	i_2: bit_sampling_generator
		PORT MAP(	edge		=> edge,
					clk_12M5			=> clk_12M5,
					reset_n		=> reset_n,
					bit_tick	=> baude_tick,
					data_start	=> data_start);
	
	i_3: read_midi
		PORT MAP(	clk_12M5				=> clk_12M5,
					reset_n			=> reset_n,
					bit_tick		=> baude_tick,
					serial_in		=> serial_in,
					rx_data_valid	=> rx_data_valid,
					rx_data			=> rx_data,
					data_start		=> data_start);
END behav;
