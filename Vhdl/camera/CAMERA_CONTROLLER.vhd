library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.global.all;

ENTITY CAMERA_CONTROLLER IS
PORT(
		VSYNC	: IN STD_LOGIC;
		HREF	: IN STD_LOGIC;
		D_IN	: IN STD_LOGIC_VECTOR(7 downto 0);		
		D_OUT	: OUT	STD_LOGIC_VECTOR(7 downto 0);
		D_VALID	: OUT STD_LOGIC;
		CORRECT	: OUT STD_LOGIC;
		-- CLK and RESET --
		PCLK, RESET: IN STD_LOGIC		
);
END CAMERA_CONTROLLER;

ARCHITECTURE CAMERA_CONTROLLER_ARCH OF CAMERA_CONTROLLER is

TYPE type_state is (RST, VSYNC_STATE, CAMPIONA);

signal STATE : type_state := RST;
signal ODD_BYTE : STD_LOGIC := '0';

BEGIN
	
	PROCESS(PCLK,RESET)
		variable COUNT : integer range 0 to IMG_WIDTH*IMG_HEIGHT;
	BEGIN
		IF(RESET = '1')
		THEN
			STATE <= RST; 
			ODD_BYTE <= '0';
			D_VALID <= '0';
			COUNT := 0;
		ELSIF (RISING_EDGE(PCLK))
		THEN
		
			D_VALID <= '0';
			ODD_BYTE <= '0';
			
			case STATE is
			
			when RST =>
				if (VSYNC = '1') then
					STATE <= VSYNC_STATE;
				end if;
				
			when VSYNC_STATE =>
				if (VSYNC = '0') then
					STATE <= CAMPIONA;
				end if;
			
			when CAMPIONA =>
					
				if (VSYNC = '0') then
					IF(HREF = '1')
					THEN
						IF(ODD_BYTE = '1')
						THEN				
							D_OUT <= D_IN;
							D_VALID <= '1';
							ODD_BYTE <= '0';
							COUNT := COUNT + 1;
						ELSE
							ODD_BYTE <= '1';
						END IF;
					END IF;
				else
					if (COUNT = IMG_WIDTH*IMG_HEIGHT) then
						CORRECT <= '1';
					else
						CORRECT <= '0';
					end if;
					
					COUNT := 0;
					STATE <= VSYNC_STATE;
				end if;
				
			end case;
			
		END IF;
	END PROCESS;
	
END CAMERA_CONTROLLER_ARCH; 