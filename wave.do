onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fifo_async_tb/wr_clk_tb
add wave -noupdate /fifo_async_tb/fifo/sig_w_clk
add wave -noupdate /fifo_async_tb/fifo/sig_r_clk
add wave -noupdate /fifo_async_tb/rd_clk_tb
add wave -noupdate /fifo_async_tb/rst_tb
add wave -noupdate /fifo_async_tb/fifo/wr_clk
add wave -noupdate /fifo_async_tb/fifo/rd_clk
add wave -noupdate /fifo_async_tb/fifo/rst
add wave -noupdate /fifo_async_tb/fifo/wr_data
add wave -noupdate /fifo_async_tb/fifo/rd_data
add wave -noupdate /fifo_async_tb/fifo/wr_en
add wave -noupdate /fifo_async_tb/fifo/rd_en
add wave -noupdate /fifo_async_tb/fifo/event_rw
add wave -noupdate -radix decimal /fifo_async_tb/fifo/filled
add wave -noupdate -radix decimal /fifo_async_tb/fifo/wp
add wave -noupdate -radix decimal /fifo_async_tb/fifo/rp
add wave -noupdate /fifo_async_tb/fifo/state
add wave -noupdate -radix hexadecimal /fifo_async_tb/fifo/fifo_data
add wave -noupdate /fifo_async_tb/fifo/prev_state
add wave -noupdate /fifo_async_tb/fifo/sts_full
add wave -noupdate /fifo_async_tb/fifo/sts_empty
add wave -noupdate /fifo_async_tb/fifo/sts_high
add wave -noupdate /fifo_async_tb/fifo/sts_low
add wave -noupdate /fifo_async_tb/fifo/sts_error
add wave -noupdate /fifo_async_tb/fifo/sig_overflow
add wave -noupdate /fifo_async_tb/fifo/sig_underflow
add wave -noupdate /fifo_async_tb/fifo/data_temp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {42 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {14 ns} {86 ns}
