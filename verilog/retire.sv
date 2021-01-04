`timescale 1ns/100ps
module ss_retire(
    input clock,
    input reset,

    input logic [`WIDTH-1:0] rtr,      //ready to retire in rob
    input ROB_ENTRY [`WIDTH-1:0]ROB,    //head of ROB  

    //input from dcache for valid
    input logic write_enable,
    input logic [63:0] data_mem,

    //input from the PRF
    input logic [`XLEN-1:0] store_addr,
    input logic [`XLEN-1:0] store_data,

    //output to the Freelist
    output logic [`WIDTH -1:0] [$clog2(`PRF_SIZE)-1:0] pregold,

    //output to the dcache
    output logic [63:0] data,
    output logic data_write,
    output logic is_store,

    //output to memory
    output logic [63:0] store_address,
    output MEM_SIZE mem_size,

    //output to the PRF
    output logic [$clog2(`PRF_SIZE)-1:0] store_tag,
    
    //output to the regfile
    output logic [$clog2(`RF_SIZE)-1:0] store_rs2,
    
    //output to the Arch Map table
    output logic [`WIDTH -1:0] [$clog2(`PRF_SIZE)-1:0] preg,
    output logic [`WIDTH -1:0] [$clog2(`RF_SIZE)-1:0] dest_reg,
    output logic [`WIDTH-1:0]inst_retire,
    output logic [`WIDTH-1:0] halt,

    //output condition
    output logic [$clog2(`PRF_SIZE)-1:0] alt_tag,
    output logic switch,

    output logic [`WIDTH-1:0] retire_load

);

EXAMPLE_CACHE_BLOCK size_div;

logic [`XLEN-1:0] tstore_data;
assign tstore_data = (store_rs2==`ZERO_REG) ? 0 : store_data;

always_comb begin 
    store_tag       = 0;
    store_rs2       = 0;
    data_write      = 0;  
    is_store        = 0;
    alt_tag         = 0;
	inst_retire = 0;
size_div = 0;
data=0; 
    retire_load     = 0;
    halt            = 0;
    data=0;
    store_address = 0;
    switch = 0;
    mem_size = 0;
    for(int j=0; j<`WIDTH; j++)begin
        retire_load[j] = ROB[j].packet.rd_mem;
	if(j==1 && halt[0]==1)
        inst_retire[j] = 0;
	else 
        inst_retire[j] = rtr[j];

        preg[j]        = ROB[j].tag;
        pregold[j]     = ROB[j].tag_old;
        dest_reg[j]    = ROB[j].dest;
        if(rtr[j] ) begin
            if(ROB[j].packet.wr_mem) begin
                alt_tag = (j==1 && ROB[j].packet.inst.s.rs2==ROB[j-1].dest) ? ROB[j-1].tag : `ZERO_PREG;
                switch = (j==1 && ROB[j].packet.inst.s.rs2==ROB[j-1].dest);
                is_store    = 1;
                mem_size    = ROB[j].packet.inst.r.funct3;
                store_tag   = ROB[j].tag;
                store_rs2   = ROB[j].packet.inst.s.rs2;
                data = data_mem;
                size_div = data_mem;
                case(mem_size)
                    BYTE: begin
                        size_div.byte_level[store_addr[2:0]] = tstore_data[7:0];
                        data = size_div.byte_level;
                    end
                    HALF: begin
                        //assert(store_addr[0] == 0);
                        size_div.half_level[store_addr[2:1]] = tstore_data[15:0];
                        data = size_div.half_level;
                    end
                    WORD: begin
                        //assert(store_addr[1:0] == 0);
                        size_div.word_level[store_addr[2]] = tstore_data[31:0];
                        data = size_div.word_level;
                    end
                    default: begin
                        //assert(store_addr[1:0] == 0);
                        size_div.byte_level[store_addr[2]] = tstore_data[31:0];
                        data = size_div.word_level;
                    end
                endcase
                data_write = write_enable;
                store_address = {32'b0, store_addr}; 
                inst_retire[j] = write_enable;
            end
        end
        if(ROB[j].packet.halt & inst_retire[j])
            halt[j] = 1;
    end
end

endmodule


