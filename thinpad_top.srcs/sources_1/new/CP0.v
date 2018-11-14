`include "defines.v"

module CP0 (
	input clk,    // Clock
	input rst,  // Asynchronous reset active low
	

	input wire[4:0] read_addr_i,
	input wire read_enabled,
	output wire[`RegBus] read_data_o,

	input wire[4:0] write_addr_i,
	input wire write_enabled,
	input wire[`RegBus] write_data_i,

	output wire[`RegBus] cp0_status_o
	output wire[`RegBus] cp0_cause_o
	output wire[`RegBus] cp0_epc_o,

);

    reg[31:0] cp0_registers[31:0];

	always @(posedge clk) begin
        if(rst) begin
                cp0_registers[0] <= 0;
                cp0_registers[1] <= 0;
                cp0_registers[2] <= 0;
                cp0_registers[3] <= 0;
                cp0_registers[4] <= 0;
                cp0_registers[5] <= 0;
                cp0_registers[6] <= 0;
                cp0_registers[7] <= 0;
                cp0_registers[8] <= 0;
                cp0_registers[9] <= 0;
                cp0_registers[10] <= 0;
                cp0_registers[11] <= 0;
                cp0_registers[12] <= 0;
                cp0_registers[13] <= 0;
                cp0_registers[14] <= 0;
                cp0_registers[15] <= 0;
                cp0_registers[16] <= 0;
                cp0_registers[17] <= 0;
                cp0_registers[18] <= 0;
                cp0_registers[19] <= 0;
                cp0_registers[20] <= 0;
                cp0_registers[21] <= 0;
                cp0_registers[22] <= 0;
                cp0_registers[23] <= 0;
                cp0_registers[24] <= 0;
                cp0_registers[25] <= 0;
                cp0_registers[26] <= 0;
                cp0_registers[27] <= 0;
                cp0_registers[28] <= 0;
                cp0_registers[29] <= 0;
                cp0_registers[30] <= 0;
                cp0_registers[31] <= 0;
                                
        end else begin
            if(write_enable == 1) begin 
            	case (write_addr_i)
            		`CP0_STATUS: begin
            			cp0_registers[`CP0_STATUS] <= write_data_i;
            		end
            		`CP0_EPC: begin
            			cp0_registers[`CP0_EPC] <= write_data_i;
            		end
            		`CP0_CAUSE: begin
            			// only some part can be written
            			cp0_registers[`CP0_CAUSE][9:8] <= write_data_i[9:8];
						cp0_registers[`CP0_CAUSE][23:22] <= write_data_i[23:22];
            		end
            	endcase
                cp0_registers[write_addr] = write_data; 
            end           
        end
    end



	// register read

	assign cp0_epc_o = cp0_registers[`CP0_EPC];
	assign cp0_cause_o = cp0_registers[`CP0_CAUSE];
	assign cp0_status_o = cp0_registers[`CP0_STATUS];


    always @(*) begin
        read_data_o <= `ZeroWord;
        if (read_enabled == 1 && writeEnable_i == 1 && readAddr_i == writeAddr_i) begin
            read_data_o <= write_data_i;
        end else if (read_enabled == 1) begin
            read_data_o <= regs[read_addr_i];
        end 
    end

endmodule