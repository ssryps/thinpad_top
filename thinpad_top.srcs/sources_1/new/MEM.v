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


	reg cur_state;
	assign zero32 = `ZeroWord;
	assign stallreq_o = mem_pause_pipeline_i;

	always @(posedge clk_i) begin
		if(rst_i==`RstEnable) begin
			cur_state <= 1;
		end else if(mem_pause_pipeline_i == 0)begin
			cur_state <= 1;
		end else if(cur_state == 1) begin
			cur_state <= 0;
		end
	end

    always @(*) begin
	    if (rst_i==`RstEnable) begin
            wd_o<=`NOPRegAddr;
            wreg_o<=`WriteDisable;
            wdata_o<=`ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;
            mem_addr_o <= `ZeroWord;
            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
            mem_data_o <= `ZeroWord;
            mem_op_o <= `MEMCONTROL_OP_NOP;	
            cur_state <= 0;
        end else if(cur_state == 1) begin
            wd_o<=wd_i;
            wreg_o<=wreg_i;
            wdata_o<=wdata_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            whilo_o <= whilo_i;
            mem_addr_o <= `ZeroWord;
            mem_data_sz_o <= `MEMECONTROL_OP_WORD;
            mem_data_o <= `ZeroWord;
            mem_op_o <= `MEMCONTROL_OP_NOP;	
            wdata_o <= mem_data_i;
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
				// `EXE_LWL_OP:		begin
		  //           mem_addr_o <= mem_addr_i;
		  //           mem_data_sz_o <= `MEMECONTROL_OP_BYTE;
		  //           mem_data_o <= mem_data_i;
		  //           mem_op_o <= `MEMCONTROL_OP_READ;	
				// 	case (mem_addr_i[1:0])
				// 		2'b00:	begin
				// 			wdata_o <= mem_data_i[31:0];
				// 		end
				// 		2'b01:	begin
				// 			wdata_o <= {mem_data_i[23:0],reg2_i[7:0]};
				// 		end
				// 		2'b10:	begin
				// 			wdata_o <= {mem_data_i[15:0],reg2_i[15:0]};
				// 		end
				// 		2'b11:	begin
				// 			wdata_o <= {mem_data_i[7:0],reg2_i[23:0]};	
				// 		end
				// 		default:	begin
				// 			wdata_o <= `ZeroWord;
				// 		end
				// 	endcase				
				// end
				// `EXE_LWR_OP:		begin
				// 	mem_addr_o <= {mem_addr_i[31:2], 2'b00};
				// 	mem_we <= `WriteDisable;
				// 	mem_sel_o <= 4'b1111;
				// 	mem_ce_o <= `Enable;
				// 	case (mem_addr_i[1:0])
				// 		2'b00:	begin
				// 			wdata_o <= {reg2_i[31:8],mem_data_i[31:24]};
				// 		end
				// 		2'b01:	begin
				// 			wdata_o <= {reg2_i[31:16],mem_data_i[31:16]};
				// 		end
				// 		2'b10:	begin
				// 			wdata_o <= {reg2_i[31:24],mem_data_i[31:8]};
				// 		end
				// 		2'b11:	begin
				// 			wdata_o <= mem_data_i;	
				// 		end
				// 		default:	begin
				// 			wdata_o <= `ZeroWord;
				// 		end
				// 	endcase					
				//end
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
				// `EXE_SWL_OP:		begin
				// 	mem_addr_o <= {mem_addr_i[31:2], 2'b00};
				// 	mem_we <= `WriteEnable;
				// 	mem_ce_o <= `Enable;
				// 	case (mem_addr_i[1:0])
				// 		2'b00:	begin						  
				// 			mem_sel_o <= 4'b1111;
				// 			mem_data_o <= reg2_i;
				// 		end
				// 		2'b01:	begin
				// 			mem_sel_o <= 4'b0111;
				// 			mem_data_o <= {zero32[7:0],reg2_i[31:8]};
				// 		end
				// 		2'b10:	begin
				// 			mem_sel_o <= 4'b0011;
				// 			mem_data_o <= {zero32[15:0],reg2_i[31:16]};
				// 		end
				// 		2'b11:	begin
				// 			mem_sel_o <= 4'b0001;	
				// 			mem_data_o <= {zero32[23:0],reg2_i[31:24]};
				// 		end
				// 		default:	begin
				// 			mem_sel_o <= 4'b0000;
				// 		end
				// 	endcase							
				// end
				// `EXE_SWR_OP:		begin
				// 	mem_addr_o <= {mem_addr_i[31:2], 2'b00};
				// 	mem_we <= `WriteEnable;
				// 	mem_ce_o <= `Enable;
				// 	case (mem_addr_i[1:0])
				// 		2'b00:	begin						  
				// 			mem_sel_o <= 4'b1000;
				// 			mem_data_o <= {reg2_i[7:0],zero32[23:0]};
				// 		end
				// 		2'b01:	begin
				// 			mem_sel_o <= 4'b1100;
				// 			mem_data_o <= {reg2_i[15:0],zero32[15:0]};
				// 		end
				// 		2'b10:	begin
				// 			mem_sel_o <= 4'b1110;
				// 			mem_data_o <= {reg2_i[23:0],zero32[7:0]};
				// 		end
				// 		2'b11:	begin
				// 			mem_sel_o <= 4'b1111;	
				// 			mem_data_o <= reg2_i[31:0];
				// 		end
				// 		default:	begin
				// 			mem_sel_o <= 4'b0000;
				// 		end
				// 	endcase											
				//end 
				default:		begin
				end
			endcase	
        end
    end
endmodule
