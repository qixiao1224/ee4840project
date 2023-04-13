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
module npu_v8
(
  input [7:0] DA,
  input [7:0] DB,
  input [7:0] DC,
  input [7:0] DD,
  input [7:0] DE,
  input [7:0] DF,
  input [7:0] DG,
  input [7:0] DH,
  input CLKEXT,
  input RST_GLO,
  input EN_MAC, RST_MAC, EN_ReLU,
  input EN_PISO_OUT, CLR_PISO_OUT, SHIFT_OUT,
  input EN_BUF_IN, CLR_BUF_IN,
  input RD_EN,
  input WR_EN,
  input [15:0] SSFR,
  input CTR_OUT,OUT_DONE,   //signals from FSMs that are just for debugging (connected to PISO_DEB)
  input SEL_CON,            //used to disable MAC2 and ReLU2 when switches to manual control
  output FULL,
  output EMPTY,
  output reg [7:0] D_OUT,
  ////////////////////////////////////////////////////////////
  //the following ports are for debugging(for testbench use only)
  output [7:0] piso_output,
  output [15:0] MAC1_output, ReLU1_output, MAC2_output, ReLU2_output
);

  wire [7:0] input_buffer_out_a, input_buffer_out_b, input_buffer_out_c, input_buffer_out_d;
  wire [7:0] input_buffer_out_e, input_buffer_out_f, input_buffer_out_g, input_buffer_out_h;
  wire [15:0] MAC1_result, MAC2_result,MAC3_result, MAC4_result;
  wire [15:0] ReLU1_OUT, ReLU2_OUT,ReLU3_OUT, ReLU4_OUT;
  wire [7:0]  piso_out_out;
  //wire [15:0] CON_SIG;
  wire [7:0] FIFO_OUT;
  wire [7:0] COMP_INDEX;
  wire [15:0] COMP_LARGEST;
  wire [7:0] COMP_LARGEST_8bit;
  wire [7:0] CONV_OUT;
  
////////////////////////////////////////////////////////////////////////////
//initiation of input buffer
  wire CLR_BUF_IN_LOGIC;                                //actual wire connected to the module for CLR_BUF_IN
  assign CLR_BUF_IN_LOGIC = CLR_BUF_IN | RST_GLO;       //OR reset logic

  input_buffer buffer1 
  (
    .EN_BUF_IN(EN_BUF_IN), 
    .CLR_BUF_IN(CLR_BUF_IN_LOGIC), 
    .CLKEXT(CLKEXT), 
    .a(DA), 
    .b(DB), 
    .c(DC), 
    .d(DD), 
    .e(DE), 
    .f(DF), 
    .g(DG), 
    .h(DH), 
    .out_a(input_buffer_out_a), 
    .out_b(input_buffer_out_b), 
    .out_c(input_buffer_out_c), 
    .out_d(input_buffer_out_d),
    .out_e(input_buffer_out_e), 
    .out_f(input_buffer_out_f), 
    .out_g(input_buffer_out_g), 
    .out_h(input_buffer_out_h)
  );
///////////////////////////////////////////////////////////////////////////////
//initiation of MACs

  wire EN_MAC234_LOGIC;                                           //actual wire connected to the mac2, mac3 and mac4 module for EN_MAC
  assign EN_MAC234_LOGIC = EN_MAC  & (SEL_CON);                   //automatically disabled if in manual mode     

  MAC MAC1 
  (
    .EN_MAC(EN_MAC), 
    .RST_MAC(RST_MAC), 
    .CLKEXT(CLKEXT), 
    .a(input_buffer_out_a), 
    .b(input_buffer_out_b), 
    .BIAS_IN(DA), 
    .MAC_result(MAC1_result),
    .reset(RST_GLO)
  );

  MAC MAC2 
  (
    .EN_MAC(EN_MAC234_LOGIC), 
    .RST_MAC(RST_MAC), 
    .CLKEXT(CLKEXT), 
    .a(input_buffer_out_c), 
    .b(input_buffer_out_d), 
    .BIAS_IN(DC), 
    .MAC_result(MAC2_result),
    .reset(RST_GLO)
  );

    MAC MAC3 
  (
    .EN_MAC(EN_MAC234_LOGIC), 
    .RST_MAC(RST_MAC), 
    .CLKEXT(CLKEXT), 
    .a(input_buffer_out_e), 
    .b(input_buffer_out_f), 
    .BIAS_IN(DE), 
    .MAC_result(MAC3_result),
    .reset(RST_GLO)
  );

    MAC MAC4 
  (
    .EN_MAC(EN_MAC234_LOGIC), 
    .RST_MAC(RST_MAC), 
    .CLKEXT(CLKEXT), 
    .a(input_buffer_out_g), 
    .b(input_buffer_out_h), 
    .BIAS_IN(DG), 
    .MAC_result(MAC4_result),
    .reset(RST_GLO)
  );
