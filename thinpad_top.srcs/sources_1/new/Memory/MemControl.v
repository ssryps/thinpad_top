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

`define MEMCONTROL_ADDR_ROM_START    32'hbfc00000
`define MEMCONTROL_ADDR_ROM_END      32'hbfc00fff
`define MEMCONTROL_ADDR_FLASH_START  32'hbe000000
`define MEMCONTROL_ADDR_FLASH_END    32'hbeffffff
`define MEMCONTROL_ADDR_SERIAL_START 32'hbfd003f8
`define MEMCONTROL_ADDR_SERIAL_END   32'hbfd003fc
`define MEMCONTROL_ADDR_VGA_POS    32'hbfc03000
`define MEMCONTROL_ADDR_PS2_POS	  32'haf000000

`define DEVICE_CHOICE_LEN		3
`define DEVICE_ROM				3'b000
`define DEVICE_FLASH			3'b001
`define DEVICE_SERIAL			3'b010
`define DEVICE_VGA				3'b011
`define DEVICE_PG2				3'b100
`define DEVICE_RAM				3'b101
`define DEVICE_NOP				3'b110

`define MEMCONTROL_STATE_INIT			 3'b000
`define MEMCONTROL_STATE_ONLY_PC		 3'b001
`define MEMCONTROL_STATE_PC_READ_WRITE	 3'b010
`define MEMCONTROL_STATE_PC_READ		 3'b011
`define MEMCONTROL_STATE_PC_WRITE		 3'b100

// mem access will halt the pipeline, so inside we need a state to record current state
reg cur_state; 
//  currently it remains unknown if a write or read can be finished in a period, so 
// add a reg to record current phase of a primitive operation(read or write)
reg cur_phase;

module MemControl(
		input wire clk, 
		input wire rst,
		input wire[MEMCONTROL_ADDR_LEN - 1:0] pc_addr_i,
		input wire[31:0] mem_addr_i,
		input wire[31:0] mem_data_i,
		input wire[MEMCONTROL_OP_LEN - 1:0] mem_op_i,

		//output signal to lower layer
		
		//SRAM 
		output wire 						      sram_enabled,
		output wire[`SRAMCONTROL_OP_LEN   - 1: 0] sram_op, 
		output wire[`SRAMCONTROL_ADDR_LEN - 1: 0] sram_addr,
		output wire[`SRAMCONTROL_DATA_LEN - 1: 0] sram_data,

		// Serial
		output wire									serial_enabled,
		output wire[`SERIALCONTROL_OP_LEN - 1: 0]   serial_op,
		output wire[`SERIALCONTROL_ADDR_LEN - 1: 0]	serial_addr,
		output wire[`SERIALCONTROL_DATA_LEN - 1: 0]	serial_data,

		// result to pc and mem
		output wire[31:0] pc_data_o,
		output wire[31:0] mem_data_o,
		output wire pause_pipeline_o
    );

	reg mmu_mem_addr;
	reg [`DEVICE_CHOICE_LEN - 1:0] mmu_mem_device;
	reg mmu_pc_addr;
	reg [`DEVICE_CHOICE_LEN - 1:0] mmu_pc_device;
	
	// now no mmu, so just assign the virtual addr to the 
	assign mmu_mem_addr = mem_addr;

	// find the proper device the input addr is related
	always @(*) begin 
		if(~rst) begin
			if(mem_addr >= `MEMCONTROL_ADDR_ROM_START && mem_addr <= `MEMCONTROL_ADDR_ROM_END) begin
				mmu_mem_device <= `DEVICE_ROM;
			end else if (mem_addr >= `MEMCONTROL_ADDR_FLASH_START && mem_addr <= `MEMCONTROL_ADDR_FLASH_END) begin
				mmu_mem_device <= `DEVICE_FLASH;
			end else if (mem_addr >= `MEMCONTROL_ADDR_SERIAL_START && mem_addr <= `MEMCONTROL_ADDR_SERIAL_END) begin
				mmu_mem_device <= `DEVICE_SERIAL;
			end else if (mem_addr >= `MEMCONTROL_VGA_START && mem_addr <= `MEMCONTROL_VGA_END) begin
				mmu_mem_device <= `DEVICE_VGA;
			end else if (mem_addr >= `MEMCONTROL_PG2_START && mem_addr <= `MEMCONTROL_PG2_END) begin
				mmu_mem_device <= `DEVICE_PG2;
			end else begin
				mmu_mem_device <= `DEVICE_RAM;
			end		

			if(pc_addr >= `MEMCONTROL_ADDR_ROM_START && pc_addr <= `MEMCONTROL_ADDR_ROM_END) begin
				mmu_pc_device <= `DEVICE_ROM;
			end else if (pc_addr >= `MEMCONTROL_ADDR_FLASH_START && pc_addr <= `MEMCONTROL_ADDR_FLASH_END) begin
				mmu_pc_device <= `DEVICE_FLASH;
			end else if (pc_addr >= `MEMCONTROL_ADDR_SERIAL_START && pc_addr <= `MEMCONTROL_ADDR_SERIAL_END) begin
				mmu_pc_device <= `DEVICE_SERIAL;
			end else if (pc_addr == `MEMCONTROL_ADDR_VGA_POS) begin
				mmu_pc_device <= `DEVICE_VGA;
			end else if (pc_addr == `MEMCONTROL_PG2_POS) begin
				mmu_pc_device <= `DEVICE_PG2;
			end else begin
				mmu_pc_device <= `DEVICE_RAM;
			end		
			if(mem_op == `MEMCONTROL_OP_NOP) begin
				mmu_mem_device <= `DEVICE_NOP;
			end
		end else begin
			mmu_mem_device <= `DEVICE_NOP;
			mmu_pc_device  <= `DEVICE_NOP;
		end
	end


	// send signal to sub-devices
	always @(posedge clk) begin 
		sram_enabled   <= 0;
		serial_enabled <= 0;

		if(~rst) begin
						
		end 
	end
	
	always @(*) begin

	end
endmodule
