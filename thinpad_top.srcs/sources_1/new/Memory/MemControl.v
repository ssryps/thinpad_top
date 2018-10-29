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


`define MEMCONTROL_STATE_INIT			 	 3'b000
`define MEMCONTROL_STATE_ONLY_PC		 	 3'b001
`define MEMCONTROL_STATE_PC_READ_AND_WRITE	 3'b010
`define MEMCONTROL_STATE_PC_READ_OR_WRITE	 3'b011

// mem access will halt the pipeline, so inside we need a state to record current state
reg cur_state; 
//  currently it remains unknown if a write or read can be finished in a period, so 
// add a reg to record current phase of a primitive operation(read or write)
reg cur_phase;

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

		// result to pc and mem
		output wire[31:0] pc_data_o,
		output wire[31:0] mem_data_o,
		output wire pause_pipeline_o
    );

	
    reg cur_state;

	always @(posedge clk) begin 
		if(rst) begin
			cur_state <= `MEMCONTROL_STATE_INIT;
		end else begin
			case (cur_state)
				`MEMCONTROL_STATE_INIT: begin
					if(mem_op_i == `MEMCONTROL_OP_NOP) begin
						cur_state <= `MEMCONTROL_STATE_ONLY_PC;
						cur_phase <= 0;
					end else if(mem_op_i == `MEMCONTROL_OP_WRITE || mem_op_i == `MEMCONTROL_OP_READ) begin
						if(mem_data_sz_i == `MEMECONTROL_OP_WORD) begin 
							cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE;
							cur_phase = 0;
						end else begin
							cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE;
							cur_phase = 0;		
						end
					end

				end
				`MEMCONTROL_STATE_ONLY_PC: begin
				end

				default : /* default */;
			endcase
		end
	end

	// send signal to sub-devices
	always @(posedge clk) begin 

		if(~rst) begin
						
		end 
	end
	
	always @(*) begin

	end
endmodule
