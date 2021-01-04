/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  if_stage.v                                          //
//                                                                     //
//  Description :  instruction fetch (IF) stage of the pipeline;       // 
//                 fetch instruction, compute next PC location, and    //
//                 send them down the pipeline.                        //
//                                                                     //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

module if_stage(
	input       clock,                  // system clock
	input       reset,                  // system reset
     // only go to next instruction when true
	                                      // makes pipeline behave as single-cycle
	input  logic [63:0] Imem2proc_data,          // Data coming back from instruction-memory
	input  logic Imem2proc_valid,          // Data coming back from instruction-memory
	input  [`WIDTH-1:0] rs_rob_hazard,

	//input from ras
	input logic [`WIDTH-1:0] [`XLEN-1:0] return_addr,
	input logic [`WIDTH-1:0] ret_valid,
	input logic  haz_enable,
	//////input from the branch predictor if a branch instruction comes
	input logic [`WIDTH-1:0][31:0] T_PC,
	input logic [`WIDTH-1:0]hit,
	input logic rollback,
	input logic [`XLEN-1:0]exception_pc,

	output logic [63:0] proc2Imem_addr, //output logic [`XLEN-1:0] proc2Imem_addr,    // Address sent to Instruction memory
	output IF_ID_PACKET [`WIDTH-1:0] if_packet_out,         // Output data packet from IF going to ID, see sys_defs for signal information 
	output logic [`WIDTH-1:0]is_branch,
	output logic [`WIDTH-1:0]is_jump,
	output logic [`WIDTH-1:0][`XLEN-1:0] PC2btb

);


	logic    [`XLEN-1:0] PC_reg;             // PC we are currently fetching
	
	logic    [`XLEN-1:0] PC_plus_2width;
	logic    [`XLEN-1:0] next_PC;
	logic           PC_enable, done;
	logic ret_val;
	logic [`XLEN-1:0] ret_add;

	assign proc2Imem_addr = {PC_reg[`XLEN-1:3], 3'b0};
	

	always_comb begin
		for(int s=0;s<`WIDTH;s++)begin
			PC2btb[s]= if_packet_out[s].PC;
		end
	end

	always_comb begin 
		if(PC_reg[2]==1)begin
			if_packet_out[0].inst = Imem2proc_data[31:0] ;
			if_packet_out[0].valid = 1'b0;
			if_packet_out[1].inst = Imem2proc_data[63:32];
			if_packet_out[1].valid = PC_enable;
		end
		else begin
			if_packet_out[0].inst = Imem2proc_data[31:0];
			if_packet_out[0].valid = PC_enable;
			if((T_PC[0]==PC_reg+8) && (is_jump[0]||is_branch[0]) )begin
				if_packet_out[1].inst = Imem2proc_data[63:32];
				if_packet_out[1].valid = PC_enable;
			end
			else if ((is_jump[0]||is_branch[0]||rollback))begin
				if_packet_out[1].inst = Imem2proc_data[63:32];
				if_packet_out[1].valid = 1'b0;
			end
			else begin
				if_packet_out[1].inst = Imem2proc_data[63:32];
				if_packet_out[1].valid = PC_enable;
			end
		end
	end


	always_comb begin 
		is_jump   = 0 ;
		is_branch = 0 ;
		ret_val	=	0;
		ret_add	=	0;
		case(Imem2proc_data[6:0])
			`RV32_JALR_OP,`RV32_JAL_OP :  is_jump[0]   = PC_enable ;
			`RV32_BRANCH	           :  is_branch[0] = PC_enable ;
		endcase
		case(Imem2proc_data[38:32])
			`RV32_JALR_OP,`RV32_JAL_OP : 	is_jump[1]   = PC_enable ;	
			`RV32_BRANCH		 : 			is_branch[1] = PC_enable ;
		endcase

		for(int i=0; i<`WIDTH; i++) begin
			if(!ret_val) begin
				ret_val	=	is_jump[i];
				ret_add	=	return_addr[i];
			end
		end

	end

	
	// next PC is target_pc if there is a taken branch or
	// the next sequential PC (PC+4) if no branch
	// (halting is handled with the enable PC_enable;
	assign next_PC = (rollback)? exception_pc :
				//(ret_val) ? ret_add :
				(hit ==2'b01)? T_PC[0] :
				(hit == 2'b10 )? T_PC[1]:
				(hit ==2'b11)?((T_PC[0]== PC_reg+8)?T_PC[1]:T_PC[0]):PC_plus_2width;

	
	// The take-branch signal must override stalling (otherwise it may be lost)
	assign PC_plus_2width = (PC_reg[2])?PC_reg+ 4 : PC_reg + 8;
	assign PC_enable = ((Imem2proc_valid | rollback)&&(rs_rob_hazard==0))? 1'b1 : 1'b0;	
	// Pass PC+4 down pipeline w/instruction
//	assign if_packet_out.NPC = PC_plus_2width;
//	assign if_packet_out.PC  = PC_reg;
	// This register holds the PC value
	// synopsys sync_set_reset "reset"
	always_ff @(posedge clock) begin
		if(reset)
			PC_reg <= 0;       // initial PC value is 0
		else if((PC_enable|rollback))
			PC_reg <= next_PC; // transition to next PC
	end  // always

//	assign if_packet_out.valid = PC_enable ;
	always_comb begin
		done=0;
		for(int j=0;j<`WIDTH;j++)begin	
			if(if_packet_out[j].valid) begin
				if_packet_out[j].PC  = (!done)? PC_reg + 4*j : PC_reg;
			end
			else begin
				if_packet_out[j].PC  =  PC_reg + 4*j;
				done =1;
			end 
			if_packet_out[j].NPC   = PC_plus_2width - 4*(`WIDTH-1-j);
			//if_packet_out[j].valid = PC_enable ;
		end
	end

endmodule  // module if_stage
