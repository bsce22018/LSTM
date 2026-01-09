`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 12:35:51 PM
// Design Name: 
// Module Name: sigmoid_activation
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


module sigmoid_activation (
    input  signed [15:0] input_value,
    output reg signed [15:0] sigmoid_output
);
    always @(*) begin
        // Clamp extreme values
        if (input_value <= -16'sd2048)      // ? -8
            sigmoid_output = 16'sd0;         // 0.0
        else if (input_value >= 16'sd2048)   // ? +8
            sigmoid_output = 16'sd256;       // 1.0
        else
            // Linear approximation near 0:
            // sigmoid(x) ? 0.5 + x/8
            sigmoid_output = 16'sd128 + (input_value >>> 3);
    end
endmodule

