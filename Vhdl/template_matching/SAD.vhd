library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

-- Template matching implementato con algoritmo SAD --
-- Confronto la finestra con il template facendo la
-- differenza in valore assoluto tra pixel corrispondenti
-- e sommando tali differenze.

-- Il modulo è implementato con pipeline a 3 stadi:
-- I stadio: faccio la differenza in valore assoluto in parallelo
--					all'interno del frammento di finestra ricevuto
-- II stadio: faccio la somma tra tutte le differenze nel frammento
--					di finestra (somma parziale)
-- III stadio: faccio la somma totale (score) di tutte le somme parziali e la
--					mando in uscita se sono nell'ultimo frammento
entity SAD is
port
(	

	-- Input ports
	window_valid 		: in std_logic;
	window_seq 			: in natural range 0 to COMPUTATION_STEPS - 1;
	window_in 			: in window_packet;
	
	-- Input programmazione template
	pixel_valid			: in std_logic;
	pixel_in				: in pixel;
	pixel_row			: in natural range 0 to TEMPLATE_SIZE - 1;
	pixel_col			: in natural range 0 to TEMPLATE_SIZE - 1;
	

	-- Output ports
	score_valid 		: out std_logic;
	score					: out score_type_vector;
	
	clk : in std_logic;
	reset : in std_logic
);
end SAD;

architecture SAD_arch of SAD is

	signal window_valid_1, window_valid_2 : std_logic;
	signal window_seq_1, window_seq_2 : natural range 0 to COMPUTATION_STEPS - 1;
	signal template : window_type;	
	signal temp_sad : window_packet;
	signal partial_sum_2_3 : integer range 0 to SCORE_MAX / COMPUTATION_STEPS - 1;


begin
process(clk)
	-- stage 0 --
	variable window_pixel : pixel_int;
	variable template_pixel : pixel_int;
	-- stage 1 --
	variable partial_sum : integer range 0 to SCORE_MAX / COMPUTATION_STEPS - 1;
	-- stage 2 --
	variable total_sum : score_type;
	
	variable programming_row : natural range 0 to TEMPLATE_SIZE - 1;
begin
	if (rising_edge(clk)) then
	
		if (reset = '1') then
			score_valid <= '0';
			window_valid_1 <= '0';
			window_valid_2 <= '0';
			total_sum := 0;
			for row in 0 to TEMPLATE_SIZE - 1 loop
				template(row) <= (others => '1');
			end loop;
		else
		
		if (pixel_valid = '1') then
			programming_row := TEMPLATE_SIZE - 1 - pixel_row;
			template(pixel_col)(programming_row*PIXEL_WIDTH + PIXEL_WIDTH - 1 downto programming_row*PIXEL_WIDTH) <= pixel_in;
		end if;
		
		for stage in 0 to 2 loop
			case stage is
		
					when 0 => -- Effettuo la differenza in valore assoluto tra i pixel corrispondenti del frammento di finestra

							window_valid_1 <= window_valid;
							window_seq_1 <= window_seq;
							
							if (window_valid = '1') then
							
								for col in 0 to TEMPLATE_SIZE / COMPUTATION_STEPS - 1 loop
									for row in 0 to TEMPLATE_SIZE - 1 loop
							
										window_pixel := to_integer(unsigned(window_in(col)(row*PIXEL_WIDTH + PIXEL_WIDTH - 1 downto row*PIXEL_WIDTH)));
										template_pixel := to_integer(unsigned(template(col + window_seq * TEMPLATE_SIZE / COMPUTATION_STEPS)(row*PIXEL_WIDTH + PIXEL_WIDTH - 1 downto row*PIXEL_WIDTH)));
										
										temp_sad(col)(row*PIXEL_WIDTH + PIXEL_WIDTH - 1 downto row*PIXEL_WIDTH) <= std_logic_vector(to_unsigned(abs(window_pixel - template_pixel), PIXEL_WIDTH));
										
							
									end loop; -- row loop
								end loop; -- col loop
							
							end if;
							
					when 1 => -- Sommo le differenze calcolate nel precedente clock e ottengo la somma per il frammento di finestra

							window_valid_2 <= window_valid_1;
							window_seq_2 <= window_seq_1;
							
							if (window_valid_1 = '1') then
								
								partial_sum := 0;
								for col in 0 to TEMPLATE_SIZE / COMPUTATION_STEPS - 1 loop
									for row in 0 to TEMPLATE_SIZE - 1 loop
									
										partial_sum := partial_sum + to_integer(unsigned(temp_sad(col)(row*PIXEL_WIDTH + PIXEL_WIDTH - 1 downto row*PIXEL_WIDTH)));
										
									end loop; -- row loop
								end loop; -- col loop
								
								partial_sum_2_3 <= partial_sum;
								
							end if;
							
					when 2 => -- Sommo le somme parziali e ottengo la somma totale per la finestra
							score_valid <= '0';
							if (window_valid_2 = '1') then
								
								total_sum := total_sum + partial_sum_2_3;
								
								if (window_seq_2 = COMPUTATION_STEPS - 1) then
								
									score <= std_logic_vector(to_unsigned(total_sum, SCORE_WIDTH));
									score_valid <= '1';
									total_sum := 0;
									
								end if;
								
							end if;
							
					when others => null;

				end case; --stage
			end loop; --stage

		end if; --reset
	end if; --clock
end process;
end architecture;