module memory_write(
    input logic        clk,
        input logic        reset,
        input logic [31:0] writedata,
        input logic [31:0] control_reg,
    
        output logic wren0,wren1,wren2,wren3,wren_conv,wren_dense,wren_denseb,
        output logic [7:0] data0,data1,data2,data3,data4,data5,data6,
        output logic [9:0] image_ram_addr,
        output logic [14:0] conv_ram_addr,
        output logic [14:0] dense_ram_addr,
        output logic [14:0] denseb_ram_addr
);

logic [7:0] image_count;
logic [14:0] conv_write_count,dense_write_count;
logic [15:0] SSFR_instr;
logic writedone;

typedef enum logic [2:0] { IDLE, WRITE_FOUR, WRITE_SEQ_CONV , WRITE_SEQ_DENSE} state_t;
state_t current_state, next_state;

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
    if (control_reg == 32'h0001 && current_state == IDLE && (!writedone)) //TODO 
        next_state = WRITE_FOUR;
    else if (image_count == 8'd224 && current_state == WRITE_FOUR)
        next_state = WRITE_SEQ_CONV;
    else if (conv_write_count == 15'd18815 && current_state == WRITE_SEQ_CONV)
        next_state = WRITE_SEQ_DENSE;
    else if (dense_write_count == 15'd16745 && current_state == WRITE_SEQ_DENSE)
        next_state = IDLE;
end


// WRITE
always_ff @(posedge clk) begin
    if (reset) begin
        image_count <= 8'b0;
        writedone <= 0;
        data1 <= 8'b0;
        data2 <= 8'b0;
        data3 <= 8'b0;
        data0 <= 8'b0;
        data4 <= 8'b0;
        data5 <= 8'b0;
        wren0 <= 0;
        wren1 <= 0;
        wren2 <= 0;
        wren3 <= 0;
        wren_conv <= 0;
        wren_dense <= 0;
        image_ram_addr <= 0;
        conv_ram_addr <= 0;
        dense_ram_addr <= 0;
    end else begin
        //data0 <= writedata[31:24];
        //data1 <= writedata[23:16];
        //data2 <= writedata[15:8];
        //data3 <= writedata[7:0];
        SSFR_instr <= 16'b0010000010101000; // TODO change with states
        case (current_state)
            IDLE: begin
                    image_count <= 0;
                    conv_write_count <= 0;
                    dense_write_count <= 0;
            end
        WRITE_FOUR: begin // Data is splitted into 4. store in different memories
            data0 <= writedata[31:24];
            data1 <= writedata[23:16];
            data2 <= writedata[15:8];
            data3 <= writedata[7:0];
            wren0 <= 1;
            wren1 <= 1;
            wren2 <= 1;
            wren3 <= 1;
            wren_conv <= 0;
            wren_dense <= 0;
                    if (image_count < 8'd224) begin
                        image_count <= image_count + 1;
                        image_ram_addr <= image_ram_addr + 1; // TODO check memory addr continuity// We are getting back to this memory later
                    end	  
        end
            WRITE_SEQ_CONV: begin
            data4 <= writedata[7:0];
            wren0 <= 0;
            wren1 <= 0;
            wren2 <= 0;
            wren3 <= 0;
            wren_conv <= 1;
            wren_dense <= 0;
                    if (conv_write_count < 15'd18815) begin
            conv_write_count <= conv_write_count + 1;
            conv_ram_addr <= conv_ram_addr + 1;
                    end
        end
 /*           WRITE_SEQ_DENSE: begin
            data6 <= writedata[7:0];
            wren0 <= 0;
            wren1 <= 0;
            wren2 <= 0;
            wren3 <= 0;
            wren_conv <= 0;
            wren_dense <= 1;
                    if (dense_write_count < 15'd16745) begin
            dense_write_count <= dense_write_count + 1;
            dense_ram_addr <= dense_ram_addr + 1;
                    end
                    else writedone = 1;
        end
        // TODO Two additional states for wrting during calculation
        default: begin
            wren0 <= 0;
            wren1 <= 0;
            wren2 <= 0;
            wren3 <= 0;
            wren_conv <= 0;
            wren_dense <= 0;
        end*/
        endcase  
    end//end if
end//end for ff

endmodule
