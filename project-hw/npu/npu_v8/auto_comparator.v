/*
automatic comparator that will accept four 16-bit inputs together and compare
them to the previously stored largest number, and stored the largest number within them
for the next comparison
The index of largest number will be remembered and outputted (based on all previous inputs)
The current_largest_8bit only depends on current four inputs, will not consider results from previous cycles
*/

module auto_comparator (
    input signed [15:0] in1, in2, in3, in4,             // current inputs in 2's complement format
    input enable,                                       // enable signal
    input trig,                                         //triggering signal for conducting one comparison operation
    input clk,                                          // clock signal
    input reset,                                        //reset signal
    output reg [7:0] index,                             // index of the largest number from last reset(0 for resetting, 1 is the smallest valid number)
    output reg signed [15:0] largest,                   // store largest number of all previous inputs
    output reg signed [7:0]  current_largest_8bit       // store largest number of current four inputs (only current, will not consider previous results)
    ////////////////////////////////////////
    //the following ports are for debugging
    //output [15:0] largest_out,
    //output trig_delayed_out,
    //output [7:0] trig_counter_out
    
);

reg trig_delayed;                   // delayed triggering signal (delayed for one clock cycle)
reg [7:0] trig_counter;             //counting how many times the triggering event happens
reg signed [15:0] current_largest;  // storing the current largest 16-bit result of current cycle (will not consider previous cycles)

/*                     _______
trig:           ______|       |____________               (from EN_ReLU signal)
                               ________
trig_delayed:   ______________|        |_______________   (delay for one clock cycle)
*/

//configuring trig_delayed signal
always @(posedge clk) begin
    if (reset) trig_delayed<=0;
    else if (enable) trig_delayed<=trig;
end

//configuring trig_counter
always @(posedge clk) begin
    if (reset) trig_counter<=0;
    else if (enable & trig) trig_counter<=trig_counter+1'b1;        //increment when enable and trig (will increment before trig_delayed) 
end

//configuring the comparator
always @(posedge clk) begin
    if (reset) begin
        index<=0;                           //reserved number indicating resetted
        largest<=16'h8000;                  //smallest 16-bit 2's complement number
        //largest_8bit<=8'b1000000;           //smallest 8-bit 2's complement number
        current_largest<=16'h8000;          
        current_largest_8bit<=8'b1000000;
    end

    if (enable & trig_delayed) begin

        if (in1 >= in2 && in1 >= in3 && in1 >= in4) begin
            if (in1 > largest) begin
                largest <= in1;
                //largest_8bit <= sixteen_to_eight(in1);
                index <= (trig_counter << 2) - 2'b11;                  // index = trig_counter*4-3
            end
            else largest <= largest;

            ////////////////////////////////////////////////
            //current largest will not depend on previous largest
            current_largest<=in1;
            current_largest_8bit<=sixteen_to_eight(in1);
        end

        else if (in2 >= in1 && in2 >= in3 && in2 >= in4) begin
            if (in2 > largest) begin
                largest <= in2;
                //largest_8bit <= sixteen_to_eight(in2);
                index <= (trig_counter << 2) - 2'b10;                       // index = trig_counter*4-2
            end
            else largest <= largest;

            ////////////////////////////////////////////////
            //current largest will not depend on previous largest
            current_largest<=in2;
            current_largest_8bit<=sixteen_to_eight(in2);
        end

        else if (in3 >= in1 && in3 >= in2 && in3 >= in4) begin
            if (in3 > largest) begin
                largest <= in3;
                //largest_8bit <= sixteen_to_eight(in3);
                index <= (trig_counter << 2) - 1'b1;                  // index = trig_counter*4-1
            end
            else largest <= largest;

            ////////////////////////////////////////////////
            //current largest will not depend on previous largest
            current_largest<=in3;
            current_largest_8bit<=sixteen_to_eight(in3);
        end

        else begin // in4 >= in1 && in4 >= in2 && in4 >= in3
            if (in4 > largest) begin
                largest <= in4;
                //largest_8bit <= sixteen_to_eight(in4);
                index <= (trig_counter << 2);                  // index = trig_counter*4
            end
            else largest<=largest;

            ////////////////////////////////////////////////
            //current largest will not depend on previous largest
            current_largest<=in4;
            current_largest_8bit<=sixteen_to_eight(in4);
        end

    end
end

//debugging assigns
//assign trig_delayed_out = trig_delayed;
//assign trig_counter_out = trig_counter;

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

endmodule



