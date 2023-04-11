module FSM_ACC (
    input clk,
    input reset,
    input enable,
    input CTR_OUT,
    input EN_FSM,
    input OUT_DONE,
    output EN_BUF_IN,
    output CLR_BUF_IN,
    output EN_MAC,
    output RST_MAC,      //act as both the reset signal for MAC1 and downcount counter
    output EN_ReLU,     
    output CLR_PISO_OUT 
);

    reg [2:0] current_state,next_state;
    reg ACC_Flag; // flag signal that is only used inside the FSM, indicting the FSM has gone through ACC state
    parameter IDLE=3'b000, BIAS=3'b001, ACC=3'b011, LAST=3'b111, WAIT=3'b110;

//combinational state transtion definition
    always @(*) begin
        case (current_state)
            IDLE: if (EN_FSM) next_state=BIAS;
                  else        next_state=IDLE;

            BIAS: next_state=ACC;

            ACC: if (~CTR_OUT) next_state=ACC;
                 else begin
                    if (EN_FSM) next_state=BIAS;
                    else        next_state=LAST;
                 end

            LAST: next_state=WAIT;

            WAIT: if (~OUT_DONE) next_state=WAIT;
                  else next_state=IDLE;

            default: next_state=IDLE;
        endcase
    end

//sequential state change
    always @(posedge clk) begin
        if (reset) begin
            current_state<=IDLE;
            ACC_Flag<=0;
        end

        else if (enable) begin
            current_state<=next_state;
            if (current_state==IDLE) ACC_Flag<=0;   //clear the acc flag if reset
            if (current_state==ACC)  ACC_Flag<=1;   //set the acc flag if gone through ACC state
        end

    end

//Moore machine, output only relevant to current state
    assign EN_BUF_IN = (current_state==ACC);
    assign CLR_BUF_IN = (current_state==IDLE) || (current_state==BIAS);
    assign EN_MAC = (current_state!=WAIT) && (current_state!=IDLE);
    assign RST_MAC = (current_state==BIAS);
    assign CLR_PISO_OUT = (current_state==IDLE);
    assign EN_ReLU = ((current_state==BIAS) && ACC_Flag ) || (current_state==LAST);


endmodule