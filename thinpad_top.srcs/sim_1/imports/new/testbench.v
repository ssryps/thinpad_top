`include "defines.v"
`include "MemoryUtils.v"

module closemips_testbench;
//module openmips_min_sopc(
//	input wire clk,
//	input wire rst
//
//);

wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;

// wire mem_we_i;
// wire[`RegBus] mem_addr_i;
// wire[`RegBus] mem_data_i;
// wire[`RegBus] mem_data_o;
// wire[3:0] mem_sel_i;  
// wire mem_ce_i;  

wire[`MEMCONTROL_ADDR_LEN - 1:0] pc_addr_i;
wire[31:0] mem_addr_i;
wire[31:0] mem_data_i;
wire[5:0]	 mem_data_sz_i;	
wire[`MEMCONTROL_OP_LEN - 1:0] mem_op_i;
wire mem_enabled;

wire[31:0] pc_data_o;
wire[31:0] mem_data_o;
wire pause_pipeline_final_o;

// signal to outer devices
wire[31:0] ram1_data;  //BaseRAM数据，低8位与CPLD串口控制器共享
wire[19:0] ram1_addr; //BaseRAM地址
wire[3:0] ram1_be_n;  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
wire ram1_ce_n;       //BaseRAM片选，低有效
wire ram1_oe_n;       //BaseRAM读使能，低有效
wire ram1_we_n;       //BaseRAM写使能，低有效

//ExtRAM信号
wire[31:0] ram2_data;  //ExtRAM数据
wire[19:0] ram2_addr; //ExtRAM地址
wire[3:0] ram2_be_n;  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
wire ram2_ce_n;       //ExtRAM片选，低有效
wire ram2_oe_n;       //ExtRAM读使能，低有效
wire ram2_we_n;       //ExtRAM写使能，低有效




wire my_clk_50M, my_clk_11M0592;
reg rst;

initial begin
  rst = 1;
  #20;
  rst = 0;
  #1000;
  rst = 0;
end

clock osc0 (
    .clk_11M0592(my_clk_11M0592),
    .clk_50M    (my_clk_50M)
);

closemips closemips0(
	.clk(my_clk_50M),
	.rst(rst),

	.rom_addr_o(inst_addr),
	.rom_data_i(inst),
	.rom_ce_o(rom_ce),

	.mem_addr_o(mem_addr_i),
	.mem_data_o(mem_data_i),
	.mem_data_sz_o(mem_data_sz_i),
	.mem_op_o(mem_op_i),
    .mem_enabled(mem_enabled),
	.mem_data_i(mem_data_o),
	.mem_pause_pipeline_i(pause_pipeline_final_o)
);

//inst_rom inst_rom0(
//	.ce(rom_ce),
//	.addr(inst_addr),
//	.inst(inst)	
//);

// ram ram0(
// 	.clk(my_clk_50M),
// 	.we(mem_we_i),
// 	.addr(mem_addr_i),
// 	.sel(mem_sel_i),
// 	.data_i(mem_data_i),
// 	.data_o(mem_data_o),
// 	.ce(mem_ce_i)	
// );
closemem closemem0(
	.clk_50M(my_clk_50M),
	.rst(rst),
	.pc_addr_i(inst_addr),
	.mem_addr_i(mem_addr_i),
	.mem_data_i(mem_data_i),
	.mem_data_sz_i(mem_data_sz_i),
	.mem_op_i(mem_op_i),

	.pc_data_o(inst),
	.mem_data_o(mem_data_o),
	.pause_pipeline_final_o(pause_pipeline_final_o),

	.ram1_data(ram1_data),
	.ram1_addr(ram1_addr),
	.ram1_be_n(ram1_be_n),
	.ram1_ce_n(ram1_ce_n),
	.ram1_oe_n(ram1_oe_n),
	.ram1_we_n(ram1_we_n),

	.ram2_data(ram2_data),
	.ram2_addr(ram2_addr),
	.ram2_be_n(ram2_be_n),
	.ram2_ce_n(ram2_ce_n),
	.ram2_oe_n(ram2_oe_n),
	.ram2_we_n(ram2_we_n)

	);


sram_model2 base1(/*autoinst*/
            .DataIO(ram1_data[15:0]),
            .Address(ram1_addr[19:0]),
            .OE_n(ram1_oe_n),
            .CE_n(ram1_ce_n),
            .WE_n(ram1_we_n),
            .LB_n(ram1_be_n[0]),
            .UB_n(ram1_be_n[1])
            );
sram_model1 base2(/*autoinst*/
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
