--top_level
--copyright by bruelcor
--version 0.1
--15.03.2013 18.22

--version 0.2
--22.03.2013 15.54

--version 0.3
--05.06.2013 20:43 edited by herscmic

--Funktion: Top Level Block, Analog Loop und Digital Loop integriert

-- Bedienung: SW(17) 	= Codeccontroll ein/aus
--			  SW(16) 	= Analog Loop / Digital Loop : Settings fuer den Codeccontroller
--			  SW(15) 	= I2S ein/aus
--			  SW(14) 	= Mode audio_controll ( '0': Signale von Synthesizer,  '1': Digitalloop)
--			  SW(13) 	= '0': Töne per Tastatur, '1': Melodie
--			  SW(12) 	= Melodie: Mozart, kleine Nachtmusik
--			  SW(11) 	= Melodie: Tschaikovsky, Overture 1812
--			  SW(10) 	= Melodie: Beethoven, Für Elise
--			  SW(0-12)	= Töne per Tastatur (eine Oktave) wenn SW(13)='0'
--			  KEY(0) 	= Reset					
--			  KEY(1) 	= FM-Ratio aendern
--			  KEY(2) 	= FM-Depth aendern   -> zu Tonedecoder: "Musik starten". neu = "Keyboard aktivieren"
--			  KEY(3) 	= Melodie abspielen  -> Wurde nicht benutzt! 




LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.note_type_pkg.all;

-- Entity Declaration 
-------------------------------------------
ENTITY top_level IS
	PORT (	CLOCK_50				:IN			std_logic;
			KEY						:IN			std_logic_vector(3 DOWNTO 0);		--Taster
			SW						:IN			std_logic_vector(17 DOWNTO 0);		--Schalter
			AUD_ADCDAT				:IN			std_logic;							--SD vom Coded DA Wandlung
			AUD_DACDAT				:OUT		std_logic;							--SD zum Codec AD Wandlung
			AUD_BCLK				:OUT		std_logic;							--I2S Bit Clock
			AUD_XCK					:OUT		std_logic;							--Master Clock
			AUD_DACLRCK				:OUT		std_logic;
			AUD_ADCLRCK				:OUT		std_logic;							--WS zum Codec bei AD Wandlung
			I2C_SCLK				:OUT		std_logic;
			I2C_SDAT				:INOUT		std_logic;
			LEDG					:OUT 		std_logic_vector(7 DOWNTO 0);		--Led-Leuchten grün
			HEX0, HEX3, HEX2		:OUT 		std_logic_vector (6 DOWNTO 0);		--Siebensegmentanzeigen
			HEX4, HEX5, HEX1		:OUT 		std_logic_vector (6 DOWNTO 0);		--Siebensegmentanzeigen
			GPIO_25:			IN	std_logic
		  );
END top_level;

-- Architecture Declaration
-------------------------------------------
ARCHITECTURE rtl OF top_level IS
-- Signals & Constants Declaration
-------------------------------------------
SIGNAL		tl_write_done:			std_logic;										--Sendebestätigung vom I2C Master
SIGNAL		tl_ack_error:			std_logic;										--Senden fehlgeschlagen von I2C Master
SIGNAL		tl_write:		  		std_logic;
SIGNAL		tl_write_data:			std_logic_vector (15 downto 0);					--I2C Sendedaten
SIGNAL		tl_clk_12M:				std_logic;										--Masterclock 12MHz
SIGNAL		tl_sw_button:			std_logic_vector (17 downto 0);					--synchronisierte Schalter
SIGNAL		tl_key:					std_logic_vector (2 downto 0);					--synchronisierte Taster
SIGNAL		tl_DACDAT_pl:			std_logic_vector (15 downto 0);					
SIGNAL		tl_DACDAT_pr:			std_logic_vector (15 downto 0);				
SIGNAL		tl_ADCDAT_pl:			std_logic_vector (15 downto 0);
SIGNAL		tl_ADCDAT_pr:			std_logic_vector (15 downto 0);
SIGNAL		tl_WS:					std_logic;
SIGNAL 		tl_digiloop:			std_logic;										--Audioschleife über Digitalloop
SIGNAL		t_audio_mode_i:		std_logic;										


