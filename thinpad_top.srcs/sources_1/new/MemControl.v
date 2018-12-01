`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2018 09:53:20 AM
// Design Name: 
// Module Name: Memcontrol
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
 `include"MemoryUtils.v"


`define MEMCONTROL_STATE_INIT			 		 		4'b0000
`define MEMCONTROL_STATE_ONLY_PC		 	 			4'b0001
`define MEMCONTROL_STATE_ONLY_PC_RESULT		 			4'b0010
`define MEMCONTROL_STATE_PC_READ_OR_WRITE		 		4'b0011
`define MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT		4'b0100
`define MEMCONTROL_STATE_PC_READ_OR_WRITE_1    		 	4'b0101
`define MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT	4'b0110
`define MEMCONTROL_STATE_PC_READ_AND_WRITE	 			4'b0111
`define MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT	4'b1000
`define MEMCONTROL_STATE_PC_READ_AND_WRITE1				4'b1001
`define MEMCONTROL_STATE_PC_READ_AND_WRITE_READ_RESULT	4'b1010
`define MEMCONTROL_STATE_PC_READ_AND_WRITE2				4'b1011
`define MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT	4'b1100
`define MEMCONTROL_STATE_RST 							4'b1101

module MemControl(
		input wire clk, 
		input wire rst,
		input wire[`MEMCONTROL_ADDR_LEN - 1:0] pc_addr_i,
		input wire[31:0] mem_addr_i,
		input wire[31:0] mem_data_i,
		input wire[5:0]	 mem_data_sz_i,	
		input wire[`MEMCONTROL_OP_LEN - 1:0] mem_op_i,
		input wire mem_enabled,

		input wire[31:0] mmu_result_i,
		input wire mmu_pause_i,

		// control signal to MMU
		output wire[`MEMCONTROL_OP_LEN - 1  :0]	op_o,
		output wire[`MEMCONTROL_ADDR_LEN - 1:0] addr_o,
		output wire[31:0]						data_o,
		output wire enable_o,
		
		// result to pc and mem
		output wire[31:0] pc_data_o,
		output wire[31:0] mem_data_o,
		output reg mem_data_valid_o,
		
		output wire pause_pipeline_o
		// exception 
//		output wire is_pc_valid
    );

	// mem access will halt the pipeline, so inside we need a state to record current state
	reg[3:0] cur_state; 
	//  currently it remains unknown if a write or read can be finished in a period, so 
	// add a reg to record current phase of a primitive operation(read or write)
	
	reg [`MEMCONTROL_OP_LEN - 1:0]op_o_reg;
	reg [`MEMCONTROL_ADDR_LEN - 1:0]addr_o_reg;
	reg [31:0]data_o_reg;
	reg [31:0]pc_data_o_reg;
	reg [31:0]mem_data_o_reg;

	// read_or_write and read_and_write state to hold temperory data
	reg [31:0]read_or_write_temp_pc;
	reg [31:0]read_and_write_temp_pc;
	reg [31:0]read_and_write_temp_mem;
	//reg [31:0]read_and_write_temp_
	//reg input_valid;

	reg[31:0] pc_addr_i_host;
	reg[31:0] mem_addr_i_host;
	reg [31:0] mem_data_i_host;
	reg[5:0]	 mem_data_sz_i_host;	
	reg[`MEMCONTROL_OP_LEN - 1:0] mem_op_i_host;


	assign enable_o = mem_enabled;


	assign op_o = op_o_reg;
	assign addr_o = addr_o_reg;
	assign data_o = data_o_reg;
	assign pc_data_o = pc_data_o_reg;
	assign mem_data_o = mem_data_o_reg;
	//assign pause_pipeline_o = !((cur_state == `MEMCONTROL_STATE_RST) || (cur_state == `MEMCONTROL_STATE_ONLY_PC) || (cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_1)
	// || (cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE2) || (mem_enabled == 0));
	assign pause_pipeline_o = !((cur_state == `MEMCONTROL_STATE_ONLY_PC_RESULT && mmu_pause_i == 0) || (cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT && mmu_pause_i == 0)
		|| (cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT && mmu_pause_i == 0));
	// assign input_valid = ((cur_state == `MEMCONTROL_STATE_INIT) || (cur_state == `MEMCONTROL_STATE_ONLY_PC_RESULT) 
	//  	|| (cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE) || (cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE));

	always @(posedge clk ) begin 

		pc_addr_i_host <= pc_addr_i_host;
		mem_addr_i_host <= mem_addr_i_host ;
		mem_data_i_host <= mem_data_i_host;
		mem_data_sz_i_host <= mem_data_sz_i_host;	
 		mem_op_i_host <= mem_op_i_host ;

		if(rst) begin
			cur_state <= `MEMCONTROL_STATE_RST;
		end else begin
			if (cur_state == `MEMCONTROL_STATE_RST ) begin
				cur_state <= `MEMCONTROL_STATE_INIT;
			end if (cur_state == `MEMCONTROL_STATE_INIT) begin
				if(mem_op_i == `MEMCONTROL_OP_WRITE) begin
					if(mem_data_sz_i == `MEMECONTROL_OP_WORD) begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
					end else begin
						cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT;	
					end
				end else if(mem_op_i == `MEMCONTROL_OP_READ || mem_op_i == `MEMCONTROL_OP_READ_UN) begin
					cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
				end else begin
					cur_state  <= `MEMCONTROL_STATE_ONLY_PC_RESULT;				
				end
				mem_addr_i_host <= mem_addr_i ;
				mem_data_i_host <= mem_data_i;
				mem_data_sz_i_host <= mem_data_sz_i;	
		 		mem_op_i_host <= mem_op_i;

			end else if(cur_state == `MEMCONTROL_STATE_ONLY_PC_RESULT) begin
                if(mmu_pause_i == 0)  begin
                    if(mem_op_i == `MEMCONTROL_OP_WRITE) begin
                        if(mem_data_sz_i == `MEMECONTROL_OP_WORD) begin
                            cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
                        end else begin
                            cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT;    
                        end
                    end else if(mem_op_i == `MEMCONTROL_OP_READ  || mem_op_i == `MEMCONTROL_OP_READ_UN) begin
                            cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
                    end else begin
                            cur_state  <= `MEMCONTROL_STATE_ONLY_PC_RESULT;                
                    end

					mem_addr_i_host <= mem_addr_i ;
					mem_data_i_host <= mem_data_i;
					mem_data_sz_i_host <= mem_data_sz_i;	
			 		mem_op_i_host <= mem_op_i;

                end else begin
                    cur_state <= `MEMCONTROL_STATE_ONLY_PC_RESULT;
                end
                
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT) begin
				if(mmu_pause_i == 0)  begin                
					cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT;
					// temp save pc
					read_or_write_temp_pc <= mmu_result_i;
                end else begin
                    cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
                end
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT) begin
                if(mmu_pause_i == 0)  begin
                    if(mem_op_i == `MEMCONTROL_OP_WRITE) begin
                        if(mem_data_sz_i == `MEMECONTROL_OP_WORD) begin
                            cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
                        end else begin
                            cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT;    
                        end
                    end else if(mem_op_i == `MEMCONTROL_OP_READ  || mem_op_i == `MEMCONTROL_OP_READ_UN) begin
                            cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
                    end else begin
                            cur_state  <= `MEMCONTROL_STATE_ONLY_PC_RESULT;                
                    end
					mem_addr_i_host <= mem_addr_i ;
					mem_data_i_host <= mem_data_i;
					mem_data_sz_i_host <= mem_data_sz_i;	
			 		mem_op_i_host <= mem_op_i;

                end else begin
                    cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT;
                end

			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT) begin
				if(mmu_pause_i == 0)  begin                
					cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_READ_RESULT;
					// temp save pc
					read_and_write_temp_pc <= mmu_result_i;
                end else begin
                    cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT;
                end

			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_READ_RESULT) begin
				if(mmu_pause_i == 0)  begin                
					cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT;
					read_and_write_temp_mem <= mmu_result_i;
                end else begin
                    cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_READ_RESULT;
                end

			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT) begin
				 
                if(mmu_pause_i == 0)  begin
                    if(mem_op_i == `MEMCONTROL_OP_WRITE) begin
                        if(mem_data_sz_i == `MEMECONTROL_OP_WORD) begin
                            cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
                        end else begin
                            cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT;    
                        end
                    end else if(mem_op_i == `MEMCONTROL_OP_READ || mem_op_i == `MEMCONTROL_OP_READ_UN) begin
                            cur_state <= `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT;
                    end else begin
                            cur_state  <= `MEMCONTROL_STATE_ONLY_PC_RESULT;                
                    end
					mem_addr_i_host <= mem_addr_i ;
					mem_data_i_host <= mem_data_i;
					mem_data_sz_i_host <= mem_data_sz_i;	
			 		mem_op_i_host <= mem_op_i;

                end else begin
                    cur_state <= `MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT;
                end
			end

			if( mem_enabled == 0) begin
				cur_state <= `MEMCONTROL_STATE_ONLY_PC_RESULT;
			
			end
		end
	end
 
    reg[31:0] temp_result;
	always @(*) begin 
		//if(!pause_pipeline_i) begin
//		    temp_result <= `ZeroWord;

			if (cur_state == `MEMCONTROL_STATE_RST) begin
				op_o_reg   <= `MEMCONTROL_OP_READ; 
				addr_o_reg <= pc_addr_i;
				data_o_reg <=  mem_data_i;
				pc_data_o_reg <= `ZeroWord;	
				mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
				mem_data_valid_o <= 0;


			end if (cur_state == `MEMCONTROL_STATE_INIT ) begin
				op_o_reg   <= `MEMCONTROL_OP_READ;
				addr_o_reg <= pc_addr_i;
				data_o_reg <=  mem_data_i;
				pc_data_o_reg <= `ZeroWord;	
				mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
								mem_data_valid_o <= 0;

			end else if(cur_state == `MEMCONTROL_STATE_ONLY_PC_RESULT) begin
				if(mmu_pause_i == 0)  begin                

					op_o_reg   <= `MEMCONTROL_OP_READ;
					addr_o_reg <=  pc_addr_i;
					data_o_reg <=  mem_data_i;

					pc_data_o_reg <= mmu_result_i;	
					mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
						mem_data_valid_o <= 0;

        		end else begin 
        			op_o_reg   <= `MEMCONTROL_OP_READ;
					addr_o_reg <= pc_addr_i;
					data_o_reg <=  mem_data_i_host;

	            	mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
	                pc_data_o_reg <= mmu_result_i;
					mem_data_valid_o <= 0;

        		end

            end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_PC_RESULT) begin
                if(mmu_pause_i == 0)  begin                
					op_o_reg   <=  `MEMCONTROL_OP_READ;
					addr_o_reg <=  pc_addr_i;
					data_o_reg <=  mem_data_i_host;

	                pc_data_o_reg <= mmu_result_i;    
	                mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
					mem_data_valid_o <= 0;

                end else begin
					op_o_reg   <=  `MEMCONTROL_OP_READ;
					addr_o_reg <= pc_addr_i;
					data_o_reg <=  mem_data_i_host;

	                pc_data_o_reg <= mmu_result_i;    
	                mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
    				mem_data_valid_o <= 0;

	            end
			
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_OR_WRITE_MEM_RESULT) begin
                 if(mmu_pause_i == 0)  begin       

                 	if(mem_op_i_host == `MEMCONTROL_OP_READ || mem_op_i_host == `MEMCONTROL_OP_READ_UN) begin 
						op_o_reg   <=  `MEMCONTROL_OP_READ;
                 	end else begin 
                		op_o_reg   <=  `MEMCONTROL_OP_WRITE;
                 		
                 	end
					addr_o_reg <=  mem_addr_i_host;
					data_o_reg <=  mem_data_i_host;

	                pc_data_o_reg <= read_or_write_temp_pc;    
	                mem_data_o_reg <= mmu_result_i;
	                mem_data_valid_o <= 0;

	                if(mem_op_i_host == `MEMCONTROL_OP_READ_UN) begin 
	                	case (mem_data_sz_i_host) 
	                		`MEMECONTROL_OP_BYTE: begin 
	                			case (mem_addr_i_host[1:0])
		                			2'b11:	begin
										mem_data_o_reg <= {{24{1'b0}},mmu_result_i[31:24]};
									end
									2'b10:	begin
										mem_data_o_reg <= {{24{1'b0}},mmu_result_i[23:16]};
									end
									2'b01:	begin
										mem_data_o_reg <= {{24{1'b0}},mmu_result_i[15:8]};
									end
									2'b00:	begin
										mem_data_o_reg <= {{24{1'b0}},mmu_result_i[7:0]};
									end
								endcase
	                		end
							`MEMECONTROL_OP_HALF_WORD: begin 
	                			case (mem_addr_i_host[1])
	                				1'b1:	begin
										mem_data_o_reg <= {{16{1'b0}},mmu_result_i[31:16]};
									end
									1'b0:	begin
										mem_data_o_reg <= {{16{1'b0}},mmu_result_i[15:0]};
									end
	                			endcase
                			end
	                		default : /* default */;
	                	endcase
	                	mem_data_valid_o <= 1;

	                end

	                if(mem_op_i_host == `MEMCONTROL_OP_READ) begin 
	                	case (mem_data_sz_i_host) 
	                		`MEMECONTROL_OP_BYTE: begin 
	                			case (mem_addr_i_host[1:0])
									2'b11:	begin
										mem_data_o_reg <= {{24{mmu_result_i[31]}},mmu_result_i[31:24]};
									end
									2'b10:	begin
										mem_data_o_reg <= {{24{mmu_result_i[23]}},mmu_result_i[23:16]};
									end
									2'b01:	begin
										mem_data_o_reg <= {{24{mmu_result_i[15]}},mmu_result_i[15:8]};
									end
									2'b00:	begin
										mem_data_o_reg <= {{24{mmu_result_i[7]}},mmu_result_i[7:0]};
									end
								endcase
	                		end
							`MEMECONTROL_OP_HALF_WORD: begin 
	                			case (mem_addr_i_host[1])
	                				1'b1:	begin
										mem_data_o_reg <= {{16{mmu_result_i[31]}},mmu_result_i[31:16]};
									end
									1'b0:	begin
										mem_data_o_reg <= {{16{mmu_result_i[15]}},mmu_result_i[15:0]};
									end
	                			endcase
                			end
	                		default : /* default */;
	                	endcase
	                	mem_data_valid_o <= 1;

	                end
					
				end else begin
                 	if(mem_op_i_host == `MEMCONTROL_OP_READ || mem_op_i_host == `MEMCONTROL_OP_READ_UN) begin 
						op_o_reg   <=  `MEMCONTROL_OP_READ;
                 	end else begin 
                		op_o_reg   <=  `MEMCONTROL_OP_WRITE;
                 		
                 	end
					addr_o_reg <=  mem_addr_i_host;
					data_o_reg <=  mem_data_i_host; 

	                pc_data_o_reg <= read_or_write_temp_pc;    
	                mem_data_o_reg <= mmu_result_i;
					mem_data_valid_o <= 0;

				end
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_PC_RESULT) begin
				
                if(mmu_pause_i == 0)  begin                
					op_o_reg   <=  `MEMCONTROL_OP_READ;
					addr_o_reg <= pc_addr_i;
					data_o_reg <=  mem_data_i_host;

	                pc_data_o_reg <= mmu_result_i;    
	                mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
    					mem_data_valid_o <= 0;

                end else begin
					op_o_reg   <=  `MEMCONTROL_OP_READ;
					addr_o_reg <= pc_addr_i;
					data_o_reg <=  mem_data_i_host;

	                pc_data_o_reg <= mmu_result_i;    
	                mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
    								mem_data_valid_o <= 0;

	            end
			
		
			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_READ_RESULT) begin
                if(mmu_pause_i == 0)  begin                			
	                op_o_reg   <=  `MEMCONTROL_OP_READ;
					addr_o_reg <= mem_addr_i_host;
					data_o_reg <=  mem_data_i_host;
					
	                pc_data_o_reg <= read_and_write_temp_pc;    
	                mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
				mem_data_valid_o <= 0;

				end else begin
					op_o_reg   <=  `MEMCONTROL_OP_READ;
					addr_o_reg <= mem_addr_i_host;
					data_o_reg <=  mem_data_i_host;

	                pc_data_o_reg <= read_and_write_temp_pc;    
	                mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
				mem_data_valid_o <= 0;

				end

			end else if(cur_state == `MEMCONTROL_STATE_PC_READ_AND_WRITE_WRITE_RESULT) begin
				if(mmu_pause_i == 0)  begin                			
					op_o_reg   <= `MEMCONTROL_OP_WRITE;
					addr_o_reg <=  mem_addr_i_host;

					if(mem_data_sz_i == `MEMECONTROL_OP_HALF_WORD) begin
						if(mem_addr_i[1:0] == 2'b00) begin
							data_o_reg <= {read_and_write_temp_mem[31: 16], mem_data_i_host[15:0]};
						end else begin
							data_o_reg <= {mem_data_i_host[15: 0], read_and_write_temp_mem[15:0]};
						end 
					end else begin
						if(mem_addr_i[1:0] == 2'b00) begin
							data_o_reg <= {read_and_write_temp_mem[31: 8], mem_data_i_host[7:0]};
						end else if(mem_addr_i[1:0] == 2'b01) begin
							data_o_reg <= {read_and_write_temp_mem[31: 16], mem_data_i_host[7:0], read_and_write_temp_mem[7:0]};
						end else if(mem_addr_i[1:0] == 2'b10) begin
							data_o_reg <= {read_and_write_temp_mem[31: 24], mem_data_i_host[7:0], read_and_write_temp_mem[15:0]};
						end else  begin
							data_o_reg <= {mem_data_i_host[7:0], read_and_write_temp_mem[23:0]};
						end

					end
					mem_data_valid_o <= 0;

	                pc_data_o_reg <= read_and_write_temp_pc;    
	                mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;


				end else begin
					op_o_reg   <= `MEMCONTROL_OP_WRITE;
					addr_o_reg <=  mem_addr_i_host;
					
					if(mem_data_sz_i_host == `MEMECONTROL_OP_HALF_WORD) begin
						if(mem_addr_i_host[1:0] == 2'b00) begin
							data_o_reg <= {read_and_write_temp_mem[31: 16], mem_data_i_host[15:0]};
						end else begin
							data_o_reg <= {mem_data_i_host[15: 0], read_and_write_temp_mem[15:0]};
						end 
					end else begin
						if(mem_addr_i_host[1:0] == 2'b00) begin
							data_o_reg <= {read_and_write_temp_mem[31: 8], mem_data_i_host[7:0]};
						end else if(mem_addr_i_host[1:0] == 2'b01) begin
							data_o_reg <= {read_and_write_temp_mem[31: 16], mem_data_i_host[7:0], read_and_write_temp_mem[7:0]};
						end else if(mem_addr_i_host[1:0] == 2'b10) begin
							data_o_reg <= {read_and_write_temp_mem[31: 24], mem_data_i_host[7:0], read_and_write_temp_mem[15:0]};
						end else  begin
							data_o_reg <= {mem_data_i_host[7:0], read_and_write_temp_mem[23:0]};
						end

					end
					mem_data_valid_o <= 0;

	                pc_data_o_reg <= read_and_write_temp_pc;    
	                mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;

    				
				end
			end else begin
				    op_o_reg   <=  `MEMCONTROL_OP_READ;
                    addr_o_reg <=  `ZeroWord;
                    data_o_reg <=  `ZeroWord;
                    pc_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;    
	                mem_data_o_reg <= `MEMCONTROL_DEFAULT_DATA;
    				mem_data_valid_o <= 0;

			end
//		end
	end
endmodule
