`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2026 03:27:21 PM
// Design Name: 
// Module Name: uart_rx
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

module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire clk,
    input  wire rx,
    output reg  [7:0] data,
    output reg  valid
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;

    reg [15:0] clk_cnt = 0;
    reg [2:0]  bit_idx = 0;
    reg [7:0]  rx_shift = 0;
    reg        rx_busy = 0;

    always @(posedge clk) begin
        valid <= 0;

        if (!rx_busy) begin
            if (rx == 0) begin
                rx_busy <= 1;
                clk_cnt <= CLKS_PER_BIT / 2;
                bit_idx <= 0;
            end
        end else begin
            if (clk_cnt == CLKS_PER_BIT - 1) begin
                clk_cnt <= 0;

                if (bit_idx < 8) begin
                    rx_shift[bit_idx] <= rx;
                    bit_idx <= bit_idx + 1;
                end else begin
                    rx_busy <= 0;
                    data  <= rx_shift;
                    valid <= 1;
                end
            end else begin
                clk_cnt <= clk_cnt + 1;
            end
        end
    end
endmodule
