
module dcache_control(
    input   clock,
    input   reset,

    input logic st_en,
    input logic [63:0] st_addr,
    input logic [63:0] st_data,
    input MEM_SIZE st_mem_size,
    input MEM_SIZE ex_mem_size,

    //inputs coming from ex:
    input  [31:0] sproc2Dcache_addr,
    input logic cache_enable,
    input logic [1:0] ldproc2Dmem_command,

    //inputs from the main memory
    input   [3:0] Dmem2proc_response,
    input   [63:0] Dmem2proc_data,
    input   [3:0] Dmem2proc_tag,

    //inputs from cache
    input   cachemem_valid,
    input  [63:0] cachemem_data,


    //outputs to ex:
    output logic [63:0] Dcache_data_out, // value is memory[proc2Dcache_addr]
    output logic  Dcache_valid_out,      // when this is high

    //outputs to main memory
    output logic  [1:0] proc2Dmem_command,
    output logic [31:0] proc2Dmem_addr,

    //outputs to the cache
    output logic  [4:0] current_index,
    output logic  [7:0] current_tag,
    output logic  [4:0] last_index,
    output logic  [7:0] last_tag,
    output logic  data_write_enable,
    output MEM_SIZE rd_size,

    //output to retire
    output logic write_enable
  );
  EXAMPLE_CACHE_BLOCK size_div;
  logic last_cache_enable;
  logic [1:0] sproc2Dmem_command;
  logic  [63:0] proc2Dcache_addr;
  assign proc2Dcache_addr = (st_en) ? st_addr : {32'b0, sproc2Dcache_addr};
  assign sproc2Dmem_command = (st_en) ? (write_enable) ? BUS_STORE : BUS_LOAD : ldproc2Dmem_command;

  assign rd_size = (st_en) ? DOUBLE : ex_mem_size;

  logic [3:0] current_mem_tag;

  logic miss_outstanding;

  assign {current_tag, current_index} = proc2Dcache_addr[31:3];

  wire changed_addr = (current_index != last_index) || (current_tag != last_tag) 
                              || ((last_cache_enable!=cache_enable) & last_cache_enable==0);

  wire send_request = miss_outstanding && !changed_addr;

   //assign size_div = cachemem_data;
  //choosing data blocks
  always_comb begin
    Dcache_data_out = cachemem_data;
    size_div = cachemem_data;
    case (rd_size) 
      BYTE: begin
            Dcache_data_out = {56'b0, size_div.byte_level[proc2Dcache_addr[1:0]]};
	          //$display("time = %t         Proc 2 Dcache _ addr = %h", $time, proc2Dcache_addr [2:0]);
        end
      HALF: begin
            //assert(proc2Dcache_addr[0] == 0);
            Dcache_data_out = {48'b0, size_div.half_level[ proc2Dcache_addr[2:1]]};
        end
      WORD: begin
            //assert(proc2Dcache_addr[1:0] == 0);
            Dcache_data_out = {32'b0, size_div.word_level[proc2Dcache_addr[2]]};
        end
      DOUBLE:
        Dcache_data_out = cachemem_data;
    endcase
  end

  //assign Dcache_data_out = cachemem_data; ///(data_write_enable)?Dmem2proc_data:cachemem_data;

 // assign Dcache_valid_out =(data_write_enable)? 1'b1 : cachemem_valid;//(data_write_enable)? 1'b1: cachemem_valid; 
  assign Dcache_valid_out = !st_en & cachemem_valid & cache_enable;//(data_write_enable)? 1'b1: cachemem_valid; 
  assign write_enable     = cachemem_valid & st_en;

  assign proc2Dmem_addr = {proc2Dcache_addr[31:3],3'b0};
  assign proc2Dmem_command = (miss_outstanding && !changed_addr) ?  sproc2Dmem_command :
                                                                    BUS_NONE;

  assign data_write_enable =  (current_mem_tag == Dmem2proc_tag) &&
                              (current_mem_tag != 0) && !changed_addr  && (sproc2Dmem_command !=BUS_NONE) ;

  wire update_mem_tag = (changed_addr || miss_outstanding || data_write_enable); // && (sproc2Dmem_command !=BUS_NONE);

  wire unanswered_miss = changed_addr ? !Dcache_valid_out :
                                        miss_outstanding && (Dmem2proc_response == 0);

  // synopsys sync_set_reset "reset"
  always_ff @(posedge clock) begin
    if(reset) begin
      last_index       <= -1;   // These are -1 to get ball rolling when
      last_tag         <= -1;   // reset goes low because addr "changes"
      current_mem_tag  <= 0;              
      miss_outstanding <= 0;
      last_cache_enable <= 0;
    end else begin
      last_index       <= current_index;
      last_tag         <= current_tag;
      miss_outstanding <= unanswered_miss;
      last_cache_enable <= cache_enable;
      
      if(update_mem_tag)begin
        current_mem_tag  <= Dmem2proc_response;

      end
    end
  end

endmodule

