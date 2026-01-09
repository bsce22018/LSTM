`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 12:38:51 PM
// Design Name: 
// Module Name: hidden_state_update
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

//ht?=ot??tanh(ct?)
module hidden_state_update (
    input  signed [15:0] output_gate,
    input  signed [15:0] cell_state,
    output signed [15:0] hidden_state
);
    wire signed [15:0] tanh_cell;

    tanh_activation t1(cell_state, tanh_cell);
    fixed_point_multiplier m1(output_gate, tanh_cell, hidden_state);

endmodule

