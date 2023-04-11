##################################################
#  Modelsim do file to run simuilation
#  MS 7/2015
##################################################

vlib work 
vmap work work

# Include Netlist and Testbench
vlog +acc -incr ../../rtl/npu_top/npu_top.v 
vlog +acc -incr ../../rtl/npu_v8/npu_v8.v 
vlog +acc -incr ../../rtl/npu_v8/MAC.v 
vlog +acc -incr ../../rtl/npu_v8/ReLU.v 
vlog +acc -incr ../../rtl/npu_v8/piso_out.v 
vlog +acc -incr ../../rtl/npu_v8/input_buffer.v 
vlog +acc -incr ../../rtl/npu_v8/auto_comparator.v 
vlog +acc -incr ../../rtl/npu_v8/syn_fifo.v
vlog +acc -incr ../../rtl/npu_v8/data_converter.v  
vlog +acc -incr ../../rtl/FSM/FSM.v 
vlog +acc -incr ../../rtl/FSM/FSM_ACC.v 
vlog +acc -incr ../../rtl/FSM/FSM_OUT.v 
vlog +acc -incr ../../rtl/SSFR/SSFR.v 
vlog +acc -incr npu_top_test.v 

# Run Simulator 
vsim +acc -t ps -lib work testbench 
do waveformat.do   
run -all
