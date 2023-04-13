module image_ram( 
    output reg [7:0] q,
    input [7:0] data,
    input [13:0] address,
    input wren, clock
);
	 // force M10K ram style
    reg [7:0] mem [16383:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clock) begin
        if (wren) begin
            mem[address] <= data;
        end
        q <= mem[address]; // q doesn't get d in this clock cycle
    end
endmodule

