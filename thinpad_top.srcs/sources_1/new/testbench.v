`include "defines.v"

module closemips_testbench;
//module openmips_min_sopc(
//	input wire clk,
//	input wire rst
//
//);

wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;

wire my_clk_50M, my_clk_11M0592;
reg rst;

initial begin
  rst = 1;
  #20;
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
	.rom_ce_o(rom_ce)

);

inst_rom inst_rom0(
	.ce(rom_ce),
	.addr(inst_addr),
	.inst(inst)	
);

endmodule
