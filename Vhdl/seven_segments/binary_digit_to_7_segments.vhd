library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity binary_digit_to_7_segments is
port
(
	digit		: in natural range 0 to 9;
	seg		: out std_logic_vector(6 downto 0)
);
end binary_digit_to_7_segments;

architecture binary_digit_to_7_segments_arch of binary_digit_to_7_segments is

begin

	with digit select
	seg <= 	"1000000" 	when 0,
				"1111001" 	when 1,
				"0100100" 	when 2,
				"0110000" 	when 3,
				"0011001"	when 4,
				"0010010"	when 5,
				"0000011" 	when 6,
				"1111000" 	when 7,
				"0000000" 	when 8,
				"0011000"	when 9,
				"0000110" 	when others;

end architecture;