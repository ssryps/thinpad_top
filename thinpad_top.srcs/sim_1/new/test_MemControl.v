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

module test_MemControl;
wire clk_50M, clk_11M0592;
reg rst;

reg[`MEMCONTROL_ADDR_LEN - 1:0] pc_addr_i;
reg[31:0] mem_addr_i;
reg[31:0] mem_data_i;
reg[5:0]	 mem_data_sz_i;	
reg[`MEMCONTROL_OP_LEN - 1:0] mem_op_i;
wire skip_next_edge;

wire[31:0] pc_data_o;
wire[31:0] mem_data_o;
wire pause_pipeline_final_o;

wire[`MEMCONTROL_OP_LEN - 1  : 0]	op_i;
wire[`MEMCONTROL_ADDR_LEN - 1 : 0] 	addr_i;
wire[31:0]						data_i;

wire [31:0] sram_data_i;
wire [31:0] serial_data_i;

wire 						      sram_enabled;
wire[`SRAMCONTROL_OP_LEN   - 1: 0] sram_op;
wire[`SRAMCONTROL_DATA_LEN - 1: 0] sram_data;
wire[`SRAMCONTROL_ADDR_LEN - 1: 0] sram_addr;
	
	// Serial
wire									serial_enabled;
wire[`SERIALCONTROL_OP_LEN - 1: 0]   serial_op;
wire[`SERIALCONTROL_DATA_LEN - 1: 0]	serial_data;
wire[`SERIALCONTROL_ADDR_LEN - 1: 0]	serial_addr;


wire[31:0] result_o;
wire pause_pipeline_o;

// output to Memcontrol

wire[31:0] ram1_data; //BaseRAM数据，低8位与CPLD串口控制器共享
wire[19:0] ram1_addr; //BaseRAM地址
wire ram1_ce_n;       //BaseRAM片选，低有效
wire ram1_oe_n;       //BaseRAM读使能，低有效
wire ram1_we_n;       //BaseRAM写使能，低有效
wire[3:0] ram1_be_n;  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0

wire[31:0] ram2_data; //BaseRAM数据，低8位与CPLD串口控制器共享
wire[19:0] ram2_addr; //BaseRAM地址
wire ram2_ce_n;       //BaseRAM片选，低有效
wire ram2_oe_n;       //BaseRAM读使能，低有效
wire ram2_we_n;       //BaseRAM写使能，低有效
wire[3:0] ram2_be_n;  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0



initial begin
    rst = 1;
    #20;
    rst  = 0;
    pc_addr_i = 32'h0000_0000;
    mem_addr_i = 32'h0000_0000;
    mem_data_i = 32'h1111_1111;
    mem_data_sz_i = `MEMECONTROL_OP_WORD;
    mem_op_i = `MEMCONTROL_OP_WRITE;
    #120;
    pc_addr_i = 32'h0000_0000;
    mem_addr_i = 32'h2222_2222;
    mem_data_i = 32'h3333_3333;
    mem_data_sz_i = `MEMECONTROL_OP_WORD;
    mem_op_i = `MEMCONTROL_OP_WRITE;
    #120;
    pc_addr_i = 32'h0000_0000;
    mem_addr_i = 32'h2222_2222;
    mem_data_i = 32'h2222_2222;
    mem_data_sz_i = `MEMECONTROL_OP_WORD;
    mem_op_i = `MEMCONTROL_OP_READ;
    #120;
    pc_addr_i = 32'h2222_2222;
    mem_addr_i = 32'h2222_2222;
    mem_data_i = 32'h2222_2222;
    mem_data_sz_i = `MEMECONTROL_OP_WORD;
    mem_op_i = `MEMCONTROL_OP_NOP;
      
end


clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
);

MemControl mem_control(
    .clk(clk_50M),
	.rst(rst),
	.pc_addr_i(pc_addr_i),
	.mem_addr_i(mem_addr_i),
    .mem_data_i(mem_data_i),
    .mem_data_sz_i(mem_data_sz_i),
    .mem_op_i(mem_op_i),
    .mmu_result_i(result_o),
    .pause_pipeline_i(pause_pipeline_o),
    .op_o(op_i),
    .addr_o(addr_i),
    .data_o(data_i),
    .pc_data_o(pc_data_o),
    .mem_data_o(mem_data_o),
    .pause_pipeline_o(pause_pipeline_final_o)
    );

MMUControl mmu_control(
	.clk(clk_50M),
	.rst(rst),
    .op_i(op_i),
	.addr_i(addr_i),
	.data_i(data_i),
	.sram_data_i(sram_data_i),
	.serial_data_i(serial_data_i),
	.sram_enabled(sram_enabled),
	.sram_op(sram_op),
	.sram_data(sram_data),
	.sram_addr(sram_addr),
	.serial_enabled(serial_enabled),
	.serial_op(serial_op),
	.serial_data(serial_data),
	.serial_addr(serial_addr),
	.result_o(result_o),
	.pause_pipeline_o(pause_pipeline_o)
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

sram_model base1(/*autoinst*/
            .DataIO(ram1_data[15:0]),
            .Address(ram1_addr[19:0]),
            .OE_n(ram1_oe_n),
            .CE_n(ram1_ce_n),
            .WE_n(ram1_we_n),
            .LB_n(ram1_be_n[0]),
            .UB_n(ram1_be_n[1])
            );
sram_model base2(/*autoinst*/
            .DataIO(ram1_data[31:16]),
            .Address(ram1_addr[19:0]),
            .OE_n(ram1_oe_n),
            .CE_n(ram1_ce_n),
            .WE_n(ram1_we_n),
            .LB_n(ram1_be_n[2]),
            .UB_n(ram1_be_n[3])
            );
sram_model base3(/*autoinst*/
                        .DataIO(ram2_data[15:0]),
                        .Address(ram2_addr[19:0]),
                        .OE_n(ram2_oe_n),
                        .CE_n(ram2_ce_n),
                        .WE_n(ram2_we_n),
                        .LB_n(ram2_be_n[0]),
                        .UB_n(ram2_be_n[1])
                        );
                        
sram_model base4(/*autoinst*/
            .DataIO(ram2_data[31:16]),
            .Address(ram2_addr[19:0]),
            .OE_n(ram2_oe_n),
            .CE_n(ram2_ce_n),
            .WE_n(ram2_we_n),
            .LB_n(ram2_be_n[2]),
            .UB_n(ram2_be_n[3])
            );

endmodule
