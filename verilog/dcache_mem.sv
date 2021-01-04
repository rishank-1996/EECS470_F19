//parameter `DC_SIZE = 32;

// dcachemem64x32

`timescale 1ns/100ps

module dcache_mem(
        input clock, reset, wr1_en,
        
        input   st_wr_en,
        input [63:0] st_addr,
        input [63:0] st_wr_data,
        input  [4:0] wr1_idx, rd1_idx,
        input  [7:0] wr1_tag, rd1_tag,
        input  [63:0] wr1_data, 

        output [63:0] rd1_data,
        output rd1_valid
        
      );


  logic [4:0] st_wr_idx;
  logic [7:0] st_wr_tag;
  logic [`DC_SIZE-1:0] [63:0] data ;
  logic [`DC_SIZE-1:0] [7:0] tags; 
  logic [`DC_SIZE-1:0] valids;
  logic cache_valid;

  assign {st_wr_tag, st_wr_idx} = st_addr[31:3];
  assign cache_valid = valids[st_wr_idx];

  assign rd1_data = data[rd1_idx];
  assign rd1_valid = valids[rd1_idx] && (tags[rd1_idx] == rd1_tag);
  

  always_ff @(posedge clock) begin
    if(reset)
      valids <=  0;
    else begin
      if(wr1_en) begin
        valids[wr1_idx]  <=  1;
        data[wr1_idx]    <= wr1_data;
        tags[wr1_idx]    <= wr1_tag;
      end
      if(st_wr_en) begin
        valids[st_wr_idx]  <=  1;
        data[st_wr_idx]    <= st_wr_data;
        tags[st_wr_idx]    <= st_wr_tag;
      end
    end
  end

endmodule
