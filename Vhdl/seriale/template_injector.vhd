library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;
use work.convolution_package.all;

entity template_injector is
	port
	(
		-- Input ports
		UART_RXD				: IN STD_LOGIC;	-- seriale
		
		-- Output ports
		prog_valid			: out std_logic;
		prog_index			: out std_logic_vector(TEMPLATE_MATCHING_MODULES_WIDTH - 1 downto 0);
		prog_row				: out natural range 0 to TEMPLATE_SIZE - 1;
		prog_col				: out natural range 0 to TEMPLATE_SIZE - 1;
		prog_pixel			: out pixel;
		
		--control
		CLK 					: IN STD_LOGIC;
		RESET 				: IN STD_LOGIC
	);
end template_injector;

architecture template_injector_arch of template_injector is

	type programming_state is (PROGRAM_INDEX, PROGRAM_PIXEL);
	
	SIGNAL RX_DATA: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL RX_BUSY: STD_LOGIC := '0';

	COMPONENT RX
	PORT(
		CLK		: IN STD_LOGIC;
		RESET		: IN STD_LOGIC;
		RX_LINE	: IN STD_LOGIC;
		DATA		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		BUSY		: OUT STD_LOGIC
	);
	END COMPONENT;

begin

	RX_1: RX PORT MAP (CLK, RESET, UART_RXD, RX_DATA, RX_BUSY);

	process(clk)
		
		variable row : natural range 0 to TEMPLATE_SIZE - 1 := 0;
		variable col : natural range 0 to TEMPLATE_SIZE - 1 := 0;
		variable old_rx_busy : std_logic := '0';
		
		-- indice ricevuto al primo byte e utlizzato per programmare
		-- il template nelle successive iterazioni
		variable temp_index : std_logic_vector(TEMPLATE_MATCHING_MODULES_WIDTH - 1 downto 0) := (others => '0');
		variable state : programming_state;
		
	begin
	if (rising_edge(clk)) then
	
		prog_valid 	<= '0';
			
		if (reset = '1') then
			
			-- reset inner state
			state := PROGRAM_INDEX;
			row := 0;
			col := 0;
			
			-- reset outputs
			prog_index 	<= (others => '0');
			prog_row 	<= 0;
			prog_col 	<= 0;
			prog_pixel 	<= (others => '0');
			
		else
			
			if (old_rx_busy = '1' and RX_BUSY = '0') then -- falling edge di RX_BUSY
			
				-- E' stato ricevuto un byte
				
				case state is
					when PROGRAM_INDEX =>
					
						-- campiono l'indice del template da programmare
						temp_index := RX_DATA(TEMPLATE_MATCHING_MODULES_WIDTH - 1 downto 0);
						-- transizione di stato
						state := PROGRAM_PIXEL;
						
					when PROGRAM_PIXEL =>
					
						prog_valid 	<= '1';
						prog_index 	<= temp_index;
						prog_pixel 	<= RX_DATA;
						prog_row 	<= row;
						prog_col 	<= col;
						
						--Incrementare row e col
						col := (col + 1) mod TEMPLATE_SIZE;
						if (col = 0) then
							row := (row + 1) mod TEMPLATE_SIZE;
						end if;
						
						-- transizione di stato
						if (row = 0 and col = 0) then
							state := PROGRAM_INDEX;
						end if;
						
				end case;
			
			end if; -- falling edge rx_busy
			
			old_rx_busy := RX_BUSY;
		
		end if; -- reset
	end if; --clk
	
	end process;

end template_injector_arch;

