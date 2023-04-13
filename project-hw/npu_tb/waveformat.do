onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -radix decimal /testbench/clk
add wave -noupdate -radix decimal /testbench/reset
add wave -noupdate -radix decimal /testbench/writedata
add wave -noupdate -radix decimal /testbench/write
add wave -noupdate -radix decimal /testbench/chipselect
add wave -noupdate -radix decimal /testbench/reading
add wave -noupdate -radix decimal /testbench/data0
add wave -noupdate -radix decimal /testbench/data1
add wave -noupdate -radix decimal /testbench/data2
add wave -noupdate -radix decimal /testbench/data3


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


