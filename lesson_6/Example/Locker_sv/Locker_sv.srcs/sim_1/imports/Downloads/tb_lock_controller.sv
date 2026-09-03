// tb_lock_controller.sv
// Testbench for lock_controller.sv: self-checking, task-based,
// success sequence AND error sequence -- and uses state.name() so
// PASS/FAIL output (and the Wave window, if you add `state` to it)
// shows readable names like "WAIT_D2" instead of a raw number.
//
// Console run (Vivado XSim), from the folder with all three files:
//     xvlog -sv lock_pkg.sv lock_controller.sv tb_lock_controller.sv
//     xelab tb_lock_controller -s tb_sim
//     xsim tb_sim -R
// (In the GUI, make sure File Type = SystemVerilog for all three files.)
//
// Local quick check (Icarus Verilog):
//     iverilog -g2012 -o sim lock_pkg.sv lock_controller.sv tb_lock_controller.sv
//     vvp sim

import lock_pkg::*;

module tb_lock_controller;

    logic       clk;
    logic       rst;
    logic [3:0] digit_in;
    logic       unlocked_led;

    lock_controller dut (
        .clk(clk), .rst(rst),
        .digit_in(digit_in), .unlocked_led(unlocked_led)
    );

    // ---- Clock generator ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Self-checking task: apply one digit, check the resulting state ----
    task automatic check_transition(
        input logic [3:0] digit_val,
        input state_t      expected_state,
        input string        step_name
    );
        digit_in = digit_val;
        @(posedge clk); #1;
        if (dut.state === expected_state)
            $display("[%0t ns] PASS: %-28s -> state=%s", $time, step_name, dut.state.name());
        else
            $display("[%0t ns] FAIL: %-28s -> expected %s, got %s",
                      $time, step_name, expected_state.name(), dut.state.name());
    endtask

    initial begin
        // ---- Reset ----
        rst = 1; digit_in = 4'd0;
        @(posedge clk); #1;
        rst = 0;
        $display("[%0t ns] after reset: state=%s (expect LOCKED)", $time, dut.state.name());

        // ---- Scenario 1: correct sequence -> UNLOCKED ----
        check_transition(dut.CODE0, WAIT_D2,  "digit1 correct");
        check_transition(dut.CODE1, WAIT_D3,  "digit2 correct");
        check_transition(dut.CODE2, UNLOCKED, "digit3 correct");
        if (unlocked_led === 1'b1)
            $display("[%0t ns] PASS: unlocked_led=1 after correct sequence", $time);
        else
            $display("[%0t ns] FAIL: unlocked_led expected 1, got %0b", $time, unlocked_led);

        // ---- Reset before the error scenario ----
        rst = 1; digit_in = 4'd0;
        @(posedge clk); #1;
        rst = 0;

        // ---- Scenario 2: error on the second digit -> back to LOCKED ----
        check_transition(dut.CODE0,     WAIT_D2, "digit1 correct");
        check_transition(dut.CODE1 + 1, LOCKED,  "digit2 WRONG -> back to LOCKED");

        $display("[%0t ns] Simulation finished", $time);
        $finish;
    end

endmodule
