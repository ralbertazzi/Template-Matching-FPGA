library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity occurrence_counter is
generic
(
	COUNTER_WIDTH : natural := 10;
	COUNTER_BASE : natural := 1000
);
port
(
	template_matching_finished : in std_logic;
	template_matching_found		: in std_logic;
	
	count								: out std_logic_vector(COUNTER_WIDTH - 1 downto 0);
	
	clk								: in std_logic;
	reset								: in std_logic
);
end occurrence_counter;

architecture occurrence_counter_arch of occurrence_counter is

begin

	process(clk)
		variable counter 		: natural range 0 to COUNTER_BASE - 1 := 0;
		variable old_found 	: std_logic;
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				counter := 0;
			else
				if (template_matching_finished = '1') then
					
					if (old_found = '0' and template_matching_found = '1') then
						counter := (counter + 1) mod COUNTER_BASE;
					end if;
					
					old_found := template_matching_found;
				end if;
			end if;
			
			count <= std_logic_vector(to_unsigned(counter, COUNTER_WIDTH));
			
		end if;
	end process;

end architecture;