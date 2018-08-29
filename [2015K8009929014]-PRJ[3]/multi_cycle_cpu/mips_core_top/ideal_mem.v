/* =========================================
* Ideal Memory Module for MIPS CPU Core
* Synchronize write (clock enable)
* Asynchronize read (do not use clock signal)
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 31/05/2016
* Version: v0.0.1
*===========================================
*/
`define ADDIU_opcode 6'b001001
`define LW_opcode 6'b100011
`define SW_opcode 6'b101011
`define BNE_opcode 6'b000101//if rs != rt then branch
`define BEQ_opcode 6'b000100///if rs = rt then branch
`define J_opcode 6'b000010//jump target
`define JAL_opcode 6'b000011//I: GPR[31]¡û PC + 8 ; I+1:PC ¡û PCGPRLEN..28 || instr_index || 02
`define SLTI_opcode 6'b001010
`define SLTIU_opcode 6'b001011
`define LUI_opcode 6'b001111

`define SPECIAL_opcode 6'b000000
    `define ADD_func_code 6'b100000
    `define ADDU_func_code 6'b100001
    `define SUB_func_code 6'b100010
    `define SUBU_func_code 6'b100011
    `define AND_func_code 6'b100100
    `define OR_func_code 6'b100101
    `define SLT_func_code 6'b101010
    `define SLL_func_code 6'b000000
    `define JR_func_code 6'b001000

