`include "defines.v"

module hilo(

	input wire clk,
	input wire rst,
	
    input wire writeEnable_i,
    input wire[`RegBus] writeHi_i,
    input wire[`RegBus] writeLo_i,

    output wire[`RegBus] dataHi_o,
    output wire[`RegBus] dataLo_o,
);
    wire[`RegBus] hi;
    wire[`RegBus] lo;

	always @ (posedge clk) begin
		if(rst == `RstEnable) begin
        
		end 
        else begin
					
		end    //if
	end      //always
			
endmodule