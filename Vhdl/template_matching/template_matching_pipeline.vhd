library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

entity template_matching_pipeline is
	port
	(
		-- Input ports programming
		prog_valid						: in std_logic;
		prog_index						: in std_logic_vector(TEMPLATE_MATCHING_MODULES_WIDTH-1 downto 0);
		prog_row							: in natural range 0 to TEMPLATE_SIZE - 1;
		prog_col							: in natural range 0 to TEMPLATE_SIZE - 1;
		prog_pixel						: in pixel;
		
		-- Input ports camera
		camera_in_valid 				: in std_logic;
		camera_in_pixel				: in pixel;

		-- Output ports template matching
		template_matching_finished	: out std_logic;	-- a 1 per un solo clock
		template_matching_found		: out std_logic;
		template_matching_winner	: out natural range 0 to TEMPLATE_MATCHING_MODULES - 1;
		template_matching_row		: out natural range 0 to IMG_HEIGHT - 1;
		template_matching_col		: out natural range 0 to IMG_WIDTH - 1;
		
		-- clock, reset
		clk 	: in std_logic;
		reset : in std_logic;
		
		threshold_multiplier			: in std_logic_vector(5 downto 0);
		masked							: in std_logic_vector(TEMPLATE_MATCHING_MODULES - 1 downto 0)
	);
end template_matching_pipeline;


architecture tm_pipeline_arch of template_matching_pipeline is

	component window_extractor is
	port
	(
		pixel_in_valid : in std_logic;
		pixel_in : in pixel;
		
		window_valid : out std_logic;
		window_seq : out natural range 0 to COMPUTATION_STEPS - 1;
		window_out : out window_packet;
		
		clk : in std_logic;
		reset : in std_logic
		
	);
	end component;
	
	component template_finder is
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
	end component;
	
	component template_aggregator is
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
	end component;
	
	-- signals from window_extractor to template_finder
	signal window_valid_sig : std_logic;
	signal window_seq_sig	: natural range 0 to COMPUTATION_STEPS - 1;
	signal window_out_sig	: window_packet;
	
	-- signals from template_finder to template_aggregator
	signal score_valid_sig	: std_logic;
	signal scores_sig			: template_matching_score_array;

begin

	window_extractor_port_map: window_extractor
	port map
	(
		pixel_in_valid 	=> camera_in_valid,
		pixel_in 			=> camera_in_pixel,
		
		window_valid		=> window_valid_sig,
		window_seq 			=> window_seq_sig,
		window_out 			=> window_out_sig,
		
		clk 					=> clk,
		reset 				=> reset
	);
	
	template_finder_port_map: template_finder
	port map
	(
		window_valid 		=> window_valid_sig,
		window_seq 			=> window_seq_sig,
		window_in 			=> window_out_sig,
		
		pixel_valid			=> prog_valid,
		template_index		=> prog_index,
		pixel_in				=> prog_pixel,
		pixel_row			=> prog_row,
		pixel_col			=> prog_col,

		score_valid 		=> score_valid_sig,
		scores				=> scores_sig,
		
		clk 					=> clk,
		reset 				=> reset
	);

	template_aggregator_port_map: template_aggregator
	port map
	(
		score_valid 					=> score_valid_sig,
		scores							=> scores_sig,
		threshold_multiplier			=> threshold_multiplier,
		masked							=> masked,
		
		template_matching_finished	=> template_matching_finished,
		template_matching_found		=> template_matching_found,
		template_matching_winner	=> template_matching_winner,
		template_matching_row		=> template_matching_row,
		template_matching_col		=> template_matching_col,		
	
		clk 								=> clk,
		reset 							=> reset
	);

end tm_pipeline_arch;
