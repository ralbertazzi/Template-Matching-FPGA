library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.global.all;

entity sram_reader is
port(
		-- FIFO CHANNEL --
		WR_FULL : in STD_LOGIC;
		WR_REQ  : out STD_LOGIC;
		WR_DATA : out STD_LOGIC_VECTOR(7 downto 0);
		
		-- SRAM CONTROLLER CHANNEL --
		RD_ACK  : in STD_LOGIC;
		DATA_IN : in STD_LOGIC_VECTOR(15 downto 0);
		RD_ADDR : out STD_LOGIC_VECTOR(17 downto 0);
		RD      : out STD_LOGIC;
		
		-- CLK and RESET --
		CLK, RESET: in STD_LOGIC
		
);
end sram_reader;

architecture sram_reader_arch of sram_reader is

type state_type is (WR_FIFO, RD_SRAM);
signal curr_state, next_state : state_type;
-- altri segnali interni
signal TEMP_DATA : std_logic_vector(15 downto 0);
signal COUNT, next_count : integer range 0 to 1 := 0;
signal ADDRESS, next_address : integer range 0 to IMG_WIDTH * IMG_HEIGHT / 2 - 1 := 0;

begin

	sync_proc: process(CLK, next_state, RESET)
	begin
		if (RESET = '1') then
			COUNT <= 0;
			ADDRESS <= 0;
			curr_state <= RD_SRAM;
		elsif(rising_edge(CLK)) then
			curr_state <= next_state;
			ADDRESS <= next_address;
			COUNT <= next_count;
		end if;
	end process sync_proc;
	
	state_proc: process(curr_state)
	begin
		-- pre assign output --
		next_count <= COUNT;
		next_address <= ADDRESS;
		
		case curr_state is
				
			when RD_SRAM =>
			
				if (RD_ACK = '0') then
					WR_REQ <= '0';
					RD <= '1';
					next_state <= RD_SRAM;
				else
					next_address <= (ADDRESS + 1) mod (IMG_WIDTH * IMG_HEIGHT / 2);
					TEMP_DATA <= DATA_IN;
					RD <= '0';
					next_state <= WR_FIFO;
					
					if (WR_FULL = '0') then
						WR_REQ <= '1';
						WR_DATA <= TEMP_DATA(7 downto 0);
						next_count <= 1;
					else
						WR_REQ <= '0';
						next_count <= 0;
					end if;
					
				end if;
				
				
			when WR_FIFO =>
					
				if (WR_FULL = '0') then
					WR_REQ <= '1';
					
					if (COUNT = 0) then
						RD <= '0';
						WR_DATA <= TEMP_DATA(7 downto 0);
						next_count <= COUNT + 1;
						next_state <= WR_FIFO;
					else
						RD <= '1';
						WR_DATA <= TEMP_DATA(15 downto 8);
						next_state <= RD_SRAM;
					end if;
					
				else
					WR_REQ <= '0';
					RD <= '0';
					next_state <= WR_FIFO;
				end if;
				
		end case;
	end process state_proc;
	
-- assegnamenti asincroni
RD_ADDR <= std_logic_vector(to_unsigned(ADDRESS, 18));

end sram_reader_arch;