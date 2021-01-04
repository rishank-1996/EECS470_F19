/////////////////////////////////////////////////////////////////////////////////////////////
// Dispatch stage:                                                                         //
// Decodes the incoming instruction from Fetch stage                                       //
// Checks for structural hazard in RS and ROB.                                             //
// Allocates entry in RS and ROB if no strcutral hazard.                                   //
/////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/100ps


  // Decode an instruction: given instruction bits IR produce the
  // appropriate datapath control signals.
  //
  // This is a *combinational* module (basically a PLA).
  //
module decoder2(

	//input [31:0] inst,
	//input valid_inst_in,  // ignore inst when low, outputs will
	                      // reflect noop (except valid_inst)
	//see sys_defs.svh for definition
	input IF_ID_PACKET if_packet,
	
	output ALU_OPA_SELECT opa_select,
	output ALU_OPB_SELECT opb_select,
	output DEST_REG_SEL   dest_reg, // mux selects
	output ALU_FUNC       alu_func,
	output logic rd_mem, wr_mem, cond_branch, uncond_branch,
	output logic csr_op,    // used for CSR operations, we only used this as 
	                        //a cheap way to get the return code out
	output logic halt,      // non-zero on a halt
	output logic illegal,    // non-zero on an illegal instruction
	output logic valid_inst  // for counting valid instructions executed
	                        // and for making the fetch stage die on halts/
	                        // keeping track of when to allow the next
	                        // instruction out of fetch
	                        // 0 for HALT and illegal instructions (die on halt)

);

	INST inst;
	logic valid_inst_in;
	
	assign inst          = if_packet.inst;
	assign valid_inst_in = if_packet.valid;
	assign valid_inst    = valid_inst_in;
	
	always_comb begin
		// default control values:
		// - valid instructions must override these defaults as necessary.
		//	 opa_select, opb_select, and alu_func should be set explicitly.
		// - invalid instructions should clear valid_inst.
		// - These defaults are equivalent to a noop
		// * see sys_defs.vh for the constants used here
		opa_select = OPA_IS_RS1;
		opb_select = OPB_IS_RS2;
		alu_func = ALU_ADD;
		dest_reg = DEST_NONE;
		csr_op = `FALSE;
		rd_mem = `FALSE;
		wr_mem = `FALSE;
		cond_branch = `FALSE;
		uncond_branch = `FALSE;
		halt = `FALSE;
		illegal = `FALSE;
		if(valid_inst_in) begin
			casez (inst) 
				`RV32_LUI: begin
					dest_reg   = DEST_RD;
					opa_select = OPA_IS_ZERO;
					opb_select = OPB_IS_U_IMM;
				end
				`RV32_AUIPC: begin
					dest_reg   = DEST_RD;
					opa_select = OPA_IS_PC;
					opb_select = OPB_IS_U_IMM;
				end
				`RV32_JAL: begin
					dest_reg      = DEST_RD;
					opa_select    = OPA_IS_PC;
					opb_select    = OPB_IS_J_IMM;
					uncond_branch = `TRUE;
				end
				`RV32_JALR: begin
					dest_reg      = DEST_RD;
					opa_select    = OPA_IS_RS1;
					opb_select    = OPB_IS_I_IMM;
					uncond_branch = `TRUE;
				end
				`RV32_BEQ, `RV32_BNE, `RV32_BLT, `RV32_BGE,
				`RV32_BLTU, `RV32_BGEU: begin
					opa_select  = OPA_IS_PC;
					opb_select  = OPB_IS_B_IMM;
					cond_branch = `TRUE;
				end
				`RV32_LB, `RV32_LH, `RV32_LW,
				`RV32_LBU, `RV32_LHU: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					rd_mem     = `TRUE;
				end
				`RV32_SB, `RV32_SH, `RV32_SW: begin
					opb_select = OPB_IS_S_IMM;
					wr_mem     = `TRUE;
				end
				`RV32_ADDI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
				end
				`RV32_SLTI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SLT;
				end
				`RV32_SLTIU: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SLTU;
				end
				`RV32_ANDI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_AND;
				end
				`RV32_ORI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_OR;
				end
				`RV32_XORI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_XOR;
				end
				`RV32_SLLI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SLL;
				end
				`RV32_SRLI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SRL;
				end
				`RV32_SRAI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
					alu_func   = ALU_SRA;
				end
				`RV32_ADD: begin
					dest_reg   = DEST_RD;
				end
				`RV32_SUB: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SUB;
				end
				`RV32_SLT: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SLT;
				end
				`RV32_SLTU: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SLTU;
				end
				`RV32_AND: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_AND;
				end
				`RV32_OR: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_OR;
				end
				`RV32_XOR: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_XOR;
				end
				`RV32_SLL: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SLL;
				end
				`RV32_SRL: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SRL;
				end
				`RV32_SRA: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_SRA;
				end
				`RV32_MUL: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MUL;
				end
				`RV32_MULH: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MULH;
				end
				`RV32_MULHSU: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MULHSU;
				end
				`RV32_MULHU: begin
					dest_reg   = DEST_RD;
					alu_func   = ALU_MULHU;
				end
				`RV32_CSRRW, `RV32_CSRRS, `RV32_CSRRC: begin
					csr_op = `TRUE;
				end
				`WFI: begin
					halt = `TRUE;
				end
				default: illegal = `TRUE;

		endcase // casez (inst)
		end // if(valid_inst_in)
	end // always
