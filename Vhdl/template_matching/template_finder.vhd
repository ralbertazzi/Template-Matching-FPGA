library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

entity template_finder is

	port
	(
		-- Input ports
		window_valid 		: in std_logic;
		window_seq 			: in natural range 0 to COMPUTATION_STEPS - 1;
		window_in 			: in window_packet;
		
		-- Input programmazione template
		pixel_valid			: in std_logic;
		template_index		: in std_logic_vector(TEMPLATE_MATCHING_MODULES_WIDTH-1 downto 0);
		pixel_in				: in pixel;
		pixel_row			: in natural range 0 to TEMPLATE_SIZE - 1;
		pixel_col			: in natural range 0 to TEMPLATE_SIZE - 1;

		-- Output ports
		score_valid 		: out std_logic;
		scores				: out template_matching_score_array;
		
		clk : in std_logic;
		reset : in std_logic
	);
end template_finder;

architecture template_finder_arch of template_finder is

	component decoder_param IS
		GENERIC
		(
			INPUT_WIDTH 	: natural := 2;
			OUTPUT_DECODES : natural := 4
		);
		PORT
		(
			data		: IN STD_LOGIC_VECTOR (INPUT_WIDTH - 1 DOWNTO 0);
			enable	: IN STD_LOGIC;
			selected : OUT STD_LOGIC_VECTOR(OUTPUT_DECODES - 1 DOWNTO 0)
		);
	END component;

	component SAD
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
			
			clk 	: in std_logic;
			reset : in std_logic
		);
	end component;
	
	signal pixel_valids : std_logic_vector(TEMPLATE_MATCHING_MODULES - 1 downto 0);
	signal score_valids : std_logic_vector(TEMPLATE_MATCHING_MODULES - 1 downto 0);
	
	signal scores_inner : template_matching_score_array;
	
	constant all_ones : std_logic_vector(TEMPLATE_MATCHING_MODULES - 1 downto 0) := (others => '1');

begin
	
	score_valid <= '1' when score_valids = all_ones
						else '0';
	
	scores <= scores_inner;
	
	decoder_map: decoder_param
	GENERIC MAP 
	(
		INPUT_WIDTH 	=> TEMPLATE_MATCHING_MODULES_WIDTH,
		OUTPUT_DECODES => TEMPLATE_MATCHING_MODULES
	)
	PORT MAP
	(
		data 		=>	template_index,
		enable 	=>	pixel_valid,
		selected => pixel_valids
	);

	gen_sad: for i in 0 to TEMPLATE_MATCHING_MODULES - 1 generate
		sadx: SAD port map
		(
			window_valid 	=> window_valid,
			window_seq 		=> window_seq,
			window_in 		=> window_in,
			
			pixel_in 		=> pixel_in,
			pixel_row 		=> pixel_row,
			pixel_col 		=> pixel_col,
			pixel_valid 	=> pixel_valids(i),
			
			score_valid 	=> score_valids(i),
			score 			=> scores_inner(i),
			
			clk 				=> clk,
			reset 			=> reset
		);
	end generate gen_sad;

end template_finder_arch;
