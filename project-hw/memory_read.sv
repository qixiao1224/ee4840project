// Use for 4840 Project
//Memory Access


module memory_read(
    input logic        clk,
    input logic        reset,
    input logic [31:0] writedata,
    input logic [31:0] control_reg,
    
    output logic [7:0] out0, out1, out2, out3, out_para,
    //output logic [7:0] filter0,filter1,filter2,filter3,
    output logic [15:0] SSFR_instr
);

logic [7:0] data0, data1, data2, data3;


//TODO: Size to be determined
parameter layer34_start_position = 0;

// Counters
logic [4:0] channel_count;
logic [5:0] filter32_count;
logic [6:0] channel64_count;
logic [4:0] block_count, block34_count, block5_count;
logic [3:0] layer12_count, layer34_count, layer5_count;
logic [1:0] z_counter; // To maintain write back sequence

//Address Register
logic [13:0] image_ram_addr;//TODO: need to modify
logic [15:0] conv_ram_addr;
logic [15:0] dense_ram_addr;

logic [13:0] ram_store_addr;

//Write enable Signal
logic wren1,wren2,wren3,wren0,wren_conv,wren_dense;
logic wr_back;

//Temp Register to store data in one block
logic [7:0] temp [15:0];

//Register to calculate which ram to store in
logic [2:0] reg_num;
logic start_write_back, stop_write_back;

//State Initialization
typedef enum logic [1:0] { IDLE, LAYER12, LAYER34 , LAYER5, DENSE} state_t;
state_t current_state, next_state;

// Memory module definitions //TODO: Need to mv to top module
image_ram image_ram0 (.address(image_ram_addr), .clock(clk), .data(), .wren(), .q(read0));//address[13:0]
image_ram image_ram1 (.address(image_ram_addr), .clock(clk), .data(), .wren(), .q(read1));
image_ram image_ram2 (.address(image_ram_addr), .clock(clk), .data(), .wren(), .q(read2));
image_ram image_ram3 (.address(image_ram_addr), .clock(clk), .data(), .wren(), .q(read3));

//Dual Port ram //TODO: need to specify
//Port A: Write back
//Port B: Read
res_ram ram0 (.address(ram_addr_b), .clock(clk), .data(data0), .wren(wren0), .q(read0));//address[13:0]
res_ram ram1 (.address(ram_addr_b), .clock(clk), .data(data1), .wren(wren1), .q(read1));
res_ram ram2 (.address(ram_addr_b), .clock(clk), .data(data2), .wren(wren2), .q(read2));
res_ram ram3 (.address(ram_addr_b), .clock(clk), .data(data3), .wren(wren3), .q(read3));

conv_ram conv_ram0 (.address(conv_ram_addr), .clock(clk), .data(data0), .wren(wren_conv), .q(read4));//address [15:0]
dense_ram dense_ram0 (.address(dense_ram_addr), .clock(clk), .data(data0), .wren(wren_dense), .q(read5));



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
			wren0_a <= 1;
			data0_a <= D_out;
			ram_addr_a <= ram_store_addr;
		end
		1: begin
			wren1_a <= 1;
			data1_a <= D_out;
			ram_addr_a <= ram_store_addr;
		end
		2: begin
			wren2_a <= 1;
			data2_a <= D_out;
			ram_addr_a <= ram_store_addr;
		end
		3: begin
			wren3_a <= 1;
			data3_a <= D_out;
			ram_addr_a <= ram_store_addr;
			ram_store_addr <= ram_store_addr + 1;
		end
	endcase
	end
	else if (stop_write_back) begin // Close all write enable
	   stop_write_back <= 0;
	   wren0_a <= 0;
	   wren1_a <= 0;
	   wren2_a <= 0;
	   wren3_a <= 0;
	   reg_num <= reg_num + 1;
	end
    end
end


