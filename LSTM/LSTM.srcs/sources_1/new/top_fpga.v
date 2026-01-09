`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2026 03:29:02 PM
// Design Name: 
// Module Name: top_fpga
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


module top_fpga (
    input  wire clk,
    input  wire uart_rx,
    output wire uart_tx,
    output reg  led
);

    wire [7:0] rx_byte;
    wire rx_valid;

    uart_rx rx0 (.clk(clk), .rx(uart_rx), .data(rx_byte), .valid(rx_valid));

    wire signed [47:0] input_vector;
    wire input_ready;

    packet_fsm fsm (
        .clk(clk),
        .rx_data(rx_byte),
        .rx_valid(rx_valid),
        .input_vector(input_vector),
        .input_ready(input_ready)
    );

    wire signed [47:0] hidden_vector;

    lstm_top lstm (
        .clk(clk),
        .reset(1'b0),
        .input_vector(input_vector),
        .hidden_vector(hidden_vector)
    );

    // Send HX only (for simplicity)
    reg [7:0] tx_data;
    reg send;

    uart_tx tx0 (.clk(clk), .data(tx_data), .send(send), .tx(uart_tx));

    always @(posedge clk) begin
        send <= 0;
        if (input_ready) begin
            tx_data <= hidden_vector[47:40];
            send <= 1;
            led <= ~led;
        end
    end
endmodule

