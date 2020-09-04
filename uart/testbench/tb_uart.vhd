-- ***************************************************************************
 -- * File:        tb_uart_tx.vhd
 -- * Created on:  03 Sep 2020
 -- * Author:      Yan Zong
 -- * Web:		   zongyan.info
 -- * Copyright:   (C) 2020 Yan Zong.
 -- *
 -- *              alinx_ax301 is free software; you can redistribute it and/or 
 -- *              modify it under the terms of the GNU General Public License 
 -- *              as published by the Free Software Foundation; either version 3 
 -- *              of the License, or (at your option) any later version.
 -- *
 -- *              alinx_ax301 is distributed in the hope that it will be useful, 
 -- *              but WITHOUT ANY WARRANTY; without even the implied warranty of
 -- *              MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 -- *              GNU General Public License for more details.
-- ****************************************************************************

library ieee;
use ieee.std_logic_1164.all;

library work;

entity tb_uart is
end entity tb_uart;

architecture behavioural of tb_uart is

	-- each bit consist of CLK_CYCLE clock cycles
	constant CLK_CYCLE : natural := 50 * 1000000 / 115200;
	
	-- each uart frame data consists of 1 start bit + 8 data bits + 1 stop bit 
	constant CLK_BYTE_CYCLE : natural := 10 * CLK_CYCLE;
	
	signal clk, rst : std_logic := '0';
	
	signal tx_data_in : std_logic_vector(7 downto 0) := (others => '0');
	signal tx_data_in_vld, tx_data_out_ready, tx_data_out : std_logic := '0';
	
	signal rx_data_in, rx_data_in_ready, rx_data_out_vld : std_logic := '0';
	signal rx_data_out : std_logic_vector(7 downto 0) := (others => '0');

	signal cnt_data, clk_cnt, byte_cnt: natural := 0;

	signal data_word       : std_logic_vector(7 downto 0);
	type data_tmp is array (0 to 13) of std_logic_vector(data_word'range);
	constant data      : data_tmp :=
                                (     
								 x"66",
                                 x"7E", 
                                 x"FF", 
                                 x"03",
								 x"21",								 
                                 x"AA",  
                                 x"BB",  
                                 x"CC",  								 
                                 x"DD",  
                                 x"EE",  
                                 x"15",  
								 x"C4", 
								 x"7E",	
								 x"DD"								 
                                );
	
begin 

	dut_uart_tx : entity work.uart_tx
		port map (		
			clk				=> clk,
			rst				=> rst, 
			data_in			=> tx_data_in,
			data_in_vld		=> tx_data_in_vld,
			
			dataout_ready	=> tx_data_out_ready,
			data_out		=> tx_data_out 
		);
		
	p_clk : process
	   begin
		   wait for 20 ns; clk <= '1';
		   wait for 20 ns; clk <= '0';
	end process;		
	
	stimulus : process
	   begin
			wait for 20 ns; rst  <= '0';
			wait for 18 ns; rst  <= '1';
			wait;
	end process stimulus;	
	
	-- this process is used for each bit
	p_clock_count: process (clk, rst)
		begin
			if rising_edge(clk) then 
				if rst = '0' or clk_cnt = CLK_CYCLE - 1 then 
					clk_cnt <= 0;
				else
					clk_cnt <= clk_cnt + 1;
				end if;
			end if;
	end process;
	
	-- this process is used for each uart frame data
	-- each uart frame data consists of 1 start + 8 data + 1 stop bit
	p_byte_count: process (clk, rst)
		begin
			if rising_edge(clk) then 
				if rst = '0' or byte_cnt = CLK_BYTE_CYCLE - 1 then 
					byte_cnt <= 0;
				else
					byte_cnt <= byte_cnt + 1;
				end if;
			end if;
	end process;	
	
	p_data : process (rst, clk)
		begin
			if rst = '0' then 
				tx_data_in <= (others => '0');
			elsif rising_edge(clk) then
			
				if clk_cnt = CLK_CYCLE - 1 and byte_cnt = CLK_BYTE_CYCLE - 1 then 
					tx_data_in <= data(cnt_data);
					cnt_data <= (cnt_data + 1) mod 14;	
				end if;
				
				if cnt_data > 1 and cnt_data < 14 then 
					tx_data_in_vld <= '1';
				else
					tx_data_in_vld <= '0';
				end if;
			end if;
	end process p_data;	
		
		
		
		

		
	




end architecture behavioural; 
