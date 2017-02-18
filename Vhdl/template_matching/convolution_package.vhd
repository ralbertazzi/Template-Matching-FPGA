library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;

package convolution_package is

	constant COMPUTATION_STEPS : natural := 8;	-- numero di intervalli elementari di clock usati
																-- nel template matching e trasferimento window
																
	constant TEMPLATE_SIZE : natural := 32; 		-- dimensione del lato del template (quadrato)
	
	subtype window_column is std_logic_vector((PIXEL_WIDTH * TEMPLATE_SIZE - 1) downto 0);
	type window_type is array(natural range 0 to TEMPLATE_SIZE - 1) of window_column;
	
	type window_packet is array(0 to (TEMPLATE_SIZE / COMPUTATION_STEPS - 1)) of window_column;
	
	constant SCORE_MAX : natural := (2**PIXEL_WIDTH - 1) * TEMPLATE_SIZE * TEMPLATE_SIZE;
	
	constant SCORE_WIDTH : natural := 18; -- 16 per 16, 18 per 32, 20 per 64
	
	subtype score_type is natural range 0 to 2**SCORE_WIDTH - 1;
	subtype score_type_vector is std_logic_vector(SCORE_WIDTH - 1 downto 0);
	
	constant TEMPLATE_MATCHING_MODULES_WIDTH : natural := 2;
	constant TEMPLATE_MATCHING_MODULES : natural := 4;
	
	-- Non posso usare score_type (che è un natural) altrimenti quartus mi dice che non
	-- riesce a generare il symbol per una porta così complicata..
	type template_matching_score_array is array(0 to TEMPLATE_MATCHING_MODULES - 1) of score_type_vector;
	
	constant DEFAULT_CAMERA_PROGRAMMING_ROW  	: natural := (IMG_HEIGHT - TEMPLATE_SIZE) / 2 - TEMPLATE_SIZE; -- sottraggo TEMPLATE_SIZE per evitare il punto sporco sulla camera
	constant DEFAULT_CAMERA_PROGRAMMING_COL 	: natural := (IMG_WIDTH - TEMPLATE_SIZE) / 2;
	
end package convolution_package;