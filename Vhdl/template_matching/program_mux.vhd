library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

entity programmazione_mux is
port
(
	serial_prog_valid : 	in std_logic;
	serial_prog_index : 	in std_logic_vector(TEMPLATE_MATCHING_MODULES_WIDTH - 1 downto 0);
	serial_prog_row	:	in natural range 0 to TEMPLATE_SIZE - 1;
	serial_prog_col	:	in natural range 0 to TEMPLATE_SIZE - 1;
	serial_prog_pixel	:  in pixel;
	
	camera_prog_valid	: 	in std_logic;
	camera_prog_index	:	in std_logic_vector(TEMPLATE_MATCHING_MODULES_WIDTH - 1 downto 0);
	camera_prog_row	:	in natural range 0 to TEMPLATE_SIZE - 1;
	camera_prog_col	:	in natural range 0 to TEMPLATE_SIZE - 1;
	camera_prog_pixel	:	in pixel;
	
	prog_valid			: 	out std_logic;
	prog_index			:	out std_logic_vector(TEMPLATE_MATCHING_MODULES_WIDTH - 1 downto 0);
	prog_row				:	out natural range 0 to TEMPLATE_SIZE - 1;
	prog_col				:	out natural range 0 to TEMPLATE_SIZE - 1;
	prog_pixel			:	out pixel		
);
end programmazione_mux;

architecture programmazione_mux_arch of programmazione_mux is
begin

	prog_valid <= serial_prog_valid or camera_prog_valid;
	
	prog_index <= serial_prog_index when serial_prog_valid = '1'
			else camera_prog_index;
	
	prog_row <= serial_prog_row when serial_prog_valid = '1'
					else camera_prog_row;
					
	prog_col <= serial_prog_col when serial_prog_valid = '1'
				else camera_prog_col;
				
	prog_pixel <= serial_prog_pixel when serial_prog_valid = '1'
			else camera_prog_pixel;
	
end architecture;