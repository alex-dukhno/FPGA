// tb_lock_controller.v
// Testbench for lock_controller.v: self-checking, task-based,
// success sequence AND error sequence (both required by the ДЗ).
//
// Console run (Vivado XSim), from the folder with both files:
//     xvlog lock_controller.v tb_lock_controller.v
//     xelab tb_lock_controller -s tb_sim
//     xsim tb_sim -R
// Local quick check (Icarus Verilog):
//     iverilog -o sim lock_controller.v tb_lock_controller.v
//     vvp sim

module tb_lock_controller;

    reg        clk;
    reg        rst;
    reg  [3:0] digit_in;
    wire       unlocked_led;

    lock_controller dut (
        .clk(clk), .rst(rst),
        .digit_in(digit_in), .unlocked_led(unlocked_led)
    );

    // ---- Clock generator ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Self-checking task: apply one digit, check the resulting state ----
    task automatic check_transition;
        input [3:0] digit_val;
        input [1:0] expected_state;
        input [8*40-1:0] step_name;  // fixed-width "string" (classic Verilog has no string type)
        begin
            digit_in = digit_val;
            @(posedge clk); #1;
            if (dut.state === expected_state)
                $display("[%0t ns] PASS: %0s -> state=%0d", $time, step_name, dut.state);
            else
                $display("[%0t ns] FAIL: %0s -> expected %0d, got %0d", $time, step_name, expected_state, dut.state);
        end
    endtask

    initial begin
        // ---- Reset ----
        rst = 1; digit_in = 4'd0;
        @(posedge clk); #1;
        rst = 0;
        $display("[%0t ns] after reset: state=%0d (expect LOCKED=0)", $time, dut.state);

        // ---- Scenario 1: correct sequence -> UNLOCKED ----
        check_transition(dut.CODE0, dut.WAIT_D2,  "digit1 correct");
        check_transition(dut.CODE1, dut.WAIT_D3,  "digit2 correct");
        check_transition(dut.CODE2, dut.UNLOCKED, "digit3 correct");
        if (unlocked_led === 1'b1)
            $display("[%0t ns] PASS: unlocked_led=1 after correct sequence", $time);
        else
            $display("[%0t ns] FAIL: unlocked_led expected 1, got %0b", $time, unlocked_led);

        // ---- Reset before the error scenario ----
        rst = 1; digit_in = 4'd0;
        @(posedge clk); #1;
        rst = 0;

        // ---- Scenario 2: error on the second digit -> back to LOCKED ----
        check_transition(dut.CODE0,     dut.WAIT_D2, "digit1 correct");
        check_transition(dut.CODE1 + 1, dut.LOCKED,  "digit2 WRONG -> reset to LOCKED");

        $display("[%0t ns] Simulation finished", $time);
        $finish;
    end

endmodule
