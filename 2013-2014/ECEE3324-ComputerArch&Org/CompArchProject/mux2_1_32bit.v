/*
* mux2_1_32bit is a module that selects one of two 32-bit inputs.
*
* Input:
*     in0 (32bit) - The value to select if sel is 0
*     in1 (32bit) - The value to select if sel is 1
*     sel (1bit)  - The selector
*
* Output:
*     out (32bit) - The chosen value
*/
module mux2_1_32bit(input [31:0] in0, in1,
                   input sel,
                   output [31:0] out);
 
    assign out = (sel ? in1 : in0);
  
endmodule