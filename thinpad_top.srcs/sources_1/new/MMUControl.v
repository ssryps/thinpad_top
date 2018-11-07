`timescale 1ns / 1ps



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

module MMUControl (
	input wire clk,    
	input wire rst,  
	input wire[`MEMCONTROL_OP_LEN - 1  :0]	op_i,
	input wire[`MEMCONTROL_ADDR_LEN - 1:0] 	addr_i,
	input wire[31:0]						data_i,

    input wire[31:0]                       sram_data_i,
    input wire[31:0]                       serial_data_i,            
	//output signal to lower layer
	//SRAM 
	output wire 						      sram_enabled,
	output wire[`SRAMCONTROL_OP_LEN   - 1: 0] sram_op, 
	output wire[`SRAMCONTROL_DATA_LEN - 1: 0] sram_data,
	output wire[`SRAMCONTROL_ADDR_LEN - 1: 0] sram_addr,
	
	// Serial
	output wire									serial_enabled,
	output wire[`SERIALCONTROL_OP_LEN - 1: 0]   serial_op,
	output wire[`SERIALCONTROL_DATA_LEN - 1: 0]	serial_data,
	output wire[`SERIALCONTROL_ADDR_LEN - 1: 0]	serial_addr,
	
	// output to Memcontrol

	output wire[31:0] result_o,
	output wire pause_pipeline_o

	);

	reg[`MEMCONTROL_ADDR_LEN - 1:0] mmu_addr;
	reg[`DEVICE_CHOICE_LEN - 1:0] device;
	reg [2:0]cur_state;
    reg sram_enabled_reg;
    reg serial_enabled_reg;
    reg [31:0]result_o_reg;
    reg [`SRAMCONTROL_OP_LEN - 1:0]sram_op_reg;
    reg [`SRAMCONTROL_ADDR_LEN - 1:0]sram_addr_reg;
    reg [31:0] sram_data_reg;
    assign sram_enabled = sram_enabled_reg;
    assign serial_enabled = serial_enabled_reg;
    
    assign pause_pipeline_o = (cur_state == `MMUCONTROL_STATE_PAUSE);
    assign result_o = result_o_reg;//(cur_state == `MMUCONTROL_STATE_RESULT? sram_data_i: `SRAMCONTROL_DEFAULT_DATA);

    assign sram_op = (op_i == `MEMCONTROL_OP_WRITE? `SRAMCONTROL_OP_WRITE : (op_i == `MEMCONTROL_OP_READ? `SRAMCONTROL_OP_READ: `SRAMCONTROL_OP_NOP));
    assign sram_addr = addr_i[22: 2];
    assign sram_data = data_i;
	
	always @(*) begin 
		if(~rst) begin
			if(mmu_addr >= `MMU_ADDR_ROM_START && mmu_addr <= `MMU_ADDR_ROM_END) begin
				device <= `DEVICE_ROM;
			end else if (mmu_addr >= `MMU_ADDR_FLASH_START && mmu_addr <= `MMU_ADDR_FLASH_END) begin
				device <= `DEVICE_FLASH;
			end else if (mmu_addr >= `MMU_ADDR_SERIAL_START && mmu_addr <= `MMU_ADDR_SERIAL_END) begin
				device <= `DEVICE_SERIAL;
			end else if (mmu_addr == `MMU_ADDR_VGA_POS) begin
				device <= `DEVICE_VGA;
			end else if (mmu_addr == `MMU_ADDR_PS2_POS) begin
				device <= `DEVICE_PG2;
			end else begin
				device <= `DEVICE_RAM;

				// currently map to physical address directly 
				mmu_addr <= addr_i;
				if(cur_state == `MMUCONTROL_STATE_RESULT) begin
					result_o_reg <= sram_data_i;
				end
			end	if(op_i == `MEMCONTROL_OP_NOP) begin
				device <= `DEVICE_NOP;
			end

		end else begin
			device  <= `DEVICE_NOP;
		end
	end

	always @(posedge clk) begin 
		if(rst) begin
			cur_state <= `MMUCONTROL_STATE_INIT;	
			sram_data_reg <= `SRAMCONTROL_DEFAULT_DATA;
			sram_enabled_reg <= 0;
		end else begin	
			if(cur_state == `MMUCONTROL_STATE_INIT) begin
				//if(op_i == `MEMCONTROL_OP_READ || op_i == `MEMCONTROL_OP_WRITE) begin
					cur_state <= `MMUCONTROL_STATE_PAUSE;
					case (device)
						`DEVICE_RAM: begin
							sram_enabled_reg <= 1;
                		end
						default : /* default */;
					endcase
				// end else begin
				// 	cur_state <= `MMUCONTROL_STATE_INIT;
				// end

			end else if(cur_state == `MMUCONTROL_STATE_PAUSE) begin
				cur_state <= `MMUCONTROL_STATE_RESULT;
				case (device)
					`DEVICE_RAM: begin
                        sram_enabled_reg <= 1;
                	end
					default : /* default */;
				endcase
			end else if(cur_state == `MMUCONTROL_STATE_RESULT) begin
				//cur_state <= `MMUCONTROL_STATE_INIT;
				cur_state <= `MMUCONTROL_STATE_PAUSE;
				case (device)
					`DEVICE_RAM: begin
                        sram_enabled_reg <= 1;
            		end
					default : /* default */;
				endcase
			end
		end
	end

	// always @(*) begin 
	// 	if(cur_state == `MMUCONTROL_STATE_RESULT) begin
	// 	 	case (device)
	// 			`DEVICE_RAM: begin
 //    				result_o_reg <= sram_data_i;		
	//             end
	// 			default : /* default */;
	// 		endcase
	// 	end
	// end

endmodule