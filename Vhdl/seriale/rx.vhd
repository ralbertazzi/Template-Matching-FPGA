LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY RX IS
PORT(
	CLK: IN STD_LOGIC;
	RESET: IN STD_LOGIC;
	RX_LINE: IN STD_LOGIC;
	BUSY: OUT STD_LOGIC;
	DATA: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
END RX;

ARCHITECTURE RX_ARCH OF RX IS

	CONSTANT DATA_DURATION: INTEGER := 5208;
	
	TYPE type_state is (IDLE, RX_START_BIT, RX_DATA, RX_STOP_BIT);
	signal STATE : type_state := IDLE;

	signal DATABUFF: STD_LOGIC_VECTOR (7 DOWNTO 0);
	
	BEGIN
	PROCESS(CLK)
		variable CLOCK_COUNT: integer RANGE 0 TO DATA_DURATION-1:=0;
		variable INDEX: integer RANGE  0 TO 9:=0;
	BEGIN
		IF(RISING_EDGE(CLK))
		THEN
			IF (RESET = '1')
			THEN
				STATE <= IDLE;
				INDEX := 0;
				CLOCK_COUNT := 0;
				BUSY <= '0';
			ELSE

				case STATE is
				
				when IDLE =>
					INDEX := 0;
					CLOCK_COUNT := 0;
					--start bit found
					if(RX_LINE = '0')
					then
						BUSY <= '1';
						STATE <= RX_START_BIT;
					else
						BUSY <= '0';
						STATE <= IDLE;
					end if;

				when RX_START_BIT =>
					-- controllo a metà della durata del bit di start che sia ancora basso per evitare bit spuri
					if(CLOCK_COUNT = (DATA_DURATION-1)/2) then
						if(RX_LINE = '0') then
							CLOCK_COUNT := 0; --ho trovato la metà, da questo momento campioniamo il dato circa a metà del periodo in cui è disponibile
							STATE <= RX_DATA;
						else
							--se era uno start bit spurio torno a idle
							STATE <= IDLE;
						end if;
					else
						CLOCK_COUNT := CLOCK_COUNT + 1;
						STATE <= RX_START_BIT;
					end if;

				when RX_DATA =>
					if(CLOCK_COUNT < DATA_DURATION-1) then
						CLOCK_COUNT := CLOCK_COUNT +1;
						STATE <= RX_DATA;
					else
						--salvo il bit e azzero il contatore
						DATABUFF(INDEX) <= RX_LINE;
						CLOCK_COUNT := 0;

						--controllo e aggiornamento indice
						if(INDEX < 7) then
							INDEX := INDEX +1;
							STATE <= RX_DATA;
						else
							INDEX := 0;
							STATE <=RX_STOP_BIT;
						end if;
					end if;

				when RX_STOP_BIT =>
					if(CLOCK_COUNT < DATA_DURATION-1) then
						CLOCK_COUNT := CLOCK_COUNT +1;
						STATE <= RX_STOP_BIT;
					else
						BUSY <= '0';
						DATA <= DATABUFF;
						STATE <= IDLE;
					end if;

				end case;
				
			END IF;
		END IF;
	END PROCESS;
END RX_ARCH;