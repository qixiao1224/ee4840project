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
    input logic [7:0]  data_dense0,data_dense1,data_dense2,data_dense3,
    input logic        we_dense0,we_dense1,we_dense2,we_dense3,

    //outputs from RAM
    output logic [7:0] read_image0,read_image1,read_image2,read_image3,read_conv,read_dense0,read_dense1,read_dense2,read_dense3

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
dense_ram dense_ram0 (.wraddress(dense_ram_addr_a), .rdaddress(dense_ram_addr_b), .clock(clk), .data(data_dense0), .wren(we_dense0), .q(read_dense0)); // bias
dense_ram dense_ram1 (.wraddress(dense_ram_addr_a), .rdaddress(dense_ram_addr_b), .clock(clk), .data(data_dense1), .wren(we_dense1), .q(read_dense1));
dense_ram dense_ram2 (.wraddress(dense_ram_addr_a), .rdaddress(dense_ram_addr_b), .clock(clk), .data(data_dense2), .wren(we_dense2), .q(read_dense2));
dense_ram dense_ram3 (.wraddress(dense_ram_addr_a), .rdaddress(dense_ram_addr_b), .clock(clk), .data(data_dense3), .wren(we_dense3), .q(read_dense3));


endmodule



