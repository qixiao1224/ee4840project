`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD #1

module testbench(  );

  reg clk;
  reg reset;

  reg [7:0] read0,read1,read2,read3,read_conv;
  wire [7:0] out0,out1,out2,out3,out_param;
  wire [14:0] conv_ram_addr;
  wire [9:0] image_ram_addr;
  wire [7:0] u0,u1,u2,u3,u4,u5,u6,u7,u8,u9,u10,u11,u12,u13,u14,u15;
  wire [13:0] ram_addr_a, ram_addr_b;
     wire [2:0] ram_num;
     wire start_write_back, stop_write_back;
     wire wr_en; //top write back signal
     wire [13:0] ram_store_addr;
memory_read_layer12_test memory1
(.clk(clk),
 .reset(reset),    
.read_image0(read0), 
.read_image1(read1), 
.read_image2(read2), 
.read_image3(read3),
.read_conv(read_conv),
.out0(out0),
.out1(out1), 
.out2(out2), 
.out3(out3), 
.out_param(out_param),
.image_ram_addr(image_ram_addr),
.conv_ram_addr(conv_ram_addr),
.u0(u0),
.u1(u1),
.u2(u2),
.u3(u3),
.u4(u4),
.u5(u5),
.u6(u6),
.u7(u7),
.u8(u8),
.u9(u9),
.u10(u10),
.u11(u11),
.u12(u12),
.u13(u13),
.u14(u14),
.u15(u15),
.ram_addr_a_test(ram_addr_a),
.ram_addr_b_test(ram_addr_b),
.ram_num(ram_num),
.start_write_back(start_write_back),
.stop_write_back(stop_write_back),
.wr_en(wr_en),
.ram_store_addr(ram_store_addr)
);


initial begin

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Example 1: Using PISO_OUT to get output, doing accumulation for a 3*3 kernel


//Initialization

reset = 0;
clk = 0;
read0 = 0;
read1 = 0;
read2 = 0;
read3 = 0;
read_conv=8'd2;





@(posedge clk);
reset = 1;


@(posedge clk);
reset = 0;
 

  repeat (800000) begin
  @(posedge clk);
  read0 = read0 +1;
  read1 = read1 +1;
  read2 = read2 +1;
  read3 = read3 +1;
  end





//////////////////////////////////////////////////////////////////////////////////////////////////////////

  repeat(10)  @(posedge clk); //give FSM a few cycles to complete output operation

//////////////////////////////////////////////////////////////////////////////////////////////////////////





  $stop;

end

always begin
        `HALF_CLOCK_PERIOD;
        clk = ~clk;
end

endmodule
