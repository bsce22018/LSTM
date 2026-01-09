`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2026 03:27:54 PM
// Design Name: 
// Module Name: uart_tx
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

module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire clk,
    input  wire [7:0] data,
    input  wire send,
    output reg  tx,
    output reg  busy
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;

    reg [9:0] shift;
    reg [15:0] clk_cnt;
    reg [3:0] bit_idx;

    initial tx = 1;

    always @(posedge clk) begin
        if (send && !busy) begin
            busy <= 1;
            shift <= {1'b1, data, 1'b0};
            bit_idx <= 0;
            clk_cnt <= 0;
        end else if (busy) begin
            if (clk_cnt == CLKS_PER_BIT - 1) begin
                clk_cnt <= 0;
                tx <= shift[bit_idx];
                bit_idx <= bit_idx + 1;

                if (bit_idx == 9) begin
                    busy <= 0;
                    tx <= 1;
                end
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end
endmodule

