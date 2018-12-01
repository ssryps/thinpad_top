`include "defines.v"

module CP0 (
	input clk,    // Clock
	input rst,  // Asynchronous reset active low
	

	input wire[4:0] read_addr_i,
	input wire read_enabled,
	output reg[`RegBus] read_data_o,

	input wire[4:0] write_addr_i,
	input wire write_enabled,
	input wire[`RegBus] write_data_i,

	output reg[`RegBus] cp0_status_o,
	output reg[`RegBus] cp0_cause_o,
	output reg[`RegBus] cp0_epc_o,
	output reg[`RegBus] cp0_ebase_o,

    input wire[`RegBus] excp_type_i,
    input wire[`RegBus] excp_inst_addr_i, 
    input wire excp_in_delay_slot_i,
    input wire[`RegBus] excp_bad_addr
    

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

                cp0_registers[`CP0_EBASE] <= `CP0_EBASE_ADDR;
                                
        end else begin
            if(write_enabled == 1) begin 
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
                cp0_registers[write_addr_i] <= write_data_i; 
            end           

            if(excp_type_i[`EXCP_BAD_LOAD_ADDR] == 1) begin 
                if(excp_in_delay_slot_i == 1) begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i - 4;
                    cp0_registers[`CP0_CAUSE][31] <= 1;
                end else begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i ;
                    cp0_registers[`CP0_CAUSE][31] <= 0;    
                end
                cp0_registers[`CP0_STATUS][1] <= 1;    
                cp0_registers[`CP0_CAUSE][6:2] <= 5'b00100;         

                cp0_registers[`CP0_BAD_ADDR] <= excp_bad_addr;       
            end

            if(excp_type_i[`EXCP_BAD_STORE_ADDR] == 1) begin 
                if(excp_in_delay_slot_i == 1) begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i - 4;
                    cp0_registers[`CP0_CAUSE][31] <= 1;
                end else begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i;
                    cp0_registers[`CP0_CAUSE][31] <= 0;    
                end
                cp0_registers[`CP0_STATUS][1] <= 1;    
                cp0_registers[`CP0_CAUSE][6:2] <= 5'b00101;                
                cp0_registers[`CP0_BAD_ADDR] <= excp_bad_addr;       

            end



            if(excp_type_i[`EXCP_SYSCALL] == 1) begin 
              //  if(cp0_registers[`CP0_STATUS][1] == 1) begin 
                    if(excp_in_delay_slot_i == 1) begin 
                        cp0_registers[`CP0_EPC] <= excp_inst_addr_i - 4;
                        cp0_registers[`CP0_CAUSE][31] <= 1;
                    end else begin 
                        cp0_registers[`CP0_EPC] <= excp_inst_addr_i;
                        cp0_registers[`CP0_CAUSE][31] <= 0;    
                    end
                //end
                cp0_registers[`CP0_STATUS][1] <= 1;    
                cp0_registers[`CP0_CAUSE][6:2] <= 5'b01000;                
            end

            if(excp_type_i[`EXCP_BREAK] == 1) begin 
              //  if(cp0_registers[`CP0_STATUS][1] == 1) begin 
                    if(excp_in_delay_slot_i == 1) begin 
                        cp0_registers[`CP0_EPC] <= excp_inst_addr_i - 4;
                        cp0_registers[`CP0_CAUSE][31] <= 1;
                    end else begin 
                        cp0_registers[`CP0_EPC] <= excp_inst_addr_i;
                        cp0_registers[`CP0_CAUSE][31] <= 0;    
                    end
                //end
                cp0_registers[`CP0_STATUS][1] <= 1;    
                cp0_registers[`CP0_CAUSE][6:2] <= 5'b01001;                
            end


            if(excp_type_i[`EXCP_INVALID_INST] == 1) begin 
                if(excp_in_delay_slot_i == 1) begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i - 4;
                    cp0_registers[`CP0_CAUSE][31] <= 1;
                end else begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i;
                    cp0_registers[`CP0_CAUSE][31] <= 0;    
                end
                cp0_registers[`CP0_STATUS][1] <= 1;    
                cp0_registers[`CP0_CAUSE][6:2] <= 5'b01010;                
            end

            if(excp_type_i[`EXCP_OVERFLOW] == 1) begin 
                if(excp_in_delay_slot_i == 1) begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i - 4;
                    cp0_registers[`CP0_CAUSE][31] <= 1;
                end else begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i;
                    cp0_registers[`CP0_CAUSE][31] <= 0;    
                end
                cp0_registers[`CP0_STATUS][1] <= 1;    
                cp0_registers[`CP0_CAUSE][6:2] <= 5'b01100;                
            end

            if(excp_type_i[`EXCP_ERET] == 1) begin 
                cp0_registers[`CP0_STATUS][1] <= 0;    
            end
                 
            if(excp_type_i[`EXCP_BAD_PC_ADDR] == 1) begin 
                if(excp_in_delay_slot_i == 1) begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i - 4;
                    cp0_registers[`CP0_CAUSE][31] <= 1;
                end else begin 
                    cp0_registers[`CP0_EPC] <= excp_inst_addr_i;
                    cp0_registers[`CP0_CAUSE][31] <= 0;    
                end
                cp0_registers[`CP0_STATUS][1] <= 1;    
                cp0_registers[`CP0_CAUSE][6:2] <= 5'b00100;      
                cp0_registers[`CP0_BAD_ADDR] <= excp_inst_addr_i;       
          
            end
           

        end
    end




    always @(*) begin
        if(rst) begin
            read_data_o <= `ZeroWord;
            cp0_epc_o <= `ZeroWord;
            cp0_cause_o <= `ZeroWord;
            cp0_status_o <= `ZeroWord;
            cp0_ebase_o <= cp0_registers[`CP0_EBASE];

        end else begin
            read_data_o <= `ZeroWord;
            if (read_enabled == 1 && write_enabled == 1 && read_addr_i == write_addr_i) begin
                read_data_o <= write_data_i;
            end else if (read_enabled == 1) begin
                read_data_o <= cp0_registers[read_addr_i];
            end 

            if(write_enabled == 1 && write_addr_i == `CP0_EPC) begin 
                cp0_epc_o <= write_data_i;
            end else begin
                cp0_epc_o <= cp0_registers[`CP0_EPC];
            end

            if(write_enabled == 1 && write_addr_i == `CP0_CAUSE) begin 
                cp0_cause_o <= write_data_i;
            end else begin
                cp0_cause_o <= cp0_registers[`CP0_CAUSE];
            end

            if(write_enabled == 1 && write_addr_i == `CP0_STATUS) begin 
                cp0_status_o <= write_data_i;
            end else begin
                cp0_status_o <= cp0_registers[`CP0_STATUS];
            end
            cp0_ebase_o <= cp0_registers[`CP0_EBASE];

        end
    end
endmodule