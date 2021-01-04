module store_queue(
    input clock,
    input reset,
    input rollback,
                    
    //Input from Dispatch
    input logic [`WIDTH-1 :0] [$clog2(`PRF_SIZE)-1:0] tags,
    input [`WIDTH-1 :0] is_store,  ///If instruction is store
    input logic [`WIDTH-1: 0] is_load,   ///If instruction is load
    input MEM_SIZE [`WIDTH-1 :0] mem_size , 

    //inputs from complete stage
    input CDB [`WIDTH-1 :0] cdb,

    ////////////input from execute stage/////////////
    ///////this is the value that has to be stored at the memory location///////////////////
    input logic [`WIDTH-1:0][`XLEN-1:0] result, 

    //inputs from RS
    input logic [`WIDTH-1 :0] [$clog2(`PRF_SIZE)-1:0] load_tags,
    input logic [`WIDTH-1:0] load_issue, 

    /////input from execute 
    input logic [`WIDTH-1 : 0][`XLEN-1:0] ex_addr,
    input logic [`WIDTH-1 : 0][$clog2(`PRF_SIZE)-1:0] ex_st_tags, //////////////////////to match the tags from the quueue
    input MEM_SIZE mem_size_ex_stage, ///Mem size from the Execute stage 
    //from ex stage
    input [`WIDTH-1: 0][1:0] is_ex_load,   ///If instruction is load 

    //inputs from Retire stage
    input logic[`WIDTH-1: 0] retire_en,
    input logic[`WIDTH-1: 0] retire_load,
    input logic[`WIDTH-1 :0][$clog2(`PRF_SIZE)-1:0]retire_tag, //Retiring Tag 

    ///////output to execute stage 
    output logic[`WIDTH-1: 0] st_value_valid,
    output logic [`WIDTH-1: 0][`XLEN-1:0] st_value,

    //outputs to RS
    output logic  [`WIDTH-1 :0] [$clog2(`PRF_SIZE)-1:0] load_issue_PC,
    output logic [`WIDTH-1:0] load_issue_permit
);


