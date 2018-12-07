`timescale 1ns / 1ps


`include "defines.v"
`include"MemoryUtils.v"

`define MMU_ADDR_ROM_START    32'hbfc00000
`define MMU_ADDR_ROM_END      32'hbfc00fff
`define MMU_ADDR_FLASH_START  32'hbe000000
`define MMU_ADDR_FLASH_END    32'hbeffffff
`define MMU_ADDR_SERIAL_START 32'hbfd003f8
`define MMU_ADDR_SERIAL_END   32'hbfd003fc
`define MMU_ADDR_VGA_POS      32'hbfc03000
`define MMU_ADDR_PS2_POS	     32'haf000000

`define DEVICE_CHOICE_LEN		3
`define DEVICE_ROM				3'b000
`define DEVICE_FLASH			3'b001
`define DEVICE_SERIAL			3'b010
`define DEVICE_VGA				3'b011
`define DEVICE_PG2				3'b100
`define DEVICE_RAM				3'b101
`define DEVICE_NOP				3'b110

`define MMUCONTROL_STATE_INIT	 3'b000
`define MMUCONTROL_STATE_PAUSE	 3'b001
`define MMUCONTROL_STATE_RESULT  3'b010

`define MAX_PFN2_LEN            19
`define MAX_PFN2_RANGE          `MAX_PFN2_LEN-1:0

`define HIT_ERROR               6'b111111

