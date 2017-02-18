library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

entity template_camera_programmer is
port
(
	pixel_valid : in std_logic;
	pixel_in		: in pixel;
	
	prog_enable	: in std_logic;
	
	prog_valid	: out std_logic;
	prog_row		: out natural range 0 to TEMPLATE_SIZE - 1;
	prog_col		: out natural range 0 to TEMPLATE_SIZE - 1;
	prog_pixel	: out pixel;
	
	clk 			: in std_logic;
	reset 		: in std_logic
);
end template_camera_programmer;

architecture template_camera_programmer_arch of template_camera_programmer is
	type state_type is (IDLE, WAIT_NEW_IMAGE, PROG_TEMPLATE);
begin

	process(clk)
		variable last_prog_enable : std_logic;
		variable state : state_type := IDLE;
		variable image_row : natural range 0 to IMG_HEIGHT - 1 	:= 0;
		variable image_col : natural range 0 to IMG_WIDTH - 1 	:= 0;
		variable template_row : natural;
		variable template_col : natural;
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
			
				-- reset inner state
				state := IDLE;
				image_row := 0;
				image_col := 0;
				last_prog_enable := '1';
				
				-- reset outputs
				prog_valid <= '0';
				prog_row <= 0;
				prog_col <= 0;
				prog_pixel <= (others => '0');
			else
			
				prog_valid <= '0';
				
				case state is
					when IDLE =>
						if (prog_enable = '1' and last_prog_enable = '0') then
							state := WAIT_NEW_IMAGE;
						end if;
						
					when WAIT_NEW_IMAGE =>
						if (image_row = 0 and image_col = 0) then
							state := PROG_TEMPLATE;
						end if;
					
					when PROG_TEMPLATE =>
					
						if ( pixel_valid = '1') then
							if (	image_row >= DEFAULT_CAMERA_PROGRAMMING_ROW and 
								image_row < DEFAULT_CAMERA_PROGRAMMING_ROW + TEMPLATE_SIZE and
								image_col >= DEFAULT_CAMERA_PROGRAMMING_COL and 
								image_col < DEFAULT_CAMERA_PROGRAMMING_COL + TEMPLATE_SIZE
							) then
							
								template_row := image_row - DEFAULT_CAMERA_PROGRAMMING_ROW;
								template_col := image_col - DEFAULT_CAMERA_PROGRAMMING_COL;
								
								prog_valid <= '1';
								prog_row <= template_row;
								prog_col <= template_col;
								prog_pixel <= pixel_in;
								
							end if;
							
						if (image_row = IMG_HEIGHT - 1 and image_col = IMG_WIDTH - 1) then
							state := IDLE;
						end if;
							
						end if;

						

					
				end case;
				
				if (pixel_valid = '1') then
					-- Update row and col when pixel valid
					image_col := (image_col + 1) mod IMG_WIDTH;
					if (image_col = 0) then
						image_row := (image_row + 1) mod IMG_HEIGHT;
					end if;
				end if;
				
				last_prog_enable := prog_enable;
				
			end if; -- reset
		end if; -- clk
	end process;
end architecture;