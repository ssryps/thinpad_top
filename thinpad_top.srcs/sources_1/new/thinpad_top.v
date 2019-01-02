// `default_nettype none
`include "defines.v"
`include "MemoryUtils.v"

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信号
    output wire uart_rdn,         //读串口信号，低有效
    output wire uart_wrn,         //写串口信号，低有效
    input wire uart_dataready,    //串口数据准备好
    input wire uart_tbre,         //发送数据标志
    input wire uart_tsre,         //数据发送完毕标志

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //USB 控制器信号，参考 SL811 芯片手册
    output wire sl811_a0,
    inout  wire[7:0] sl811_d,
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参考 DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

 // assign txd = rxd;

/* =========== Demo code begin =========== */

// PLL分频示例
wire[31:0] cur_inst;
wire my_clk_50M, my_clk_11M0592;

wire locked, clk_10M, clk_20M;
pll_example clock_gen
 (
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked), // 锁定输出，"1"表示时钟稳定，可作为后级电路复位
 // Clock in ports
  .clk_in1(clk_50M) // 外部时钟输入
 );

reg reset_of_clk10M;
// 异步复位，同步释放
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

always@(posedge clk_10M or posedge reset_of_clk10M) begin
    if(reset_of_clk10M)begin
        // Your Code
    end
    else begin
        // Your Code
    end
end

// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

wire[31:0] cnt_correct_instruction1;
wire[31:0] cnt_correct_instruction2;
wire pc_branch_flag;
// 7段数码管译码器演示，将number用16进制显示在数码管上面
reg[7:0] number;

reg[15:0] led_bits;
//assign leds = led_bits;


always@(posedge clock_btn or posedge reset_btn) begin
    if(reset_btn)begin //复位按下，设置LED和数码管为初始值
        number<=0;
        led_bits <= 16'h1;
    end
    else begin //每次按下时钟按钮，数码管显示值加1，LED循环左移
        number <= number+1;
        led_bits <= {led_bits[14:0],led_bits[15]};
    end
end

//直连串口接收发送演示，从直连串口收到的数据再发送出去
wire [7:0] ext_uart_rx;
reg  [7:0] ext_uart_buffer, ext_uart_tx;
wire ext_uart_reay, ext_uart_busy;
reg ext_uart_start, ext_uart_avai;

// async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
//     ext_uart_r(
//         .clk(clk_50M),                       //外部时钟信号
//         .RxD(rxd),                           //外部串行信号输入
//         .RxD_data_ready(ext_uart_ready),  //数据接收到标志
//         .RxD_clear(ext_uart_ready),       //清除接收标志
//         .RxD_data(ext_uart_rx)             //接收到的一字节数据
//     );

// always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
//     if(ext_uart_ready)begin
//         ext_uart_buffer <= ext_uart_rx;
//         ext_uart_avai <= 1;
//     end else if(!ext_uart_busy && ext_uart_avai)begin
//         ext_uart_avai <= 0;
//     end
// end

// always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
//     if(!ext_uart_busy && ext_uart_avai)begin
//         ext_uart_tx <= ext_uart_buffer + 1;
//         ext_uart_start <= 1;
//     end else begin
//         ext_uart_start <= 0;
//     end
// end

// async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
//     ext_uart_t(
//         .clk(clk_50M),                  //外部时钟信号
//         .TxD(txd),                      //串行信号输出
//         .TxD_busy(ext_uart_busy),       //发送器忙状态指示
//         .TxD_start(ext_uart_start),    //开始发送信号
//         .TxD_data(ext_uart_tx)        //待发送的数据
//     );

//图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz

wire [11:0] hdata;
assign video_red = pixel_data[7:5]; //红色竖条
assign video_green = pixel_data[4:2]; //绿色竖条
assign video_blue = pixel_data[1:0]; //蓝色竖条
//assign video_red = hdata < 266 ? 3'b111 : 0; //红色竖条
//assign video_green = hdata < 532 && hdata >= 266 ? 3'b111 : 0; //绿色竖条
//assign video_blue = hdata >= 532 ? 2'b11 : 0; //蓝色竖条
assign video_clk = clk_50M;
wire vga_read_enable;
wire[16:0] vga_read_addr;
wire[31:0] vga_read_data;
wire[7:0] pixel_data;