logic [`S_QUEUE_SIZE-1:0] sc_status; ////keeps the completed status of the particular store  
logic [`S_QUEUE_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] s_queue; ////////////keeps the store instruction addresses
logic [`S_QUEUE_SIZE-1:0] [`XLEN-1:0] s_data; ////////////keeps the store instruction data that has to be stored at a particular mem location
logic [`S_QUEUE_SIZE-1:0] [`XLEN-1:0] s_addr; ////////////keeps the store instruction addr of mem location
logic [`S_QUEUE_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] l_queue; ////////////keeps the load instruction addresses 
logic [`S_QUEUE_SIZE-1:0] [$clog2(`S_QUEUE_SIZE)-1:0] l_pointer; ///////////the corresponding store queue tail pointer when load was dispatched 
logic [$clog2(`S_QUEUE_SIZE)-1:0] tail;                       ////////Store queue tail 
logic [$clog2(`S_QUEUE_SIZE)-1:0] sc_pointer;                 //store completion pointer 
logic [$clog2(`S_QUEUE_SIZE)-1:0] l_tail;                     //The load queue tail 
logic [$clog2(`S_QUEUE_SIZE)-1:0] nsc_pointer;
logic [$clog2(`S_QUEUE_SIZE)-1:0] counter;
logic [$clog2(`S_QUEUE_SIZE)-1:0] counter_p;
logic [$clog2(`S_QUEUE_SIZE)-1:0] counter_two;
//logic checker;
logic [`S_QUEUE_SIZE-1:0] retire_load_queue;    ///Retire bits for load Queue
logic [`S_QUEUE_SIZE-1:0] s_queue_busybit;      ///Busy Bit for Store Entries 
logic [`S_QUEUE_SIZE-1:0] [1:0] S_queue_mem_size;       ///Mem size array for Store Queue Entries  
logic size_check;
logic [`S_QUEUE_SIZE-1:0] l_queue_busybit;
logic [`WIDTH-1:0] load_issue_permit_old;
logic papa;
always_ff@(posedge clock)begin
    if(reset | rollback)begin
        sc_pointer        <= 0;
        l_tail            <= 0;
        tail              <= 0;      
        s_queue           <= 0;
        s_addr            <= 0;
        s_data            <= 0;
        sc_status         <= 0;
        l_queue           <= 0;
        l_pointer         <= 0;
        retire_load_queue <= 0;
        s_queue_busybit   <= 0;
        S_queue_mem_size  <= 0;
        size_check        <= 0;
        l_queue_busybit   <= 0;
    end
    else begin
        
        sc_pointer <= nsc_pointer;
        case(is_store)
            2'b00: begin
            end
            2'b01: begin
                s_queue[tail]               <= tags[0];
                sc_status[tail]             <= 0;
                s_queue_busybit[tail]       <= 1;
                S_queue_mem_size[tail]      <= mem_size [0];
            end
            2'b10: begin
                s_queue[tail]     <= tags[1];
                sc_status[tail]   <= 0;
                s_queue_busybit[tail]  <= 1;
                S_queue_mem_size[tail] <= mem_size [1];
            end
            2'b11: begin
                s_queue[tail]               <= tags[0];
                sc_status[tail]             <= 0;
                s_queue_busybit[tail]       <= 1;
                S_queue_mem_size [tail]     <= mem_size [0];
                if(tail == `S_QUEUE_SIZE-1)begin
                    s_queue [0]             <= tags[1];
                    sc_status[0]            <= 0;
                    s_queue_busybit [0]     <= 1;
                    S_queue_mem_size[0]     <= mem_size [1];
                end 
                else begin
                    s_queue[tail+1]             <= tags[1];
                    sc_status[tail+1]           <= 0;
                    s_queue_busybit[tail + 1]   <= 1;
                    S_queue_mem_size  [tail+1]  <= mem_size [1];
                end 

            end
        endcase

        tail <= (is_store==2'b11) ? tail+2 :
                    (is_store==2'b00) ? tail : tail + 1;
        
        case(is_load)
            2'b00: begin
            end
            2'b01: begin
                l_queue[l_tail]     <=  tags[0];
                l_pointer[l_tail]   <=  tail;
                retire_load_queue [l_tail] <=  0;
                l_queue_busybit [l_tail]   <=  1;
            end
            2'b10: begin
                l_queue[l_tail]     <=  tags[1];
                retire_load_queue [l_tail] <=  0;
                l_queue_busybit [l_tail] <= 1;
                if(is_store == 2'b01)
                    l_pointer[l_tail]   <=  tail+1;
                else
                    l_pointer[l_tail]   <=  tail;
            end
            2'b11: begin
                l_queue[l_tail]     <=  tags[0];
                l_pointer[l_tail]   <=  tail;
                retire_load_queue [l_tail] <=  0;
                l_queue_busybit[l_tail] <= 1;
                if(l_tail==`S_QUEUE_SIZE-1) begin
                    l_queue[0]   <=  tags[1];
                    l_pointer[0] <=  tail;
                    retire_load_queue [0] <=  0;
                    l_queue_busybit[0] <= 1;
                end else begin
                    l_queue[l_tail+1]   <=  tags[1];
                    l_pointer[l_tail+1] <=  tail;
                    retire_load_queue [l_tail + 1] <=  0;
                    l_queue_busybit [l_tail + 1] <= 1;
                end
            end
        endcase

        l_tail <= (is_load == 2'b11) ? l_tail + 2 :
                        (is_load == 2'b00) ? l_tail : l_tail + 1;
    end 

    for(int k=0;k<`WIDTH;k++)begin
        if(cdb[k].completed)begin                 ///////store completion status bit incoming from complete stage 
            for(int j=0; j<`S_QUEUE_SIZE;j++)begin  
                if((s_queue[j] == cdb[k].PR )&&  (sc_status[j]!=1) && (s_queue_busybit[j]==1) && !rollback)begin   ///match complete stage incoming tags and the store queue tags 
                    sc_status[j] <= 1;                   ///update store ccompletion bit 
                    break;
                end     
            end 
        end 
    end 

    for(int x=0;x<`WIDTH;x++) begin
        for(int y=0;y<`S_QUEUE_SIZE;y++) begin
            if(ex_st_tags[x]== s_queue[y] && (is_ex_load[x]==2'b10) ) begin
                s_addr[y]   <= ex_addr[x];
                s_data[y]   <= result[x];
            end
        end
    end

    for(int p = 0; p < `WIDTH; p++)begin
        if(retire_en [p] && retire_load[p])begin
            for(int cam = 0; cam < `S_QUEUE_SIZE ; cam ++)begin
                if((retire_tag [p] == l_queue [cam])&& !retire_load_queue[cam] && ((cam != l_tail) && is_load)) begin //cam < l_tail )begin
                    retire_load_queue [cam]  <= 1;
                    break ;
                end 
            end 
        end 
    end 
end 


always_comb begin
    if(sc_status[sc_pointer])begin
        nsc_pointer = sc_pointer + 1;       ////updating store completion pointer 
    end
    else begin
        nsc_pointer = sc_pointer;
    end 

    /////////////////cam store queue in case a load comes//////////////////////////////
    st_value = 0;
    st_value_valid = 0;
    
  /*  for(int b=0;b<`WIDTH;b++) begin
        if(is_ex_load[b] == 2'b01)begin
            for(int c=0;c<`S_QUEUE_SIZE;c++) begin
                if((ex_st_tags[b]== l_queue[c]) && (retire_load_queue[c] ==0 ))begin
                    for(int a=0;a<`S_QUEUE_SIZE;a++) begin
                        if(ex_addr[b]== s_addr[a]) begin
                            if((l_pointer[c]<=tail && a < =l_pointer[c]) || 
                                        (l_pointer[c]>=tail && (a>=tail && a <=l_pointer[c] ) ) ||
                                                    ((tail == l_pointer[c]) && tail == 0)) begin
                                st_value[b]       = s_data[a];
                                st_value_valid[b] = 1;
                            end
                            else
                                st_value_valid[b] = 0;
                        end
            else begin 


                    end
                    end
                end
            end
       end
    end
    */


    for(int b = 0;b < `WIDTH; b++) begin
        if((is_ex_load[b] == 2'b01) && (mem_size_ex_stage == 2'h2 ))begin
            for(int c =0 ;c<`S_QUEUE_SIZE ; c++)begin
                if((ex_st_tags [b] == l_queue[c]) && !(retire_load_queue [c]))begin
                        if(l_pointer[c] <= tail)begin
                            for(int z = 0; z < `S_QUEUE_SIZE ; z++)begin
                                if(z>=tail)begin
                                if((ex_addr [b] == s_addr [z]) && (s_queue_busybit[z]) && (S_queue_mem_size [z]==2'h2))begin
                                    st_value [b] = s_data [z];
                                    st_value_valid [b] = 1;
                                end 
                                else if((ex_addr [b] == s_addr [z]) && (s_queue_busybit[z]) && (S_queue_mem_size [z]!=2'h2))begin
                                    st_value_valid [b] = 0;
                                    
                                end 

                                
                                end 
                            end 
                            for(int z1 = 0; z1 < l_pointer[c]; z1++)begin
                                if((ex_addr [b] == s_addr [z1]) && (s_queue_busybit[z1]) && (S_queue_mem_size [z1]==2'h2))begin
                                    st_value [b] = s_data [z1];
                                    st_value_valid [b] = 1;
                                end 
                                else if((ex_addr [b] == s_addr [z1]) && (s_queue_busybit[z1]) && (S_queue_mem_size [z1]!=2'h2))begin
                                    st_value_valid [b] = 0;
                                end 
                            end
                        end 
                        else if(l_pointer [c] > tail)begin
                            for(int z2 = 0; z2 < l_pointer [c]; z2 ++)begin
                                if(z2 >= tail)begin
                                if((ex_addr [b] == s_addr [z2]) && (s_queue_busybit[z2]) && (S_queue_mem_size [z2] == 2'h2))begin
                                    st_value [b] = s_data [z2];
                                    st_value_valid [b] = 1;
                                end
                                else if((ex_addr [b] == s_addr [z2]) && (s_queue_busybit[z2]) && (S_queue_mem_size [z2]!=2'h2))begin
                                    st_value_valid [b] = 0;    
                                end 
                                end 
                            end 
                        end 
                        else
                        st_value_valid [b] = 0;
                end 
                //else
              //  st_value_valid [b] = 0;
            end
        end
	else begin
		st_value_valid [b] = 0;
	end 

    end  
    counter             = 0;
    counter_p             = 0;
    counter_two         = 0;
    load_issue_PC       = 0;
    load_issue_permit   = 0;
    load_issue_permit_old  = 0;
    papa =0;
    for(int a =0;a< `WIDTH; a++)begin
        if(load_issue[a] )begin
            load_issue_PC[a] = load_tags[a];
            for(int a1 = 0; a1 < `S_QUEUE_SIZE; a1++)begin
                if((l_queue[a1] == load_tags[a]) && (retire_load_queue [a1] == 0) ) begin//&& !((is_load[0] == 1 || is_load[1]==1) && ((tags[0] == load_tags[a1]) || (tags[1]==load_tags[a1]))))begin
                    counter = 0;
                    counter_two = 0;
                    if(l_pointer [a1] <= tail ) begin//|| (l_pointer [a1] == tail))begin
                        for (int a9 = 0;a9 < `S_QUEUE_SIZE; a9++)begin
                            if(a9 >=tail)begin
                              if(s_queue_busybit[a9]==0)begin
                            
                                for(int a2 = 0; a2 <  l_pointer[a1]; a2++)begin
                                    if(sc_status [a2])begin
                                       counter = counter + 1;
                                    end
                                    else begin
                                        break;
                                    end 
                                   if(counter == l_pointer [a1]) begin//)load_issue_permit_old[a])begin
                                        load_issue_permit[a] = 1;
                                   end 
                                    
                                    else begin
                                        load_issue_permit[a] = 0;
                                    end
                                end 
                                break;

                              end
                              else begin  
                              //  papa=1;
                                 if(sc_status[a9])begin
                                   counter_p = counter_p +1;
                                  end
                                  else begin
                                    load_issue_permit[a] = 0;
                                   break;
                                  end 
                                 if(counter_p == `S_QUEUE_SIZE - tail)begin
                       
                                    for(int a21 = 0; a21 <  l_pointer[a1]; a21++)begin
                                        if(sc_status [a21])begin
                                            counter = counter + 1;
                                        end
                                        else begin
                                            break;
                                        end 
                                        if(counter == l_pointer [a1] ) begin
                                            load_issue_permit[a] = 1;
                                        end 
                                        else begin
                                            load_issue_permit[a] = 0;
                                        end
                                    end 
                                 end 
                                 else begin
                           
                                 end
                                end
                            end
                            
                              
                        end
                       

                        if( (l_pointer [a1] == 0) && (l_queue_busybit [a1]) )begin
                            if(tail == 0 && sc_pointer ==0)begin
                                load_issue_permit[a] = 1;
                            end 
                            else if(tail == 0 && sc_pointer!= 0 )begin
                                load_issue_permit [a] = 0;
                            end 
                            else if(tail !=0 && sc_pointer > tail  ) begin
                                load_issue_permit [a] = 0;

                            end
                            else if(tail !=0 && sc_pointer < tail  ) begin
                                load_issue_permit [a] = 1;

                            end
                        end 

                    end

                
                  else if(l_pointer [a1] > tail )begin
                     for(int a3 = 0; (a3 < l_pointer[a1] ); a3++)begin
                          if(a3 >= tail) begin
                            if(sc_status [a3])begin
                                counter_two = counter_two + 1;
                            end 
                            else begin
                                break;
                            end 
                            if(counter_two == (l_pointer[a1] - tail ))begin
                                load_issue_permit[a] = 1;
                            end
                            else begin
                                load_issue_permit[a] = 0;
                            end 
                        end 
                        end 
                    end                    
                end 
            end 
        end 
        else begin
            load_issue_permit[a] = 0;
        end 
    end 
end 


endmodule 