// WRITE
always_ff @(posedge clk) begin
    if (reset) begin
        data1 <= 8'b0;
        data2 <= 8'b0;
        data3 <= 8'b0;
        data0 <= 8'b0;

        read0 <= 8'b0;
        read1 <= 8'b0;
        read2 <= 8'b0;
        read3 <= 8'b0;
        read4 <= 8'b0;
        read5 <= 8'b0;

	wr_en <= 0;

        //addr
        image_ram_addr <= 0;
        conv_ram_addr <= 0;
        ram_addr_b <= 0;
        dense_ram_addr <= 0;
    end else begin
        SSFR_instr <= 16'b0010000010101000; // TODO: change with states // ?
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
                        temp[0] <= read0;
                        temp[1] <= read1;
                        temp[2] <= read2;
                        temp[3] <= read3;
                        //MAC counter = filter number = 9
                        out0 <= 8'd0; 
                        out1 <= 8'd9; 
                        out_param <= read4; // Bias
                        image_ram_addr <= image_ram_addr + 1;
                    end
                    1: begin
                        temp[4] <= read0;
                        temp[5] <= read1;
                        temp[6] <= read2;
                        temp[7] <= read3;
                        out0 <= temp[0];
                        out1 <= temp[1];
                        out2 <= temp[2];
                        out3 <= temp[3];
                        out_param <= read4; // Param0
                        image_ram_addr <= image_ram_addr + 12;
                    end
                    2: begin
                        temp[8] <= read0;
                        temp[9] <= read1;
                        temp[10] <= read2;
                        temp[11] <= read3;
                        out0 <= temp[1];
                        out1 <= temp[4];
                        out2 <= temp[3];
                        out3 <= temp[6];
                        out_param <= read4; // Param1
                        image_ram_addr <= image_ram_addr + 1;
                    end
                    3: begin
                        temp[12] <= read0;
                        temp[13] <= read1;
                        temp[14] <= read2;
                        temp[15] <= read3;
                        out0 <= temp[4];
                        out1 <= temp[5];
                        out2 <= temp[6];
                        out3 <= temp[7];
                        out_param <= read4; // Param2
			case (z_counter)
				0: image_ram_addr <= image_ram_addr - 13; // To upper right side block
				1: image_ram_addr <= image_ram_addr - 2; // To lower left side block
				2: image_ram_addr <= image_ram_addr - 13; // To lower right side block
				3: image_ram_addr <= image_ram_addr - 26; // TO upper left side of the next block
			endcase
                        z_counter <= z_counter + 1;
                    end

                    4: begin
                        out0 <= temp[2];
                        out1 <= temp[3];
                        out2 <= temp[8];
                        out3 <= temp[9];
                        out_param <= read4; // Param3
                        
                    end

                    5: begin
                        out0 <= temp[3];
                        out1 <= temp[6];
                        out2 <= temp[9];
                        out3 <= temp[12];
                        out_param <= read4; // Param4
                    end

                    6: begin
                        out0 <= temp[6];
                        out1 <= temp[7];
                        out2 <= temp[12];
                        out3 <= temp[13];
                        out_param <= read4; // Param5
                    end

                    7: begin
                        out0 <= temp[8];
                        out1 <= temp[9];
                        out2 <= temp[10];
                        out3 <= temp[11];
                        out_param <= read4; // Param6
                    end

                    8: begin
                        out0 <= temp[9];
                        out1 <= temp[12];
                        out2 <= temp[11];
                        out3 <= temp[14];
                        out_param <= read4; // Param7
                    end

                    9: begin
                        out0 <= temp[12];
                        out1 <= temp[13];
                        out2 <= temp[14];
                        out3 <= temp[15];
                        out_param <= read4;// Param8
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
                           image_ram_addr <= 0;
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
                        temp[0] <= read0;
                        temp[1] <= read1;
                        temp[2] <= read2;
                        temp[3] <= read3;
                        //MAC counter = filter number = 288
                        out0 <= 8'd1; //256
                        out1 <= 8'd32;//32
                        out_param <= read4; // Bias
                        ram_addr_b <= ram_addr_b + 1; 
                    end
                    1: begin
                        temp[4] <= read0;
                        temp[5] <= read1;
                        temp[6] <= read2;
                        temp[7] <= read3;
                        out0 <= temp[0];
                        out1 <= temp[1];
                        out2 <= temp[2];
                        out3 <= temp[3];
                        out_param <= read4; // Param0
                        ram_addr_b <= ram_addr_b + 5;
                    end
                    2: begin
                        temp[8] <= read0;
                        temp[9] <= read1;
                        temp[10] <= read2;
                        temp[11] <= read3;
                        out0 <= temp[1];
                        out1 <= temp[4];
                        out2 <= temp[3];
                        out3 <= temp[6];
                        out_param <= read4; // Param1
                        ram_addr_b <= ram_addr_b + 1;
                    end
                    3: begin
                        temp[12] <= read0;
                        temp[13] <= read1;
                        temp[14] <= read2;
                        temp[15] <= read3;
                        out0 <= temp[4];
                        out1 <= temp[5];
                        out2 <= temp[6];
                        out3 <= temp[7];
                        out_param <= read4; // Param2
                        ram_addr_b <= ram_addr_b - 7;
                        //return to the original para ram place since next layer use same address
                    end

                    4: begin
                        out0 <= temp[2];
                        out1 <= temp[3];
                        out2 <= temp[8];
                        out3 <= temp[9];
                        out_param <= read4; // Param3
                    end

                    5: begin
                        out0 <= temp[3];
                        out1 <= temp[6];
                        out2 <= temp[9];
                        out3 <= temp[12];
                        out_param <= read4; // Param4
                    end

                    6: begin
                        out0 <= temp[6];
                        out1 <= temp[7];
                        out2 <= temp[12];
                        out3 <= temp[13];
                        out_param <= read4; // Param5
                    end

                    7: begin
                        out0 <= temp[8];
                        out1 <= temp[9];
                        out2 <= temp[10];
                        out3 <= temp[11];
                        out_param <= read4; // Param6
                    end

                    8: begin
                        out0 <= temp[9];
                        out1 <= temp[12];
                        out2 <= temp[11];
                        out3 <= temp[14];
                        out_param <= read4; // Param7
                    end

                    9: begin
                        out0 <= temp[12];
                        out1 <= temp[13];
                        out2 <= temp[14];
                        out3 <= temp[15];
                        out_param <= read4;// Param8

                    end

                    10: begin
                        
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
                endcase

