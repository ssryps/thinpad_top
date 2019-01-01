`include "defines.v"
`include "MemoryUtils.v"

module rom(
	input wire ce,
	input wire[`ROM_ADDR_LEN - 1:0] addr,
	output reg[`InstBus] inst
);



always @ (*) begin
	if (ce == `Disable) begin
		inst <= `ZeroWord;
	end else begin
		case (addr)
            0: inst = 32'h00000000;
            4: inst = 32'h10000001;
            8: inst = 32'h00000000;
            12: inst = 32'h3c08beff;
            16: inst = 32'h3508fff8;
            20: inst = 32'h240900ff;
            24: inst = 32'had090000;
            28: inst = 32'h3c10be00;
            32: inst = 32'h240f0000;
            36: inst = 32'h020f7821;
            40: inst = 32'h8de90000;
            44: inst = 32'h8def0004;
            48: inst = 32'h000f7c00;
            52: inst = 32'h012f4825;
            56: inst = 32'h3c08464c;
            60: inst = 32'h3508457f;
            64: inst = 32'h11090003;
            68: inst = 32'h00000000;
            72: inst = 32'h10000045;
            76: inst = 32'h00000000;
            80: inst = 32'h240f0038;
            84: inst = 32'h020f7821;
            88: inst = 32'h8df10000;
            92: inst = 32'h8def0004;
            96: inst = 32'h000f7c00;
            100: inst = 32'h022f8825;
            104: inst = 32'h240f0058;
            108: inst = 32'h020f7821;
            112: inst = 32'h8df20000;
            116: inst = 32'h8def0004;
            120: inst = 32'h000f7c00;
            124: inst = 32'h024f9025;
            128: inst = 32'h3252ffff;
            132: inst = 32'h240f0030;
            136: inst = 32'h020f7821;
            140: inst = 32'h8df30000;
            144: inst = 32'h8def0004;
            148: inst = 32'h000f7c00;
            152: inst = 32'h026f9825;
            156: inst = 32'h262f0008;
            160: inst = 32'h000f7840;
            164: inst = 32'h020f7821;
            168: inst = 32'h8df40000;
            172: inst = 32'h8def0004;
            176: inst = 32'h000f7c00;
            180: inst = 32'h028fa025;
            184: inst = 32'h262f0010;
            188: inst = 32'h000f7840;
            192: inst = 32'h020f7821;
            196: inst = 32'h8df50000;
            200: inst = 32'h8def0004;
            204: inst = 32'h000f7c00;
            208: inst = 32'h02afa825;
            212: inst = 32'h262f0004;
            216: inst = 32'h000f7840;
            220: inst = 32'h020f7821;
            224: inst = 32'h8df60000;
            228: inst = 32'h8def0004;
            232: inst = 32'h000f7c00;
            236: inst = 32'h02cfb025;
            240: inst = 32'h12800010;
            244: inst = 32'h00000000;
            248: inst = 32'h12a0000e;
            252: inst = 32'h00000000;
            256: inst = 32'h26cf0000;
            260: inst = 32'h000f7840;
            264: inst = 32'h020f7821;
            268: inst = 32'h8de80000;
            272: inst = 32'h8def0004;
            276: inst = 32'h000f7c00;
            280: inst = 32'h010f4025;
            284: inst = 32'hae880000;
            288: inst = 32'h26d60004;
            292: inst = 32'h26940004;
            296: inst = 32'h26b5fffc;
            300: inst = 32'h1ea0fff4;
            304: inst = 32'h00000000;
            308: inst = 32'h26310020;
            312: inst = 32'h2652ffff;
            316: inst = 32'h1e40ffd7;
            320: inst = 32'h00000000;
            324: inst = 32'h3c11bfd0;
            328: inst = 32'h363103f8;
            332: inst = 32'hae330000;
            336: inst = 32'h02600008;
            340: inst = 32'h00000000;
            344: inst = 32'h1000ffff;
            348: inst = 32'h00000000;
            352: inst = 32'h1000ffff;
            default: inst = 0;
        endcase
	end
end

endmodule
