`include "defines.v"

module inst_rom(
	input wire ce,
	input wire[`InstAddrBus] addr,
	output reg[`InstBus] inst
);

reg[`InstBus] inst_mem[`InstMemNum:0];

initial $readmemh ( "inst_rom.data", inst_mem );

always @ (*) begin
	if (ce == `Disable) begin
		inst <= `ZeroWord;
	end else begin
		//inst <= inst_mem[addr[`InstMemNumLog2:2]-30'h00000000];
		inst <= inst_mem[addr[`InstMemNumLog2:2]-30'h20000000];
	end
end

endmodule
