/*
* ALU is a module to perform arithmetic operations.
* It supports AND, OR, ADD, SUB, SetLessThan, and NOR
*
* Modified from solution in hw6.
*
* Input:
*     in0 (32bit) - The first input
*     in1 (32bit) - The second input
*     operation (4bit) - The operation code.
* 
* Output:
*     out  (32bit) - The result of computation. 0 if operation unrecognized.
*     Zero (1bit)  - 1 iff the result of the operation was 0.
*/
module ALU(input [31:0] in0, in1,
           input [3:0] operation,            
           output reg [31:0] out,
           output Zero);

    assign Zero = (out == 0);

    always @ (in0 or in1 or operation) begin
        case (operation)
            4'b0000: begin // AND
                out <= in0 & in1;
            end
            4'b0001: begin // OR
                out <= in0 | in1;
            end
            4'b0010: begin // add
                out <= in0 + in1;
            end
            4'b0110: begin // subtract
                out <= in0 - in1;
            end
            4'b0111: begin // slt
                out <=  in0 < in1 ? 1 : 0;
            end
            4'b1100: begin // nor
                out <= ~( in0  | in1 );
            end
            default: begin
                out <= 0;
            end
        endcase
    end
endmodule