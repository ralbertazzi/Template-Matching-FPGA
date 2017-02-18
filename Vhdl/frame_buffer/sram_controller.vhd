library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity sram_controller is
port(
		-- READ CHANNEL --
		RD_REQ: in STD_LOGIC;
		RD_ACK : out STD_LOGIC;
		RD_ADDR: in STD_LOGIC_VECTOR(17 downto 0);
		RD_DATA: out STD_LOGIC_VECTOR(15 downto 0);
		
		-- WRITE CHANNEL --
		WR_REQ: in STD_LOGIC;
		WR_ACK: out STD_LOGIC;
		WR_ADDR: in STD_LOGIC_VECTOR(17 downto 0);
		WR_DATA: in STD_LOGIC_VECTOR(15 downto 0);
		
		-- SRAM BUS SIGNALS --
		SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N: out STD_LOGIC;
		SRAM_ADDR: out STD_LOGIC_VECTOR(17 downto 0);
		SRAM_DQ: inout STD_LOGIC_VECTOR(15 downto 0);
		
		-- CLK and RESET --
		CLK, RESET: in STD_LOGIC
		
);
end sram_controller;

architecture sram_controller_arch of sram_controller is

type state_type is (IDLE_RD, IDLE_WR, R, W);
signal curr_state, next_state : state_type;
-- altri segnali interni
signal rd_data_reg : std_logic_vector(15 downto 0);

begin

	sync_proc: process(CLK, next_state, RESET)
	begin
		if (RESET = '1') then
			curr_state <= IDLE_RD;
		elsif(rising_edge(CLK)) then
			curr_state <= next_state;
		end if;
	end process sync_proc;
	
	state_proc: process(curr_state)
		variable rdwr : std_logic_vector(1 downto 0);
	begin
		rdwr := RD_REQ & WR_REQ;
		-- pre assign output --
		RD_ACK <= '0'; WR_ACK <= '0';
		SRAM_ADDR <= (others => '0');
		SRAM_DQ <= (others => 'Z');
		SRAM_OE_N <= '1'; SRAM_WE_N <= '1';
		
		case curr_state is
		
			when IDLE_RD =>
			
				case rdwr is
					when "00" => 
						next_state <= IDLE_RD;
					when "01" =>
						SRAM_WE_N <= '0';
						SRAM_DQ <= WR_DATA;
						SRAM_ADDR <= WR_ADDR;
						next_state <= W;
					when "10" | "11" =>
						SRAM_OE_N <= '0';
						SRAM_ADDR <= RD_ADDR;
						next_state <= R;
					when others =>
						next_state <= IDLE_RD;
					
				end case;
				
			when IDLE_WR =>
			
				case rdwr is
					when "00" => 
						next_state <= IDLE_WR;
					when "01" | "11" =>
						SRAM_WE_N <= '0';
						SRAM_DQ <= WR_DATA;
						SRAM_ADDR <= WR_ADDR;
						next_state <= W;
					when "10" =>
						SRAM_OE_N <= '0';
						SRAM_ADDR <= RD_ADDR;
						next_state <= R;
					when others =>
						next_state <= IDLE_WR;
					
				end case;
				
			when R =>
			
				RD_ACK <= '1';
				rd_data_reg	<= SRAM_DQ;
				SRAM_ADDR <= RD_ADDR;
				next_state <= IDLE_WR;
			
			when W =>
			
				WR_ACK <= '1';
				SRAM_ADDR <= WR_ADDR;
				next_state <= IDLE_RD;
			
			when others => -- should never happen
				next_state <= IDLE_RD;
				RD_ACK <= '0'; WR_ACK <= '0';
				rd_data_reg <= (others => '0');
				SRAM_ADDR <= (others => '0');
				SRAM_DQ <= (others => 'Z');
				SRAM_OE_N <= '1'; SRAM_WE_N <= '1';
		
				
		end case;
	end process state_proc;
	
-- assegnamenti asincroni
RD_DATA <= rd_data_reg;

-- sempre abilitati
SRAM_CE_N <= '0'; SRAM_UB_N <= '0'; SRAM_LB_N <= '0'; 

end sram_controller_arch;