-- ***************************************************************************
 -- * File:        uart_tx.vhd
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

entity uart_tx is 
	generic (
		clk_freq	: natural := 50; -- unit: MHz
		baud_rate	: natural := 115200
		);
	port (
		clk			: in std_logic := '0';
		rst			: in std_logic := '0';
		data_in		: in std_logic_vector (7 downto 0) := (others => '0');
		data_in_vld	: in std_logic := '0';
		
		dataout_ready: out std_logic := '0';
		data_out	: out std_logic := '0';
		);
end entity uart_tx;

architecture rtl of uart_tx is 

-- the number of cycles for each bit.
constant CLK_CYCLE := natural := clk_freq * 1000000 / baud_rate;

signal clk_cnt, bit_cnt : unsigned(15 downto 0) := (others => '0');

type TX_STATE_T is (TX_IDLE, TX_START, TX_SEND_DATA, RX_STOP);
signal tx_state : TX_STATE_T := TX_IDLE;

begin 

	-- clk_cnt only increases in the 'TX_SEND_DATA' state.
	p_clock_count: process (clk, rst, tx_state)
		begin
			if rising_edge(clk) then 
				if rst = '0' then 
					clk_cnt <= (others => '0');
				elsif ((tx_state = TX_SEND_DATA) and (clk_cnt = CLK_CYCLE - 1)) or (tx_state /= TX_REC_DATA) then 
					clk_cnt <= (others => '0');
				else
					clk_cnt <= clk_cnt + 1;
				end if;
			end if;
	end process;
	
	-- bit_cnt only increases in the 'TX_REC_DATA' state.
	p_bit_count: process (clk, rst, tx_state)
		begin
			if rising_edge(clk) then 
				if rst = '0' then 
					bit_cnt <= (others => '0');
				elsif (tx_state = TX_SEND_DATA) and (clk_cnt = CLK_CYCLE - 1) then 
					bit_cnt <= bit_cnt + 1;
				else
					bit_cnt <= (others => '0');
				end if;		
			end if;
	end process;

	p_state: process (rst, clk, data_in_vld, clk_cnt, bit_cnt)
		begin
			if rst = '0' then 
				tx_state <= TX_IDLE;
			elsif rising_edge(clk) then 
				case tx_state is 
					when TX_IDLE => 
						if data_in_vld = '1' then  
							tx_state <= TX_START;
						else
							tx_state <= TX_IDLE;
						end if;
					when TX_START =>
						if clk_cnt = CLK_CYCLE - 1 then 
							tx_state <= TX_SEND_DATA;
						else
							tx_state <= TX_START;
						end if;
					when TX_SEND_DATA => 
						if ((clk_cnt = CLK_CYCLE - 1) and (bit_cnt = 7)) then 
							tx_state <= TX_STOP;
						else 
							tx_state <= TX_SEND_DATA;
						end if;
					when TX_STOP => 
						if clk_cnt = CLK_CYCLE - 1 then
							tx_state <= TX_IDLE;
						else
							tx_state <= TX_STOP;
						end if;
					when others =>
						tx_state <= TX_IDLE;		
				end case;
			end if;
	end process;
	
	p_data: process (clk, rst, tx_state, clk_cnt)
		begin
			if rst = '0' then 
				data_out <= '1';
			elsif rising_edge(clk) then 
				case tx_state is
					when TX_IDLE => 
						data_out <= '1';
					when TX_START => 
						data_out <= '0';
					when TX_SEND_DATA => 
						data_out <= data_in(bit_cnt);
					when TX_STOP => 
						data_out <= '1';
					when others 	
						data_out <= '1';
				end case;
			end if;
	end process;
	
	p_vld_sig: process (rst, clk, tx_state)
		begin 
			if rst = '0' then 
				dataout_ready <= '0';
			elsif rising_edge(clk) then 
				if (tx_state = TX_IDLE and data_in_vld = '1')
					dataout_ready <= '1';
				elsif (tx_state = TX_STOP and clk_cnt = CLK_CYCLE - 1) then 
					dataout_ready <= '1';
				else 
					dataout_ready <= '0';
				end if;				
			end if;
	end process;

end architecture rtl;
