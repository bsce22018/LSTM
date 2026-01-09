`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 12:37:58 PM
// Design Name: 
// Module Name: lstm_gate
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

//gate=activation(Winput??input+Whidden??hidden+bias)
module lstm_gate (
    input  signed [15:0] input_feature,      // x(t)
    input  signed [15:0] previous_hidden,     // h(t-1)
    input  signed [15:0] weight_input,         // W_x
    input  signed [15:0] weight_hidden,        // W_h
    input  signed [15:0] bias,                 // Bias
    output signed [15:0] gate_output
);
    wire signed [15:0] mult_input;
    wire signed [15:0] mult_hidden;
    wire signed [15:0] sum1;
    wire signed [15:0] sum2;

    // W_x * x(t)
    fixed_point_multiplier m1(weight_input, input_feature, mult_input);

    // W_h * h(t-1)
    fixed_point_multiplier m2(weight_hidden, previous_hidden, mult_hidden);

    // Sum products
    fixed_point_adder a1(mult_input, mult_hidden, sum1);

    // Add bias
    fixed_point_adder a2(sum1, bias, sum2);

    // Sigmoid activation
    sigmoid_activation s1(sum2, gate_output);

endmodule

