library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

entity square_generator is

	port
	(
		-- input
		DRAW : IN STD_LOGIC;
		DRAW_ROW : IN NATURAL range 0 TO IMG_HEIGHT - 1;
		DRAW_COL : IN NATURAL range 0 TO IMG_WIDTH - 1;
		
		FIFO_DATA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_ACK : IN STD_LOGIC;
		
		--output
		R: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		G: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		B: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		FIFO_RD_REQ: OUT STD_LOGIC;
		
		--control
		CLK : IN STD_LOGIC;
		RESET : IN STD_LOGIC
		
	);
	
end square_generator;

architecture square_generator_arch of square_generator is
	
begin
	
	process (clk, reset)
	
		variable row : natural range 0 to IMG_HEIGHT - 1 := 0;
		variable col : natural range 0 to IMG_WIDTH - 1 := 0;
		
		variable DRAW_inner : std_logic;
		variable DRAW_ROW_inner : natural range 0 to IMG_HEIGHT - 1;
		variable DRAW_COL_inner : natural range 0 to IMG_WIDTH - 1;
		
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				-- sync reset
				row :=0;
				col := 0;
				DRAW_ROW_inner := 0;
				DRAW_COL_inner := 0;
				DRAW_inner := '0';
				R <= (others=>'0');
				G <= (others=>'1');
				B <= (others=>'0');
			else
				
				if(row = 0 and col = 0) -- sono in (0,0) --> campiono riga e colonna
				then
					DRAW_inner := DRAW;
					DRAW_ROW_inner 	:= DRAW_ROW;
					DRAW_COL_inner 	:= DRAW_COL;
				end if;
				
				--calcolo del dato in uscita
				if(	DRAW_inner = '1' AND 
						(
							-- Condizione per i due bordi orizzontali
							((row = DRAW_ROW_inner OR row = DRAW_ROW_inner + TEMPLATE_SIZE - 1) -- Verifico o riga sopra o riga sotto
							AND col >= DRAW_COL_inner AND col <= DRAW_COL_inner + TEMPLATE_SIZE - 1)
							
							OR
							
							((col = DRAW_COL_inner OR col = DRAW_COL_inner + TEMPLATE_SIZE - 1) -- Verifico o colonna sinistra o colonna destra
							AND row >= DRAW_ROW_inner AND row <= DRAW_ROW_inner + TEMPLATE_SIZE - 1)
						)
					)
				then --viola
					R <= (others=>'1');
					G <= (others=>'0');
					B <= (others=>'1');
				else --pixel corrente
					R <= FIFO_DATA;
					G <= FIFO_DATA;
					B <= FIFO_DATA;
				end if;
				
				--aggiornamento indici di riga e colonna				
				if(VGA_ACK = '1')
				then
					FIFO_RD_REQ <= '1';
					if (col = IMG_WIDTH - 1) then
						row := (row + 1) mod IMG_HEIGHT;
					end if;
					col := (col + 1) mod IMG_WIDTH;
				else
					FIFO_RD_REQ <= '0';
				end if;
				
			end if;	
		end if;
	end process;

end architecture;