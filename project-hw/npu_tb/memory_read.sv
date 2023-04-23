// Use for 4840 Project
//Memory Access


module memory_read(
    //TODO: interface need to be modified
    input logic        clk,
    input logic        reset,

    //read from outter ram
    input logic [7:0] read_image0, read_image1, read_image2, read_image3;
    input logic [7:0] read_conv,read_dense,

    //TODO: output not fixed.
    output logic [7:0] out0, out1, out2, out3, out_param,
    //output logic [7:0] filter0,filter1,filter2,filter3,

    //output read address to upper level
    output logic [9:0] image_ram_addr;
    output logic [14:0] conv_ram_addr;
    output logic [14:0] dense_ram_addr;

);

//send data to res_ram
logic [7:0] data0, data1, data2, data3;
logic [7:0] D_out;

//TODO: Weird part, consider changing.
parameter layer34_start_position = 0;

// Counters
logic [4:0] channel_count;
logic [5:0] filter32_count;
logic [6:0] channel64_count;
logic [4:0] block_count, block34_count, block5_count;
logic [3:0] layer12_count, layer34_count, layer5_count;
logic [1:0] z_counter; // To maintain write back sequence

//Res ram Address Register
logic [13:0] ram_addr_a,ram_addr_b;

//temp addr served as a counter
logic [13:0] ram_store_addr;

//Write enable Signal
logic wren1,wren2,wren3,wren0;
logic wr_en; //top write back signal

//Temp Register to store data in one block
logic [7:0] processing_unit_4x4 [15:0];

//Register to calculate which ram to store in
logic [2:0] reg_num;
logic start_write_back, stop_write_back;

//State Initialization
typedef enum logic [1:0] { IDLE, LAYER12, LAYER34 , LAYER5, DENSE} state_t;
state_t current_state, next_state;


//residue ram to store output from each layer // address[13:0]
//inner use in this module
res_ram res_ram0 (.wraddress(ram_addr_a), .rdaddress(ram_addr_b), .clock(clk), .data(data0), .wren(wren0), .q(read_res0));//address[13:0]
res_ram res_ram1 (.wraddress(ram_addr_a), .rdaddress(ram_addr_b), .clock(clk), .data(data1), .wren(wren1), .q(read_res1));
res_ram res_ram2 (.wraddress(ram_addr_a), .rdaddress(ram_addr_b), .clock(clk), .data(data2), .wren(wren2), .q(read_res2));
res_ram res_ram3 (.wraddress(ram_addr_a), .rdaddress(ram_addr_b), .clock(clk), .data(data3), .wren(wren3), .q(read_res3));


//Port A: Write back
//Port B: Read
// memory memory( .clk(clk),
//         .reset(reset),
//         //connect image ram (read only)
//         .image_ram_addr_b(image_ram_addr),
//         .read_image0(read_image0),
//         .read_image1(read_image1),
//         .read_image2(read_image2),
//         .read_image3(read_image3),
//         //connect conv ram (read only)
//         .conv_ram_addr_b(conv_ram_addr),
//         .read_conv(read_conv)
//         //connect dense ram (read only)
//         .dense_ram_addr_b(dense_ram_addr),
//         .read_dense(read_dense)
//         );


// State updates
always_ff @(posedge clk) begin
    if (reset)
        current_state <= IDLE;
    else 
        current_state <= next_state;
    
end

