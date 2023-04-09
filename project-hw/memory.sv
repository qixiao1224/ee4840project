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

logic [7:0] data1, data2, data3, data4;
logic [14:0] count;

logic [13:0] ram_addr_1, ram_addr_2, ram_addr_3, ram_addr_4;
logic [15:0] ram_fc_addr_1;

logic wren1,wren2,wren3,wren4,wren_fc;

enum logic [2:0] {IDLE, WRITE, READ} state_t;
state_t state, next_state;

sp_ram sp_ram1 (.address(ram_addr_1), .clock(clk), .data(data1), .wren(wren1), .q(read1));//address[13:0]
sp_ram sp_ram2 (.address(ram_addr_2), .clock(clk), .data(data2), .wren(wren2), .q(read2));
sp_ram sp_ram3 (.address(ram_addr_3), .clock(clk), .data(data3), .wren(wren3), .q(read3));
sp_ram sp_ram4 (.address(ram_addr_4), .clock(clk), .data(data4), .wren(wren4), .q(read4));
sp_ram_fc sp_ram_fc1  (.address(ram_fc_addr_1), .clock(clk), .data(data4), .wren(wren_fc), .q(read4));//address [15:0]

always_ff @(posedge clk) begin
   state <= next_state;
end

always_comb begin
  next_state = state;
  if (reset) begin
     next_state = IDLE;
  end case (state)
     IDLE: if (chipselect && write) next_state = WRITE;
     WRITE: if (&count) next_state = READ; // TODO may change
     READ: if(&ram_addr_1 & (&ram_addr_2) & (&ram_addr_3) & (&ram_addr_4)) next_state = IDLE; // TODO
     default: next_state = IDLE;
     endcase
  end


end

// WRITE
always_ff @(posedge clk) begin
  if (reset) begin
    count <= 15'b0;
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



