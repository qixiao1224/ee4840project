module mem_cntrl(input logic [31:0] in,
			input logic we,
			input logic clk,
			input logic [1:0] mode,
			output reg [31:0] out);

// Initialize memory modules
M10K_256_32 mem0(.q(), .d(), .write_address(), .read_address(), .we(), .clk());

endmodule