endmodule // decoder



module ss_dispatch( 
		input	         	  clock,               // system clock
		input         	 	reset,               // system reset

		input  IF_ID_PACKET  [`WIDTH-1:0] if_id_packet_in,
    input  logic [`WIDTH-1:0]				ROB_hazard,   //rob_hazard output logic in rob module instantiated pipeline.sv
    input  logic [`WIDTH-1:0]				RS_hazard,    // full output logic in rs module instantiated in pipeline.sv
	
		output ID_DISP_PACKET [`WIDTH-1:0] disp_packet_out,
    output logic [`WIDTH-1:0] dispatch_en,
    output logic [`WIDTH-1:0] is_store,
		output logic [`WIDTH-1:0] is_load,
		output MEM_SIZE [`WIDTH-1:0] disp_mem_size

);

DEST_REG_SEL [`WIDTH-1:0] dest_reg_select;
logic [`WIDTH-1:0] valid_inst;

	////////////////////Add logic for SH handling on ROB and RS////////// 
	//assign dispatch_en = ~(ROB_hazard | RS_hazard);

always_comb begin
	for(int j=0; j<`WIDTH; j++) begin
		disp_packet_out[j].inst = if_id_packet_in[j].inst; 
		disp_packet_out[j].NPC = if_id_packet_in[j].NPC;
		disp_packet_out[j].PC = if_id_packet_in[j].PC;
		disp_packet_out[j].valid = dispatch_en[j];
		
		case (dest_reg_select[j])
			DEST_RD:    disp_packet_out[j].dest_reg_idx = if_id_packet_in[j].inst.r.rd;
			DEST_NONE:  disp_packet_out[j].dest_reg_idx = `ZERO_REG;
			default:    disp_packet_out[j].dest_reg_idx = `ZERO_REG; 
		endcase
	end
end

	genvar i;
	generate	
		for(i=0; i<`WIDTH; i++) begin: generate_block1
			
			decoder2 decoder (
			.if_packet(if_id_packet_in[i]),	 
			// Outputs
			.opa_select(disp_packet_out[i].opa_select),
			.opb_select(disp_packet_out[i].opb_select),
			.alu_func(disp_packet_out[i].alu_func),
			.dest_reg(dest_reg_select[i]),
			.rd_mem(disp_packet_out[i].rd_mem),
			.wr_mem(disp_packet_out[i].wr_mem),
			.cond_branch(disp_packet_out[i].cond_branch),
			.uncond_branch(disp_packet_out[i].uncond_branch),
			.csr_op(disp_packet_out[i].csr_op),
			.halt(disp_packet_out[i].halt),
			.illegal(),
			.valid_inst(valid_inst[i])
			);
		end
	endgenerate

	always_comb begin
		for(int y=0; y<`WIDTH; y++) begin
			dispatch_en[y] = valid_inst[y] & ~(ROB_hazard[y]|RS_hazard[y]);
			is_store[y] = dispatch_en[y] & disp_packet_out[y].wr_mem ;
			is_load[y]  =  dispatch_en[y] &   disp_packet_out[y].rd_mem ;
			disp_mem_size[y] = disp_packet_out[y].inst.r.funct3;
		end
	end


	// mux to generate dest_reg_idx based on
	// the dest_reg_select output from decoder

endmodule
