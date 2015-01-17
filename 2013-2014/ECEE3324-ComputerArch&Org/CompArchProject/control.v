`timescale 1ns/1ns      // needed for the delay at line 37

/*
* Control is a module that manages the setting of control values throughout the
* processor.
*
* Input:
*     opcode - 
*     rst    -
* 
* Output:
*     RegDst   - The value that controls the register destination mux
*     ALUsrc   - The value that controls the ALU source
*     MemtoReg - 1 if a value from memory should be written to registers
*     RegWrite - 1 if a register should be written to
*     MemRead  - 1 if memory should be read
*     MemWrite - 1 if memory should be written to
*     Branch   - 1 if this instruction should branch to a new instruction
*     ALUOp1   - second bit of the ALU opcode
*     ALUOP0   - first bit of the ALU opcode
*     Jump     - 1 if this instruction should jump to a new instruction
*     addI     - Is the instruction addI?
*     stop     - 1 if the program should end
*     
*/
module control (input [5:0] opcode,
                input rst,
                output reg RegDst, ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite,
                Branch, ALUOp1, ALUOp0, Jump, addI, stop);
  // These cases and outputs are taken from figure 4.22, P&H
  
  always @ (posedge rst) begin
    {RegDst, ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite,
                Branch, ALUOp1, ALUOp0, Jump, addI, stop} = 12'b000010000000;
  end
                     
  always @ (opcode) begin
    {RegDst, ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite,
                Branch, ALUOp1, ALUOp0, Jump, addI, stop} = 12'b000000000000;
    case (opcode)

      6'b00000 : begin        // r-type, add
        RegDst = 1;
        RegWrite = 1;
        ALUOp1 = 1;
        MemWrite = 0;
      end

      6'b001000: begin        // I-type, addI
        ALUsrc = 1;
        RegWrite = 1;
        MemWrite = 0;
		    ALUOp1 = 1;
		    addI = 1;
      end

      6'b100011: begin        // lw
        MemWrite = 0;
        ALUsrc = 1;
        MemtoReg = 1;
        RegWrite = 1;
        MemRead = 1;
      end

      6'b101011: begin        // sw
        ALUsrc = 1;
        #5 MemWrite = 1;         // delayed to allow for write to occur
		  end

      6'b000010: begin        // jump                
        Jump = 1;
        RegWrite = 0;
        MemWrite = 0;
      end

      6'b000100: begin        // beq
        Branch = 1;
        ALUOp0 = 1;
        MemWrite = 0;
      end

      6'b111111:              // stop
        {RegDst, ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite,
                Branch, ALUOp1, ALUOp0, Jump, addI, stop} = 12'b000000000001;

      default:
        {RegDst, ALUsrc, MemtoReg, RegWrite, MemRead, MemWrite,
                Branch, ALUOp1, ALUOp0, Jump, addI} = 11'b00000000000;

    endcase
  end
endmodule
          
