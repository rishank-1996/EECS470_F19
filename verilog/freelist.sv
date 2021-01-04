`timescale 1ns/100ps
//parameter `FL_SIZE = 32;

module ss_freelist(
    input clock,
    input reset,

    //input from ROB upon rewind
    input logic rollback_en,
    input logic [$clog2(`ROB_SIZE)-1:0] rewind_head,

    //input indicating if SH on dispatch (only reason not to send out free_reg!) 
    input logic [`WIDTH-1 :0] dispatch_en,    //asserted on SH

    //inputs from retire
    input logic [`WIDTH-1 :0] retire_en,  //connected to inst_retire from retire
    input logic  [`WIDTH-1 :0] [$clog2(`PRF_SIZE)-1:0] retire_reg, //connected to pregold from retire

    //output to dispatch (ROB, RS and Maptable(RAT))
    output logic  [`WIDTH-1 :0] [$clog2(`PRF_SIZE)-1:0] free_reg
);
 
    logic [`FL_SIZE-1 :0] [$clog2(`PRF_SIZE)-1:0] freeregisters, n_fl;
    logic [$clog2(`FL_SIZE)-1:0]  head, tail;
    logic [$clog2(`FL_SIZE)-1:0]  next_head, next_tail; 
    
    
    always_comb begin
        free_reg    =   0;
        n_fl        = freeregisters;
        next_head   = head;
        next_tail   = tail;
        case(`WIDTH) 
            1:  begin
                casez(dispatch_en) 
                    1'b0: begin         //not requiring a free_reg
                    end
                    1'b1: begin         //requiring one free_reg
                        free_reg  = freeregisters[head];
                        next_head = head + 1;
                    end
                endcase
                casez(retire_en) 
                    1'b0: begin         //not requiring a free_reg
                    end
                    1'b1: begin         //requiring one free_reg
                        n_fl[tail] = retire_reg;
                        next_tail = tail + 1;
                    end
                endcase
            end

            2:  begin
                casez(dispatch_en)        
                    2'b00:  begin  //require no free_reg
                    end
            
                    2'b01:  begin  //require one free_reg
                        free_reg[0] = freeregisters[head];
                        free_reg[1] = `ZERO_PREG;
                        next_head   = head + 1;
                    end

                    2'b10:  begin  //require one free_reg
                        free_reg[1] = freeregisters[head];
                        free_reg[0] = `ZERO_PREG;
                        next_head   = head + 1;
                    end
            
                    2'b11:  begin  //require two free_reg
                        free_reg[0] = freeregisters[head];
                        free_reg[1] = freeregisters[head+1];
                        if(head==`FL_SIZE-1)
                            free_reg[1] = freeregisters[0];
                        next_head   = head + 2;
                    end
                endcase

                casez(retire_en)        
                    2'b00:  begin  //getting no free_reg
                    end
            
                    2'b01:  begin  //getting one free_reg
                            n_fl[tail]  = retire_reg[0];
                            next_tail   = tail + 1;
                    end

                    2'b10:  begin  //getting one free_reg
                        n_fl[tail]  = retire_reg[1];
                        next_tail   = tail + 1;
                    end
            
                    2'b11:  begin  //getting two free_reg
                        n_fl[tail]  = retire_reg[0];
                        n_fl[tail+1]  = retire_reg[1];
                        if(tail==`FL_SIZE-1)
                            n_fl[0]  = retire_reg[1];
                        next_tail   = tail + 2;
                    
                    end
                endcase
            end 
        endcase
    end


    always_ff@(posedge clock) begin
        if(reset) begin
            for(int i=0; i<`FL_SIZE; i++) begin
                freeregisters[i] <=  (i+`FL_SIZE);
            end
            head <=  0;   //top of freelist
            tail <=  0;   //bottom of freelist
        end
        else begin
            head            <=  (rollback_en)? rewind_head + 1 : next_head;  //inc or dec head pointer
            tail            <=  next_tail;
            freeregisters   <=  n_fl;
        end
    end

endmodule
//should never be a shortage of free reg since max entries in rob is 32

