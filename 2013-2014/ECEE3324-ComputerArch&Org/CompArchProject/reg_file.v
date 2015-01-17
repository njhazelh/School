/*
* reg_file is a module containing 32 32bit registers.  Data is read or written
* to the registers based on the input and control signals.
*
* Input:
*     readReg1  (5bit)  - The first register to read from
*     readReg2  (5bit)  - The second register to read from
*     writeReg  (5bit)  - The register to write to
*     writeData (32bit) - The data to write
*     enable    (1bit)  - 1 if the data should be written, else 0
*     clk       (1bit)  - The clock
*     rst       (1bit)  - The reset value (all registers set to 0 on negedge)
* 
* Output:
*     readData1 (32bit) - The data read from register readReg1
*     readData2 (32bit) - The data read from register readReg2
*/
module reg_file(input [4:0] readReg1, readReg2, writeReg,
                input [31:0] writeData,
                input enable, clk, rst,
                output [31:0] readData1, readData2);

    reg [31:0] registers [0:31];
    reg [31:0] readData1Reg, readData2Reg;
    assign readData1 = registers[readReg1];
    assign readData2 = registers[readReg2];

    always @ (negedge rst) begin
        registers [0] = 0;
        registers [1] = 0;
        registers [2] = 0;
        registers [3] = 0;
        registers [4] = 0;
        registers [5] = 0;
        registers [6] = 0;
        registers [7] = 0;
        registers [8] = 0;
        registers [9] = 0;
        registers [10] = 0;
        registers [11] = 0;
        registers [12] = 0;
        registers [13] = 0;
        registers [14] = 0;
        registers [15] = 0;
        registers [16] = 0;
        registers [17] = 0;
        registers [18] = 0;
        registers [19] = 0;
        registers [20] = 0;
        registers [21] = 0;
        registers [22] = 0;
        registers [23] = 0;
        registers [24] = 0;
        registers [25] = 0;
        registers [26] = 0;
        registers [27] = 0;
        registers [28] = 0;
        registers [29] = 0;
        registers [30] = 0;
        registers [31] = 0;
        readData1Reg = 0;
        readData2Reg = 0;
    end
	
	always @ (posedge clk) begin 
        readData1Reg = registers[readReg1];
        readData2Reg = registers[readReg2];
        if (enable && (writeReg != 0)) registers [writeReg] <= writeData;
            registers[readReg1] = readData1Reg;
            registers[readReg2] = readData2Reg;
    end

endmodule