`timescale 1ns/100ps

module ss_issue(
    input clock,  
    input reset,

    //input from ROB
    input logic rollback_en,
    
    //Input from the RS
    input RS_OBJ [`WIDTH-1:0]issue_packet,
    
    //input from execute
    input logic ld_in_ex,
    input logic data_input,
    //input logic load_stall,

    //inputs from the Execute stage
    input logic [`WIDTH-1:0]stall_ALU,


    //Output to the EX stage 
    output logic [`WIDTH-1 : 0]FU_unit_ALU, //Which Functional Unit does the Instruction require
    output logic [`WIDTH-1 : 0]FU_unit_mul,
    output RS_OBJ [`WIDTH-1: 0]ex_packet, //The Packet containing the Instruction to be executed

    //Output to the RS
    output logic [`WIDTH - 1 :0]delete_confirm 
    );

    logic [`WIDTH-1:0]a,b,c;

    always_comb begin
        case (`WIDTH) 
            1:  begin
                    casez (issue_packet[0].packet.alu_func)
                        ALU_ADD,  ALU_SUB  , ALU_AND , 
                        ALU_SLT,  ALU_SLTU , ALU_OR  , 
                        ALU_XOR,  ALU_SRL  , ALU_SLL , 
                        ALU_SRA: begin                         
                                    a = 1;
                                    b = 0;
                                    c = 0;
                                end

                        ALU_MUL , ALU_MULH , ALU_MULHSU, 
                        ALU_MULHU: begin
                                    b = 1;
                                    a = 0;
                                    c = 0;
                                end
                        default: begin
                                    c = 1;                   
                                end
                    endcase 
                end 
            2:  begin
                    casez(issue_packet[0].packet.alu_func)
                        ALU_ADD,  ALU_SUB  , ALU_AND , 
                        ALU_SLT,  ALU_SLTU , ALU_OR  , 
                        ALU_XOR,  ALU_SRL  , ALU_SLL , 
                        ALU_SRA                                 : begin
                                                                    a[0] = 1;
                                                                    b[0] = 0;
                                                                    c[0] = 0;
                                                                end
                        ALU_MUL , ALU_MULH , ALU_MULHSU, 
                        ALU_MULHU                               : begin
                                                                    b[0] = 1;
                                                                    a[0] = 0;
                                                                    c[0] = 0;
                                                                end

                        default                                 : begin
                                                                    c[0] = 1;
                                                                    a[0] = 0;
                                                                    b[0] = 0;
                                                                end
                    endcase

                    casez(issue_packet[1].packet.alu_func)
                        ALU_ADD,  ALU_SUB  , ALU_AND , 
                        ALU_SLT,  ALU_SLTU , ALU_OR  , 
                        ALU_XOR,  ALU_SRL  , ALU_SLL , 
                        ALU_SRA                                     : begin
                                                                        a[1] = 1;
                                                                        b[1] = 0;
                                                                        c[1] = 0;
                                                                    end
                        ALU_MUL , ALU_MULH , ALU_MULHSU, 
                        ALU_MULHU                                   : begin
                                                                        b[1] = 1;
                                                                        a[1] = 0;
                                                                        c[1] = 0;
                                                                    end
    
                        default                                 : begin
                                                                        c[1] = 1;
                                                                        a[1] = 0;
                                                                        b[1] = 0;
                                                                    end
                    endcase

                end
            endcase
        end



    
    always_ff @(posedge clock) begin   

        if(reset||rollback_en) begin
                FU_unit_ALU         <= 0; //zero for both widths
		        FU_unit_mul         <= 0; //zero for both widths
                ex_packet           <= 0;
                delete_confirm      <= 1;
            end
        else if(ld_in_ex & !data_input) begin // &!load_stall) begin
            delete_confirm <= 0;
        end
        else begin
                if(`WIDTH == 1) begin
                    if(a == 1)begin
                        if(!stall_ALU) begin
                            ex_packet           <= issue_packet;
                            FU_unit_ALU         <= 1;
                            FU_unit_mul         <= 0;
                            delete_confirm      <= 1;
                        end
                        else begin
                            ex_packet           <= 0;
                            FU_unit_ALU         <= 1;
                            FU_unit_mul         <= 0;
                            delete_confirm      <= 0;   
        
                        end
                    end
                    else if(b == 1)begin
                        ex_packet           <= issue_packet;
                        FU_unit_ALU         <= 0;
                        FU_unit_mul         <= 1;
                        delete_confirm      <= 1;
                    end    
                    else if(c == 1)begin
                        ex_packet           <= issue_packet;
                        FU_unit_ALU         <= 0;
			            FU_unit_mul         <= 0;
                        delete_confirm      <= 1;
            
                    end
                    else begin
                        ex_packet           <= 0;
                        FU_unit_ALU         <= a;
			            FU_unit_mul         <= b;
                        delete_confirm      <= 0;
     
                    end
                end
                
                else begin    //Width  = 2
                    if(a[0] == 1 && a[1] == 1)begin
                        if(stall_ALU == 2'b00) begin
                            ex_packet[`WIDTH-2]                 <=  issue_packet[`WIDTH-2];
                            FU_unit_ALU[`WIDTH-2]               <=  issue_packet[`WIDTH-2].packet.valid;
                            FU_unit_mul[`WIDTH-2]               <=  0;
                            delete_confirm[`WIDTH-2]            <=  issue_packet[`WIDTH-2].packet.valid;
                            ex_packet[`WIDTH-1]                 <=  issue_packet[`WIDTH-1];
                            FU_unit_ALU[`WIDTH-1]               <=  issue_packet[`WIDTH-1].packet.valid;
                            FU_unit_mul[`WIDTH-1]               <=  0;
                            delete_confirm[`WIDTH-1]            <=  issue_packet[`WIDTH-1].packet.valid;
                        end
                        else if (stall_ALU == 2'b10)begin
                            ex_packet[`WIDTH-2]                 <=  issue_packet[`WIDTH-2];
                            FU_unit_ALU[`WIDTH-2]               <=  issue_packet[`WIDTH-2].packet.valid;
                            FU_unit_mul[`WIDTH-2]               <=  0;
                            delete_confirm[`WIDTH-2]            <=  issue_packet[`WIDTH-2].packet.valid;

                            delete_confirm[`WIDTH-1]            <=  0; 
                        end
                        else if (stall_ALU == 2'b01)begin
                            delete_confirm[`WIDTH-2]            <=  0;

                            ex_packet[`WIDTH-1]                 <=  issue_packet[`WIDTH-1];
                            FU_unit_ALU[`WIDTH-1]               <=  issue_packet[`WIDTH-1].packet.valid;
                            FU_unit_mul[`WIDTH-1]               <=  0;
                            delete_confirm[`WIDTH-1]            <=  issue_packet[`WIDTH-1].packet.valid; 
                        end
                        else begin   ////Stall on both units 

                            delete_confirm[`WIDTH-2]            <=  0;

                            delete_confirm[`WIDTH-1]            <=  0;
                        end
                    end 

                    else if(a[0]== 1 && a[1] ==0)begin
                        if(stall_ALU == 2'b00) begin 
                            ex_packet[`WIDTH-2]                 <=  issue_packet[`WIDTH - 2];
                            FU_unit_ALU[`WIDTH-2]               <=  issue_packet[`WIDTH-2].packet.valid;
                            FU_unit_mul[`WIDTH-2]               <=  0;
                            delete_confirm[`WIDTH-2]            <=  issue_packet[`WIDTH-2].packet.valid;
                            ex_packet[`WIDTH-1]                 <=  issue_packet[`WIDTH-1];
                            FU_unit_ALU[`WIDTH-1]               <=  0;
                            FU_unit_mul[`WIDTH-1]               <=  ~c; //c = 1 means not a multiplier operation 
                            delete_confirm[`WIDTH-1]            <=  1;
                        end
                        else if(stall_ALU == 2'b10) begin
                            ex_packet[`WIDTH-2]                 <=  issue_packet[`WIDTH - 2];
                            FU_unit_ALU[`WIDTH-2]               <=  issue_packet[`WIDTH-2].packet.valid;
                            FU_unit_mul[`WIDTH-2]               <=  0;
                            delete_confirm[`WIDTH-2]            <=  issue_packet[`WIDTH-2].packet.valid;
                            
                            delete_confirm[`WIDTH-1]            <=  0;

                        end
                        else if( stall_ALU == 2'b01)begin 
                            delete_confirm[`WIDTH-2]            <=  0;

                            ex_packet[`WIDTH-1]                 <=  issue_packet[`WIDTH-1];
                            FU_unit_ALU[`WIDTH-1]               <=  0;
                            FU_unit_mul[`WIDTH-1]               <=  ~c; //c = 1 means not a multiplier operation 
                            delete_confirm[`WIDTH-1]            <=  1;
                        end
                        else begin
                            delete_confirm[`WIDTH-2]            <=  0;
                            
                            delete_confirm[`WIDTH-1]            <=  0;
                        end
                    end

                    else if(a[0]== 0 && a[1] ==1)begin
                        if(stall_ALU == 2'b00) begin
                            ex_packet[`WIDTH-2]                 <=   issue_packet[`WIDTH - 2];
                            FU_unit_ALU[`WIDTH-2]               <=   0;
                            FU_unit_mul[`WIDTH-2]               <=   ~c;
                            delete_confirm[`WIDTH-2]            <=   1;
                            ex_packet[`WIDTH-1]                 <=   issue_packet[`WIDTH-1];
                            FU_unit_ALU[`WIDTH-1]               <=   issue_packet[`WIDTH-1].packet.valid;
                            FU_unit_mul[`WIDTH-1]               <=   0; 
                            delete_confirm[`WIDTH-1]            <=   issue_packet[`WIDTH-1].packet.valid;
                        end
                        else if(stall_ALU == 2'b01)begin
                            delete_confirm[`WIDTH-1]            <=   0;

                            ex_packet[`WIDTH-1]                 <=   issue_packet[`WIDTH - 2];
                            FU_unit_ALU[`WIDTH-1]               <=   0;
                            FU_unit_mul[`WIDTH-1]               <=   ~c;
                            delete_confirm[`WIDTH-2]            <=   1;

                        end
                        else if ( stall_ALU == 2'b10 ) begin
                            ex_packet[`WIDTH-2]                 <=   issue_packet[`WIDTH - 2];
                            FU_unit_ALU[`WIDTH-2]               <=   0;
                            FU_unit_mul[`WIDTH-2]               <=   ~c;
                            delete_confirm[`WIDTH-2]            <=   1;

                            delete_confirm[`WIDTH-1]            <=   0;
                        end
                        else begin
                            delete_confirm[`WIDTH-2]            <=  0;
 
                            delete_confirm[`WIDTH-1]            <=  0;
                        end
                    end

                    else begin  ///none of the operations require the functionality of the ALU
                        ex_packet[`WIDTH-2]                 <=  issue_packet[`WIDTH - 2];
                        FU_unit_ALU[`WIDTH-2]               <=  0;
                        FU_unit_mul[`WIDTH-2]               <=  ~c;
                        delete_confirm[`WIDTH-2]            <=  issue_packet[`WIDTH-2].packet.valid & !stall_ALU[`WIDTH-2];
                        ex_packet[`WIDTH-1]                 <=  issue_packet[`WIDTH-1];
                        FU_unit_ALU[`WIDTH-1]               <=  0;
                        FU_unit_mul[`WIDTH-1]               <=  ~c; 
                        delete_confirm[`WIDTH-1]            <=  issue_packet[`WIDTH-1].packet.valid & !stall_ALU[`WIDTH-1];
                    end
                end
            end
            //else begin
            //    delete_confirm <= 0;
            //end
        end
endmodule

