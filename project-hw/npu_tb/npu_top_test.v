`timescale 1ns/1ps
`define HALF_CLOCK_PERIOD #1

//////////////////////////////////////////////////////////////////////////////////
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

module testbench(  );

  reg [7:0] DA,DB,DC,DD,DE,DF,DG,DH;
  reg CLKEXT;
  reg SEL_CON;
  reg EN_FSM;
  reg RD_EN;
  reg EN_CONFIG;
  reg RST_GLO;
  wire FULL;
  wire EMPTY;
  wire [7:0] D_OUT;

//////////////////////
//debugging purpose
  wire FSM_EN_ReLU1_output, FSM_SHIFT_OUT_output, FSM_CLR_PISO_OUT_output;
  wire FSM_EN_PISO_OUT_output, FSM_EN_MAC1_output, FSM_EN_BUF_IN_output, FSM_CLR_BUF_IN_output, FSM_RST_MAC1_output;
  wire [7:0] piso_output;
  wire [15:0] MAC1_output, ReLU1_output, MAC2_output, ReLU2_output;
//////////

  npu_top npu_top 
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
    .SEL_CON(SEL_CON), 
    .EN_FSM(EN_FSM), 
    .D_OUT(D_OUT), 
    .RD_EN(RD_EN),
    .EN_CONFIG(EN_CONFIG),
    .RST_GLO(RST_GLO),
    .FULL(FULL),
    .EMPTY(EMPTY),
    ///////////////////////////////
    //the following for debugging purpose
    .MAC1_output(MAC1_output),
    .MAC2_output(MAC2_output),
    .ReLU1_output(ReLU1_output),
    .ReLU2_output(ReLU2_output),
    .FSM_EN_PISO_OUT_output(FSM_EN_PISO_OUT_output),
    .FSM_RST_MAC1_output(FSM_RST_MAC1_output),
    .FSM_EN_MAC1_output(FSM_EN_MAC1_output),
    .FSM_EN_ReLU1_output(FSM_EN_ReLU1_output),
    .FSM_CLR_BUF_IN_output(FSM_CLR_BUF_IN_output),
    .FSM_EN_BUF_IN_output(FSM_EN_BUF_IN_output),
    .FSM_CLR_PISO_OUT_output(FSM_CLR_PISO_OUT_output),
    .FSM_SHIFT_OUT_output(FSM_SHIFT_OUT_output),
    .piso_output(piso_output)
  );


initial begin

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Example 1: Using PISO_OUT to get output, doing accumulation for a 3*3 kernel

  DA=0;DB=0;DC=0;DD=0;DE=0;DF=0;DG=0;DH=0;
  CLKEXT=0;
  SEL_CON=1;        //set to FSM auto mode
  EN_FSM=0;
  RD_EN=0;
  EN_CONFIG=0;
  RST_GLO=0;

  @(posedge CLKEXT);
  RST_GLO=1;      //global reset when booting up

  @(posedge CLKEXT);
  RST_GLO=0;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  @(posedge CLKEXT);
  EN_FSM=1;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  @(posedge CLKEXT);  //only compute for one neuron
  EN_FSM=0;

  @(negedge CLKEXT);  //begin to load data
  DA=8'b0000_0001;    //bias for MAC1
  DC=8'b0000_0001;    //bias for MAC2
  DE=8'b0000_0001;    //bias for MAC3
  DG=8'b0000_0001;    //bias for MAC4

  //CTR[15:8] represents the number of accumulation for current neuron
  //e.g. for a 3*3 kernel this should be 9
  DB=8'b0000_0000;    //CTR[15:8]
  DD=8'b0000_1001;    //CTR[7:0]

  //DF and DH are don't care terms in this cycle

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  repeat(9) begin     //repeat for 9 cycles, assuming doing the accumulation for one 3*3 kernel

  @(posedge CLKEXT);  //do nothing at postive edge
  @(negedge CLKEXT);  //load one data at each negative edge, in this case the data for each cycle is same
  DA=8'b0000_0001;    //pixel value for MAC1
  DB=8'b0000_0010;    //weight for MAC1
  DC=8'b0000_0001;    //pixel value for MAC2
  DD=8'b0000_0010;    //weight for MAC2
  DE=8'b0000_0001;    //pixel value for MAC3
  DF=8'b0000_0010;    //weight for MAC3
  DG=8'b0000_0001;    //pixel value for MAC4
  DH=8'b0000_0010;    //weight for MAC4

  end

  @(posedge CLKEXT);  //turn for EN_CONFIG for configuring SSFR
  EN_CONFIG=1;        //If EN_CONFIG is low for this cycle, the content of SSFR will remain unchanged 

  @(negedge CLKEXT);  //SSFR configuration, now setting to PISO_OUT option (same as default)
  DA=8'b0010_0000;    //SSFR[15:8]
  DB=8'b1010_1000;    //SSFR[7:0]

  @(posedge CLKEXT);
  EN_CONFIG=0;        //EN_CONFIG must be turned off after one cycle


//////////////////////////////////////////////////////////////////////////////////////////////////////////

  repeat(15)  @(posedge CLKEXT); //give FSM a few cycles to complete output operation

