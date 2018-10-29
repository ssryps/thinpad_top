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

module test_MMUControl;
wire clk_50M, clk_11M0592;
reg rst;

reg[`MEMCONTROL_OP_LEN - 1  : 0]	op_i;
reg[`MEMCONTROL_ADDR_LEN - 1 : 0] 	addr_i;
reg[31:0]						data_i;

reg 						      sram_enabled;
reg[`SRAMCONTROL_OP_LEN   - 1: 0] sram_op;
reg[`SRAMCONTROL_DATA_LEN - 1: 0] sram_data;
reg[`SRAMCONTROL_ADDR_LEN - 1: 0] sram_addr;
	
	// Serial
reg									serial_enabled;
reg[`SERIALCONTROL_OP_LEN - 1: 0]   serial_op;
reg[`SERIALCONTROL_DATA_LEN - 1: 0]	serial_data;
reg[`SERIALCONTROL_ADDR_LEN - 1: 0]	serial_addr;

// output to Memcontrol

reg[31:0] result_o;
reg pause_pipeline_o;


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
    #30;
    rst  = 0;
    op_i = `MEMCONTROL_OP_WRITE;
    addr_i   = {11'h0000, 21'h111111};
    data_i = 32'h88888888;
    #20;
    op_i = `MEMCONTROL_OP_READ;
    #20 ;
    rst  = 0;
    op_i = `MEMCONTROL_OP_WRITE;
    addr_i   = {11'h0000, 21'h011111};
    data_i = 32'h11111111;
    #40;
    op_i = `MEMCONTROL_OP_READ;
    addr_i   = {11'h0000, 21'h011111};
    #40 ;   
    op_i = `MEMCONTROL_OP_READ;
    addr_i  = {11'h0000, 21'h111111};

end


clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
);


MMUControl mmu_control(
	.clk(clk_50M),
	.rst(rst),
	.op_i(op_i),
	.addr_i(addr_i),
	.data_i(data_i),
	.sram_enabled(sram_enabled),
	.sram_op(sram_op),
	.sram_data(sram_data),
	.sram_addr(sram_addr),
	.serial_enabled(serial_enabled),
	.serial_op(serial_op),
	.serial_data(serial_data),
	.serial_addr(serial_addr)
	);

SRAMControl sram_control(
            .clk(clk_50M),
            .rst(rst),
            .enabled_i(sram_enabled),
            .op_i(sram_op),
            .data_i(sram_data), 
            .addr_i(sram_addr),
            .result_o(result_o), 
    // control signal to sram
            .ram1_data(ram1_data),
            .ram1_addr(ram1_addr),
            .ram1_ce(ram1_ce_n),
            .ram1_oe(ram1_oe_n),
            .ram1_we(ram1_we_n),
            .ram1_be(ram1_be_n),
            .ram2_data(ram2_data),
            .ram2_addr(ram2_addr),
            .ram2_ce(ram2_ce_n),
            .ram2_oe(ram2_oe_n),
            .ram2_we(ram2_we_n),
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
