`timescale 1ns/100ps
//parameter `PRF_SIZE = 64;

module ss_physical_reg_file(
        input clock,
        input reset,
        //input addresses from issue
        input logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0]  PA,
        input logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0]  PB,
	      input logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0]  tb_reg,

        //inputs from complete to write
        input CDB   [`WIDTH-1:0] cdb,
        input logic [`WIDTH-1:0] [`XLEN-1:0] ALU_RESULT,

        //input from retire on store inst
        input logic [$clog2(`PRF_SIZE)-1:0] store_tag,
        input logic [`WIDTH-1:0] [$clog2(`PRF_SIZE)-1:0] retire_tag,

        //input from RRAT
        input logic [$clog2(`PRF_SIZE)-1:0] store_rs2_tag,
        output logic [`XLEN-1:0] store_data,

        //output from prf to retire on store
        output logic [31:0] store_tag_value,
        output logic [`WIDTH-1:0] [`XLEN-1:0] retire_value,

        //output values to issue
        output logic [`WIDTH-1:0] [`XLEN-1:0] PA_value,
        output logic [`WIDTH-1:0] [`XLEN-1:0] PB_value,     
        output  logic [`WIDTH-1:0][`XLEN-1:0] tb_value
        
      );
  
  logic    [`PRF_SIZE-1:0] [`XLEN-1:0] pregisters;   // 64, 32-bit Registers
  logic done, dones;
  logic  [`WIDTH-1:0] [`XLEN-1:0] rda_preg;
  logic  [`WIDTH-1:0] [`XLEN-1:0] rdb_preg;

  assign store_tag_value  = pregisters[store_tag];

  assign store_data = pregisters[store_rs2_tag];

  always_comb begin
    for(int j=0; j<`WIDTH; j++) begin
      rda_preg[j] = pregisters[PA[j]];
      rdb_preg[j] = pregisters[PB[j]];
    end

    for(int q=0; q<`WIDTH; q++) begin
      done = 0;
      for(int w=0; w<`WIDTH; w++) begin
        if (cdb[w].completed && (cdb[w].PR == retire_tag[q])) begin
          retire_value[q] = ALU_RESULT[w];  //internal forwarding
          done = 1;
        end
        else begin
          if(!done)
            retire_value[q] = pregisters[retire_tag[q]];
        end
      end
    end

    for(int q=0; q<`WIDTH; q++) begin
      dones = 0;
      for(int w=0; w<`WIDTH; w++) begin
        if (cdb[w].completed && (cdb[w].PR == tb_reg[q])) begin
          tb_value[q] = ALU_RESULT[w];
          dones = 1;
        end
        else begin
          if(!dones)
            tb_value[q] = pregisters[tb_reg[q]];
        end
      end
    end

    for(int q=0; q<`WIDTH; q++) begin
      //
      // Read port A
      //
      for(int w=0; w<`WIDTH; w++) begin
        if (cdb[w].completed && (cdb[w].PR == PA[q]))
          PA_value[q] = ALU_RESULT[w];  //internal forwarding
        else
          PA_value[q] = rda_preg[q];
      end

      //
      // Read port B
      //
      for(int w=0; w<`WIDTH; w++) begin
        if (cdb[w].completed && (cdb[w].PR == PB[q]))
          PB_value[q] = ALU_RESULT[w];  //internal forwarding
        else
          PB_value[q] = rdb_preg[q];
      end
    end
  end

  //
  // Write port
  //
  always_ff @(posedge clock) begin
    if(reset)
      pregisters <= 0;
    for(int i=0; i<`WIDTH; i++) begin  
      if (cdb[i].completed) begin
        pregisters[cdb[i].PR] <= ALU_RESULT[i];
      end
    end
  end

endmodule // pregfile
