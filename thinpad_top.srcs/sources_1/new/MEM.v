`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/26/2018 12:16:51 PM
// Design Name:
// Module Name: MEM
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
`include "defines.v"
`include "MemoryUtils.v"

`define OP_HALF_UNSIGNED 3'b000
`define OP_HALF_SIGNED   3'b001
`define OP_BYTE_UNSIGNED 3'b010
`define OP_BYTE_SIGNED   3'b011
`define OP_WORD 		 3'b100
`define OP_NOP  		 3'b101

module MEM(
	input wire clk_i,
    input wire rst_i,
    input wire [`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire [`RegBus] wdata_i,

    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,
    input wire whilo_i,

    //for load and store
    input wire[`AluOpBus] aluop_i,
	input wire[`RegBus] mem_addr_i,
	input wire[`RegBus] reg2_i,

    input wire[`RegBus] mem_data_i,
    input wire mem_pause_pipeline_i,

    output reg [`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg [`RegBus] wdata_o,

    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o,
    output reg whilo_o,

    //for load and store
    output reg[`RegBus] mem_addr_o,
	output reg[`MEMCONTROL_OP_LEN - 1:0] mem_op_o,
	output reg[5:0] mem_data_sz_o,
	output reg[`RegBus] mem_data_o,
	output reg mem_enabled,

	output wire stallreq_o, 


	input wire cp0_reg_we_i,
	input wire[4:0] cp0_reg_write_addr_i,
	input wire[31:0] cp0_reg_data_i,
	output wire cp0_reg_we_o,
	output wire[4:0] cp0_reg_write_addr_o,
	output wire[31:0] cp0_reg_data_o,

	input wire[`RegBus] excp_type_i,
	input wire[`RegBus] excp_inst_addr_i, 
	input wire excp_in_delay_slot_i, 

	output reg[`RegBus] excp_type_o,
	output wire[`RegBus] excp_inst_addr_o, 
	output wire excp_in_delay_slot_o,
	output reg[`RegBus] excp_bad_addr,

	input wire[`RegBus] cp0_status_i,
	input wire[`RegBus] cp0_cause_i,
	input wire[`RegBus] cp0_epc_i
	);
	reg mem_we;

	reg[3:0] last_op;
	reg[5:0] last_sz;
	reg[1:0] last_pos;

	reg cur_state;

	reg[4:0] cp0_reg_write_addr_o_reg;
	reg cp0_reg_we_o_reg;
    reg[31:0] cp0_reg_data_o_reg;

	reg is_load_bad_addr, is_store_bad_addr;
	reg[`RegBus] bad_addr;

    assign cp0_reg_we_o = cp0_reg_we_o_reg;
	assign cp0_reg_write_addr_o = cp0_reg_write_addr_o_reg;
    assign cp0_reg_data_o = cp0_reg_data_o_reg;


	assign stallreq_o = mem_pause_pipeline_i;

	always @(posedge clk_i) begin
		if(rst_i==`RstEnable) begin
			cur_state <= 1'b1;
			last_op <= `OP_NOP;
		end else begin 
			if(mem_pause_pipeline_i == 1'b0)begin
				cur_state <= 1'b1;
				
		    end else if(cur_state == 1'b1) begin
				cur_state <= 1'b0;
				last_op <= `OP_NOP;
				case (aluop_i)
					`EXE_LB_OP:		begin
			            last_op <= `OP_BYTE_SIGNED;
			            last_pos <= mem_addr_i[1:0];
					end
					`EXE_LBU_OP:		begin
			            last_op <= `OP_BYTE_UNSIGNED;
			            last_pos <= mem_addr_i[1:0];
					end
					`EXE_LH_OP:		begin
			            last_op <= `OP_HALF_SIGNED;
			            last_pos <= mem_addr_i[1:0];
					end
					`EXE_LHU_OP:		begin
			            last_op <= `OP_HALF_UNSIGNED;
			            last_pos <= mem_addr_i[1:0];
					end
					`EXE_LW_OP:		begin
			            last_op <= `OP_WORD;
			            last_pos <= mem_addr_i[1:0];
					end
				endcase
			end
		end
	    
	end



    always @(*) begin
        if (rst_i==`RstEnable) begin
            wd_o<=`NOPRegAddr;
            wreg_o<=`WriteDisable;
           // wdata_o<=`ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;
            mem_addr_o <= `ZeroWord;
            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
            mem_data_o <= `ZeroWord;
            mem_op_o <= `MEMCONTROL_OP_NOP;	
            //cur_state <= 0; 
			cp0_reg_write_addr_o_reg <= 5'b00000;
            cp0_reg_we_o_reg<= `WriteDisable;
            cp0_reg_data_o_reg <= 32'b00000000_00000000_00000000_00000000;
			is_load_bad_addr <= 0;
			is_store_bad_addr <= 0;

        end else begin
		    wdata_o<=wdata_i;
            wd_o<=wd_i;
            wreg_o<=wreg_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            whilo_o <= whilo_i;
	        // mem_addr_o <= `ZeroWord;
	        // mem_data_sz_o <= `MEMECONTROL_OP_WORD;
	        // mem_data_o <= `ZeroWord;
	        // mem_op_o <= `MEMCONTROL_OP_NOP;	
            //wdata_o <= mem_data_i;
    		cp0_reg_data_o_reg <= cp0_reg_data_i;
			cp0_reg_write_addr_o_reg <= cp0_reg_write_addr_i;
			cp0_reg_we_o_reg <= cp0_reg_we_i;
			is_load_bad_addr <= 1'b0;
            is_store_bad_addr <= 1'b0;
           
            if(mem_pause_pipeline_i == 0) begin

				if(last_op == `OP_BYTE_UNSIGNED) begin
		        	case (last_pos)
						2'b11:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
						end
						2'b10:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
						end
						2'b01:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
						end
						2'b00:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
						end
						default:  begin
							wdata_o <= `ZeroWord;
						end
					endcase	
		        end else if(last_op == `OP_BYTE_SIGNED) begin
		     		case (last_pos)
						2'b11:	begin
							wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
						end
						2'b10:	begin
							wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
						end
						2'b01:	begin
							wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
						end
						2'b00:	begin
							wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase	

				end else if(last_op == `OP_HALF_UNSIGNED) begin
			    	case (last_pos)
						2'b10:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[31:16]};
						end
						2'b00:	begin
							wdata_o <= {{24{1'b0}},mem_data_i[15:0]};
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase	

				end else if(last_op == `OP_HALF_SIGNED) begin
		    		case (last_pos)
						2'b10:	begin
							wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:16]};
						end
						2'b00:	begin
							wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:0]};
						end
						default:	begin
							wdata_o <= `ZeroWord;
						end
					endcase	
		
				end else if(last_op == `OP_WORD) begin
					wdata_o <= mem_data_i;
				end
            end


            if(cur_state == 1) begin
                case (aluop_i)
					`EXE_LB_OP:		begin
			            mem_addr_o <= mem_addr_i;
			            mem_data_sz_o <= `MEMECONTROL_OP_BYTE;
			            mem_data_o <= reg2_i;
			            mem_op_o <= `MEMCONTROL_OP_READ;	
					end
					`EXE_LBU_OP:		begin
			            mem_addr_o <= mem_addr_i;
			            mem_data_sz_o <= `MEMECONTROL_OP_BYTE;
			            mem_data_o <= reg2_i;
			            mem_op_o <= `MEMCONTROL_OP_READ;	
					end
					`EXE_LH_OP:		begin
						if(mem_addr_i[0] == 0) begin 							
				            mem_addr_o <= mem_addr_i;
				            mem_data_sz_o <= `MEMECONTROL_OP_HALF_WORD;
				            mem_data_o <= reg2_i;
				            mem_op_o <= `MEMCONTROL_OP_READ;	
						end else begin 
							mem_addr_o <= `ZeroWord;
				            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
				            mem_data_o <= `ZeroWord;
				            mem_op_o <= `MEMCONTROL_OP_NOP;	
				            is_load_bad_addr <= 1;
				            bad_addr <= mem_addr_i;
						end
					end

					`EXE_LHU_OP:		begin
			            if(mem_addr_i[0] == 0) begin 							
					        mem_addr_o <= mem_addr_i;
				            mem_data_sz_o <= `MEMECONTROL_OP_HALF_WORD;
				            mem_data_o <= reg2_i;
				            mem_op_o <= `MEMCONTROL_OP_READ;	
						end else begin 
							mem_addr_o <= `ZeroWord;
				            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
				            mem_data_o <= `ZeroWord;
				            mem_op_o <= `MEMCONTROL_OP_NOP;	
				            is_load_bad_addr <= 1;
					        bad_addr <= mem_addr_i;
					
						end

					end
					`EXE_LW_OP:		begin
			            if(mem_addr_i[1:0] == 2'b00) begin 							
				            mem_addr_o <= mem_addr_i;
				            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
				            mem_data_o <= reg2_i;
				            mem_op_o <= `MEMCONTROL_OP_READ;	
						end else begin 
							mem_addr_o <= `ZeroWord;
				            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
				            mem_data_o <= `ZeroWord;
				            mem_op_o <= `MEMCONTROL_OP_NOP;	
				            is_load_bad_addr <= 1;
					        bad_addr <= mem_addr_i;

						end

					end
	
					`EXE_SB_OP:		begin
			            mem_addr_o <= mem_addr_i;
			            mem_data_sz_o <= `MEMECONTROL_OP_BYTE;
			            mem_data_o <= reg2_i;
			            mem_op_o <= `MEMCONTROL_OP_WRITE;	
			
					end
					`EXE_SH_OP:		begin
			            if(mem_addr_i[0] == 0) begin 							
						    mem_addr_o <= mem_addr_i;
				            mem_data_sz_o <= `MEMECONTROL_OP_HALF_WORD;
				            mem_data_o <= reg2_i;
				            mem_op_o <= `MEMCONTROL_OP_WRITE;	
			            end else begin 
							mem_addr_o <= `ZeroWord;
				            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
				            mem_data_o <= `ZeroWord;
				            mem_op_o <= `MEMCONTROL_OP_NOP;	
				            is_store_bad_addr <= 1;
					        bad_addr <= mem_addr_i;

						end
					end
					`EXE_SW_OP:		begin
			            if(mem_addr_i[1:0] == 2'b00) begin 							
					        mem_addr_o <= mem_addr_i;
				            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
				            mem_data_o <= reg2_i;
				            mem_op_o <= `MEMCONTROL_OP_WRITE;	
						end else begin 
							mem_addr_o <= `ZeroWord;
				            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
				            mem_data_o <= `ZeroWord;
				            mem_op_o <= `MEMCONTROL_OP_NOP;	
				            is_store_bad_addr <= 1;

					        bad_addr <= mem_addr_i;
						end
					end
					
	
					default:		begin
				     	mem_addr_o <= `ZeroWord;
			            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
			            mem_data_o <= `ZeroWord;
			            mem_op_o <= `MEMCONTROL_OP_NOP;	
					end
				endcase	
        	end
		end
    end

    //exception handler 
    assign excp_in_delay_slot_o = excp_in_delay_slot_i;
    assign excp_inst_addr_o = excp_inst_addr_i;

    always @(*) begin
        excp_type_o <= `ZeroWord;
        excp_bad_addr <= `ZeroWord;
    	if (rst_i==`RstEnable || excp_inst_addr_i == `ZeroWord) begin
            // No necessary reset
    	end else begin
    		if(excp_type_i[`EXCP_BAD_PC_ADDR] == 1) begin 
	    		if((cp0_status_i[1] == 0) ) begin //&& (cp0_status_i[0] == 1)
    	   			excp_type_o <= excp_type_i;
            	end
			end else if(excp_type_i[`EXCP_SYSCALL] == 1) begin 
	    		if((cp0_status_i[1] == 0) ) begin //&& (cp0_status_i[0] == 1)
    	   			excp_type_o <= excp_type_i;
            	end
			end else if(excp_type_i[`EXCP_BREAK] == 1) begin 
                if((cp0_status_i[1] == 0) ) begin //&& (cp0_status_i[0] == 1)
    	  			excp_type_o <= excp_type_i;
              	end       
			end else if(excp_type_i[`EXCP_INVALID_INST] == 1) begin 
                if((cp0_status_i[1] == 0) ) begin //&& (cp0_status_i[0] == 1)
    	  			excp_type_o <= excp_type_i;
              	end       
            end else if(excp_type_i[`EXCP_OVERFLOW] == 1) begin 
	            if((cp0_status_i[1] == 0) ) begin //&& (cp0_status_i[0] == 1)
    	  			excp_type_o <= excp_type_i;
              	end       
            end else if(excp_type_i[`EXCP_ERET] == 1) begin 
                //if((cp0_status_i[1] == 1) ) begin //&& (cp0_status_i[0] == 1)
    	  			excp_type_o <= excp_type_i;
              	//end       
            end else if(is_load_bad_addr == 1 || is_store_bad_addr == 1) begin 
            	if((cp0_status_i[1] == 0) ) begin //&& (cp0_status_i[0] == 1)
    	  			excp_type_o <= {excp_type_i[31:`EXCP_BAD_STORE_ADDR + 1], is_store_bad_addr, is_load_bad_addr, excp_type_i[`EXCP_BAD_LOAD_ADDR - 1: 0]};
    	  			excp_bad_addr <= bad_addr;
              	end
            end
    	end
    
    end

    always @(*) begin 
    	if(excp_type_o != `ZeroWord) begin 
    		mem_enabled <= 1'b0;
    	end else begin 
    		mem_enabled <= 1'b1;
    	end
    end

endmodule
