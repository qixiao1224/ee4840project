module FSM_OUT (
    input clk,
    input reset,
    input enable,
    input EN_ReLU,
    output SHIFT_OUT,
    output EN_PISO_OUT,
    output OUT_DONE,
    output WR_EN
);
    reg [3:0] current_state,next_state;
    parameter OUT_IDLE=4'b0000, OUT_S1=4'b0001, OUT_S2=4'b0010, OUT_S3=4'b0011, OUT_S4=4'b0100, OUT_S5=4'b0101;
    parameter OUT_S6=4'b0110, OUT_S7=4'b0111, OUT_S8=4'b1000, OUT_S9=4'b1001;

//combinational state transtion definition
    always @(*) begin
        case (current_state)
            OUT_IDLE:  if (EN_ReLU) next_state=OUT_S1;
                       else          next_state=OUT_IDLE;

            OUT_S1:    next_state=OUT_S2;
            OUT_S2:    next_state=OUT_S3;
            OUT_S3:    next_state=OUT_S4;
            OUT_S4:    next_state=OUT_S5;
            OUT_S5:    next_state=OUT_S6;
            OUT_S6:    next_state=OUT_S7;
            OUT_S7:    next_state=OUT_S8;
            OUT_S8:    next_state=OUT_S9;
            OUT_S9:    next_state=OUT_IDLE;

            default:   next_state=OUT_IDLE;
        endcase
    end

//sequential state change
    always @(posedge clk) begin
        if (reset) current_state<=OUT_IDLE;
        else if (enable) current_state<=next_state;
    end

//Moore machine, output only relevant to current state
    assign SHIFT_OUT= (current_state != OUT_S1);
    assign EN_PISO_OUT= (current_state != OUT_IDLE) && (current_state != OUT_S9);
    assign OUT_DONE= (current_state==OUT_S9);
    assign WR_EN = (current_state != OUT_IDLE) && (current_state != OUT_S1);


endmodule