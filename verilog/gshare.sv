`define BHR_SIZE 6
`define PHT_SIZE 64
`define PHT_WIDTH 2

module gshare (
                    input clock,
                    input reset,

                    //inputs from the If stage
                    input [`WIDTH-1:0][31:0]PC,
                    input [`WIDTH-1:0]is_jump,
                    input [`WIDTH-1:0]is_branch,

                    //inputs from Execute stage
                    input [`WIDTH-1:0][31:0] EX_PC,
                    input [`WIDTH-1:0]take_branch,

                    //inputs from the BTB
                    input [`WIDTH-1:0]mismatch,
                    
                    //prediction
                    output logic prediction  
                    
);

typedef struct packed{
                    logic [5:0] GHR;
                    logic [31:0] PC_i;
                    //logic [2:0] t;
} GBHR;

logic [5:0] history, n_history;      
logic [5:0] xorgate, xorgate2;
logic [63 : 0][1:0] pht, npht;
GBHR [5:0] g_obj;
logic [63 : 0] append, nappend;
logic [2:0] tail, n_tail;
logic y;
logic [1:0]f;
always_ff @(posedge clock)begin
    if(reset)begin
        for (int j = 0; j< `BHR_SIZE ; j++)begin
            g_obj[j].GHR <= 0;
            g_obj[j].PC_i  <= 0;
        end 
        history <= 6'b111111;
       tail <= 0;
       f<=0;
        for (int k = 0; k< `PHT_SIZE ; k++)begin
            pht [k] <= 2'b11;
            append [k] <= 1;
        end 
        
    end 

    else begin
       // tail <= n_tail;

        for(int i=0; i<`WIDTH; i++)begin
            if(is_branch[i] || is_jump [i])begin
                if(y==0) begin
                    
                    xorgate <= PC [i][5:0] ^ history;
                    history <= {PC [i][5:0] ^ history , history [5:1]};
                    g_obj[tail + i + f].GHR <= history;
                    g_obj[tail + i + f].PC_i <= PC[i];

                end 
                else begin
                    xorgate <= PC [i][5:0] ^ n_history;
                    history <= {append[xorgate], n_history [5:1]};
                    g_obj[tail].GHR <= n_history;
                    g_obj[tail].PC_i <= PC[i];
                end
                
                if(tail == 0) begin 
                    tail <= 1;
                    f <= 1;
                end 
                else if(tail == 1) begin
                    tail <= 2;
                    f <= 2 ;
                end 
                else if(tail == 2)begin
                    tail <= 0;
                    f<=0;
                    
                end 
               


                
            end 
        end 


        
    end 
//end 
     



    for(int z =0; z< `WIDTH; z++)begin
        for(int b = 0; b< `BHR_SIZE ; b++)begin
            if(EX_PC[z] == g_obj[b].PC_i)begin
                xorgate2 <= EX_PC[z] ^ g_obj[b].PC_i;
                case (pht[xorgate2])
                    2'b11: begin 
                                if(!take_branch[z])begin
                                    pht[xorgate2] <= 2'b10; //taken 
                                    append [xorgate2] <= 0;
                                end
                            end  
                    2'b10: begin 
                                if(!take_branch[z])begin
                                    pht[xorgate2] <= 2'b01; //not taken
                                    append [xorgate2] <= 0;
                                end
                                else begin
                                    pht[xorgate2] <= 2'b11;
                                    append [xorgate2] <= 1;
                                end  //strongly taken
                            end  
                    2'b01: begin 
                                if(!take_branch[z])begin
                                    pht[xorgate2] <= 2'b00; //strongly not taken
                                    append [xorgate2] <= 0;
                                end
                                else begin
                                    pht[xorgate2] <= 2'b10; //taken
                                    append [xorgate2] <= 1;
                                end
                            end 
                    2'b00: begin
                                if(take_branch[z])begin
                                   pht[xorgate2] <= 2'b01;
                                   append [xorgate2] <= 0;
                                end 
                            end 
                endcase 
            end 
        end 
    end 
end 

always_comb begin

    for (int l =0; l<`WIDTH ; l++)begin
        if(mismatch [l])begin
            for(int p = 0; p<6; p++) begin
                if(g_obj[p].PC_i == EX_PC [l])begin
                    n_history = g_obj[p].GHR;
                    y = 1;
                end
                else begin
                    y = 0;
                end 
            end
        end 
        else begin
            y =0 ;
        end 
    end
 
    
  

     
end 

endmodule 



                        
    


             

                



