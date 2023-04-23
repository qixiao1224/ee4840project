onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -radix unsigned /testbench/clk
add wave -noupdate -radix unsigned /testbench/reset
add wave -noupdate -radix unsigned /testbench/read0
add wave -noupdate -radix unsigned /testbench/out0
add wave -noupdate -radix unsigned /testbench/out1
add wave -noupdate -radix unsigned /testbench/out2
add wave -noupdate -radix unsigned /testbench/out3
add wave -noupdate -radix unsigned /testbench/out_param
#add wave -noupdate -radix unsigned /testbench/data2
#add wave -noupdate -radix unsigned /testbench/data3
add wave -noupdate -radix unsigned /testbench/image_ram_addr
add wave -noupdate -radix unsigned /testbench/conv_ram_addr
add wave -noupdate -radix unsigned /testbench/u0 
add wave -noupdate -radix unsigned /testbench/u1 
add wave -noupdate -radix unsigned /testbench/u2 
add wave -noupdate -radix unsigned /testbench/u3 
add wave -noupdate -radix unsigned /testbench/u4 
add wave -noupdate -radix unsigned /testbench/u5 
add wave -noupdate -radix unsigned /testbench/u6 
add wave -noupdate -radix unsigned /testbench/u7 
add wave -noupdate -radix unsigned /testbench/u8 
add wave -noupdate -radix unsigned /testbench/u9 
add wave -noupdate -radix unsigned /testbench/u10 
add wave -noupdate -radix unsigned /testbench/u11 
add wave -noupdate -radix unsigned /testbench/u12 
add wave -noupdate -radix unsigned /testbench/u13 
add wave -noupdate -radix unsigned /testbench/u14 
add wave -noupdate -radix unsigned /testbench/u15 
add wave -noupdate -radix unsigned /testbench/ram_addr_a
add wave -noupdate -radix unsigned /testbench/ram_addr_b
add wave -noupdate -radix unsigned /testbench/reg_num
add wave -noupdate -radix unsigned /testbench/start_write_back
add wave -noupdate -radix unsigned /testbench/stop_write_back
add wave -noupdate -radix unsigned /testbench/wr_en
add wave -noupdate -radix unsigned /testbench/ram_store_addr
add wave -noupdate -radix unsigned /testbench/memory1/block_count



#add wave -noupdate -radix decimal /testbench/CLKEXT
#add wave -noupdate -radix binary /testbench/DA
#add wave -noupdate -radix binary /testbench/DB
#add wave -noupdate -radix binary /testbench/DC
#add wave -noupdate -radix binary /testbench/DD
#add wave -noupdate -radix binary /testbench/DE
#add wave -noupdate -radix binary /testbench/DF
#add wave -noupdate -radix binary /testbench/DG
#add wave -noupdate -radix binary /testbench/DH

#add wave -noupdate -radix decimal /testbench/SEL_CON
#add wave -noupdate -radix binary /testbench/EN_FSM
#add wave -noupdate -radix binary /testbench/RD_EN
#add wave -noupdate -radix binary /testbench/EN_CONFIG
#add wave -noupdate -radix binary /testbench/RST_GLO
#add wave -noupdate -radix binary /testbench/FULL
#add wave -noupdate -radix binary /testbench/EMPTY
#add wave -noupdate -radix decimal /testbench/D_OUT

#add wave -noupdate -radix decimal /testbench/FSM_EN_PISO_OUT_output
#add wave -noupdate -radix binary /testbench/MAC1_output
#add wave -noupdate -radix decimal /testbench/ReLU1_output
#add wave -noupdate -radix binary /testbench/MAC2_output
#add wave -noupdate -radix decimal /testbench/ReLU2_output
#add wave -noupdate -radix binary /testbench/piso_output


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 223
configure wave -valuecolwidth 89
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {12 ns}


