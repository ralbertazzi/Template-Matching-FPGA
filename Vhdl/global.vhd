library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package global is

	constant IMG_HEIGHT : natural := 480;
	constant IMG_WIDTH  : natural := 640;
	
	-- bit per ogni pixel
	constant PIXEL_WIDTH : natural := 8;    		
	subtype pixel is std_logic_vector(PIXEL_WIDTH - 1 downto 0);
	
	subtype pixel_int is integer range 0 to 2**PIXEL_WIDTH - 1;
	
end package global;