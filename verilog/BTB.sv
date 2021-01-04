//`define BTB_SIZE 32
module BTB(
            input clock,
            input reset,
            //input from predictor
            input STATE curr_state,

            //input from IF stage
            input logic [`WIDTH-1:0][31:0] PC,
            input [`WIDTH-1:0]    is_branch,
            input [`WIDTH-1:0]    is_jump,

            //input from Execute
            input logic [`WIDTH-1:0] [31:0] EX_TARGET,
            input logic [`WIDTH-1:0] [31:0] EX_PC,
            input logic [`WIDTH-1:0] [5:0] EX_tag,
            input [`WIDTH-1:0]    take_branch, 

            //input from ROB
            input logic rollback,
            input logic [`XLEN-1:0] rollback_PC,
            input logic [`XLEN-1:0] ROLLBACK_TARGET,

            //Output to the IF stage
            output logic [`WIDTH-1:0][31:0] T_PC,
            output logic [`WIDTH-1:0] hit,

            //output to ROB
            output [`WIDTH-1:0][5:0] ROB_tag,

            /////Rollback variable
           output logic [`WIDTH-1:0] mismatch

);

logic [1:0] combined;
assign ROB_tag = EX_tag;
logic [$clog2(`BTB_SIZE)-1:0]head;
BTB_entry [`BTB_SIZE - 1:0] buf_obj;

assign combined = is_branch|is_jump;

always_comb begin
    T_PC    = 0;
    for(int k =0; k< `WIDTH; k++)begin
        for(int i = 0;i < `BTB_SIZE; i++) begin
            if(is_branch[k] || is_jump[k])begin
                if(PC[k] == buf_obj[i].PC)begin
                    T_PC[k] = buf_obj[i].NPC;
                    hit[k] = 1;
                    break;
                end
                else begin
                    T_PC[k]= {PC[k][31:3],3'b000} + 8;
                    hit[k] = 0;
                end 
            end
            else begin
                hit[k] = 0;
            end 
        end    //////////////Check if inst PC exists
    end
end //end of always

    always_comb begin
        mismatch = 0;
        for(int w =0; w<`WIDTH; w++)begin
            if(take_branch[w])begin 
                for(int k = 0;k<`BTB_SIZE ;k++)begin
                    if(buf_obj[k].PC == EX_PC[w])begin
                        if(buf_obj[k].NPC != EX_TARGET[w] || EX_TARGET[w] == ({EX_PC[w][31:3],3'b000} + 8))begin      ///Write only if NPCs are not equal
                            mismatch[w] = 1;
                            break;                     ///Trigger mismatch  
                        end
                        else begin
                            mismatch[w] = 0;
                        end
                    end
                end
            end  //////checking and writing from Execute 
        end 
    end 

    always_ff @(posedge clock) begin
        if(reset)begin
            head     <=  0;
            buf_obj  <= '0;
        end 
        else begin
            // for(int h = 0; h<`WIDTH ; h++)begin    
            //     if(hit[h] == 0 && (is_branch[h] || is_jump[h]))begin
            //         buf_obj[head].PC  <= PC[h];
            //         buf_obj[head].NPC <= {PC[h][31:3],3'b000} + 8;
            //         head <= head+1;
            //     end////Writing from IF stage if does not exist
            // end

            case(combined)
                2'b00: begin
                end
                2'b01: begin
                    case(hit)
                        2'b00: begin
                            buf_obj[head].PC  <= PC[0];
                            buf_obj[head].NPC <= {PC[0][31:3],3'b000} + 8;
                            head <= head+1;
                        end
                        default: begin
                        end
                    endcase
                end
                2'b10: begin
                    case(hit)
                        2'b00: begin
                            buf_obj[head].PC  <= PC[1];
                            buf_obj[head].NPC <= {PC[1][31:3],3'b000} + 8;
                            head <= head+1;
                        end
                        default: begin
                        end
                    endcase
                end
                2'b11: begin
                    case(hit)
                        2'b00: begin
                            buf_obj[head].PC  <= PC[0];
                            buf_obj[head].NPC <= {PC[0][31:3],3'b000} + 8;
                            if(head==31) begin
                                buf_obj[0].PC  <= PC[1];
                                buf_obj[0].NPC <= {PC[1][31:3],3'b000} + 8;
                            end 
                            else begin
                                buf_obj[head+1].PC  <= PC[1];
                                buf_obj[head+1].NPC <= {PC[1][31:3],3'b000} + 8;
                            end
                            head <= head+2;
                        end
                        2'b10: begin
                            buf_obj[head].PC  <=  PC[0];
                            buf_obj[head].NPC <= {PC[0][31:3],3'b000} + 8;
                            head <= head+1;                            
                        end
                        2'b01: begin
                            buf_obj[head].PC  <=  PC[1];
                            buf_obj[head].NPC <= {PC[1][31:3],3'b000} + 8;
                            head <= head+1;
                        end
                        2'b11: begin
                        end
                    endcase
                end
            endcase

            if(rollback) begin
                for(int k = 0;k<`BTB_SIZE ;k++) begin
                    if(buf_obj[k].PC == rollback_PC) begin
                        if(curr_state == WEA_T || curr_state == WEA_NT) begin      
                            buf_obj[k].NPC <= ROLLBACK_TARGET;
                            break;                    
                        end
                        else begin
                        end
                    end
                end
            end
            /*for(int w =0; w<`WIDTH; w++) begin
                if(take_branch[w]) begin 
                    for(int k = 0;k<`BTB_SIZE ;k++) begin
                        if(buf_obj[k].PC == EX_PC[w]) begin
                            if(buf_obj[k].NPC != EX_TARGET[w] && 
                                        (curr_state == WEA_T || curr_state == WEA_NT) ) begin      
                                buf_obj[k].NPC <= EX_TARGET[w];
                                break;                    
                            end
                            else begin
                            end
                        end
                    end
                end  //////checking and writing from Execute 
            end*/ 
        end
    end

endmodule 



  