/***************
LAYER 5
****************/

            LAYER5: begin
                layer5_count <= layer5_count + 1;//next cycle for 3x3
                conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position : 9


                case (layer34_count) 
                    0: begin // Outputting bias and MACcounter = 32
                        temp[0] <= read0;
                        temp[1] <= read1;
                        temp[2] <= read2;
                        temp[3] <= read3;
                        //MAC counter = filter number = 288
                        out0 <= 8'd1; //256
                        out1 <= 8'd32;//32
                        out_param <= read4; // Bias
                        ram_addr_b <= ram_addr_b + 1; 
                    end
                    1: begin
                        temp[4] <= read0;
                        temp[5] <= read1;
                        temp[6] <= read2;
                        temp[7] <= read3;
                        out0 <= temp[0];
                        out1 <= temp[1];
                        out2 <= temp[2];
                        out3 <= temp[3];
                        out_param <= read4; // Param0
                        ram_addr_b <= ram_addr_b + 5;
                    end
                    2: begin
                        temp[8] <= read0;
                        temp[9] <= read1;
                        temp[10] <= read2;
                        temp[11] <= read3;
                        out0 <= temp[1];
                        out1 <= temp[4];
                        out2 <= temp[3];
                        out3 <= temp[6];
                        out_param <= read4; // Param1
                        ram_addr_b <= ram_addr_b + 1;
                    end
                    3: begin
                        temp[12] <= read0;
                        temp[13] <= read1;
                        temp[14] <= read2;
                        temp[15] <= read3;
                        out0 <= temp[4];
                        out1 <= temp[5];
                        out2 <= temp[6];
                        out3 <= temp[7];
                        out_param <= read4; // Param2
                        ram_addr_b <= ram_addr_b - 7;
                        //return to the original para ram place since next layer use same address
                    end

                    4: begin
                        out0 <= temp[2];
                        out1 <= temp[3];
                        out2 <= temp[8];
                        out3 <= temp[9];
                        out_param <= read4; // Param3
                    end

                    5: begin
                        out0 <= temp[3];
                        out1 <= temp[6];
                        out2 <= temp[9];
                        out3 <= temp[12];
                        out_param <= read4; // Param4
                    end

                    6: begin
                        out0 <= temp[6];
                        out1 <= temp[7];
                        out2 <= temp[12];
                        out3 <= temp[13];
                        out_param <= read4; // Param5
                    end

                    7: begin
                        out0 <= temp[8];
                        out1 <= temp[9];
                        out2 <= temp[10];
                        out3 <= temp[11];
                        out_param <= read4; // Param6
                    end

                    8: begin
                        out0 <= temp[9];
                        out1 <= temp[12];
                        out2 <= temp[11];
                        out3 <= temp[14];
                        out_param <= read4; // Param7
                    end

                    9: begin
                        out0 <= temp[12];
                        out1 <= temp[13];
                        out2 <= temp[14];
                        out3 <= temp[15];
                        out_param <= read4;// Param8

                    end

                    10: begin
                        
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
                            ram_addr_b = ram_addr_b - 36*64 + 1;      //restart ram from next block
                            layer5_count <= 0;                       //Filter finished, read same bias for next filter
                            
                            // SSFR output
                            out0 <= 8'b11000001;                      
                            out_param <= 8'b00101000; 
                            
                            //next block
                            block5_count <= block5_count + 1;  
 
                            if (block5_count == 35) begin 
                            //6x6 blocks finished , switch filter
                                ram_addr_b <= layer5_start_position; //parameter ram address positon restart from TODO
                                channel64_count <= channel64_count + 1;
                            end  
                            else begin 
                            // block not finished, same filter, restart conv_ram
                                conv_ram_addr <= conv_ram_addr - 4608;  //12*12*32; Back to the same filter
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




