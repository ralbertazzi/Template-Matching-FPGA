library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity template_index_encoder is
port
(
	keys 		: in std_logic_vector(3 downto 0);
	
	index 	: out std_logic_vector(1 downto 0);
	enabled 	: out std_logic
);
end template_index_encoder;

architecture template_index_encoder_arch of template_index_encoder is
begin
	
	-- KEY[3..0] arrivano in logica negata
	
	with keys select
	enabled <= '1' when "1110" | "1101" | "1011" | "0111",
					'0' when others;
				
	with keys select
	index <= "00" when "1110",
				"01" when "1101",
				"10" when "1011",
				"11" when "0111",
				"00" when others;

end architecture;