`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD #1

`define IMG_INPUT "../img0_z.txt"
`define CONV_FILTER_INPUT "../weight_bias_conv2d1.txt"
`define CONV1_RESULT "../conv2d1_result.txt"

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
conv1_result = $fopen (`CONV1_RESULT, "r");


if (!img_input) begin 
    $display("Cannot Open IMG!");
    $finish;
end

if (!conv_filter_input) begin 
    $display("Cannot Open IMG!");
    $finish;
end

if (!conv1_result) begin 
    $display("Cannot Open IMG!");
    $finish;
end

clk = 0;
reset = 0;
writedata = 0;

@(posedge clk); 
reset = 1;


@(posedge clk);
reset = 0;

@(posedge clk);
@(posedge clk);
@(posedge clk);
control_reg = 32'b1;

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




 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
//////////////////////////////////////////////////////////////////////////////////////////////////////////

control_reg = 32'h2;

  repeat(1000000)  @(posedge clk); //give FSM a few cycles to complete output operation

//////////////////////////////////////////////////////////////////////////////////////////////////////////





  $stop;

end

always begin
        `HALF_CLOCK_PERIOD;
        clk = ~clk;
end

endmodule