// State Switching
always_comb begin
    next_state = current_state;
    if (control_reg == 32'h0002)
        next_state = LAYER12; // Counter + CNN + SSFR ( Maxpooling/ReLU )
    else if (channel32_count == 5'd32 && current_state == LAYER12) //TODO: Counter need to be determined
        next_state = LAYER34; // Counter + CNN + SSFR ( Maxpooling/ReLu )
    else if (channel64_count == 6'd64 && current_state == LAYER34)//TODO: Counter need to be determined
        next_state = LAYER5;  // Counter + CNN + SSFR (ReLU)
    else if (conv2_write_count == 16'd37578 && current_state == LAYER5)//TODO: Counter need to be determined
        next_state = DENSE;  // Counter + MAC
    else if (dense_count == 16'd37578 && current_state = DENSE)//TODO: Counter need to be determined
        next_state = IDLE;
end


// Responsible for writing back to memory
always_ff @(posedge clk) begin
    if (reset) begin
    reg_num <= 0;
    start_write_back <= 0;
    stop_write_back <= 0;
    ram_store_addr = 0; // Starting from 0
    end
    else begin
        if (wr_en) begin
        // Waited a cycle for actual output
            wr_en <= 0;
            start_write_back <= 1;
        end
        else if (start_write_back)begin
            start_write_back <= 0;
            stop_write_back <= 1;
            case (reg_num) // Write to corresponding ram
                0: begin
                    wren0 <= 1;
                    data0 <= D_out;
                    ram_addr_a <= ram_store_addr;
                end
                1: begin
                    wren1 <= 1;
                    data1 <= D_out;
                    ram_addr_a <= ram_store_addr;
                end
                2: begin
                    wren2 <= 1;
                    data2 <= D_out;
                    ram_addr_a <= ram_store_addr;
                end
                3: begin
                    wren3 <= 1;
                    data3 <= D_out;
                    ram_addr_a <= ram_store_addr;
                    ram_store_addr <= ram_store_addr + 1;
                end
            endcase
        end
        else if (stop_write_back) begin // Close all write enable
            stop_write_back <= 0;
            wren0 <= 0;
            wren1 <= 0;
            wren2 <= 0;
            wren3 <= 0;
            reg_num <= reg_num + 1;
        end
    end
end


// REAd
always_ff @(posedge clk) begin
    if (reset) begin
        data1 <= 8'b0;
        data2 <= 8'b0;
        data3 <= 8'b0;
        data0 <= 8'b0;

    wr_en <= 0;

        //addr
        image_ram_addr <= 0;
        conv_ram_addr <= 0;
        ram_addr_b <= 0;
        dense_ram_addr <= 0;
    end else begin
        //SSFR_instr <= 16'b0010000010101000; // TODO: change with states // ?
        //*****CASE OF DIFFERENT STATE*****//
        case (current_state)
            //STATE 0: IDLE
            IDLE: begin
        z_counter <= 0;
                //layer 12
                layer12_count <= 0;
                block_count <= 0;
                channel32_count <= 0;
                //layer 34
                filter32_count <= 5'b0;
                channel64_count <= 6'b0;
                block34_count <= 0;
        //layer 5
        block5_count <= 0;
        layer5_count <= 0;
            end

/***************
LAYER 12
****************/

            //STATE 1: Convolute and maxpooling 26x26 into 12x12x32
            LAYER12: begin 
                //read image from 4 memories. read filter parameters from conv.
                conv_ram_addr <= conv_ram_addr  + 1; // Reading Bias and filter
                layer12_count <= layer12_count + 1;

                //11 cycles in total to deal with a 4x4 block
                case (layer12_count) 
                    0: begin // Outputting bias and counter = 32
                        processing_unit_4x4[0] <= read_image0;
                        processing_unit_4x4[1] <= read_image1;
                        processing_unit_4x4[2] <= read_image2;
                        processing_unit_4x4[3] <= read_image3;
                        //MAC counter = filter number = 9
                        out0 <= 8'd0; 
                        out1 <= 8'd9; 
                        out_param <= read_conv; // Bias
                        ram_addr_b <= ram_addr_b + 1;
                    end
                    1: begin
                        processing_unit_4x4[4] <= read_image0;
                        processing_unit_4x4[5] <= read_image1;
                        processing_unit_4x4[6] <= read_image2;
                        processing_unit_4x4[7] <= read_image3;
                        out0 <= processing_unit_4x4[0];
                        out1 <= processing_unit_4x4[1];
                        out2 <= processing_unit_4x4[2];
                        out3 <= processing_unit_4x4[3];
                        out_param <= read_conv; // Param0
                        ram_addr_b <= ram_addr_b + 12;
                    end
                    2: begin
                        processing_unit_4x4[8] <= read_image0;
                        processing_unit_4x4[9] <= read_image1;
                        processing_unit_4x4[10] <= read_image2;
                        processing_unit_4x4[11] <= read_image3;
                        out0 <= processing_unit_4x4[1];
                        out1 <= processing_unit_4x4[4];
                        out2 <= processing_unit_4x4[3];
                        out3 <= processing_unit_4x4[6];
                        out_param <= read_conv; // Param1
                        ram_addr_b <= ram_addr_b + 1;
                    end
                    3: begin
                        processing_unit_4x4[12] <= read_image0;
                        processing_unit_4x4[13] <= read_image1;
                        processing_unit_4x4[14] <= read_image2;
                        processing_unit_4x4[15] <= read_image3;
                        out0 <= processing_unit_4x4[4];
                        out1 <= processing_unit_4x4[5];
                        out2 <= processing_unit_4x4[6];
                        out3 <= processing_unit_4x4[7];
                        out_param <= read_conv; // Param2
            case (z_counter)
                0: ram_addr_b <= ram_addr_b - 13; // To upper right side block
                1: ram_addr_b <= ram_addr_b - 2; // To lower left side block
                2: ram_addr_b <= ram_addr_b - 13; // To lower right side block
                3: ram_addr_b <= ram_addr_b - 26; // TO upper left side of the next block
            endcase
                        z_counter <= z_counter + 1;
                    end

                    4: begin
                        out0 <= processing_unit_4x4[2];
                        out1 <= processing_unit_4x4[3];
                        out2 <= processing_unit_4x4[8];
                        out3 <= processing_unit_4x4[9];
                        out_param <= read_conv; // Param3
                        
                    end

                    5: begin
                        out0 <= processing_unit_4x4[3];
                        out1 <= processing_unit_4x4[6];
                        out2 <= processing_unit_4x4[9];
                        out3 <= processing_unit_4x4[12];
                        out_param <= read_conv; // Param4
                    end

                    6: begin
                        out0 <= processing_unit_4x4[6];
                        out1 <= processing_unit_4x4[7];
                        out2 <= processing_unit_4x4[12];
                        out3 <= processing_unit_4x4[13];
                        out_param <= read_conv; // Param5
                    end

                    7: begin
                        out0 <= processing_unit_4x4[8];
                        out1 <= processing_unit_4x4[9];
                        out2 <= processing_unit_4x4[10];
                        out3 <= processing_unit_4x4[11];
                        out_param <= read_conv; // Param6
                    end

                    8: begin
                        out0 <= processing_unit_4x4[9];
                        out1 <= processing_unit_4x4[12];
                        out2 <= processing_unit_4x4[11];
                        out3 <= processing_unit_4x4[14];
                        out_param <= read_conv; // Param7
                    end

                    9: begin
                        out0 <= processing_unit_4x4[12];
                        out1 <= processing_unit_4x4[13];
                        out2 <= processing_unit_4x4[14];
                        out3 <= processing_unit_4x4[15];
                        out_param <= read_conv;// Param8
                        conv_ram_addr <= conv_ram_addr - 9;//return to filter [0]
                    end

                    10: begin
                        out0 <= 8'b11000001; // SSFR
                        out_param <= 8'b00101000;
                        layer12_count <= 0;
                        block_count <= block_count + 1; // Updating offset
                        wr_en <= 1; // write back once
                        if (block_count < 13*13) begin 
                            conv_ram_addr <= conv_ram_addr - 1; //return to filter[0]
                            ram_addr_b <= 0;
                        end
                        else
                            channel32_count <= channel32_count + 1; // 32 channel, when loop_count == 32, next state.
                            conv_ram_addr <= conv_ram_addr + 9;//move to next filter
                        block_count <= 0;
                    end
                endcase
            end//end STATE LAYER12.

/***************
LAYER 34
****************/

            //STATE 2
            //TODO: ASSUME WE HAVE 12X12 FROM PREVIOUS LAYER RATHER THAN 13x13
            LAYER34: begin
                layer34_count <= layer34_count + 1;//next cycle for 3x3
                conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position : 9
        //count for 32 channel from previous layer
                //channel64_count //count for 64 channel from this layer


                case (layer34_count) 
                    0: begin // Outputting bias and MACcounter = 32
                        processing_unit_4x4[0] <= read_res0;
                        processing_unit_4x4[1] <= read_res1;
                        processing_unit_4x4[2] <= read_res2;
                        processing_unit_4x4[3] <= read_res3;
                        //MAC counter = filter number = 288
                        out0 <= 8'd1; //256
                        out1 <= 8'd32;//32
                        out_param <= read_conv; // Bias
                        ram_addr_b <= ram_addr_b + 1; 
                    end
                    1: begin
                        processing_unit_4x4[4] <= read_res0;
                        processing_unit_4x4[5] <= read_res1;
                        processing_unit_4x4[6] <= read_res2;
                        processing_unit_4x4[7] <= read_res3;
                        out0 <= processing_unit_4x4[0];
                        out1 <= processing_unit_4x4[1];
                        out2 <= processing_unit_4x4[2];
                        out3 <= processing_unit_4x4[3];
                        out_param <= read_conv; // Param0
                        ram_addr_b <= ram_addr_b + 5;
                    end
                    2: begin
                        processing_unit_4x4[8] <= read_res0;
                        processing_unit_4x4[9] <= read_res1;
                        processing_unit_4x4[10] <= read_res2;
                        processing_unit_4x4[11] <= read_res3;
                        out0 <= processing_unit_4x4[1];
                        out1 <= processing_unit_4x4[4];
                        out2 <= processing_unit_4x4[3];
                        out3 <= processing_unit_4x4[6];
                        out_param <= read_conv; // Param1
                        ram_addr_b <= ram_addr_b + 1;
                    end
                    3: begin
                        processing_unit_4x4[12] <= read_res0;
                        processing_unit_4x4[13] <= read_res1;
                        processing_unit_4x4[14] <= read_res2;
                        processing_unit_4x4[15] <= read_res3;
                        out0 <= processing_unit_4x4[4];
                        out1 <= processing_unit_4x4[5];
                        out2 <= processing_unit_4x4[6];
                        out3 <= processing_unit_4x4[7];
                        out_param <= read_conv; // Param2
                        ram_addr_b <= ram_addr_b - 7;
                        //return to the original para ram place since next layer use same address
                    end

                    4: begin
                        out0 <= processing_unit_4x4[2];
                        out1 <= processing_unit_4x4[3];
                        out2 <= processing_unit_4x4[8];
                        out3 <= processing_unit_4x4[9];
                        out_param <= read_conv; // Param3
                    end

                    5: begin
                        out0 <= processing_unit_4x4[3];
                        out1 <= processing_unit_4x4[6];
                        out2 <= processing_unit_4x4[9];
                        out3 <= processing_unit_4x4[12];
                        out_param <= read_conv; // Param4
                    end

                    6: begin
                        out0 <= processing_unit_4x4[6];
                        out1 <= processing_unit_4x4[7];
                        out2 <= processing_unit_4x4[12];
                        out3 <= processing_unit_4x4[13];
                        out_param <= read_conv; // Param5
                    end

                    7: begin
                        out0 <= processing_unit_4x4[8];
                        out1 <= processing_unit_4x4[9];
                        out2 <= processing_unit_4x4[10];
                        out3 <= processing_unit_4x4[11];
                        out_param <= read_conv; // Param6
                    end

                    8: begin
                        out0 <= processing_unit_4x4[9];
                        out1 <= processing_unit_4x4[12];
                        out2 <= processing_unit_4x4[11];
                        out3 <= processing_unit_4x4[14];
                        out_param <= read_conv; // Param7
                    end

                    9: begin
                        out0 <= processing_unit_4x4[12];
                        out1 <= processing_unit_4x4[13];
                        out2 <= processing_unit_4x4[14];
                        out3 <= processing_unit_4x4[15];
                        out_param <= read_conv;// Param8

                    end

                    10: begin
                        //TODO: FIXME: need to add wr_en signal to start write back
                        conv_ram_addr <= conv_ram_add - 1; //No adding parameter ram address this cycle
                        filter32_count <= filter32_count + 1; //go to next channel of prev layer
                        if (filter32_count < 32) begin 
                            //Have Not Finish ONE Filter
                            ram_addr_b <= ram_addr_b + 36*(filter32_count+1);//restart ram from the start position in this block
                            layer34_count <= 1;                              //Filter not finished, do not return to 0
                        end
                        else begin 
                            //One Filter Finished

                            //RESET counters and address position
                            filter32_count <= 0;                      //next filter counter begin
                            ram_addr_b = ram_addr_b - 36*32;      //restart ram from original block, incremented later
                            layer34_count <= 0;                       //Filter finished, read same bias for next filter
                            
                            // SSFR output
                            out0 <= 8'b11000001;
                            out_param <= 8'b00101000;
                            
                            //next block
                            block34_count <= block34_count + 1;

                            case (z_counter)
                            0: ram_addr_b <= ram_addr_b + 1; // To upper right side block
                            1: ram_addr_b <= ram_addr_b - 2; // To lower left side block
                            2: ram_addr_b <= ram_addr_b - 6; // To lower right side block
                            3: ram_addr_b <= ram_addr_b - 12; // TO upper left side of the next block
                            endcase
                            z_counter <= z_counter + 1;

                            if (block34_count == 35) begin 
                            //6x6 blocks finished , switch filter
                                ram_addr_b <= layer34_start_position; //parameter ram address positon restart from 0
                                channel64_count <= channel64_count + 1;
                            end  
                            else begin 
                            // block not finished, same filter, restart conv_ram
                                conv_ram_addr <= conv_ram_addr - 4608;  //12*12*32; Back to the same filter
                            end
                        end
                    end
                endcase
            end

/***************
LAYER 5
****************/

            LAYER5: begin //TODO: Need to modify
                layer34_count <= layer34_count + 1;//next cycle for 3x3
                conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position : 9

                case (layer34_count) 
                    0: begin // Outputting bias and MACcounter = 32
                        processing_unit_4x4[0] <= read_res0;
                        processing_unit_4x4[1] <= read_res1;
                        processing_unit_4x4[2] <= read_res2;
                        processing_unit_4x4[3] <= read_res3;
                        //MAC counter = filter number = 288
                        out0 <= 8'd1; //256
                        out1 <= 8'd32;//32
                        out_param <= read_conv; // Bias
                        ram_addr_b <= ram_addr_b + 1; 
                    end
                    1: begin
                        processing_unit_4x4[4] <= read_res0;
                        processing_unit_4x4[5] <= read_res1;
                        processing_unit_4x4[6] <= read_res2;
                        processing_unit_4x4[7] <= read_res3;
                        out0 <= processing_unit_4x4[0];
                        out1 <= processing_unit_4x4[1];
                        out2 <= processing_unit_4x4[2];
                        out3 <= processing_unit_4x4[3];
                        out_param <= read_conv; // Param0
                        ram_addr_b <= ram_addr_b + 5;
                    end
                    2: begin
                        processing_unit_4x4[8] <= read_res0;
                        processing_unit_4x4[9] <= read_res1;
                        processing_unit_4x4[10] <= read_res2;
                        processing_unit_4x4[11] <= read_res3;
                        out0 <= processing_unit_4x4[1];
                        out1 <= processing_unit_4x4[4];
                        out2 <= processing_unit_4x4[3];
                        out3 <= processing_unit_4x4[6];
                        out_param <= read_conv; // Param1
                        ram_addr_b <= ram_addr_b + 1;
                    end
                    3: begin
                        processing_unit_4x4[12] <= read_res0;
                        processing_unit_4x4[13] <= read_res1;
                        processing_unit_4x4[14] <= read_res2;
                        processing_unit_4x4[15] <= read_res3;
                        out0 <= processing_unit_4x4[4];
                        out1 <= processing_unit_4x4[5];
                        out2 <= processing_unit_4x4[6];
                        out3 <= processing_unit_4x4[7];
                        out_param <= read_conv; // Param2
                        ram_addr_b <= ram_addr_b - 7;
                        //return to the original para ram place since next layer use same address
                    end

                    4: begin
                        out0 <= processing_unit_4x4[2];
                        out1 <= processing_unit_4x4[3];
                        out2 <= processing_unit_4x4[8];
                        out3 <= processing_unit_4x4[9];
                        out_param <= read_conv; // Param3
                    end

                    5: begin
                        out0 <= processing_unit_4x4[3];
                        out1 <= processing_unit_4x4[6];
                        out2 <= processing_unit_4x4[9];
                        out3 <= processing_unit_4x4[12];
                        out_param <= read_conv; // Param4
                    end

                    6: begin
                        out0 <= processing_unit_4x4[6];
                        out1 <= processing_unit_4x4[7];
                        out2 <= processing_unit_4x4[12];
                        out3 <= processing_unit_4x4[13];
                        out_param <= read_conv; // Param5
                    end

                    7: begin
                        out0 <= processing_unit_4x4[8];
                        out1 <= processing_unit_4x4[9];
                        out2 <= processing_unit_4x4[10];
                        out3 <= processing_unit_4x4[11];
                        out_param <= read_conv; // Param6
                    end

                    8: begin
                        out0 <= processing_unit_4x4[9];
                        out1 <= processing_unit_4x4[12];
                        out2 <= processing_unit_4x4[11];
                        out3 <= processing_unit_4x4[14];
                        out_param <= read_conv; // Param7
                    end

                    9: begin
                        out0 <= processing_unit_4x4[12];
                        out1 <= processing_unit_4x4[13];
                        out2 <= processing_unit_4x4[14];
                        out3 <= processing_unit_4x4[15];
                        out_param <= read_conv;// Param8

                    end

                    10: begin
                        //TODO: FIXME: need to add wr_en signal to start write back
                        conv_ram_addr <= conv_ram_add - 1; //No adding parameter ram address this cycle
                        filter32_count <= filter32_count + 1; //go to next channel of prev layer
                        if (filter32_count < 32) begin 
                            //Have Not Finish ONE Filter
                            ram_addr_b <= ram_addr_b + 36*(filter32_count+1);//restart ram from the start position in this block
                            layer34_count <= 1;                              //Filter not finished, do not return to 0
                        end
                        else begin 
                            //One Filter Finished

                            //RESET counters and address position
                            filter32_count <= 0;                      //next filter counter begin
                            ram_addr_b = ram_addr_b - 36*32;      //restart ram from original block, incremented later
                            layer34_count <= 0;                       //Filter finished, read same bias for next filter
                            
                            // SSFR output
                            out0 <= 8'b11000001;
                            out_param <= 8'b00101000;
                            
                            //next block
                            block34_count <= block34_count + 1;

                            case (z_counter)
                            0: ram_addr_b <= ram_addr_b + 1; // To upper right side block
                            1: ram_addr_b <= ram_addr_b - 2; // To lower left side block
                            2: ram_addr_b <= ram_addr_b - 6; // To lower right side block
                            3: ram_addr_b <= ram_addr_b - 12; // TO upper left side of the next block
                            endcase
                            z_counter <= z_counter + 1;

                            if (block34_count == 35) begin 
                            //6x6 blocks finished , switch filter
                                ram_addr_b <= layer34_start_position; //parameter ram address positon restart from 0
                                channel64_count <= channel64_count + 1;
                            end  
                            else begin 
                            // block not finished, same filter, restart conv_ram
                                conv_ram_addr <= conv_ram_addr - 4608;  //12*12*32; Back to the same filter
                            end
                        end
                    end
                endcase
            end



            DENSE: begin
                //
            end

            default: begin
                //?
            end
        endcase  //end of state machine
    end//end if
end//end for ff
endmodule



