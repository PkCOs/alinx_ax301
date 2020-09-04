# The script can be run at the command line using the following command
# do scripts/tb_uart.do

quit -sim
#compile work files
#vcom ../testbench/tb_uart.vhd

# Simulate file
vsim work.tb_uart

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clock /tb_uart/clk
add wave -noupdate -label reset /tb_uart/rst
add wave -noupdate -label cnt_data /tb_uart/cnt_data
add wave -noupdate -label data -radix hexadecimal /tb_uart/data
add wave -noupdate -label clk_cnt /tb_uart/clk_cnt
add wave -noupdate -label tx_data_in_vld /tb_uart/dut_uart_tx/data_in_vld
add wave -noupdate -label tx_data_in -radix hexadecimal /tb_uart/dut_uart_tx/data_in
add wave -noupdate -label tx_clk_cnt /tb_uart/dut_uart_tx/clk_cnt
add wave -noupdate -label tx_bit_cnt /tb_uart/dut_uart_tx/bit_cnt
add wave -noupdate -label tx_state /tb_uart/dut_uart_tx/tx_state
add wave -noupdate -label tx_dataout /tb_uart/dut_uart_tx/data_out
add wave -noupdate -label tx_dataout_ready /tb_uart/dut_uart_tx/dataout_ready
add wave -noupdate -label rx_data_in /tb_uart/dut_uart_rx/data_in
add wave -noupdate -label rx_data_in_ready /tb_uart/dut_uart_rx/datain_ready
add wave -noupdate -label rx_clk_cnt /tb_uart/dut_uart_rx/clk_cnt
add wave -noupdate -label rx_bit_cnt /tb_uart/dut_uart_rx/bit_cnt
add wave -noupdate -label rx_state /tb_uart/dut_uart_rx/rx_state
add wave -noupdate -label rx_data_out -radix hexadecimal /tb_uart/dut_uart_rx/data_out
add wave -noupdate -label rx_data_out_vld /tb_uart/dut_uart_rx/data_out_vld
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {114752057 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {22716376046 ps} {24176550105 ps}
