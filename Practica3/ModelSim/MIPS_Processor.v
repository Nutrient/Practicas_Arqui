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
	parameter MEMORY_DEPTH = 64 //cambiamos el tamaño del programa para que pueda caber

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
wire JumpR_wire;
wire JumpJal_wire;
wire Zero_wire;
wire [2:0] ALUOp_wire;
wire [3:0] ALUOperation_wire;
wire [4:0] WriteRegister_wire;
wire [4:0] MUX_Ra_WriteRegister_wire;
wire [31:0] MUX_PC_wire;
wire [31:0] PC_wire;
wire [31:0] Instruction_wire;
wire [31:0] ReadData1_wire;
wire [31:0] ReadData2_wire;
wire [31:0] ReadData_wire;
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
wire [31:0] MUX_Jal_ReadData_ALUResult_wire;
integer ALUStatus;


//PipeRegister added

wire [31:0] ID_PC_4_wire;
wire [31:0] ID_Instruction_wire;

//PipeRegister ID_EX output
wire [31:0] ID_EX_ReadData1_wire;
wire [31:0] ID_EX_ReadData2_wire;
wire [31:0] ID_EX_InmmediateExtend_wire;
wire [31:0] ID_EX_ID_PC_4_wire;
wire [4:0]  ID_EX_Instruction_20_16_wire;
wire [4:0]  ID_EX_Instruction_15_11_wire;
wire ID_EX_RegWrite_wire;
wire ID_EX_MemWrite_wire;
wire ID_EX_MemtoReg_wire;
wire ID_EX_BranchEQ_NE_wire;
wire ID_EX_RegDst_wire;
wire ID_EX_ALUOp_wire;
wire ID_EX_ALUSrc_wire;
wire ID_EX_MemRead_wire;

//PipeRegister EX_MEM output
wire EX_EM_RegWrite_wire;
wire EX_EM_MemtoReg_wire;
wire EX_EM_MemWrite_wire;
wire EX_EM_BranchEQ_NE_wire;
wire EX_EM_MemRead_wire;
wire [31:0]EX_EM_PC_Shift2_wire ;
wire EX_EM_Zero_wire;
wire [31:0] EX_EM_ALUResult_wire ;
wire [31:0] EX_EM_ID_EX_ReadData2_wire;
wire [4:0] EX_EM_WriteRegister_wire ;

//PipeRegister MEM_WB
wire MEM_WB_RegWrite_wire;
wire MEM_WB_MemtoReg_wire;
wire [31:0] MEM_WB_ReadData_wire;
wire [31:0] MEM_WB_ALUResult_wire;
wire [4:0] MEM_WB_WriteRegister_wire;



//Se agregan los wires necesarios
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Control // de control agregamos las señales faltantes como jump, memwrite, etc
ControlUnit
(
	.OP(ID_Instruction_wire[31:26]),
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
	.DataInput(ID_EX_InmmediateExtend_wire),

	.DataOutput(ShiftLeft2_SignExt_wire)
);

ShiftLeft2 //concatenamos la direccion de salto
ShiftLeft28
(
	.DataInput({6'b00000,ID_Instruction_wire[25:0]}),

	.DataOutput(Shifted28_wire)
);

assign PCSrc_wire = EX_EM_BranchEQ_NE_wire & EX_EM_Zero_wire;

Adder32bits
PC_Adder_Shift2
(
	.Data0(ID_EX_ID_PC_4_wire),
	.Data1(ShiftLeft2_SignExt_wire),
	
	.Result(PC_Shift2_wire)


);

Multiplexer2to1 //seleccionamos cual sera la siguiente instruccion 
#(
	.NBits(32)
)
PCShift_OR_PC
(
	.Selector(PCSrc_wire),
	.MUX_Data0(PC_4_wire),
	.MUX_Data1(EX_EM_PC_Shift2_wire),

	.MUX_Output(MUX_to_MUX_wire)
);


Multiplexer2to1 //seleccionamos entre pc o jump
#(
	.NBits(32)
)
MUX_PCJump
(
	.Selector(Jump_wire),
	.MUX_Data0(MUX_to_MUX_wire),
	.MUX_Data1({ID_PC_4_wire[31:28],Shifted28_wire[27:0]}),

	.MUX_Output(MUX_ForRetJumpAndJump)
);

