`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 12:36:31 PM
// Design Name: 
// Module Name: tanh_activation
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


module tanh_activation (
    input  signed [15:0] input_value,
    output reg signed [15:0] tanh_output
);
    always @(*) begin
        if (input_value <= -16'sd2048)
            tanh_output = -16'sd256;   // -1.0
        else if (input_value >= 16'sd2048)
            tanh_output = 16'sd256;    // +1.0
        else
            // Linear approximation: tanh(x) ? x
            tanh_output = input_value;
    end
endmodule

