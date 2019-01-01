`timescale 1ns / 1ps


`include "defines.v"
`include"MemoryUtils.v"

`define MMU_ADDR_ROM_START    32'hbfc00000
`define MMU_ADDR_ROM_END      32'hbfc00fff
`define MMU_ADDR_FLASH_START  32'hbe000000
`define MMU_ADDR_FLASH_END    32'hbeffffff
`define MMU_ADDR_SERIAL_START 32'hbfd003f8
`define MMU_ADDR_SERIAL_END   32'hbfd003fc
`define MMU_ADDR_VGA_POS      32'hbfc03000
`define MMU_ADDR_PS2_POS	     32'haf000000

`define DEVICE_CHOICE_LEN		3
`define DEVICE_ROM				3'b000
`define DEVICE_FLASH			3'b001
`define DEVICE_SERIAL			3'b010
`define DEVICE_VGA				3'b011
`define DEVICE_PG2				3'b100
`define DEVICE_RAM				3'b101
`define DEVICE_NOP				3'b110

`define MMUCONTROL_STATE_INIT	 3'b000
`define MMUCONTROL_STATE_PAUSE	 3'b001
`define MMUCONTROL_STATE_RESULT  3'b010
`define MMUCONTROL_STATE_PAUSE_FLASH	 3'b011

module MMUControl (
	input wire clk,    
	input wire rst,  
	input wire[`MEMCONTROL_OP_LEN - 1  :0]	op_i,
	input wire[`MEMCONTROL_ADDR_LEN - 1:0] 	addr_i,
	input wire[31:0]						data_i,
	input wire enable_i,

    input wire[31:0]                       sram_data_i,
//    input wire[31:0]                       serial_data_i, 
    //input from FlashControl
    input wire[31:0] flash_result_i,
    input wire pause_from_flash_i,
    input wire[31:0] rom_result_i,
           
	//output signal to lower layer
	//SRAM 
	output wire 						      sram_enabled,
	output wire[`SRAMCONTROL_OP_LEN   - 1: 0] sram_op, 
	output wire[`SRAMCONTROL_DATA_LEN - 1: 0] sram_data,
	output wire[`SRAMCONTROL_ADDR_LEN - 1: 0] sram_addr,
	
	//output to Flash
    output wire flash_enabled,
    output wire flash_op,
    output wire[`FLASHCONTROL_ADDR_LEN - 1:0] flash_addr,
    
    //output to rom
    output wire rom_enabled,
    output wire[`ROM_ADDR_LEN - 1:0] rom_addr,
	
	// Serial
//	output wire									serial_enabled,
//	output wire[`SERIALCONTROL_OP_LEN - 1: 0]   serial_op,
//	output wire[`SERIALCONTROL_DATA_LEN - 1: 0]	serial_data,
//	output wire[`SERIALCONTROL_ADDR_LEN - 1: 0]	serial_addr,
	
	// output to Memcontrol

	output wire[31:0] result_o,
	output wire pause_pipeline_o
		);
    assign mmu_addr_i = addr_i[3:0];
	wire[`MEMCONTROL_ADDR_LEN - 1:0] mmu_addr;
	reg[`DEVICE_CHOICE_LEN - 1:0] device;
	reg [2:0] cur_state;
    reg sram_enabled_reg;
    reg flash_enabled_reg;
