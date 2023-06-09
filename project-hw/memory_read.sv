// Use for 4840 Project
//Memory Access
// Simplified ver.

module memory_read(
    input logic        clk,
    input logic        reset,

    //read from outter ram
    input logic [7:0] read_image0, read_image1, read_image2, read_image3,
    input logic [7:0] read_conv,read_dense0,read_dense1,read_dense2,read_dense3,
    input logic [7:0] D_out,
    input logic [31:0] control_reg,

    output logic [7:0] DA,DB,DC,DD,DE,DF,DG,DH,
    //output logic [7:0] filter0,filter1,filter2,filter3,

    //output read address to upper level
    output logic [31:0] ready,
    output logic [31:0] answer,
    output logic [9:0] image_ram_addr,
    output logic [14:0] conv_ram_addr,
    output logic [14:0] dense_ram_addr,
    output logic [14:0] dense_ram_bias_addr,
    output logic EN_FSM, EN_CONFIG    
);

//send data to res_ram
logic [7:0] data0, data1, data2, data3, data0_four, data0_dense;


//TODO: Weird part, consider changing. It is not weird, I endorse this part.
// This is for reading res_mem addr
parameter layer34_start_position = 0; // This is the first time actually reads conv result (from layer12), position should be 0
parameter layer5_start_position = 1568; // Layer 34 gives out a result size of 14*14*32, divide by 4 into mems
parameter layer_dense_start_position = 1856; // Layer 5 gives out a result size of 6*6*32, div 4, plus previous result
parameter layer_dense10_start_position = 2368;
// Counters
logic [4:0] channel_count;
logic [5:0] filter32_count,filter32_count_1;
logic [6:0] channel32_count,channel64_count,channel64_count_1;
logic [7:0] block_count, block34_count, block5_count;
logic [3:0] layer12_count, layer34_count, layer5_count;
logic [1:0] dense_case, dense_10_case;
logic [5:0] dense_bias_count;
logic [9:0] dense_count;
logic [1:0] z_counter; // To maintain write back sequence
logic z_counter_end;
//Res ram Address Register
logic [13:0] ram_addr_a,ram_addr_b, ram_addr_a_four, ram_addr_a_dense;

logic [7:0] read_res0,read_res1,read_res2,read_res3;

//temp outputs
logic [7:0] out_param_1, out_param_2, out_param_3;

//temp addr served as a counter
logic [13:0] ram_store_addr;

//Write enable Signal
logic wren1,wren2,wren3,wren0;
logic wr_en; //top write back signal
logic wr_en_dense;
logic ready_sig;

//Temp Register to store data in one block
logic [7:0] processing_unit_4x4 [15:0];

