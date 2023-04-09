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
logic [14:0] read_count;
logic [7:0] image_count;

logic [13:0] ram_addr_1, ram_addr_2, ram_addr_3, ram_addr_0;
logic [15:0] conv_ram_addr, dense_ram_addr;

logic wren1,wren2,wren3,wren0,wren_conv, wren_dense;

enum logic [2:0] {IDLE, WRITE, READ} state_t;
state_t state, next_state;

enum logic [1:0] {WRITE_FOUR, WRITE_SEQ} write_state_t;
write_state_t write_state, next_write_state;

image_ram ram0 (.address(ram_addr_0), .clock(clk), .data(data0), .wren(wren0), .q(read0));//address[13:0]
image_ram ram1 (.address(ram_addr_1), .clock(clk), .data(data1), .wren(wren1), .q(read1));
image_ram ram2 (.address(ram_addr_2), .clock(clk), .data(data2), .wren(wren2), .q(read2));
image_ram ram3 (.address(ram_addr_3), .clock(clk), .data(data3), .wren(wren3), .q(read3));
conv_ram conv_ram0 (.address(conv_ram_addr), .clock(clk), .data(data4), .wren(wren_conv), .q(read4));//address [15:0]
dense_ram dense_ram0 (.address(dense_ram_addr), .clock(clk), .data(data5), .wren(wren_dense), .q(read5));

always_ff @(posedge clk) begin
   state <= next_state;
   write_state <= next_write_state;
end

always_comb begin
  next_state = state;
  next_write_state = write_state;

  if (reset) begin
     next_state = IDLE;
     next_write_state = WRITE_FOUR;
  end else 
     case (state)
     IDLE: if (chipselect && write) next_state = WRITE;
     WRITE: begin 
               if (&read_count) next_state = READ; // TODO must change
               else if (image_count == 8'd196) next_write_state = WRITE_SEQ; // TODO WRITE_SEQ need also switch back to WRITE_FOUR
            end
     READ: if(&ram_addr_1 & (&ram_addr_2) & (&ram_addr_3) & (&ram_addr_4)) next_state = IDLE; // TODO
     default: begin
                next_state = IDLE;
                write_next_state = WRITE_FOUR;
              end
     endcase
  end


end

// WRITE
always_ff @(posedge clk) begin
  if (reset) begin
    count <= 15'b0;
    image_count <= 8'b0;
    data1 <= 8'b0;
    data2 <= 8'b0;
    data3 <= 8'b0;
    data4 <= 8'b0;
  end else if (state == WRITE) begin
    data1 <= writedata[31:24];
    data2 <= writedata[23:16];
    data3 <= writedata[15:8];
    data4 <= writedata[7:0];
    count <= count + 1;
    if (write_state == WRITE_FOUR) image_count = image_count + 1;
    else if (write_state  == WRITE_SEQ) ; // TODO some condition change 
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



