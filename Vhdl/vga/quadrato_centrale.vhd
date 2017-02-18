library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

entity quadrato_centrale is
port
(
	template_matching_found : in std_logic;
	template_matching_row   : in natural range 0 to IMG_HEIGHT - 1;
	template_matching_col	: in natural range 0 to IMG_WIDTH - 1;
	
	center						: in std_logic;
	
	draw							: out std_logic;
	draw_row						: out natural range 0 to IMG_HEIGHT - 1;
	draw_col						: out natural range 0 to IMG_WIDTH - 1
);
end quadrato_centrale;

architecture quadrato_centrale_arch of quadrato_centrale is
begin

	draw <= template_matching_found or center;
	draw_row <= template_matching_row when center = '0' else DEFAULT_CAMERA_PROGRAMMING_ROW;
	draw_col <= template_matching_col when center = '0' else DEFAULT_CAMERA_PROGRAMMING_COL;
	
end architecture;