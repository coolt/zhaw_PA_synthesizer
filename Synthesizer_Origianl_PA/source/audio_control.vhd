--audio_control
--copyright by herscmic
--version 0.1
--05.04.2013

--Funktion: Verbindet momentan nur die Links und rechts Vektoren wenn AUDIO_MODE=1

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


-- Entity Declaration 
-------------------------------------------
ENTITY audio_control IS
	PORT ( 	ADCDAT_pl_i			:IN 	std_logic_vector (15 DOWNTO 0);
			ADCDAT_pr_i			:IN 	std_logic_vector (15 DOWNTO 0);
			DACDAT_pl_o			:OUT	std_logic_vector (15 DOWNTO 0);
			DACDAT_pr_o			:OUT	std_logic_vector (15 DOWNTO 0);
			AUDIO_MODE			:IN		std_logic;
			dds_DATA_I			:IN		std_logic_vector (15 DOWNTO 0)
			
		  );
END audio_control;

-- Architecture Declaration
-------------------------------------------
ARCHITECTURE rtl OF audio_control IS
-- Signals & Constants Declaration
-------------------------------------------

BEGIN
verbindung: PROCESS( ADCDAT_pl_i, ADCDAT_pr_i, AUDIO_MODE, dds_DATA_I)

BEGIN 
	IF AUDIO_MODE='1' THEN
		DACDAT_pl_o <= ADCDAT_pl_i;
		DACDAT_pr_o <= ADCDAT_pr_i;
	ELSE 
		DACDAT_pl_o <= dds_DATA_I;
		DACDAT_pr_o <= dds_DATA_I;
	END IF;
END PROCESS verbindung;	
		

--Components Declaration
------------------------------------------
END ARCHITECTURE rtl;