`timescale 1 ps / 1 ps

module ideal_mem #(
	parameter ADDR_WIDTH = 10,	// 1KB
	parameter MEM_WIDTH = 2 ** (ADDR_WIDTH - 2)
	) (
	input			clk,			//source clock of the MIPS CPU Evaluation Module

	input [ADDR_WIDTH - 1:0]	Waddr,			//Memory write port address
	input [ADDR_WIDTH - 1:0]	Raddr1,			//Read port 1 address
	input [ADDR_WIDTH - 1:0]	Raddr2,			//Read port 2 address

	input			Wren,			//write enable
	input			Rden1,			//port 1 read enable
	input			Rden2,			//port 2 read enable

	input [31:0]	Wdata,			//Memory write data
	output [31:0]	Rdata1,			//Memory read data 1
	output [31:0]	Rdata2			//Memory read data 2
);

reg [31:0]	mem [MEM_WIDTH - 1:0];

`define ADDIU(rt, rs, imm) {6'b001001, rs, rt, imm}
`define LW(rt, base, off) {6'b100011, base, rt, off}
`define SW(rt, base, off) {6'b101011, base, rt, off}
`define BNE(rs, rt, off) {6'b000101, rs, rt, off}

`ifdef MIPS_CPU_SIM
	//Add memory initialization here
	initial 
	begin
mem[0] = 32'h00000000;	// addr = 0x0
    mem[1] = 32'h08000004;    // addr = 0x4
    mem[2] = 32'h00000000;    // addr = 0x8
    mem[3] = 32'hffffffff;    // addr = 0xc
    mem[4] = 32'h241d0400;    // addr = 0x10
    mem[5] = 32'h0c00000e;    // addr = 0x14
    mem[6] = 32'h00000000;    // addr = 0x18
    mem[7] = 32'h3c010000;    // addr = 0x1c
    mem[8] = 32'hac20000c;    // addr = 0x20
    mem[9] = 32'h08000009;    // addr = 0x24
    mem[10] = 32'h00000000;    // addr = 0x28
    mem[11] = 32'h00851021;    // addr = 0x2c
    mem[12] = 32'h03e00008;    // addr = 0x30
    mem[13] = 32'h00000000;    // addr = 0x34
    mem[14] = 32'h3c0d0000;    // addr = 0x38
    mem[15] = 32'h3c0c0000;    // addr = 0x3c
    mem[16] = 32'h258c01e8;    // addr = 0x40
    mem[17] = 32'h3c0b0000;    // addr = 0x44
    mem[18] = 32'h3c070000;    // addr = 0x48
    mem[19] = 32'h8da9000c;    // addr = 0x4c
    mem[20] = 32'h256b00e8;    // addr = 0x50
    mem[21] = 32'h24e70208;    // addr = 0x54
    mem[22] = 32'h01805025;    // addr = 0x58
    mem[23] = 32'h00004025;    // addr = 0x5c
    mem[24] = 32'h8d460000;    // addr = 0x60
    mem[25] = 32'h01602025;    // addr = 0x64
    mem[26] = 32'h01801025;    // addr = 0x68
    mem[27] = 32'h8c430000;    // addr = 0x6c
    mem[28] = 32'h8c850000;    // addr = 0x70
    mem[29] = 32'h00c31821;    // addr = 0x74
    mem[30] = 32'h10650005;    // addr = 0x78
    mem[31] = 32'h00000000;    // addr = 0x7c
    mem[32] = 32'h08000009;    // addr = 0x80
    mem[33] = 32'h00000000;    // addr = 0x84
    mem[34] = 32'h24080001;    // addr = 0x88
    mem[35] = 32'h24090001;    // addr = 0x8c
    mem[36] = 32'h24420004;    // addr = 0x90
    mem[37] = 32'h24840004;    // addr = 0x94
    mem[38] = 32'h1447fff4;    // addr = 0x98
    mem[39] = 32'h00000000;    // addr = 0x9c
    mem[40] = 32'h254a0004;    // addr = 0xa0
    mem[41] = 32'h256b0020;    // addr = 0xa4
    mem[42] = 32'h144affed;    // addr = 0xa8
    mem[43] = 32'h00000000;    // addr = 0xac
    mem[44] = 32'h15000004;    // addr = 0xb0
    mem[45] = 32'h00000000;    // addr = 0xb4
    mem[46] = 32'h00001025;    // addr = 0xb8
    mem[47] = 32'h03e00008;    // addr = 0xbc
    mem[48] = 32'h00000000;    // addr = 0xc0
    mem[49] = 32'hada9000c;    // addr = 0xc4
    mem[50] = 32'h1000fffb;    // addr = 0xc8
    mem[51] = 32'h00000000;    // addr = 0xcc
    mem[52] = 32'h01200000;    // addr = 0xd0
    mem[53] = 32'h01000101;    // addr = 0xd4
    mem[54] = 32'h00000000;    // addr = 0xd8
    mem[55] = 32'h00000000;    // addr = 0xdc
    mem[56] = 32'h00000001;    // addr = 0xe0
    mem[57] = 32'h00000000;    // addr = 0xe4
    mem[58] = 32'h00000000;    // addr = 0xe8
    mem[59] = 32'h00000001;    // addr = 0xec
    mem[60] = 32'h00000002;    // addr = 0xf0
    mem[61] = 32'h7fffffff;    // addr = 0xf4
    mem[62] = 32'h80000000;    // addr = 0xf8
    mem[63] = 32'h80000001;    // addr = 0xfc
    mem[64] = 32'hfffffffe;    // addr = 0x100
    mem[65] = 32'hffffffff;    // addr = 0x104
    mem[66] = 32'h00000001;    // addr = 0x108
    mem[67] = 32'h00000002;    // addr = 0x10c
    mem[68] = 32'h00000003;    // addr = 0x110
    mem[69] = 32'h80000000;    // addr = 0x114
    mem[70] = 32'h80000001;    // addr = 0x118
    mem[71] = 32'h80000002;    // addr = 0x11c
    mem[72] = 32'hffffffff;    // addr = 0x120
    mem[73] = 32'h00000000;    // addr = 0x124
    mem[74] = 32'h00000002;    // addr = 0x128
    mem[75] = 32'h00000003;    // addr = 0x12c
    mem[76] = 32'h00000004;    // addr = 0x130
    mem[77] = 32'h80000001;    // addr = 0x134
    mem[78] = 32'h80000002;    // addr = 0x138
    mem[79] = 32'h80000003;    // addr = 0x13c
    mem[80] = 32'h00000000;    // addr = 0x140
    mem[81] = 32'h00000001;    // addr = 0x144
    mem[82] = 32'h7fffffff;    // addr = 0x148
    mem[83] = 32'h80000000;    // addr = 0x14c
    mem[84] = 32'h80000001;    // addr = 0x150
    mem[85] = 32'hfffffffe;    // addr = 0x154
    mem[86] = 32'hffffffff;    // addr = 0x158
    mem[87] = 32'h00000000;    // addr = 0x15c
    mem[88] = 32'h7ffffffd;    // addr = 0x160
    mem[89] = 32'h7ffffffe;    // addr = 0x164
    mem[90] = 32'h80000000;    // addr = 0x168
    mem[91] = 32'h80000001;    // addr = 0x16c
    mem[92] = 32'h80000002;    // addr = 0x170
    mem[93] = 32'hffffffff;    // addr = 0x174
    mem[94] = 32'h00000000;    // addr = 0x178
    mem[95] = 32'h00000001;    // addr = 0x17c
    mem[96] = 32'h7ffffffe;    // addr = 0x180
    mem[97] = 32'h7fffffff;    // addr = 0x184
    mem[98] = 32'h80000001;    // addr = 0x188
    mem[99] = 32'h80000002;    // addr = 0x18c
    mem[100] = 32'h80000003;    // addr = 0x190
    mem[101] = 32'h00000000;    // addr = 0x194
    mem[102] = 32'h00000001;    // addr = 0x198
    mem[103] = 32'h00000002;    // addr = 0x19c
    mem[104] = 32'h7fffffff;    // addr = 0x1a0
    mem[105] = 32'h80000000;    // addr = 0x1a4
    mem[106] = 32'hfffffffe;    // addr = 0x1a8
    mem[107] = 32'hffffffff;    // addr = 0x1ac
    mem[108] = 32'h00000000;    // addr = 0x1b0
    mem[109] = 32'h7ffffffd;    // addr = 0x1b4
    mem[110] = 32'h7ffffffe;    // addr = 0x1b8
    mem[111] = 32'h7fffffff;    // addr = 0x1bc
    mem[112] = 32'hfffffffc;    // addr = 0x1c0
    mem[113] = 32'hfffffffd;    // addr = 0x1c4
    mem[114] = 32'hffffffff;    // addr = 0x1c8
    mem[115] = 32'h00000000;    // addr = 0x1cc
    mem[116] = 32'h00000001;    // addr = 0x1d0
    mem[117] = 32'h7ffffffe;    // addr = 0x1d4
    mem[118] = 32'h7fffffff;    // addr = 0x1d8
    mem[119] = 32'h80000000;    // addr = 0x1dc
    mem[120] = 32'hfffffffd;    // addr = 0x1e0
    mem[121] = 32'hfffffffe;    // addr = 0x1e4
    mem[122] = 32'h00000000;    // addr = 0x1e8
    mem[123] = 32'h00000001;    // addr = 0x1ec
    mem[124] = 32'h00000002;    // addr = 0x1f0
    mem[125] = 32'h7fffffff;    // addr = 0x1f4
    mem[126] = 32'h80000000;    // addr = 0x1f8
    mem[127] = 32'h80000001;    // addr = 0x1fc
    mem[128] = 32'hfffffffe;    // addr = 0x200
    mem[129] = 32'hffffffff;    // addr = 0x204


	end
`endif

always @ (posedge clk)
begin
	if (Wren)
		mem[Waddr] <= Wdata;
                  if(mem[3]==32'b0)begin
            $display("pass");
            $finish;
            end
            else if(mem[3]==32'b1)
            begin
            $display("fail");
            $finish;
            end
            
end

assign Rdata1 = {32{Rden1}} & mem[Raddr1];
assign Rdata2 = {32{Rden2}} & mem[Raddr2];

endmodule
