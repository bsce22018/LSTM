`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 12:39:21 PM
// Design Name: 
// Module Name: lstm_cell
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

module lstm_cell (
    input clk,
    input reset,
    input signed [15:0] input_feature,     // x(t)
    output signed [15:0] hidden_output     // h(t)
);
    // Internal states
    reg signed [15:0] cell_state;
    reg signed [15:0] hidden_state;

    // Gate outputs
    wire signed [15:0] forget_gate;
    wire signed [15:0] input_gate;
    wire signed [15:0] output_gate;
    wire signed [15:0] cell_candidate;
    wire signed [15:0] new_cell_state;
    wire signed [15:0] new_hidden_state;

    // Example constant weights 
    localparam signed [15:0] W = 16'sd128;   // 0.5
    localparam signed [15:0] B = 16'sd0;

    lstm_gate forget(input_feature, hidden_state, W, W, B, forget_gate);
    lstm_gate inputg(input_feature, hidden_state, W, W, B, input_gate);
    lstm_gate outputg(input_feature, hidden_state, W, W, B, output_gate);
    lstm_gate cellg(input_feature, hidden_state, W, W, B, cell_candidate);

    cell_state_update c1(forget_gate, cell_state, input_gate, cell_candidate, new_cell_state);
    hidden_state_update h1(output_gate, new_cell_state, new_hidden_state);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cell_state   <= 16'sd0;
            hidden_state <= 16'sd0;
        end else begin
            cell_state   <= new_cell_state;
            hidden_state <= new_hidden_state;
        end
    end

    assign hidden_output = hidden_state;

endmodule

