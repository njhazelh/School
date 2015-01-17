`timescale 1ns/1ns

/*
* singleCycleCPU_tb is the test bench for our single cycle processor.
*/
module singleCycleCPU_tb;
    reg clk;
    reg rst;
    integer count;

    initial begin
        clk = 1;
        rst = 0;
        count = 0;
    end

    always #100 count = count+1;
    always #50 clk = ~clk;  

    initial begin    
        #25 rst = 1;
        #2 rst = 0;
    end

    CPU cpu(clk,rst); 

endmodule
