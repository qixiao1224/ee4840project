module ReLU
(
	input [15:0] Data_IN,
	input CLKEXT, 
	input reset,				//reset the output of ReLU to 0 (controlled by RST_GLO)
	input BYPASS,				//ReLU function will be bypassed if 1 (output will replicate any input)
	input EN_ReLU,
	output reg [15:0] ReLU_OUT
);


always @ (posedge CLKEXT)
	begin
		if (reset) ReLU_OUT<=0;

		if (EN_ReLU)begin

		case(Data_IN[15] & (!BYPASS))
			1'b0: ReLU_OUT <= Data_IN;
			1'b1: ReLU_OUT <= 16'b0;
		endcase

		end
	end

endmodule