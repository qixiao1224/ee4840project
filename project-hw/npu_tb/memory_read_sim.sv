// Use for 4840 Project
//Memory Access
// Simplify ver.

module memory_read_sim(
    //TODO: interface need to be modified
    input logic        clk,
    input logic        reset,

    //read from outter ram
    input logic [7:0] read_image0, read_image1, read_image2, read_image3,
    input logic [7:0] read_conv,read_dense,read_denseb_0,read_denseb_1,read_denseb_2,read_denseb_3,
    input logic [7:0] D_out,
    input logic [31:0] control_reg,

    //TODO: output not fixed.
    output logic [7:0] DA,DB,DC,DD,DE,DF,DG,DH,
    //output logic [7:0] filter0,filter1,filter2,filter3,

    //output read address to upper level
    output logic [9:0] image_ram_addr,
    output logic [14:0] conv_ram_addr,
    output logic [14:0] dense_ram_addr,
    output logic [14:0] dense_ram_bias_addr,
    output logic EN_FSM, EN_CONFIG

    //NPU Control Sig,
    
);

//send data to res_ram
logic [7:0] data0, data1, data2, data3;


//TODO: Weird part, consider changing. It is not weird, I endorse this part.
parameter layer34_start_position = 0; // This is the first time actually reads conv result, position should be 0
parameter layer5_start_position = 1568; // Layer 34 gives out a result size of 14*14*32, divide by 4 into mems
parameter layer_dense_start_position = 1856; // Layer 5 gives out a result size of 6*6*32, div 4, plus previous result

// Counters
logic [4:0] channel_count;
logic [5:0] filter32_count,filter32_count_1;
logic [6:0] channel32_count,channel64_count,channel64_count_1;
logic [7:0] block_count, block34_count, block5_count;
logic [3:0] layer12_count, layer34_count, layer5_count,dense_case, dense_10_case;
logic [3:0] dense_bias_count;
logic [8:0] dense_count;
logic [1:0] z_counter; // To maintain write back sequence
logic z_counter_end;
//Res ram Address Register
logic [13:0] ram_addr_a,ram_addr_b;

logic [7:0] read_res0,read_res1,read_res2,read_res3;

//temp outputs
logic [7:0] out_param_1, out_param_2, out_param_3;

//temp addr served as a counter
logic [13:0] ram_store_addr;

//Write enable Signal
logic wren1,wren2,wren3,wren0;
logic wr_en; //top write back signal

//Temp Register to store data in one block
logic [7:0] processing_unit_4x4 [15:0];

//Register to calculate which ram to store in
logic [1:0] ram_num;
logic start_write_back, stop_write_back,writing,delayed_cycle1,delayed_cycle2;

//delay
logic delayed=0;

//State Initialization
typedef enum logic [2:0] { IDLE, LAYER12, LAYER34 , LAYER5, DENSE, DENSE_10} state_t;
state_t current_state, next_state;


