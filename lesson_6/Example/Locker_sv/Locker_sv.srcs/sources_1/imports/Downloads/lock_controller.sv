// lock_controller.sv
// Three-digit code lock controller, three-process pattern.
// Written in SystemVerilog: state_t (from lock_pkg) gives named states,
// so state.name() in the testbench (and the Wave window in Vivado)
// shows "WAIT_D2" etc. instead of a raw number.
//
// IMPORTANT: in your Vivado project, make sure both this file and
// lock_pkg.sv have File Type = SystemVerilog (Sources panel ->
// right-click -> Source File Properties), and that lock_pkg.sv is
// ordered/compiled before this file (Vivado normally handles package
// dependency order automatically).

import lock_pkg::*;

module lock_controller (
    input  logic       clk,
    input  logic       rst,        // asynchronous reset, active high
    input  logic [3:0] digit_in,
    output logic       unlocked_led
);

    // The 3-digit code. Change these three values to set a different code.
    localparam logic [3:0] CODE0 = 4'd5;
    localparam logic [3:0] CODE1 = 4'd3;
    localparam logic [3:0] CODE2 = 4'd7;

    state_t state, next_state;

    // ---- Block 1: state register (memory only) ----
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= LOCKED;
        else
            state <= next_state;
    end

    // ---- Block 2: next-state logic (transitions) ----
    always_comb begin
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
    always_comb begin
        unlocked_led = (state == UNLOCKED);
    end

endmodule
