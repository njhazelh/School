/*
* shiftL2_32bit is a module to left shift a 32-bit value by 2.
*
* Inputs:
*     in (32bit) - The value to shift
*
* Output:
*     out (32bit) - The resulting value
*/
module shiftL2_32bit (input [31:0] in,
                      output reg [31:0] out);
                      
    always @ (in) begin
        out = {in[29:0], 2'b00};
    end

endmodule