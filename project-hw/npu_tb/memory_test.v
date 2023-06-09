`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD #1

`define IMG_INPUT "../../data/img1_z.txt"
`define CONV12_FILTER_INPUT "../../data/weight_bias_conv2d1.txt"
`define CONV34_FILTER_INPUT "../../data/weight_bias_conv2d2.txt"
`define CONV5_FILTER_INPUT "../../data/weight_bias_conv2d3.txt"
`define DENSE1_WEIGHT_INPUT "../../data/weight_bias_dense1_z_r_group4.txt"
`define DENSE2_WEIGHT_INPUT "../../data/weight_bias_dense2_group4.txt"

`define POOLING1_RESULT "../../data/pooling1_result_z.txt"
`define POOLING2_RESULT "../../data/pooling2_result_z.txt"
`define CONV5_RESULT "../../data/conv2d3_flatten_result_z.txt"
`define DENSE1_RESULT "../../data/dense1_result.txt"
`define DENSE2_RESULT "../../data/final_index.txt"

module testbench(  );
  //input and output from top module
  reg clk;
  reg reset;
  reg [31:0] writedata;
  reg [31:0] control_reg;
  wire [7:0] D_OUT;

  //Iteration num
  integer i;

  //FILE flags
  integer img_input;
  integer conv12_filter_input;
  integer conv34_filter_input;
  integer conv5_filter_input;
  integer conv1_result;
  integer pooling1_result;
  integer pooling2_result;
  integer conv5_result;
  integer dense1_weight_input;
  integer dense2_weight_input;
  integer dense1_result;
  integer dense2_result;
  
  //error counters
  reg [10:0] error_count_layer12;
  reg [10:0] error_count_layer34;
  reg [10:0] error_count_layer5;
  reg [10:0] error_count_dense1;
  reg [10:0] error_count_dense2;
  //temp value to compare
  reg [7:0] out0, out1, out2, out3;
  reg [7:0] out0_ff, out1_ff, out2_ff, out3_ff;

  reg [7:0] conv_filter_array;
  reg [7:0] conv1_result_array;
  reg  [7:0] img_array;
  reg [7:0] tmp0,tmp1,tmp2,tmp3,tmp4;



//Module
mem_top mem_top1( .clk(clk),
                 .reset(reset),
                 .writedata(writedata),
                 .control_reg(control_reg),
                 .D_OUT(D_OUT)
                );


