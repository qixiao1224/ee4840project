module npu_top
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
  input SEL_CON,
  input EN_FSM,
  input RD_EN,
  input EN_CONFIG,
  input RST_GLO,
  output FULL,
  output EMPTY,
  output [7:0] D_OUT,
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  //the following ports are for debugging(for testbench use not for PISO_DEB)
  output FSM_EN_ReLU1_output, FSM_SHIFT_OUT_output, FSM_CLR_PISO_OUT_output,
  output FSM_EN_PISO_OUT_output, FSM_EN_MAC1_output, FSM_EN_BUF_IN_output, FSM_CLR_BUF_IN_output, FSM_RST_MAC1_output,
  output [7:0] piso_output,
  output [15:0] MAC1_output, ReLU1_output, MAC2_output, ReLU2_output
);

  //The wire starting with FSM means it comes from FSM, the one starting with NPU means it is connected to the input port of npu_v7 
  wire FSM_EN_MAC, NPU_EN_MAC;            
  wire FSM_RST_MAC, NPU_RST_MAC;
  wire FSM_EN_ReLU, NPU_EN_ReLU;
  wire FSM_EN_PISO_OUT, NPU_EN_PISO_OUT;
  wire FSM_CLR_PISO_OUT, NPU_CLR_PISO_OUT;
  wire FSM_SHIFT_OUT, NPU_SHIFT_OUT;
  wire FSM_EN_BUF_IN, NPU_EN_BUF_IN;
  wire FSM_CLR_BUF_IN, NPU_CLR_BUF_IN;
  wire FSM_WR_EN;   //for connecting the WR_EN from FSM to NPU core (there is no manual WR_EN, it only comes from FSM)
  
  wire [15:0] SSFR_OUT;

  wire CTR_OUT,OUT_DONE;    //debugging signals from FSM that are connected to PISO_DEB in npu_v7
  
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //initiation of FSM

  FSM FSM1 
  (    
    .DB(DB), 
    .DD(DD), 
    .clk(CLKEXT), 
    .reset(RST_GLO),
    .enable(SEL_CON),                        // if SEL_CON=1 , the FSM will be enabled    
    .EN_FSM(EN_FSM),                
    .EN_BUF_IN(FSM_EN_BUF_IN), 
    .CLR_BUF_IN(FSM_CLR_BUF_IN), 
    .EN_MAC(FSM_EN_MAC), 
    .RST_MAC(FSM_RST_MAC), 
    .EN_ReLU(FSM_EN_ReLU),  
    .CLR_PISO_OUT(FSM_CLR_PISO_OUT), 
    .SHIFT_OUT(FSM_SHIFT_OUT),
    .EN_PISO_OUT(FSM_EN_PISO_OUT), 
    .WR_EN(FSM_WR_EN),
    .CTR_OUT(CTR_OUT),                //debugging output connected to PISO_DEB
    .OUT_DONE(OUT_DONE)               //debugging output connected to PISO_DEB
  );
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //initiation of npu core
  npu_v8 npu_v8_1   
  ( 
    .DA(DA), 
    .DB(DB), 
    .DC(DC), 
    .DD(DD), 
    .DE(DE), 
    .DF(DF), 
    .DG(DG), 
    .DH(DH),
    .CLKEXT(CLKEXT), 
    .RST_GLO(RST_GLO),
    .EN_MAC(NPU_EN_MAC), 
    .RST_MAC(NPU_RST_MAC), 
    .EN_ReLU(NPU_EN_ReLU),  
    .EN_PISO_OUT(NPU_EN_PISO_OUT), 
    .CLR_PISO_OUT(NPU_CLR_PISO_OUT),
    .SHIFT_OUT(NPU_SHIFT_OUT), 
    .EN_BUF_IN(NPU_EN_BUF_IN), 
    .CLR_BUF_IN(NPU_CLR_BUF_IN), 
    .D_OUT(D_OUT), 
    .RD_EN(RD_EN),
    .WR_EN(FSM_WR_EN),
    .SSFR(SSFR_OUT),
    .CTR_OUT(CTR_OUT),          //only for debugging
    .OUT_DONE(OUT_DONE),        //only for debugging
    .SEL_CON(SEL_CON),
    .FULL(FULL),
    .EMPTY(EMPTY),
    ///////////////////////////////////
    //the following ports are for debugging in testbench
    .MAC1_output(MAC1_output),
    .ReLU1_output(ReLU1_output),
    .MAC2_output(MAC2_output),
    .ReLU2_output(ReLU2_output),
    .piso_output(piso_output)
  );
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //initiation of SSFR
  SSFR SSFR_0(
    .data_in({DA,DB}),
    .clk(CLKEXT),
    .enable(EN_CONFIG),
    .reset(RST_GLO),
    .data_out(SSFR_OUT)
  );
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //control MUX specificatin
  // If SEL_CON then control the NPU with FSM generated signal
  // If ~SEL_CON then control the NPU with external signal (reuse DC[7:0] port)
  /*
    DC[7]	EXT_EN_BUF_IN
    DC[6]	EXT_CLR_BUF_IN
    DC[5]	EXT_EN_MAC
    DC[4]	EXT_RST_MAC
    DC[3]	EXT_EN_ReLU
    DC[2]	EXT_SHIFT_OUT
    DC[1]	EXT_EN_PISO_OUT
    DC[0]	EXT_CLR_PISO_OUT
  */
  assign NPU_EN_MAC       = SEL_CON ? FSM_EN_MAC : DC[5];
  assign NPU_RST_MAC      = SEL_CON ? FSM_RST_MAC : DC[4];
  assign NPU_EN_ReLU      = SEL_CON ? FSM_EN_ReLU : DC[3];
  assign NPU_EN_PISO_OUT  = SEL_CON ? FSM_EN_PISO_OUT : DC[1];
  assign NPU_CLR_PISO_OUT = SEL_CON ? FSM_CLR_PISO_OUT : DC[0];
  assign NPU_SHIFT_OUT    = SEL_CON ? FSM_SHIFT_OUT : DC[2];
  assign NPU_EN_BUF_IN    = SEL_CON ? FSM_EN_BUF_IN : DC[7]; 
  assign NPU_CLR_BUF_IN   = SEL_CON ? FSM_CLR_BUF_IN : DC[6];
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////


  /////////////////////////////////////////////////////////////////////
  //debugging wires for testbench use
  assign FSM_EN_MAC1_output = FSM_EN_MAC;
  assign FSM_EN_PISO_OUT_output = FSM_EN_PISO_OUT;
  assign FSM_EN_BUF_IN_output = FSM_EN_BUF_IN;
  assign FSM_CLR_BUF_IN_output = FSM_CLR_BUF_IN;
  assign FSM_RST_MAC1_output = FSM_RST_MAC;
  assign FSM_EN_ReLU1_output = FSM_EN_ReLU;
  assign FSM_SHIFT_OUT_output = FSM_SHIFT_OUT;
  assign FSM_CLR_PISO_OUT_output = FSM_CLR_PISO_OUT;
  ///////////////////////////////////////////////////////////////////////////


endmodule


