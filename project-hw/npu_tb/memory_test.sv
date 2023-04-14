`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD #1

module testbench(  );

  reg clk;
  reg reset;
  reg [31:0] writedata;
  reg write;
  reg chipselect;
  reg reading;

  wire [7:0] data0,data1,data2,data3;
  wire [13:0] ram_addr_output;
  wire [15:0] conv_ram_addr_output,dense_ram_addr_output;


  top_memory top_memory 
  (
    .clk(clk), 
    .reset(reset), 
    .writedata(writedata), 
    .write(write),
    .chipselect(chipselect), 
    .reading(reading),
    .ram_addr_output(ram_addr_output),//TODO Test signal
    .dense_ram_addr_output(dense_ram_addr_output),//TODO Test signal
    .conv_ram_addr_output(conv_ram_addr_output) ,//TODO Test signal



    .data0(data0), 
    .data1(data1),
    .data2(data2),
    .data3(data3)

  );


initial begin

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Example 1: Using PISO_OUT to get output, doing accumulation for a 3*3 kernel


//Initialization


reset = 0;
chipselect = 0;
writedata = 32'd0;
write = 0;
reading = 0;
clk = 0;




  @(posedge clk);


  @(posedge clk);
  reset = 1;      //global reset when booting up

  @(posedge clk);
  reset = 0;

  @(posedge clk);
  chipselect = 1;
  write = 1;

  @(posedge clk);
  write = 0;
 

  repeat (110000) begin
  @(posedge clk);
  writedata = writedata + 1;
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