//TB start
initial begin
	//Open files
	img_input = $fopen (`IMG_INPUT, "r");
	conv12_filter_input = $fopen (`CONV12_FILTER_INPUT, "r");
	conv34_filter_input = $fopen (`CONV34_FILTER_INPUT, "r");
	conv5_filter_input = $fopen (`CONV5_FILTER_INPUT, "r");
	dense1_weight_input = $fopen (`DENSE1_WEIGHT_INPUT, "r");
        dense2_weight_input = $fopen (`DENSE2_WEIGHT_INPUT, "r");

	pooling1_result = $fopen(`POOLING1_RESULT,"r");
	pooling2_result = $fopen(`POOLING2_RESULT,"r");
	conv5_result = $fopen(`CONV5_RESULT,"r");
	dense1_result = $fopen(`DENSE1_RESULT,"r");
        dense2_result = $fopen(`DENSE2_RESULT,"r");

	//test file opening
	if (!img_input) begin 
	    $display("Cannot Open IMG!");
	    $finish;
	end

	if (!conv12_filter_input) begin 
	    $display("Cannot Open LAYER12 PARA!");
	    $finish;
	end

	if (!conv34_filter_input) begin 
	    $display("Cannot Open LAYER34 PARA!");
	    $finish;
	end

	if (!conv5_filter_input) begin 
	    $display("Cannot Open LAYER5 PARA!");
	    $finish;
	end

	if (!dense1_weight_input) begin 
	    $display("Cannot Open DENSE1 WEIGHT!");
	    $finish;
	end

	if (!dense2_weight_input) begin 
	    $display("Cannot Open DENSE2 WEIGHT!");
	    $finish;
	end


	if (!pooling1_result) begin 
	    $display("Cannot Open POOLING RESULT 1!");
	    $finish;
	end

	if (!pooling2_result) begin 
	    $display("Cannot Open POOLING RESULT 2!");
	    $finish;
	end

	if (!conv5_result) begin 
	    $display("Cannot Open POOLING RESULT 2!");
	    $finish;
	end

	if (!dense1_result) begin 
	    $display("Cannot Open DENSE1 RESULT 2!");
	    $finish;
	end

	if (!dense2_result) begin 
	    $display("Cannot Open DENSE2 RESULT 2!");
	    $finish;
	end


	//Start signal
	clk = 0;
	reset = 0;
	writedata = 0;
	error_count_layer12 = 0;
	error_count_layer34 = 0;
	error_count_layer5 = 0;
        error_count_dense1 = 0;
        error_count_dense2 = 0;
	@(posedge clk); 
	reset = 1;

	@(posedge clk);
	reset = 0;

	@(posedge clk);


	//////////////////////Start Model LOADING//////////////////////////////////////////////////////
	control_reg = 32'b1;

	@(posedge clk);


	//write image
	for (i = 0; i < 224; i = i + 1)begin
	    $fscanf(img_input, "%8b", tmp0);
	    writedata = tmp0;
	    
	    $fscanf(img_input, "%8b", tmp1);
	    writedata = (writedata << 8)+ tmp1;

	    $fscanf(img_input, "%8b", tmp2);
	    writedata = (writedata << 8)+ tmp2;

	    $fscanf(img_input, "%8b", tmp3);
	    writedata = (writedata << 8)+ tmp3;

	    @(posedge clk);
	end

	//write convolution parameters layer 12
	for (i = 0; i < 320; i = i + 1)begin
	    $fscanf(conv12_filter_input, "%8b", tmp4);
	    writedata = tmp4;

	    @(posedge clk);
	end

	//write convolution parameters layer 34
	for (i = 0; i < 9248; i = i + 1)begin
	    $fscanf(conv34_filter_input, "%8b", tmp4);
	    writedata = tmp4;

	    @(posedge clk);
	end

	//write convolution parameters layer 5
	for (i = 0; i < 9247; i = i + 1)begin
	    $fscanf(conv5_filter_input, "%8b", tmp4);
	    writedata = tmp4;

	    @(posedge clk);
	end

	//write weights layer dense1
	for (i = 0; i < 4104; i = i + 1)begin
	    $fscanf(dense1_weight_input, "%8b", tmp0);
	    writedata  = tmp0;
	    
	    $fscanf(dense1_weight_input, "%8b", tmp1);
	    writedata = (writedata << 8)+ tmp1;

	    $fscanf(dense1_weight_input, "%8b", tmp2);
	    writedata = (writedata << 8)+ tmp2;

	    $fscanf(dense1_weight_input, "%8b", tmp3);
	    writedata = (writedata << 8)+ tmp3;

	    @(posedge clk);
	end

	//write weights layer dense2
	for (i = 0; i < 99; i = i + 1)begin
	    $fscanf(dense2_weight_input, "%8b", tmp0);
	    writedata = tmp0;
	    
	    $fscanf(dense2_weight_input, "%8b", tmp1);
	    writedata = (writedata << 8)+ tmp1;

	    $fscanf(dense2_weight_input, "%8b", tmp2);
	    writedata = (writedata << 8)+ tmp2;

	    $fscanf(dense2_weight_input, "%8b", tmp3);
	    writedata = (writedata << 8)+ tmp3;

	    @(posedge clk);
	end


	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);


	//////////////////////Start Model Inferncing//////////////////////////////////////////////////////

	control_reg = 32'h2;
	@(posedge clk);
	control_reg = 32'h0;
	  repeat(1000000)  @(posedge clk);
	

	//////////////////////////////////////////////////////////////////////////////////////////////////////////

	/*Layer 12 TESTING*/
	for (i = 0; i < 1568; i = i + 1) begin
		out0 = testbench.mem_top1.memory_read1.res_ram0.mem[i];
		out1 = testbench.mem_top1.memory_read1.res_ram1.mem[i];
		out2 = testbench.mem_top1.memory_read1.res_ram2.mem[i];
		out3 = testbench.mem_top1.memory_read1.res_ram3.mem[i];
		
		$fscanf(pooling1_result,"%b",out0_ff);
		$fscanf(pooling1_result,"%b",out1_ff);
		$fscanf(pooling1_result,"%b",out2_ff);
		$fscanf(pooling1_result,"%b",out3_ff);

		if (out0 != out0_ff) begin 
		      error_count_layer12 = error_count_layer12 + 1;
		end
		if (out1 != out1_ff) begin 
		      error_count_layer12 = error_count_layer12 + 1;
		end
		if (out2 != out2_ff) begin 
		      error_count_layer12 = error_count_layer12 + 1;
		end
		if (out3 != out3_ff) begin 
		      error_count_layer12 = error_count_layer12 + 1;
		end

	end




	/*Layer 34 TESTING*/
	for (i = 1568; i < 1568+288; i = i + 1) begin
		out0 = testbench.mem_top1.memory_read1.res_ram0.mem[i];
		out1 = testbench.mem_top1.memory_read1.res_ram1.mem[i];
		out2 = testbench.mem_top1.memory_read1.res_ram2.mem[i];
		out3 = testbench.mem_top1.memory_read1.res_ram3.mem[i];
		
		$fscanf(pooling2_result,"%b",out0_ff);
		$fscanf(pooling2_result,"%b",out1_ff);
		$fscanf(pooling2_result,"%b",out2_ff);
		$fscanf(pooling2_result,"%b",out3_ff);

		if (out0 != out0_ff) begin 
		      error_count_layer34 = error_count_layer34 + 1;
		      $display ("Error of mem0 in position %d" ,i);
			$display ("npu out:" ,out0);
			$display ("file out:" ,out0_ff);
		end
		if (out1 != out1_ff) begin 
		      error_count_layer34 = error_count_layer34 + 1;
			$display ("Error of mem0 in position %d" ,i);
			$display ("npu out:" ,out1);
			$display ("file out:" ,out1_ff);
		end
		if (out2 != out2_ff) begin 
		      error_count_layer34 = error_count_layer34 + 1;
			$display ("Error of mem0 in position %d" ,i);
			$display ("npu out:" ,out2);
			$display ("file out:" ,out2_ff);
		end
		if (out3 != out3_ff) begin 
		      error_count_layer34 = error_count_layer34 + 1;
			$display ("Error of mem0 in position %d" ,i);
			$display ("npu out:" ,out3);
			$display ("file out:" ,out3_ff);
		end

	end


	/*Layer 5 TESTING*/
	for (i = 1568+288; i < 1568+288+128*4; i = i + 4) begin
		out0 = testbench.mem_top1.memory_read1.res_ram0.mem[i];
		out1 = testbench.mem_top1.memory_read1.res_ram0.mem[i+1];
		out2 = testbench.mem_top1.memory_read1.res_ram0.mem[i+2];
		out3 = testbench.mem_top1.memory_read1.res_ram0.mem[i+3];
		
		$fscanf(conv5_result,"%b",out0_ff);
		$fscanf(conv5_result,"%b",out1_ff);
		$fscanf(conv5_result,"%b",out2_ff);
		$fscanf(conv5_result,"%b",out3_ff);

		if (out3 != out0_ff) begin 
		      error_count_layer5 = error_count_layer5 + 1;
		      $display ("Error of mem0 in position %d" ,i);
			$display ("npu out:" ,out0);
			$display ("file out:" ,out0_ff);
		end
		if (out2 != out1_ff) begin 
		      error_count_layer5 = error_count_layer5 + 1;
			$display ("Error of mem1 in position %d" ,i);
			$display ("npu out:" ,out1);
			$display ("file out:" ,out1_ff);
		end

		if (out1 != out2_ff) begin 
		      error_count_layer5 = error_count_layer5 + 1;
			$display ("Error of mem2 in position %d" ,i);
			$display ("npu out:" ,out2);
			$display ("file out:" ,out2_ff);
		end
		if (out0 != out3_ff) begin 
		      error_count_layer5 = error_count_layer5 + 1;
			$display ("Error of mem3 in position %d" ,i);
			$display ("npu out:" ,out3);
			$display ("file out:" ,out3_ff);
		end

	end


	/*DENSE1*/
	for (i = 1568+288+128*4; i < 1568+288+128*4+32; i = i + 4) begin
		out0 = testbench.mem_top1.memory_read1.res_ram0.mem[i];
		out1 = testbench.mem_top1.memory_read1.res_ram0.mem[i+1];
		out2 = testbench.mem_top1.memory_read1.res_ram0.mem[i+2];
		out3 = testbench.mem_top1.memory_read1.res_ram0.mem[i+3];
		
		$fscanf(dense1_result,"%b",out0_ff);
		$fscanf(dense1_result,"%b",out1_ff);
		$fscanf(dense1_result,"%b",out2_ff);
		$fscanf(dense1_result,"%b",out3_ff);

			//$display ("npu out:%b" ,out3);
			//$display ("file out:%b" ,out0_ff);
			//$display ("npu out:%b" ,out2);
			//$display ("file out:%b" ,out1_ff);
			//$display ("npu out:%b" ,out1);
			//$display ("file out:%b" ,out2_ff);
			//$display ("npu out:%b" ,out0);
			//$display ("file out:%b" ,out3_ff);
		if (out3 != out0_ff) begin 
		      error_count_dense1 = error_count_dense1 + 1;
		      $display ("Error of mem0 in position %d" ,i);
			$display ("npu out:" ,out3);
			$display ("file out:" ,out0_ff);
		end
		if (out2 != out1_ff) begin 
		      error_count_dense1 = error_count_dense1 + 1;
			$display ("Error of mem1 in position %d" ,i+1);
			$display ("npu out:" ,out2);
			$display ("file out:" ,out1_ff);
		end
		if (out1 != out2_ff) begin 
		      error_count_dense1 = error_count_dense1 + 1;
			$display ("Error of mem2 in position %d" ,i+2);
			$display ("npu out:" ,out1);
			$display ("file out:" ,out2_ff);
		end
		if (out0 != out3_ff) begin 
		      error_count_dense1 = error_count_dense1 + 1;
			$display ("Error of mem3 in position %d" ,i+3);
			$display ("npu out:" ,out0);
			$display ("file out:" ,out3_ff);
		end

	end


        /*DENSE2*/
	for (i = 1568+288+128*4+32+9; i < 1568+288+128*4+32+10; i = i + 1) begin
		out0 = testbench.mem_top1.memory_read1.res_ram0.mem[i];

		
		$fscanf(dense2_result,"%b",out0_ff);


		if (out0 != out0_ff) begin 
		      error_count_dense2 = error_count_dense2 + 1;
		      $display ("Error of RESULT");
			$display ("npu out:" ,out0);
			$display ("file out:" ,out0_ff);
		end


	end

	/* ERROR DISPLAY*/
	$display ("Error of Layer 12 = %d" ,error_count_layer12);
	$display ("Error of Layer 34 = %d" ,error_count_layer34);
	$display ("Error of Layer 5 = %d" ,error_count_layer5);
	$display ("Error of Layer dense1 = %d" ,error_count_dense1);
	$display ("Error of Layer dense2 = %d" ,error_count_dense2);

	  $stop;

end

always begin
        `HALF_CLOCK_PERIOD;
        clk = ~clk;
end

endmodule