SIGNAL		tl_strobe:				std_logic;

SIGNAL 		tl_bclk:				std_logic;												--halbierter 12MHz Takt
SIGNAL		tl_fm_ratio:			natural range 0 to 10;							--Synthesizer Verhältnis						
SIGNAL		tl_fm_depth:			natural range 0 to 10;							--Synthesizer Tiefe

-- midi interface - tone decoder
SIGNAL 		tl_note_0:		std_logic_vector(8 downto 0);	
SIGNAL 		tl_note_1:		std_logic_vector(8 downto 0);
SIGNAL 		tl_note_2:		std_logic_vector(8 downto 0);
SIGNAL 		tl_note_3:		std_logic_vector(8 downto 0);
SIGNAL 		tl_note_4:		std_logic_vector(8 downto 0);
SIGNAL 		tl_note_5:		std_logic_vector(8 downto 0);
SIGNAL 		tl_note_6:		std_logic_vector(8 downto 0);
SIGNAL 		tl_note_7:		std_logic_vector(8 downto 0);
SIGNAL 		tl_note_8:		std_logic_vector(8 downto 0);
SIGNAL 		tl_note_9:		std_logic_vector(8 downto 0);

-- tone decoder -- FM synth (LUT)
SIGNAL		tl_n_cum_0:				natural range 0 to 65000;						--Tonhöhe 
SIGNAL		tl_n_cum_1:				natural range 0 to 65000;						--Tonhöhe 
SIGNAL		tl_n_cum_2:				natural range 0 to 65000;						--Tonhöhe 
SIGNAL		tl_n_cum_3:				natural range 0 to 65000;						--Tonhöhe 
SIGNAL		tl_n_cum_4:				natural range 0 to 65000;						--Tonhöhe 
SIGNAL		tl_n_cum_5:				natural range 0 to 65000;						--Tonhöhe 
SIGNAL		tl_n_cum_6:				natural range 0 to 65000;						--Tonhöhe 
SIGNAL		tl_n_cum_7:				natural range 0 to 65000;						--Tonhöhe 
SIGNAL		tl_n_cum_8:				natural range 0 to 65000;						--Tonhöhe 
SIGNAL		tl_n_cum_9:				natural range 0 to 65000;						--Tonhöhe 

-- tone decoder -- adder 
SIGNAL		tl_tone_on:				std_logic_vector(9 downto 0); 				--fuer fm_synth 

-- FM synth -- adder 
SIGNAL		tl_dacdat_g_0:			std_logic_vector(15 downto 0);
SIGNAL		tl_dacdat_g_1:			std_logic_vector(15 downto 0);
SIGNAL		tl_dacdat_g_2:			std_logic_vector(15 downto 0);
SIGNAL		tl_dacdat_g_3:			std_logic_vector(15 downto 0);
SIGNAL		tl_dacdat_g_4:			std_logic_vector(15 downto 0);
SIGNAL		tl_dacdat_g_5:			std_logic_vector(15 downto 0);
SIGNAL		tl_dacdat_g_6:			std_logic_vector(15 downto 0);
SIGNAL		tl_dacdat_g_7:			std_logic_vector(15 downto 0);
SIGNAL		tl_dacdat_g_8:			std_logic_vector(15 downto 0);
SIGNAL		tl_dacdat_g_9:			std_logic_vector(15 downto 0);

-- adder to audio control
SIGNAL		tl_dacdat:				std_logic_vector(15 downto 0);



--Components Declaration
------------------------------------------
COMPONENT midi_interface 
PORT(   clk_12M5_i:   IN std_logic; 
        reset_n_i:    IN std_logic;
        serial_i:     IN std_logic; 
        note_o: out t_note_array
        );
