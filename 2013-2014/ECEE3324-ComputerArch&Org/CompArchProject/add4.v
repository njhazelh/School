/*
* add4 is a module to add 4 to a 32-bit value
*
* Input:
*     in (32bit) - The data to add 4 to.
*
* Output:
*     out (32bit) - The result of the addition
*/
module add4 (input [31:0] in,
             output reg [31:0] out);
             
    always @ (in) begin   // asynchronous from the clock
        out = in + 4;
    end
  
endmodule