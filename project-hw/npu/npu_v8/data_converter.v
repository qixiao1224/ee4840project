/*
This module converts 16 bit binary number to 8 bit binary number, both in 2's complement format
The input width and output width are both 8-bit, thus it takes two cycles to import one 16-bit data

Generally the module uses truncation method, assuming the decimal point is in middle for both input and output
Special operations such as rounding, overflow/underflow control are also included

Policy for dealing with fixed-point number is copied from MATLAB fixed-point operations
*/

module data_converter (
    input clk,
    input [7:0] in,
    input trig,             //similar trigger signal to comparator, for conducting one conversion
    input enable,
    input reset,

    output reg [7:0] out

    /////////////////////////////
    //the followings are debugging ports
    //output trig_delayed_output,
    //output [15:0] buffer_output,
    //output MSB_flag_output

);

reg trig_delayed;           // delayed triggering signal (delayed for one clock cycle)
reg [15:0] buffer;          //buffer region to store one complete 16-bit number dynamically
reg [15:0] buffer_stable;   //buffer to store stable 16-bit number
reg MSB_flag;               //flag used to indicate the current 8-bit value belongs to MSB (1 for MSB, 0 for LSB)

/*                     ________________
trig:           ______|                |____________               (from EN_PISO_OUT signal)
                               ________________
trig_delayed:   ______________|                |_______________   (delay for one clock cycle)
*/

//configuring trig_delayed signal
always @(posedge clk) begin
    if (reset) trig_delayed<=0;
    else if (enable) trig_delayed<=trig;
end

//configuring the data coversion
always @(posedge clk) begin
    if (reset) begin
        //out<=0;
        buffer<=0;
        MSB_flag<=1;                        //MSBs will come before LSB from PISO_OUT
    end

    else if (enable & trig_delayed) begin
        if (MSB_flag) begin
            buffer[15:8]<=in;
            MSB_flag<=0;
            buffer_stable<=buffer;          //put previous concatnated 16-bit result to a stable buffer region for conversion 
        end

        else begin
            buffer[7:0]<=in;
            MSB_flag<=1;
        end
    end
end

always @(posedge MSB_flag) begin
  out = sixteen_to_eight(buffer);
end

/////////////////////////////////////////////////////////////////////////////////
//function used to convert 16b binary number to 8b (following 2's complement rules)

function reg [7:0] sixteen_to_eight(input [15:0] sixteen);
  begin
    if (sixteen[15] == 0) begin                                 //if the input is positive
      if (sixteen[15:11] != 0)                                  //saturation control (overflow)
        sixteen_to_eight = 8'b01111111;
      else if (sixteen[11:3] == 9'b011111111)                   //special condition to avoid rounding
        sixteen_to_eight = 8'b01111111;
      else if (sixteen[3])                                      //rounding situation
        sixteen_to_eight = sixteen[11:4] + 1;
      else
        sixteen_to_eight = sixteen[11:4];                       //regular truncating operation, without rounding or saturatin issue
    end

    else begin                                                 //if the input is negative
      if (sixteen[15:11] != 5'b11111)                          //saturaton control (underflow)
        sixteen_to_eight = 8'b10000000;
      else if (sixteen[3])                                     //rounding situation
        sixteen_to_eight = sixteen[11:4] + 1;
      else                                                     //regular truncating operation, without rounding or saturatin issue
        sixteen_to_eight = sixteen[11:4];
    end
  end
endfunction

///////////////////////////////////////////
//debugging connections
//assign trig_delayed_output = trig_delayed;
//assign MSB_flag_output = MSB_flag;
//assign buffer_output = buffer;
    
endmodule