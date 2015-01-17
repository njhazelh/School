`timescale 1ns/1ns      // needed for the delay of stop

/*
* CPU is a module containing all the parts of our CPU linked together.
*
* Input:
*     clk (1bit) - The clock. Changes typically made on posedges
*     rst (1bit) - The reset value.
*/
module CPU (input clk, input rst); 

    // Wires
    wire [31:0] PCin, PCout, Add4Out, Instruction, SEout, WriteData, RD1, RD2;
    wire [31:0] JumpAddr, ALUB, ALUout, SL1out, MX2_1_in, MX3_0_in, MX4_1_in;
    wire [27:0] SL0out_28bits;
    wire [4:0] WriteReg;
    wire [3:0] ALUctrl;
    wire [1:0] ALUop;
    wire Zero, MX2_ctrl;

    //control signals
    wire RegDst, ALUsrc, MemtoReg, RegWrite, MemRead;
    wire MemWrite, Branch, ALUOp1, ALUOp0, Jump, addI, stop;

    // Assignments
    assign ALUop = {ALUOp1, ALUOp0};
    assign JumpAddr = {Add4Out[31:28], SL0out_28bits};
    assign MX2_ctrl = Branch & Zero;

    // Modules
    PC              PC0(PCin, clk, rst, PCout);
    add4            AD0(PCout, Add4Out);
    control         CN0(Instruction[31:26], rst, RegDst, ALUsrc, MemtoReg,
                        RegWrite, MemRead, MemWrite, Branch, ALUOp1,
                        ALUOp0, Jump, addI, stop);
    signExt         SE0(Instruction[15:0], SEout[31:0]);
    aluCtrl         AC0(ALUop, addI, Instruction[5:0], ALUctrl);
    mux2_1_5bit     MX0(Instruction[20:16], Instruction[15:11], RegDst,
                        WriteReg);
    reg_file        RF0(Instruction[25:21], Instruction[20:16], WriteReg,
                        WriteData, RegWrite, clk, rst, RD1, RD2);
    shiftL2_26bit   SL0(Instruction[25:0], SL0out_28bits);
    mux2_1_32bit    MX1(RD2, SEout, ALUsrc, ALUB);
    ALU             AL0(RD1, ALUB, ALUctrl, ALUout, Zero);
    shiftL2_32bit   SL1(SEout, SL1out);
    add             AD1(Add4Out, SL1out, MX2_1_in);
    mux2_1_32bit    MX2(Add4Out, MX2_1_in, MX2_ctrl, MX3_0_in);
    mux2_1_32bit    MX3(MX3_0_in, JumpAddr, Jump, PCin);
    mux2_1_32bit    MX4(ALUout, MX4_1_in, MemtoReg, WriteData);
    Memory          MEM(PCout, Instruction, ALUout, RD2,  MemRead, MemWrite,
                        MX4_1_in);

    // Stop processing after the cycle ends
    always @ (posedge stop) #10 $stop; // #10 to allow last reg write
endmodule