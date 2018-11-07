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
`define OP_NOP  		 3'b100

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

	output wire stallreq_o
	);
    wire[`RegBus] zero32;
	reg mem_we;

	reg[3:0] last_op;
	reg[5:0] last_sz;
	reg[1:0] last_pos;

	reg cur_state;
	assign zero32 = `ZeroWord;
	assign stallreq_o = mem_pause_pipeline_i;

	always @(posedge clk_i) begin
		if(rst_i==`RstEnable) begin
			cur_state <= 1;
			last_op <= `OP_NOP;
		end else begin 
		    wdata_o<=wdata_i;
			if(mem_pause_pipeline_i == 0)begin
				cur_state <= 1;
				
		    end else if(cur_state == 1) begin
				cur_state <= 0;
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
            cur_state <= 0;
        end else begin
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
			            mem_addr_o <= mem_addr_i;
			            mem_data_sz_o <= `MEMECONTROL_OP_HALF_WORD;
			            mem_data_o <= reg2_i;
			            mem_op_o <= `MEMCONTROL_OP_READ;	
					end
					`EXE_LHU_OP:		begin
			            mem_addr_o <= mem_addr_i;
			            mem_data_sz_o <= `MEMECONTROL_OP_HALF_WORD;
			            mem_data_o <= reg2_i;
			            mem_op_o <= `MEMCONTROL_OP_READ;	
					end
					`EXE_LW_OP:		begin
			            mem_addr_o <= mem_addr_i;
			            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
			            mem_data_o <= reg2_i;
			            mem_op_o <= `MEMCONTROL_OP_READ;	

					end
	
					`EXE_SB_OP:		begin
			            mem_addr_o <= mem_addr_i;
			            mem_data_sz_o <= `MEMECONTROL_OP_BYTE;
			            mem_data_o <= reg2_i;
			            mem_op_o <= `MEMCONTROL_OP_WRITE;	
			
					end
					`EXE_SH_OP:		begin
			            mem_addr_o <= mem_addr_i;
			            mem_data_sz_o <= `MEMECONTROL_OP_HALF_WORD;
			            mem_data_o <= reg2_i;
			            mem_op_o <= `MEMCONTROL_OP_WRITE;	
					end
					`EXE_SW_OP:		begin
			            mem_addr_o <= mem_addr_i;
			            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
			            mem_data_o <= reg2_i;
			            mem_op_o <= `MEMCONTROL_OP_WRITE;	
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
endmodule
