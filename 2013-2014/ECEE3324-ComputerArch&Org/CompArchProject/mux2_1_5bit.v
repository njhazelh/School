/*
* mux2_1_5bit is a module to select one of two 5-bit inputs.
* 
* Inputs:
*     in0 (5bit) - The value to output if sel is 0
*     in1 (5bit) - The value to output if sel is 1
*     sel (1bit) - The selector value
*
* Outputs:
*     out - The chosen value
*/
module mux2_1_5bit(input [4:0] in0, in1,
                   input sel,
                   output [4:0] out);
 
    assign out = (sel ? in1 : in0);
  
endmodule