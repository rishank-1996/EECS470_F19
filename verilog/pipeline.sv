`timescale 1ns/100ps

`ifndef __PIPELINE_V__
`define __PIPELINE_V__



module pipeline(

	input         clock,                    // System clock
	input         reset,                    // System reset
	input [3:0]   mem2proc_response,        // Tag from memory about current request
	input [63:0]  mem2proc_data,            // Data coming back from memory
	input [3:0]   mem2proc_tag,              // Tag from memory about current reply
	
	output logic [1:0]  proc2mem_command,    // command sent to memory
	output logic [`XLEN-1:0] proc2mem_addr,      // Address sent to memory
	output logic [63:0] proc2mem_data,// Data sent to memory

	`ifndef CACHE_MODE
	output MEM_SIZE proc2mem_size,          // data size sent to memory
	`endif

	output logic [3:0]  pipeline_completed_insts,
	output EXCEPTION_CODE   pipeline_error_status,
	output logic [`WIDTH-1:0][$clog2(`RF_SIZE)-1:0]  pipeline_commit_wr_idx,
	output logic [`WIDTH-1:0][`XLEN-1:0] pipeline_commit_wr_data,
	output logic [`WIDTH-1:0]  pipeline_commit_wr_en,
	output logic [`WIDTH-1:0][`XLEN-1:0] pipeline_commit_NPC,
	
	
	// testing hooks (these must be exported so we can test
	// the synthesized version) data is tested by looking at
	// the final values in memory
	
	
	// Outputs from IF-Stage 
	output logic [`XLEN-1:0][`WIDTH-1:0] if_NPC_out,
	output logic [31:0][`WIDTH-1:0] if_IR_out,
	output logic  [`WIDTH-1:0]      if_valid_inst_out,

	//For debuggging purpose
	output IF_ID_PACKET [`WIDTH-1:0] if_packet,
	output IF_ID_PACKET [`WIDTH-1:0] if_id_packet,
	output RS_OBJ [`WIDTH-1:0] issue_packet,
	output RS_OBJ [`WIDTH-1:0]  issue_ex_packet,
	output ROB_ENTRY [`WIDTH-1:0] retire_entry,
	output EX_COMPLETE [`WIDTH-1:0] complete_packet,
	output ID_DISP_PACKET [`WIDTH-1:0] disp_packet,
	output logic [`XLEN-1:0] proc2Dmem_addr,
	output logic [63:0] proc2Dmem_data ,
	output logic [1:0]  halt_status

);
		
	// Outputs from IF-Stage
	logic [63:0] proc2Imem_addr;
	logic [63:0] proc2Icache_addr;

	logic load_stall;
	//our variable definitions - super scalar
	logic [`WIDTH-1:0] mismatch;
	logic [`WIDTH-1:0] retire_load;
	logic rollback;
	logic [`WIDTH-1:0][`XLEN-1:0]T_PC;
	logic [`WIDTH-1:0]hit ;
	logic [`WIDTH-1:0]is_branch ;
	logic [`WIDTH-1:0]is_jump ;
	logic [`WIDTH-1:0][`XLEN-1:0]PC2btb ;
	STATE state;
	CDB [`WIDTH-1:0] cdb;
	logic [`RR_SIZE-1:0] [$clog2(`PRF_SIZE)-1:0] rrtable;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] PA, PB;
	logic [`WIDTH-1:0] PA_ready, PB_ready;
	logic [`WIDTH-1:0]	rob_hazard;
	logic [`WIDTH-1:0]	SH_RS;
	logic [`WIDTH-1:0] [`XLEN-1:0] valueA;
	logic [`WIDTH-1:0] [`XLEN-1:0] valueB;
	logic [`WIDTH-1:0] [`XLEN-1:0] alu_result;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] operandA;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] operandB;
	logic [`WIDTH-1:0] rtr;
	logic [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] retire_reg;
	logic [`WIDTH-1:0] inst_retire;
	logic [$clog2(`ROB_SIZE)-1:0] rewind_head;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] RRAT_newpreg;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] free_preg;
	logic [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] regA , regB;
	logic [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0] dest_rob;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] prev_T;
	logic [`WIDTH-1:0] FU_unit_ALU;
	logic [`WIDTH-1:0] FU_unit_mul;
	logic [`WIDTH-1:0] stall_ALU;
	logic [`XLEN-1:0]  store_data;
	logic [`WIDTH-1:0] [`XLEN-1:0] retire_data;
	logic [`WIDTH-1:0] execution_done;
	logic [`WIDTH-1:0] delete_confirm;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] new_free_preg;
	logic [`WIDTH-1:0] dispatch_en;
	logic [`WIDTH-1:0] zero_cond;
	logic  i_cache_data_write_en ;
	logic  i_cache_data_read_valid ;
	MEM_SIZE ex_mem_size, st_mem_size;
	logic [4:0] icache_rd_idx;
	logic [4:0] icache_wr_idx;
	logic [7:0] icache_wr_tag;
	logic [7:0] icache_rd_tag;
	logic [63:0] icache_rd_data;
	logic [63:0] icache_wr_data;
	logic [63:0] Icache_data_out;
	logic Icache_valid_out;
	logic [`XLEN-1:0] mem_result_out;
	//logic [1:0]  proc2Dmem_command;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] mism_tag;
	logic [$clog2(`PRF_SIZE)-1:0] store_rs2_tag;
	logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] EX_tag;
	logic [`WIDTH-1:0] [`XLEN-1:0] EX_TARGET, EX_PC;
	logic [`XLEN-1:0] exception_pc;
	logic [`WIDTH-1:0] take_branch;
	logic [`WIDTH-1:0] halt;
	logic predict, taken;
	logic [$clog2(`RF_SIZE)-1:0] st_rs2;
	logic  [63:0] cachemem_data;
	logic tload_present ;
    logic   cachemem_valid;
	logic  [1:0] proc2Dmem_command;
	logic  [1:0] proc2Imem_command;
    logic [31:0] sproc2Dmem_addr;
    logic [63:0] Dcache_data_out;
    logic  Dcache_valid_out;
	logic  [4:0] current_index;
    logic  [7:0] current_tag;
    logic  [4:0] last_index;
    logic  [7:0] last_tag;
	logic  data_write_enable;	
	logic [`WIDTH-1:0] [`XLEN-1:0] return_addr;
	logic [`WIDTH-1:0] ret_valid;
	logic [1:0] sproc2dmem_cmd;
	logic cache_enable;
	logic [31:0] store_tag_value;
	logic [5:0] store_tag;
	logic [31:0] store_p2_value;
	logic  wr_en;
	logic store;
	logic write_enable;
	logic [63:0] wr_data;
	logic [63:0] wr_addr;
	logic [`WIDTH-1:0] st_value_valid;
	logic [`WIDTH-1:0] [`XLEN-1:0] st_value;
	logic [`WIDTH-1:0] temp_taken;
	logic [`WIDTH-1:0] is_store;
	logic [`WIDTH-1:0] is_load;
	logic hazard;
	logic [`WIDTH-1:0][`XLEN-1:0] ex_addr;
	logic [`WIDTH-1:0][`XLEN-1:0] rob_result;
	logic [`WIDTH-1:0][$clog2(`PRF_SIZE)-1:0] ex_st_PC;
	logic [`WIDTH-1:0][1:0] is_ex_load;
	logic [`WIDTH-1:0][`XLEN-1:0] result;
	logic [`WIDTH-1:0][`XLEN-1:0] result_store;
	logic [`WIDTH-1:0][$clog2(`PRF_SIZE)-1:0]load_issue_PC;
	logic [`WIDTH-1:0][$clog2(`PRF_SIZE)-1:0]load_PC;
	logic [`WIDTH-1:0]load_issue;
	logic [`WIDTH-1:0]load_issue_permit;
	logic [`XLEN-1:0] rollback_pc;
	logic h_able;
    logic [$clog2(`PRF_SIZE)-1:0] alt_tag, store_t;
    logic switch;
	//logic hazard;
	logic        vc_en,   swap_en;
	logic [4:0]  vc_idx,  swap_idx;
	logic [7:0]  vc_tag,  swap_tag;
	logic [63:0] vc_write, swap_data; 
	logic [63:0] vc_data;
	logic vc_valid;
	MEM_SIZE rd_size;	
	MEM_SIZE [`WIDTH-1:0] disp_mem_size;
	MEM_SIZE [`WIDTH-1:0] mem_size_ex;
	
	/////////////////////////tb instnces
	logic [`WIDTH-1:0][`XLEN-1:0] tb_data;
	logic [`WIDTH-1:0][$clog2(`PRF_SIZE)-1:0] tb_reg;

	`ifndef CACHE_MODE
	MEM_SIZE proc2Dmem_size;
	`endif

	assign hazard = data_write_enable;
	assign pipeline_completed_insts =(inst_retire == 2'b11)? 3'b10: 
					(inst_retire == 2'b10 |inst_retire == 2'b01)? 3'b01:3'b0;
	assign tb_reg =RRAT_newpreg; 
	assign pipeline_error_status = (halt_status!=2'b00)? HALTED_ON_WFI : NO_ERROR;
	assign pipeline_commit_wr_data = (inst_retire)?tb_data:0;
	assign pipeline_commit_wr_en = (halt_status[0]) ? 2'b01 : inst_retire;
	assign h_able = (proc2Dmem_command != BUS_NONE) | (wr_en);
	assign pipeline_commit_wr_idx = retire_reg;
	
	always_comb begin
		for(int m=0; m<`WIDTH; m++)
			pipeline_commit_NPC[m] = retire_entry[m].packet.PC;
	end

	always_ff@(posedge clock) begin
		if(reset)
			halt_status <= 0;
		else if(halt_status==0)
			halt_status <= halt;
	end
	
//////////////////////////////////////////////right now d cache is not being implemented/////
	assign proc2mem_command =	(wr_en) ? BUS_STORE :
	     (proc2Dmem_command == BUS_NONE) ? proc2Imem_command : proc2Dmem_command;
	assign proc2mem_addr =  (wr_en) ? proc2Dmem_addr :
		 (proc2Dmem_command == BUS_NONE) ? proc2Imem_addr : proc2Dmem_addr;
		 
	//original from here
	//	assign proc2mem_addr = proc2Imem_addr; 

	`ifndef CACHE_MODE
	assign proc2mem_size = (wr_en) ? DOUBLE :
	     (proc2Dmem_command == BUS_NONE) ? DOUBLE : ex_mem_size;
	`endif
	assign proc2mem_data = wr_data;
	assign store_t = (switch) ? alt_tag : store_rs2_tag;

	always_comb begin
		case(`WIDTH)
			1: begin
				predict = ~mismatch;
				taken 	= temp_taken; 
			end
			2: begin
				predict = (mismatch==2'b00) ? 1 : 0;
				taken	= (temp_taken==2'b00) ? 0 : 1; 	 
			end
		endcase
	end
	

//////////////////////////////////////////////////
//                                              //
//                  i cache                     //
//                                              //
//////////////////////////////////////////////////

	cache icache_mem(
		.clock(clock),
		.reset(reset),
		.wr1_en(i_cache_data_write_en),
		.wr1_idx(icache_wr_idx),
		.rd1_idx(icache_rd_idx),
		.wr1_tag(icache_wr_tag),
		.rd1_tag(icache_rd_tag),
		.wr1_data(mem2proc_data),
		.rd1_data(icache_rd_data),
		.rd1_valid(i_cache_data_read_valid)

		/*//ports to vc
		.vc_en(vc_en),   
		.swap_en(swap_en),
		.vc_idx(vc_idx),  
		.swap_idx(swap_idx),
		.vc_tag(vc_tag),  
		.swap_tag(swap_tag),
		.vc_write(vc_write), 
		.swap_data(swap_data), 
        .vc_data(vc_data),
        .vc_valid(vc_valid)*/
	
	);


//////////////////////////////////////////////////
//                                              //
//                victim cache                  //
//                                              //
//////////////////////////////////////////////////

	/*victimcache vc0(
		.clock(clock),
		.reset(reset), 
		.wr_en(vc_en),  
		.swap_en(swap_en),
		.wr_idx(vc_idx), 
		.swap_idx(swap_idx),
		.wr_tag(vc_tag), 
		.swap_tag(swap_tag),
		.data(vc_write),  
		.swap_data(swap_data), 
        .rd_data(vc_data),
        .rd_valid(vc_valid)
	);*/

//////////////////////////////////////////////////
//                                              //
//            i cache controller                //
//                                              //
//////////////////////////////////////////////////

	icache icache_control(
		.clock(clock),
		.reset(reset),
		.Imem2proc_response(mem2proc_response),
		.Imem2proc_data(mem2proc_data),
		.Imem2proc_tag(mem2proc_tag),
		.hazard(hazard),

		.haz_enable(h_able),

		.proc2Icache_addr(proc2Icache_addr),
		.cachemem_data(icache_rd_data),
		.cachemem_valid(i_cache_data_read_valid),

		.proc2Imem_command(proc2Imem_command),
		.proc2Imem_addr(proc2Imem_addr),

		.Icache_data_out(Icache_data_out), // value is memory[proc2Icache_addr]
		.Icache_valid_out(Icache_valid_out),      // when this is high

		.current_index(icache_rd_idx),
		.current_tag(icache_rd_tag),
		.last_index(icache_wr_idx),
		.last_tag(icache_wr_tag),
		.data_write_enable(i_cache_data_write_en)
	
	);
	

//////////////////////////////////////////////////
//                                              //
//                  Branch Predictor            //
//                                              //
//////////////////////////////////////////////////

	bimod_pred predictor(
		.clock(clock),
		.reset(reset),
		//input
		.taken(predict),
		.enable(taken),
		//output
		.state(state),
		.prediction()
	);
	
//////////////////////////////////////////////////
//                                              //
//               Branch Target Buffer           //
//                                              //
//////////////////////////////////////////////////

	BTB btb(
		.clock(clock),
		.reset(reset),
		//inputs
		.curr_state(state),
		.PC(PC2btb),
		.is_branch(is_branch),
		.is_jump(is_jump),
		.EX_TARGET(EX_TARGET),
		.EX_PC(EX_PC),
		.EX_tag(EX_tag),
		.take_branch(take_branch),
		.rollback(rollback),
		.rollback_PC(rollback_pc),
		.ROLLBACK_TARGET(exception_pc),
		//outputs
		.T_PC(T_PC),
		.hit(hit),
		.ROB_tag(mism_tag),
		.mismatch(mismatch)
	);


//////////////////////////////////////////////////
//                                              //
//                     RAS                      //
//                                              //
//////////////////////////////////////////////////

	ras ras1(
		.clock(clock),
		.reset(reset),
		.is_jump(is_jump),
		.if_packet(if_packet),
		.rollback_en(rollback),
		.return_addr(return_addr),
		.valid_ret_addr(ret_valid)

	);

//////////////////////////////////////////////////
//                                              //
//                  IF-Stage                    //
//                                              //
//////////////////////////////////////////////////

	//these are debug signals that are now included in the packet,
	//breaking them out to support the legacy debug modes
	always_comb begin
		for(int i=0;i<`WIDTH;i++)begin
			if_NPC_out[i]        = if_packet[i].NPC;
			if_IR_out[i]         = if_packet[i].inst;
			if_valid_inst_out[i] = if_packet[i].valid;
		end
	end
	
	if_stage if_stage_0 (
		// Inputs
		.clock (clock),
		.reset (reset),
		.hit(hit),
		.T_PC(T_PC),
		.haz_enable(h_able),
		.rollback(rollback),
		.exception_pc(exception_pc),
		.Imem2proc_data(Icache_data_out),
		.Imem2proc_valid(Icache_valid_out),
		.rs_rob_hazard(SH_RS | rob_hazard),
		.return_addr(return_addr),
		.ret_valid(ret_valid),
		
		// Outputs
		.proc2Imem_addr(proc2Icache_addr),
		.if_packet_out(if_packet),
		.is_branch(is_branch),
		.is_jump(is_jump),
		.PC2btb(PC2btb)

	);

//////////////////////////////////////////////////
//                                              //
//            IF/ID Pipeline Register           //
//                                              //
//////////////////////////////////////////////////

// synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if (reset) begin 
			if_id_packet  <= 0;
		end else  begin// if (reset)
			for(int i=0;i<`WIDTH;i++)begin
				if((SH_RS[i]|rob_hazard[i]) == 0)
					if_id_packet[i] <= (rollback) ? 0 : if_packet[i];
				else begin
					if(rollback)
						if_id_packet[i] <= 0;
				end
			end
		end
	end // always



//////////////////////////////////////////////////
//                                              //
//                 DISPATCH                     //
//                                              //
//////////////////////////////////////////////////

	ss_dispatch disp0(
		.clock(clock),
		.reset(reset),

		//inputs
		.if_id_packet_in(if_id_packet),
		.ROB_hazard(rob_hazard),
		.RS_hazard(SH_RS),

		//outputs
		.disp_packet_out(disp_packet),
		.dispatch_en(dispatch_en),
		.is_store(is_store),
		.is_load(is_load),
		.disp_mem_size(disp_mem_size)
	);


//////////////////////////////////////////////////
//                                              //
//                  RS                          //
//                                              //
//////////////////////////////////////////////////


	rs rs0(
			//inputs
			.reset(reset),
			.clock(clock),
			.rollback_en(rollback),
			.id_packet(disp_packet),  		 //to come from decoder
			.write_true(dispatch_en), 		 //from decoder
			.PA_ready(PA_ready), //from maptable
			.PB_ready(PB_ready), //from maptable
			.PA(PA),			 //from maptable
			.PB(PB),		 	 //from maptable	
			.free_register(free_preg),
			.cdb(cdb),
			.delete_confirm(delete_confirm),	 //from issue stage
			.ld_in_ex(cache_enable),
			
			//outputs
			.load_PC(load_PC),
			.load_issue_PC(load_issue_PC),
			.load_issue(load_issue), 
			.load_issue_permit(load_issue_permit),
			.regA(regA),	//operand A address to Maptable
			.regB(regB), 	//operand B address to Maptable
			.issue_packet(issue_packet), 	//The RS entry going to be issued and then deleted
			.full(SH_RS)		// RS facing a structural hazard
		);

//////////////////////////////////////////////////
//                                              //
//                   rob                        //
//                                              //
//////////////////////////////////////////////////

	ss_rob robss(
		.clk(clock),
		.reset(reset),
		//inputs
		.dispatch_en(dispatch_en),
		.packet(disp_packet),
		.tag_old(prev_T),
		.free_reg(free_preg),
		.retire_en(inst_retire),
		.cdb(cdb),
		.mismatch_en(mismatch),
		.mismatch_tag(mism_tag),
		.alu_result(rob_result),
		//outputs
		.exception_pc(exception_pc),
		.dest_reg(dest_rob),
		.rob_hazard(rob_hazard),
		.ready_to_retire(rtr),
		.retire_entry(retire_entry),
		.rollback(rollback),
		.rewind_head(rewind_head),
		.rollback_pc(rollback_pc)
	);


//////////////////////////////////////////////////
//                                              //
//                  maptable                    //
//                                              //
//////////////////////////////////////////////////
	
	ss_maptable mt_ss(
		.reset(reset),
		.clock(clock),
		.dest_rob(dest_rob),
		.rollback_en(rollback),
		.regA(regA),
		.regB(regB),
		.dispatch_en(dispatch_en),
		.cdb(cdb),
		.free_register(free_preg),
		.rrat_table(rrtable),
		//outputs
		.prev_T(prev_T),		//to ROB
		.PA(PA),				//to RS and ROB
		.PB(PB),				//to RS and ROB
		.PA_ready(PA_ready),	//to RS and ROB
		.PB_ready(PB_ready)		//to RS and ROB
	);


//////////////////////////////////////////////////
//                                              //
//                  Archi map                   //
//                                              //
//////////////////////////////////////////////////
	
	ss_RRAT ssrrat0(
		.clock(clock),
		.reset(reset),
		.retire_dest(retire_reg),
		.retire_en(inst_retire),
		.P_value(RRAT_newpreg),
		.store_rs2(st_rs2),
		//outputs
		.store_rs2_tag(store_rs2_tag),
		.rrat_table(rrtable)
	);


//////////////////////////////////////////////////
//                                              //
//             physical register file           //
//                                              //
//////////////////////////////////////////////////

	ss_physical_reg_file prf0(
		//inputs
		.reset(reset),
		.clock(clock),
		.PA(operandA),				//from issue stage to execute
		.PB(operandB),				//from issue stage to execute
		.cdb(cdb),					//coming from complete stage
		.ALU_RESULT(alu_result),	//coming from complete stage
		.tb_reg(tb_reg),
    	.store_tag(store_tag),
		.retire_tag(RRAT_newpreg),
		.store_rs2_tag(store_t),
		//outputs
		.store_data(store_data),
		.PA_value(valueA),			//going to execute 
		.PB_value(valueB), 			//same
		.tb_value(tb_data), 
		.store_tag_value(store_tag_value),
		.retire_value(retire_data)
		
	);

//////////////////////////////////////////////////
//                                              //
//                  freelist                    //
//                                              //
//////////////////////////////////////////////////
	
	//superscalar
	ss_freelist fl1(
		//inputs
		.reset(reset),
		.clock(clock),
		.rollback_en(rollback),
		.rewind_head(rewind_head),
		.dispatch_en(dispatch_en),						//Combined from RS and ROB	
		.retire_en(inst_retire),				//from retire
		.retire_reg(new_free_preg),	//from retire

		//outputsex_mem_packet
		.free_reg(free_preg)		//to ROB, RS and Maptable
	);


//////////////////////////////////////////////////
//                                              //
//                   issue _stage               //
//                                              //
//////////////////////////////////////////////////

	ss_issue i0(
		.clock(clock),
		.reset(reset),
		.rollback_en(rollback),
		.issue_packet(issue_packet),
		.stall_ALU(stall_ALU),
		.ld_in_ex(tload_present),
		.data_input((st_value_valid!=2'b00|Dcache_valid_out) && !load_stall), // && !load_stall),
		//.load_stall(load_stall),
		.FU_unit_ALU(FU_unit_ALU),
		.FU_unit_mul(FU_unit_mul),
		.ex_packet(issue_ex_packet),
		.delete_confirm(delete_confirm)
	
	);

//////////////////////////////////////////////////
//                                              //
//                  EX_STAGE                    //
//                                              //
//////////////////////////////////////////////////

	SS_Ex_stage ex_out(
	.clock(clock),
	.reset(reset),
	.rollback(rollback),
	.mem_data(Dcache_data_out[`XLEN-1:0]),
	.mem_data_valid(Dcache_valid_out),
	.FU_unit_ALU(FU_unit_ALU),
	.FU_unit_mul(FU_unit_mul),
	.ex_packet(issue_ex_packet),
	.PA_value(valueA),
	.PB_value(valueB),
	.st_value(st_value),
	.st_value_valid(st_value_valid),
	////from retire stage
	.retire_store(store),
	.retire_store_address(wr_addr),
	.retire_store_size(st_mem_size),
	//outputs
	.PA(operandA),
	.PB(operandB),
	.complete_packet(complete_packet),
	.execution_done(execution_done),
	.ALU_stall(stall_ALU),
	.temp_taken(temp_taken),
	.take_branch(take_branch),
	.PC(EX_PC),
	.tag(EX_tag),
	.target(EX_TARGET),
	.proc2dcache_command(sproc2dmem_cmd),
	.load_present(cache_enable),
	.proc2dcache_addr(sproc2Dmem_addr),
	.result_store(result_store), 
	.ex_addr(ex_addr),
	.mem_size(ex_mem_size),
	.ex_st_PC(ex_st_PC), //////////////////////to match the PC from the quueue
	.is_ex_load(is_ex_load),   ///If instruction is load 
	.rob_result(rob_result),
	.load_stall(load_stall),
	.tload_present(tload_present)

	);


//////////////////////////////////////////////////
//                                              //
//                  complete-Stage              //
//                                              //
//////////////////////////////////////////////////

	ss_complete c0(
		//inputs
		.clock(clock),
		.reset(reset),
		.rollback_en(rollback),
		.ex_complete_packet(complete_packet),
		.execution_complete(execution_done),
		//outputs
		.cdb(cdb),
		.result(alu_result)
	);


//////////////////////////////////////////////////
//                                              //
//                  retire                      //
//                                              //
//////////////////////////////////////////////////

	ss_retire r0(
		//inputs
		.reset(reset),
		.clock(clock),
		.rtr(rtr),		//from ROB
		.ROB(retire_entry),
		.store_addr(store_tag_value),
		.store_data(store_data),
		.write_enable(write_enable),
		.data_mem(cachemem_data),

		//outputs
		.pregold(new_free_preg),	//to the freelist
		//output to the dcache
    	.data(wr_data),
		.data_write(wr_en),
		.is_store(store),
    	//output to memory
		.store_address(wr_addr),
		.mem_size(st_mem_size),
		//somewhere else
		.store_tag(store_tag),
		.store_rs2(st_rs2),
		.inst_retire(inst_retire),
		.preg(RRAT_newpreg),		//to the RRAT
		.dest_reg(retire_reg),		//to the regfile
		.halt(halt),
		.alt_tag(alt_tag),
		.switch(switch),
		.retire_load(retire_load)
	);


//////////////////////////////////////////////////
//                                              //
//            D-CACHE Controller                //
//                                              //
//////////////////////////////////////////////////

	dcache_control dcache_control(
		.clock(clock),
		.reset(reset),

		//inputs from retire
		.st_addr(wr_addr),
		.st_en(store),
		.st_data(wr_data),
		.st_mem_size(st_mem_size),
		.ex_mem_size(ex_mem_size),

		//inputs from ex
		.sproc2Dcache_addr(sproc2Dmem_addr),
		.cache_enable(cache_enable & !rollback),
		.ldproc2Dmem_command(sproc2dmem_cmd),

		.Dmem2proc_response(mem2proc_response),
		.Dmem2proc_data(mem2proc_data),
		.Dmem2proc_tag(mem2proc_tag),
	
		.cachemem_data(cachemem_data),
		.cachemem_valid(cachemem_valid),
		//outputs
		.proc2Dmem_command(proc2Dmem_command),
		.proc2Dmem_addr(proc2Dmem_addr),
	
		.Dcache_data_out(Dcache_data_out), 
		.Dcache_valid_out(Dcache_valid_out),      
	
		.current_index(current_index),
		.current_tag(current_tag),
		.last_index(last_index),
		.last_tag(last_tag),
		.data_write_enable(data_write_enable),
		.rd_size(rd_size),

		//output to retire
		.write_enable(write_enable)
	  
	  );

//////////////////////////////////////////////////
//                                              //
//                  D-CACHE                     //
//                                              //
//////////////////////////////////////////////////

	dcache_mem dcache_mem(
		.clock(clock), 
		.reset(reset), 
		//inputs from retire
		.st_addr(wr_addr),
		.st_wr_en(wr_en),
		.st_wr_data(wr_data),
		.wr1_en(data_write_enable),
		.wr1_idx(last_index), 
		.rd1_idx(current_index),
		.wr1_tag(last_tag), 
		.rd1_tag(current_tag),
		.wr1_data(mem2proc_data),
		//outputs
    	.rd1_data(cachemem_data),
    	.rd1_valid(cachemem_valid)
        
		);

//////////////////////////////////////////////////
//                                              //
//                 REGFILE                      //
//                                              //
//////////////////////////////////////////////////

	ss_regfile rf(
		//inputs
		.wr_clk(clock),
		.wr_idx(retire_reg),    // read/write index
		.wr_data(retire_data),            // write data
		.wr_en(inst_retire)
	);

//////////////////////////////////////////////////
//                                              //
//              LOAD STORE QUEUE                //
//                                              //
//////////////////////////////////////////////////

	store_queue sq0(
		.clock(clock),
		.reset(reset),
		.rollback(rollback),
										
		//Input from Dispatch
		.tags(free_preg),
		.is_store(is_store),  ///If instruction is store
		.is_load(is_load),   ///If instruction is load 
		.mem_size(disp_mem_size),

		//inputs from complete stage
		.cdb(cdb),

		////////////input from execute stage/////////////
		///////this is the value that has to be stored at the memory location///////////////////
		.result(result_store), 

		//inputs from RS
		.load_tags(load_PC),
		.load_issue(load_issue), 

		/////input from execute 
		.ex_addr(ex_addr),
		.ex_st_tags(ex_st_PC), //////////////////////to match the PC from the quueue
		.mem_size_ex_stage(ex_mem_size),
		.is_ex_load(is_ex_load),   ///If instruction is load 
		.retire_en(inst_retire),
		.retire_tag(RRAT_newpreg),
		///////output to execute stage 
		.st_value_valid(st_value_valid),
		.st_value(st_value),

		//outputs to RS
		.load_issue_PC(load_issue_PC),
		.load_issue_permit(load_issue_permit),

		.retire_load(retire_load)
	);

endmodule  // module verisimple
`endif // __PIPELINE_V__
