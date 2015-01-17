/*
* aluCtrl is a module that controls the operation the ALU should perform.
* Modified from the solution in hw6
*
* Input:
*     ALUop (2bit)       - ALUop code
*     addI  (1bit)       - Is the instruction addI?
*     instruction (6bit) - The function code.
*
* Output:
*     operation (4bit) - The operation code for the ALU
*/
module aluCtrl(input[1:0] ALUop,
               input addI,
               input[5:0] instruction,
               output reg[3:0] operation );

    // These codes and outputs are taken from figure 4.13, P&H.

    always @ (ALUop or instruction) begin
        case (ALUop)

            2'b00: operation = 4'b0010;      // lw, sw -> add

            2'b01: operation = 4'b0110;      // branch equal -> sub     

            2'b10: begin
                if (addI)
                    operation = 4'b0010;
                else begin
                    case (instruction[3:0])
                        4'b0000: operation = 4'b0010;
                        4'b0010: operation = 4'b0110;
                        4'b0100: operation = 4'b0000;
                        4'b0101: operation = 4'b0001;
                        4'b1010: operation = 4'b0111;
                        default: operation = 4'b0000;
                    endcase
                end
            end

            2'b11: begin
                case (instruction[3:0])
                    4'b0010: operation = 4'b0110;
                    4'b1010: operation = 4'b0111;
                    default: operation = 4'b0000;
                endcase
            end

            default: operation = 4'b0000;

        endcase
    end
endmodule