
module mem_top (input logic clk,
                input logic reset,
                input logic [31:0] writedata,
                input logic [31:0] control_reg,
                output logic [7:0] D_OUT
                );




//wire between modules
logic [7:0] read_image0,read_image1,read_image2,read_image3,read_conv,read_dense,read_denseb;
logic [14:0] conv_ram_addr_a,conv_ram_addr_b,dense_ram_addr_a,dense_ram_addr_b,denseb_ram_addr_a,denseb_ram_addr_b;
logic [9:0] image_ram_addr_a,image_ram_addr_b;
logic we_image0,we_image1,we_image2,we_image3,we_conv,we_dense;
logic [7:0] data_image0,data_image1,data_image2,data_image3,data_conv,data_dense,data_denseb;

logic [7:0] DA,DB,DC,DD,DE,DF,DG,DH;
logic EN_FSM, EN_CONFIG;

memory memory1( 
    .clk(clk),
    .reset(reset),

//input from image_ram
    //memory_read
    .image_ram_addr_b(image_ram_addr_b),
    //memory_write
    .image_ram_addr_a(image_ram_addr_a),
    .data_image0(data_image0),
    .data_image1(data_image1),
    .data_image2(data_image2),
    .data_image3(data_image3),
    .we_image0(we_image0),
    .we_image1(we_image1),
    .we_image2(we_image2),
    .we_image3(we_image3),

//input from conv_Ram
//memory_read
    .conv_ram_addr_b(conv_ram_addr_b),
//memory_write
    .conv_ram_addr_a(conv_ram_addr_a),
    .data_conv(data_conv),
    .we_conv(we_conv),

//input from dense_ram
//memory_read
.dense_ram_addr_b(dense_ram_addr_b),
//memory_write
    .dense_ram_addr_a(dense_ram_addr_a),
    .data_dense(data_dense),
    .we_dense(we_dense),

//memory_read
.denseb_ram_addr_b(denseb_ram_addr_b),
//memory_write
    .denseb_ram_addr_a(denseb_ram_addr_a),
    .data_denseb(data_denseb),
    .we_denseb(we_denseb),


//outputs from RAM
//memory_read 
    .read_image0(read_image0), 
    .read_image1(read_image1), 
    .read_image2(read_image2), 
    .read_image3(read_image3),
    .read_conv(read_conv),
    .read_dense(read_dense),
    .read_denseb(read_denseb)
);

memory_write memory_write1(
    .clk(clk),
    .reset(reset),
    .writedata(writedata),
    .control_reg(control_reg),
    
    .wren0(we_image0),
    .wren1(we_image1),
    .wren2(we_image2),
    .wren3(we_image3),
    .wren_conv(we_conv),
    .wren_dense(we_dense),
    .wren_denseb(we_denseb),
    .data0(data_image0),
    .data1(data_image1),
    .data2(data_image2),
    .data3(data_image3),
    .data4(data_conv),
    .data5(data_dense),
    .data6(data_denseb),
    .image_ram_addr(image_ram_addr_a),
    .conv_ram_addr(conv_ram_addr_a),
    .dense_ram_addr(dense_ram_addr_a),
    .denseb_ram_addr(denseb_ram_addr_a)
);



memory_read memory_read1(
    .clk(clk),
    .reset(reset),

    //read from outter ram
    .read_image0(read_image0), 
    .read_image1(read_image1), 
    .read_image2(read_image2), 
    .read_image3(read_image3),
    .read_conv(read_conv),
    .read_dense(read_dense),
    .read_denseb(read_denseb),

    //TODO: NOT WIRED
    .out0(DA), 
    .out1(DB), 
    .out2(DC), 
    .out3(DD), 
    .out_param(DE),
    .out_param1(DF),
    .out_param2(DG),
    .out_param3(DH),
    .control_reg(control_reg),
    
    //output logic [7:0] filter0,filter1,filter2,filter3,

    //output read address to upper level
    .image_ram_addr(image_ram_addr_b),
    .conv_ram_addr(conv_ram_addr_b),
    .dense_ram_addr(dense_ram_addr_b),
    .dense_ram_bias_addr(denseb_ram_addr_b)

);


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
    .CLKEXT(clk), 
    .SEL_CON(1'b1), //TODO
    .EN_FSM(EN_FSM), //TODO
    .D_OUT(D_OUT),//OUtput 
    //.RD_EN(RD_EN),
    .EN_CONFIG(EN_CONFIG),
    .RST_GLO(reset)
    //.FULL(FULL),
    //.EMPTY(EMPTY),
    ///////////////////////////////
    //the following for debugging purpose
    //.MAC1_output(MAC1_output),
    //.MAC2_output(MAC2_output),
    //.ReLU1_output(ReLU1_output),
    //.ReLU2_output(ReLU2_output),
    //.FSM_EN_PISO_OUT_output(FSM_EN_PISO_OUT_output),
    //.FSM_RST_MAC1_output(FSM_RST_MAC1_output),
    //.FSM_EN_MAC1_output(FSM_EN_MAC1_output),
    //.FSM_EN_ReLU1_output(FSM_EN_ReLU1_output),
    //.FSM_CLR_BUF_IN_output(FSM_CLR_BUF_IN_output),
    //.FSM_EN_BUF_IN_output(FSM_EN_BUF_IN_output),
    //.FSM_CLR_PISO_OUT_output(FSM_CLR_PISO_OUT_output),
    //.FSM_SHIFT_OUT_output(FSM_SHIFT_OUT_output),
    //.piso_output(piso_output)
  );





endmodule
