// Use for 4840 Project
//Memory Access


module memory_read(
    input logic        clk,
    input logic        reset,
    input logic [31:0] writedata,
    input logic [31:0] control_reg,
    
    output logic [7:0] out0, out1, out2, out3, out_para,
    output logic [7:0] filter0,filter1,filter2,filter3;
    output logic [15:0] SSFR_instr;
);

logic [7:0] data0, data1, data2, data3;

// Counters
logic [7:0] image_count;
logic [15:0] conv1_write_count, conv2_write_count;
logic [15:0] dense_write_count;

logic [4:0] block_count;
logic [2:0] state_count;
logic [3:0] layer12_count;

logic [13:0] ram_addr;
logic [15:0] conv_ram_addr;
logic [15:0] dense_ram_addr;

logic wren1,wren2,wren3,wren0,wren_conv, wren_dense;

logic [7:0] temp [15:0];


typedef enum logic [1:0] { IDLE, LAYER12, LAYER34 , LAYER5, DENSE} state_t;
state_t current_state, next_state;

// Memory module definitions
image_ram ram0 (.address(ram_addr), .clock(clk), .data(data0), .wren(wren0), .q(read0));//address[13:0]
image_ram ram1 (.address(ram_addr), .clock(clk), .data(data1), .wren(wren1), .q(read1));
image_ram ram2 (.address(ram_addr), .clock(clk), .data(data2), .wren(wren2), .q(read2));
image_ram ram3 (.address(ram_addr), .clock(clk), .data(data3), .wren(wren3), .q(read3));
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
    else if (image_count == 8'd196 && current_state == LAYER12)
        next_state = LAYER34; // Counter + CNN + SSFR ( Maxpooling/ReLu )
    else if (conv1_write_count == 16'd55744 && current_state == LAYER34)
        next_state = LAYER5;  // Counter + CNN + SSFR (ReLU)
    else if (conv2_write_count == 16'd37578 && current_state == LAYER5)
        next_state = DENSE;  // Counter + MAC
    else if (dense_count == 16'd37578 && current_state = DENSE)
        next_state = IDLE;
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

        //addr
        ram_addr <= 0;
        conv_ram_addr <= 0;
        dense_ram_addr <= 0;
    end else begin
        SSFR_instr <= 16'b0010000010101000; // TODO change with states // ?
        
        case (current_state)
            IDLE: begin
                    image_count <= 0;
                    conv1_write_count <= 0;
                    conv2_write_count <= 0;
                    dense_write_count <= 0;
            end
            LAYER12: begin //read image from 4 memories. read filter parameters from conv.
                case (stage_count)
                    0:  begin // Includes first 4 cycles of read and store temp regs
                        // Read TODO something fishy
                        conv_ram_addr <= conv_ram_addr + 1; // Reading Bias and filter
                            ram_addr <= layer12_count + block_count; // Block_count is base
                        layer12_count <= layer12_count + 1;

                        // Writing temp registers and output for first 4 cycles
                        case (layer12_count)
                            0: begin // Outputting bias and counter = 32
                                temp[0] <= read0;
                                            temp[1] <= read1;
                                            temp[2] <= read2;
                                            temp[3] <= read3;
                                out0 <= 8'd0;
                                out1 <= 8'd32;
                                out_param <= read4; // Bias
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
                            end
                            4: begin
                                out0 <= temp[2];
                                out1 <= temp[3];
                                out2 <= temp[8];
                                out3 <= temp[9];
                                out_param <= read4; // Param3
                                stage_count <= stage_count + 1;
                            end
                        endcase
                    end // end case 0

                    // TODO write back somewhere here
                    1: begin
                        conv_ram_addr <= conv_ram_addr + 1; // Reading Bias and filter
                        layer12_count <= layer12_count + 1;

                        case (layer12_count)
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
                                out0 <= 8'b11000001; // SSFR
                                out_param <= 8'b00101000;
                                layer12_count <= 0;
                                stage_count <= 0;
                                block_count <= block_count + 4; // Updating offset
                                if (block_count < 676) begin
                                    conv_ram_addr <= conv_ram_addr - 11;
                                    block_count <= 0;
                                end
                            end
                        endcase
                    end
                endcase
                    
            end
            LAYER34: begin

            end
            LAYER5: begin

            
            end
            DENSE: begin

        
            end

            default: begin
                    //?
            end
        

        endcase  
    end//end if
end//end for ff

endmodule




