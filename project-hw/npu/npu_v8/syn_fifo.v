/*
register-based synchronous fifo design
*/

module syn_fifo #(
    parameter WIDTH= 8,
    parameter DEPTH = 4
) (
    input clk,
    input rst,
    
    input enable,               //enable signal with highest priority
    input wr_en,                //write enable signal
    input rd_en,                //read enable signal
    input [WIDTH-1:0] data_in,  //data input port

    output reg [WIDTH-1:0] data_out,    //data output port
    output reg full,            //signal indicating the fifo is full
    output reg empty            //signal indicating the fifo is empty
);

    localparam DEPTH_log2 = $clog2(DEPTH);

    wire [WIDTH-1:0] head;                   //the head of fifo (next output data)
    reg [DEPTH_log2-1:0] write_ptr;          //write pointer
    reg [DEPTH_log2-1:0] read_ptr;           //read pointer
    reg [WIDTH-1:0] fifo_data [DEPTH-1:0];   //registers to store fifo data
    reg [DEPTH_log2:0] number_of_data;       //current number of data stored in the fifo

    assign head = fifo_data[read_ptr];

//read pointer operation
    always @(posedge clk) begin
        if (rst)begin
            read_ptr<=0; 
        end
        else if (rd_en && enable) begin
            data_out<=head;
            read_ptr<=read_ptr+1'b1;
        end
    end

//write pointer opeartion
    always @(posedge clk) begin
        if (rst)begin
            write_ptr<=0;
        end
        else if (wr_en && enable)begin
            fifo_data[write_ptr]<=data_in;
            write_ptr<=write_ptr+1'b1;
        end
    end

//full and empty signal generation
    always @(posedge clk) begin
        if (rst)begin
            number_of_data<=0;
            empty<=1'b1;
            full<=0;
        end

        else if (wr_en && ~rd_en && enable) begin             //if writing a data but not reading
            number_of_data<=number_of_data+1'b1;
            empty<=0;                               //impossible to be empty
            full<=(number_of_data == DEPTH-1);      //insert full signal if number_of_data reached depth-1
        end

        else if (~wr_en && rd_en && enable) begin             //if reading a data but not writing
            number_of_data<=number_of_data-1'b1;
            full<=0;                               //impossible to be full
            empty<=(number_of_data == 1);          //insert empty signal is number of data reached 1
        end

        /*
            in the other two situations, when ~wr_en && ~rd_en OR wr_en && rd_en, number of data, full, empty all remain
            unchanged, thus not specified
        */
    end
    
endmodule