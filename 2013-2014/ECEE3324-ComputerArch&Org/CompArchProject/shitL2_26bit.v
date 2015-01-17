/*
* shiftL2_26bit is a module that left shifts a 26-bit value by 2.
* 
* Input:
*     in (26bit) - The value to shift.
* 
* Output:
*     out (26-bit) - The resulting value after the shift.
*/
module shiftL2_26bit (input [25:0] in,
                      output reg [27:0] out);

    always @ (in) begin
        out = {in[25:0], 2'b00};
    end

endmodule