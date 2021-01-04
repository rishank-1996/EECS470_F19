//parameter `WIDTH = 2;
//parameter `ROB_SIZE = 32;
`timescale 1ns/100ps

module ss_rob (
	input 	   	clk,
	input 	   	reset,
	input	   	[`WIDTH-1:0] dispatch_en,
	input ID_DISP_PACKET [`WIDTH-1:0] packet,
	input 		[`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] tag_old, 	//input from maptable
	input 		[`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] free_reg,
	input    	[`WIDTH-1:0]  retire_en,
	input 		CDB [`WIDTH-1:0] cdb,


	//input from BTB
	input logic [`WIDTH-1:0] mismatch_en,
	input logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] mismatch_tag,
	input logic [`WIDTH-1:0] [`XLEN-1:0] alu_result,

	//output to maptable requesting older tag:
	output logic [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] dest_reg,

	output logic [`WIDTH-1:0] rob_hazard,
	output logic [`WIDTH-1:0] ready_to_retire,
	output ROB_ENTRY [`WIDTH-1:0] retire_entry,

	//output to every stage that affected by rollback
	output logic rollback,
	output logic [`XLEN-1:0] exception_pc,
	output logic [$clog2(`ROB_SIZE)-1:0] rewind_head,

	//output to BTB
	output logic [`XLEN-1:0] rollback_pc
);

	ROB_ENTRY [`ROB_SIZE-1:0] Rob_table;
	logic [$clog2(`ROB_SIZE)-1:0] tail_cntr;
	logic [$clog2(`ROB_SIZE)-1:0] head_cntr;
	logic [$clog2(`ROB_SIZE)-1:0] diff;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] tag ;
	logic double_store;

	assign double_store = ((Rob_table[head_cntr].packet.wr_mem) | (Rob_table[head_cntr+1].packet.wr_mem)); 
	assign rollback 	= Rob_table[head_cntr].rollback & Rob_table[head_cntr].tag_ready;
	assign rollback_pc  = Rob_table[head_cntr].packet.PC;
	assign exception_pc = Rob_table[head_cntr].alu_result;
	assign rewind_head	= head_cntr;

	assign diff = (head_cntr - tail_cntr);
	always_comb begin
		case(`WIDTH)
			1: begin
				rob_hazard[0]  =  (diff == 1) ? 1'b1 : 1'b0;
			end
			2: begin
				rob_hazard[0]  =  (diff == 1) ? 1'b1 : 1'b0;
				rob_hazard[1]  =  (diff == 1 || diff == 2) ? 1'b1 : 1'b0;
			end
		endcase
	end

	always_comb begin		//what about dependent instructions?
		for(int w=0; w<`WIDTH; w++) begin
			retire_entry[w] 	= Rob_table[head_cntr+w];
			if(head_cntr==`ROB_SIZE-1) begin
				retire_entry[1] = Rob_table[0];
			end
			tag[w]				= free_reg[w];
			dest_reg[w]			= packet[w].dest_reg_idx;
		end	
	end
	
	//readytoretire logic
	always_comb begin
		case(`WIDTH)
			1: begin
				ready_to_retire  = (Rob_table[head_cntr].tag_ready) ? 1'b1 : 1'b0;
			end

			2: begin
				if(Rob_table[head_cntr].tag_ready) begin
					if(!Rob_table[head_cntr].rollback) begin
						if(head_cntr==31) begin
							if(Rob_table[0].tag_ready && !Rob_table[0].rollback && !double_store) begin
								ready_to_retire = 2'b11;
							end
							else begin
								ready_to_retire = 2'b01;
							end
						end
						else begin
							if(Rob_table[head_cntr+1].tag_ready && !Rob_table[head_cntr+1].rollback && !double_store) begin
								ready_to_retire = 2'b11;
							end
							else begin
								ready_to_retire = 2'b01;
							end
						end
					end
					else begin
						ready_to_retire = 2'b01;
					end
				end
				else begin
					ready_to_retire = 2'b00;
				end
			end
		endcase	
	end

	always_ff@(posedge clk) begin
		if(reset) begin
			Rob_table <= {
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0
			};
			tail_cntr <= {$clog2(`ROB_SIZE){1'b0}} ; 
			head_cntr <= {$clog2(`ROB_SIZE){1'b0}}; 
		end
		else begin
			case (dispatch_en)
				0: begin
				end

				1: begin
					if(!rollback) begin
						Rob_table[tail_cntr].packet    <= packet[0];
						Rob_table[tail_cntr].rollback  <= 1'b0;
						Rob_table[tail_cntr].tag       <= tag[0];
						Rob_table[tail_cntr].tag_ready <= 1'b0;
						Rob_table[tail_cntr].tag_old   <= tag_old[0];
						Rob_table[tail_cntr].dest      <= dest_reg[0];
						Rob_table[tail_cntr].alu_result<= 0;
					end
					else begin
						Rob_table[rewind_head+1].packet    <= packet[0];
						Rob_table[rewind_head+1].rollback  <= 1'b0;
						Rob_table[rewind_head+1].tag       <= tag[0];
						Rob_table[rewind_head+1].tag_ready <= 1'b0;
						Rob_table[rewind_head+1].tag_old   <= tag_old[0];
						Rob_table[rewind_head+1].dest      <= dest_reg[0];
						Rob_table[tail_cntr+1].alu_result		<= 0;
					end
					tail_cntr	  <= (rollback) ? rewind_head + 2: tail_cntr +1 ;
				end

				2: begin
					if(!rollback) begin
						Rob_table[tail_cntr].packet    <= packet[1];
						Rob_table[tail_cntr].rollback  <= 1'b0;
						Rob_table[tail_cntr].tag       <= tag[1];
						Rob_table[tail_cntr].tag_ready <= 1'b0;
						Rob_table[tail_cntr].tag_old   <= tag_old[1];
						Rob_table[tail_cntr].dest      <= dest_reg[1];
						Rob_table[tail_cntr].alu_result<= 0;
					end
					else begin
						Rob_table[rewind_head+1].packet    <= packet[1];
						Rob_table[rewind_head+1].rollback  <= 1'b0;
						Rob_table[rewind_head+1].tag       <= tag[1];
						Rob_table[rewind_head+1].tag_ready <= 1'b0;
						Rob_table[rewind_head+1].tag_old   <= tag_old[1];
						Rob_table[rewind_head+1].dest      <= dest_reg[1];
						Rob_table[tail_cntr+1].alu_result	<= 0;
					end
					tail_cntr 	  <= (rollback) ? rewind_head + 2: tail_cntr +1 ;
				end

				3: begin
					if(!rollback) begin
						Rob_table[tail_cntr].packet    <= packet[0];
						Rob_table[tail_cntr].rollback  <= 1'b0;
						Rob_table[tail_cntr].tag       <= tag[0];
						Rob_table[tail_cntr].tag_ready <= 1'b0;
						Rob_table[tail_cntr].tag_old   <= tag_old[0];
						Rob_table[tail_cntr].dest      <= dest_reg[0];
						Rob_table[tail_cntr].alu_result<= 0;
						if(tail_cntr!=`ROB_SIZE-1) begin
							Rob_table[tail_cntr+1].packet    <= packet[1];
							Rob_table[tail_cntr+1].rollback  <= 1'b0;
							Rob_table[tail_cntr+1].tag       <= tag[1];
							Rob_table[tail_cntr+1].tag_ready <= 1'b0;
							Rob_table[tail_cntr+1].tag_old   <= tag_old[1];
							Rob_table[tail_cntr+1].dest      <= dest_reg[1];
							Rob_table[tail_cntr+1].alu_result<= 0;
						end
						else begin
							Rob_table[0].packet    <= packet[1];
							Rob_table[0].rollback  <= 1'b0;
							Rob_table[0].tag       <= tag[1];
							Rob_table[0].tag_ready <= 1'b0;
							Rob_table[0].tag_old   <= tag_old[1];
							Rob_table[0].dest      <= dest_reg[1];
							Rob_table[0].alu_result<= 0;
						end
					end
					else begin
						
					end
					tail_cntr 	  <= (rollback) ? rewind_head + 3: tail_cntr +2;	
				end
			endcase

			//broadcast both tags
			for(int p=0; p<`WIDTH; p++) begin
				if(cdb[p].completed & !rollback) begin
					for(int i=0; i<`ROB_SIZE; i++) begin
						if(Rob_table[i].tag == cdb[p].PR) begin
							Rob_table[i].tag_ready <= 1'b1;
						end
					end
				end
			end

			if(rollback) begin
				tail_cntr <= rewind_head + 1;
				for(int j=0; j<`ROB_SIZE; j++) begin
					Rob_table[j].tag_ready<=1'b0;
					/*if(rewind_head==31)
						Rob_table[j].tag_ready <= 1'b0;*/
				end
			end

			//assert rollback on mismatch
			for(int j=0; j<`WIDTH; j++) begin
				if(mismatch_en[j]) begin
					for(int l=0; l<`ROB_SIZE; l++) begin
						if(Rob_table[l].tag == mismatch_tag[j]) begin
							Rob_table[l].rollback <= 1'b1;
							Rob_table[l].alu_result <= alu_result[j];
						end
					end
				end
			end

			case(retire_en)
				0: begin
				end
				
				1:begin
					Rob_table[head_cntr].tag_ready <= 0;
					head_cntr   <= head_cntr +1 ;
				end 

				3: begin
					Rob_table[head_cntr].tag_ready 		<= 0;
					if(head_cntr==`ROB_SIZE-1) begin
						Rob_table[0].tag_ready <= 0;
					end
					else begin
						Rob_table[head_cntr+1].tag_ready 	<= 0;
					end
					head_cntr 	<= head_cntr + 2;
				end
			endcase
		end
	end 


endmodule
