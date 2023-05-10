module memory_write(
        input logic        clk,
        input logic        reset,
        input logic [31:0] writedata,
        input logic [31:0] control_reg,
    
        output logic we_image0,we_image1,we_image2,we_image3,we_conv,we_dense0,we_dense1,we_dense2,we_dense3,
        output logic [7:0] data_image0,data_image1,data_image2,data_image3,data_conv,data_dense0,data_dense1,data_dense2,data_dense3,
        output logic [9:0] image_ram_addr_a,
        output logic [14:0] conv_ram_addr_a,
        output logic [14:0] dense_ram_addr_a
);

logic [7:0] image_count;
logic [14:0] conv_write_count,dense_write_count;
//logic [15:0] SSFR_instr;
logic writedone;

typedef enum logic [2:0] { IDLE, WRITE_FOUR, WRITE_SEQ_CONV , WRITE_FOUR_DENSE} state_t;
state_t current_state, next_state, state_delay;

// State updates
always_ff @(posedge clk) begin
    if (reset)
        current_state <= IDLE;
    else 
        current_state <= next_state;
	state_delay <= current_state;
    
end

// State Switching
always_comb begin
    next_state = current_state;
    if (control_reg == 32'h0001 && current_state == IDLE && (!writedone)) //TODO 
        next_state = WRITE_FOUR;
    else if (image_count == 8'd224 && current_state == WRITE_FOUR)
        next_state = WRITE_SEQ_CONV;
    else if (conv_write_count == 15'd18815 && current_state == WRITE_SEQ_CONV)
        next_state = WRITE_FOUR_DENSE;
    else if (dense_write_count == 15'd4203 && current_state == WRITE_FOUR_DENSE)
        next_state = IDLE;
end


// WRITE
always_ff @(posedge clk) begin
        case (current_state)
            IDLE: begin
                    image_count <= 8'b0;
                    writedone <= 0;
                    image_ram_addr_a <= 0;
                    conv_ram_addr_a <= 0;
                    dense_ram_addr_a <= 0;
                    image_count <= 0;
                    conv_write_count <= 0;
                    dense_write_count <= 0;
            end

            WRITE_FOUR: begin // Data is splitted into 4. store in different memories
                    if (image_count < 8'd224) begin
                        image_count <= image_count + 1;
                        image_ram_addr_a <= image_ram_addr_a + 1; 
                    end
		    else begin
			// Write a conv value
				image_count <= image_count + 1;
                        	image_ram_addr_a <= image_ram_addr_a + 1;
				conv_write_count <= conv_write_count + 1;
            			conv_ram_addr_a <= conv_ram_addr_a + 1;
			end
            end

            WRITE_SEQ_CONV: begin
                    if (conv_write_count < 15'd18815) begin
            			conv_write_count <= conv_write_count + 1;
            			conv_ram_addr_a <= conv_ram_addr_a + 1;
                    end else begin
                  	conv_write_count <= conv_write_count + 1;
            		conv_ram_addr_a <= conv_ram_addr_a + 1;   
                        dense_write_count <= dense_write_count + 1;
                        dense_ram_addr_a <= dense_ram_addr_a + 1;                     
                    end  
            end

            WRITE_FOUR_DENSE: begin
                if (dense_write_count < 15'd4202) begin
                    dense_write_count <= dense_write_count + 1;
                    dense_ram_addr_a <= dense_ram_addr_a + 1;
                end
//		else if (dense_write_count == 15'd4203) begin
//		    dense_write_count <= dense_write_count + 1;
//                  dense_ram_addr_a <= dense_ram_addr_a + 1;
//		end
           end

        endcase
end//end for ff

assign data_image0 = writedata[31:24];
assign data_image1 = writedata[23:16];
assign data_image2 = writedata[15:8];
assign data_image3 = writedata[7:0];
assign data_conv   = writedata[7:0];
assign data_dense0 = writedata[31:24];
assign data_dense1 = writedata[23:16];
assign data_dense2 = writedata[15:8];
assign data_dense3 = writedata[7:0];

assign we_image0 = current_state == WRITE_FOUR ? 1:0;
assign we_image1 = current_state == WRITE_FOUR ? 1:0;
assign we_image2 = current_state == WRITE_FOUR ? 1:0;
assign we_image3 = current_state == WRITE_FOUR ? 1:0;
assign we_conv = ((next_state == WRITE_SEQ_CONV) || (image_count == 8'd225)) && conv_write_count < 18816 ? 1:0;
assign we_dense0 = (((next_state == WRITE_FOUR_DENSE) || (conv_write_count == 15'd18815)) && (dense_write_count < 15'd4203)) ? 1:0;
assign we_dense1 = (((next_state == WRITE_FOUR_DENSE) || (conv_write_count == 15'd18815)) && (dense_write_count < 15'd4203)) ? 1:0;
assign we_dense2 = (((next_state == WRITE_FOUR_DENSE) || (conv_write_count == 15'd18815)) && (dense_write_count < 15'd4203)) ? 1:0;
assign we_dense3 = (((next_state == WRITE_FOUR_DENSE) || (conv_write_count == 15'd18815)) && (dense_write_count < 15'd4203)) ? 1:0;

endmodule
