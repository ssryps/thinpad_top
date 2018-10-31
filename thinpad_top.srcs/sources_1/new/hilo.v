`include "defines.v"

module hilo(

	input wire clk,
	input wire rst,
	
    input wire writeEnable_i,
    input wire[`RegBus] writeHi_i,
    input wire[`RegBus] writeLo_i,

    output reg[`RegBus] dataHi_o,
    output reg[`RegBus] dataLo_o
);

	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
            dataHi_o <= `ZeroWord;
            dataLo_o <= `ZeroWord;
		end 
        else if (writeEnable_i == `WriteEnable) begin
			dataHi_o <= writeHi_i;
            dataLo_o <= writeLo_i;
		end    //if
	end      //always
			
endmodule