//    reg serial_enabled_reg;
    reg [31:0]result_o_reg;
    reg rom_enable_reg;

    assign mmu_state = cur_state;
    assign mmu_op_i = op_i;
    
    assign sram_enabled = sram_enabled_reg;
    assign flash_enabled = flash_enabled_reg;
    assign rom_enabled = rom_enable_reg;
  //  assign serial_enabled = serial_enabled_reg;
    
    assign pause_pipeline_o = (cur_state == `MMUCONTROL_STATE_PAUSE || cur_state == `MMUCONTROL_STATE_PAUSE_FLASH);
    assign result_o = result_o_reg;//(cur_state == `MMUCONTROL_STATE_RESULT? sram_data_i: `SRAMCONTROL_DEFAULT_DATA);

    assign sram_op = (op_i == `MEMCONTROL_OP_WRITE? `SRAMCONTROL_OP_WRITE : (op_i == `MEMCONTROL_OP_READ? `SRAMCONTROL_OP_READ: `SRAMCONTROL_OP_NOP));
    assign sram_addr = addr_i[22: 2];
    assign sram_data = data_i;
    
    assign flash_op = (op_i == `MEMCONTROL_OP_READ? `FLASHCONTROL_OP_READ : `FLASHCONTROL_OP_NOP);
    assign flash_addr = addr_i[`FLASHCONTROL_ADDR_LEN - 1:0];
    
    assign rom_addr = addr_i[`ROM_ADDR_LEN - 1:0];
    
        // currently map to physical address directly 
	assign mmu_addr = addr_i;
    

	always @(*) begin 
		if(~rst) begin
            sram_enabled_reg <= 1'b0;
            flash_enabled_reg <= 1'b0;
			device  <= `DEVICE_NOP;
			result_o_reg <= `ZeroWord;
			if( enable_i == 1) begin
				if(mmu_addr >= `MMU_ADDR_ROM_START && mmu_addr <= `MMU_ADDR_ROM_END) begin
					device <= `DEVICE_ROM;
					rom_enable_reg <= 1'b1;
					flash_enabled_reg <= 1'b0;
					sram_enabled_reg <= 1'b0;
					result_o_reg <= rom_result_i;
				end else if (mmu_addr >= `MMU_ADDR_FLASH_START && mmu_addr <= `MMU_ADDR_FLASH_END) begin
				    if(flash_op == `FLASHCONTROL_OP_READ)begin 
					   device <= `DEVICE_FLASH;
					   flash_enabled_reg <= 1'b1;
					   sram_enabled_reg <= 1'b0;
					   rom_enable_reg <= 1'b0;
					   result_o_reg <= flash_result_i;
					end else begin
					    sram_enabled_reg <= 0;
                        device  <= `DEVICE_NOP;
                        result_o_reg <= `ZeroWord;
					end
				end else if (mmu_addr >= `MMU_ADDR_SERIAL_START && mmu_addr <= `MMU_ADDR_SERIAL_END) begin
					device <= `DEVICE_SERIAL;
				end else if (mmu_addr == `MMU_ADDR_VGA_POS) begin
					device <= `DEVICE_VGA;
				end else if (mmu_addr == `MMU_ADDR_PS2_POS) begin
					device <= `DEVICE_PG2;
				end else begin
					device <= `DEVICE_RAM;
	                sram_enabled_reg <= 1'b1;
	                flash_enabled_reg <= 1'b0;
	                rom_enable_reg <= 1'b0;
                    result_o_reg <= sram_data_i;

	    		end
			end

		end else begin
            sram_enabled_reg <= 0;
			device  <= `DEVICE_NOP;
			result_o_reg <= `ZeroWord;
			
		end
	end

	always @(posedge clk) begin 
		if(rst) begin
			cur_state <= `MMUCONTROL_STATE_INIT;	
//			sram_enabled_reg <= 0;
		end else begin	
//			sram_enabled_reg <= 0;
			if(cur_state == `MMUCONTROL_STATE_INIT  ||  enable_i == 0) begin
				//if(op_i == `MEMCONTROL_OP_READ || op_i == `MEMCONTROL_OP_WRITE) begin
					cur_state <= `MMUCONTROL_STATE_PAUSE;
					case (device)
						`DEVICE_RAM: begin
//							sram_enabled_reg <= 1;
                
                		end
						default : /* default */;
					endcase
				// end else begin
				// 	cur_state <= `MMUCONTROL_STATE_INIT;
				// end

			end else if(cur_state == `MMUCONTROL_STATE_PAUSE) begin
				//cur_state <= `MMUCONTROL_STATE_RESULT;
				case (device)
					`DEVICE_RAM: begin
					   cur_state <= `MMUCONTROL_STATE_RESULT;
                	end
                    `DEVICE_FLASH: begin
                       cur_state <= `MMUCONTROL_STATE_PAUSE_FLASH;
                    end
					default : cur_state <= `MMUCONTROL_STATE_RESULT;
				endcase
//			end else if(cur_state == `MMUCONTROL_STATE_RESULT) begin
            end else if(cur_state == `MMUCONTROL_STATE_PAUSE_FLASH) begin
                if(pause_from_flash_i == 1'b0) begin
                    cur_state <= `MMUCONTROL_STATE_RESULT;
                end

            end else begin
				cur_state <= `MMUCONTROL_STATE_PAUSE;
				case (device)
					`DEVICE_RAM: begin
        //                sram_enabled_reg <= 1;

            		end
					default : /* default */;
				endcase
			end
		end
	end
	// end

endmodule