`timescale 1ns / 1ps
//
// WIDTH: bits in register hdata & vdata
// HSIZE: horizontal size of visible field 
// HFP: horizontal front of pulse
// HSP: horizontal stop of pulse
// HMAX: horizontal max size of value
// VSIZE: vertical size of visible field 
// VFP: vertical front of pulse
// VSP: vertical stop of pulse
// VMAX: vertical max size of value
// HSPP: horizontal synchro pulse polarity (0 - negative, 1 - positive)
// VSPP: vertical synchro pulse polarity (0 - negative, 1 - positive)
//
module vga
#(parameter WIDTH = 0, HSIZE = 0, HFP = 0, HSP = 0, HMAX = 0, VSIZE = 0, VFP = 0, VSP = 0, VMAX = 0, HSPP = 0, VSPP = 0)
(
    input wire clk,
    output wire hsync,
    output wire vsync,
    output reg [WIDTH - 1:0] hdata,
    output reg [WIDTH - 1:0] vdata,
    output wire data_enable,

    output reg read_en_o,
    output wire [16:0] read_addr_o,
    output reg [7:0] pixel_data_o,
    input wire [31:0] read_data_i
);
reg [WIDTH - 1:0] hdata_fast;
reg [WIDTH - 1:0] vdata_fast;

// init
initial begin
    hdata <= 0;
    vdata <= 0;
    hdata_fast <= 1;
    vdata_fast <= 0;
	read_en_o<=1;
end
//assign read_addr_o=(hdata_fast+800*vdata_fast)&16'b1111111111111100;
assign read_addr_o=(hdata_fast+800*vdata_fast)>>2;

// hdata
always @ (posedge clk)
begin
    if (hdata == (HMAX - 1))
        hdata <= 0;
    else
        hdata <= hdata + 1;
    if (hdata_fast == (HMAX - 1))
        hdata_fast <= 0;
    else
        hdata_fast <= hdata_fast + 1;
end

// vdata
always @ (posedge clk)
begin
    if (hdata == (HMAX - 1)) 
    begin
        if (vdata == (VMAX - 1))
            vdata <= 0;
        else
            vdata <= vdata + 1;
    end
    if (hdata_fast == (HMAX - 1)) 
    begin
        if (vdata_fast == (VMAX - 1))
            vdata_fast <= 0;
        else
            vdata_fast <= vdata_fast + 1;
    end
end

wire [1:0] lowbit;
assign lowbit=hdata&2'b11;
//assign lowbit=hdata&2'b11;
always @ (*)
begin
	read_en_o<=1;
	if (lowbit==2'b00) begin
		pixel_data_o<=read_data_i[7:0];
	end else if (lowbit==2'b01) begin
		pixel_data_o<=read_data_i[15:8];
	end else if (lowbit==2'b10) begin
		pixel_data_o<=read_data_i[23:16];
	end else begin
		pixel_data_o<=read_data_i[31:24];
	end
	//prev_pixel<=read_data_i;
	//if (read_addr_o==479999)
	//	read_addr_o<=0;
	//else
	//	read_addr_o<=read_addr_o+1;
end

// hsync & vsync & blank
assign hsync = ((hdata >= HFP) && (hdata < HSP)) ? HSPP : !HSPP;
assign vsync = ((vdata >= VFP) && (vdata < VSP)) ? VSPP : !VSPP;
assign data_enable = ((hdata < HSIZE) & (vdata < VSIZE));

endmodule
