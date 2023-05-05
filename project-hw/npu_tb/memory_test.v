`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD #1

`define IMG_INPUT "../../data/img0_z.txt"
`define CONV12_FILTER_INPUT "../../data/weight_bias_conv2d1.txt"
`define CONV34_FILTER_INPUT "../../data/weight_bias_conv2d2.txt"
`define CONV5_FILTER_INPUT "../../data/weight_bias_conv2d3.txt"
`define POOLING1_RESULT "../../data/pooling1_result_z.txt"
`define POOLING2_RESULT "../../data/pooling2_result_z.txt"

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
  
  //error counters
  reg [10:0] error_count_layer12;
  reg [10:0] error_count_layer34;
  reg [10:0] error_count_layer5;

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
pooling1_result = $fopen(`POOLING1_RESULT,"r");
pooling2_result = $fopen(`POOLING2_RESULT,"r");

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


if (!pooling1_result) begin 
    $display("Cannot Open POOLING RESULT 1!");
    $finish;
end

if (!pooling2_result) begin 
    $display("Cannot Open POOLING RESULT 2!");
    $finish;
end

//Start signal
clk = 0;
reset = 0;
writedata = 0;
error_count_layer12 = 0;
error_count_layer34 = 0;
error_count_layer5 = 0;

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
for (i = 0; i < 9248; i = i + 1)begin
    $fscanf(conv5_filter_input, "%8b", tmp4);
    writedata = tmp4;

    @(posedge clk);
end


 @(posedge clk);
 @(posedge clk);
 @(posedge clk);


//////////////////////Start Model Inferncing//////////////////////////////////////////////////////

control_reg = 32'h2;

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
        end
	if (out1 != out1_ff) begin 
              error_count_layer34 = error_count_layer34 + 1;
        end
	if (out2 != out2_ff) begin 
              error_count_layer34 = error_count_layer34 + 1;
        end
	if (out3 != out3_ff) begin 
              error_count_layer34 = error_count_layer34 + 1;
        end

end


/* ERROR DISPLAY*/
$display ("Error of Layer 12 = %d" ,error_count_layer12);
$display ("Error of Layer 34 = %d" ,error_count_layer34);

  $stop;

end

always begin
        `HALF_CLOCK_PERIOD;
        clk = ~clk;
end

endmodule