PipeRegister
#(
	.N(64)
)
PipeRegister_IF_ID
(

	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({PC_4_wire[31:0],Instruction_wire[31:0]}),

	.DataOutput({ID_PC_4_wire[31:0],ID_Instruction_wire[31:0]})

);

PipeRegister
#(
// 32 * 4 + 10 (2 Instructions) + 6 (1 bit control) + 3 (output ALUOP)
	.N(148)
)
PipeRegister_ID_EX
(

	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({RegWrite_wire,
					MemtoReg_wire,
					MemWrite_wire,
					BranchEQ_NE_wire,
					MemRead_wire,
					RegDst_wire,
					ALUOp_wire, //3
					ALUSrc_wire,
					ID_PC_4_wire[31:0],
					ReadData1_wire[31:0],
					ReadData2_wire[31:0],
					InmmediateExtend_wire[31:0],
					ID_Instruction_wire[20:16],
					ID_Instruction_wire[15:11]					
	
	}),

	.DataOutput({ID_EX_RegWrite_wire, //wb
					ID_EX_MemtoReg_wire, //wb
					ID_EX_MemWrite_wire,//m
					ID_EX_BranchEQ_NE_wire, //m
					ID_EX_MemRead_wire, //m
					ID_EX_RegDst_wire, //
					ID_EX_ALUOp_wire,
					ID_EX_ALUSrc_wire,
					ID_EX_ID_PC_4_wire[31:0],
					ID_EX_ReadData1_wire[31:0],
					ID_EX_ReadData2_wire[31:0],
					ID_EX_InmmediateExtend_wire[31:0],
					ID_EX_Instruction_20_16_wire[4:0],
					ID_EX_Instruction_15_11_wire[4:0]
	
	})

);

PipeRegister
#(
//5 + 32 + 1 + 32 + 32 + 5
	.N(107)
)
PipeRegister_EX_MEM
(
	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({
					ID_EX_RegWrite_wire,
					ID_EX_MemtoReg_wire,
					ID_EX_MemWrite_wire,
					ID_EX_BranchEQ_NE_wire,
					ID_EX_MemRead_wire,
					PC_Shift2_wire,
					Zero_wire,
					ALUResult_wire,
					ID_EX_ReadData2_wire[31:0],
					WriteRegister_wire
	}),


	.DataOutput({EX_EM_RegWrite_wire,
					 EX_EM_MemtoReg_wire,
					 EX_EM_MemWrite_wire,
					 EX_EM_BranchEQ_NE_wire,
					 EX_EM_MemRead_wire,
					 EX_EM_PC_Shift2_wire, 
					 EX_EM_Zero_wire,
					 EX_EM_ALUResult_wire, 
					 EX_EM_ID_EX_ReadData2_wire, 
					 EX_EM_WriteRegister_wire 
	
	})

);

PipeRegister
// 2
#(
	.N(71)
)
PipeRegister_MEM_WB
(

	.clk(clk),
	.reset(reset),
	.enable(1),
	.DataInput({EX_EM_RegWrite_wire,
				  EX_EM_MemtoReg_wire,
				  ReadData_wire,
				  EX_EM_ALUResult_wire,
				  EX_EM_WriteRegister_wire
	
	}),

	.DataOutput({MEM_WB_RegWrite_wire,
				  MEM_WB_MemtoReg_wire,
				  MEM_WB_ReadData_wire,
				  MEM_WB_ALUResult_wire,
				  MEM_WB_WriteRegister_wire})

);



//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
//******************************************************************/
Multiplexer2to1 //seleccionamos en que registro debemos escribir #Trump
#(
	.NBits(5)
)
MUX_ForRTypeAndIType
(
	.Selector(ID_EX_RegDst_wire),
	.MUX_Data0(ID_EX_Instruction_20_16_wire),
	.MUX_Data1(ID_EX_Instruction_15_11_wire),
	
	.MUX_Output(WriteRegister_wire)

);

