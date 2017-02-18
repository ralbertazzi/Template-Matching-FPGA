library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.global.all;

entity sram_writer is
port(
		-- INPUT CHANNEL --
		RD_VALID: in STD_LOGIC;
		RD_DATA: in STD_LOGIC_VECTOR(7 downto 0);
		
		-- SRAM CONTROLLER CHANNEL --
		WR_ACK  : in STD_LOGIC;
		DATA_OUT: out STD_LOGIC_VECTOR(15 downto 0);
		WR_ADDR : out STD_LOGIC_VECTOR(17 downto 0);
		WR      : out STD_LOGIC;
		
		-- CLK and RESET --
		CLK, RESET: in STD_LOGIC
		
);
end sram_writer;

architecture sram_writer_arch of sram_writer is

type state_type is (RD_FIFO, WR_SRAM);
signal curr_state, next_state : state_type;

signal TEMP_DATA : std_logic_vector(15 downto 0);
signal COUNT, next_count : integer range 0 to 1 := 0;
signal ADDRESS, next_address : integer range 0 to IMG_WIDTH * IMG_HEIGHT / 2 - 1 := 0;

begin

	sync_proc: process(CLK, next_state, RESET)
	begin
		if (RESET = '1') then
			COUNT <= 0;
			ADDRESS <= 0;
			curr_state <= RD_FIFO;
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
		
			when WR_SRAM =>
				if (WR_ACK = '0') then
					WR <= '1';
					next_state <= WR_SRAM;
				else
					
					next_address <= (ADDRESS + 1) mod (IMG_WIDTH * IMG_HEIGHT / 2);
					next_state <= RD_FIFO;
					WR <= '0';
					if (RD_VALID = '1') then
						TEMP_DATA(7 downto 0) <= RD_DATA;
						next_count <= 1;
					else
						next_count <= 0;
					end if;
				end if;
				
				
			when RD_FIFO =>
					
				if (RD_VALID = '1') then
					
					if (COUNT = 0) then
						WR <= '0';
						TEMP_DATA(7 downto 0) <= RD_DATA;
						next_count <= COUNT + 1;
						next_state <= RD_FIFO;
					else
						WR <= '1';
						TEMP_DATA(15 downto 8) <= RD_DATA;
						DATA_OUT <= TEMP_DATA;
						next_state <= WR_SRAM;
					end if;
					
				else
					WR <= '0';
					next_state <= RD_FIFO;
				end if;
		
				
		end case;
	end process state_proc;
	
-- assegnamenti asincroni
WR_ADDR <= std_logic_vector(to_unsigned(ADDRESS, 18));

end sram_writer_arch;