`timescale 10ns / 1ns

module mips_cpu(
	input  rst,
	input  clk,

	output [31:0] PC,
	input  [31:0] Instruction,

	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,

	input  [31:0] Read_data,
	output MemRead,

	output [31:0] cycle_cnt,		//counter of total cycles
	output [31:0] inst_cnt,			//counter of total instructions
	output [31:0] br_cnt,			//counter of branch/jump instructions
	output [31:0] ld_cnt,			//counter of load instructions
	output [31:0] st_cnt,			//counter of store instructions
	output [31:0] user1_cnt,		//user defined counter (reserved)
	output [31:0] user2_cnt,
	output [31:0] user3_cnt
);

	// TODO: insert your code
	wire [31:0] alu_in_A,alu_in_B,alu_out_result;
        wire [2:0] alu_in_ALUop;
        wire alu_out_zero,alu_out_overflow,alu_out_carryout;//ALU
        alu alu(.A(alu_in_A),.B(alu_in_B),.ALUop(alu_in_ALUop),.Overflow(alu_out_overflow),.CarryOut(alu_out_carryout),.Zero(alu_out_zero),.Result(alu_out_result));
    
    
        wire [4:0] reg_in_raddr1,reg_in_raddr2,reg_in_waddr;
        wire[31:0] reg_in_wdata;
        wire[31:0] reg_out_rdata1,reg_out_rdata2;
        wire wen;//rf
        reg_file reg_file(.clk(clk),.rst(rst),.waddr(reg_in_waddr),.raddr1(reg_in_raddr1),.raddr2(reg_in_raddr2),.wen(wen),.wdata(reg_in_wdata),.rdata1(reg_out_rdata1),.rdata2(reg_out_rdata2));
    
        reg[31:0] Instruction_reg,Memory_data,A,B,ALUOut;//AAAAAAAAAAAAAA
        wire PC_control;
        wire [31:0] PC_next,sign_extend;
    
        wire PCWriteCond, PCWrite, cu_MemRead, cu_MemWrite, IRWrite;
        wire[1:0]MemtoReg;
        wire [1:0] PCSource;
        wire [2:0] ALUOp;
        wire [2:0] ALUSrcB;
        wire [1:0]ALUSrcA;
        wire RegWrite;
        wire [1:0]RegDst;
        wire[5:0] opcode;
        ControlUnit ControlUnit(.clk(clk),.rst(rst),.opcode(opcode),.funct(Instruction_reg[5:0]),.PCWriteCond(PCWriteCond),.PCWrite(PCWrite),.MemRead(cu_MemRead),.MemWrite(cu_MemWrite)
        ,.MemtoReg(MemtoReg),.IRWrite(IRWrite),.PCSource(PCSource),.ALUOp(ALUOp),.ALUSrcB(ALUSrcB),.ALUSrcA(ALUSrcA),.RegWrite(RegWrite),.RegDst(RegDst),.cycle_cnt(cycle_cnt),.inst_cnt(inst_cnt),.br_cnt(br_cnt),.ld_cnt(ld_cnt),.st_cnt(st_cnt));
    
        wire[2:0] ALUop;
        ALU_control ALU_control(Instruction_reg[5:0],Instruction_reg[31:26],ALUOp,ALUop);
    
        wire[31:0] sa;
        assign sa={27'b0,Instruction_reg[10:6]};
        assign opcode=Instruction_reg[31:26];
        assign reg_in_raddr1=Instruction_reg[25:21];
        assign reg_in_raddr2=Instruction_reg[20:16];
        assign reg_in_waddr=(RegDst[1])?5'b11111:((RegDst[0])?Instruction_reg[15:11]:Instruction_reg[20:16]);
         //assign reg_in_waddr=(RegDst)?Instruction_reg[15:11]:Instruction_reg[20:16];
        assign reg_in_wdata=(MemtoReg[1])?PC_reg:(MemtoReg[0])?Memory_data:ALUOut;
        assign wen=RegWrite;
    
        assign sign_extend={{16{Instruction_reg[15]}},Instruction_reg[15:0]};
    
        assign alu_in_A=(ALUSrcA[1])?B:(ALUSrcA[0])?A:PC;
        assign alu_in_B=(ALUSrcB[2])?sa:(ALUSrcB[1])?
        ((ALUSrcB[0])?sign_extend<<2:sign_extend):
        ((ALUSrcB[0])?32'd4:B);
        assign alu_in_ALUop=ALUop;
    
        assign PC_control=(Instruction_reg[26])?(PCWriteCond&~alu_out_zero)|PCWrite:(PCWriteCond&alu_out_zero)|PCWrite;
        assign PC_next=(PCSource[0])?
        ((PCSource[1])?32'd0:ALUOut):
        ((PCSource[1])? {PC[31:28], Instruction_reg[25:0], 2'b0} :alu_out_result);
    
        assign Address=ALUOut;
        assign Write_data = B;
        assign MemRead=cu_MemRead;
        assign MemWrite = cu_MemWrite;
    
        reg [31:0] PC_reg;
        assign PC=PC_reg;
    
    
    always @(posedge clk)
        begin
            if(rst)
            begin
                PC_reg <= 32'd0;
                Instruction_reg=32'b0;
                Memory_data = 32'b0;
                A = 32'b0;
                B = 32'b0;
                ALUOut = 32'b0;
            end
            else if(PC_control)
                PC_reg <= PC_next;
    
            if(IRWrite)
                Instruction_reg = Instruction;
            
            Memory_data = Read_data;
            A = reg_out_rdata1;
            B = reg_out_rdata2;
            ALUOut = alu_out_result;
            
        end
    
    
        
    endmodule
    
    
    module ALU_control(
    input [5:0] funct,
    input [5:0] opcode,
    input [1:0] ALUOp,
    output reg [2:0] ALUop
    );
    always@(*)
    begin
      case(ALUOp)
      2'b00:
      ALUop=3'b010;
      2'b10:
      begin
        case(funct)
        6'b100001:ALUop=3'b010;//addu
        6'b100000:ALUop=3'b010;//add
        6'b100011:ALUop=3'b110;//subu
        6'b100010:ALUop=3'b110;//sub
        6'b001000:ALUop=3'b010;//JR
        6'b000000:ALUop=3'b101;//sll
        6'b100101:ALUop=3'b010;//or
        6'b100100:ALUop=3'b000;//and
        6'b101010:ALUop=3'b111;//slt
        default:ALUop=3'b010;
        endcase
        end
      2'b01:
      case(opcode)
      6'b000100:ALUop=3'b110;//beq,bne's sub
      6'b000101:ALUop=3'b110;//beq,bne
      6'b001111:ALUop=3'b011;//lui
      6'b001010:ALUop=3'b111;//slti
      6'b001011:ALUop=3'b100;//sltiu
    
      default:ALUop=3'b010;
      endcase
      default:ALUop=3'b000;
      endcase
    end
    endmodule
    
    
    module ControlUnit(
        input clk,
        input rst,
        input [5:0] opcode,
        input [5:0] funct,
        output reg PCWriteCond,
        output reg PCWrite,
        output reg MemRead,
        output reg MemWrite,
        output reg [1:0]MemtoReg,
        output reg IRWrite,
        output reg [1:0] PCSource,
        output reg [2:0] ALUOp,
        output reg [2:0] ALUSrcB,
        output reg [1:0]ALUSrcA,
        output reg RegWrite,
        output reg [1:0]RegDst,
        output reg [31:0] cycle_cnt,		//counter of total cycles
        output reg [31:0] inst_cnt,            //counter of total instructions
        output reg [31:0] br_cnt,            //counter of branch/jump instructions
        output reg [31:0] ld_cnt,            //counter of load instructions
        output reg [31:0] st_cnt            //counter of store instructions
    );
        reg[3:0] current_state, next_state;
        parameter [3:0] S0=4'b0000,S1=4'b0001,S2=4'b0010,S3=4'b0011,S4=4'b0100,S5=4'b0101,S6=4'b0110,S7=4'b0111,S8=4'b1000,S9=4'b1001,S10=4'b1010,S11=4'b1011,S12=4'b1100,S13=4'b1101,S14=4'b1110,S15=4'b1111;
        always@(posedge clk)
        begin
        if(rst)
        begin
        current_state<=S0;
        cycle_cnt<=0;
        inst_cnt<=0;
        br_cnt<=0;
        ld_cnt<=0;
        st_cnt<=0;
        end
        else
        begin
        cycle_cnt<=cycle_cnt+1;//cycles
         case(current_state)
           S0:inst_cnt=inst_cnt+1;
           S3:ld_cnt=ld_cnt+1;
           S5:st_cnt=st_cnt+1;
           S8:br_cnt=br_cnt+1;//beq,bne
           S9:br_cnt=br_cnt+1;//j
           S12:br_cnt=br_cnt+1;//jal
           S14:br_cnt=br_cnt+1;//jr
           default:;
           endcase
        current_state<=next_state;
        end
        end
     
        always@(current_state or opcode)
        begin
          case(current_state)
          S0:next_state=S1;
          S1:
          begin
            case(opcode[5:0])
            6'b000000:begin
            if(funct==6'b000000)
            next_state=S15;
            else
            next_state=S6;
            end//r_type
            6'b000101:next_state=S8;//bne
            6'b000100:next_state=S8;//beq
            6'b100011:next_state=S2;//lw
            6'b101011:next_state=S2;//sw
            6'b000010:next_state=S9;//j
            6'b000011:next_state=S12;
            6'b001111:next_state=S13;//lui
           6'b001010:next_state=S13;//slti
           6'b001001:next_state=S10;//addiu
           6'b001011:next_state=S13;//sltiu
            default:next_state=S0;
            endcase
          end
          S2:
          begin
            case(opcode[3])
            1'b0:next_state=S3;
            1'b1:next_state=S5;
            default:next_state=S0;
            endcase
            end
          S3:next_state=S4;
          S4:next_state=S0;
          S5:next_state=S0;
          S6:begin
          case(funct)
          6'b001000:next_state=S14;
          default:next_state=S7;
          endcase
          end
          S7:next_state=S0;
          S8:next_state=S0;
          S9:next_state=S0;
          S10:next_state=S11;
          S11:next_state=S0;
          S12:next_state=S0;
          S13:next_state=S11;
          S14:next_state=S0;
          S15:next_state=S7;
          default:next_state=S0;
          endcase
        end
    
        always@(*)
        begin
          case(current_state)
          S0:
          begin
         PCWriteCond<=0;
                PCWrite<=1;
                MemRead<=1;
                MemWrite<=0;
                MemtoReg<=00;
                IRWrite<=1;
                PCSource<=00;
                ALUOp<=00;
                ALUSrcB<=001;
                ALUSrcA<=00;
                RegWrite<=0;
                RegDst<=00; 
          end
          S1:
          begin
          PCWriteCond<=0;
                PCWrite<=0;
                MemRead<=0;
                MemWrite<=0;
                MemtoReg<=00;
                IRWrite<=0;
                PCSource<=00;
                ALUOp<=00;
                ALUSrcB<=011;
                ALUSrcA<=00;
                RegWrite<=0;
                RegDst<=00; 
          end
          S2:
          begin
             PCWriteCond<=0;
                    PCWrite<=0;
                    MemRead<=0;
                    MemWrite<=0;
                    MemtoReg<=00;
                    IRWrite<=0;
                    PCSource<=00;
                    ALUOp<=00;
                    ALUSrcB<=010;
                    ALUSrcA<=01;
                    RegWrite<=0;
                    RegDst<=00; 
          end
          S3:
        begin
                  PCWriteCond<=0;
                         PCWrite<=0;
                         MemRead<=1;
                         MemWrite<=0;
                         MemtoReg<=00;
                         IRWrite<=0;
                         PCSource<=00;
                         ALUOp<=00;
                         ALUSrcB<=000;
                         ALUSrcA<=00;
                         RegWrite<=0;
                         RegDst<=00; 
               end
          S4:
          begin
                  PCWriteCond<=0;
                         PCWrite<=0;
                         MemRead<=0;
                         MemWrite<=0;
                         MemtoReg<=01;
                         IRWrite<=0;
                         PCSource<=00;
                         ALUOp<=00;
                         ALUSrcB<=000;
                         ALUSrcA<=00;
                         RegWrite<=1;
                         RegDst<=00; 
               end
          S5:
           begin
                  PCWriteCond<=0;
                         PCWrite<=0;
                         MemRead<=0;
                         MemWrite<=1;
                         MemtoReg<=00;
                         IRWrite<=0;
                         PCSource<=00;
                         ALUOp<=00;
                         ALUSrcB<=000;
                         ALUSrcA<=00;
                         RegWrite<=0;
                         RegDst<=00; 
               end
          S6:
          begin
                  PCWriteCond<=0;
                         PCWrite<=0;
                         MemRead<=0;
                         MemWrite<=0;
                         MemtoReg<=00;
                         IRWrite<=0;
                         PCSource<=00;
                         ALUOp<=10;
                         ALUSrcB<=000;
                         ALUSrcA<=01;
                         RegWrite<=0;
                         RegDst<=00; 
               end
          S7:
           begin
                  PCWriteCond<=0;
                         PCWrite<=0;
                         MemRead<=0;
                         MemWrite<=0;
                         MemtoReg<=00;
                         IRWrite<=0;
                         PCSource<=00;
                         ALUOp<=00;
                         ALUSrcB<=000;
                         ALUSrcA<=00;
                         RegWrite<=1;
                         RegDst<=01; 
               end
          S8:
             begin
                  PCWriteCond<=1;
                         PCWrite<=0;
                         MemRead<=0;
                         MemWrite<=0;
                         MemtoReg<=00;
                         IRWrite<=0;
                         PCSource<=01;
                         ALUOp<=01;
                         ALUSrcB<=000;
                         ALUSrcA<=01;
                         RegWrite<=0;
                         RegDst<=00; 
               end
            S9:
            begin
                  PCWriteCond<=0;
                         PCWrite<=1;
                         MemRead<=0;
                         MemWrite<=0;
                         MemtoReg<=00;
                         IRWrite<=0;
                         PCSource<=10;
                         ALUOp<=00;
                         ALUSrcB<=000;
                         ALUSrcA<=00;
                         RegWrite<=0;
                         RegDst<=00; 
               end
               S10:
                begin
                            PCWriteCond<=0;
                                   PCWrite<=0;
                                   MemRead<=0;
                                   MemWrite<=0;
                                   MemtoReg<=00;
                                   IRWrite<=0;
                                   PCSource<=00;
                                   ALUOp<=00;
                                   ALUSrcB<=010;
                                   ALUSrcA<=01;
                                   RegWrite<=0;
                                   RegDst<=00; 
                         end
              S11:
              begin
                                      PCWriteCond<=0;
                                             PCWrite<=0;
                                             MemRead<=0;
                                             MemWrite<=0;
                                             MemtoReg<=00;
                                             IRWrite<=0;
                                             PCSource<=00;
                                             ALUOp<=00;
                                             ALUSrcB<=000;
                                             ALUSrcA<=00;
                                             RegWrite<=1;
                                             RegDst<=00; 
                                   end
            S12:
            begin
              PCWriteCond<=0;
                                             PCWrite<=1;
                                             MemRead<=0;
                                             MemWrite<=0;
                                             MemtoReg<=10;
                                             IRWrite<=0;
                                             PCSource<=10;
                                             ALUOp<=00;
                                             ALUSrcB<=000;
                                             ALUSrcA<=00;
                                             RegWrite<=1;
                                             RegDst<=10; 
            end
            S13:
                begin
                            PCWriteCond<=0;
                                   PCWrite<=0;
                                   MemRead<=0;
                                   MemWrite<=0;
                                   MemtoReg<=00;
                                   IRWrite<=0;
                                   PCSource<=00;
                                   ALUOp<=01;
                                   ALUSrcB<=010;
                                   ALUSrcA<=01;
                                   RegWrite<=0;
                                   RegDst<=00; 
                         end
               S14:
                begin
                            PCWriteCond<=0;
                                   PCWrite<=1;
                                   MemRead<=0;
                                   MemWrite<=0;
                                   MemtoReg<=00;
                                   IRWrite<=0;
                                   PCSource<=01;
                                   ALUOp<=00;
                                   ALUSrcB<=000;
                                   ALUSrcA<=00;
                                   RegWrite<=0;
                                   RegDst<=00; 
                         end
              S15:
                begin
                            PCWriteCond<=0;
                                   PCWrite<=0;
                                   MemRead<=0;
                                   MemWrite<=0;
                                   MemtoReg<=00;
                                   IRWrite<=0;
                                   PCSource<=00;
                                   ALUOp<=10;
                                   ALUSrcB<=100;
                                   ALUSrcA<=10;
                                   RegWrite<=0;
                                   RegDst<=00; 
                         end
          default:;
          endcase
        end
endmodule
