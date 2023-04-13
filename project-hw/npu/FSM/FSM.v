module FSM (
    input [7:0] DB,
    input [7:0] DD,
    input clk,
    input reset,                //reset signal that will reset FSM_ACC, FSM_OUT, down_counter
    input enable,
    input EN_FSM,
    output EN_BUF_IN,
    output CLR_BUF_IN,
    output EN_MAC,
    output RST_MAC,
    output EN_ReLU,
    output CLR_PISO_OUT,
    output SHIFT_OUT,
    output EN_PISO_OUT,
    output WR_EN,
/////////////////////////////////////
//the following ports are for debugging
    output CTR_OUT,
    output OUT_DONE
);

    down_counter down_counter1(
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .CTR_IN({DB,DD}),
        .RST_CTR(RST_MAC),
        .CTR_OUT(CTR_OUT)
    );

    FSM_ACC FSM_ACC1(
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .EN_FSM(EN_FSM),
        .CTR_OUT(CTR_OUT),
        .OUT_DONE(OUT_DONE),
        .EN_BUF_IN(EN_BUF_IN),
        .CLR_BUF_IN(CLR_BUF_IN),
        .EN_MAC(EN_MAC),
        .RST_MAC(RST_MAC),
        .EN_ReLU(EN_ReLU),
        .CLR_PISO_OUT(CLR_PISO_OUT) 
    ); 

    FSM_OUT FSM_OUT1(
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .EN_ReLU(EN_ReLU),
        .SHIFT_OUT(SHIFT_OUT),
        .EN_PISO_OUT(EN_PISO_OUT),
        .OUT_DONE(OUT_DONE),
        .WR_EN(WR_EN)
    );
    
endmodule


 module down_counter #(
    parameter n=16
 ) (
    input clk,
    input reset,                            //reset signal for resetting everything to initial state
    input enable,
    input [n-1:0] CTR_IN,                   //input value for resetting the coutner
    input RST_CTR,                          //enable signal for resetting for initial value for counting down
    output reg CTR_OUT                      //will be high for one cycle if finish counting
 );

    reg [n-1:0] current_value;
    reg run_flag;

    always @(posedge clk) begin
        if (reset) begin
            current_value<=0;
            run_flag<=0;
            CTR_OUT<=0;
        end

        else if (enable)begin
            if (RST_CTR) begin
                current_value<=CTR_IN;
                run_flag<=1;            //must be manually reset for the next countdown
            end
            else begin
                if (run_flag)begin
                    current_value <= current_value-1;
                    if (current_value==1)begin
                        CTR_OUT<=1;                     //set CTR_OUT high for one clock cycle
                        run_flag<=0;
                    end
                end
                else CTR_OUT<=0;
            end
        end

    end
    
 endmodule