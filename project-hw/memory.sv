// Use for 4840 Project
//Memory Access


module memory(
    input logic        clk,
    input logic        reset,
    //input from image_ram
    input logic [] image_ram_addr,
    input logic [] data_image_0,data_iamge_1,data_image_2,data_image_3,
    input logic    we_image,

    //input from 
    
    output logic [7:0] read0, read1, read2, read3, read4, read5;
);

logic [7:0] data0, data1, data2, data3;


logic [13:0] ram_addr;
logic [15:0] conv_ram_addr;
logic [15:0] dense_ram_addr;

logic wren1,wren2,wren3,wren0,wren_conv, wren_dense;


// Memory module definitions
image_ram ram0 (.address(ram_addr), .clock(clk), .data(data0), .wren(wren0), .q(read0));//address[13:0]
image_ram ram1 (.address(ram_addr), .clock(clk), .data(data1), .wren(wren1), .q(read1));
image_ram ram2 (.address(ram_addr), .clock(clk), .data(data2), .wren(wren2), .q(read2));
image_ram ram3 (.address(ram_addr), .clock(clk), .data(data3), .wren(wren3), .q(read3));
conv_ram conv_ram0 (.address(conv_ram_addr), .clock(clk), .data(data0), .wren(wren_conv), .q(read4));//address [15:0]
dense_ram dense_ram0 (.address(dense_ram_addr), .clock(clk), .data(data0), .wren(wren_dense), .q(read5));

res_ram ram0 (.address(ram_addr_b), .clock(clk), .data(data0), .wren(wren0), .q(read0));//address[13:0]
res_ram ram1 (.address(ram_addr_b), .clock(clk), .data(data1), .wren(wren1), .q(read1));
res_ram ram2 (.address(ram_addr_b), .clock(clk), .data(data2), .wren(wren2), .q(read2));
res_ram ram3 (.address(ram_addr_b), .clock(clk), .data(data3), .wren(wren3), .q(read3));



endmodule



