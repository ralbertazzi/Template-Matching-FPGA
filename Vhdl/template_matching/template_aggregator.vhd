library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

-- TEMPLATE AGGREGATOR STATICO --
-- Verifico se lo score è inferiore a un certo valore
-- costante di threshold

entity template_aggregator is
port
(
		score_valid 					: in std_logic;
		scores							: in template_matching_score_array;
		masked							: in std_logic_vector(TEMPLATE_MATCHING_MODULES - 1 downto 0);
		threshold_multiplier			: in std_logic_vector(5 downto 0);
		
		template_matching_finished	: out std_logic;	-- a 1 per un solo clock
		template_matching_found		: out std_logic;
		template_matching_winner	: out natural range 0 to TEMPLATE_MATCHING_MODULES - 1;
		template_matching_row		: out natural range 0 to IMG_HEIGHT - 1;
		template_matching_col		: out natural range 0 to IMG_WIDTH - 1;		
	
		clk : in std_logic;
		reset : in std_logic
);
end template_aggregator;

architecture template_aggregator_arch of template_aggregator is

begin
	process(clk)
		-- inner state: template matching
		variable current_winner		 	: natural range 0 to TEMPLATE_MATCHING_MODULES - 1;
		variable current_winner_col 	: natural range 0 to IMG_WIDTH - 1 := 0;
		variable current_winner_row 	: natural range 0 to IMG_HEIGHT - 1 := 0;
		variable current_winner_score : score_type := SCORE_MAX - 1;
		variable temp_score				: score_type;
		variable temp_winner				: natural range 0 to TEMPLATE_MATCHING_MODULES - 1;
		
		-- inner state: row and col
		variable col_count : natural range 0 to IMG_WIDTH - 1 := 0;
		variable row_count : natural range 0 to IMG_HEIGHT - 1 := 0;
		
		variable threshold : natural;
		
	begin
		if (rising_edge(clk)) then
		
			if (reset = '1') then
				-- reset variables
				current_winner := 0;
				current_winner_col := 0;
				current_winner_row := 0;
				current_winner_score := SCORE_MAX - 1;
				col_count := 0;
				row_count := 0;
				-- reset outputs
				template_matching_finished <= '0';
				template_matching_found <= '0';
				template_matching_row <= 0;
				template_matching_col <= 0;
				template_matching_winner <= 0;
			else
				template_matching_finished <= '0';
				
				if (score_valid = '1') then
					temp_score := SCORE_MAX - 1;
					temp_winner := 0;
					for i in 0 to TEMPLATE_MATCHING_MODULES - 1 loop
						if (masked(i) = '0' and to_integer(unsigned(scores(i))) < temp_score) then
							temp_score := to_integer(unsigned(scores(i)));
							temp_winner := i;
						end if;						
					end loop;
					
					if (row_count >= TEMPLATE_SIZE and col_count >= TEMPLATE_SIZE and temp_score < current_winner_score) then
						current_winner := temp_winner;
						current_winner_score := temp_score;
						current_winner_row := row_count;
						current_winner_col := col_count;
					end if;
					
					if (col_count = IMG_WIDTH - 1 and row_count = IMG_HEIGHT - 1) then -- end of image
					
						template_matching_finished <= '1';
						threshold := to_integer(unsigned(threshold_multiplier)) * TEMPLATE_SIZE * TEMPLATE_SIZE;
						
						if (current_winner_score < threshold) then
							template_matching_found <= '1';
							template_matching_row <= current_winner_row - TEMPLATE_SIZE;
							template_matching_col <= current_winner_col - TEMPLATE_SIZE;
							template_matching_winner <= current_winner;
						else
							template_matching_found <= '0';
						end if;
						
						--reset computation
						current_winner_score := SCORE_MAX - 1;
					end if;
					
					col_count := (col_count + 1) mod IMG_WIDTH;
					-- update current state (row and col)
					if (col_count = 0) then
						row_count := (row_count + 1) mod IMG_HEIGHT;
					end if;
					
				end if; -- score_valid
				
			end if; -- reset
		end if; -- clock
	end process;
	
end architecture;