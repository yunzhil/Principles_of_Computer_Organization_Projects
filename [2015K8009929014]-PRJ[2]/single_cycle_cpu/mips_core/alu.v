`ifdef PRJ1_FPGA_IMPL
	// the board does not have enough GPIO, so we implement a 4-bit ALU
    `define DATA_WIDTH 4
`else
    `define DATA_WIDTH 32
`endif

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output reg [`DATA_WIDTH - 1:0] Result
);

	// TODO: insert your code
	wire [`DATA_WIDTH+1:0] S_Result;//扩展Result，用于计算CarryOut与Overflow
              wire[`DATA_WIDTH-1:0] B_use;//实际参加运算的B
              wire cin;//用于减法的carryin
                always@(*)
                  begin
                    case(ALUop)//根据ALUop选择输出数据
                       3'b000:Result=A&B;//AND
                       3'b001:Result=A|B;//OR
                       3'b010:Result=S_Result;//ADD
                       3'b110:Result=S_Result;//SUB
                       3'b111:
                              Result=Overflow^S_Result[`DATA_WIDTH-1];//SLT
                      default:
                         Result=0;
                            endcase
                          end
                  assign Zero=(Result==0)?1:0;//Zero
                  assign CarryOut=S_Result[`DATA_WIDTH+1]^cin; //CarryOut
                  assign Overflow=S_Result[`DATA_WIDTH]^S_Result[`DATA_WIDTH-1];//Overflow
                  assign B_use=({`DATA_WIDTH{ALUop[2]}}^B);//B_use
                  assign cin=ALUop[2];//carryout for SUB
                  assign S_Result={A[`DATA_WIDTH-1],A}+{B_use[`DATA_WIDTH-1],B_use}+cin;//S_Result
endmodule
