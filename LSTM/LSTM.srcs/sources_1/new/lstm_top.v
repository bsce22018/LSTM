`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 09:33:12 PM
// Design Name: 
// Module Name: lstm_top
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


module lstm_top (
    input clk,
    input reset,
    input  signed [3*16-1:0] input_vector,  // Flattened array [x, y, z]
    output signed [3*16-1:0] hidden_vector   // Flattened array [hx, hy, hz]
);

    // Unpack the inputs for clarity
    wire signed [15:0] x_in = input_vector[47:32];
    wire signed [15:0] y_in = input_vector[31:16];
    wire signed [15:0] z_in = input_vector[15:0];

    wire signed [15:0] x_out, y_out, z_out;

    // Instantiate 3 LSTM cells (one for each axis)
    lstm_cell1 lstm_x (.clk(clk), .reset(reset), .input_feature(x_in), .hidden_output(x_out));
    lstm_cell1 lstm_y (.clk(clk), .reset(reset), .input_feature(y_in), .hidden_output(y_out));
    lstm_cell1 lstm_z (.clk(clk), .reset(reset), .input_feature(z_in), .hidden_output(z_out));

    // Pack the outputs back into a vector
    assign hidden_vector = {x_out, y_out, z_out};

endmodule
