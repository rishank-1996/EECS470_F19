module bimod_pred(
    input clock,
    input reset,

    //input from the BTB
    input logic taken,
    input logic enable,

    //output to the BTB
    output STATE state,

    //output to the fetch stage
    output logic prediction
);

    logic next_prediction;
    STATE n_state;

    assign next_prediction = (state==STR_T || state==WEA_T) ? 1'b1 : 1'b0;

    always_comb begin
        n_state = state;
        case(state)
            STR_T: begin
                n_state =(taken) ? STR_T : WEA_T;
            end
            WEA_T: begin
                n_state = ( taken) ? STR_T : WEA_NT;
            end
            WEA_NT: begin
                n_state = ( taken) ? WEA_T : STR_NT;
            end
            STR_NT: begin
                n_state = ( taken) ? WEA_NT : STR_NT;
            end
        endcase
    end

    always_ff@(posedge clock) begin
        if(reset) begin
            state       <= STR_T;
            prediction  <= 1;
        end
        else begin
            if(enable) begin
                state       <= n_state;
                prediction  <= next_prediction;
            end
        end
    end
endmodule