END COMPONENT;

COMPONENT codeccontroller
	PORT (	clk,reset_n	 			 		:IN      		std_logic;
			write_done_i, ack_error_i   	:IN      		std_logic;
			write_o     					:OUT   			std_logic;
			write_data_o				 	:OUT			std_logic_vector (15 downto 0);
			event_ctrl_i			     	:IN 			std_logic;
			LED_out							:OUT 			std_logic;
			audio_mode_i					:IN 			std_logic
    	  );
END COMPONENT;

COMPONENT i2c_master
	PORT (	clk         				 	:IN    			std_logic;
			reset_n     				 	:IN   			std_logic;
			write_i     				 	:IN     		std_logic;
			write_data_i					:IN				std_logic_vector(15 downto 0);
			sda_io							:INOUT			std_logic;
			scl_o							:OUT   			std_logic;
			write_done_o			    	:OUT			std_logic;
			ack_error_o						:OUT			std_logic
          );
END COMPONENT;

COMPONENT infrastructure_block
	PORT(   s_reset_n						:IN    			std_logic;
			clk_50M          				:IN    			std_logic;
			button							:IN 			std_logic_vector(17 DOWNTO 0);
			key_in							:IN				std_logic_vector(2 DOWNTO 0);
    	    clk_12M                    	 	:OUT   			std_logic;
		    button_sync						:OUT 			std_logic_vector(17 DOWNTO 0);
			key_sync						:OUT			std_logic_vector(2 DOWNTO 0)
			);
END COMPONENT;

COMPONENT i2s_master
	PORT (	clk_12M							:IN				std_logic;
			i2s_reset_n						:IN				std_logic;
			INIT_N_i						:IN				std_logic;	
			ADCDAT_s						:IN				std_logic;
			DACDAT_pl						:IN				std_logic_vector(15 downto 0);
			DACDAT_pr						:IN				std_logic_vector(15 downto 0);
			STROBE_O						:OUT			std_logic;	
			BCLK							:OUT			std_logic;
			DACDAT_s						:OUT			std_logic;
			ADCDAT_pl						:OUT			std_logic_vector(15 downto 0);
			ADCDAT_pr						:OUT			std_logic_vector(15 downto 0);
			WS								:OUT			std_logic
			
		 );					
END COMPONENT;

COMPONENT audio_control
	PORT (	ADCDAT_pl_i						:IN 			std_logic_vector (15 DOWNTO 0);
			ADCDAT_pr_i						:IN 			std_logic_vector (15 DOWNTO 0);
			DACDAT_pl_o						:OUT			std_logic_vector (15 DOWNTO 0);
			DACDAT_pr_o						:OUT			std_logic_vector (15 DOWNTO 0);
			AUDIO_MODE						:IN				std_logic;
			dds_DATA_I						:IN				std_logic_vector (15 DOWNTO 0)
		 );
END COMPONENT;

COMPONENT tone_decoder
	PORT (	clk								:IN				std_logic;	--clk_12M
			reset_n							:IN				std_logic;
			tone_cmd						:IN				std_logic_vector(13 DOWNTO 0);
			tone_on_o						:OUT			std_logic;
			musik_start						:IN				std_logic;
			N_CUM							:OUT 			natural range 0 to 65000;
			notes_keyboard				:IN 			std_logic_vector(8 downto 0)
		);
END COMPONENT;


		
COMPONENT fm_coder_7segment		
PORT(   	clk,reset_n						:IN 	     	std_logic;
			count_i     					:IN 	     	std_logic_vector(1 DOWNTO 0);
			fm_ratio						:OUT	     	natural range 0 to 1000;
			fm_depth		 	 			:OUT	     	natural range 0 to 10;
			hex_1, hex_2, hex_3				:OUT			std_logic_vector(6 DOWNTO 0);			
			hex_4, hex_0, hex_m				:OUT 			std_logic_vector(6 DOWNTO 0)
		);