////////////////////////////////////////////////////////////////////////////////////
//initiation of ReLUs

  wire EN_ReLU234_LOGIC;                                            //actual wire connected to the ReLU2 module for EN_ReLU
  assign EN_ReLU234_LOGIC = EN_ReLU & (SEL_CON);                    //automatically disabled if in debug mode or manual mode

  ReLU ReLU1 
  (
    .Data_IN(MAC1_result), 
    .EN_ReLU(EN_ReLU), 
    .CLKEXT(CLKEXT), 
    .ReLU_OUT(ReLU1_OUT),
    .reset(RST_GLO),
    .BYPASS(SSFR[12])
  );

  ReLU ReLU2 
  (
    .Data_IN(MAC2_result), 
    .EN_ReLU(EN_ReLU234_LOGIC), 
    .CLKEXT(CLKEXT), 
    .ReLU_OUT(ReLU2_OUT),
    .reset(RST_GLO),
    .BYPASS(SSFR[11])
  );

  ReLU ReLU3 
  (
    .Data_IN(MAC3_result), 
    .EN_ReLU(EN_ReLU234_LOGIC), 
    .CLKEXT(CLKEXT), 
    .ReLU_OUT(ReLU3_OUT),
    .reset(RST_GLO),
    .BYPASS(SSFR[10])
  );

  ReLU ReLU4 
  (
    .Data_IN(MAC4_result), 
    .EN_ReLU(EN_ReLU234_LOGIC), 
    .CLKEXT(CLKEXT), 
    .ReLU_OUT(ReLU4_OUT),
    .reset(RST_GLO),
    .BYPASS(SSFR[9])
  );

////////////////////////////////////////////////////////////////////////////////////
//initiation of PISO_OUT
  wire CLR_PISO_OUT_LOGIC;                                  //actual wire connected to the module for CLR_PISO_OUT
  assign CLR_PISO_OUT_LOGIC = CLR_PISO_OUT | RST_GLO;       //OR reset logic

  piso_out piso_out1 
  (
    .EN_PISO_OUT(EN_PISO_OUT), 
    .CLR_PISO_OUT(CLR_PISO_OUT_LOGIC), 
    .SHIFT_OUT(SHIFT_OUT), 
    .CLKEXT(CLKEXT), 
    .data_0(ReLU4_OUT[15:8]), 
    .data_1(ReLU4_OUT[7:0]), 
    .data_2(ReLU3_OUT[15:8]), 
    .data_3(ReLU3_OUT[7:0]), 
    .data_4(ReLU2_OUT[15:8]), 
    .data_5(ReLU2_OUT[7:0]), 
    .data_6(ReLU1_OUT[15:8]), 
    .data_7(ReLU1_OUT[7:0]), 
    .data_out(piso_out_out)
  );

////////////////////////////////////////////////////////////////////////////////////
//initiation of output FIFO
  wire RST_FIFO_LOGIC;                                      //actual wire connected to the module for RST_FIFO
  assign RST_FIFO_LOGIC = SSFR[5] | RST_GLO;                //OR reset logic

  wire WR_EN_LOGIC;
  assign WR_EN_LOGIC = (!FULL) & WR_EN;                     //write operation disabled if full

  wire RD_EN_LOGIC;
  assign RD_EN_LOGIC = (!EMPTY) & RD_EN;                    //read operation disabled if empty

  syn_fifo #(.WIDTH(8),.DEPTH(128)) syn_fifo_1
  (
    .clk(CLKEXT),
    .rst(RST_FIFO_LOGIC),
    .enable(SSFR[6]),
    .wr_en(WR_EN_LOGIC),
    .rd_en(RD_EN_LOGIC),
    .data_in(piso_out_out),
    .data_out(FIFO_OUT),
    .full(FULL),
    .empty(EMPTY)

  );
////////////////////////////////////////////////////////////////////////////////////
//initiation of comparator
  wire RST_COMP_LOGIC;                                      //actual wire connected to the module for RST_COMP
  assign RST_COMP_LOGIC = SSFR[7] | RST_GLO;                //OR reset logic

  auto_comparator comparator1(
    .in1(ReLU1_OUT),
    .in2(ReLU2_OUT),
    .in3(ReLU3_OUT),
    .in4(ReLU4_OUT),
    .enable(SSFR[8]),
    .trig(EN_ReLU),
    .clk(CLKEXT),
    .reset(RST_COMP_LOGIC),
    .index(COMP_INDEX),
    .largest(COMP_LARGEST),
    .current_largest_8bit(COMP_LARGEST_8bit)
  );

////////////////////////////////////////////////////////////////////////////////////
//initiation of data converter
  wire RST_CONV_LOGIC;                                      //actual wire connected to the module for RST_CONV
  assign RST_CONV_LOGIC = SSFR[3] | RST_GLO;                //OR reset logic

  data_converter data_converter1(
    .clk(CLKEXT),
    .in(piso_out_out),
    .trig(EN_PISO_OUT),
    .enable(SSFR[4]),
    .reset(RST_CONV_LOGIC),
    .out(CONV_OUT)
  );


////////////////////////////////////////////////////////////////////////////////////
//specification of output mux
  always @(*) begin
    case (SSFR[15:13])
      3'b000: D_OUT = FIFO_OUT;
      3'b001: D_OUT = piso_out_out;
      3'b010: D_OUT = CONV_OUT;
      3'b011: D_OUT = COMP_INDEX;
      3'b100: D_OUT = COMP_LARGEST[15:8];
      3'b101: D_OUT = COMP_LARGEST[7:0];
      3'b110: D_OUT = COMP_LARGEST_8bit;

      default: D_OUT = 8'b0;
    endcase
  end

///////////////////////////////////////////////////////////////////////////////////
//debugging assigns for testbench, not for PISO_DEB
  assign MAC1_output = MAC1_result;
  assign MAC2_output = MAC2_result;
  assign ReLU1_output = ReLU1_OUT;
  assign ReLU2_output = ReLU2_OUT;
  assign piso_output = piso_out_out;

endmodule
