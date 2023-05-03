onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -radix unsigned /testbench/clk
add wave -noupdate -radix unsigned /testbench/reset
add wave -noupdate -radix unsigned /testbench/mem_top1/image_ram_addr_a
add wave -noupdate -radix unsigned /testbench/mem_top1/image_ram_addr_b
add wave -noupdate -radix unsigned /testbench/mem_top1/conv_ram_addr_a
add wave -noupdate -radix unsigned /testbench/mem_top1/we_conv

add wave -noupdate -radix unsigned /testbench/mem_top1/dense_ram_addr_a
add wave -noupdate -radix unsigned /testbench/mem_top1/we_image0
add wave -noupdate -radix unsigned /testbench/mem_top1/data_image0
add wave -noupdate -radix unsigned /testbench/mem_top1/data_image1
add wave -noupdate -radix unsigned /testbench/mem_top1/data_image2
add wave -noupdate -radix unsigned /testbench/mem_top1/data_image3

#add wave -noupdate -radix unsigned /testbench/tmp0
#add wave -noupdate -radix unsigned /testbench/tmp1
#add wave -noupdate -radix unsigned /testbench/tmp2
#add wave -noupdate -radix unsigned /testbench/tmp3
#add wave -noupdate -radix unsigned /testbench/i
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_image0
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_image1
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_image2
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_image3
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_res0
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_res1
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_res2
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_res3

add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/ram_num

add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/conv_ram_addr_a
add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/conv_ram_addr_b
add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/image_ram_addr_b
add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/data_conv
add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/we_conv
add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/read_conv
add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/conv_ram0/mem[0]
add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/conv_ram0/mem[1]

add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/out0
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/out1
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/out2
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/out3

add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/out_param
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/out_param1
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/out_param2
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/out_param3
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/layer12_count


add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/current_state
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_write1/current_state
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/control_reg
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/EN_FSM
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/EN_CONFIG
add wave -noupdate -radix unsigned /testbench/mem_top1/DA
add wave -noupdate -radix unsigned /testbench/mem_top1/DB
add wave -noupdate -radix unsigned /testbench/mem_top1/DC
add wave -noupdate -radix unsigned /testbench/mem_top1/DD
add wave -noupdate -radix unsigned /testbench/mem_top1/DE
add wave -noupdate -radix unsigned /testbench/mem_top1/DF
add wave -noupdate -radix unsigned /testbench/mem_top1/DG
add wave -noupdate -radix unsigned /testbench/mem_top1/DH

add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/ram_addr_a
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/ram_addr_b


add wave -noupdate -radix hexadecimal /testbench/writedata
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/D_out
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/D_out
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/D_out

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


