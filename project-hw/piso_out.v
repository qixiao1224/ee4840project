module piso_out 
(  
  input EN_PISO_OUT, CLKEXT, CLR_PISO_OUT, SHIFT_OUT, 
  input [7:0] data_0, data_1, data_2, data_3,data_4,data_5,data_6,data_7,
  output reg [7:0] data_out
);
  
  // PISO register array to load and shift data
  ///////////////////////////////////////////////////////////////////
  /*
      leftmost    data_7--data_6--data_5--data_4--data_3--data_2--data_1--data_0--data_out      rightmost (output)
  */
  //////////////////////////////////////////////////////////////////
  
  reg [7:0] data_reg_1, data_reg_2, data_reg_3,data_reg_4,data_reg_5,data_reg_6,data_reg_7;
  

  always @ (posedge CLKEXT) begin

    if (CLR_PISO_OUT) begin
      data_out   <= 8'b00000000; // Reset PISO register array on reset
      data_reg_1 <= 8'b00000000; 
      data_reg_2 <= 8'b00000000; 
      data_reg_3 <= 8'b00000000; 
      data_reg_4 <= 8'b00000000; 
      data_reg_5 <= 8'b00000000; 
      data_reg_6 <= 8'b00000000;
      data_reg_7 <= 8'b00000000; 
    end

    else begin
      
      // Load the data to the PISO register array and reset the serial data out register
      if (~SHIFT_OUT && EN_PISO_OUT) begin
	      data_out   <= data_0;
      	data_reg_1 <= data_1;
	      data_reg_2 <= data_2;
	      data_reg_3 <= data_3;
        data_reg_4 <= data_4;
	      data_reg_5 <= data_5;
	      data_reg_6 <= data_6;
        data_reg_7 <= data_7;

      // Shift the loaded data 1 postion to right; into the serial data out register
	end
      else if(SHIFT_OUT && EN_PISO_OUT)
      	{data_reg_7, data_reg_6, data_reg_5, data_reg_4,data_reg_3, data_reg_2, data_reg_1, data_out} <= {8'b0, data_reg_7, data_reg_6, data_reg_5, data_reg_4, data_reg_3, data_reg_2, data_reg_1};
    end
  end
  
endmodule
