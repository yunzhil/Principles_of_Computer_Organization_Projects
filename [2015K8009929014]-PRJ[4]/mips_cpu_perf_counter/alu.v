`ifdef PRJ1_FPGA_IMPL
	// the board does not have enough GPIO, so we implement a 4-bit ALU
    `define DATA_WIDTH 4
`else
    `define DATA_WIDTH 32
`endif

`timescale 10ns / 1ns

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
    wire [`DATA_WIDTH+1:0] S_Result;//???Result?????????CarryOut??Overflow
                  wire[`DATA_WIDTH-1:0] B_use;//???¦Ì???????B
                  wire cin;//?????????carryin
                    always@(*)
                      begin
                        case(ALUop)//????ALUop???????????
                           3'b000:Result<=A&B;//AND
                           3'b001:Result<=A|B;//OR
                           3'b010:Result<=S_Result;//ADD
                           3'b110:Result<=S_Result;//SUB
                           3'b111:
                                  Result<=Overflow^S_Result[`DATA_WIDTH-1];//SLT
                           3'b011:Result<={B[15:0],16'b0};
                           3'b100:Result<=(A<B)?1:0;
                           3'b101:Result<=A<<B;
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
