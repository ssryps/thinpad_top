`include "defines.v"

module ex_mem(

	input wire clk,
	input wire rst,
	
	
	//input from ex	
	input wire[`RegAddrBus] ex_wd,
	input wire ex_wreg,
	input wire[`RegBus] ex_wdata, 

	input wire[`RegBus] ex_hi,
	input wire[`RegBus] ex_lo,
	input wire ex_whilo,	

    //Stall singal from CTRL
    input wire [`StallBus] stall_i,

	//for load and store
	input wire[`AluOpBus] ex_aluop,
	input wire[`RegBus] ex_mem_addr,
	input wire[`RegBus] ex_reg2,
	
	//ouput to mem
	output reg[`RegAddrBus] mem_wd,
	output reg mem_wreg,
	output reg[`RegBus] mem_wdata,
	
	output reg[`RegBus] mem_hi,
	output reg[`RegBus] mem_lo,
	output reg mem_whilo,

	//for load and store
	output reg[`AluOpBus] mem_aluop,
	output reg[`RegBus] mem_mem_addr,
	output reg[`RegBus] mem_reg2,

	input wire cp0_reg_we_i,
	input wire[4:0] cp0_reg_write_addr_i,
	input wire[31:0] cp0_reg_data_i,
	output reg cp0_reg_we_o,
	output reg[4:0] cp0_reg_write_addr_o,
	output reg[31:0] cp0_reg_data_o


);

	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
		    mem_wdata <= `ZeroWord;	
			mem_hi <= `ZeroWord;
			mem_lo <= `ZeroWord;
			mem_whilo <= `WriteDisable;
			mem_aluop <= `EXE_SLL_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;
		end else if(stall_i[3]==`Stall&&stall_i[4]==`NotStall) begin
			mem_wd <= `NOPRegAddr;
			mem_wreg <= `WriteDisable;
		    mem_wdata <= `ZeroWord;	
			mem_hi <= `ZeroWord;
			mem_lo <= `ZeroWord;
			mem_whilo <= `WriteDisable;
			mem_aluop <= `EXE_SLL_OP;
			mem_mem_addr <= `ZeroWord;
			mem_reg2 <= `ZeroWord;

			cp0_reg_write_addr_o <= 5'b00000;
            cp0_reg_we_o <= `WriteDisable;
            cp0_reg_data_o <= 32'b00000000_00000000_00000000_00000000;

		end else if (stall_i[3]==`NotStall) begin
			mem_wd <= ex_wd;
			mem_wreg <= ex_wreg;
			mem_wdata <= ex_wdata;
			mem_hi <= ex_hi;
			mem_lo <= ex_lo;
			mem_whilo <= ex_whilo;
			mem_aluop <= ex_aluop;
			mem_mem_addr <= ex_mem_addr;
			mem_reg2 <= ex_reg2;
			cp0_reg_data_o <= cp0_reg_data_i;
			cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
			cp0_reg_we_o <= cp0_reg_we_i;
		end    //if
	end      //always
			
endmodule
