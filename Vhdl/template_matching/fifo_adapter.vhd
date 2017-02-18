library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_adapter is
generic
(
	WIDTH : natural := 8
);
port
(
	fifo_req 	: out std_logic;
	fifo_empty 	: in std_logic;
	fifo_data 	: in std_logic_vector(WIDTH - 1 downto 0);
	
	data_valid 	: out std_logic;
	data 		: out std_logic_vector(WIDTH - 1 downto 0);
	
	clk 		: in std_logic
);
end fifo_adapter;

architecture fifo_adapter_arch of fifo_adapter is
	type state_type is (Idle, Transmit);
begin
	process(clk)
		variable state: state_type := Idle;
	begin
		if (rising_edge(clk)) then
		
			if (fifo_empty = '1') then
				fifo_req 	<= '0';
				data_valid 	<= '0';
			else
				case state is
					when Idle => 
						fifo_req 	<= '1';
						data_valid 	<= '1';
						data <= fifo_data;
						state := Transmit;
					when Transmit =>
						fifo_req 	<= '0';
						data_valid 	<= '0';
						state := Idle;
				end case;
			end if;

		end if; -- clock
	end process;
end architecture;
