`timescale 1ns/100ps
module ss_RRAT( 
    input reset,
    input clock,

    //input from retire stage
    input logic [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] retire_dest,
    input logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] P_value,
    input logic [`WIDTH-1:0] retire_en,
    input logic [$clog2(`RF_SIZE)-1:0] store_rs2,

    //output to the PRF
    output logic [$clog2(`PRF_SIZE)-1:0] store_rs2_tag,
    //output to freelist
    output logic [`RR_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] rrat_table

);

    logic [`RR_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] map_memory; //PR Memory map
    logic [$clog2(`PRF_SIZE)-1:0] rs2_tag;

    assign rs2_tag = map_memory[store_rs2];


    //bypassing logic for the retiring register upon the rollback signal
    always_comb begin
        store_rs2_tag = rs2_tag;
        rrat_table = map_memory;
        for(int h=0; h<`WIDTH; h++) begin
            if(retire_en[h])
                rrat_table[retire_dest[h]] =   P_value[h];
        end

        /*for(int h=0; h<`WIDTH; h++) begin
            if(retire_en[h]) begin
                if(store_rs2 == retire_dest)
                    store_rs2_tag= P_value[h]; 
            end
        end*/
    end

    always_ff @(posedge clock) begin
        if(reset) begin
            for(int i=0;i<`RR_SIZE;i=i+1) begin
                map_memory[i] <=  i;
            end  
        end
        else begin
            for(int h=0; h<`WIDTH; h++) begin
                if(retire_en[h])
                    map_memory[retire_dest[h]] <=   P_value[h];
            end
        end
    end

endmodule 




