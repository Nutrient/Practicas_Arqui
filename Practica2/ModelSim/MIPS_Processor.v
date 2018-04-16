/******************************************************************
* Description
*	This is the top-level of a MIPS processor that can execute the next set of instructions:
*		add
*		addi
*		sub
*		ori
*		or
*		bne
*		beq
*		and
*		nor
* This processor is written Verilog-HDL. Also, it is synthesizable into hardware.
* Parameter MEMORY_DEPTH configures the program memory to allocate the program to
* be execute. If the size of the program changes, thus, MEMORY_DEPTH must change.
* This processor was made for computer organization class at ITESO.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	12/06/2016
******************************************************************/


module MIPS_Processor
#(
	parameter MEMORY_DEPTH = 32
)

(
	// Inputs
	input clk,
	input reset,
	input [7:0] PortIn,
	// Output
	output [31:0] ALUResultOut,
	output [31:0] PortOut
);
//******************************************************************/
//******************************************************************/
assign  PortOut = 0;

//******************************************************************/
//******************************************************************/
// Data types to connect modules
wire BranchEQ_NE_wire;
wire MemRead_wire;
wire MemtoReg_wire;
wire MemWrite_wire;
wire RegDst_wire;
wire NotZeroANDBrachNE;
wire ZeroANDBrachEQ;
wire ORForBranch;
wire ALUSrc_wire;
wire PCSrc_wire;
wire RegWrite_wire;
wire Jump_wire;
wire Zero_wire;
wire [2:0] ALUOp_wire;
wire [3:0] ALUOperation_wire;
wire [4:0] WriteRegister_wire;
wire [31:0] MUX_PC_wire;
wire [31:0] PC_wire;
wire [31:0] Instruction_wire;
wire [31:0] ReadData1_wire;
wire [31:0] ReadData2_wire;
wire [31:0] InmmediateExtend_wire;
wire [31:0] ReadData2OrInmmediate_wire;
wire [31:0] ALUResult_wire;
wire [31:0] PC_4_wire;
wire [31:0] InmmediateExtendAnded_wire;
wire [31:0] PCtoBranch_wire;
wire [31:0] MUX_ReadData_ALUResult_wire;
wire [31:0] PC_Shift2_wire;
wire [31:0] ShiftLeft2_SignExt_wire;
wire [31:0] Shifted28_wire;
wire [31:0] MUX_to_PC_wire;
wire [31:0] MUX_to_MUX_wire;
wire [31:0] MUX_ForRetJumpAndJump;
integer ALUStatus;


//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Control
ControlUnit
(
	.OP(Instruction_wire[31:26]),
	.RegDst(RegDst_wire),
	.BranchEQ_NE(BranchEQ_NE_wire),
	.MemRead(MemRead_wire),
	.MemtoReg(MemtoReg_wire),
	.MemWrite(MemWrite_wire),
	.ALUOp(ALUOp_wire),
	.ALUSrc(ALUSrc_wire),
	.Jump(Jump_wire),
	.RegWrite(RegWrite_wire)
);

PC_Register
ProgramCounter
(
	.clk(clk),
	.reset(reset),
	.NewPC(MUX_to_PC_wire),

	.PCValue(PC_wire)
);




ProgramMemory
#(
	.MEMORY_DEPTH(MEMORY_DEPTH)
)
ROMProgramMemory
(
	.Address(PC_wire),
	.Instruction(Instruction_wire)
);

Adder32bits
PC_Puls_4
(
	.Data0(PC_wire),
	.Data1(4),
	
	.Result(PC_4_wire)
);

ShiftLeft2
Left2
(
	.DataInput(InmmediateExtend_wire),

	.DataOutput(ShiftLeft2_SignExt_wire)
);

