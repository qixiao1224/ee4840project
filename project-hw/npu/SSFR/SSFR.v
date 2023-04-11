/*
//////////////////////////////////////////////////////////////////////////////////////////////////
Specification Table of SSFR[15:0]
SSFR[15]	  SSFR[14]	  SSFR[13]	  SSFR[12]	    SSFR[11]	    SSFR[10]	    SSFR[9]	       SSFR[8]
SEL_OUT[2]	SEL_OUT[1]	SEL_OUT[0]	BYPASS_ReLU1	BYPASS_ReLU2	BYPASS_ReLU3	BYPASS_ReLU4	 EN_COMP

SSFR[7]	    SSFR[6]	    SSFR[5]	    SSFR[4]	      SSFR[3]	      SSFR[2]	SSFR[1]	SSFR[0]
RST_COMP	  EN_FIFO     RST_FIFO    EN_CONV       RST_CONV      unused  unused  unused

Default Values (if reset)
SSFR[15:8]	SSFR[7:0]						
00100000	  10101000
/////////////////////////////////////////////////////////////////////////////////////////////////
*/

module SSFR (
    input [15:0] data_in,
    input clk,
    input enable,
    input reset,
    output reg [15:0] data_out
);
    always @(posedge clk) begin
        if (reset) data_out<=16'b0010_0000_1010_1000;
        else if (enable) begin
            data_out<=data_in;
        end
    end
    
endmodule