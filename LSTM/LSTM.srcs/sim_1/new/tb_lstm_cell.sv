`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 07:33:30 PM
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

    integer file;
    integer r;
    string timestamp;
    string line;
    real x_r, y_r, z_r;
    bit first_line;

    initial begin
        reset = 1;
        input_feature = 0;
        first_line = 1;

        #20 reset = 0;

        file = $fopen("accelerometer.csv", "r");
        if (file == 0) begin
            $fatal("ERROR: Cannot open CSV file");
        end

        while (!$feof(file)) begin
            line = "";
            r = $fgets(line, file);

            if (first_line) begin
                first_line = 0;
            end else begin
                r = $sscanf(
                    line,
                    "%[^,],%*[^,],%f,%f,%f",
                    timestamp, x_r, y_r, z_r
                );

                if (r == 4) begin
                    input_feature = $rtoi(x_r * 256.0);
                    @(posedge clk);

                    $display("Time=%s X=%f LSTM_out=%d",
                             timestamp, x_r, hidden_output);
                end
            end
        end

        $fclose(file);
        $display("Simulation finished OK");
        $finish;
    end

endmodule

