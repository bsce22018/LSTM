`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 07:04:16 PM
// Design Name: 
// Module Name: tb_lstm_cell
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


`timescale 1ns/1ps

module tb_lstm_cell;

    reg clk;
    reg reset;
    reg signed [15:0] input_feature;
    wire signed [15:0] hidden_output;

    // DUT
    lstm_cell LSTM (
        .clk(clk),
        .reset(reset),
        .input_feature(input_feature),
        .hidden_output(hidden_output)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // File I/O
    integer file;
    integer r;
    reg [255:0] line;
    reg [255:0] timestamp;
    real x_r, y_r, z_r;
    reg first_line;

    initial begin : read_loop
        reset = 1;
        input_feature = 0;
        first_line = 1;

        #20 reset = 0;

        file = $fopen("accelerometer.csv", "r");
        if (file == 0) begin
            $display("ERROR: File not found");
            $finish;
        end

        while (!$feof(file)) begin
            r = $fgets(line, file);
            if (r == 0) disable read_loop;

            if (first_line) begin
                first_line = 0; // skip header
            end else begin
                r = $sscanf(
                    line,
                    "%[^,],%*[^,],%f,%f,%f",
                    timestamp, x_r, y_r, z_r
                );

                if (r == 4) begin
                    // Q8.8 conversion
                    input_feature = $rtoi(x_r * 256.0);
                    @(posedge clk);

                    $display("Time=%s X=%f LSTM_out=%d",
                             timestamp, x_r, hidden_output);
                end
            end
        end

        $fclose(file);
        $display("Simulation completed");
        $finish;
    end

endmodule

