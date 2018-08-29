`ifdef PRJ1_FPGA_IMPL
	// the board does not have enough GPIO, so we implement 4 4-bit registers
    `define DATA_WIDTH 4
	`define ADDR_WIDTH 2
`else
    `define DATA_WIDTH 32
	`define ADDR_WIDTH 5
`endif

module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);

	// TODO: insert your code
   reg [`DATA_WIDTH-1:0] register [(1'b1<<`ADDR_WIDTH)-1:0];//register
          //  reg [`ADDR_WIDTH:0] count;//count nubmer
            always@(posedge clk)
                begin
                     if(wen&& |waddr)//�Ĵ���������д����
                     register[waddr]<=wdata;
                     else;
                end
                assign rdata1=(raddr1==0)?0:register[raddr1];//�첽��
                assign rdata2=(raddr2==0)?0:register[raddr2];//�첽��

endmodule
