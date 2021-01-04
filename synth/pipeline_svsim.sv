`ifndef SYNTHESIS

//
// This is an automatically generated file from 
// dc_shell Version O-2018.06 -- May 21, 2018
//

// For simulation only. Do not modify.

module pipeline_svsim(

	input         clock,                    	input         reset,                    	input [3:0]   mem2proc_response,        	input [63:0]  mem2proc_data,            	input [3:0]   mem2proc_tag,              	
	output logic [1:0]  proc2mem_command,    	output logic [32-1:0] proc2mem_addr,      	output logic [63:0] proc2mem_data,
	 

	output logic [3:0]  pipeline_completed_insts,
	output EXCEPTION_CODE   pipeline_error_status,
	output logic [2-1:0][$clog2(32)-1:0]  pipeline_commit_wr_idx,
	output logic [2-1:0][32-1:0] pipeline_commit_wr_data,
	output logic [2-1:0]  pipeline_commit_wr_en,
	output logic [2-1:0][32-1:0] pipeline_commit_NPC,
	
	
				
	
		output logic [32-1:0][2-1:0] if_NPC_out,
	output logic [31:0][2-1:0] if_IR_out,
	output logic  [2-1:0]      if_valid_inst_out,

		output IF_ID_PACKET [2-1:0] if_packet,
	output IF_ID_PACKET [2-1:0] if_id_packet,
	output RS_OBJ [2-1:0] issue_packet,
	output RS_OBJ [2-1:0]  issue_ex_packet,
	output ROB_ENTRY [2-1:0] retire_entry,
	output EX_COMPLETE [2-1:0] complete_packet,
	output ID_DISP_PACKET [2-1:0] disp_packet,
	output logic [32-1:0] proc2Dmem_addr,
	output logic [63:0] proc2Dmem_data ,
	output logic [1:0]  halt_status

);
		
		

  pipeline pipeline( {>>{ clock }}, {>>{ reset }}, {>>{ mem2proc_response }}, 
        {>>{ mem2proc_data }}, {>>{ mem2proc_tag }}, {>>{ proc2mem_command }}, 
        {>>{ proc2mem_addr }}, {>>{ proc2mem_data }}, 
        {>>{ pipeline_completed_insts }}, {>>{ pipeline_error_status }}, 
        {>>{ pipeline_commit_wr_idx }}, {>>{ pipeline_commit_wr_data }}, 
        {>>{ pipeline_commit_wr_en }}, {>>{ pipeline_commit_NPC }}, 
        {>>{ if_NPC_out }}, {>>{ if_IR_out }}, {>>{ if_valid_inst_out }}, 
        {>>{ if_packet }}, {>>{ if_id_packet }}, {>>{ issue_packet }}, 
        {>>{ issue_ex_packet }}, {>>{ retire_entry }}, {>>{ complete_packet }}, 
        {>>{ disp_packet }}, {>>{ proc2Dmem_addr }}, {>>{ proc2Dmem_data }}, 
        {>>{ halt_status }} );
endmodule
`endif
