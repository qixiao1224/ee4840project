onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -radix unsigned /testbench/clk
add wave -noupdate -radix unsigned /testbench/reset
add wave -noupdate -radix unsigned /testbench/mem_top1/image_ram_addr_a
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_write1/image_count
add wave -noupdate -radix unsigned /testbench/mem_top1/image_ram_addr_b
add wave -noupdate -radix unsigned /testbench/mem_top1/conv_ram_addr_a
add wave -noupdate -radix unsigned /testbench/mem_top1/we_conv

add wave -noupdate -radix unsigned /testbench/mem_top1/dense_ram_addr_a
add wave -noupdate -radix unsigned /testbench/mem_top1/we_image0
add wave -noupdate -radix unsigned /testbench/mem_top1/data_image0
add wave -noupdate -radix unsigned /testbench/mem_top1/data_image1
add wave -noupdate -radix unsigned /testbench/mem_top1/data_image2
add wave -noupdate -radix unsigned /testbench/mem_top1/data_image3
add wave -noupdate -radix unsigned /testbench/mem_top1/data_conv
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_write1/data0
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_write1/data1
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_write1/data2
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_write1/data3

#add wave -noupdate -radix unsigned /testbench/tmp0
#add wave -noupdate -radix unsigned /testbench/tmp1
#add wave -noupdate -radix unsigned /testbench/tmp2
#add wave -noupdate -radix unsigned /testbench/tmp3

add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_res0
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_res1
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_res2
add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_res3

add wave -group {datas} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_image0
add wave -group {datas} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_image1
add wave -group {datas} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_image2
add wave -group {datas} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/read_image3
add wave -group {datas} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[0]
add wave -group {datas} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[1]
add wave -group {datas} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[2]
add wave -group {datas} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[3]

add wave -group {layer12} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/layer12_count
add wave -group {layer12} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/channel32_count
add wave -group {layer12} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/block_count

add wave -group {layer34} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/layer34_count
add wave -group {layer34} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/channel64_count
add wave -group {layer34} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/filter32_count
add wave -group {layer34} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/block34_count

add wave -group {layer5} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/layer5_count
add wave -group {layer5} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/block5_count
add wave -group {layer5} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/channel64_count_1
add wave -group {layer5} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/filter32_count_1

add wave -group {dense} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/dense_count
add wave -group {dense} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/dense_bias_count
add wave -group {dense} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/dense_case


add wave -group {writeback} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/ram_num
add wave -group {writeback} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/wr_en
add wave -group {writeback} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/writing
add wave -group {writeback} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/stop_write_back
add wave -group {writeback} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/ram_addr_a
add wave -group {writeback} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/ram_addr_b

add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[0]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[1]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[2]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[3]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[4]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[5]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[6]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[7]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[8]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[9]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[10]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[11]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[12]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[13]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[14]
add wave -group {processing unit} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/processing_unit_4x4[15]

add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/conv_ram_addr_a
add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/conv_ram_addr_b
add wave -noupdate -radix unsigned /testbench/mem_top1/memory1/image_ram_addr_b


add wave -noupdate -radix unsigned /testbench/mem_top1/memory_read1/layer12_count


add wave -group {state} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/current_state
add wave -group {state} -noupdate -radix unsigned /testbench/mem_top1/memory_write1/current_state


add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/control_reg
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/EN_FSM
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/memory_read1/EN_CONFIG
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/DA
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/DB
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/DC
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/DD
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/DE
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/DF
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/DG
add wave -group {npu} -noupdate -radix unsigned /testbench/mem_top1/DH

add wave -group {writedata} -noupdate -radix hexadecimal /testbench/writedata

add wave -group {npu_out} -noupdate -radix unsigned /testbench/mem_top1/D_OUT
add wave -group {npu_out} -noupdate -radix unsigned /testbench/mem_top1/npu_top/MAC1_output
add wave -group {npu_out} -noupdate -radix unsigned /testbench/mem_top1/npu_top/MAC2_output

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


