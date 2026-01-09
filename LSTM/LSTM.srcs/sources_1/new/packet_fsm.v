`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/08/2026 03:28:28 PM
// Design Name: 
// Module Name: packet_fsm
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


module packet_fsm (
    input clk,
    input [7:0] rx_data,
    input rx_valid,
    output reg signed [47:0] input_vector,
    output reg input_ready
);

    reg [2:0] state;
    reg signed [15:0] x, y, z;

    localparam IDLE=0, XL=1, XH=2, YL=3, YH=4, ZL=5, ZH=6, END=7;

    always @(posedge clk) begin
        input_ready <= 0;

        if (rx_valid) begin
            case (state)
                IDLE: if (rx_data == 8'hAA) state <= XL;
                XL:  begin x[7:0]  <= rx_data; state <= XH; end
                XH:  begin x[15:8] <= rx_data; state <= YL; end
                YL:  begin y[7:0]  <= rx_data; state <= YH; end
                YH:  begin y[15:8] <= rx_data; state <= ZL; end
                ZL:  begin z[7:0]  <= rx_data; state <= ZH; end
                ZH:  begin z[15:8] <= rx_data; state <= END; end
                END: begin
                    if (rx_data == 8'h55) begin
                        input_vector <= {x, y, z};
                        input_ready  <= 1;
                    end
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

