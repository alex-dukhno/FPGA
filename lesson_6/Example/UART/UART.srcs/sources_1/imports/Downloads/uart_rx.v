// uart_rx.v
// UART receiver: cyclic FSM IDLE -> START -> DATA -> STOP -> IDLE.
// Matches the state diagram from the lecture slides exactly.
// Written in classic Verilog (no logic/always_comb/always_ff/typedef).
//
// baud_tick is an EXTERNAL pulse (one pulse per bit period, ideally
// near the middle of each bit) -- generating it from clk is a separate
// concern (a simple clock divider) and is not detailed here, matching
// how it was taught: this module only cares that baud_tick arrives
// once per bit period, not where it comes from.

module uart_rx (
    input  wire       clk,
    input  wire       rst,        // asynchronous reset, active high
    input  wire       rx,         // serial input line
    input  wire       baud_tick,  // one pulse per bit period
    output reg  [7:0] rx_data,    // captured byte
    output reg        byte_ready  // one-cycle pulse: valid byte received
);

    // States
    localparam [1:0] IDLE  = 2'd0;
    localparam [1:0] START = 2'd1;
    localparam [1:0] DATA  = 2'd2;
    localparam [1:0] STOP  = 2'd3;

    reg [1:0] state, next_state;
    reg [2:0] bit_count, next_bit_count;  // 0..7

    // ---- Block 1: state + bit_count register (memory only) ----
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            bit_count <= 3'd0;
        end else begin
            state     <= next_state;
            bit_count <= next_bit_count;
        end
    end

    // ---- Block 2: next-state logic (transitions) ----
    always @(*) begin
        next_state     = state;      // default -> avoids an unintended latch
        next_bit_count = bit_count;  // default
        case (state)
            IDLE:
                if (!rx) next_state = START;
            START:
                if (baud_tick) begin
                    if (rx) begin
                        next_state = IDLE;  // was noise, not a real start bit
                    end else begin
                        next_state     = DATA;
                        next_bit_count = 3'd0;  // reset for the new byte
                    end
                end
            DATA:
                if (baud_tick) begin
                    if (bit_count == 3'd7)
                        next_state = STOP;
                    else
                        next_bit_count = bit_count + 3'd1;
                end
            STOP:
                if (baud_tick)
                    next_state = IDLE;
            default:
                next_state = IDLE;
        endcase
    end

    // ---- Block 3: output logic ----
    // rx_data: shift register, captures one bit per baud_tick while in DATA.
    // New bit goes into the MSB and everything shifts right -- after 8
    // shifts this correctly reconstructs an LSB-first serial stream.
    always @(posedge clk or posedge rst) begin
        if (rst)
            rx_data <= 8'd0;
        else if (state == DATA && baud_tick)
            rx_data <= { rx, rx_data[7:1] };
    end

    // byte_ready: Mealy-style -- checks the ACTUAL stop bit value at the
    // moment of sampling, not just "we are in state STOP". This is the
    // same byte_ready shown on the "UART RX -- Moore or Mealy?" slide.
    always @(*) begin
        byte_ready = (state == STOP) && baud_tick && rx;
    end

endmodule
