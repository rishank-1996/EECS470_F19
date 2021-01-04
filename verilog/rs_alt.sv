`timescale 1ns/100ps

//parameter `RS_SIZE = 16;

module rs ( 
    input reset,
    input clock,

    //input from ROB
    input logic rollback_en,

    input ID_DISP_PACKET[`WIDTH-1:0] id_packet,
    input logic[`WIDTH-1:0] write_true,
    
    //inputs from map table 
    input logic[`WIDTH-1:0] PA_ready,
    input logic[`WIDTH-1:0] PB_ready,
    input logic[`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] PA,
    input logic[`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] PB,

    ///////inputs from lsq////

    input logic [`WIDTH-1:0][5:0] load_issue_PC,
    input logic [`WIDTH-1:0] load_issue_permit,


    //Input from Free List
    input logic[`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0]free_register,

    //input from complete
    input CDB[`WIDTH-1:0] cdb,

    //input from the issue stage
    input logic[`WIDTH-1:0] delete_confirm,

    //input from ex telling load exists
    input logic ld_in_ex,
            
    //outputs to the map table
    output logic[`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] regA,
    output logic[`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] regB,  //both addresses

    //output to the issue stage
    output RS_OBJ[`WIDTH-1:0] issue_packet,

    //////output to lsq/////
    output logic [`WIDTH-1 :0] [5:0] load_PC,
    output logic [`WIDTH-1:0] load_issue,

    //output to the decode stage to inform about a filled table
    output logic [`WIDTH-1:0] full

    );
   
    RS_OBJ [`RS_SIZE-1:0] OBJ, N_OBJ;	//RS table
    logic [`WIDTH-1:0] [$clog2(`RS_SIZE)-1:0]  prev_issue, del;
    logic[`RS_SIZE-1:0] issue_idx, load_idx; //Indices of RS_OBJ that are ready for issue
    logic issue_entry;
    logic entry_filled;
    int count;
    logic[18:0 ]count_inst, load_cnt, last_count;
    logic issue_is_ld;    

    ///////////////////////////////////////////////////////////////////////////
    //////////////////////////full_condition///////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////
    always_comb begin 
    	N_OBJ =OBJ ;
        count = 0;
        for (int a = 0; a < `WIDTH; a++) begin        
        	regA[a]   = id_packet[a].inst.r.rs1;
    		regB[a]   = id_packet[a].inst.r.rs2;
	    end 
 
        for (int p=0; p < `RS_SIZE; p++) begin
            if(!N_OBJ[p].busy)
                count = count + 1;
        end
        for(int h=0; h<`WIDTH; h++) begin
            full[h] = (ld_in_ex) ? 1: (count > h) ? 0 : 1;
        end


        /////////////////////////////////////////////////////////complete stage//////////////////////////
        for(int p=0; p<`WIDTH; p++) begin
            if(cdb[p].completed) begin
                for(int u=0; u < `RS_SIZE; u++) begin
                    if(N_OBJ[u].T1 == cdb[p].PR && N_OBJ[u].busy) begin
                        N_OBJ[u].P1_ready = 1'b1;
                        N_OBJ[u].send_issue = (N_OBJ[u].P2_ready)? 1:0;    
                    end
                    if(N_OBJ[u].T2 == cdb[p].PR && N_OBJ[u].busy) begin
                        N_OBJ[u].P2_ready = 1'b1;
                        N_OBJ[u].send_issue = (N_OBJ[u].P1_ready)? 1:0;
                    end
                end
            end
        end

        /////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////execute stage //////////////////////
        /////////////////////////////////////////////////////////////////////////////////
        for(int q=0;q < `WIDTH; q++) begin
            if(delete_confirm[q]) begin
                N_OBJ[prev_issue[q]].busy = ~delete_confirm[q];
            end
        end      

        ///////////////////////////////////////////////////////
        /////////////////////issue packet ///////////////////////
        //////////////////////////////////////////////
        issue_idx    = 0;
        load_idx     = 0;             
        issue_packet = 0;
        del = 0;
        issue_is_ld = 1'b0;
        load_issue      = 0;
        load_PC         = 0;
        load_cnt        = 20'hfffff;


        for(int w=0; w < `WIDTH; w++) begin
            issue_entry = 1'b0;
            last_count=21'hFFFFF;
            for(int v=0; v < `RS_SIZE; v++) begin
                if((issue_packet[w].inst_cnt < last_count ) && (!issue_idx[v]) && (!issue_entry)) begin
                    if((N_OBJ[v].send_issue == 1'b1) && (N_OBJ[v].busy == 1) ) begin
                        if(N_OBJ[v].packet.rd_mem) begin
                            if(!issue_is_ld ) begin
                                if(N_OBJ[v].load_permit && !ld_in_ex) begin
                                        issue_packet[w] = N_OBJ[v];
                                        issue_is_ld = 1;
                                        del[w]          = v;
                                        issue_entry     = 1'b1;
                                end
                                else begin
                                    issue_packet[w] = 0;
                                end
                            end
                            else begin
                                issue_packet[w] = 0;
                            end
                        end
                        else if(N_OBJ[v].packet.wr_mem) begin
                            if(!issue_is_ld) begin
                                issue_packet[w] = N_OBJ[v];
                                issue_is_ld = 1;
                                del[w]          = v;
                                issue_entry     = 1'b1;
                            end
                            else begin
                                issue_packet[w] = 0;
                            end
                        end
                        else begin
                            issue_packet[w] = N_OBJ[v];
                            del[w]          = v;
                            issue_entry     = 1'b1;
                        end
                    end
                    else begin
                        issue_packet[w] = 0;
                    end
                    last_count = N_OBJ[v].inst_cnt;
                end
                issue_idx[v]    = 1'b1;
            end
        end


        //asking for permit
        for(int i=0; i<`WIDTH; i++) begin
            for(int j=0; j<`RS_SIZE; j++) begin
                if(N_OBJ[j].packet.rd_mem && !N_OBJ[j].load_permit && N_OBJ[j].busy && !load_idx[j]) begin
                    if(N_OBJ[j].inst_cnt < load_cnt ) begin
                        load_issue[i] = 1;
                        load_PC[i]    = N_OBJ[j].T;
                        load_cnt    =   N_OBJ[j].inst_cnt;
                        load_idx[j] = 1;
                    end
                end
            end
        end


        ///////////////////////////////////////////////////////////////
        //////////////write an entry to rs///////////////////////////
        //////////////////////////////////////////////////////////

        for(int r=0; r < `WIDTH; r++) begin
            entry_filled = 0;
            if(write_true[r]) begin
                for(int m=0; m < `RS_SIZE; m++) begin
                    if(N_OBJ[m].busy == 1'b0 && !entry_filled) begin
                        N_OBJ[m].packet     = id_packet[r];
                        N_OBJ[m].busy       = 1'b1;
                        N_OBJ[m].T          = free_register[r];
                        N_OBJ[m].T1         = PA[r];
                        N_OBJ[m].P1_ready   = PA_ready[r];
                        N_OBJ[m].T2         = PB[r];
                        N_OBJ[m].P2_ready   = PB_ready[r];
                        N_OBJ[m].load_permit= 0;
                        N_OBJ[m].inst_cnt     =  (r!=0) ? ((write_true==2'b10) ? count_inst : count_inst + 1)  : count_inst ;
                        if(r > 0) begin
                            N_OBJ[m].T1         = (regA[r] == id_packet[r-1].dest_reg_idx)?
                                                    free_register[r-1] : PA[r];
                            N_OBJ[m].P1_ready   = (regA[r]!= `ZERO_REG && regA[r] == id_packet[r-1].dest_reg_idx)?
                                                    1'b0 : PA_ready[r];
                            N_OBJ[m].T2         = (regB[r] == id_packet[r-1].dest_reg_idx)?
                                                    free_register[r-1] : PB[r];
                            N_OBJ[m].P2_ready   = (regB[r]!= `ZERO_REG && regB[r] == id_packet[r-1].dest_reg_idx)?
                                                    1'b0 : PB_ready[r];
                        end
                        N_OBJ[m].send_issue = N_OBJ[m].P1_ready & N_OBJ[m].P2_ready;
                        entry_filled     = 1'b1;
                    end
                end
            end
        end


    end
  

    
    // synopsys sync_set_reset "reset"
    always_ff@(posedge clock) begin
        if(reset) begin
            count_inst           <= 0 ; 
        end
        if(reset || rollback_en) begin 
            for(int f=0; f < `RS_SIZE; f++) begin
                OBJ[f] <=  {
                    0,  //packet
                    0,  //busy
                    0,  //T
                    0,  //T1
                    0,  //T2
                    0,  //P1_ready
                    0,  //P2_ready
                    0,   //send_issue
                    0,  //instr counter
                    0   //load_permit
                }; 
                prev_issue      <= 0;
            end
        end
        else begin
	        count_inst <= (write_true==2'b11) ? count_inst+2 : (write_true==2'b00) ? count_inst : count_inst+1;
            prev_issue      <=  del;
            OBJ             <=  N_OBJ;   
            
            ///////////////////////////Asking for permit///////////////
            for(int g=0; g<=`WIDTH; g++) begin
                if(load_issue_permit[g]) begin
                    for(int j=0; j< `RS_SIZE; j++) begin
                        if(N_OBJ[j].packet.rd_mem && N_OBJ[j].T==load_issue_PC[g]) begin
                            OBJ[j].load_permit <= load_issue_permit[g];  
                        end
                    end
                end
            end 
        end
    end

endmodule

