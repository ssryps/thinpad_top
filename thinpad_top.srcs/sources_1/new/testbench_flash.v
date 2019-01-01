`include "defines.v"
`include "MemoryUtils.v"

module closemips_testbench;
//module openmips_min_sopc(
//  input wire clk,
//  input wire rst
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
wire[5:0]    mem_data_sz_i; 
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

wire [22:0]flash_a;      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
wire [15:0]flash_d;      //Flash数据
wire flash_rp_n;         //Flash复位信号，低有效
wire flash_vpen;         //Flash写保护信号，低电平时不能擦除、烧写
wire flash_ce_n;         //Flash片选信号，低有效
wire flash_oe_n;         //Flash读使能信号，低有效
wire flash_we_n;         //Flash写使能信号，低有效
wire flash_byte_n;       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

parameter FLASH_INIT_FILE = "/home/yw-zhang/Desktop/main.elf";    //Flash初始化文件，请修改为实际的绝对路径

wire my_clk_50M, my_clk_11M0592;
reg rst;

initial begin
  rst = 1;
  #200;
  rst = 0;
  #1000;
  rst = 0;
end

clock osc0 (
    .clk_11M0592(my_clk_11M0592),
    .clk_50M    (my_clk_50M)
);

thinpad_top thinpad_top__ (
    .clk_50M(my_clk_50M),
    .clk_11M0592(my_clk_11M0592),
    .reset_btn(rst),
    .base_ram_data(ram1_data),
    .base_ram_addr(ram1_addr),
    .base_ram_be_n(ram1_be_n),
    .base_ram_ce_n(ram1_ce_n),
    .base_ram_oe_n(ram1_oe_n),
    .base_ram_we_n(ram1_we_n),

    .ext_ram_data(ram2_data),
    .ext_ram_addr(ram2_addr),
    .ext_ram_be_n(ram2_be_n),
    .ext_ram_ce_n(ram2_ce_n),
    .ext_ram_oe_n(ram2_oe_n),
    .ext_ram_we_n(ram2_we_n),
    
    .flash_d(flash_d),
    .flash_a(flash_a),
    .flash_rp_n(flash_rp_n),
    .flash_vpen(flash_vpen),
    .flash_oe_n(flash_oe_n),
    .flash_ce_n(flash_ce_n),
    .flash_byte_n(flash_byte_n),
    .flash_we_n(flash_we_n)
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
            
x28fxxxp30 #(.FILENAME_MEM(FLASH_INIT_FILE)) flash(
            .A(flash_a[1+:22]), 
            .DQ(flash_d), 
            .W_N(flash_we_n),    // Write Enable 
            .G_N(flash_oe_n),    // Output Enable
            .E_N(flash_ce_n),    // Chip Enable
            .L_N(1'b0),    // Latch Enable
            .K(1'b0),      // Clock
            .WP_N(flash_vpen),   // Write Protect
            .RP_N(flash_rp_n),   // Reset/Power-Down
            .VDD('d3300), 
            .VDDQ('d3300), 
            .VPP('d1800), 
            .Info(1'b1));

initial begin 
    wait(flash_byte_n == 1'b0);
    $display("8-bit Flash interface is not supported in simulation!");
    $display("Please tie flash_byte_n to high");
    $stop;
end


endmodule
