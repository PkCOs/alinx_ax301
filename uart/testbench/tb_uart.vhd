-- ***************************************************************************
 -- * File:        tb_uart.vhd
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
	
	signal clk, rst : std_logic := '0';
	
	signal tx_data_in : std_logic_vector(7 downto 0) := (others => '0');
	signal tx_data_in_vld, tx_data_out_ready, tex_data_out : std_logic := '0';
	
	signal rx_data_in, rx_data_in_ready, rx_data_out_vld : std_logic := '0';
	signal rx_data_out : std_logic_vector(7 downto 0) := (others => '0');
	
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

	dut_uart_rx : entity work.uart_rx
		port map (
			clk				=> clk,
			rst				=> rst,
			data_in			=> rx_data_in,
			datain_ready	=> rx_data_in_ready,
			
			data_out_vld	=> rx_data_out_vld,
			data_out		=> rx_data_out
		);
		
	p_clk : process
	   begin
		   wait for 200 ms; sys_clk <= '1';
		   wait for 200 ms; sys_clk <= '0';
	end process;		
	
	stimulus : process
	   begin
			wait for 200 ms; reset  <= '0';
			wait for 180 ms; reset  <= '1';
			wait;
	end process stimulus;	
		
		
		
		

		
	




end architecture behavioural; 
