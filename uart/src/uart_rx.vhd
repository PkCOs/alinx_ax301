-- ***************************************************************************
 -- * File:        uart_rx.vhd
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

entity uart_rx is 
	generic (
		clk_freq	: natural := 50; -- unit: MHz
		baud_rate	: natural := 115200
		);
	port (
		clk			: in std_logic := '0';
		rst			: in std_logic := '0';
		data_in		: in std_logic := '0';
		datain_ready: in std_logic := '0';
		
		data_out_vld: out std_logic := '0';
		data_out	: out std_logic_vector (7 downto 0) := (others => '0');
		);
end entity uart_rx;

architecture rtl of uart_rx is 

-- the number of cycles for each bit.
constant CLK_CYCLE := natural := clk_freq * 1000000 / baud_rate;

signal clk_cnt, bit_cnt : unsigned(15 downto 0) := (others => '0');
signal rx_bits : std_logic_vector (7 downto 1) := (others => '0');
signal data_out_vld_i := std_logic := '0';

type RX_STATE_T is (RX_IDLE, RX_START, RX_REC_DATA, RX_STOP, RX_DATA);
signal rx_state : RX_STATE_T := RX_IDLE;

begin 

	-- clk_cnt only increases in the 'RX_REC_DATA' state.
	p_clock_count: process (clk, rst, rx_state)
		begin
			if rising_edge(clk) then 
				if rst = '0' then 
					clk_cnt <= (others => '0');
				elsif ((rx_state = RX_REC_DATA) and (clk_cnt = CLK_CYCLE - 1)) or (rx_state /= RX_REC_DATA) then 
					clk_cnt <= (others => '0');
				else
					clk_cnt <= clk_cnt + 1;
				end if;
			end if;
	end process;
	
	-- bit_cnt only increases in the 'RX_REC_DATA' state.
	p_bit_count: process (clk, rst, rx_state)
		begin
			if rising_edge(clk) then 
				if rst = '0' then 
					bit_cnt <= (others => '0');
				elsif (rx_state = RX_REC_DATA) and (clk_cnt = CLK_CYCLE - 1) then 
					bit_cnt <= bit_cnt + 1;
				else
					bit_cnt <= (others => '0');
				end if;		
			end if;
	end process;

	p_state: process (rst, clk, data_in, clk_cnt, bit_cnt)
		begin
			if rst = '0' then 
				rx_state <= RX_IDLE;
			elsif rising_edge(clk) then 
				case rx_state is 
					when RX_IDLE => 
						if falling_edge(data_in) then 
							rx_state <= RX_START;
						else
							rx_state <= RX_IDLE;
						end if;
					when RX_START =>
						if clk_cnt = CLK_CYCLE - 1 then 
							rx_state <= RX_REC_DATA;
						else
							rx_state <= RX_START;
						end if;
					when RX_REC_DATA => 
						if ((clk_cnt = CLK_CYCLE - 1) and (bit_cnt = 7)) then 
							rx_state <= RX_STOP;
						else 
							rx_state <= RX_REC_DATA;
						end if;
					when RX_STOP => 
						if clk_cnt = CLK_CYCLE/2 - 1 then
							rx_state <= RX_DATA;
						else
							rx_state <= RX_STOP;
						end if;
					when RX_DATA => 
						if datain_ready = '1' then -- receiving data completes
							rx_state <= RX_IDLE;
						else
							rx_state <= RX_DATA;
						end if;
					when others =>
						rx_state <= RX_IDLE;		
				end case;
			end if;
	end process;
	
	p_data: process (clk, rst, rx_state, clk_cnt)
		begin
			if rst = '0' then 
				rx_bits <= (others => '0');
			elsif rising_edge(clk) then 
				if (rx_state = RX_REC_DATA) and (clk_cnt = CLK_CYCLE/2 - 1) then 
					rx_bits(bit_cnt) <= data_in;
				else
					rx_bits <= rx_bits;
				end if;
			end if;
	end process;
	
	p_vld_sig: process 
		begin 
			if rst = '0' then 
				data_out_vld_i <= '0';
			elsif rising_edge(clk) then 
				if rx_state = RX_STOP then 
					data_out_vld_i <= '1';
				elsif (rx_state = S_DATA && datain_ready = '1')
					data_out_vld_i <= '0';
				end if;				
			end if;
	end process;
	
	data_out_vld <= data_out_vld_i;
	data_out <= rx_bits;

end architecture rtl;
