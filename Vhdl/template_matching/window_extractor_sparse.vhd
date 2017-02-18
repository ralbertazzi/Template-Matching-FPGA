library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

entity window_extractor is

	port
	(
		pixel_in_valid : in std_logic;
		pixel_in : in pixel;
		
		window_valid : out std_logic;
		window_seq : out natural range 0 to COMPUTATION_STEPS - 1;
		window_out : out template_packet;
		
		clk : in std_logic;
		reset : in std_logic
		
	);
	
end window_extractor;

architecture window_extractor_arch of window_extractor is

component simple_dual_port_ram_single_clock is

	generic 
	(
		DATA_WIDTH : natural;
		DATA_NUM : natural
	);

	port 
	(
		clk	: in std_logic;
		raddr	: in natural range 0 to DATA_NUM - 1;
		waddr	: in natural range 0 to DATA_NUM - 1;
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic;
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end component simple_dual_port_ram_single_clock;

-- line buffer 

signal raddr, waddr : natural range 0 to IMG_WIDTH - 1;
signal line_buffer_data_rd, line_buffer_data_wr : std_logic_vector(((PIXEL_WIDTH * (DRAW_SIZE - 1)) - 1) downto 0);
signal wen : std_logic;

-- state

type state_type is (READ_PIXEL, TRANSFER_WINDOW);
	
begin

line_buffer: simple_dual_port_ram_single_clock
	generic map 
	(				
		DATA_WIDTH => (PIXEL_WIDTH * (DRAW_SIZE - 1)),
		DATA_NUM => IMG_WIDTH
	)
	port map
	(
		clk	=> clk,
		raddr	=> raddr,
		waddr	=> waddr,
		data	=> line_buffer_data_wr,
		we		=> wen,
		q		=> line_buffer_data_rd
	);
	
	process (clk, reset)
	
	-- window

		variable window : window_type;
		
		variable window_column_temp : window_column;

		variable row : natural range 0 to IMG_HEIGHT - 1 := 0;
		variable col : natural range 0 to IMG_WIDTH - 1 := 0;
		variable step_counter : natural range 0 to COMPUTATION_STEPS - 1 := 0;
		variable start_index : natural range 0 to DRAW_SIZE - 1 := 0;
		
		variable line_buffer_temp : std_logic_vector(((PIXEL_WIDTH * (DRAW_SIZE - 1)) - 1) downto 0);
		
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				-- sync reset
				row := 0;
				col := 0;
				step_counter := 0;			
			else
			
				window_valid <= '0';
				wen <= '0';
				raddr <= col;
				waddr <= col;
				
				if (step_counter = 0) then
				
					if (pixel_in_valid = '1') then
					
						-- lettura colonna corrente dal line buffer
						line_buffer_temp := line_buffer_data_rd;
							
						-- shift a sinistra della window
						for i in 0 to DRAW_SIZE - 2 loop
							window(i) := window(i + 1);
						end loop;
						
						-- assegnamento alla window della colonna corrente del line buffer
						window(DRAW_SIZE - 1) := line_buffer_temp & pixel_in;
						
						line_buffer_temp := line_buffer_temp(((PIXEL_WIDTH * (DRAW_SIZE - 2)) - 1) downto 0) & pixel_in;
					
						-- shift verso l'alto della colonna del line buffer e
						-- scrittura in ram della colonna del line buffer
						wen <= '1';
						line_buffer_data_wr <= line_buffer_temp;
							
						
						-- In uscita mettiamo le colonne meno significtive della finestra
						start_index := 0;
						
						window_valid <= '1';
						
					for J in 0 to TEMPLATE_SIZE / COMPUTATION_STEPS - 1 loop
						for I in 0 to TEMPLATE_SIZE - 1 loop
							window_out(J)(I*PIXEL_WIDTH + PIXEL_WIDTH - 1 downto I*PIXEL_WIDTH) <= window(J*2)((I*2 + 1)*PIXEL_WIDTH + PIXEL_WIDTH - 1 downto (I*2 + 1)*PIXEL_WIDTH);
						end loop;
					end loop;
						
						step_counter := 1; -- cambio stato
						
					end if;
				
				else -- trasferimento finestra
					
					window_valid <= '1';
					
					-- aggiornamento finestra di uscita
					start_index := start_index + DRAW_SIZE / COMPUTATION_STEPS;
					
					for J in 0 to TEMPLATE_SIZE / COMPUTATION_STEPS - 1 loop
						for I in 0 to TEMPLATE_SIZE - 1 loop
							window_out(J)(I*PIXEL_WIDTH + PIXEL_WIDTH - 1 downto I*PIXEL_WIDTH) <= window(start_index + J*2)((I*2 + 1)*PIXEL_WIDTH + PIXEL_WIDTH - 1 downto (I*2 +1)*PIXEL_WIDTH);
						end loop;
					end loop;
					
					step_counter := (step_counter + 1) mod COMPUTATION_STEPS;
					-- se step_counter = 0, cambio stato
				
				end if; -- step_counter
				
				if (pixel_in_valid = '1') then
					-- Incremento il contatore di colonna
					col := (col + 1) mod IMG_WIDTH;
					if (col = 0) then
						row := (row + 1) mod IMG_HEIGHT;
					end if;
				end if;
				
			end if; -- reset
			
			window_seq <= step_counter - 1;
			
		end if; -- clock
	
	end process;

end architecture;