//////////////////////////////////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////////////////////////////////
//Example 2: Using Auto Comparator to get 8-bit largest output (max pooling), doing accumulation for a 3*3 kernel

  DA=0;DB=0;DC=0;DD=0;DE=0;DF=0;DG=0;DH=0;
  CLKEXT=0;
  SEL_CON=1;        //set to FSM auto mode
  EN_FSM=0;
  RD_EN=0;
  EN_CONFIG=0;
  RST_GLO=0;

  @(posedge CLKEXT);
  RST_GLO=1;      //global reset when booting up

  @(posedge CLKEXT);
  RST_GLO=0;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  @(posedge CLKEXT);
  EN_FSM=1;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  @(posedge CLKEXT);  //only compute for one neuron
  EN_FSM=0;

  @(negedge CLKEXT);  //begin to load data
  DA=8'b0000_0001;    //bias for MAC1
  DC=8'b0000_0001;    //bias for MAC2
  DE=8'b0000_0010;    //bias for MAC3 (larger than the other bias, thus MAC3 will generate largest value in the end)
  DG=8'b0000_0001;    //bias for MAC4

  //CTR[15:8] represents the number of accumulation for current neuron
  //e.g. for a 3*3 kernel this should be 9
  DB=8'b0000_0000;    //CTR[15:8]
  DD=8'b0000_1001;    //CTR[7:0]

  //DF and DH are don't care terms in this cycle

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  repeat(9) begin     //repeat for 9 cycles, assuming doing the accumulation for one 3*3 kernel

  @(posedge CLKEXT);  //do nothing at postive edge
  @(negedge CLKEXT);  //load one data at each negative edge, in this case the data for each cycle is same
  DA=8'b0000_0001;    //pixel value for MAC1
  DB=8'b0000_0010;    //weight for MAC1
  DC=8'b0000_0001;    //pixel value for MAC2
  DD=8'b0000_0010;    //weight for MAC2
  DE=8'b0000_0001;    //pixel value for MAC3
  DF=8'b0000_0010;    //weight for MAC3
  DG=8'b0000_0001;    //pixel value for MAC4
  DH=8'b0000_0010;    //weight for MAC4

  end

  @(posedge CLKEXT);  //turn for EN_CONFIG for configuring SSFR
  EN_CONFIG=1;        //If EN_CONFIG is low for this cycle, the content of SSFR will remain unchanged 

  @(negedge CLKEXT);  //SSFR configuration, now setting to auto comparator 8-bit largest output
  DA=8'b1100_0001;    //SSFR[15:8]
  DB=8'b0010_1000;    //SSFR[7:0]

  @(posedge CLKEXT);
  EN_CONFIG=0;        //EN_CONFIG must be turned off after one cycle


//////////////////////////////////////////////////////////////////////////////////////////////////////////

  repeat(15)  @(posedge CLKEXT); //give FSM a few cycles to complete output operation

//////////////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////////////////////////////
//Example 3: Using 16bit to 8bit converter to get 8-bit compressed output, doing accumulation for a 3*3 kernel

  DA=0;DB=0;DC=0;DD=0;DE=0;DF=0;DG=0;DH=0;
  CLKEXT=0;
  SEL_CON=1;        //set to FSM auto mode
  EN_FSM=0;
  RD_EN=0;
  EN_CONFIG=0;
  RST_GLO=0;

  @(posedge CLKEXT);
  RST_GLO=1;      //global reset when booting up

  @(posedge CLKEXT);
  RST_GLO=0;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  @(posedge CLKEXT);
  EN_FSM=1;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  @(posedge CLKEXT);  //only compute for one neuron
  EN_FSM=0;

  @(negedge CLKEXT);  //begin to load data
  DA=8'b0000_0001;    //bias for MAC1
  DC=8'b0000_0001;    //bias for MAC2
  DE=8'b0000_0010;    //bias for MAC3 (larger than the other bias, thus MAC3 will generate largest value in the end)
  DG=8'b0000_0001;    //bias for MAC4

  //CTR[15:8] represents the number of accumulation for current neuron
  //e.g. for a 3*3 kernel this should be 9
  DB=8'b0000_0000;    //CTR[15:8]
  DD=8'b0000_1001;    //CTR[7:0]

  //DF and DH are don't care terms in this cycle

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  repeat(9) begin     //repeat for 9 cycles, assuming doing the accumulation for one 3*3 kernel

  @(posedge CLKEXT);  //do nothing at postive edge
  @(negedge CLKEXT);  //load one data at each negative edge, in this case the data for each cycle is same
  DA=8'b0000_0001;    //pixel value for MAC1
  DB=8'b0000_0010;    //weight for MAC1
  DC=8'b0000_0001;    //pixel value for MAC2
  DD=8'b0000_0010;    //weight for MAC2
  DE=8'b0000_0001;    //pixel value for MAC3
  DF=8'b0000_0010;    //weight for MAC3
  DG=8'b0000_0001;    //pixel value for MAC4
  DH=8'b0000_0010;    //weight for MAC4

  end

  @(posedge CLKEXT);  //turn for EN_CONFIG for configuring SSFR
  EN_CONFIG=1;        //If EN_CONFIG is low for this cycle, the content of SSFR will remain unchanged 

  @(negedge CLKEXT);  //SSFR configuration, now setting to auto comparator 8-bit largest output
  DA=8'b0100_0000;    //SSFR[15:8]
  DB=8'b1011_0000;    //SSFR[7:0]

  @(posedge CLKEXT);
  EN_CONFIG=0;        //EN_CONFIG must be turned off after one cycle


//////////////////////////////////////////////////////////////////////////////////////////////////////////

  repeat(15)  @(posedge CLKEXT); //give FSM a few cycles to complete output operation

//////////////////////////////////////////////////////////////////////////////////////////////////////////
  $stop;

end

always begin
        `HALF_CLOCK_PERIOD;
        CLKEXT = ~CLKEXT;
end

endmodule
