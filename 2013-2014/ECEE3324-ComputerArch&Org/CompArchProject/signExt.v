/*
* signExt is a module to sign extend a 16 bit integer value into a 32 bit value.
*
* Input:
*     in (16bit) - The value to extend.
* 
* Output:
*     out (32bit) - The sign extended value.
*/
module signExt (input [15:0] in,
                output reg [31:0] out);
  
    always @ (in) begin
        if (in[15] == 1'b1)
            out = {16'b1111111111111111, in};
        else
            out = {16'b0000000000000000, in};
    end

endmodule