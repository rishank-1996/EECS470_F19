`timescale 1ns/100ps
//parameter `RF_SIZE = 32;
module ss_regfile(
        input wr_clk,
        input  [`WIDTH-1:0] [$clog2(`RF_SIZE)-1:0]        wr_idx,    // read/write index
        input  [`WIDTH-1:0] [`XLEN-1:0]  wr_data,            // write data
        input  [`WIDTH-1:0]              wr_en  
          
      );

  logic    [`RF_SIZE-1:0] [`XLEN-1:0] registers;   // 32, 64-bit Registers


  always_ff@(posedge wr_clk) begin
    for(int i=0; i<`WIDTH; i++) begin
      if(wr_en[i]) 
        registers[wr_idx[i]] <= (wr_idx=={$clog2(`RF_SIZE){1'b0}}) ? 0 : wr_data[i];
    end
  end

endmodule // regfile
