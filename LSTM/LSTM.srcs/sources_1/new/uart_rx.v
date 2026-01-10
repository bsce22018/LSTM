module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 115200
)(
    input  wire        clk,
    input  wire        rst_n,    // active low reset (add reset for safety)
    input  wire        rx,       // asynchronous UART RX
    output reg  [7:0]  data,
    output reg         valid,
    output reg         framing_error  // optional: high for 1 cycle when stop bit not high
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;

    // Synchronizer for async rx
    reg rx_sync_0 = 1'b1;
    reg rx_sync_1 = 1'b1;

    // State machine / counters
    reg [15:0] clk_cnt = 0;
    reg [3:0]  bit_idx = 0;   // up to 8, need 4 bits
    reg [7:0]  rx_shift = 0;
    reg        rx_busy = 1'b0;
    reg        rx_start_edge = 1'b0;
    reg        rx_prev = 1'b1;

    // Synchronize rx and detect falling edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_sync_0 <= 1'b1;
            rx_sync_1 <= 1'b1;
            rx_prev   <= 1'b1;
            rx_start_edge <= 1'b0;
        end else begin
            rx_sync_0 <= rx;
            rx_sync_1 <= rx_sync_0;
            rx_prev   <= rx_sync_1;
            // falling edge detection: prev high, now low
            rx_start_edge <= (rx_prev == 1'b1 && rx_sync_1 == 1'b0);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt       <= 0;
            bit_idx       <= 0;
            rx_shift      <= 0;
            rx_busy       <= 1'b0;
            data          <= 8'h00;
            valid         <= 1'b0;
            framing_error <= 1'b0;
        end else begin
            valid <= 1'b0;
            framing_error <= 1'b0;

            if (!rx_busy) begin
                // Wait for a clean falling edge on synchronized rx (start bit)
                if (rx_start_edge) begin
                    rx_busy <= 1'b1;
                    // sample first data bit at ~1.5 bit times from the start edge:
                    // set clk_cnt so that the next sample occurs after CLKS_PER_BIT/2 cycles
                    // then after each CLKS_PER_BIT cycles sample next data bit.
                    clk_cnt <= CLKS_PER_BIT / 2;
                    bit_idx <= 0;
                end
            end else begin
                if (clk_cnt == CLKS_PER_BIT - 1) begin
                    clk_cnt <= 0;

                    if (bit_idx < 8) begin
                        // sample data bits LSB first
                        rx_shift[bit_idx] <= rx_sync_1;
                        bit_idx <= bit_idx + 1;
                    end else begin
                        // After 8 data bits, next sample is stop bit
                        // Check stop bit (should be 1)
                        if (rx_sync_1 == 1'b1) begin
                            data  <= rx_shift;
                            valid <= 1'b1;
                        end else begin
                            // framing error: stop bit low
                            framing_error <= 1'b1;
                            data <= rx_shift; // still present the received byte
                            valid <= 1'b1;
                        end
                        rx_busy <= 1'b0;
                    end
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end
        end
    end
endmodule
