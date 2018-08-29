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

`timescale 1 ps / 1 ps

module ideal_mem #(
	parameter ADDR_WIDTH = 10,
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
`define BNE(rt, rs, offset) {6'b000101, rs, rt, offset}
`define LW(rt, base, offset) {6'b100011, base, rt, offset}
`define SW(rt, base, offset) {6'b101011, base, rt, offset}
`define NOP 32'b0

`ifdef MIPS_CPU_SIM
	//Add memory initialization here
	initial begin
		     mem[0] = 32'h241a0001; //r[1] <= mem[128], i
               mem[1] = 32'h17400002; //r[2] <= mem[129], number
               mem[2] = 32'h00000000; //r[3] <= mem[130], 10
               mem[3] = 32'hffffffff; //number += 100
               mem[4] = 32'h24040000; //i++
               mem[5] = 32'h24050064; //while
               mem[6] = 32'hac8400c8; //mem[128] <= r[1], i
               mem[7] = 32'h24840004; //mem[129] <= r[2], number
               mem[8] = 32'h1485fffd;
               mem[9] = 32'h00000000;
               mem[10] = 32'h24040000; //i
               mem[11] = 32'h8c8600c8; //number
               mem[12] = 32'hac86012c; //10 for branch
               mem[13] = 32'h24840004;
               mem[14] = 32'h1485fffc;
               mem[15] = 32'h00000000;
               mem[16] = 32'h24040000;
               mem[17] = 32'h8c86012c;
               mem[18] = 32'h14c40007;
               mem[19] = 32'h00000000;
               mem[20] = 32'h24840004;
               mem[21] = 32'h1485fffb;
               mem[22] = 32'h00000000;
               mem[23] = 32'h241a0001;
               mem[24] = 32'h17400005;
               mem[25] = 32'h00000000;
               mem[26] = 32'h24040001;
               mem[27] = 32'h241a0001;
               mem[28] = 32'h17400002;
               mem[29] = 32'h00000000;
               mem[30] = 32'h24040000;
               mem[31] = 32'hac04000c;
               mem[32] = 32'h241a0001;
               mem[33] = 32'h1740fffe;
               mem[34] = 32'h00000000;

		//TODO: Please update the memory initialization with your owm instructions and data
		//each initialization data is 32-bit
		//e.g.,
		//mem[0] = `ADDID(5'd2, 5'd0, 16'd10);
		//mem[1] = xxxx;
		//mem[2] = xxxx;
	end
`endif

always @ (posedge clk)
begin
	if (Wren)
		mem[Waddr] <= Wdata;
end

assign Rdata1 = {32{Rden1}} & mem[Raddr1];
assign Rdata2 = {32{Rden2}} & mem[Raddr2];

endmodule
