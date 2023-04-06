module acc_top(input logic        clk,
	        input logic 	   reset,
		input logic [31:0]  data,

		output logic [7:0] VGA_R, VGA_G, VGA_B,
		output logic 	   VGA_CLK, VGA_HS, VGA_VS,
		                   VGA_BLANK_n,
		output logic 	   VGA_SYNC_n);
