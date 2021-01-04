`timescale 1ns/100ps
`define DEPTH 4

/////////////////////////ALU UNIT/////////////////////////
module alu (
    input logic FU_unit,
    input   [`XLEN-1:0]regA,
    input   [`XLEN-1:0]regB,
    input ALU_FUNC func,
    output logic [`XLEN-1:0] result,
    output logic    done 
);
    wire signed [`XLEN-1:0] opA, opB;
    assign opA = regA;
	assign opB = regB;
    assign done = FU_unit;
    always_comb begin
        result = 0;
        if(FU_unit) begin
            case (func)
                ALU_ADD            : result = regA + regB;
                ALU_SUB            : result = regA - regB;
                ALU_AND            : result = regA & regB;
                ALU_SLT            : result = opA  < opB;
                ALU_SLTU           : result = regA < regB;
                ALU_OR             : result = regA | regB;
                ALU_XOR            : result = regA ^ regB;
                ALU_SRL            : result = regA >> regB[4:0];
                ALU_SLL            : result = regA << regB[4:0];
                ALU_SRA            : result = opA >>> regB[4:0];
            endcase 
        end
    end
endmodule 

///////////////////////////////////////BRANCH UNIT///////////////////
module brcond(// Inputs
    input logic FU_unit,
	input [`XLEN-1:0] rs1,    
	input [`XLEN-1:0] rs2,
	input  [2:0] func,  // Specifies which condition to check

	output logic cond    
);

	logic signed [`XLEN-1:0] signed_rs1, signed_rs2;
	assign signed_rs1 = rs1;
	assign signed_rs2 = rs2;
	always_comb begin
        cond = 0;
        if(FU_unit) begin
            case (func)
                3'b000: cond = signed_rs1 == signed_rs2;  // BEQ
                3'b001: cond = signed_rs1 != signed_rs2;  // BNE
                3'b100: cond = signed_rs1 < signed_rs2;   // BLT
                3'b101: cond = signed_rs1 >= signed_rs2;  // BGE
                3'b110: cond = rs1 < rs2;                 // BLTU
                3'b111: cond = rs1 >= rs2;                // BGEU
            endcase
        end
	end
endmodule 

////////////////////////////////////////////MUL UNIT-1//////////////////////////////
module mult_stage (
    input clock,
    input reset,
    input start,
    input logic [4:0] func_in,
    output logic [4:0] func_out,
    input [63:0]product_in, mplier_in, mcand_in,
    input  logic [$clog2(`PRF_SIZE)-1:0] tag_in,
    output logic [$clog2(`PRF_SIZE)-1:0] tag_out,
    output logic done,
    output logic [63:0] product_out, mplier_out, mcand_out
);
    
    logic [63:0] prod_in_reg, partial_prod_reg;
    logic [63:0] partial_product, next_mplier, next_mcand;

    assign product_out = prod_in_reg + partial_prod_reg;
    assign partial_product = mplier_in[(64/`DEPTH -1):0] * mcand_in;

    assign next_mplier = mplier_in >>(64/`DEPTH);
    assign next_mcand  = mcand_in <<(64/`DEPTH);

    //synopsys sync_set_reset "reset"
    always_ff @(posedge clock) begin
        prod_in_reg      <= #1 product_in;
        partial_prod_reg <= #1 partial_product;
        mplier_out       <= #1 next_mplier;
        mcand_out        <= #1 next_mcand;
    end

    // synopsys sync_set_reset "reset"
    always_ff @(posedge clock) begin
        if(reset) begin
            done <=  1'b0;
            tag_out <= 6'b0;
            func_out <= 0;
        end
        else begin
            done <= start;
            tag_out <= tag_in;
            func_out <= func_in;
        end
    end

endmodule

