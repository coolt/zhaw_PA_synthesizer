-------------------------------------------
-- Block code:  modulo_divider.vhd
-- History: 	14.Nov.2012 - 1st version (dqtm)
--                 <date> - <changes>  (<author>)
-- Function: modulo divider with generic width. Output MSB with 50% duty cycle.
--		Can be used for clock-divider when no exact ratio required.
-------------------------------------------

-- Library & Use Statements
-------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


-- Entity Declaration 
-------------------------------------------
ENTITY modulo_divider IS
GENERIC (width		: positive  := 5 );
  PORT( clk	: IN    std_logic;
    	   clk_div     : OUT   std_logic
    	);
END modulo_divider;


-- Architecture Declaration?
-------------------------------------------
ARCHITECTURE rtl OF modulo_divider IS
-- Signals & Constants Declaration?
-------------------------------------------
signal count, next_count: unsigned(width-1 downto 0);	 


-- Begin Architecture
-------------------------------------------
BEGIN

  --------------------------------------------------
  -- PROCESS FOR COMBINATORIAL LOGIC
  --------------------------------------------------
  comb_logic: PROCESS(count)
  BEGIN	
	-- increment	
	next_count <= count + 1 ;
  END PROCESS comb_logic;   
  
  --------------------------------------------------
  -- PROCESS FOR REGISTERS
  --------------------------------------------------
  flip_flops : PROCESS(clk)
  BEGIN	
  	
    IF rising_edge(clk) THEN
		count <= next_count ;
    END IF;
  END PROCESS flip_flops;		
  
  
  --------------------------------------------------
  -- CONCURRENT ASSIGNMENTS
  --------------------------------------------------
  -- take MSB and convert for output data-type
  clk_div <= std_logic(count(width-1));
  
  
 -- End Architecture 
------------------------------------------- 
END rtl;

