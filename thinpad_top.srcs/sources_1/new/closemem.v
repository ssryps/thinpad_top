`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2018 08:48:16 AM
// Design Name: 
// Module Name: test_MMUControl
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

`include "MemoryUtils.v"

module closemem(
    	input wire clk_50M,
    	input wire rst,
    	input wire[`MEMCONTROL_ADDR_LEN - 1:0] pc_addr_i,
    	input wire[31:0] mem_addr_i,
    	input wire[31:0] mem_data_i,
    	input wire[5:0]	 mem_data_sz_i,	
    	input wire[`MEMCONTROL_OP_LEN - 1:0] mem_op_i,
        input wire mem_enabled,

        // TLB
        input wire[31:0] cp0_index_i,
        input wire[31:0] cp0_entryhi_i,
        input wire[31:0] cp0_entrylo0_i,
        input wire[31:0] cp0_entrylo1_i,
        input wire[31:0] cp0_random_i,
    	input wire[`TLB_OP_RANGE] tlb_op_i,
        output wire[`TLB_EXCEPTION_RANGE] tlb_exc_o,// to MEM
        // cp0 data bypass
        input wire mem_wb_o_cp0_reg_we_i,
        input wire[4:0] mem_wb_o_cp0_reg_write_addr_i,
        input wire[`RegBus] mem_wb_o_cp0_reg_data_i,

        input wire RxD,
        
    	output wire[31:0] pc_data_o,
    	output wire[31:0] mem_data_o,
        output wire mem_data_valid_o,
    	output wire pause_pipeline_final_o,

        // signal to outer devices
        inout wire[31:0] ram1_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
        output wire[19:0] ram1_addr, //BaseRAM地址
        output wire[3:0] ram1_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
        output wire ram1_ce_n,       //BaseRAM片选，低有效
        output wire ram1_oe_n,       //BaseRAM读使能，低有效
        output wire ram1_we_n,       //BaseRAM写使能，低有效

        //ExtRAM信号
        inout wire[31:0] ram2_data,  //ExtRAM数据
        output wire[19:0] ram2_addr, //ExtRAM地址
        output wire[3:0] ram2_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
        output wire ram2_ce_n,       //ExtRAM片选，低有效
        output wire ram2_oe_n,       //ExtRAM读使能，低有效
        output wire ram2_we_n,      //ExtRAM写使能，低有效

        // serial signal
        output wire TxD,
        output wire serial_excp,

        //flash信号
        output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
        inout  wire [15:0]flash_d,      //Flash数据
        output wire flash_rp_n,         //Flash复位信号，低有效
        output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
        output wire flash_ce_n,         //Flash片选信号，低有效
        output wire flash_oe_n,         //Flash读使能信号，低有效
        output wire flash_we_n,         //Flash写使能信号，低有效
        output wire flash_byte_n       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1
	);



wire[`MEMCONTROL_OP_LEN - 1  : 0]	op_i;
wire[`MEMCONTROL_ADDR_LEN - 1 : 0] 	addr_i;
wire[31:0]						data_i;
wire enable_i;

// Sram
wire 	               		       sram_enabled;
wire[`SRAMCONTROL_OP_LEN   - 1: 0] sram_op;
wire[`SRAMCONTROL_DATA_LEN - 1: 0] sram_data;
wire[`SRAMCONTROL_ADDR_LEN - 1: 0] sram_addr;
wire [31:0] sram_data_i;
	
// Serial
wire[`SERIALCONTROL_OP_LEN - 1: 0] serial_op;
wire[7: 0] serial_data;
wire serial_mode;
wire[31:0] serial_data_i;


wire[31:0] result_o;
wire pause_pipeline_o;

wire[31:0] flash_result_i;
wire pause_from_flash_i;
wire flash_enabled;
wire flash_op;
wire[`FLASHCONTROL_ADDR_LEN - 1:0] flash_addr;

wire[31:0] rom_data;
wire[`ROM_ADDR_LEN - 1:0] rom_addr;
wire rom_enabled;

// output to Memcontrol




// initial begin
//     rst = 1;
//     #20;
//     rst  = 0;
//     pc_addr_i = 32'h0000_0000;
//     mem_addr_i = 32'h0000_0000;
//     mem_data_i = 32'h1111_1111;
//     mem_data_sz_i = `MEMECONTROL_OP_WORD;
//     mem_op_i = `MEMCONTROL_OP_WRITE;
//     #120;
//     pc_addr_i = 32'h0000_0000;
//     mem_addr_i = 32'h2222_2222;
//     mem_data_i = 32'h3333_3333;
//     mem_data_sz_i = `MEMECONTROL_OP_WORD;
//     mem_op_i = `MEMCONTROL_OP_WRITE;
//     #120;
//     pc_addr_i = 32'h0000_0000;
//     mem_addr_i = 32'h2222_2222;
//     mem_data_i = 32'h2222_2222;
//     mem_data_sz_i = `MEMECONTROL_OP_WORD;
//     mem_op_i = `MEMCONTROL_OP_READ;
//     #120;
//     pc_addr_i = 32'h2222_2222;
//     mem_addr_i = 32'h2222_2222;
//     mem_data_i = 32'h2222_2222;
//     mem_data_sz_i = `MEMECONTROL_OP_WORD;
//     mem_op_i = `MEMCONTROL_OP_NOP;
//     #60;
//     pc_addr_i = 32'h0000_0000;
//     mem_addr_i = 32'h2222_2221;
//     mem_data_i = 32'h4444_4444;
//     mem_data_sz_i = `MEMECONTROL_OP_BYTE;
//     mem_op_i = `MEMCONTROL_OP_WRITE;
//     #160;
//     pc_addr_i = 32'h2222_2222;
//     mem_addr_i = 32'h2222_2222;
//     mem_data_i = 32'h5555_5555;
//     mem_data_sz_i = `MEMECONTROL_OP_HALF_WORD;
//     mem_op_i = `MEMCONTROL_OP_WRITE;
//     #160;
//     pc_addr_i = 32'h0000_0000;
//     mem_addr_i = 32'h2222_2222;
//     mem_data_i = 32'h2222_2222;
//     mem_data_sz_i = `MEMECONTROL_OP_HALF_WORD;
//     mem_op_i = `MEMCONTROL_OP_READ;
//     #120;
// end


MemControl mem_control(
    .clk(clk_50M),
	.rst(rst),
	.pc_addr_i(pc_addr_i),
	.mem_addr_i(mem_addr_i),
    .mem_data_i(mem_data_i),
    .mem_data_sz_i(mem_data_sz_i),
    .mem_op_i(mem_op_i),
    .mem_enabled(mem_enabled),
    .mmu_result_i(result_o),
    .mmu_pause_i(pause_pipeline_o),
    .op_o(op_i),
    .addr_o(addr_i),
    .data_o(data_i),
    .enable_o(enable_i),
    .pc_data_o(pc_data_o),
    .mem_data_o(mem_data_o),
    .mem_data_valid_o(mem_data_valid_o),
    .pause_pipeline_o(pause_pipeline_final_o)
    );

MMUControl mmu_control(
	.clk(clk_50M),
	.rst(rst),
    .op_i(op_i),
	.addr_i(addr_i),
    .enable_i(enable_i),

	.data_i(data_i),
	.sram_data_i(sram_data_i),
    .flash_result_i(flash_result_i),
	.pause_from_flash_i(pause_from_flash_i),
	.rom_result_i(rom_data),
	.serial_data_i(serial_data_i),
    // TLB
    
    .cp0_index_i(cp0_index_i),
    .cp0_entryhi_i(cp0_entryhi_i),
    .cp0_entrylo0_i(cp0_entrylo0_i),
    .cp0_entrylo1_i(cp0_entrylo1_i),
    .cp0_random_i(cp0_random_i),
    // cp0 data bypass
    .mem_wb_o_cp0_reg_write_addr_i(mem_wb_o_cp0_reg_write_addr_i),
    .mem_wb_o_cp0_reg_data_i(mem_wb_o_cp0_reg_data_i),
    .mem_wb_o_cp0_reg_we_i(mem_wb_o_cp0_reg_we_i),

	.sram_enabled(sram_enabled),
	.sram_op(sram_op),
	.sram_data(sram_data),
	.sram_addr(sram_addr),

    .flash_enabled(flash_enabled),
	.flash_op(flash_op),
	.flash_addr(flash_addr),
	.rom_enabled(rom_enabled),
	.rom_addr(rom_addr),

	.serial_op(serial_op),
	.serial_data(serial_data),
	.serial_mode(serial_mode),

	.result_o(result_o),
	.pause_pipeline_o(pause_pipeline_o),
    .tlb_exception_o(tlb_exc_o),
    .tlb_op_i(tlb_op_i)
	);

SRAMControl sram_control(
            .clk(clk_50M),
            .rst(rst),
            .enabled_i(sram_enabled),
            .op_i(sram_op),
            .data_i(sram_data), 
            .addr_i(sram_addr),
            .result_o(sram_data_i), 
    // control signal to sram
            .ram1_data(ram1_data),
            .ram1_addr(ram1_addr),
            .ram1_ce_o(ram1_ce_n),
            .ram1_oe_o(ram1_oe_n),
            .ram1_we_o(ram1_we_n),
            .ram1_be(ram1_be_n),
            .ram2_data(ram2_data),
            .ram2_addr(ram2_addr),
            .ram2_ce_o(ram2_ce_n),
            .ram2_oe_o(ram2_oe_n),
            .ram2_we_o(ram2_we_n),
            .ram2_be(ram2_be_n)
    );

SerialControl serial_control(
            .clk(clk_50M),
            .rst(rst),

            .op_i(serial_op),
            .mode_i(serial_mode),
            .data_i(serial_data),
            .result_o(serial_data_i),
            .serial_excp(serial_excp),

            .RxD(RxD),
            .TxD(TxD)
    );

FlashControl flash_control(
    .clock(clk_50M),
    .rst(rst),
    .enabled_i(flash_enabled),
    .op_i(flash_op),
    .addr_i(flash_addr),
    .result_o(flash_result_i),
    .pause_from_flash(pause_from_flash_i),
    .flash_a(flash_a),
    .flash_d(flash_d),
    .flash_rp_n(flash_rp_n),
    .flash_vpen(flash_vpen),
    .flash_ce_n(flash_ce_n),
    .flash_oe_n(flash_oe_n),
    .flash_we_n(flash_we_n),
    .flash_byte_n(flash_byte_n)
);

rom ROM(
    .ce(rom_enabled),
    .addr(rom_addr),
    .inst(rom_data)
);
endmodule