//Register to calculate which ram to store in
logic [1:0] ram_num;
logic [2:0] loop_num;
logic [3:0] loop_num_dense;

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
    else if (channel64_count == 6'd32 && layer34_count == 10 && block34_count == 36 && filter32_count ==32 && current_state == LAYER34)
        next_state = LAYER5;  // Counter + CNN + SSFR (ReLU)
    else if (channel64_count_1 == 6'd32 && layer5_count == 10 && block5_count == 4 && filter32_count_1 == 32 && current_state == LAYER5)
        next_state = DENSE;  // Counter + MAC
    else if (dense_bias_count == 32 && current_state == DENSE)
        next_state = DENSE_10;  // Counter + MAC
    else if (dense_bias_count == 12  && current_state == DENSE_10)
        next_state = IDLE;
end


// Responsible for WRITING BACK to memory (layer12 and layer34)


always_ff @(posedge clk) begin
    if (reset) begin
    ram_num <= 0;
    loop_num <= 0;
    ram_addr_a <= 0;
    
    ready <= 0;
    answer <= 0;

    wren0 <=0;
    wren1 <=0;
    wren2 <=0;
    wren3 <=0;
    ready_sig <= 0;

    loop_num_dense <= 0;
    wr_en_dense <= 0;
    end
    else begin
        if (wr_en) begin
            case (loop_num)
                4: begin
		    case (ram_num) // Write to corresponding ram
		        0: begin
		            wren0 <= 1;
		            data0 <= D_out;

		        end
		        1: begin
		            wren1 <= 1;
		            data1 <= D_out;

		        end
		        2: begin
		            wren2 <= 1;
		            data2 <= D_out;

		        end
		        3: begin
		            wren3 <= 1;
		            data3 <= D_out;
		        end
		    endcase
                   end
                 5: begin
                        wren0 <= 0;
            		wren1 <= 0;
            		wren2 <= 0;
            		wren3 <= 0;
                        ram_num <= ram_num + 1;
                        wr_en <= 0;
                        if (ram_num == 3) ram_addr_a <= ram_addr_a + 1;
                        
                    end
	     endcase  
            if (loop_num == 5)
                 loop_num <= 0;
            else
                 loop_num <= loop_num + 1;      
         
        end
    end
    if (reset) begin
    
    end
    else begin
        if (wr_en_dense) begin
            case (loop_num_dense)
                5: begin
		       wren0 <= 1;
		       data0 <= D_out;
		       if (ready_sig == 1) begin
				ready <= 1;
				answer <= D_out;
				ready_sig <= 0;
			end
                   end

                6: begin
                       wren0 <= 0;
                       ram_addr_a <= ram_addr_a + 1;
                   end


		7: begin
		       wren0 <= 1;
		       data0 <= D_out;
		   end

		8: begin
                       wren0 <= 0;
                       ram_addr_a <= ram_addr_a + 1;

		   end

		9: begin
		       wren0 <= 1;
		       data0 <= D_out;
		   end

		10: begin
		       wren0 <= 0;
                       ram_addr_a <= ram_addr_a + 1;

		   end

		11: begin
		       wren0 <= 1;
		       data0 <= D_out;
		   end

		12: begin
                       wren0 <= 0;
                       ram_addr_a <= ram_addr_a + 1;
                       wr_en_dense <= 0;
                       
		   end

	     endcase  
            if (loop_num_dense == 12) loop_num_dense <= 0;
            else loop_num_dense <= loop_num_dense + 1;        
        end
    end

/***
READ
***/
	if (reset) begin
	end
        //*****CASE OF DIFFERENT STATE*****//
	else begin
        case (current_state)
            //STATE 0: IDLE
            IDLE: begin
		DA <= 0;
		DB <= 0;
		DC <= 0;
		DD <= 0;
		DE <= 0;
		DF <= 0;
		DG <= 0;
		DH <= 0;
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

		EN_CONFIG <= 0;
		EN_FSM <= 0;

		        image_ram_addr <= 0;
        conv_ram_addr <= 0;
        ram_addr_b <= 0;
        dense_ram_addr <= 0;
	dense_ram_bias_addr <= 0;

        EN_CONFIG <= 0;
        EN_FSM <= 0;

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

			if (channel32_count == 32) ram_addr_b <= ram_addr_b + 1; // For the next stage
                    end
                endcase
            end//end STATE LAYER12.

/***************
LAYER 34
****************/

            //STATE 2
            // Use one filter to do 4*4 conv, and do all 32 layers for previous result and current filter
	    // Then move on to the next block
	    // 36 blocks, previous result return to the original position, do this process again with another filter
	    // Finish after 32 filters have been exhausted.
            LAYER34: begin

                case (layer34_count) 
                    0: begin // Outputting bias and MACcounter = 32
			conv_ram_addr <= conv_ram_addr + 1;
			layer34_count <= layer34_count + 1;
                             
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

                        ram_addr_b <= ram_addr_b+ 6;
                    end
                    1: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer34_count <= layer34_count + 1;

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

			ram_addr_b <= ram_addr_b + 1;
                    end
                    2: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer34_count <= layer34_count + 1;

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

			ram_addr_b <= ram_addr_b - 8;

                    end
                    3: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer34_count <= layer34_count + 1;

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
                    end

                    4: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer34_count <= layer34_count + 1;

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
			layer34_count <= layer34_count + 1;

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
			layer34_count <= layer34_count + 1;


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
			layer34_count <= layer34_count + 1;

                        DA <= processing_unit_4x4[8];
                        DC <= processing_unit_4x4[9];
                        DE <= processing_unit_4x4[10];
                        DG <= processing_unit_4x4[11];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;

			// Prepare early since we might not have 10
                        filter32_count <= filter32_count + 1; //go to next channel of prev layer
                        if (filter32_count < 31) begin 
                            //Have Not Finish ONE Filter
                            ram_addr_b <= ram_addr_b + 49;//restart ram from the start position in this block
                        end

                    end

                    8: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer34_count <= layer34_count + 1;

                        DA <= processing_unit_4x4[9];
                        DC <= processing_unit_4x4[12];
                        DE <= processing_unit_4x4[11];
                        DG <= processing_unit_4x4[14];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;

			if (filter32_count < 32) begin 
                            // Compensate for missing layer34 == 1
                            ram_addr_b <= ram_addr_b + 1;
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

			// If we are directly looping back to 1
                        processing_unit_4x4[0] <= read_res0;
                        processing_unit_4x4[1] <= read_res1;
                        processing_unit_4x4[2] <= read_res2;
                        processing_unit_4x4[3] <= read_res3;
                        
			if (filter32_count == 32) begin
				// One filter done at current block
				if (block34_count == 35) begin
					// This filter is entirely done
					if (channel64_count == 31) begin
						// This stage is done
						layer34_count <= layer34_count + 1;
						channel64_count <= channel64_count + 1;
						block34_count <= block34_count + 1;
						z_counter <= 0;

						// Ram addr and conv addr just increase
						ram_addr_b <= layer5_start_position;
					end
					else begin
						// Switch filter
						layer34_count <= layer34_count + 1;
						channel64_count <= channel64_count + 1;
						block34_count <= block34_count + 1;
						z_counter <= 0;

						// Ram addr goes back to pos 0, conv addr is normally increased
						// Check conv addr starts from 289
						ram_addr_b <= layer34_start_position;
					end
				end
				else begin
				// Move block
					case (z_counter)
						// NOTE: we are starting from 0 (in the first cycle)
                            			0: ram_addr_b <= ram_addr_b - 49*31 + 1; // To upper right side block
                            			1: ram_addr_b <= ram_addr_b - 49*31 + 6; // To lower left side block
                            			2: ram_addr_b <= ram_addr_b - 49*31 + 1; // To lower right side block
                            			3: begin
							if ((ram_addr_b -49*31 +2) % 14 == 0) ram_addr_b <= ram_addr_b -49*31+2;
							else ram_addr_b <= ram_addr_b - 49*31 - 6; // To upper left side of the next block
			    			end
                           	 	endcase
                            		z_counter <= z_counter + 1;

					// No need for bias
					// conv parameter/filter needs to be moved back
					conv_ram_addr <= conv_ram_addr - 289; // check whether this has been moved to 320 at next cycle (first cycle only)
					layer34_count <= layer34_count + 1; // can store result
					block34_count <= block34_count + 1;
				end
			end
			else begin
				// Filter not done at current block, dive deeper to another layer and filter layer
				conv_ram_addr <= conv_ram_addr + 1;
				ram_addr_b <= ram_addr_b + 6;
				layer34_count <= 1;
			end
                        
                    end

                    10: begin
                	// If we are here, there are three conditions
			// 1. Move block
			// 2. Switch filter
			// 3. This stage is done
				if (block34_count == 36) block34_count <= 0;
				ram_addr_b <= ram_addr_b + 1; // Compensate for missing add 1
				conv_ram_addr <= conv_ram_addr + 1;
                            filter32_count <= 0;                      //next filter counter begin
			
                            layer34_count <= 0;                       //Filter finished, read same bias for next filter
                            
                            wr_en <= 1; //write back after finishing one block
                            // SSFR output
                            DA <= 8'b11000001;
                            DB <= 8'b00101000;
                            EN_CONFIG <= 1;
                            EN_FSM <= 1;
                    end
                endcase
            end

/***************
LAYER 5
****************/

            //STATE 3
            // Use one filter to do 4*4 conv, and do all 32 layers for previous result and current filter
	    // Then move on to the next block
	    // 4 blocks, previous result return to the original position, do this process again with another filter
	    // Finish after 32 filters have been exhausted.
            LAYER5: begin

                case (layer5_count) 
                    0: begin
			conv_ram_addr <= conv_ram_addr + 1;
			layer5_count <= layer5_count + 1;
                             
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
			EN_CONFIG <= 0;
                        EN_FSM <= 0;

                        ram_addr_b <= ram_addr_b + 2;
                    end
                    1: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer5_count <= layer5_count + 1;

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

			ram_addr_b <= ram_addr_b + 1;
                    end
                    2: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer5_count <= layer5_count + 1;

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

			ram_addr_b <= ram_addr_b - 4;

                    end
                    3: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer5_count <= layer5_count + 1;

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
                    end

                    4: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer5_count <= layer5_count + 1;

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
			layer5_count <= layer5_count + 1;

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
			layer5_count <= layer5_count + 1;

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
			layer5_count <= layer5_count + 1;

                        DA <= processing_unit_4x4[8];
                        DC <= processing_unit_4x4[9];
                        DE <= processing_unit_4x4[10];
                        DG <= processing_unit_4x4[11];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;

			// Prepare early since we might not have 10
                        filter32_count_1 <= filter32_count_1 + 1; //go to next channel of prev layer
                        if (filter32_count_1 < 31) begin 
                            //Have Not Finish ONE Filter
                            ram_addr_b <= ram_addr_b + 9;//restart ram from the start position in this block
                        end

                    end

                    8: begin
                	conv_ram_addr <= conv_ram_addr + 1;
			layer5_count <= layer5_count + 1;

                        DA <= processing_unit_4x4[9];
                        DC <= processing_unit_4x4[12];
                        DE <= processing_unit_4x4[11];
                        DG <= processing_unit_4x4[14];
                        DB <= read_conv; // Bias
			DD <= read_conv;
			DF <= read_conv;
			DH <= read_conv;

			if (filter32_count_1 < 32) begin 
                            // Compensate for missing layer34 == 1
                            ram_addr_b <= ram_addr_b + 1;
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

			// If we are directly looping back to 1
                        processing_unit_4x4[0] <= read_res0;
                        processing_unit_4x4[1] <= read_res1;
                        processing_unit_4x4[2] <= read_res2;
                        processing_unit_4x4[3] <= read_res3;
                        
			if (filter32_count_1 == 32) begin
				// One filter done at current block
				if (block5_count == 3) begin
					// This filter is entirely done
					if (channel64_count_1 == 31) begin
						// This stage is done
						layer5_count <= layer5_count + 1;
						channel64_count_1 <= channel64_count_1 + 1;
						block5_count <= block5_count + 1;
						z_counter <= 0;

						// Ram addr and conv addr just increase
						ram_addr_b <= layer_dense_start_position;
					end
					else begin
						// Switch filter
						layer5_count <= layer5_count + 1;
						channel64_count_1 <= channel64_count_1 + 1;
						block5_count <= block5_count + 1;
						z_counter <= 0;

						// Ram addr goes back to pos 0, conv addr is normally increased
						// Check conv addr starts from 289
						ram_addr_b <= layer5_start_position;
					end
				end
				else begin
				// Move block
					case (z_counter)
						// NOTE: we are starting from 0 (in the first cycle)
                            			0: ram_addr_b <= ram_addr_b - 9*31 + 1; // To upper right side block
                            			1: ram_addr_b <= ram_addr_b - 9*31 + 2; // To lower left side block
                            			2: ram_addr_b <= ram_addr_b - 9*31 + 1; // To lower right side block
                            			3: begin
							if ((ram_addr_b -9*31 +1) % 3 == 0) ram_addr_b <= ram_addr_b -9*31+2;
							else ram_addr_b <= ram_addr_b - 9*31 - 3; // To upper left side of the next block
			    			end
                           	 	endcase
                            		z_counter <= z_counter + 1;

					// No need for bias
					// conv parameter/filter needs to be moved back
					conv_ram_addr <= conv_ram_addr - 289; // check whether this has been moved to ??? at next cycle (first cycle only)
					layer5_count <= layer5_count + 1; // can store result
					block5_count <= block5_count + 1;
				end
			end
			else begin
				// Filter not done at current block, dive deeper to another layer and filter layer
				conv_ram_addr <= conv_ram_addr + 1;
				ram_addr_b <= ram_addr_b + 2;
				layer5_count <= 1;
			end
                        
                    end

                    10: begin
                	// If we are here, there are three conditions
			// 1. Move block
			// 2. Switch filter
			// 3. This stage is done
				if (block5_count == 4) block5_count <= 0;
                                if (next_state == DENSE) begin 
					dense_ram_addr <= dense_ram_addr + 1;
				end //dense_ram_addr <= dense_ram_addr + 1;
				else ram_addr_b <= ram_addr_b + 1; // Compensate for missing add 1
				conv_ram_addr <= conv_ram_addr + 1;
                            filter32_count_1 <= 0;                      //next filter counter begin
			
                            layer5_count <= 0;                       //Filter finished, read same bias for next filter

//			    if (channel64_count_1 == 0 && filter32_count_1 == 32 && block5_count == 1) ram_addr_a <= ram_addr_a + 3; // Very first time do a reverse z
                            wr_en_dense <= 1; //write back after finishing one block
                            // SSFR output
                            DA <= 8'b01000000;
                            DB <= 8'b11010000;
                            EN_CONFIG <= 1;
                            EN_FSM <= 1;
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
				DA <= read_dense0; // Bias
				DC <= read_dense1;
				DE <= read_dense2;
				DG <= read_dense3;

				EN_CONFIG <= 0;
                            	EN_FSM <= 0;

				ram_addr_b <= ram_addr_b + 1; // Next cycle reads next position of conv result
				dense_ram_addr <= dense_ram_addr + 1; // Next param

				dense_case <= dense_case + 1; // switch case
			end
			1: begin
				DB <= read_dense0; // Different 
				DD <= read_dense1;
				DF <= read_dense2;
				DH <= read_dense3;
				DA <= read_res0; // Same conv result correspond to different dense parameters TODO maybe just one mem?
				DC <= read_res0; // But we can still read from 4 different conv_mems
				DE <= read_res0; // 4 exact copies, each 512 nums
				DG <= read_res0;

				if (dense_count < 511) begin
					// Keep calculating 512 times
					if (dense_count != 510) begin
						//if (dense_count != 509) 
						ram_addr_b <= ram_addr_b + 1;
						dense_ram_addr <= dense_ram_addr + 1;
					end
					dense_case <= 1;
					dense_count <= dense_count + 1;
				end
				else begin
					// dense_count == 511
					// Switch to next four set of biases
					dense_ram_addr <= dense_ram_addr + 1;
					dense_case <= dense_case + 1;
					dense_count <= 0;
					dense_bias_count <= dense_bias_count + 4;

					// If just switch, return to orignal pos
					// If change stage. keep reading from result ram
                                        if (dense_bias_count != 28)
						ram_addr_b <= layer_dense_start_position;
                                        else 
                                        	ram_addr_b <= ram_addr_b + 1;

				end
			end
			2: begin
				// Basically wait for data to load from new addr

				// SSFR output
                        	DA <= 8'b01000000;
                            	DB <= 8'b10110000;
				EN_CONFIG <= 1;
                            	EN_FSM <= 1;
				wr_en_dense <= 1; // Write four
				dense_ram_addr <= dense_ram_addr + 1;

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
				// MAC counter 512
				DB <= 8'd0; //0
				DD <= 8'd32; //32
				// make sure this is getting different bias
				DA <= read_dense0; // Bias
				DC <= read_dense1;
				DE <= read_dense2;
				DG <= read_dense3;

				EN_CONFIG <= 0;
                                
                            	EN_FSM <= 0;

				ram_addr_b <= ram_addr_b + 1; // Next cycle reads next position of conv result
				dense_ram_addr <= dense_ram_addr + 1; // Next param

				dense_10_case <= dense_10_case + 1; // switch case
			end
			1: begin
				DB <= read_dense0; // Different 
				DD <= read_dense1;
				DF <= read_dense2;
				DH <= read_dense3;
				DA <= read_res0; // Same conv result correspond to different dense parameters TODO maybe just one mem?
				DC <= read_res0; // But we can still read from 4 different conv_mems
				DE <= read_res0; // 4 exact copies, each 512 nums
				DG <= read_res0;


				if (dense_count < 31) begin
					// Keep calculating 512 times
					dense_10_case <= 1;
					dense_count <= dense_count + 1;

					if (dense_count != 30) begin
						//if (dense_count != 29) 
						dense_ram_addr <= dense_ram_addr + 1;
						ram_addr_b <= ram_addr_b + 1;
						 
                                                 //dense_ram_addr <= dense_ram_addr + 1;
						
					end 
				end
				else begin
					// dense_count == 32
					// Switch to next four set of biases
					dense_ram_addr <= dense_ram_addr + 1;
					dense_10_case <= dense_10_case + 1;
					dense_count <= 0;
					dense_bias_count <= dense_bias_count + 4;
					//dense_ram_addr <= dense_ram_addr + 1; // Next param

					// If just switch, return to orignal pos
					// If change stage. keep reading from result ram
                                        if (dense_bias_count != 8)
						ram_addr_b <= layer_dense10_start_position;
                                        else 
                                        	ram_addr_b <= ram_addr_b + 1;


				end
			end
			2: begin
				// Basically wait for data to load from new addr

				// SSFR output
                        	DA <= 8'b01111111;
                        	DB <= 8'b00101000;
				EN_CONFIG <= 1;
                                if (next_state != IDLE)
                            		EN_FSM <= 1;
				wr_en_dense <= 1; // Write four
				dense_ram_addr <= dense_ram_addr + 1;
				
				if (dense_bias_count == 12) begin
					// Right now, next_state == DENSE_10, be in charge of preparing the addr for next stage
					// Preparing is done at 1, do nothing
					dense_bias_count <= 0;
					dense_10_case <= 0;
					ready_sig <= 1;
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
	end
end//end for ff

//assign data0 = wr_en ? data0_four : data0_dense;
//assign ram_addr_a = wr_en ? ram_addr_a_four : ram_addr_a_dense;

endmodule