END COMPONENT;

COMPONENT fm_synth
PORT (	fm_clk_12M						:IN				std_logic;
			fm_reset_n						:IN				std_logic;
			fm_bclk							:IN				std_logic;
			strobe							:IN				std_logic;
			tone_on_i						:IN				std_logic;
			N_CUM								:IN				natural range 0 to 65000;
			synth_ratio						:IN				natural range 0 to 1000;
			synth_depth						:IN				natural range 0 to 10;
			data_o							:OUT			std_logic_vector(15 downto 0)
		  );
END COMPONENT;

COMPONENT adder 
	PORT (clk					: IN std_logic;
			reset_n				: IN std_logic;	
			data_0_i				: IN std_logic_vector(15 downto 0);
			note_0_on_i			: IN std_logic ; 	
			data_1_i				: IN std_logic_vector(15 downto 0);
			note_1_on_i			: IN std_logic ; 
			data_2_i				: IN std_logic_vector(15 downto 0);
			note_2_on_i			: IN std_logic ; 
			data_3_i				: IN std_logic_vector(15 downto 0);
			note_3_on_i			: IN std_logic ; 
			data_4_i				: IN std_logic_vector(15 downto 0);
			note_4_on_i			: IN std_logic ; 
			data_5_i				: IN std_logic_vector(15 downto 0);
			note_5_on_i			: IN std_logic ; 
			data_6_i				: IN std_logic_vector(15 downto 0);
			note_6_on_i			: IN std_logic ; 
			data_7_i				: IN std_logic_vector(15 downto 0);
			note_7_on_i			: IN std_logic ; 
			data_8_i				: IN std_logic_vector(15 downto 0);
			note_8_on_i			: IN std_logic ; 
			data_9_i				: IN std_logic_vector(15 downto 0);
			note_9_on_i			: IN std_logic ; 
			dds_DATA_O			: OUT	std_logic_vector (15 DOWNTO 0)
		  );
END COMPONENT;





-- Begin Architecture
-------------------------------------------
BEGIN

-- Port Maps
-------------------------------------------
i_MIDI_INTERFACE: midi_interface
	PORT MAP(
<<<<<<< HEAD
				clk_12M5_i   		=> tl_clk_12M,
				reset_n_i    		=> KEY(0), -- analog to existing design 
				serial_i     		=> GPIO_10, 
				note_o(0)     		=> tl_note_0,
				note_o(1)    		=> tl_note_1,
				note_o(2)     		=> tl_note_2,
				note_o(3)     		=> tl_note_3,
				note_o(4)     		=> tl_note_4, 
				note_o(5)    		=> tl_note_5,
				note_o(6)    		=> tl_note_6,
				note_o(7)     		=> tl_note_7,
				note_o(8)     		=> tl_note_8, 
				note_o(9)    		=> tl_note_9
				); 
=======
		clk_12M5_i   => tl_clk_12M,
		reset_n_i    => KEY(0), -- analog to existing design 
		serial_i     => GPIO_25, 
		note_o(0)     => tl_note_1,
		note_o(1)    => tl_note_2,
		note_o(2)     => tl_note_3,
		note_o(3)     => tl_note_4,
		note_o(4)     => tl_note_5, 
		note_o(5)     => tl_note_6,
		note_o(6)     => tl_note_7,
		note_o(7)     => tl_note_8,
		note_o(8)     => tl_note_9, 
		note_o(9)    => tl_note_10
		); 




>>>>>>> branch_is_working

CODECCONTROLLER_INST : codeccontroller
	PORT MAP ( write_done_i    => 	tl_write_done,						
				ack_error_i 	   => 	tl_ack_error,
				write_o				=>		tl_write,
				write_data_o	  	=>		tl_write_data,
				event_ctrl_i		=>		tl_sw_button(17),
				clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				LED_out				=>		LEDG(0),
				audio_mode_i		=>		tl_sw_button(16)
			  );
			  