wire [31:0]zero32;
assign zero32 = `ZeroWord;
blk_mem_gen_0 graphicmem (
  .clka(zero32),    // input wire clka
  .ena(zero32),      // input wire ena
  .wea(zero32),      // input wire [0 : 0] wea
  .addra(zero32),  // input wire [16 : 0] addra
  .dina(zero32),    // input wire [31 : 0] dina
  .clkb(my_clk_50M),    // input wire clkb
  .enb(vga_read_enable),      // input wire enb
  .addrb(vga_read_addr),  // input wire [16 : 0] addrb
  .doutb(vga_read_data)  // output wire [31 : 0] doutb
);

vga #(12, 800, 856, 976, 1040, 600, 637, 643, 666, 1, 1) vga800x600at75 (
    .clk(clk_50M),
    .hdata(hdata), //横坐标
    .vdata(),      //纵坐标
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de),
    // read from graphic MEM
    .read_en_o(vga_read_enable),
	.read_addr_o(vga_read_addr),
	.pixel_data_o(pixel_data),
    .read_data_i(vga_read_data)
);
/* =========== Demo code end =========== */
wire[`InstAddrBus] inst_addr;
wire[`InstBus] inst;
wire rom_ce;

// wire mem_we_i;
// wire[`RegBus] mem_addr_i;
// wire[`RegBus] mem_data_i;
// wire[`RegBus] mem_data_o;
// wire[3:0] mem_sel_i;
// wire mem_ce_i;

wire[`MEMCONTROL_ADDR_LEN - 1:0] pc_addr_i;
wire[31:0] mem_addr_i;
wire[31:0] mem_data_i;
wire[5:0]	 mem_data_sz_i;
wire[`MEMCONTROL_OP_LEN - 1:0] mem_op_i;
wire mem_enabled;

wire[31:0] pc_data_o;
wire[31:0] mem_data_o;
wire mem_data_valid_o;
wire pause_pipeline_final_o;

