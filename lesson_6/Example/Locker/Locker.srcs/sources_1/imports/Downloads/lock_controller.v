// lock_controller.v
// Three-digit code lock controller, three-process pattern.
// Written in classic Verilog (no logic/always_comb/always_ff/typedef)
// so it drops straight into a Vivado project without any file-type
// detection issues (see earlier session notes on .sv vs .v problems).

module lock_controller (
    input  wire       clk,
    input  wire       rst,        // asynchronous reset, active high
    input  wire [3:0] digit_in,
    output reg        unlocked_led
);

    // The 3-digit code. Change these three values to set a different code.
    localparam [3:0] CODE0 = 4'd5;
    localparam [3:0] CODE1 = 4'd3;
    localparam [3:0] CODE2 = 4'd7;

    // States
    localparam [1:0] LOCKED   = 2'd0;
    localparam [1:0] WAIT_D2  = 2'd1;
    localparam [1:0] WAIT_D3  = 2'd2;
    localparam [1:0] UNLOCKED = 2'd3;

    reg [1:0] state, next_state;

    // ---- Block 1: state register (memory only) ----
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= LOCKED;
        else
            state <= next_state;
    end

    // ---- Block 2: next-state logic (transitions) ----
    always @(*) begin
        next_state = state;  // default -> avoids an unintended latch
        case (state)
            LOCKED:
                if (digit_in == CODE0) next_state = WAIT_D2;
                else                   next_state = LOCKED;
            WAIT_D2:
                if (digit_in == CODE1) next_state = WAIT_D3;
                else                   next_state = LOCKED;
            WAIT_D3:
                if (digit_in == CODE2) next_state = UNLOCKED;
                else                   next_state = LOCKED;
            UNLOCKED:
                next_state = UNLOCKED;
            default:
                next_state = LOCKED;
        endcase
    end

    // ---- Block 3: output logic (Moore -- depends only on state) ----
    always @(*) begin
        unlocked_led = (state == UNLOCKED);
    end

endmodule