ShiftLeft2
ShiftLeft28
(
	.DataInput({6'b00000,Instruction_wire[25:0]}),

	.DataOutput(Shifted28_wire)
);

assign PCSrc_wire = BranchEQ_NE_wire & Zero_wire;

Adder32bits
PC_Adder_Shift2
(
	.Data0(PC_4_wire),
	.Data1(ShiftLeft2_SignExt_wire),
	
	.Result(PC_Shift2_wire)


);

Multiplexer2to1
#(
	.NBits(32)
)
PCShift_OR_PC
(
	.Selector(PCSrc_wire),
	.MUX_Data0(PC_4_wire),
	.MUX_Data1(PC_Shift2_wire),

	.MUX_Output(MUX_to_MUX_wire)
);


Multiplexer2to1
#(
	.NBits(32)
)
MUX_PCJump
(
	.Selector(Jump_wire),
	.MUX_Data0(MUX_to_MUX_wire),
	.MUX_Data1({PC_4_wire[31:28],Shifted28_wire[27:0]}),

	.MUX_Output(MUX_ForRetJumpAndJump)
);

//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Multiplexer2to1
#(
	.NBits(5)
)
MUX_ForRTypeAndIType
(
	.Selector(RegDst_wire),
	.MUX_Data0(Instruction_wire[20:16]),
	.MUX_Data1(Instruction_wire[15:11]),
	
	.MUX_Output(WriteRegister_wire)

);



RegisterFile
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(RegWrite_wire),
	.WriteRegister(WriteRegister_wire),
	.ReadRegister1(Instruction_wire[25:21]),
	.ReadRegister2(Instruction_wire[20:16]),
	.WriteData(MUX_ReadData_ALUResult_wire),
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);

SignExtend
SignExtendForConstants
(   
	.DataInput(Instruction_wire[15:0]),
   .SignExtendOutput(InmmediateExtend_wire)
);



Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(ALUSrc_wire),
	.MUX_Data0(ReadData2_wire),
	.MUX_Data1(InmmediateExtend_wire),
	
	.MUX_Output(ReadData2OrInmmediate_wire)

);


ALUControl
ArithmeticLogicUnitControl
(
	.ALUOp(ALUOp_wire),
	.ALUFunction(Instruction_wire[5:0]),
	.ALUOperation(ALUOperation_wire)

);



ALU
ArithmeticLogicUnit 
(
	.ALUOperation(ALUOperation_wire),
	.A(ReadData1_wire),
	.B(ReadData2OrInmmediate_wire),
	.shamt(Instruction_wire[10:6]),
	.Zero(Zero_wire),
	.ALUResult(ALUResult_wire)
);

//Added

DataMemory
DataMemory
(
	//In
	.clk(clk),
	.WriteData(ReadData2_wire),
	.Address({20'b0,ALUResult_wire[11:0]>>2}),
	.MemRead(MemRead_wire),
	.MemWrite(MemWrite_wire),
	//out
	.ReadData(ReadData_wire)
	
	
);

Multiplexer2to1
MUX_ForJalAndReadData_AlUResult
(
	.Selector(JumpJal_wire),
	.MUX_Data0(MUX_ReadData_ALUResult_wire),
	.MUX_Data1(PC_4_wire),

	.MUX_Output(MUX_Jal_ReadData_ALUResult_wire)
);


Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForALUResultAndReadData
(
	.Selector(MemtoReg_wire),
	.MUX_Data0(ALUResult_wire),
	.MUX_Data1(ReadData_wire),

	.MUX_Output(MUX_ReadData_ALUResult_wire)
);

assign JumpR_wire = (ALUOperation_wire == 4'b1110) ? 1'b1 : 1'b0;

assign JumpJal_wire = ({Instruction_wire[31:26],Jump_wire} == 7) ? 1'b1 : 1'b0;



Multiplexer2to1
MUX_ForRJumpAndJump
(
	.Selector(JumpR_wire),
	.MUX_Data0(MUX_ForRetJumpAndJump),
	.MUX_Data1(ReadData1_wire),

	.MUX_Output(MUX_to_PC_wire)
);




assign ALUResultOut = ALUResult_wire;


endmodule

