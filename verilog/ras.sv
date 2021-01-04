module ras(
    input clock, reset,

    //input from fetch stage
    input IF_ID_PACKET [`WIDTH-1:0] if_packet,
    input logic [`WIDTH-1:0] is_jump,
    
    //input from rob in case of rollback
    input logic rollback_en,

    //output to fetch with return address
    output logic [`WIDTH-1:0] [`XLEN-1:0] return_addr,
    output logic [`WIDTH-1:0] valid_ret_addr
);

RAS_ENTRY [`RAS_SIZE-1:0] ras;
logic [4:0] head;
logic [`WIDTH-1:0] push, pop;
logic [`WIDTH-1:0] [`XLEN-1:0] rpc;
logic [`WIDTH-1:0] link_rd, link_rs1, requal;
logic [`WIDTH-1:0] [1:0] link;
logic entry_done;


always_comb begin
    link_rd = 0;
    link_rs1 = 0;
    requal = 0;
    link = 0;
    for(int j=0; j<`WIDTH; j++) begin
        link_rd[j]  = (if_packet[j].inst.i.rd == 1 | 
                        if_packet[j].inst.i.rd == 5);
        link_rs1[j] = (if_packet[j].inst.i.rs1 == 1 | 
                        if_packet[j].inst.i.rs1 == 5);
        requal[j]   = (if_packet[j].inst.i.rd==if_packet[j].inst.i.rs1);
        link[j]     = { link_rd[j], link_rs1[j] };
    end
end

 always_comb begin
    entry_done = 0;
    pop = 0;
    push = 0;
    rpc   = 0;
    return_addr = 0;
    valid_ret_addr = 0;  
    for(int i=0; i<`WIDTH; i++) begin
        if(is_jump[i]) begin
            casez(if_packet[i].inst)
                `RV32_JAL: begin
                        if(if_packet[i].inst.j.rd == 1 || 
                                if_packet[i].inst.j.rd == 5) begin
                            push[i] = 1;
                            rpc[i]   = if_packet[i].NPC; 
                        end
                        else begin
                            push[i] = 0;
                        end
                    end
                `RV32_JALR: begin
                    case(link[i])
                        2'b00: begin
                            end
                        2'b01: begin
                                pop[i] = 1;
                                return_addr[i] = (entry_done) ? ras[head-2].RPC : ras[head-1].RPC;
                                valid_ret_addr[i] = 1;
                                entry_done = 1;
                            end
                        2'b10: begin
                                push[i] = 1;
                                rpc[i]  = if_packet[i].NPC;
                            end
                        2'b11: begin
                                if(requal[i]) begin
                                    push[i] = 1;
                                    rpc[i]  = if_packet[i].NPC;
                                end
                                else begin
                                    pop[i]  = 1;
                                    push[i] = 1;
                                    rpc[i]  = if_packet[i].NPC;
                                    return_addr[i] = (entry_done) ? ras[head-1].RPC : ras[head].RPC;
                                    valid_ret_addr[i] = 1;
                                    entry_done = 1;
                                end
                            end
                    endcase
                end
                default: begin
                        end
            endcase
        end
    end
 end

 always_ff@(posedge clock) begin
    if(reset) begin
        ras     <= 0;
        head    <= 0;
    end
    else begin
        case(pop)
            2'b00: begin
                    case(push)
                        2'b00: begin
                            end
                        2'b01: begin
                                head <= head + 1;
                                ras[head].PC <= if_packet[0].PC;
                                ras[head].RPC <= if_packet[0].NPC; 
                            end
                        2'b10: begin
                                head <= head + 1;
                                ras[head].PC <= if_packet[1].PC;
                                ras[head].RPC <= if_packet[1].NPC; 
                            end
                        2'b11: begin
                                head <= head + 2;
                                ras[head].PC <= if_packet[0].PC;
                                ras[head].RPC <= if_packet[0].NPC;
                                ras[head+1].PC <= if_packet[1].PC;
                                ras[head+1].RPC <= if_packet[1].NPC;  
                            end
                    endcase
                end
            2'b01,2'b10: begin
                    case(push)
                        2'b00: begin
                                head <= head - 1;
                            end
                        2'b01: begin
                                ras[head-1].PC <= if_packet[0].PC;
                                ras[head-1].RPC <= if_packet[0].NPC; 
                            end
                        2'b10: begin
                                ras[head-1].PC <= if_packet[1].PC;
                                ras[head-1].RPC <= if_packet[1].NPC; 
                            end
                        2'b11: begin
                                head <= head + 1;
                                ras[head-1].PC <= if_packet[0].PC;
                                ras[head-1].RPC <= if_packet[0].NPC;
                                ras[head].PC <= if_packet[1].PC;
                                ras[head].RPC <= if_packet[1].NPC;  
                            end
                    endcase
                end
            2'b11: begin
                    case(push)
                        2'b00: begin
                                head <= head - 2;
                            end
                        2'b01: begin
                                head <= head - 1;
                                ras[head-2].PC <= if_packet[0].PC;
                                ras[head-2].RPC <= if_packet[0].NPC; 
                            end
                        2'b10: begin
                                head <= head - 1;
                                ras[head-2].PC <= if_packet[1].PC;
                                ras[head-2].RPC <= if_packet[1].NPC; 
                            end
                        2'b11: begin
                                ras[head-2].PC <= if_packet[0].PC;
                                ras[head-2].RPC <= if_packet[0].NPC;
                                ras[head-1].PC <= if_packet[1].PC;
                                ras[head-1].RPC <= if_packet[1].NPC;  
                            end
                    endcase
                end
        endcase
    end
 end


endmodule

