module input_buffer
(
	input EN_BUF_IN, CLR_BUF_IN, CLKEXT,
	input [7:0] a,
	input [7:0] b,
	input [7:0] c,
	input [7:0] d,
	input [7:0] e,
	input [7:0] f,
	input [7:0] g,
	input [7:0] h,
	output reg [7:0] out_a,
	output reg [7:0] out_b,
	output reg [7:0] out_c,
	output reg [7:0] out_d,
	output reg [7:0] out_e,
	output reg [7:0] out_f,
	output reg [7:0] out_g,
	output reg [7:0] out_h
);


	always @ (posedge CLKEXT) begin
	  if (CLR_BUF_IN) begin
	      out_a <= 8'b00000000;
	      out_b <= 8'b00000000;
	      out_c <= 8'b00000000;
	      out_d <= 8'b00000000;
		  out_e <= 8'b00000000;
	      out_f <= 8'b00000000;
	      out_g <= 8'b00000000;
	      out_h <= 8'b00000000;
	  end
	  
	  else begin
	    if (EN_BUF_IN) begin
	      out_a <= a;
	      out_b <= b;
	      out_c <= c;
	      out_d <= d;
		  out_e <= e;
	      out_f <= f;
	      out_g <= g;
	      out_h <= h;
	    end
	  end
	end

endmodule