//residue ram to store output from each layer // address[13:0]
//inner use in this module
res_ram res_ram0 (.wraddress(ram_addr_a), .rdaddress(ram_addr_b), .clock(clk), .data(data0), .wren(wren0), .q(read_res0));//address[13:0]
res_ram res_ram1 (.wraddress(ram_addr_a), .rdaddress(ram_addr_b), .clock(clk), .data(data1), .wren(wren1), .q(read_res1));
res_ram res_ram2 (.wraddress(ram_addr_a), .rdaddress(ram_addr_b), .clock(clk), .data(data2), .wren(wren2), .q(read_res2));
res_ram res_ram3 (.wraddress(ram_addr_a), .rdaddress(ram_addr_b), .clock(clk), .data(data3), .wren(wren3), .q(read_res3));



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
    if (control_reg==32'h0002  && current_state == IDLE)
        next_state = LAYER12; // Counter + CNN + SSFR ( Maxpooling/ReLU )
    else if (channel32_count == 7'd32 && layer12_count == 10 && block_count == 195 && current_state == LAYER12) 
        next_state = LAYER34; // Counter + CNN + SSFR ( Maxpooling/ReLu )
    else if (channel64_count == 6'd31 && layer34_count == 9 && block34_count == 35 && filter32_count ==31 && current_state == LAYER34)
        next_state = LAYER5;  // Counter + CNN + SSFR (ReLU)
    else if (channel64_count_1 == 6'd31 && layer5_count == 10 && block5_count == 3 && filter32_count_1 == 32 && current_state == LAYER5)
        next_state = DENSE;  // Counter + MAC
    else if (dense_bias_count == 29 && dense_case == 2 && current_state == DENSE)//TODO: I am testing to seemlessly connect DENSE and DENSE_FINAL
        next_state = DENSE_10;  // Counter + MAC

/*
    else if (filter_dense_count == 6'd32 && current_state = DENSE)//TODO: Counter need to be determined
        next_state = DENSE_FINAL;
    else if (filter_dense_count == 6'd32 && current_state = DENSE_FINAL)//TODO: Counter need to be determined
        next_state = IDLE;
*/
end


// Responsible for WRITING BACK to memory

always_ff @(posedge clk) begin
    if (reset) begin
    ram_num <= 0;
    ram_addr_a <= 0;
    start_write_back <= 0;
    stop_write_back <= 0;
    writing <= 0;
    delayed_cycle1 <= 0;
    delayed_cycle2 <= 0;
    ram_store_addr <= 0; // Starting from 0
    wren0 <=0;
    wren1 <=0;
    wren2 <=0;
    wren3 <=0;
    end
    else begin
        if (wr_en) begin
        // Waited a cycle for actual output
            wr_en <= 0;
            start_write_back <= 1;
        end
        else if (start_write_back) begin
            start_write_back <= 0;
            delayed_cycle1 <= 1;
        end
        else if (delayed_cycle1) begin
            delayed_cycle2 <= 1;
            delayed_cycle1 <= 0;
        end
        else if (delayed_cycle2) begin
            writing <= 1;
            delayed_cycle2 <= 0;
        end
        else if (writing)begin
            writing <= 0;
            stop_write_back <= 1;
            case (ram_num) // Write to corresponding ram
                0: begin
                    wren0 <= 1;
                    data0 <= D_out;
                    //ram_addr_a <= ram_store_addr;
                end
                1: begin
                    wren1 <= 1;
                    data1 <= D_out;
                    //ram_addr_a <= ram_store_addr;
                end
                2: begin
                    wren2 <= 1;
                    data2 <= D_out;
                    //ram_addr_a <= ram_store_addr;
                end
                3: begin
                    wren3 <= 1;
                    data3 <= D_out;
                    //ram_addr_a <= ram_store_addr;
		    // Increment after per z_counter finishes
                    //ram_store_addr <= z_counter_end ? ram_store_addr + 1 : ram_store_addr;
                    //ram_addr_a <= z_counter_end ? ram_addr_a + 1 : ram_addr_a;
                    
                    //ram_store_addr <= ram_store_addr + 1 ;
		    //z_counter_end <= 0;//TODO:Not used?
                end
            endcase
        end
        else if (stop_write_back) begin // Close all write enable
            stop_write_back <= 0;
            wren0 <= 0;
            wren1 <= 0;
            wren2 <= 0;
            wren3 <= 0;
            ram_num <= ram_num + 1;
       if (ram_num == 3) begin
		ram_addr_a <= ram_addr_a +1 ;
            end
        end
    end
end

/***
READ
***/

always_ff @(posedge clk) begin
    if (reset) begin

   	wr_en <= 0;
        EN_CONFIG <= 0;
        EN_FSM <= 0;

        //addr
        image_ram_addr <= 0;
        conv_ram_addr <= 0;
        ram_addr_b <= 0;
        dense_ram_addr <= 0;
	dense_ram_bias_addr <= 0;
	DA <= 8'b00100000; // SSFR
        DB <= 8'b00000000;

        //delay_Sig
        delayed <= 1;

    end else begin
        EN_FSM <= 0;

        //*****CASE OF DIFFERENT STATE*****//
        case (current_state)
            //STATE 0: IDLE
            IDLE: begin
        	z_counter <= 0;
		//z_counter_end <= 0;
                //layer 12
                layer12_count <= 0;
                block_count <= 0;
                channel32_count <= 0;
                //layer 34
                filter32_count <= 5'b0;
                channel64_count <= 6'b0;
                block34_count <= 0;
		layer34_count <= 0;
        	//layer 5
        	block5_count <= 0;
        	layer5_count <= 0;
		filter32_count_1 <= 0;
		channel64_count_1 <= 0;
		// dense
		dense_count <= 0;
		dense_bias_count <= 0;
		dense_case <= 0;
		// dense 10
		dense_10_case <= 0;

                if (next_state == LAYER12) begin
			// Preparing in advance
                	image_ram_addr <= image_ram_addr + 1;
                	conv_ram_addr <= conv_ram_addr +1;
                	EN_FSM <= 1;
                end
            end

/***************
LAYER 12
****************/


            //STATE 1: Convolute and maxpooling 30*30 into 14x14x32
	    // Use one filter to conv a 4*4, then move to next block with the same filter
	    // After 196 blocks, switch to the next filter and do it again
	    // Finish after 32 filters
            LAYER12: begin 
                //11 cycles in total to deal with a 4x4 block
                case (layer12_count) 
                    0: begin 
			// Outputting bias and coefficient
                	conv_ram_addr <= conv_ram_addr  + 1; // Reading Bias and filter
                        processing_unit_4x4[0] <= read_image0;
                        processing_unit_4x4[1] <= read_image1;
                        processing_unit_4x4[2] <= read_image2;
                        processing_unit_4x4[3] <= read_image3;
                        //MAC counter = filter number = 9
                        DB <= 8'd0; //DB
                        DD <= 8'd9; //DD
                        DA <= read_conv; // Bias //DA DC DE DG
                        DC <= read_conv;
                        DE <= read_conv;
                        DG <= read_conv;
			EN_CONFIG <= 0;
                        EN_FSM <= 0;

                        image_ram_addr <= image_ram_addr + 14;
			layer12_count <= layer12_count + 1;
                        
                    end
                    1: begin
                	conv_ram_addr <= conv_ram_addr  + 1;
                        processing_unit_4x4[4] <= read_image0;
                        processing_unit_4x4[5] <= read_image1;
                        processing_unit_4x4[6] <= read_image2;
                        processing_unit_4x4[7] <= read_image3;
                        DA <= processing_unit_4x4[0]; // Pixel value
                        DC <= processing_unit_4x4[1];
                        DE <= processing_unit_4x4[2];
                        DG <= processing_unit_4x4[3];
                        DB <= read_conv; // Param0, same for all four
                        DD <= read_conv;
                        DF <= read_conv;
                        DH <= read_conv;

                        image_ram_addr <= image_ram_addr + 1;
			layer12_count <= layer12_count + 1;
                    end
                    2: begin
                	conv_ram_addr <= conv_ram_addr  + 1;
                        processing_unit_4x4[8] <= read_image0;
                        processing_unit_4x4[9] <= read_image1;
                        processing_unit_4x4[10] <= read_image2;
                        processing_unit_4x4[11] <= read_image3;
                        DA <= processing_unit_4x4[1];
                        DC <= processing_unit_4x4[4];
                        DE <= processing_unit_4x4[3];
                        DG <= processing_unit_4x4[6];
                        DB <= read_conv; // Param1
                        DD <= read_conv;
                        DF <= read_conv;
                        DH <= read_conv;
			    case (z_counter)
				0: image_ram_addr <= image_ram_addr - 15; // To upper right side block
				1: image_ram_addr <= image_ram_addr -  2; // To lower left side block
				2: image_ram_addr <= image_ram_addr - 15; // To lower right side block
				3: begin  // TO upper left side of the next block
				       if ((image_ram_addr-44)%30 == 0) image_ram_addr <= image_ram_addr -14;
				       else  image_ram_addr <= image_ram_addr - 30;
				   end
			    endcase

                  
                        z_counter <= z_counter + 1;

			layer12_count <= layer12_count + 1;
                    end
                    3: begin
                	conv_ram_addr <= conv_ram_addr  + 1; // Reading Bias and filter
                        processing_unit_4x4[12] <= read_image0;
                        processing_unit_4x4[13] <= read_image1;
			processing_unit_4x4[14] <= read_image2;
                        processing_unit_4x4[15] <= read_image3;
                        DA <= processing_unit_4x4[4];
                        DC <= processing_unit_4x4[5];
                        DE <= processing_unit_4x4[6];
                        DG <= processing_unit_4x4[7];
                        DB <= read_conv; // Param2
                        DD <= read_conv;
                        DF <= read_conv;
                        DH <= read_conv;

			layer12_count <= layer12_count + 1;
                    end

                    4: begin
                	conv_ram_addr <= conv_ram_addr  + 1; // Reading Bias and filter
                        DA <= processing_unit_4x4[2];
                        DC <= processing_unit_4x4[3];
                        DE <= processing_unit_4x4[8];
                        DG <= processing_unit_4x4[9];
                        DB <= read_conv; // Param3
                        DD <= read_conv;
                        DF <= read_conv;
                        DH <= read_conv;
                        
			layer12_count <= layer12_count + 1;
                    end

                    5: begin
                	conv_ram_addr <= conv_ram_addr  + 1; // Reading Bias and filter
                        DA <= processing_unit_4x4[3];
                        DC <= processing_unit_4x4[6];
                        DE <= processing_unit_4x4[9];
                        DG <= processing_unit_4x4[12];
                        DB <= read_conv; // Param4
                        DD <= read_conv;
                        DF <= read_conv;
                        DH <= read_conv;

			layer12_count <= layer12_count + 1;
                    end

                    6: begin
                	conv_ram_addr <= conv_ram_addr  + 1; // Reading Bias and filter
                        DA <= processing_unit_4x4[6];
                        DC <= processing_unit_4x4[7];
                        DE <= processing_unit_4x4[12];
                        DG <= processing_unit_4x4[13];
                        DB <= read_conv; // Param5
                        DD <= read_conv;
                        DF <= read_conv;
                        DH <= read_conv;

			layer12_count <= layer12_count + 1;
                    end

                    7: begin
                	conv_ram_addr <= conv_ram_addr  + 1; // Reading Bias and filter
                        DA <= processing_unit_4x4[8];
                        DC <= processing_unit_4x4[9];
                        DE <= processing_unit_4x4[10];
                        DG <= processing_unit_4x4[11];
                        DB <= read_conv; // Param6
                        DD <= read_conv;
                        DF <= read_conv;
                        DH <= read_conv;

			layer12_count <= layer12_count + 1;
                    end

                    8: begin
                	conv_ram_addr <= conv_ram_addr  + 1; // Reading Bias and filter
                        DA <= processing_unit_4x4[9];
                        DC <= processing_unit_4x4[12];
                        DE <= processing_unit_4x4[11];
                        DG <= processing_unit_4x4[14];
                        DB <= read_conv; // Param7
                        DD <= read_conv;
                        DF <= read_conv;
                        DH <= read_conv;

			layer12_count <= layer12_count + 1;
                    end

                    9: begin
                        DA <= processing_unit_4x4[12];
                        DC <= processing_unit_4x4[13];
                        DE <= processing_unit_4x4[14];
                        DG <= processing_unit_4x4[15];
                        DB <= read_conv; // Param8
                        DD <= read_conv;
                        DF <= read_conv;
                        DH <= read_conv;

			layer12_count <= layer12_count + 1;
                        
			// NOTE: Preparation work must be done at this cycle
			// to be able to reflect in 0 or 0 at next stage

                        if(block_count != 195) begin
				// Normal, switch block
				conv_ram_addr <= conv_ram_addr - 10; // 10 -> 0
				block_count <= block_count + 1;
			end
			else if (channel32_count == 31) begin
				// The last block of the last cycle
				channel32_count <= channel32_count + 1;
			end
			else begin
				// Switching filter
				channel32_count <= channel32_count + 1; // 32 filters, when loop_count == 32, next state.
				block_count <= 0;
                            	image_ram_addr <= 0;
				
			end
                    end

                    10: begin
			conv_ram_addr <= conv_ram_addr  + 1;
			image_ram_addr <= image_ram_addr + 1;
                        EN_CONFIG <= 1;
                        EN_FSM <= 1;
                        DA <= 8'b11000001; // SSFR
                        DB <= 8'b00101000;

			wr_en <= 1; // write back once
                        layer12_count <= 0;

			if (channel32_count == 32) ram_addr_b <= ram_addr_b + 1;
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

                case (layer34_count) 
                    0: begin // Outputting bias and MACcounter = 32
                             
                        processing_unit_4x4[0] <= read_res0;
                        processing_unit_4x4[1] <= read_res1;
                        processing_unit_4x4[2] <= read_res2;
                        processing_unit_4x4[3] <= read_res3;

                        //MAC counter = filter number = 288
                        DB <= 8'd1; //256
                        DD <= 8'd32;//32
                        DA <= read_conv; // Bias
			DC <= read_conv;
			DE <= read_conv;
			DG <= read_conv;
			EN_CONFIG <= 0;
                        EN_FSM <= 0;
//                        if (channel64_count == 32) begin 
//                             ram_addr_b <= 1568; // already in layer5
                           
//                        end
//                        else begin 
//                            if ( filter32_count == 0)
                            	ram_addr_b <= ram_addr_b+ 6; //still in layer34
//                            else 
//				ram_addr_b <= ram_addr_b+ 1; //still in layer34
                            conv_ram_addr <= conv_ram_addr + 1; 
//                        end
                    end
                    1: begin
                conv_ram_addr <= conv_ram_addr + 1;
                        processing_unit_4x4[4] <= read_res0;
                        processing_unit_4x4[5] <= read_res1;
                        processing_unit_4x4[6] <= read_res2;
                        processing_unit_4x4[7] <= read_res3;
                        DA <= processing_unit_4x4[0];
                        DC <= processing_unit_4x4[1];
                        DE <= processing_unit_4x4[2];
                        DG <= processing_unit_4x4[3];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                        if ( filter32_count == 0) ram_addr_b <= ram_addr_b + 1;
                        else ram_addr_b <= ram_addr_b + 6;
                    end
                    2: begin
                conv_ram_addr <= conv_ram_addr + 1;
                        processing_unit_4x4[8] <= read_res0;
                        processing_unit_4x4[9] <= read_res1;
                        processing_unit_4x4[10] <= read_res2;
                        processing_unit_4x4[11] <= read_res3;
                        DA <= processing_unit_4x4[1];
                        DC <= processing_unit_4x4[4];
                        DE <= processing_unit_4x4[3];
                        DG <= processing_unit_4x4[6];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                        if (filter32_count == 0) ram_addr_b <= ram_addr_b - 8;
                        else ram_addr_b <= ram_addr_b + 1;
                    end
                    3: begin
                conv_ram_addr <= conv_ram_addr + 1;
                        processing_unit_4x4[12] <= read_res0;
                        processing_unit_4x4[13] <= read_res1;
                        processing_unit_4x4[14] <= read_res2;
                        processing_unit_4x4[15] <= read_res3;
                        DA <= processing_unit_4x4[4];
                        DC <= processing_unit_4x4[5];
                        DE <= processing_unit_4x4[6];
                        DG <= processing_unit_4x4[7];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                        if (filter32_count == 0) begin end
                        else ram_addr_b <= ram_addr_b - 8;
                        //return to the original para ram place since next layer use same address
                    end

                    4: begin
                conv_ram_addr <= conv_ram_addr + 1;
                        DA <= processing_unit_4x4[2];
                        DC <= processing_unit_4x4[3];
                        DE <= processing_unit_4x4[8];
                        DG <= processing_unit_4x4[9];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                    end

                    5: begin
                conv_ram_addr <= conv_ram_addr + 1;
                        DA <= processing_unit_4x4[3];
                        DC <= processing_unit_4x4[6];
                        DE <= processing_unit_4x4[9];
                        DG <= processing_unit_4x4[12];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                    end

                    6: begin
                conv_ram_addr <= conv_ram_addr + 1;
                        DA <= processing_unit_4x4[6];
                        DC <= processing_unit_4x4[7];
                        DE <= processing_unit_4x4[12];
                        DG <= processing_unit_4x4[13];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                    end

                    7: begin
                conv_ram_addr <= conv_ram_addr + 1;
                        DA <= processing_unit_4x4[8];
                        DC <= processing_unit_4x4[9];
                        DE <= processing_unit_4x4[10];
                        DG <= processing_unit_4x4[11];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                    end

                    8: begin
                conv_ram_addr <= conv_ram_addr + 1;
                        DA <= processing_unit_4x4[9];
                        DC <= processing_unit_4x4[12];
                        DE <= processing_unit_4x4[11];
                        DG <= processing_unit_4x4[14];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                        filter32_count <= filter32_count + 1; //go to next channel of prev layer
                        if (filter32_count < 31) begin 
                            //Have Not Finish ONE Filter
                            ram_addr_b <= ram_addr_b + 49;//restart ram from the start position in this block
                            //layer34_count <= 1;                              //Filter not finished, do not return to 0
                        end
                    end

                    9: begin
               
                        DA <= processing_unit_4x4[12];
                        DC <= processing_unit_4x4[13];
                        DE <= processing_unit_4x4[14];
                        DG <= processing_unit_4x4[15];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;

                        processing_unit_4x4[0] <= read_res0;
                        processing_unit_4x4[1] <= read_res1;
                        processing_unit_4x4[2] <= read_res2;
                        processing_unit_4x4[3] <= read_res3;
                        

                       // if (filter32_count < 32) begin 
                        //    ram_addr_b <= ram_addr_b + 1;
                            //Have Not Finish ONE Filter
                        //    layer34_count <= 1;                              //Filter not finished, do not return to 0
                       // end


                        if (filter32_count == 32) begin
                            case (z_counter)
                            0: ram_addr_b <= ram_addr_b - 49*31 + 1; // To upper right side block
                            1: ram_addr_b <= ram_addr_b - 49*31 + 6; // To lower left side block
                            2: ram_addr_b <= ram_addr_b - 49*31 + 1; // To lower right side block
                            3: begin
				if ((ram_addr_b -49*31 +2) % 14 == 0) ram_addr_b <= ram_addr_b -49*31+2;
				else ram_addr_b <= ram_addr_b - 49*31- 6; // TO upper left side of the next block
			    end
                            endcase
                            z_counter <= z_counter + 1;

                            if (block34_count != 35) begin
                                conv_ram_addr <= conv_ram_addr - 289;

                            end else begin //block34_count == 35
                                conv_ram_addr <= conv_ram_addr;
                                if (channel64_count == 31) ram_addr_b <= 1568;
                                else if (channel64_count < 31) ram_addr_b <= layer34_start_position; 
                            end
                        end else begin
                            conv_ram_addr <= conv_ram_addr + 1;
                            ram_addr_b <= ram_addr_b + 1;
                            //Have Not Finish ONE Filter
                            layer34_count <= 1;                              //Filter not finished, do not return to 0
                        end

                        //if (filter32_count == 32 && channel64_count == 31 && block34_count == 35)
                        //    ram_addr_b <= 1568;
                        //else if (channel64_count < 31 && filter32_count ==32) ram_addr_b <= layer34_start_position; 

			//if (filter32_count == 32 && block34_count !=35) begin 
                        //    conv_ram_addr <= conv_ram_addr -289;
                        //    EN_CONFIG <= 1;
                        //end
                        //else if (filter32_count == 32 && block34_count == 35) conv_ram_addr <= conv_ram_addr;
                        //else  conv_ram_addr <= conv_ram_addr + 1;
                        
                    end

                    10: begin
                conv_ram_addr <= conv_ram_addr + 1;
                            //One Filter Finished
			    //conv_ram_addr <= conv_ram_addr - 1; //No adding parameter ram address this cycle
                            //RESET counters and address position
                            filter32_count <= 0;                      //next filter counter begin

                            layer34_count <= 0;                       //Filter finished, read same bias for next filter
                            
                            wr_en <= 1; //write back after finishing one block
                            // SSFR output
                            DA <= 8'b11000001;
                            DB <= 8'b00101000;
                            EN_CONFIG <= 1;
                            EN_FSM <= 1;
                            //next block
                            block34_count <= block34_count + 1;
                            if (filter32_count ==32) ram_addr_b <= ram_addr_b+1;
                            //case (z_counter)
                            //0: ram_addr_b <= ram_addr_b - 49*31 + 1; // To upper right side block
                            //1: ram_addr_b <= ram_addr_b - 49*31 + 6; // To lower left side block
                            //2: ram_addr_b <= ram_addr_b - 49*31 + 1; // To lower right side block
                            //3: begin
				//if ((ram_addr_b -49*31 +2) % 14 == 0) ram_addr_b <= ram_addr_b -49*31+2;
				//else ram_addr_b <= ram_addr_b - 49*31- 6; // TO upper left side of the next block
			    //end
                            //endcase
                            //z_counter <= z_counter + 1;

                            if (block34_count == 35) begin 
                            //6x6 blocks finished , switch filter
                             //   if (next_state == LAYER5)
                              //      ram_addr_b <= 1568;
                             //   else ram_addr_b <= layer34_start_position; 
                                channel64_count <= channel64_count + 1;
                                block34_count <= 0;
                            end  
                            else begin 
                            // block not finished, same filter, restart conv_ram
                                //conv_ram_addr <= conv_ram_addr - 289;  //12*12*32; Back to the same filter
                                //layer34_count <= 0;
                            end

                    end
                endcase
            end

/***************
LAYER 5
****************/

            LAYER5: begin //TODO: Need to modify
                layer5_count <= layer5_count + 1;//next cycle for 3x3
                //conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                //TODO: ram_addr_b start from 1 here, NEED TO CHANGE
                //if (in_layer5) conv_ram_addr <= 1568;
                case (layer5_count) 
                    0: begin // Outputting bias and MACcounter = 32
                	conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                        processing_unit_4x4[0] <= read_res0;
                        processing_unit_4x4[1] <= read_res1;
                        processing_unit_4x4[2] <= read_res2;
                        processing_unit_4x4[3] <= read_res3;
                        //MAC counter = filter number = 288
                        DB <= 8'd1; //256
                        DD <= 8'd32; //32
                        DA <= read_conv; // Bias
			DC <= read_conv;
			DE <= read_conv;
			DG <= read_conv;
                        ram_addr_b <= ram_addr_b + 1;

			EN_CONFIG <= 0;
                        EN_FSM <= 0;
                        if (channel64_count_1 == 32) begin 
                             ram_addr_b <= 1568 + 289; // already in layer dense
                        end
                        else begin 
				if (filter32_count_1 == 0)
                            		ram_addr_b <= ram_addr_b+ 2; //still in layer5
                                else 
 					ram_addr_b <= ram_addr_b +1;
                            conv_ram_addr <= conv_ram_addr + 1; 
                        end
                    end
                    1: begin
                	conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                        processing_unit_4x4[4] <= read_res0;
                        processing_unit_4x4[5] <= read_res1;
                        processing_unit_4x4[6] <= read_res2;
                        processing_unit_4x4[7] <= read_res3;
                        DA <= processing_unit_4x4[0];
                        DC <= processing_unit_4x4[1];
                        DE <= processing_unit_4x4[2];
                        DG <= processing_unit_4x4[3];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                        if ( filter32_count_1 == 0) ram_addr_b <= ram_addr_b + 1;
                        else ram_addr_b <= ram_addr_b + 2;
                    end
                    2: begin
                	conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                        processing_unit_4x4[8] <= read_res0;
                        processing_unit_4x4[9] <= read_res1;
                        processing_unit_4x4[10] <= read_res2;
                        processing_unit_4x4[11] <= read_res3;
                        DA <= processing_unit_4x4[1];
                        DC <= processing_unit_4x4[4];
                        DE <= processing_unit_4x4[3];
                        DG <= processing_unit_4x4[6];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                        if (filter32_count_1 == 0) ram_addr_b <= ram_addr_b - 4;
                        else ram_addr_b <= ram_addr_b + 1;
                    end
                    3: begin
                	conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                        processing_unit_4x4[12] <= read_res0;
                        processing_unit_4x4[13] <= read_res1;
                        processing_unit_4x4[14] <= read_res2;
                        processing_unit_4x4[15] <= read_res3;
                        DA <= processing_unit_4x4[4];
                        DC <= processing_unit_4x4[5];
                        DE <= processing_unit_4x4[6];
                        DG <= processing_unit_4x4[7];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                        if (filter32_count_1 == 0) begin end
                        else ram_addr_b <= ram_addr_b - 4;
                        //return to the original para ram place since next layer use same address
                    end

                    4: begin
                	conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                        DA <= processing_unit_4x4[2];
                        DC <= processing_unit_4x4[3];
                        DE <= processing_unit_4x4[8];
                        DG <= processing_unit_4x4[9];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                    end

                    5: begin
                	conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                        DA <= processing_unit_4x4[3];
                        DC <= processing_unit_4x4[6];
                        DE <= processing_unit_4x4[9];
                        DG <= processing_unit_4x4[12];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                    end

                    6: begin
                	conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                       DA <= processing_unit_4x4[6];
                        DC <= processing_unit_4x4[7];
                        DE <= processing_unit_4x4[12];
                        DG <= processing_unit_4x4[13];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                    end

                    7: begin
                	conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                       DA <= processing_unit_4x4[8];
                        DC <= processing_unit_4x4[9];
                        DE <= processing_unit_4x4[10];
                        DG <= processing_unit_4x4[11];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                    end

                    8: begin
                	conv_ram_addr <= conv_ram_addr + 1;//TODO: check if conv_ram start from right position
                        DA <= processing_unit_4x4[9];
                        DC <= processing_unit_4x4[12];
                        DE <= processing_unit_4x4[11];
                        DG <= processing_unit_4x4[14];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;
                        filter32_count_1 <= filter32_count_1 + 1; //go to next channel of prev layer
                        if (filter32_count_1 < 31) begin 
                            //Have Not Finish ONE Filter
                            ram_addr_b <= ram_addr_b + 9;//restart ram from the start position in this block
                            //layer34_count <= 1;                              //Filter not finished, do not return to 0
                        end
                    end

                    9: begin

                        DA <= processing_unit_4x4[12];
                        DC <= processing_unit_4x4[13];
                        DE <= processing_unit_4x4[14];
                        DG <= processing_unit_4x4[15];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;

			processing_unit_4x4[0] <= read_res0;
                        processing_unit_4x4[1] <= read_res1;
                        processing_unit_4x4[2] <= read_res2;
                        processing_unit_4x4[3] <= read_res3;

                        if (filter32_count_1 == 32) begin
                            case (z_counter)
                            0: ram_addr_b <= ram_addr_b - 9*31 + 1; // To upper right side block
                            1: ram_addr_b <= ram_addr_b - 9*31 + 2; // To lower left side block
                            2: ram_addr_b <= ram_addr_b - 9*31 + 1; // To lower right side block
                            3: begin
				if ((ram_addr_b -9*31 +1) % 3  == 0) ram_addr_b <= ram_addr_b -9*31+2;
				else ram_addr_b <= ram_addr_b - 9*31- 3; // TO upper left side of the next block
			    end
                            endcase
                            z_counter <= z_counter + 1;
                            
                            if (block5_count != 3) begin
                                conv_ram_addr <= conv_ram_addr - 289;

                            end else begin //block34_count == 35
                                conv_ram_addr <= conv_ram_addr;
                                if (channel64_count_1 == 31) ram_addr_b <= 1568+288;
                                else if (channel64_count_1 < 31) ram_addr_b <= layer5_start_position; 
                            end
                        end else begin
                            conv_ram_addr <= conv_ram_addr + 1;
                            ram_addr_b <= ram_addr_b + 1;
                            //Have Not Finish ONE Filter
                            layer5_count <= 1;                              //Filter not finished, do not return to 0
			end

		    end

                    10: begin
                conv_ram_addr <= conv_ram_addr + 1;
                            //One Filter Finished
			    //conv_ram_addr <= conv_ram_addr - 1; //No adding parameter ram address this cycle
                            //RESET counters and address position
                            filter32_count_1 <= 0;                      //next filter counter begin

                            layer5_count <= 0;                       //Filter finished, read same bias for next filter
                            
                            wr_en <= 1; // TODO "special" write back, may write sequentially, write 4 works too
                            // SSFR output

                            DA <= 8'b01000000;
                            DB <= 8'b10110000;
                            EN_CONFIG <= 1;
                            EN_FSM <= 1;
                            //next block
                            block5_count <= block5_count + 1;
                            if (filter32_count_1 ==32) ram_addr_b <= ram_addr_b+1;


                            if (block5_count == 3) begin 
                            //2x2 blocks finished , switch filter
                                //ram_addr_b <= layer5_start_position; 
                                channel64_count_1 <= channel64_count_1 + 1;
                                block5_count <= 0;
                            end  
                            else begin 
                            // block not finished, same filter, restart conv_ram
                               // conv_ram_addr <= conv_ram_addr - 288;  //3*3*32; Back to the same filter
                            end

                    end
                endcase
            end

/********
DENSE LAYER
********/


            DENSE: begin 
		// TODO need write back
		// TODO check dense ram capacity
		// Need 4 dense mems, each has: (bias * 1 + params * 512) * 8
		case (dense_case) // 32/4 cycles total
			0: begin
				// MAC counter 512
				DB <= 8'd2; //512
				DD <= 8'd0; //0
				// make sure this is getting different bias
				DA <= read_denseb_0; // Bias
				DC <= read_denseb_1;
				DE <= read_denseb_2;
				DG <= read_denseb_3;

				EN_CONFIG <= 0;
                            	EN_FSM <= 0;

				ram_addr_b <= ram_addr_b + 1; // Next cycle reads next position of conv result
				dense_ram_bias_addr <= dense_ram_bias_addr + 1; // Next param

				dense_case <= dense_case + 1; // switch case
			end
			1: begin
				DB <= read_denseb_0; // Different 
				DD <= read_denseb_1;
				DF <= read_denseb_2;
				DH <= read_denseb_3;
				DA <= read_res0; // Same conv result correspond to different dense parameters TODO maybe just one mem?
				DC <= read_res1; // But we can still read from 4 different conv_mems
				DE <= read_res2; // 4 exact copies, each 512 nums
				DG <= read_res3;

				if (dense_count < 511) begin
					// Keep calculating 512 times
					ram_addr_b <= ram_addr_b + 1;
					dense_ram_bias_addr <= dense_ram_bias_addr + 1;
					dense_case <= 1;
					dense_count <= dense_count + 1;
				end
				else begin
					// dense_count == 511
					// Switch to next four set of biases
					dense_ram_bias_addr <= dense_ram_bias_addr + 1;
					dense_case <= dense_case + 1;
					dense_count <= 0;
					dense_bias_count <= dense_bias_count + 4;

					// If just switch, return to orignal pos
					// If change stage. keep reading from result ram
					if (dense_bias_count == 28) begin
						ram_addr_b <= ram_addr_b - 512;
					end
					else begin
						ram_addr_b <= ram_addr_b + 1;
					end
				end
			end
			2: begin
				// Basically wait for data to load from new addr

				// SSFR output
                        	DB <= 8'b01100001;
                        	DD <= 8'b00101000;
				EN_CONFIG <= 1;
                            	EN_FSM <= 1;
				wr_en <= 1; // Write four

				if (dense_bias_count == 32) begin
					// Right now, next_state == DENSE_10, be in charge of preparing the addr for next stage
					// Preparing is done at 1, do nothing
					dense_bias_count <= 0;
				end
				else begin
					dense_case <= 0;
				end
			end
		endcase
            end


/********
DENSE 10 LAYER
********/


            DENSE_10: begin 
		// TODO need write back
		// TODO check dense ram capacity
		// Need 4 dense mems, each has: (bias * 1 + params * 512) * 8
		case (dense_10_case) // 32/4 cycles total
			0: begin
				// MAC counter 10
				DB <= 8'd0; //0
				DD <= 8'd10; //10
				// make sure this is getting different bias
				DA <= read_denseb_0; // Bias
				DC <= read_denseb_1;
				DE <= read_denseb_2;
				DG <= read_denseb_3;

				EN_CONFIG <= 0;
                            	EN_FSM <= 0;

				ram_addr_b <= ram_addr_b + 1; // Next cycle reads next position of conv result
				dense_ram_bias_addr <= dense_ram_bias_addr + 1; // Next param

				dense_10_case <= dense_10_case + 1; // switch case
			end
			1: begin
				DB <= read_denseb_0; // Different 
				DD <= read_denseb_1;
				DF <= read_denseb_2;
				DH <= read_denseb_3;
				DA <= read_res0; // Same conv result correspond to different dense parameters TODO maybe just one mem?
				DC <= read_res1; // But we can still read from 4 different conv_mems
				DE <= read_res2; // 4 exact copies, each 512 nums
				DG <= read_res3;

				if (dense_count < 9) begin
					// Keep calculating 10 times
					ram_addr_b <= ram_addr_b + 1;
					dense_ram_bias_addr <= dense_ram_bias_addr + 1;
					dense_case <= 1;
					dense_count <= dense_count + 1;
				end
				else begin
					// dense_count == 9
					// Switch to next four set of biases
					dense_ram_bias_addr <= dense_ram_bias_addr + 1;
					dense_10_case <= dense_10_case + 1;
					dense_count <= 0;
					dense_bias_count <= dense_bias_count + 4;

					// If just switch, return to orignal pos
					// If change stage. keep reading from result ram
					if (dense_bias_count == 8) begin
						ram_addr_b <= ram_addr_b - 10;
						dense_bias_count <= dense_bias_count + 1;
					end
					else ram_addr_b <= ram_addr_b + 1;
				end
			end
			2: begin
				// Basically wait for data to load from new addr
				// TODO Output result to interface!!!

				// SSFR output
                        	DB <= 8'b01100000;
                        	DD <= 8'b10110000;
				EN_CONFIG <= 1;
                            	EN_FSM <= 1;

				if (dense_bias_count == 12) begin
					// Right now, next_state == DENSE_FINAL, be in charge of preparing the addr for next stage
					// Preparing is done at 1, do nothing
				end
				else begin
					dense_10_case <= 0;
				end
			end
		endcase
            end


            default: begin
                // ? LOL
            end
        endcase  //end of state machine
    end//end if
end//end for ff




endmodule