// TLB
wire[31:0] cp0_index_i;
wire[31:0] cp0_entryhi_i;
wire[31:0] cp0_entrylo0_i;
wire[31:0] cp0_entrylo1_i;
wire[31:0] cp0_random_o;
wire[`TLB_EXCEPTION_RANGE] tlb_exc_o;// to MEM
wire[`TLB_OP_RANGE] tlb_op_o;
// CP0 data bypass
wire mem_wb_o_cp0_reg_we_o;
wire[4:0] mem_wb_o_cp0_reg_write_addr_o;
wire[`RegBus] mem_wb_o_cp0_reg_data_o;

//reg rst;
//
//initial begin
//  rst = 1;
//  #20;
//  rst = 0;
//  #1000;
//  rst = 0;
//end

//clock osc0 (
//    .clk_11M0592(my_clk_11M0592),
//    .clk_50M    (my_clk_50M)
//);

wire serial_excp;

wire [2:0 ] mmu_state;
wire [2:0 ] sram_state;
wire [2:0] mmu_op_i;
wire[3:0] mmu_addr_i;
wire[3:0] sram_addr_i;
wire [3:0] mem_state;
wire[31:0] excp_type;
wire pc_flush;

assign my_clk_50M = clk_50M;
//assign my_clk_50M = clock_btn;

//assign leds[3:0] = inst_addr[5:2]; //debug
//assign leds[4] = base_ram_ce_n; //debug
//assign leds[5] = base_ram_oe_n; //debug
//assign leds[6] = base_ram_we_n; //debug
    
//assign leds[9:7] = mmu_state[2:0]; //debug
//assign leds[12:10] = sram_state[2:0]; //debug

//assign leds[15:0] = inst_addr[15:0] ;
assign leds[3:0] = cnt_correct_instruction1[15:0];

SEG7_LUT segL(.oSEG1(dpy0), .iDIG(cnt_correct_instruction2[3:0] )); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(cnt_correct_instruction2[7:4 ])); //dpy1是高位数码管

closemips closemips0(
	.clk(my_clk_50M),
	.rst(reset_of_clk10M),

	.rom_addr_o(inst_addr),
	.rom_data_i(inst),
	.rom_ce_o(rom_ce),

	.mem_addr_o(mem_addr_i),
	.mem_data_o(mem_data_i),
	.mem_data_sz_o(mem_data_sz_i),
	.mem_op_o(mem_op_i),
    .mem_enabled(mem_enabled),// no source or dest
	.mem_data_i(mem_data_o),
    .mem_data_valid_i(mem_data_valid_o),
	.mem_pause_pipeline_i(pause_pipeline_final_o),

	.cnt_correct_instruction1(cnt_correct_instruction1),
	.cnt_correct_instruction2(cnt_correct_instruction2),
	.excp_type(excp_type),
    // to closemem, for TLB 
    .cp0_index_o(cp0_index_i),
    .cp0_entryhi_o(cp0_entryhi_i),
    .cp0_entrylo0_o(cp0_entrylo0_i),
    .cp0_entrylo1_o(cp0_entrylo1_i),
    .cp0_random_o(cp0_random_o),
	.tlb_op_o(tlb_op_o),
    .tlb_exc_i(tlb_exc_o),
    // cp0 data bypass
    .mem_wb_o_cp0_reg_write_addr_o(mem_wb_o_cp0_reg_write_addr_o),
    .mem_wb_o_cp0_reg_data_o(mem_wb_o_cp0_reg_data_o),
    .mem_wb_o_cp0_reg_we_o(mem_wb_o_cp0_reg_we_o),
    .serial_excp(serial_excp)

);

closemem closemem0(
	.clk_50M(my_clk_50M),
	.rst(reset_of_clk10M),
	.pc_addr_i(inst_addr),
	.mem_addr_i(mem_addr_i),
	.mem_data_i(mem_data_i),
	.mem_data_sz_i(mem_data_sz_i),
	.mem_op_i(mem_op_i),
    .mem_enabled(mem_enabled),
	.pc_data_o(inst),
	.mem_data_o(mem_data_o),
    .mem_data_valid_o(mem_data_valid_o),
	.pause_pipeline_final_o(pause_pipeline_final_o),

	.ram1_data(base_ram_data),
	.ram1_addr(base_ram_addr),
	.ram1_be_n(base_ram_be_n),
	.ram1_ce_n(base_ram_ce_n),
	.ram1_oe_n(base_ram_oe_n),
	.ram1_we_n(base_ram_we_n),

	.ram2_data(ext_ram_data),
	.ram2_addr(ext_ram_addr),
	.ram2_be_n(ext_ram_be_n),
	.ram2_ce_n(ext_ram_ce_n),
	.ram2_oe_n(ext_ram_oe_n),
	.ram2_we_n(ext_ram_we_n),
    
    // for TLB
    .cp0_index_i(cp0_index_i),
    .cp0_entryhi_i(cp0_entryhi_i),
    .cp0_entrylo0_i(cp0_entrylo0_i),
    .cp0_entrylo1_i(cp0_entrylo1_i),
    .cp0_random_i(cp0_random_o),
    .tlb_op_i(tlb_op_o),
    .tlb_exc_o(tlb_exc_o),
    // cp0 data bypass
    .mem_wb_o_cp0_reg_write_addr_i(mem_wb_o_cp0_reg_write_addr_o),
    .mem_wb_o_cp0_reg_data_i(mem_wb_o_cp0_reg_data_o),
    .mem_wb_o_cp0_reg_we_i(mem_wb_o_cp0_reg_we_o),

    .RxD(rxd),
    .TxD(txd),
    .serial_excp(serial_excp)

	);
	
//	ila_0 debug__ (
//	   .clk(my_clk_50M),
//       .probe0(inst),
//       .probe1(my_clk_50M),
//       .probe2(inst_addr),
//       .probe3(mem_data_o),
//       .probe4(mem_addr_i)
//	);
//vio_0 vio 
//    (
//        .clk(clk_50M), 
//        .probe_in0(inst)
        
//        );

endmodule
