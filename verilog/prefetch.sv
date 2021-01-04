module prefetch ( 
                  input clock,
                  input reset,
                  input update_mem_tag , 
		  input [3:0]current_mem_tag ,
                  input [31:0]proc2Icache_addr,
                  input   Icache_valid_out,        

    		  output [31:0]proc_2_controller,
    		  output [31:0]proc_2_controller_p,
		  output [3:0]current_mem_tag_p
    
    );


    logic [15:0] tag ;
    logic [15:0] [31:0] PC;
    logic [15:0] [3:0] PC_tag;
    logic [15:0] valid;
    logic [3:0] head;
    logic wrong_pre;
    logic full;
    logic [3:0] tail;
    logic [3:0] tag_tail;
    logic [1:0]a;


    	 assign current_mem_tag_p = PC_tag[head];
         assign wrong_pre = (proc2Icache_addr != PC[head]);
	 assign proc_2_controller =  PC[tag_tail] ;
	 assign proc_2_controller_p =  PC[head] ;

    always_ff @(posedge clock)begin
        if(reset)begin
            head <= 0;
            full <= 1'b0;
            PC   <= 0 ;
            tail <= 1;
	   PC_tag <=0;
	    tag_tail<=0;
	   a<=0;
        end 
        else begin
            //for( int i =0; i<16; i++)begin
                    if(tail == head)begin
                        full <= 1'b1;
                    end 
                    else if(!wrong_pre) begin
                        tail <= tail + 1;
			if(tail !=0)
                        PC [tail] <= PC [tail-1] + 8;
			else
			PC [tail] <= PC [15] + 8;
			full <=0;
                    end
                    else if(wrong_pre)begin
                        head <= 0;
                        full <= 1'b0;
                        PC   <= 0 ;
                        tail <= 1;
                    end
            //end
            if(Icache_valid_out)begin
                head <= head+1;
            end
		if(current_mem_tag !=0)begin
		
		PC_tag[tag_tail] <= current_mem_tag;
		tag_tail <= tag_tail+1;

	//	if(a >= 1) begin
	//	tag_tail <= tag_tail+1;
	//	end 
	//	else begin
	//	a <= 1;
	//	end 
		end
        end

    end 

    
endmodule 



