`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 12:33:02 PM
// Design Name: 
// Module Name: fixed_point_multiplier
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


module fixed_point_multiplier (
    input  signed [15:0] multiplicand,   // First fixed-point number
    input  signed [15:0] multiplier,       // Second fixed-point number
    output signed [15:0] product            // Result (Q8.8)
);
    // Intermediate 32-bit product
    wire signed [31:0] full_product;

    // Multiply the two inputs
    assign full_product = multiplicand * multiplier;

    // Scale back to Q8.8 by shifting right 8 bits
    assign product = full_product >>> 8;

endmodule

