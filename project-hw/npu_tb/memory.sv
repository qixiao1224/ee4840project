// Use for 4840 Project
//Memory Access


module memory(
    input logic        clk,
    input logic        reset,

    //Indication of suffix.
    //    a: write to address
    //    b: read to address

    //input from image_ram
    input logic [9:0] image_ram_addr_a,image_ram_addr_b,
    input logic [7:0] data_image0,data_image1,data_image2,data_image3,
    input logic       we_image0,we_image1,we_image2,we_image3,

    //input from conv_Ram
    input logic [14:0] conv_ram_addr_a,conv_ram_addr_b,
    input logic [7:0]  data_conv,
    input logic        we_conv,

    //input from dense_ram
    input logic [14:0] dense_ram_addr_a,dense_ram_addr_b,
    input logic [7:0]  data_dense,
    input logic        we_dense,

    input logic [14:0] denseb_ram_addr_a,denseb_ram_addr_b,
    input logic [7:0]  data_denseb,
    input logic        we_denseb,

    //input from res_ram 
    //input logic [13:0] res_ram_addr_a, res_ram_addr_b,
    //input logic [7:0]  data_res0, data_res1, data_res2, data_res3
    //input logic        we_res0, we_res1, we_res2, we_res3,

    //TODO: Place Reserved for memory_read and memory_write

    //outputs from RAM
    output logic [7:0] read_image0,read_image1,read_image2,read_image3,read_conv,read_dense,read_denseb_0,read_denseb_1,read_denseb_2,read_denseb_3
    //output logic [7:0] read_res0,read_res1,read_res2,read_res3,
);


// Memory module definitions
//image ram: Store the input image //address[9:0]
image_ram image_ram0 (.wraddress(image_ram_addr_a), .rdaddress(image_ram_addr_b), .clock(clk), .data(data_image0), .wren(we_image0), .q(read_image0));
image_ram image_ram1 (.wraddress(image_ram_addr_a), .rdaddress(image_ram_addr_b), .clock(clk), .data(data_image1), .wren(we_image1), .q(read_image1));
image_ram image_ram2 (.wraddress(image_ram_addr_a), .rdaddress(image_ram_addr_b), .clock(clk), .data(data_image2), .wren(we_image2), .q(read_image2));
image_ram image_ram3 (.wraddress(image_ram_addr_a), .rdaddress(image_ram_addr_b), .clock(clk), .data(data_image3), .wren(we_image3), .q(read_image3));

//convolution paramter ram // address [14:0]
conv_ram conv_ram0 (.wraddress(conv_ram_addr_a), .rdaddress(conv_ram_addr_b), .clock(clk), .data(data_conv), .wren(we_conv), .q(read_conv));//address [15:0]

//dense layer parameter ram // address [14:0]
dense_ram dense_ram0 (.wraddress(dense_ram_addr_a), .rdaddress(dense_ram_addr_b), .clock(clk), .data(data_dense), .wren(we_dense), .q(read_dense)); // parameter

dense_ram denseb_ram0 (.wraddress(denseb_ram_addr_a), .rdaddress(denseb_ram_addr_b), .clock(clk), .data(data_denseb), .wren(we_denseb), .q(read_denseb_0)); // bias
dense_ram denseb_ram1 (.wraddress(denseb_ram_addr_a), .rdaddress(denseb_ram_addr_b), .clock(clk), .data(data_denseb), .wren(we_denseb), .q(read_denseb_1));
dense_ram denseb_ram2 (.wraddress(denseb_ram_addr_a), .rdaddress(denseb_ram_addr_b), .clock(clk), .data(data_denseb), .wren(we_denseb), .q(read_denseb_2));
dense_ram denseb_ram3 (.wraddress(denseb_ram_addr_a), .rdaddress(denseb_ram_addr_b), .clock(clk), .data(data_denseb), .wren(we_denseb), .q(read_denseb_3));
// //residue ram to store output from each layer // address[13:0] // Moved to lower module
// res_ram res_ram0 (.wraddress(res_ram_addr_a), .rdaddress(res_ram_addr_b), .clock(clk), .data(data_res0), .wren(we_res0), .q(read_res0));//address[13:0]
// res_ram res_ram1 (.wraddress(res_ram_addr_a), .rdaddress(res_ram_addr_b), .clock(clk), .data(data_res1), .wren(we_res1), .q(read_res1));
// res_ram res_ram2 (.wraddress(res_ram_addr_a), .rdaddress(res_ram_addr_b), .clock(clk), .data(data_res2), .wren(we_res2), .q(read_res2));
// res_ram res_ram3 (.wraddress(res_ram_addr_a), .rdaddress(res_ram_addr_b), .clock(clk), .data(data_res3), .wren(we_res3), .q(read_res3));


//memory_read memory_read0(/*TODO:*/);
//memory_write memory_write0(/*TODO:*/);

endmodule