I2C_MASTER_INST : i2c_master
	PORT MAP ( write_i			=>		tl_write,							
				write_data_i		=>		tl_write_data,
				sda_io				=>		I2C_SDAT,
				scl_o			    	=>		I2C_SCLK,
				write_done_o		=>		tl_write_done,
				ack_error_o			=>		tl_ack_error,
				clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0)
			   );
			  
INFRASTRUCTURE_BLOCK_INST : infrastructure_block						
	PORT MAP ( s_reset_n			=> 		KEY(0),
				clk_50M				=>		CLOCK_50,
				button				=>		SW,
				key_in				=>		KEY(2 DOWNTO 0),
				clk_12M				=>		tl_clk_12M,
				button_sync			=>		tl_sw_button,
				key_sync				=>		tl_key
				);

I2S_MASTER_INST : i2s_master
	PORT MAP (clk_12M				=>		tl_clk_12M,
				i2s_reset_n			=>		KEY(0),
				INIT_N_i				=>		tl_sw_button(15),
				ADCDAT_s				=>		AUD_ADCDAT,
				DACDAT_pl			=>		tl_DACDAT_pl,
				DACDAT_pr			=>		tl_DACDAT_pr,
				STROBE_O				=> 	tl_strobe,
				BCLK					=>		tl_bclk,
				DACDAT_s				=>		AUD_DACDAT,
				ADCDAT_pl			=>		tl_ADCDAT_pl,
				ADCDAT_pr			=>		tl_ADCDAT_pr,
				WS						=>		tl_WS
				);
				
AUDIO_CONTROL_INST : audio_control
	PORT MAP (ADCDAT_pl_i		=>		tl_ADCDAT_pl,
				ADCDAT_pr_i			=>		tl_ADCDAT_pr,
				DACDAT_pl_o			=>		tl_DACDAT_pl,
				DACDAT_pr_o			=>		tl_DACDAT_pr,
				AUDIO_MODE			=>		tl_sw_button(14),
				dds_DATA_I			=>		tl_dacdat		
				);

TONE_DECODER_INST_0: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(0),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_0,				
				notes_keyboard    => 	tl_note_0	
		);

TONE_DECODER_INST_1: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(1),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_1,				
				notes_keyboard    => 	tl_note_1	
		);
		
TONE_DECODER_INST_2: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(2),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_2,				
				notes_keyboard    => 	tl_note_2	
		);
		
TONE_DECODER_INST_3: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(3),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_3,				
				notes_keyboard    => 	tl_note_3	
		);
		
TONE_DECODER_INST_4: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(4),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_4,				
				notes_keyboard    => 	tl_note_4	
		);
		
TONE_DECODER_INST_5: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(5),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_5,				
				notes_keyboard    => 	tl_note_5	
		);

TONE_DECODER_INST_6: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(6),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_6,				
				notes_keyboard    => 	tl_note_6	
		);
		
TONE_DECODER_INST_7: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(7),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_7,				
				notes_keyboard    => 	tl_note_7	
		);
		
TONE_DECODER_INST_8: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(8),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_8,				
				notes_keyboard    => 	tl_note_8	
		);
		
TONE_DECODER_INST_9: tone_decoder
	PORT MAP( clk					=>		tl_clk_12M,
				reset_n				=>		KEY(0),
				tone_cmd				=>		tl_sw_button(13 DOWNTO 0),
				tone_on_o			=>		tl_tone_on(9),
				musik_start			=>		tl_key(2),            				
				N_CUM					=>		tl_n_cum_9,				
				notes_keyboard    => 	tl_note_9	
		);

FM_SYNTH_INST_0: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(0),
				N_CUM					=> 		tl_n_cum_0,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_0
		  );
		  
FM_SYNTH_INST_1: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(1),
				N_CUM					=> 		tl_n_cum_1,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_1
		  );
		  
