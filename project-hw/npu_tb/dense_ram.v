module dense_ram( 
    output reg [7:0] q,
    input [7:0] data,
    input [14:0] rdaddress,wraddress,
    input wren, clock
);
	 // force M10K ram style
    reg [7:0] mem [32767:0]  /* synthesis ramstyle = "no_rw_check, M10K" */;
	 
    always @ (posedge clock) begin
        if (wren) begin
            mem[wraddress] <= data;
        end
        q <= mem[rdaddress]; // q doesn't get d in this clock cycle
    end
endmodule