////////////////////////////////////////////MUL UNIT-1//////////////////////////////
module mul1 (
    input clock,
    input reset,
    input logic FU_unit,
    input [`XLEN-1:0]regA,
    input [`XLEN-1:0]regB,
    input ALU_FUNC func,
    input logic rollback,
    input logic [$clog2(`PRF_SIZE)-1:0] tag_in,
    output logic [`XLEN-1:0]result,
    output logic [$clog2(`PRF_SIZE)-1:0] tag_out,
    output done
);
    logic start;
    logic changed_tag;
    logic [4:0] func_out;
    logic [5:0] tag_old;
    wire [63:0] result1;
    assign changed_tag = (tag_old != tag_in);
    assign start  = ((changed_tag||(tag_in==`ZERO_PREG|FU_unit)) & (func == ALU_MUL || func == ALU_MULH || func == ALU_MULHSU || func == ALU_MULHU)) ? 1 : 0;
    
    wire [63:0] opA, opB;
    assign opA = (func == ALU_MUL || func == ALU_MULH || func == ALU_MULHSU) ? {{32{regA[31]}},regA}: {{32{1'b0}},regA};  	
	assign opB = (func == ALU_MUL || func == ALU_MULH ) ? {{32{regB[31]}},regB}: {{32{1'b0}},regB} ; 

    logic [63:0] mcand_out, mplier_out;
    logic [((`DEPTH-1)*64)-1 :0] internal_products, internal_mcands, internal_mpliers;
    logic [(`DEPTH-2):0] internal_dones, tinternal_dones; 
    assign tinternal_dones = (rollback) ? 0: internal_dones; 
    logic [17:0] internal_tags;
    logic [14:0] internal_funcs; 
    mult_stage2 mstage2 [3:0](
        .clock(clock),
        .reset(reset),
        .func_in({internal_funcs, func}),
        .func_out({func_out, internal_funcs}),
        .product_in({internal_products,64'h0}),
        .mplier_in({internal_mpliers,opB}),
        .mcand_in({internal_mcands,opA}),
        .start({tinternal_dones,start}),
        .product_out({result1,internal_products}),
        .mplier_out({mplier_out,internal_mpliers}),
        .mcand_out({mcand_out,internal_mcands}),
        .done({done,internal_dones}),
        .tag_in({internal_tags, tag_in}),
        .tag_out({tag_out, internal_tags})
    );

    assign result = ((func_out == ALU_MULH) || (func_out == ALU_MULHSU) || (func_out == ALU_MULHU) ) ? result1[63 : 32 ] : result1 [`XLEN - 1: 0] ;

    always_ff@(posedge clock) begin
        if(reset)
            tag_old <= -1;
        else if(FU_unit) begin
            tag_old <= tag_in;
        end
    end

endmodule

////////////////////////////////////////////MUL UNIT-2//////////////////////////////
module mult_stage2 (
    input clock,
    input reset,
    input start,
    input logic [4:0] func_in,
    output logic [4:0] func_out,
    input [63:0]product_in, mplier_in, mcand_in,
    input  logic [$clog2(`PRF_SIZE)-1:0] tag_in,
    output logic [$clog2(`PRF_SIZE)-1:0] tag_out,
    output logic done,
    output logic [63:0] product_out, mplier_out, mcand_out
);
    
    logic [63:0] prod_in_reg, partial_prod_reg;
    logic [63:0] partial_product, next_mplier, next_mcand;

    assign product_out = prod_in_reg + partial_prod_reg;
    assign partial_product = mplier_in[(64/`DEPTH -1):0] * mcand_in;

    assign next_mplier = mplier_in >>(64/`DEPTH);
    assign next_mcand  = mcand_in <<(64/`DEPTH);

    //synopsys sync_set_reset "reset"
    always_ff @(posedge clock) begin
        prod_in_reg      <= #1 product_in;
        partial_prod_reg <= #1 partial_product;
        mplier_out       <= #1 next_mplier;
        mcand_out        <= #1 next_mcand;
    end

    // synopsys sync_set_reset "reset"
    always_ff @(posedge clock) begin
        if(reset) begin
            done <=  1'b0;
            tag_out <= 6'b0;
            func_out <= 0;
        end
        else begin
            done <= start;
            tag_out <= tag_in;
            func_out <= func_in;
        end
    end

endmodule

////////////////////////////////////////////MUL UNIT-2//////////////////////////////
module mul2 (
    input clock,
    input reset,
    input logic FU_unit,
    input [`XLEN-1:0]regA,
    input [`XLEN-1:0]regB,
    input ALU_FUNC func,
    input logic rollback,
    input logic [$clog2(`PRF_SIZE)-1:0] tag_in,
    output logic [`XLEN-1:0]result,
    output logic [$clog2(`PRF_SIZE)-1:0] tag_out,
    output done
);
    logic start;
    logic changed_tag;
    logic [4:0] func_out;
    logic [5:0] tag_old;
    wire [63:0] result1;
    assign changed_tag = (tag_old != tag_in);
    assign start  = ((changed_tag||(tag_in==`ZERO_PREG|FU_unit)) & (func == ALU_MUL || func == ALU_MULH || func == ALU_MULHSU || func == ALU_MULHU)) ? 1 : 0;
    
    wire [63:0] opA, opB;
    assign opA = (func == ALU_MUL || func == ALU_MULH || func == ALU_MULHSU) ? {{32{regA[31]}},regA}: {{32{1'b0}},regA};  	
	assign opB = (func == ALU_MUL || func == ALU_MULH ) ? {{32{regB[31]}},regB}: {{32{1'b0}},regB} ; 

    logic [63:0] mcand_out, mplier_out;
    logic [((`DEPTH-1)*64)-1 :0] internal_products, internal_mcands, internal_mpliers;
    logic [(`DEPTH-2):0] internal_dones, tinternal_dones; 
    assign tinternal_dones = (rollback) ? 0: internal_dones;
    logic [17:0] internal_tags;
    logic [14:0] internal_funcs; 
    mult_stage2 mstage2 [3:0](
        .clock(clock),
        .reset(reset),
        .func_in({internal_funcs, func}),
        .func_out({func_out, internal_funcs}),
        .product_in({internal_products,64'h0}),
        .mplier_in({internal_mpliers,opB}),
        .mcand_in({internal_mcands,opA}),
        .start({tinternal_dones,start}),
        .product_out({result1,internal_products}),
        .mplier_out({mplier_out,internal_mpliers}),
        .mcand_out({mcand_out,internal_mcands}),
        .done({done,internal_dones}),
        .tag_in({internal_tags, tag_in}),
        .tag_out({tag_out, internal_tags})
    );

    assign result = ((func_out == ALU_MULH) || (func_out == ALU_MULHSU) || (func_out == ALU_MULHU) ) ? result1[63 : 32 ] : result1 [`XLEN - 1: 0] ;

    always_ff@(posedge clock) begin
        if(reset)
            tag_old <= -1;
        else if(FU_unit) begin
                tag_old <= tag_in;
        end
    end
endmodule

////////////////////////////////////////////////////LS UNIT/////////////////////////
module mem_ls(
	input         clock,              
	input         reset,             
	input  ID_DISP_PACKET mem_packet_in,      
    input  [`XLEN-1:0] Dcacheproc_data,
    input [`XLEN-1:0] alu_result,
	
	output logic [`XLEN-1:0] mem_result_out,      
    output logic [1:0] proc2dcache_command,
    output logic [2:0] mem_size,
	output logic [`XLEN-1:0] proc2dcache_addr 
);

    assign mem_size = mem_packet_in.inst.r.funct3;	//only the 2 LSB to determine the size;
	// Determine the command that must be sent to mem
	assign proc2dcache_command =
	                        mem_packet_in.rd_mem  ? BUS_LOAD :
	                        BUS_NONE;

	assign proc2dcache_addr = alu_result;	
	// Assign the result-out for next stage
	always_comb begin
		mem_result_out = alu_result;
		if (mem_packet_in.rd_mem) begin
			if (~mem_size[2]) begin //is this an signed/unsigned load?
				if (mem_size[1:0] == 2'b0)
					mem_result_out = {{(`XLEN-8){Dcacheproc_data[7]}}, Dcacheproc_data[7:0]};
				else if  (mem_size[1:0] == 2'b01) 
					mem_result_out = {{(`XLEN-16){Dcacheproc_data[15]}}, Dcacheproc_data[15:0]};
				else mem_result_out = Dcacheproc_data;
			end else begin
				if (mem_size[1:0] == 2'b0)
					mem_result_out = {{(`XLEN-8){1'b0}}, Dcacheproc_data[7:0]};
				else if  (mem_size[1:0] == 2'b01)
					mem_result_out = {{(`XLEN-16){1'b0}}, Dcacheproc_data[15:0]};
				else mem_result_out = Dcacheproc_data;
			end
		end
	end
	//if we are in 32 bit mode, then we should never load a double word sized data
    //assert property (@(negedge clock) (`XLEN == 32) && mem_packet_in.rd_mem |-> proc2Dmem_size != DOUBLE);
    
endmodule // module lsu


//////////////////////////////////////////MAIN MODULE///////////////////////////////
module SS_Ex_stage(
		input clock,
        input reset,

        //input from rob
        input logic rollback,
        
        //inputs from Issue 
        input [`WIDTH-1:0]FU_unit_ALU,
        input [`WIDTH-1:0]FU_unit_mul,
        input RS_OBJ [`WIDTH-1:0]ex_packet,

		//////////////////from physical register values
		input [`WIDTH-1:0][`XLEN-1:0] PA_value,
		input [`WIDTH-1:0][`XLEN-1:0] PB_value,


        //Output to the Complete stage                
        output EX_COMPLETE [`WIDTH-1:0]complete_packet,
        output logic [`WIDTH-1:0]execution_done, //Execution is done 

        //Output to the Issue stage 
        output logic [`WIDTH-1:0]ALU_stall,   //Stall on the ALU

		///////////////////////output to the physical register file
		output logic[`WIDTH-1:0][$clog2(`PRF_SIZE)-1:0] PA,
        output logic[`WIDTH-1:0][$clog2(`PRF_SIZE)-1:0] PB,


	    //////////////////////input from LSQ///////////////////
	    input logic[`WIDTH-1:0] st_value_valid,
	    input logic[`WIDTH-1:0][31:0] st_value,
     
        ////from retire stage
        input logic retire_store,
        input logic [63:0] retire_store_address,
        input MEM_SIZE retire_store_size,

        //output to predictor
        output logic [`WIDTH-1:0] temp_taken,
        
        //output to the BTB
        output logic [`WIDTH-1:0] take_branch,
        output logic [`WIDTH-1:0] [`XLEN-1:0] PC,
        output logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] tag,
        output logic [`WIDTH-1:0] [`XLEN-1:0] target,

        //output to the rob
        output logic [`WIDTH-1:0][`XLEN-1:0] rob_result,

        //input from the dcache or eventually the memory
        input logic [`XLEN-1:0] mem_data,
        input logic mem_data_valid,

        //outputs to the dCache     // outgoing instruction result (to MEM/WB)
        output logic [1:0] proc2dcache_command,
        output logic load_present,
	    output logic [`XLEN-1:0] proc2dcache_addr,

	    ///////////////////////////////store queue//////
	    output logic [`WIDTH-1 : 0][31:0] ex_addr,
        output logic [`WIDTH-1 : 0][5:0] ex_st_PC, 
        output logic [`WIDTH-1: 0][1:0] is_ex_load,
        output MEM_SIZE mem_size,   
        output logic [`WIDTH-1: 0][31:0] result_store,
        
        //output to issue
        output logic load_stall,
        output logic tload_present
 
    );

    ///////////G5 PATENTED BUFFER//////
    G5_BUFFER [`DC_SIZE-1:0] store_buffer;

    logic [4:0] retire_store_index;
    logic [7:0] retire_store_tag;
    logic [`WIDTH-1:0][`XLEN-1:0] result_mul;
    logic [`WIDTH-1:0][`XLEN-1:0] tresult_add, result_add;
    logic [`WIDTH-1:0] done_mul;
    //Multiplier operation done 
    logic [`WIDTH-1:0] done_alu, done_lsu; //ALU operation done 
    ALU_FUNC [`WIDTH-1:0] func;
    logic [`XLEN-1:0]result_mul2, result_mul1;
    logic done_mul2,done_mul1;
    logic [`WIDTH-1:0][`XLEN-1:0] mem_result_out;
    logic [`WIDTH-1:0][`XLEN-1:0] opa_mux_out, opb_mux_out;
    logic [`WIDTH-1:0]brcond_result, branch;
    logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] tag_out;
    logic [$clog2(`PRF_SIZE)-1:0] tag1, tag2;
    logic ld_location;
    logic [`WIDTH-1:0][`XLEN-1:0] true_PB_value;
    logic [`WIDTH-1:0][`XLEN-1:0] true_PA_value;
    logic [`XLEN-1:0] mux_mem_data;
    logic [`WIDTH-1:0] [2:0] mem_sizes;
    
    logic [`WIDTH-1:0] is_store;
    logic [`WIDTH-1:0] [2:0] store_mem_size;
    logic [`WIDTH-1:0] [$clog2(`DC_SIZE)-1:0] store_index;
    logic [`WIDTH-1:0] [7:0] store_tag;
    logic [$clog2(`DC_SIZE)-1:0] load_idx;
    logic [7:0] load_tag;

    logic [`WIDTH-1:0] [1:0] tempproc_command;
	logic [`WIDTH-1:0][`XLEN-1:0] tempproc_addr;    // Address sent to data-memory
    

    //////////////////ld store address calculation///////////////////////////////
    assign ex_addr = result_add;
    assign rob_result = target;
    assign {retire_store_tag, retire_store_index} = retire_store_address[31:3];
       
    assign result_store = true_PB_value ;

    always_comb begin
        ld_location = 0;
        load_present=0;
        proc2dcache_command = 0;
        proc2dcache_addr = 0;
        mem_size = 0;
        is_store   = 0;
        store_index  = 0;
        store_tag    = 0;
        store_mem_size  = 0;
        load_tag = 0;
        load_idx = 0;
        tload_present = 0;
       //assign result_store = true_PB_value ;
        mux_mem_data = mem_data;
        load_stall = ALU_stall[ld_location] ; //& st_value_valid & !mem_data_valid;

        for(int j=0;j<`WIDTH;j++)begin
            PA[j] = ex_packet[j].T1;
            PB[j] = ex_packet[j].T2;
            func[j] = ex_packet[j].packet.alu_func;
            true_PA_value[j] = (ex_packet[j].packet.inst.r.rs1 == `ZERO_REG) ? 0 : PA_value[j];
            true_PB_value[j] = (ex_packet[j].packet.inst.r.rs2 == `ZERO_REG) ? 0 : PB_value[j];
	        //////////////checking for load or store//////////////
	        is_ex_load[j] = (ex_packet[j].packet.rd_mem)? 2'b01:
			        (ex_packet[j].packet.wr_mem)? 2'b10 : 2'b00 ;	
	
            if(ex_packet[j].packet.rd_mem ) begin
                ld_location         = j;
                tload_present       = 1;
                load_present        = (st_value_valid[j]) ? 0 : 
                    (store_buffer[load_idx].dirty && store_buffer[load_idx].tag == load_tag) ? 0 : 1;
                proc2dcache_command = tempproc_command[j];
                proc2dcache_addr = tempproc_addr[j];
                {load_tag, load_idx} = tempproc_addr[j][31:0];
                mem_size         = mem_sizes[j];
            end
        end 
        //            
        // ALU opA mux
        //
        for(int l=0;l<`WIDTH;l++)begin
            opa_mux_out[l] = `XLEN'hdeadfbac;
            case(ex_packet[l].packet.opa_select) 
                OPA_IS_RS1:  opa_mux_out[l] = true_PA_value[l];
                OPA_IS_NPC:  opa_mux_out[l] = ex_packet[l].packet.NPC;
                OPA_IS_PC:   opa_mux_out[l] = ex_packet[l].packet.PC;
                OPA_IS_ZERO: opa_mux_out[l] = 0;
            endcase             
        end 
        //
        // ALU opB mux
        //
        for(int k=0;k<`WIDTH;k++)begin
            opb_mux_out[k] = `XLEN'hfacefeed;
            case(ex_packet[k].packet.opb_select) 
                OPB_IS_RS2  : opb_mux_out[k] = true_PB_value[k];
                OPB_IS_I_IMM: opb_mux_out[k] = `RV32_signext_Iimm(ex_packet[k].packet.inst);
                OPB_IS_S_IMM: opb_mux_out[k] = `RV32_signext_Simm(ex_packet[k].packet.inst);
                OPB_IS_B_IMM: opb_mux_out[k] = `RV32_signext_Bimm(ex_packet[k].packet.inst);
                OPB_IS_U_IMM: opb_mux_out[k] = `RV32_signext_Uimm(ex_packet[k].packet.inst);
                OPB_IS_J_IMM: opb_mux_out[k] = `RV32_signext_Jimm(ex_packet[k].packet.inst);
            endcase
        end
        
        
        for (int r=0;r<`WIDTH;r++) begin
            if(st_value_valid[r]==1)
                mux_mem_data = st_value[r];
        end

        for(int g=0; g<`WIDTH; g++) begin
            is_store[g] = ex_packet[g].packet.wr_mem;
            store_mem_size[g] = ex_packet[g].packet.inst.r.funct3;
            {store_tag[g], store_index[g]} = ex_addr[g][31:3];
        end
    end

	genvar i;
	generate	
		for(i=0; i<`WIDTH; i++) begin: generate_block1
            alu alu (
                .FU_unit(FU_unit_ALU[i]),
                .regA(opa_mux_out[i]),
                .regB(opb_mux_out[i]),
                .func(func[i]),
                .result(result_add[i]),
                .done(done_alu[i])
            );

            brcond brcond (// Inputs
                .FU_unit(FU_unit_ALU[i]),
                .rs1(true_PA_value[i]), 
                .rs2(true_PB_value[i]),
                .func(ex_packet[i].packet.inst.b.funct3), // inst bits to determine check

                // Output
                .cond(brcond_result[i])
            );
	
            //instantiation of the memory module to handle loads and stores
            mem_ls lsu(
                .clock(clock),              
                .reset(reset),  
                //inputs from ex stage           
                .mem_packet_in(ex_packet[i].packet),
                .alu_result(result_add[i]),
                //input from outside
                .Dcacheproc_data(mux_mem_data),
                //outputs to the outside
                .mem_result_out(mem_result_out[i]),
                .mem_size(mem_sizes[i]),      
                .proc2dcache_command(tempproc_command[i]),
                .proc2dcache_addr(tempproc_addr[i]) 
            );
        end
    endgenerate    

//two instantiations for multiply units
    mul1 mul1 (
            .clock(clock),
            .reset(reset),
            .FU_unit(FU_unit_mul[0]),
            .regA(opa_mux_out[0]),
            .regB(opb_mux_out[0]),
            .func(func[0]),
            .tag_in(ex_packet[0].T),
            .result(result_mul1),
            .tag_out(tag1),
            .rollback(rollback),
            .done(done_mul1)
        );

    mul2 mul2 (
            .clock(clock),
            .reset(reset),
            .FU_unit(FU_unit_mul[`WIDTH -1]),
            .regA(opa_mux_out[`WIDTH-1]),
            .regB(opb_mux_out[`WIDTH-1]),
            .func(func[`WIDTH-1]),
            .tag_in(ex_packet[`WIDTH-1].T),
            .result(result_mul2),
            .tag_out(tag2),
            .rollback(rollback),
            .done(done_mul2)
        ); 


     //	unconditional, or conditional and the condition is true
    always_comb begin
        branch  =   0;
        tresult_add = mem_result_out;
        for(int k=0; k<`WIDTH; k++) begin
            ex_st_PC[k] = ex_packet[k].T;
            branch[k]       =   ex_packet[k].packet.cond_branch | ex_packet[k].packet.uncond_branch;
            done_lsu[k]     =   (ex_packet[k].packet.rd_mem) ? (st_value_valid[ld_location]|mem_data_valid) :  done_alu[k]; 
            take_branch[k]  =   branch[k] | ex_packet[k].packet.uncond_branch | 
                                (ex_packet[k].packet.cond_branch & brcond_result[k]);
	        temp_taken[k]   =   ex_packet[k].packet.uncond_branch | 
                                (ex_packet[k].packet.cond_branch & brcond_result[k]);
            PC[k]           =   ex_packet[k].packet.PC;
            tag[k]           =   ex_packet[k].T;
            target[k]       =   (temp_taken[k]) ? result_add[k] : ex_packet[k].packet.NPC;
            if(take_branch[k])   begin
                tresult_add[k] = (temp_taken[k]) ?  ex_packet[k].packet.NPC : mem_result_out[k];
            end
        end

        if(`WIDTH == 2)begin
            result_mul = {result_mul2,result_mul1};
            done_mul = {done_mul2,done_mul1};
            tag_out = {tag2, tag1};
        end 
        else begin
            result_mul   = result_mul1;
            done_mul     = done_mul1;
            tag_out      = tag1;   
        end 

        for(int q=0; q<`WIDTH; q++) begin
            ALU_stall[q]    = done_alu[q];
            if(!done_mul[q]) begin
                if(done_alu[q]) begin
                    ALU_stall[q] = (ex_packet[ld_location].packet.rd_mem)? (!(mem_data_valid|st_value_valid[ld_location])) : 0;   //recently changed was 0
                end
                else if(done_alu[`WIDTH-1-q] & done_mul[`WIDTH-1-q]) begin
                    ALU_stall[`WIDTH-1-q] = (ex_packet[`WIDTH-1-q].packet.rd_mem)? (!(mem_data_valid|st_value_valid[ld_location])) : 0;
                end
                else begin
                end
            end
        end
    end

    //outputs        
    always_ff @(posedge clock)begin
        if(reset||rollback)begin
                complete_packet <=  0;
                execution_done  <=  0;
                store_buffer    <=  0;
        end 
        else begin

            for(int q=0; q<`WIDTH; q++) begin
                execution_done[q]           <= (ex_packet[ld_location].packet.rd_mem & !done_mul[q]) ? (mem_data_valid|st_value_valid[ld_location]) : 1;
                complete_packet[q].result   <= result_mul[q];
                complete_packet[q].PR       <= tag_out[q];
                complete_packet[q].halt     <=  ex_packet[q].packet.halt;
                complete_packet[q].r        <= 0;
                complete_packet[q].w        <= 0;
                
                //logic for G5 buffer
                if(is_store[q]) begin
                    if(store_mem_size[q]==BYTE || store_mem_size[q]==HALF) begin
                        store_buffer[store_index[q]].tag       <= store_tag[q];
                        store_buffer[store_index[q]].dirty     <= 1;
                    end else begin
                        store_buffer[store_index[q]].dirty     <= 0;     
                    end
                end
                if(retire_store) begin
                    if(retire_store_size==BYTE || retire_store_size==HALF)
                        if(store_buffer[retire_store_index].tag == retire_store_tag)
                            store_buffer[retire_store_index].dirty    <= 0;
                end



                if(!done_mul[q]) begin
                    if(done_lsu[q] ) begin
                        complete_packet[q].result   <= tresult_add[q];
                        complete_packet[q].PR       <= ex_packet[q].T;
                        complete_packet[q].r        <= (done_mul[q])? 0 : ex_packet[q].packet.rd_mem;
                        complete_packet[q].w        <= (done_mul[q])? 0 : ex_packet[q].packet.wr_mem;
                    end
                    else if(done_lsu[`WIDTH-1-q] & done_mul[`WIDTH-1-q]) begin
                        complete_packet[q].result   <= tresult_add[`WIDTH-1-q];
                        complete_packet[q].PR       <= ex_packet[`WIDTH-1-q].T;
                        complete_packet[q].r        <= ex_packet[`WIDTH-1-q].packet.rd_mem;
                        complete_packet[q].w        <= ex_packet[`WIDTH-1-q].packet.wr_mem;
                    end
                    else begin
                        execution_done[q] <= 0;
                    end
                end
            end
        end
    end
endmodule 

