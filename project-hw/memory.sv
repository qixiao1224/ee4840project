// Use for 4840 Project
//Memory Access


module memory(
    input logic        clk,
    input logic        reset,

    //Indication of suffix.
    //    a: read module port
    //    b: write module port 

    //input from image_ram
    input logic [9:0] image_ram_addr_a,image_ram_addr_b,
    input logic [7:0] data_image_0,data_iamge_1,data_image_2,data_image_3,
    input logic       we_image0,we_image1,we_iamge2,we_image3,

    //input from conv_Ram
    input logic [14:0] conv_ram_addr_a,conv_ram_addr_b,
    input logic [7:0]  data_conv_ram,
    input logic        we_conv,

    //input from dense_ram
    input logic [14:0] dense_ram_addr_a,dense_ram_addr_b,
    input logic [7:0]  data_dense_ram,
    input logic        we_dense,

    //input from ram (access to write and read simultaniously)
    input logic [15:0] res_ram_addr_a, res_ram_addr_b,
    input logic [7:0]  res_ram_data0,res_ram_data1,res_ram_data2,res_ram_data3,
    input logic        we_res0,we_res1,we_res2,we_res3,

    //outputs from RAM
    output logic [7:0] read_image0,read_image1,read_iamge2,read_iamge3,read_conv,read_dense,
    output logic [7:0] read_res0,read_res1,read_res2,read_res3,
);


// Memory module definitions
image_ram image_ram0 (.address(ram_addr), .clock(clk), .data(data0), .wren(wren0), .q(read0));//address[13:0]
image_ram image_ram1 (.address(ram_addr), .clock(clk), .data(data1), .wren(wren1), .q(read1));
image_ram image_ram2 (.address(ram_addr), .clock(clk), .data(data2), .wren(wren2), .q(read2));
image_ram image_ram3 (.address(ram_addr), .clock(clk), .data(data3), .wren(wren3), .q(read3));

conv_ram conv_ram0 (.address(conv_ram_addr), .clock(clk), .data(data0), .wren(wren_conv), .q(read4));//address [15:0]
dense_ram dense_ram0 (.address(dense_ram_addr), .clock(clk), .data(data0), .wren(wren_dense), .q(read5));

res_ram ram0 (.address(ram_addr_b), .clock(clk), .data(data0), .wren(wren0), .q(read0));//address[13:0]
res_ram ram1 (.address(ram_addr_b), .clock(clk), .data(data1), .wren(wren1), .q(read1));
res_ram ram2 (.address(ram_addr_b), .clock(clk), .data(data2), .wren(wren2), .q(read2));
res_ram ram3 (.address(ram_addr_b), .clock(clk), .data(data3), .wren(wren3), .q(read3));



endmodule



