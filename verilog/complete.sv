`timescale 1ns/100ps
module ss_complete(
	input   clock,
	input   reset,
	input logic rollback_en,
	input EX_COMPLETE [`WIDTH-1 :0]ex_complete_packet,
	input [`WIDTH-1 :0] execution_complete, ///////gives when to actually broadcast value

	output CDB [`WIDTH-1: 0]cdb,
	output logic [`WIDTH-1: 0] [`XLEN-1:0] result
);



	always_ff @(posedge clock) begin
		if(reset||rollback_en) begin
			for(int j=0; j<`WIDTH; j++) begin
				cdb[j].PR <= {$clog2(`PRF_SIZE){1'b0}};
				cdb[j].completed <= 1'b0;
				cdb[j].halt <= 1'b0;
				cdb[j].w		<= 0;//ex_complete_packet[j].w;
				cdb[j].r		<= 0;//ex_complete_packet[j].r;
			end
		end
		else begin
			for(int i=0; i<`WIDTH; i++) begin
				cdb[i].PR 			<=  ex_complete_packet[i].PR;
				result[i] 			<=  ex_complete_packet[i].result;
				cdb[i].completed 	<=  execution_complete[i];
				cdb[i].halt 	<=  ex_complete_packet[i].halt;
				cdb[i].w		<= ex_complete_packet[i].w;
				cdb[i].r		<= ex_complete_packet[i].r;
			end
		end
	end


	
endmodule

