module mips_cpu(
  input  rst,
  input  clk,

  output [31:0] PC,
  input  [31:0] Instruction,

  output [31:0] Address,
  output MemWrite,
  output [31:0] Write_data,

  input  [31:0] Read_data,
  output MemRead
);
  wire RegDst;
  wire Branch;
  wire MemtoReg;
  wire [1:0] ALUOp;
  wire ALUSrc;
  wire RegWrite;
  wire [4:0] Read_register1;
  wire [4:0] Read_register2;
  wire [4:0] Writeregister;
  wire [31:0] Writedata;
  wire [31:0] Read_data1;
  wire [31:0] Read_data2;
  wire [31:0] A;
  wire [31:0] B;
  wire [31:0] Sign_extend;
  wire [2:0] ALUop;
  wire [31:0] ALU_result;
  wire Zero;
  wire [31:0]Shift_left2;
  wire Overflow;
  wire CarryOut;

  reg [31:0] PC_reg;
  always@(posedge clk)//PC
    begin
    if(rst)
      PC_reg<=0;
    else if(Branch&(~Zero))
      PC_reg<=PC_reg+4+Shift_left2;
    else
      PC_reg<=PC_reg+4;       
    end
  assign Shift_left2=Sign_extend<<2;
  assign Write_data=Read_data2;
  assign Address=ALU_result;
  assign Writeregister=(RegDst==0)?Instruction[20:16]:Instruction[15:11];
  assign Sign_extend={{16{Instruction[15]}},Instruction[15:0]};
  assign B=(ALUSrc==0)?Read_data2:Sign_extend;
  assign Writedata=(MemtoReg==1)?Read_data:ALU_result;
  assign Read_register1=Instruction[25:21];
  assign Read_register2=Instruction[20:16];
  assign PC=PC_reg;
  assign A=Read_data1;
  ControlUnit ControlUnit(Instruction[31:26],RegDst,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite);//Ä£¿éÀý»¯
  reg_file Registers(clk,rst,Writeregister,Read_register1,Read_register2,RegWrite,Writedata,Read_data1,Read_data2);
  alu ALU(.A(A),.B(B),.ALUop(ALUop),.Overflow(Overflow),.CarryOut(CarryOut),.Zero(Zero),.Result(ALU_result));
  ALU_control ALU_control(Instruction[5:0],ALUOp,ALUop);
  endmodule

module ControlUnit(
  input [5:0] opcode,
  output reg RegDst,
  output reg Branch,
  output reg MemRead,
  output reg MemtoReg,
  output reg [1:0] ALUOp,
  output reg MemWrite,
  output reg ALUSrc,
  output reg RegWrite
);
  always@(opcode)//¿ØÖÆÂß¼­
  case(opcode)
  6'b001001:
  begin
  RegDst=0;
  Branch=0;
  MemRead=0;
  MemtoReg=0;
  ALUOp=2'b00;
  MemWrite=0;
  ALUSrc=1;
  RegWrite=1;
  end
  6'b000000:
  begin
  RegDst=0;
  Branch=0;
  MemRead=0;
  MemtoReg=0;
  ALUOp=2'b00;
  MemWrite=0;
  ALUSrc=0;
  RegWrite=0;
  end
  6'b100011:
  begin
  RegDst=0;
  Branch=0;
  MemRead=1;
  MemtoReg=1;
  ALUOp=2'b00;
  MemWrite=0;
  ALUSrc=1;
  RegWrite=1;
  end
  6'b101011:
  begin
  RegDst=0;
  Branch=0;
  MemRead=0;
  MemtoReg=0;
  ALUOp=2'b00;
  MemWrite=1;
  ALUSrc=1;
  RegWrite=0;
  end
  6'b000101:
  begin
  RegDst=0;
  Branch=1;
  MemRead=0;
  MemtoReg=0;
  ALUOp=2'b01;
  MemWrite=0;
  ALUSrc=0;
  RegWrite=0;
  end
  default:
  begin
  RegDst=0;
  Branch=0;
  MemRead=0;
  MemtoReg=0;
  ALUOp=2'b00;
  MemWrite=0;
  ALUSrc=0;
  RegWrite=0;
  end
  endcase     
  endmodule

module ALU_control(
  input [5:0] funct,
  input [1:0] ALUOp,
  output [2:0] ALUop
);
  assign ALUop[0]=(funct[0]|funct[3])&ALUOp[1];
  assign ALUop[1]=(~funct[2])|(~ALUOp[1]);
  assign ALUop[2]=ALUOp[0]|(funct[1]&ALUOp[1]);
endmodule
