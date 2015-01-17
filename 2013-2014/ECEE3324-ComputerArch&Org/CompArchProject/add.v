/*
* add is a module that adds two 32-bit inputs together
*
* Inputs:
*     in0 (32bit) - The first value to add
*     in1 (32bit) - The second value to add
* 
* Output:
*     out (32bit) - The result of addition
*/
module add (input [31:0] in0, in1,
            output reg [31:0] out);
            
    always @ (in0 or in1) begin   // asynchronous from the clock
        out = in0 + in1;
    end
  
endmodule