module MMUControl (
	input wire clk,    
	input wire rst,  
	input wire[`MEMCONTROL_OP_LEN - 1  :0]	op_i,
	input wire[`MEMCONTROL_ADDR_LEN - 1:0] 	addr_i,
	input wire[31:0]						data_i,
	input wire enable_i,

    input wire[31:0]                       sram_data_i,
    
	input wire[`TLB_OP_RANGE] tlb_op_i,
    // Config from CP0
    //input wire[31:0] cp0_context_i,
    //input wire[31:0] cp0_config1_i,
    input wire[31:0] cp0_index_i,
    input wire[31:0] cp0_entryhi_i,
    input wire[31:0] cp0_entrylo0_i,
    input wire[31:0] cp0_entrylo1_i,
    // cp0 数据旁路
    input wire mem_wb_o_cp0_reg_we_i,
    input wire[4:0] mem_wb_o_cp0_reg_write_addr_i,
    input wire[`RegBus] mem_wb_o_cp0_reg_data_i,
    //input wire[31:0] cp0_wire_i,
    input wire[31:0] cp0_random_i,
//    input wire[31:0]                       serial_data_i,            
	//output signal to lower layer
	//SRAM 
	output wire 						      sram_enabled,
	output wire[`SRAMCONTROL_OP_LEN   - 1: 0] sram_op, 
	output wire[`SRAMCONTROL_DATA_LEN - 1: 0] sram_data,
	output wire[`SRAMCONTROL_ADDR_LEN - 1: 0] sram_addr,
	
	// Serial
//	output wire									serial_enabled,
//	output wire[`SERIALCONTROL_OP_LEN - 1: 0]   serial_op,
//	output wire[`SERIALCONTROL_DATA_LEN - 1: 0]	serial_data,
//	output wire[`SERIALCONTROL_ADDR_LEN - 1: 0]	serial_addr,
	
	// output to Memcontrol

	output wire[31:0] result_o,
	output wire pause_pipeline_o,
    output reg[`TLB_EXCEPTION_RANGE] tlb_exception_o// output error //TODO: something else?

		);
//    assign mmu_addr_i = addr_i[3:0];
	reg[`MEMCONTROL_ADDR_LEN - 1:0] mmu_addr;
	reg[`DEVICE_CHOICE_LEN - 1:0] device;
	reg [2:0] cur_state;
    reg sram_enabled_reg;
//    reg serial_enabled_reg;
    reg [31:0]result_o_reg;
    
//    assign mmu_state = cur_state;
//    assign mmu_op_i = op_i;
    
    assign sram_enabled = sram_enabled_reg;
  //  assign serial_enabled = serial_enabled_reg;

    assign pause_pipeline_o = (cur_state == `MMUCONTROL_STATE_PAUSE);
    assign result_o = result_o_reg;//(cur_state == `MMUCONTROL_STATE_RESULT? sram_data_i: `SRAMCONTROL_DEFAULT_DATA);

    assign sram_op = (op_i == `MEMCONTROL_OP_WRITE? `SRAMCONTROL_OP_WRITE : (op_i == `MEMCONTROL_OP_READ? `SRAMCONTROL_OP_READ: `SRAMCONTROL_OP_NOP));
    assign sram_data = data_i;

    // TLB 
    wire mapped=(addr_i[31:30]!=2'b10); // 内核态的映射地址
    
    reg[`MAX_PFN2_RANGE] VPN2[`MAX_TLB_ENTRY_RANGE];
    reg[`MAX_TLB_ENTRY_RANGE] G;
    reg[7:0] ASID[`MAX_TLB_ENTRY_RANGE];

    reg[`MAX_PFN2_LEN:0] PFN0[`MAX_TLB_ENTRY_RANGE];// size of PFN0 = size of VPN2+1
    reg[`MAX_TLB_ENTRY_RANGE] V0;
    reg[`MAX_TLB_ENTRY_RANGE] D0;

    reg[`MAX_PFN2_LEN:0] PFN1[`MAX_TLB_ENTRY_RANGE];
    reg[`MAX_TLB_ENTRY_RANGE] V1;
    reg[`MAX_TLB_ENTRY_RANGE] D1;

    wire[`MAX_PFN2_RANGE] addr_VPN2=addr_i[31:13];
    wire[`MAX_PFN2_RANGE] addr_ASID=cp0_entryhi_i[7:0];
    //wire[5:0] mmu_size=cp0_config1_i[30:25];

    wire[`MAX_TLB_ENTRY_RANGE] hit;
    // generate hit result
    generate
        genvar i;
        for (i=0; i<`MAX_TLB_ENTRY_NUM; i=i+1)
        begin: ASSIGN_HIT
            assign hit[i]=((addr_VPN2==VPN2[i])&&(G[i]==1'b1||addr_ASID==ASID[i])&&(V0[i]==1'b1||V1[i]==1'b1));
        end
    endgenerate


	reg[5:0] hitNum;
    reg[`MAX_PFN2_LEN:0] realPFN;
    reg hitV;
    reg hitD;

    wire[31:0] finalAddr={realPFN,addr_i[11:0]};

    //reg[`MAX_PFN2_RANGE] hitPFN1;
    //reg hitV1;
    //reg hitD1;
    
    always @(*)begin
        // calculate result
        // number of ENTRY might change. But mask not
        case (hit)
            16'b0000000000000001:begin
                hitNum<=0;
            end

            16'b0000000000000010:begin
                hitNum<=1;
            end

            16'b0000000000000100:begin
                hitNum<=2;
            end

            16'b0000000000001000:begin
                hitNum<=3;
            end

            16'b0000000000010000:begin
                hitNum<=4;
            end

            16'b0000000000100000:begin
                hitNum<=5;
            end

            16'b0000000001000000:begin
                hitNum<=6;
            end

            16'b0000000010000000:begin
                hitNum<=7;
            end

            16'b0000000100000000:begin
                hitNum<=8;
            end

            16'b0000001000000000:begin
                hitNum<=9;
            end

            16'b0000010000000000:begin
                hitNum<=10;
            end

            16'b0000100000000000:begin
                hitNum<=11;
            end

            16'b0001000000000000:begin
                hitNum<=12;
            end

            16'b0010000000000000:begin
                hitNum<=13;
            end

            16'b0100000000000000:begin
                hitNum<=14;
            end

            16'b1000000000000000:begin
                hitNum<=15;
            end
            default: begin
                hitNum<=`HIT_ERROR;
            end
        endcase
        if (hitNum==`HIT_ERROR) begin// TODO:exception
                realPFN<=0;
                hitV<=0;
                hitD<=0;
        end else begin// exactly hit, but maybe invalid
        //if (hitNum!=`HIT_ERROR) begin
            if (addr_i[12]==1'b0) begin
                //TODO check valid or not, and read/write matters
                realPFN<=PFN0[hitNum];
                hitV<=V0[hitNum];
                hitD<=D0[hitNum];
            end else begin
                realPFN<=PFN1[hitNum];
                hitV<=V1[hitNum];
                hitD<=D1[hitNum];
            end
        end
    end

    // TLB exception
	always @(*) begin 
        if (rst==1'b1) begin
            tlb_exception_o<=`TLB_EXC_NO;
            mmu_addr<=32'b0;
        end else begin
            //if (enable_i==1 && mapped==1'b1) begin
            if (mapped==1'b1) begin
                if (hitNum==`HIT_ERROR) begin
                    tlb_exception_o<=`TLB_EXC_REFILL;
                    // sram_enabled_reg<=1'b0;
                    // disable other flag as well
                end else begin
                    tlb_exception_o<=`TLB_EXC_NO;
                end
            end else begin
                tlb_exception_o<=`TLB_EXC_NO;
            end
            if (mapped==1'b1) begin
                mmu_addr = finalAddr;
            end else begin
                mmu_addr = addr_i;
            end
        end
    end
    assign sram_addr = mmu_addr[22: 2];

    // currently map to physical address directly 
    // TODO: change this mmu_addr

	always @(*) begin 
		if(~rst) begin
            sram_enabled_reg <= 0;
			device  <= `DEVICE_NOP;
			result_o_reg <= `ZeroWord;
			if( enable_i == 1 && tlb_exception_o==`TLB_EXC_NO) begin
				if(mmu_addr >= `MMU_ADDR_ROM_START && mmu_addr <= `MMU_ADDR_ROM_END) begin
					device <= `DEVICE_ROM;
				end else if (mmu_addr >= `MMU_ADDR_FLASH_START && mmu_addr <= `MMU_ADDR_FLASH_END) begin
					device <= `DEVICE_FLASH;
				end else if (mmu_addr >= `MMU_ADDR_SERIAL_START && mmu_addr <= `MMU_ADDR_SERIAL_END) begin
					device <= `DEVICE_SERIAL;
				end else if (mmu_addr == `MMU_ADDR_VGA_POS) begin
					device <= `DEVICE_VGA;
				end else if (mmu_addr == `MMU_ADDR_PS2_POS) begin
					device <= `DEVICE_PG2;
				end else begin
					device <= `DEVICE_RAM;
	                sram_enabled_reg <= 1;
                    result_o_reg <= sram_data_i;
	    		end
			end

		end else begin
            sram_enabled_reg <= 0;
			device  <= `DEVICE_NOP;
			result_o_reg <= `ZeroWord;
		end
	end
    
    //// cp0 multiplex
    //reg[31:0] cp0_entryhi_m; // real register
    //reg[31:0] cp0_entrylo0_m;
    //reg[31:0] cp0_entrylo1_m;
    //always @(*) begin
    //    
    //end

    // perform TLBWI and TLBWR
    wire[3:0] index=cp0_index_i[3:0]; // The size of array related to max # of tlb entry
    wire[3:0] random=4'b0000;//cp0_random_i[3:0]; // The size of array related to max # of tlb entry
    integer j;
    //always @(rst or tlb_op_i or index or mem_wb_o_cp0_reg_we_i or mem_wb_o_cp0_reg_write_addr_i or mem_wb_o_cp0_reg_data_i or cp0_entryhi_i or cp0_entrylo0_i or cp0_entrylo1_i) begin
    always @(*) begin
        if (rst==1'b1) begin // TLB reset
            for (j=0;j<`MAX_TLB_ENTRY_NUM;j=j+1) begin
                VPN2[j]<=19'b0;
                ASID[j]<=8'b0;
                G[j]<=1'b0;

                PFN0[j]<=20'b0;
                D0[j]<=1'b0;
                V0[j]<=1'b0;
                PFN1[j]<=20'b0;
                D1[j]<=1'b0;
                V1[j]<=1'b0;
            end
        end else begin
            if (pause_pipeline_o==1'b0) begin
                if (tlb_op_i==`TLB_OP_TLBWI) begin
                    // cp0 data bypass
                    if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYHI) begin
                        VPN2[index]<=mem_wb_o_cp0_reg_data_i[31:13];
                        ASID[index]<=mem_wb_o_cp0_reg_data_i[7:0];
                    end else begin
                        VPN2[index]<=cp0_entryhi_i[31:13];
                        ASID[index]<=cp0_entryhi_i[7:0];
                    end
                    if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYLO0) begin
                        G[index]<=mem_wb_o_cp0_reg_data_i[0]&cp0_entrylo1_i[0];
                    end else if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYLO1) begin
                        G[index]<=cp0_entrylo0_i[0]&mem_wb_o_cp0_reg_data_i[0];
                    end else begin
                        G[index]<=cp0_entrylo0_i[0]&cp0_entrylo1_i[0];
                    end

                    if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYLO0) begin
                        PFN0[index]<=mem_wb_o_cp0_reg_data_i[25:6];
                        D0[index]<=mem_wb_o_cp0_reg_data_i[2];
                        V0[index]<=mem_wb_o_cp0_reg_data_i[1];
                    end else begin
                        PFN0[index]<=cp0_entrylo0_i[25:6];
                        D0[index]<=cp0_entrylo0_i[2];
                        V0[index]<=cp0_entrylo0_i[1];
                    end
                    if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYLO1) begin
                        PFN1[index]<=mem_wb_o_cp0_reg_data_i[25:6];
                        D1[index]<=mem_wb_o_cp0_reg_data_i[2];
                        V1[index]<=mem_wb_o_cp0_reg_data_i[1];
                    end else begin
                        PFN1[index]<=cp0_entrylo1_i[25:6];
                        D1[index]<=cp0_entrylo1_i[2];
                        V1[index]<=cp0_entrylo1_i[1];
                    end
                end else if (tlb_op_i==`TLB_OP_TLBWR) begin
                    // cp0 data bypass
                    if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYHI) begin
                        VPN2[random]<=mem_wb_o_cp0_reg_data_i[31:13];
                        ASID[random]<=mem_wb_o_cp0_reg_data_i[7:0];
                    end else begin
                        VPN2[random]<=cp0_entryhi_i[31:13];
                        ASID[random]<=cp0_entryhi_i[7:0];
                    end
                    if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYLO0) begin
                        G[random]<=mem_wb_o_cp0_reg_data_i[0]&cp0_entrylo1_i[0];
                    end else if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYLO1) begin
                        G[random]<=cp0_entrylo0_i[0]&mem_wb_o_cp0_reg_data_i[0];
                    end else begin
                        G[random]<=cp0_entrylo0_i[0]&cp0_entrylo1_i[0];
                    end

                    if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYLO0) begin
                        PFN0[random]<=mem_wb_o_cp0_reg_data_i[25:6];
                        D0[random]<=mem_wb_o_cp0_reg_data_i[2];
                        V0[random]<=mem_wb_o_cp0_reg_data_i[1];
                    end else begin
                        PFN0[random]<=cp0_entrylo0_i[25:6];
                        D0[random]<=cp0_entrylo0_i[2];
                        V0[random]<=cp0_entrylo0_i[1];
                    end
                    if (mem_wb_o_cp0_reg_we_i==1'b1 && mem_wb_o_cp0_reg_write_addr_i==`CP0_ENTRYLO1) begin
                        PFN1[random]<=mem_wb_o_cp0_reg_data_i[25:6];
                        D1[random]<=mem_wb_o_cp0_reg_data_i[2];
                        V1[random]<=mem_wb_o_cp0_reg_data_i[1];
                    end else begin
                        PFN1[random]<=cp0_entrylo1_i[25:6];
                        D1[random]<=cp0_entrylo1_i[2];
                        V1[random]<=cp0_entrylo1_i[1];
                    end
                end
            end
        end
	end

	always @(posedge clk) begin 
		if(rst) begin
			cur_state <= `MMUCONTROL_STATE_INIT;	
//			sram_enabled_reg <= 0;
		end else begin	
//			sram_enabled_reg <= 0;
			if(cur_state == `MMUCONTROL_STATE_INIT  ||  enable_i == 0) begin
				//if(op_i == `MEMCONTROL_OP_READ || op_i == `MEMCONTROL_OP_WRITE) begin
					cur_state <= `MMUCONTROL_STATE_PAUSE;
					case (device)
						`DEVICE_RAM: begin
//							sram_enabled_reg <= 1;
                
                		end
						default : /* default */;
					endcase
				// end else begin
				// 	cur_state <= `MMUCONTROL_STATE_INIT;
				// end

			end else if(cur_state == `MMUCONTROL_STATE_PAUSE) begin
				cur_state <= `MMUCONTROL_STATE_RESULT;
				case (device)
					`DEVICE_RAM: begin
  //                      sram_enabled_reg <= 1;

                	end
					default : /* default */;
				endcase
//			end else if(cur_state == `MMUCONTROL_STATE_RESULT) begin

            end else begin
				cur_state <= `MMUCONTROL_STATE_PAUSE;
				case (device)
					`DEVICE_RAM : begin
        //                sram_enabled_reg <= 1;

            		end
					default : /* default */;
				endcase
			end
		end
	end
	// end

endmodule
