library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity digit_extractor is
generic
(
	COUNTER_WIDTH : natural := 10;
	COUNTER_BASE : natural := 1000
);
port
(
	count 	: in std_logic_vector(COUNTER_WIDTH - 1 downto 0);
	
	digit3 	: out natural range 0 to 9;
	digit2 	: out natural range 0 to 9;
	digit1 	: out natural range 0 to 9;
	digit0 	: out natural range 0 to 9
);
end digit_extractor;

architecture digit_extractor_arch of digit_extractor is

signal count_int : integer;

begin
	
	count_int 	<= to_integer(unsigned(count));
	digit0 		<= count_int mod 10;						-- unita'
	digit1 		<= (count_int mod 100) / 10;			-- decine
	digit2 		<= (count_int mod 1000) / 100;		-- centinaia
	digit3 		<= (count_int mod 10000) / 1000; 	-- migliaia
	
end architecture;
