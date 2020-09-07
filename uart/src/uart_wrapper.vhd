library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity uart_wrapper is 
	generic (
		clk_freq	: natural := 50; -- unit: MHz
		baud_rate	: natural := 115200
		);
	port (
		clk			: in std_logic := '0';
		rst			: in std_logic := '0';	
		datain 		: in std_logic := '0';
		dataout 	: out std_logic := '0'		
		);
end entity uart_wrapper;

architecture rtl of uart_wrapper is 
	
	signal tx_data_vld, tx_data_ready, rx_data_vld, rx_data_ready : std_logic := '0';
	signal tx_data, rx_data : std_logic_vector(7 downto 0) := (others => '0');
	signal tx_cnt, wait_cnt: unsigned(31 downto 0) := (others => '0');
	
	type UART_STATE_T is (UART_IDLE, UART_SEND, UART_REC);
	signal uart_state : UART_STATE_T := UART_IDLE;
	
	begin 

	uart_tx_i: entity work.uart_tx
		generic map (
			clk_freq		=> clk_freq,
			baud_rate		=> baud_rate
			)
		port map (
			clk				=> clk,
			rst				=> rst,
			data_in			=> tx_data,
			data_in_vld		=> tx_data_vld,
			
			dataout_ready 	=> tx_data_ready,
			data_out		=> dataout 
			);

	uart_rx_i: entity work.uart_rx  
		generic map (
			clk_freq		=> clk_freq,
			baud_rate		=> baud_rate
			)
		port map (
			clk				=> clk,
			rst				=> rst,
			data_in			=> datain,
			datain_ready	=> rx_data_ready,
			
			data_out_vld 	=> rx_data_vld,
			data_out		=> rx_data
			);
	
	p_uart: process(clk, rst)
		begin 
			if rst = '0' then 
				uart_state <= UART_IDLE;
				wait_cnt <= (others => '0');
				tx_cnt <= (others => '0');
			elsif rising_edge (clk) then 
				rx_data_ready <= '1';
		
				case uart_state is 
				
					when UART_IDLE => 
						uart_state <= UART_SEND;
					when UART_SEND => 
						wait_cnt <= (others => '0');
						tx_data <= x"5A"; 
						
						if (tx_data_vld = '1' and tx_data_ready = '1' and tx_cnt < 12) then 
							tx_cnt <= tx_cnt + 1;
						elsif tx_data_vld = '1' and tx_data_ready = '1' then 
							tx_cnt <= (others => '0');
							tx_data_vld <= '0';
							uart_state <= UART_REC;
						elsif tx_data_vld = '0' then 
							tx_data_vld <= '1';
						end if;
					when UART_REC => 
						wait_cnt <= wait_cnt + 1;
						
						if rx_data_vld = '1' then 
							tx_data_vld <= '1';
							tx_data <= rx_data;
						elsif tx_data_vld = '1' and tx_data_ready = '1' then 
							tx_data_vld <= '0';
						elsif wait_cnt > clk_freq * 1000000 then 
							uart_state <= UART_SEND;
						end if;
					when others => 
						uart_state <= UART_IDLE;
				end case;
			end if;
	end process;
	
end architecture rtl;