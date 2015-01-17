/*
* PC is a module to provide a single point of access to the program counter
* it also provides the ability to reset the counter to the base address, 0x10000
*
* Input:
*    in  (32bit) - The new potential program counter if rst is not 1
*    clk (1bit)  - The clock.  Changes are made to out at each posedge
*    rst (1bit)  - The reset value.  Sets output to 0x1000 if rst is 1.
*
* Output:
*    out (32bit) - The new program counter, which may have been reset.
*/
module PC(input [31:0] in,
          input clk, rst,
          output reg [31:0] out);

    always @ (posedge clk or posedge rst) begin
        out = !rst ? in : 32'h00001000;
    end
    
endmodule
