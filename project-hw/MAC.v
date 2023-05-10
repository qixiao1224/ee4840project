module MAC
(
	input [7:0] a,
	input [7:0] b,
	input reset,						//reset signal for resetting output to 0 (controlled by RST_GLO)
	input [7:0] BIAS_IN,
	input CLKEXT, EN_MAC, RST_MAC,
	output reg [15:0] MAC_result
); 

	// Declare registers and wires

	wire [15:0] old_result, adder_out, mult_result;
	
	sixtheen_bit_sat_adder adder1 (.a(mult_result),.b(old_result),.adder_out(adder_out));
	
	// Store the results of the operations on the current data
	
	assign mult_result = {{8{a[7]}},a[7:0]}*{{8{b[7]}},b[7:0]};	
	assign old_result = MAC_result;

	// Clear or update data, as appropriate
	always @ (posedge CLKEXT) begin
		if (reset) MAC_result<=0;

		else if (EN_MAC) begin
			if (RST_MAC) MAC_result <= {{4{BIAS_IN[7]}}, BIAS_IN, 4'b0};
			else         MAC_result <= adder_out;
		end
	end
endmodule



 module sixtheen_bit_sat_adder
(
	input [15:0] a, b,
	output reg [15:0] adder_out
);

	wire [16:0] temp;
	assign temp = {a[15],a} + {b[15],b};
	
	always @ (*) begin	

		case (temp[16:15]) 
			2'b00 : adder_out = temp[15:0];
			2'b01 : adder_out = 16'h7FFF;
			2'b10 : adder_out = 16'h8000;
			2'b11 : adder_out = temp[15:0];
		endcase
	end
	
endmodule
