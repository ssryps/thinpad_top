`timescale 1ns / 1ns
`include "MemoryUtils.v"
module test_flash_control;

wire clk_50M, clk_11M0592;
wire [22:0]flash_a;
wire [15:0]flash_d;
wire flash_rp_n;
wire flash_vpen;
wire flash_ce_n;
wire flash_oe_n;
wire flash_we_n;
wire flash_byte_n;

reg rst;
reg flash_enabled;
reg flash_op;
reg[`FLASHCONTROL_ADDR_LEN - 1:0] flash_addr;
wire[31:0] flash_result_i;
wire pause_from_flash_i;

initial begin
    rst = 1;
    flash_enabled = 1;
    flash_addr   = 22'h0;
    #140;
    rst  = 0;
    flash_op = 1'b1;
    flash_addr   = 22'h2;
    #90;
    flash_addr   = 22'h0;
    #100;
    flash_addr   = 22'h1;
    #120;
    flash_enabled = 1'b0;
    
    

end

parameter FLASH_INIT_FILE = "/home/yw-zhang/Desktop/kernel.elf";    //Flash初始化文件，请修改为实际的绝对路径

clock osc(
    .clk_11M0592(clk_11M0592),
    .clk_50M    (clk_50M)
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

endmodule