FM_SYNTH_INST_2: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(2),
				N_CUM					=> 		tl_n_cum_2,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_2
		  );

FM_SYNTH_INST_3: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(3),
				N_CUM					=> 		tl_n_cum_3,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_3
		  );
		  
FM_SYNTH_INST_4: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(4),
				N_CUM					=> 		tl_n_cum_4,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_4
		  );
		
FM_SYNTH_INST_5: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(5),
				N_CUM					=> 		tl_n_cum_5,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_5
		  );
		  
FM_SYNTH_INST_6: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(6),
				N_CUM					=> 		tl_n_cum_6,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_6
		  );

FM_SYNTH_INST_7: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(7),
				N_CUM					=> 		tl_n_cum_7,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_7
		  );
		  
FM_SYNTH_INST_8: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(8),
				N_CUM					=> 		tl_n_cum_8,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_8
		  );
	
FM_SYNTH_INST_9: fm_synth
	PORT MAP(fm_clk_12M	 		=> 		tl_clk_12M,	
				fm_reset_n			=> 		KEY(0),		
				fm_bclk				=> 		tl_bclk,
				strobe				=> 		tl_strobe, 
				tone_on_i			=> 		tl_tone_on(9),
				N_CUM					=> 		tl_n_cum_9,
				synth_ratio			=> 		tl_fm_ratio,
				synth_depth			=> 		tl_fm_depth,
				data_o				=> 		tl_dacdat_g_9
		  );
		  
SIGNAL_ADDER: adder 
	PORT MAP (clk					=> 		tl_clk_12M,
			reset_n					=> 		KEY(0),	
			data_0_i					=> 		tl_dacdat_g_0,
			note_0_on_i				=> 		tl_tone_on(0),	
			data_1_i					=> 		tl_dacdat_g_1,
			note_1_on_i				=> 		tl_tone_on(1),
			data_2_i					=> 		tl_dacdat_g_2,
			note_2_on_i				=> 		tl_tone_on(2),
			data_3_i					=> 		tl_dacdat_g_3,
			note_3_on_i				=> 		tl_tone_on(3),
			data_4_i					=> 		tl_dacdat_g_4,
			note_4_on_i				=> 		tl_tone_on(4),
			data_5_i					=> 		tl_dacdat_g_5,
			note_5_on_i				=> 		tl_tone_on(5),
			data_6_i					=> 		tl_dacdat_g_6,
			note_6_on_i				=> 		tl_tone_on(6),
			data_7_i					=> 		tl_dacdat_g_7,
			note_7_on_i				=> 		tl_tone_on(7),
			data_8_i					=> 		tl_dacdat_g_8,
			note_8_on_i				=> 		tl_tone_on(8),
			data_9_i					=> 		tl_dacdat_g_9,
			note_9_on_i				=> 		tl_tone_on(9),
			dds_DATA_O				=>			tl_dacdat
		  );


FM_CODER_7SEGMENT_INST: fm_coder_7segment
	PORT MAP ( clk					=> 		tl_clk_12M,
				reset_n				=> 		KEY(0),					
				count_i  			=> 		tl_key (1 DOWNTO 0),				
				fm_ratio				=> 		tl_fm_ratio,				
				fm_depth				=> 		tl_fm_depth, 	 				
				hex_1					=> 		HEX3,
				hex_2					=> 		HEX2,
				hex_3					=> 		HEX5, 
				hex_4					=> 		HEX4, 
				hex_0					=> 		HEX0,
				hex_m					=>			HEX1
		);			  

		
--Ausgangs/Eingangsignal--TL-Signalverbindung	
AUD_ADCLRCK <= 	tl_WS;
AUD_DACLRCK	<= 	tl_WS;
AUD_XCK		<=	tl_clk_12M;
AUD_BCLK	<=	tl_bclk;

	
-- End Architecture
-----------------------------------------			  
END ARCHITECTURE rtl;