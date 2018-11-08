`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2018 09:53:20 AM
// Design Name: 
// Module Name: Memcontrol
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
 `include"MemoryUtils.v"


`define MEMCONTROL_STATE_INIT			 		 		4'b0000
`define MEMCONTROL_STATE_ONLY_PC		 	 			4'b0001
`define MEMCONTROL_STATE_ONLY_PC_RESULT		 			4'b0010
`define MEMCONTROL_STATE_PC_READ_OR_WRITE		 		4'b0011
`define MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT		4'b0100
`define MEMCONTROL_STATE_PC_READ_OR_WRITE_1    		 	4'b0101
`define MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT	4'b0110
`define MEMCONTROL_STATE_PC_READ_AND_WRITE	 			4'b0111
`define MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT	4'b1000
`define MEMCONTROL_STATE_PC_READ_AND_WRITE1				4'b1001
`define MEMCONTROL_STATE_PC_READ_AND_WRITE_READ_RESULT	4'b1010
`define MEMCONTROL_STATE_PC_READ_AND_WRITE2				4'b1011
`define MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT	4'b1100
`define MEMCONTROL_STATE_RST 							4'b1101

module MemControl(
		input wire clk, 
		input wire rst,
		input wire[`MEMCONTROL_ADDR_LEN - 1:0] pc_addr_i,
		input wire[31:0] mem_addr_i,
		input wire[31:0] mem_data_i,
		input wire[5:0]	 mem_data_sz_i,	
		input wire[`MEMCONTROL_OP_LEN - 1:0] mem_op_i,


		input wire[31:0] mmu_result_i,
		input wire pause_pipeline_i,


		// control signal to MMU
		output wire[`MEMCONTROL_OP_LEN - 1  :0]	op_o,
		output wire[`MEMCONTROL_ADDR_LEN - 1:0] addr_o,
		output wire[31:0]						data_o,
		
		// result to pc and mem
		output wire[31:0] pc_data_o,
		output wire[31:0] mem_data_o,
		output wire pause_pipeline_o
    );

	
	// mem access will halt the pipeline, so inside we need a state to record current state
	reg[3:0] cur_state; 
	//  currently it remains unknown if a write or read can be finished in a period, so 
	// add a reg to record current phase of a primitive operation(read or write)
	
	reg [`MEMCONTROL_OP_LEN - 1:0]op_o_reg;
	reg [`MEMCONTROL_ADDR_LEN - 1:0]addr_o_reg;
	reg [31:0]data_o_reg;
	reg [31:0]pc_data_o_reg;
	reg [31:0]mem_data_o_reg;

	// read_or_write and read_and_write state to hold temperory data
	reg [31:0]read_or_write_temp_pc;
	reg [31:0]read_and_write_temp_pc;
	reg [31:0]read_and_write_temp_mem;
	//reg [31:0]read_and_write_temp_


	assign op_o = op_o_reg;
	assign addr_o = addr_o_reg;
	assign data_o = data_o_reg;
	assign pc_data_o = pc_data_o_reg;
	assign mem_data_o = mem_data_o_reg;
	assign pause_pipeline_o = !((cur_state == `MEMCONTROL_STATE_RST) || (cur_state == `MEMCONTROL_STATE_ONLY_PC) || (cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_1)
	 || (cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE2) );

	always @(posedge clk) begin 
		if(rst) begin
			cur_state <= `MEMCONTROL_STATE_RST;
		end else begin
			if (cur_state == `MEMCONTROL_STATE_RST) begin
				cur_state <= `MEMCONTROL_STATE_INIT;
			end if (cur_state == `MEMCONTROL_STATE_INIT ) begin
				if(mem_op_i == `MEMCONTROL_OP_NOP) begin
					cur_state  <= `MEMCONTROL_STATE_ONLY_PC;
				end else if(mem_op_i == `MEMCONTROL_OP_WRITE) begin
					if(mem_data_sz_i == `MEMECONTROL_OP_WORD) begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE;
					end else begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE;	
					end
				end else if(mem_op_i == `MEMCONTROL_OP_READ) begin
					cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE;
				end

			end else if(cur_state == `MEMCONTROL_STATE_ONLY_PC) begin
				cur_state <= `MEMCONTROL_STATE_ONLY_PC_RESULT;
			end else if(cur_state == `MEMCONTROL_STATE_ONLY_PC_RESULT) begin
				if(mem_op_i == `MEMCONTROL_OP_NOP) begin
					cur_state  <= `MEMCONTROL_STATE_ONLY_PC;
				end else if(mem_op_i == `MEMCONTROL_OP_WRITE) begin
					if(mem_data_sz_i == `MEMECONTROL_OP_WORD) begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE;
					end else begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE;	
					end
				end else if(mem_op_i == `MEMCONTROL_OP_READ) begin
					cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE;
				end

			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE) begin
				cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT) begin
				// save temp pc result 
				read_or_write_temp_pc <= mmu_result_i;
				cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_1;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_1) begin
				cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT;
				// output pc and mem result
				pc_data_o_reg <= read_or_write_temp_pc;
				mem_data_o_reg <= mmu_result_i;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT) begin
		
				if(mem_op_i == `MEMCONTROL_OP_NOP) begin
					cur_state  <= `MEMCONTROL_STATE_ONLY_PC;
				end else if(mem_op_i == `MEMCONTROL_OP_WRITE) begin
					if(mem_data_sz_i == `MEMECONTROL_OP_WORD) begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE;
					end else begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE;	
					end
				end else if(mem_op_i == `MEMCONTROL_OP_READ) begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE;
				end

			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE) begin
				cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT) begin
				cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE1;
				// temp save pc
				read_and_write_temp_pc <= mmu_result_i;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE1) begin
				cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_READ_RESULT;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_READ_RESULT) begin
				cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE2;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE2) begin
				cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT;
				// output final result
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT) begin
				
				if(mem_op_i == `MEMCONTROL_OP_NOP) begin
					cur_state  <= `MEMCONTROL_STATE_ONLY_PC;
				end else if(mem_op_i == `MEMCONTROL_OP_WRITE) begin
					if(mem_data_sz_i == `MEMECONTROL_OP_WORD) begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE;
					end else begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE;	
					end
				end else if(mem_op_i == `MEMCONTROL_OP_READ) begin
					cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE;
				end
			end
		end
	end

	always @(*) begin 
		//if(!pause_pipeline_i) begin
			if (cur_state == `MEMCONTROL_STATE_RST) begin
				op_o_reg   <= `MEMCONTROL_OP_READ; 
			end if (cur_state == `MEMCONTROL_STATE_INIT ) begin
				op_o_reg   <= `MEMCONTROL_OP_READ;
				addr_o_reg <= pc_addr_i;
				data_o_reg <=  mem_data_i;
			end else if(cur_state == `MEMCONTROL_STATE_ONLY_PC) begin
				op_o_reg   <= `MEMCONTROL_OP_READ;
				addr_o_reg <= pc_addr_i; 
				pc_data_o_reg <= mmu_result_i;	
				
			end else if(cur_state == `MEMCONTROL_STATE_ONLY_PC_RESULT) begin
				mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;

				op_o_reg   <= `MEMCONTROL_OP_READ;
				addr_o_reg <= pc_addr_i;
				data_o_reg <=  mem_data_i;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE) begin
				op_o_reg   <= `MEMCONTROL_OP_READ;
				addr_o_reg <= pc_addr_i;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT) begin
				op_o_reg   <=  mem_op_i;
				addr_o_reg <=  mem_addr_i;
				data_o_reg <=  mem_data_i;

			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_1) begin
				op_o_reg   <= mem_op_i;
				addr_o_reg <= mem_addr_i;
				data_o_reg <= mem_data_i;
				
				pc_data_o_reg <= read_or_write_temp_pc;
				mem_data_o_reg <= mmu_result_i;
			
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT) begin
				
				op_o_reg   <= `MEMCONTROL_OP_READ;
				addr_o_reg <= pc_addr_i;
				data_o_reg <=  mem_data_i;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE) begin
				op_o_reg   <= `MEMCONTROL_OP_READ;
				addr_o_reg <= pc_addr_i;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT) begin
				op_o_reg   <=  `MEMCONTROL_OP_READ;
				addr_o_reg <=  mem_addr_i;
				data_o_reg <=  mem_data_i;
				// save temp pc result 
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE1) begin
				op_o_reg   <= `MEMCONTROL_OP_READ;
				addr_o_reg <= mem_addr_i;
				data_o_reg <= mem_data_i;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_READ_RESULT) begin
				op_o_reg   <= `MEMCONTROL_OP_WRITE;
				addr_o_reg <= mem_addr_i;
				if(mem_data_sz_i == `MEMECONTROL_OP_HALF_WORD) begin
					if(mem_addr_i[1:0] == 2'b00) begin
						data_o_reg <= {mmu_result_i[31: 16], mem_data_i[15:0]};
					end else if(mem_addr_i[1:0] == 2'b10) begin
						data_o_reg <= {mem_data_i[15: 0], mmu_result_i[15:0]};
					end
				end else if(mem_data_sz_i == `MEMECONTROL_OP_BYTE) begin
					if(mem_addr_i[1:0] == 2'b00) begin
						data_o_reg <= {mmu_result_i[31: 8], mem_data_i[7:0]};
					end else if(mem_addr_i[1:0] == 2'b01) begin
						data_o_reg <= {mmu_result_i[31: 16], mem_data_i[7:0], mmu_result_i[7:0]};
					end else if(mem_addr_i[1:0] == 2'b10) begin
						data_o_reg <= {mmu_result_i[31: 24], mem_data_i[7:0], mmu_result_i[15:0]};
					end else  begin
						data_o_reg <= {mem_data_i[7:0], mmu_result_i[23:0]};
					end

				end
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE2) begin
				//op_o_reg   <= `MEMCONTROL_OP_WRITE;
				//addr_o_reg <= pc_addr_i;
				pc_data_o_reg <= read_and_write_temp_pc;
				mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT) begin
				op_o_reg   <=  `MEMCONTROL_OP_READ;
				addr_o_reg <=  pc_addr_i;
				data_o_reg <=  mem_data_i;
				// save temp pc result 			
			end
		//end
	end
endmodule
