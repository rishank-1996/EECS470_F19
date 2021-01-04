// cachemem32x64

`timescale 1ns/100ps

module cache(
        input clock, reset, wr1_en,
        input  [4:0] wr1_idx, rd1_idx,
        input  [7:0] wr1_tag, rd1_tag,
        input [63:0] wr1_data, 

        output [63:0] rd1_data,
        output rd1_valid
        
      );



  logic [31:0] [63:0] data ;
  logic [31:0]  [7:0] tags; 
  logic [31:0]        valids;

  assign rd1_data = data[rd1_idx];
  assign rd1_valid = valids[rd1_idx] && (tags[rd1_idx] == rd1_tag);
//  initial begin
//  $monitor(" valids[rd1_idx]: %b tags[rd1_idx]: %b rd1_tag: %b  rd1_idx: %b",valids[rd1_idx],tags[rd1_idx],rd1_tag,rd1_idx);
//	end
  always_ff @(posedge clock) begin
    if(reset) begin
      valids <= `SD 31'b0;
      data   <= `SD 0;
      tags   <= `SD 0;
    end
    else begin 
      if(wr1_en) begin
	      valids[wr1_idx] <= `SD 1;
	      data[wr1_idx] <= `SD wr1_data;
	      tags[wr1_idx] <= `SD wr1_tag;
      end
    end
  end

endmodule
