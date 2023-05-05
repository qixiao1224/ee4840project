`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD #1

`define IMG_INPUT "../img0_z.txt"
`define CONV_FILTER_INPUT "../weight_bias_conv2d1.txt"

`define POOLING1_RESULT "../pooling1_result.txt"

module testbench(  );

  reg clk;
  reg reset;

  reg [31:0] writedata;
  reg [31:0] control_reg;
  wire [7:0] D_OUT;

  integer img_input;
  integer conv_filter_input;
  integer conv1_result;
  integer i;
  integer pooling1_result;
  
  reg [10:0] error_count_layer12;

  reg [7:0] out0, out1, out2, out3;
  reg [7:0] out0_ff, out1_ff, out2_ff, out3_ff;

  reg [7:0] conv_filter_array;
  reg [7:0] conv1_result_array;
  reg  [7:0] img_array;
  reg [7:0] tmp0,tmp1,tmp2,tmp3,tmp4;
mem_top mem_top1( .clk(clk),
                 .reset(reset),
                 .writedata(writedata),
                 .control_reg(control_reg),
                 .D_OUT(D_OUT)
                );


initial begin

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Example 1: Using PISO_OUT to get output, doing accumulation for a 3*3 kernel

//Initialization


img_input = $fopen (`IMG_INPUT, "r");
conv_filter_input = $fopen (`CONV_FILTER_INPUT, "r");

pooling1_result = $fopen(`POOLING1_RESULT,"r");

if (!img_input) begin 
    $display("Cannot Open IMG!");
    $finish;
end

if (!conv_filter_input) begin 
    $display("Cannot Open IMG!");
    $finish;
end


if (!pooling1_result) begin 
    $display("Cannot Open IMG!");
    $finish;
end

clk = 0;
reset = 0;
writedata = 0;
error_count = 0;

@(posedge clk); 
reset = 1;


@(posedge clk);
reset = 0;

@(posedge clk);

control_reg = 32'b1;

@(posedge clk);



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

for (i = 0; i < 18815; i = i + 1)begin
    $fscanf(conv_filter_input, "%8b", tmp4);
    writedata = tmp4;

    @(posedge clk);
end

for (i = 0; i < 18815; i = i + 1)begin
    $fscanf(conv_filter_input, "%8b", tmp4);
    writedata = tmp4;

    @(posedge clk);
end


 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
//////////////////////////////////////////////////////////////////////////////////////////////////////////

control_reg = 32'h2;

  repeat(1000000)  @(posedge clk); //give FSM a few cycles to complete output operation

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
              error_count_layer12 = error_count + 1;
        end
	if (out1 != out1_ff) begin 
              error_count_layer12 = error_count + 1;
        end
	if (out2 != out2_ff) begin 
              error_count_layer12 = error_count + 1;
        end
	if (out3 != out3_ff) begin 
              error_count_layer12 = error_count + 1;
        end

end

/*Layer 34 TESTING*/
for (i = 1568; i < 1568+289; i = i + 1) begin
	out0 = testbench.mem_top1.memory_read1.res_ram0.mem[i];
        out1 = testbench.mem_top1.memory_read1.res_ram1.mem[i];
	out2 = testbench.mem_top1.memory_read1.res_ram2.mem[i];
	out3 = testbench.mem_top1.memory_read1.res_ram3.mem[i];
	
	$fscanf(pooling2_result,"%b",out0_ff);
	$fscanf(pooling2_result,"%b",out1_ff);
	$fscanf(pooling2_result,"%b",out2_ff);
	$fscanf(pooling2_result,"%b",out3_ff);

	if (out0 != out0_ff) begin 
              error_count_layer34 = error_count + 1;
        end
	if (out1 != out1_ff) begin 
              error_count_layer34 = error_count + 1;
        end
	if (out2 != out2_ff) begin 
              error_count_layer34 = error_count + 1;
        end
	if (out3 != out3_ff) begin 
              error_count_layer34 = error_count + 1;
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
