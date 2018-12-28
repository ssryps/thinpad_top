`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2018 09:22:09 PM
// Design Name: 
// Module Name: SerialControl
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


module SerialControl(
		input wire clk,
		input wire rst,
		input wire[1:0] op_i,
	    input wire mode_i,          
	    input wire[7:0] data_i,
		 // output to upper devices
	    output wire[31:0] result_o,
	    output wire serial_excp,

	    input wire RxD,
	    output wire TxD
    );
    
	reg[7:0] buffer[0:15];
    reg[3:0] readPos;
    reg[3:0] recvPos;
    
    wire data_ready;
    wire[7:0] data_receive;
    wire write_busy;
    reg[7:0] ramData;
    
    wire[3:0] nextRecvPos = (recvPos == 15) ? 0 : recvPos + 1;
    wire[3:0] nextReadPos = (readPos == 15) ? 0 : readPos + 1;
    wire bufferEmpty = (recvPos == readPos);
    wire serialRead = (op_i == `SERIALCONTROL_OP_READ && mode_i == 0);
    wire serialWrite = (op_i == `SERIALCONTROL_OP_WRITE && mode_i == 0);
    wire[7:0] controlData = {6'h0, ~bufferEmpty, ~write_busy};
    
    assign result_o = {24'h0, mode_i ? controlData : ramData};
    assign serial_excp = data_ready | !bufferEmpty;
        
    //Receive buffer
    always @(posedge clk) begin
        if (rst == `Enable) begin
            buffer[0] <= 8'b0000_0000;
            buffer[1] <= 8'b0000_0000;
            buffer[2] <= 8'b0000_0000;
            buffer[3] <= 8'b0000_0000;
            buffer[4] <= 8'b0000_0000;
            buffer[5] <= 8'b0000_0000;
            buffer[6] <= 8'b0000_0000;
            buffer[7] <= 8'b0000_0000;
            buffer[8] <= 8'b0000_0000;
            buffer[9] <= 8'b0000_0000;
            buffer[10] <= 8'b0000_0000;
            buffer[11] <= 8'b0000_0000;
            buffer[12] <= 8'b0000_0000;
            buffer[13] <= 8'b0000_0000;
            buffer[14] <= 8'b0000_0000;
            buffer[15] <= 8'b0000_0000;
        end else if (data_ready == `Enable) begin
            buffer[recvPos] <= data_receive;
        end
    end
    
    //Receive pointer
    always @(posedge clk) begin
        if (rst == `Enable) begin
            recvPos <= 0;
        end else if (data_ready == `Enable) begin
            recvPos <= nextRecvPos;
        end
    end
    
    //Read pointer
    always @(posedge clk) begin
        if (rst == `Enable) begin
            readPos <= 0;
        end else if (serialRead && !bufferEmpty) begin
            readPos <= nextReadPos;
        end
    end
    
    //Data output
    always @(*) begin
        ramData = 8'b0000_0000;
        if (serialRead) begin
            if (!bufferEmpty) begin
                ramData = buffer[readPos];
            end else if (data_ready) begin  //Bypass
                ramData = data_receive;
            end
        end
    end
    
    reg[7:0] data_write;
    reg 	data_start;
 //   assign data_write = 8'b0000_0111;
    always @(posedge clk) begin
        if (rst == `Enable) begin
            data_write <= 8'h00;
            data_start <= 0;
        end else if (serialWrite && !write_busy) begin
            data_write <= data_i;
            data_start <= 1;
        end else begin 
            data_write <= 8'h00;
            data_start <= 0;	
        end

    end
    //Receiver
    async_receiver #(.ClkFrequency(50000000), .Baud(115200)) ext_uart_r(
        .clk(clk),
        .RxD(RxD),
        .RxD_data_ready(data_ready),
        .RxD_data(data_receive)
    );

    async_transmitter #(.ClkFrequency(50000000), .Baud(115200)) ext_uart_t(
        .clk(clk),
        .TxD_start(data_start),
        .TxD_data(data_write),
        .TxD(TxD),
        .TxD_busy(write_busy)
    );
    


endmodule
