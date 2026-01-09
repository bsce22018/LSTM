`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 12:33:34 PM
// Design Name: 
// Module Name: fixed_point_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fixed_point_adder (
    input  signed [15:0] input_a,
    input  signed [15:0] input_b,
    output signed [15:0] sum
);
    assign sum = input_a + input_b;
endmodule

