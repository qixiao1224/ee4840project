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


  top_memory top_memory 
  (
    .clk(clk), 
    .reset(reset), 
    .writedata(writedata), 
    .write(write),
    .chipselect(chipselect), 
    .reading(reading),
 
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
  writedata = 32'b00001111_00000000_00000001_00110011;
  chipselect = 1;
  write = 1;





//////////////////////////////////////////////////////////////////////////////////////////////////////////

  repeat(15)  @(posedge clk); //give FSM a few cycles to complete output operation

//////////////////////////////////////////////////////////////////////////////////////////////////////////





  $stop;

end

always begin
        `HALF_CLOCK_PERIOD;
        clk = ~clk;
end

endmodule