Multiplexer2to1 //vemos si vamos a hacer jal o ejecutaremos la siguiente instruccion
#(
	.NBits(32)
)
MUX_ForJalAndReadData_AlUResult
(
	.Selector(JumpJal_wire),
	.MUX_Data0(MUX_ReadData_ALUResult_wire),
	.MUX_Data1(ID_PC_4_wire), //id_ex

	.MUX_Output(MUX_Jal_ReadData_ALUResult_wire)
);

Multiplexer2to1 //seleccionamos el registro en el que escribiremos
#(
	.NBits(5)
)
MUX_WriteRegister_Ra
(
	.Selector(JumpJal_wire),
	.MUX_Data0(WriteRegister_wire),
	.MUX_Data1(5'b11111),

	.MUX_Output(MUX_Ra_WriteRegister_wire)
);



RegisterFile
Register_File
(
	.clk(clk),
	.reset(reset),
	.RegWrite(MEM_WB_RegWrite_wire),
	.WriteRegister(MUX_Ra_WriteRegister_wire),
	.ReadRegister1(ID_Instruction_wire[25:21]),
	.ReadRegister2(ID_Instruction_wire[20:16]),
	.WriteData(MUX_Jal_ReadData_ALUResult_wire),
	.ReadData1(ReadData1_wire),
	.ReadData2(ReadData2_wire)

);

SignExtend
SignExtendForConstants
(   
	.DataInput(ID_Instruction_wire[15:0]),
   .SignExtendOutput(InmmediateExtend_wire)
);



Multiplexer2to1 //seleccionamos si vamos a leer de los registros o el valor de inmediato
#(
	.NBits(32)
)
MUX_ForReadDataAndInmediate
(
	.Selector(ID_EX_ALUSrc_wire),
	.MUX_Data0(ID_EX_ReadData2_wire),
	.MUX_Data1(ID_EX_InmmediateExtend_wire),
	
	.MUX_Output(ReadData2OrInmmediate_wire)

);


ALUControl
ArithmeticLogicUnitControl
(
	.ALUOp(ID_EX_ALUOp_wire),
	.ALUFunction(ID_EX_InmmediateExtend_wire[5:0]),
	.ALUOperation(ALUOperation_wire)

);



ALU
ArithmeticLogicUnit 
(
	.ALUOperation(ALUOperation_wire),
	.A(ID_EX_ReadData1_wire),
	.B(ReadData2OrInmmediate_wire),
	.shamt(ID_EX_InmmediateExtend_wire[10:6]),
	.Zero(Zero_wire),
	.ALUResult(ALUResult_wire)
);

//Added

DataMemory //nuestra RAM
#(	 
	 .DATA_WIDTH(32),
	 .MEMORY_DEPTH(1024)

)
DataMemory
(
	//In
	.clk(clk),
	.WriteData(EX_EM_ID_EX_ReadData2_wire),
	.Address({20'b0,EX_EM_ALUResult_wire[11:0]>>2}),
	.MemRead(EX_EM_MemRead_wire),
	.MemWrite(EX_EM_MemWrite_wire),
	//out
	.ReadData(ReadData_wire)
	
	
);




Multiplexer2to1
#(
	.NBits(32)
)
MUX_ForALUResultAndReadData //seleccionamos que resultado debemos enviar para escribir
(
	.Selector(MEM_WB_MemtoReg_wire),
	.MUX_Data0(MEM_WB_ALUResult_wire),
	.MUX_Data1(MEM_WB_ReadData_wire),

	.MUX_Output(MUX_ReadData_ALUResult_wire)
);

//Falta estos 2 de jump

assign JumpR_wire = (ALUOperation_wire == 4'b1110) ? 1'b1 : 1'b0; //vamos a ver si la instruccion fue JR

assign JumpJal_wire = ({Instruction_wire[31:26],Jump_wire} == 7) ? 1'b1 : 1'b0; // o vemos si es Jal



Multiplexer2to1
MUX_ForRJumpAndJump //seleccionamos a siguente instruccion del PC/jump
(
	.Selector(JumpR_wire),
	.MUX_Data0(MUX_ForRetJumpAndJump),
	.MUX_Data1(ReadData1_wire),

	.MUX_Output(MUX_to_PC_wire)
);




assign ALUResultOut = ALUResult_wire;


endmodule

