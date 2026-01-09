`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 12:38:25 PM
// Design Name: 
// Module Name: cell_state_update
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

//ct?=ft??ct-1?+it??gt?
module cell_state_update (
    input  signed [15:0] forget_gate,
    input  signed [15:0] previous_cell,
    input  signed [15:0] input_gate,
    input  signed [15:0] cell_candidate,
    output signed [15:0] cell_state
);
    wire signed [15:0] forget_part;
    wire signed [15:0] input_part;

    fixed_point_multiplier m1(forget_gate, previous_cell, forget_part);
    fixed_point_multiplier m2(input_gate, cell_candidate, input_part);

    fixed_point_adder a1(forget_part, input_part, cell_state);

endmodule

