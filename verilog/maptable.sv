`timescale 1ns/100ps
//parameter `MT_SIZE = 32;
//parameter `PRF_SIZE = 64;

module ss_maptable ( 

    input reset,
    input clock,

    //input from ROB
    input logic [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] dest_rob,
    input logic rollback_en,

    //inputs coming from RS (two input reg addresses)
    input logic [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] regA,
    input logic [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] regB,
 
    //Input from Id stage
    input logic [`WIDTH-1:0] dispatch_en,
    
    //Input from CDB
    input CDB [`WIDTH-1:0] cdb ,  

    //Input from Free List
    input logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] free_register,

    //inputs from RRAT
    input logic [`RR_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] rrat_table,

    //Output to ROB
    output logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] prev_T,
    
    //Output to RS
    output logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] PA,
    output logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] PB,
    output logic [`WIDTH-1:0] PA_ready,
    output logic [`WIDTH-1:0] PB_ready
);

    logic [`MT_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] rmap_memory; //PR Memory map
    logic [`PRF_SIZE-1:0] plus_memory;
    logic [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] destination;


    always_comb begin
        destination      = 0;
        PA               = 0;
        PB               = 0;
        PA_ready         = 0;
        PB_ready         = 0;
        prev_T           = 0;
        for(int w=0; w<`WIDTH; w++) begin   
            prev_T[w]       = rmap_memory[dest_rob[w]];
            if(dispatch_en[w-1] && w==1 && dest_rob[w] == dest_rob[w-1]) begin
                prev_T[w] = free_register[w-1];  ///most recent change!!!!
            end      
            destination[w]      = dest_rob[w];
            PA[w]               = rmap_memory[regA[w]];
            PB[w]               = rmap_memory[regB[w]];
            PA_ready[w]         = (regA[w] == `ZERO_REG) ?
                                    1'b1 : plus_memory[rmap_memory[regA[w]]];
            PB_ready[w]         = (regB[w] == `ZERO_REG) ?
                                    1'b1 : plus_memory[rmap_memory[regB[w]]];
        end
   
        for(int p=0; p<`WIDTH; p++) begin
            for(int c=0; c<`WIDTH; c++) begin
                if(PA[p] == cdb[c].PR && cdb[c].completed) begin
                    PA_ready[p] = 1'b1;
                end
		        if(PB[p] == cdb[c].PR && cdb[c].completed) begin
                    PB_ready[p] = 1'b1;
                end
            end
        end
    end


    always_ff @(posedge clock) begin
        if(reset)begin
            for(int i=0;i<`MT_SIZE;i=i+1) begin
                rmap_memory[i] <=  i;
                plus_memory[i] <=  1'b1;
                plus_memory[i+32] <=  1'b1;
            end  
        end
        else begin
            if(!rollback_en) begin
                for(int h=0; h<`WIDTH; h++) begin
                    if(dispatch_en[h])begin
                        rmap_memory[destination[h]]     <=   free_register[h];
                        plus_memory[free_register[h]]   <=   1'b0;
                    end
                end
                
                for(int q=0; q<`WIDTH;q++) begin
                    if(cdb[q].completed)begin
                        plus_memory[cdb[q].PR]  <=  cdb[q].completed;
                    end
                end
            end
            else begin
                for(int k=0; k<`MT_SIZE; k++) begin
                    rmap_memory[k]  <=  rrat_table[k];
                    plus_memory[k]  <=  1'b1;
                    plus_memory[k+32]  <=  1'b1;
                end
            end
        end
    end

endmodule 




