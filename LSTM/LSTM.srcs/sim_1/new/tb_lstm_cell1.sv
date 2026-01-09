
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2026 07:41:39 PM
// Design Name: 
// Module Name: tb_lstm_cell1
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
`timescale 1ns / 1ps

module tb_lstm_cell1;


    reg clk;
    reg reset;
    reg signed [47:0] input_vector; // Holds {X, Y, Z}
    wire signed [47:0] hidden_vector;

    // Fixed-point conversion helpers
    integer x_f, y_f, z_f;

    lstm_top dut (
        .clk(clk),
        .reset(reset),
        .input_vector(input_vector),
        .hidden_vector(hidden_vector)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer file, r;
    string line;
    real x_r, y_r, z_r;
    bit first_line = 1;

    initial begin
        reset = 1;
        input_vector = 0;
        #50 reset = 0;

        file = $fopen("accelerometer.csv", "r");
        if (file == 0) $fatal("CSV File not found!");

        while (!$feof(file)) begin
            r = $fgets(line, file);
            if (first_line) begin
                first_line = 0; 
            end else if (r > 0) begin
                r = $sscanf(line, "%f,%f,%f", x_r, y_r, z_r);
                
                if (r == 3) begin
                    // Convert all 3 to Q8.8
                    x_f = $rtoi(x_r * 256.0);
                    y_f = $rtoi(y_r * 256.0);
                    z_f = $rtoi(z_r * 256.0);

                    @(posedge clk);
                    input_vector <= {x_f[15:0], y_f[15:0], z_f[15:0]};

                    repeat(2) @(posedge clk);
                    
                    $display("X_OUT: %d | Y_OUT: %d | Z_OUT: %d", 
                              hidden_vector[47:32], 
                              hidden_vector[31:16], 
                              hidden_vector[15:0]);
                end
            end
        end
        #1000;  
        $fclose(file);
        $finish;
    end
endmodule
