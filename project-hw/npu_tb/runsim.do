##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# Include Netlist and Testbench
vlog +acc -incr ../npu/npu_top/npu_top.v 
vlog +acc -incr ../npu/npu_v8/npu_v8.v 
vlog +acc -incr ../npu/npu_v8/MAC.v 
vlog +acc -incr ../npu/npu_v8/ReLU.v 
vlog +acc -incr ../npu/npu_v8/piso_out.v 
vlog +acc -incr ../npu/npu_v8/input_buffer.v 
vlog +acc -incr ../npu/npu_v8/auto_comparator.v 
vlog +acc -incr ../npu/npu_v8/syn_fifo.v
vlog +acc -incr ../npu/npu_v8/data_converter.v  
vlog +acc -incr ../npu/FSM/FSM.v 
vlog +acc -incr ../npu/FSM/FSM_ACC.v 
vlog +acc -incr ../npu/FSM/FSM_OUT.v 
vlog +acc -incr ../npu/SSFR/SSFR.v 
#vlog +acc -incr npu_top_test.v 


vlog +acc -incr ./memory_test.v
#vlog +acc -incr ./memory_read_layer12_test.sv
vlog +acc -incr ./memory_read.sv
vlog +acc -incr ./memory_write.sv
vlog +acc -incr ./conv_ram.v
vlog +acc -incr ./res_ram.v
vlog +acc -incr ./image_ram.v
vlog +acc -incr ./dense_ram.v
vlog +acc -incr ./mem_top.sv
vlog +acc -incr ./memory.sv

# Run Simulator 
vsim +acc -t ps -lib work testbench 
do waveformat.do   
run -all
