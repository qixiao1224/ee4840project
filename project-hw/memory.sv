// Use for 4840 Project
//Memory Access


module top_memory(
    input logic        clk,
    input logic        reset,
    input logic [31:0] writedata,
    input logic        write,
    input              chipselect,
    input logic        reading,
    
    output logic [] 
    
);

logic [7:0] data1, data2, data3, data0;
logic [8:0] read1, read2, read3, read4, read5, read0;

// Counters
logic [7:0] image_count;
logic [15:0] conv_write_count;
logic [15:0] dense_write_count;

logic [13:0] ram_addr;
logic [13:0] conv_ram_addr;
logic [15:0] dense_ram_addr;

logic wren1,wren2,wren3,wren0,wren_conv, wren_dense;
logic [1:0] write_state;

enum logic [2:0] {IDLE, WRITE, READ} state_t;
state_t state, next_state;

enum logic [1:0] {WRITE_FOUR, WRITE_SEQ_CONV, WRITE_SEQ_DENSE} write_state_t;
write_state_t write_state, next_write_state;

enum logic [1:0] {READ_BIAS, READ_DATA, READ_STALL, READ_FINAL} read_state_t;
read_state_t read_state, next_read_state;

// Memory module definitions
image_ram ram0 (.address(ram_addr), .clock(clk), .data(data0), .wren(wren0), .q(read0));//address[13:0]
image_ram ram1 (.address(ram_addr), .clock(clk), .data(data1), .wren(wren1), .q(read1));
image_ram ram2 (.address(ram_addr), .clock(clk), .data(data2), .wren(wren2), .q(read2));
image_ram ram3 (.address(ram_addr), .clock(clk), .data(data3), .wren(wren3), .q(read3));
conv_ram conv_ram0 (.address(conv_ram_addr), .clock(clk), .data(data0), .wren(wren_conv), .q(read4));//address [15:0]
dense_ram dense_ram0 (.address(dense_ram_addr), .clock(clk), .data(data0), .wren(wren_dense), .q(read5));


// State updates
always_ff @(posedge clk) begin
   state <= next_state;
   write_state <= next_write_state;
   read_state <= next_read_state;
end



// Sub cases in WRITE stage
assign write_case = (image_count == 8'd196) ? 2'b00 : 
			(conv_write_count == 16'd55744 ? 2'b01 :
                         (dense_write_count == 16'd37578 ? 2'b10 : 2'b11)));




// Outter state switching
always_comb begin
  next_state = state;
  next_write_state = write_state;
  next_read_state = read_state;

  if (reset) begin
     next_state = IDLE;
     next_write_state = WRITE_FOUR;
     next_read_state = READ_BIAS;
  end else 
     case (state)
     IDLE:  // Before everything starts
	    read_count = 0;
	    image_count = 0;
            conv_write_count = 0;
            dense_write_count = 0;
	    if (chipselect && write) begin
		next_state = WRITE;
		next_write_state = WRITE_FOUR;
		end
     WRITE: begin case(write_case) // Fill in data in order
              2'b00: (image_count == 8'd196) begin
			next_write_state = WRITE_SEQ_CONV;
			image_count = 0;
			end
	      2'b01: (conv_write_count == 14'd13936) begin
			next_write_state = WRITE_SEQ_DENSE;
			conv_write_count = 0;
			end
	      2'b10: (dense_write_count == 16'd37578) begin
			next_state == READ;
			dense_write_count = 0;
			end
                 default: next_write_state = next_write_state;
                 endcase
            end
     READ: if(&ram_addr_1 & (&ram_addr_2) & (&ram_addr_3) & (&ram_addr_4)) next_state = IDLE; // TODO
     default: begin
                next_state = IDLE;
                next_write_state = WRITE_FOUR;
		next_read_state = READ_BIAS;
              end
     endcase
  end


end

// WRITE
always_ff @(posedge clk) begin
  if (reset) begin
    image_count <= 8'b0;
    data1 <= 8'b0;
    data2 <= 8'b0;
    data3 <= 8'b0;
    data0 <= 8'b0;
    wren0 <= 0;
    wren1 <= 0;
    wren2 <= 0;
    wren3 <= 0;
    wren_conv <= 0;
    wren_dense <= 0;
    ram_addr <= 0;
    conv_ram_addr <= 0;
    dense_ram_addr <= 0;
  end else if (state == WRITE) begin
    data0 <= writedata[31:24];
    data1 <= writedata[23:16];
    data2 <= writedata[15:8];
    data3 <= writedata[7:0];
    case (write_state)
	WRITE_FOUR: begin // Data is splitted into 4. store in different memories
		wren0 <= 1;
		wren1 <= 1;
		wren2 <= 1;
		wren3 <= 1;
		wren_conv <= 0;
		wren_dense <= 0;
		image_count <= image_count + 1;
		ram_addr <= ram_addr + 1; // TODO check memory addr continuity
					  // We are getting back to this memory later
	end
        WRITE_SEQ_CONV: begin
		wren0 <= 0;
		wren1 <= 0;
		wren2 <= 0;
		wren3 <= 0;
		wren_conv <= 1;
		wren_dense <= 0;
		conv_write_count <= conv_write_count + 1;
		conv_ram_addr <= conv_ram_addr + 1;
	end
        WRITE_SEQ_DENSE: begin
		wren0 <= 0;
		wren1 <= 0;
		wren2 <= 0;
		wren3 <= 0;
		wren_conv <= 0;
		wren_dense <= 1;
		dense_write_count <= dense_write_count + 1;
		dense_ram_addr <= dense_ram_addr + 1;
	end
	// TODO Two additional states for wrting during calculation
	default: begin
		wren0 <= 0;
		wren1 <= 0;
		wren2 <= 0;
		wren3 <= 0;
		wren_conv <= 0;
		wren_dense <= 0;
	end
    endcase  
  end


// READ
always_ff @(posedge clk) begin
  if (reset) begin
    read1 <= 8'b0;
    read2 <= 8'b0;
    read3 <= 8'b0;
    read4 <= 8'b0;
  end else if (state == READ) begin

  end
end

endmodule



