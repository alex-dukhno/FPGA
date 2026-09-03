// tb_uart_rx.v
// Testbench for uart_rx.v: drives a full serial frame on rx (start bit,
// 8 data bits LSB first, stop bit) and self-checks that rx_data/byte_ready
// come out correctly. Also demonstrates a framing error (bad stop bit).
//
// Console run (Vivado XSim), from the folder with both files:
//     xvlog uart_rx.v tb_uart_rx.v
//     xelab tb_uart_rx -s tb_sim
//     xsim tb_sim -R
// Local quick check (Icarus Verilog):
//     iverilog -o sim uart_rx.v tb_uart_rx.v
//     vvp sim

module tb_uart_rx;

    reg        clk;
    reg        rst;
    reg        rx;
    reg        baud_tick;
    wire [7:0] rx_data;
    wire       byte_ready;

    uart_rx dut (
        .clk(clk), .rst(rst),
        .rx(rx), .baud_tick(baud_tick),
        .rx_data(rx_data), .byte_ready(byte_ready)
    );

    // ---- System clock ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- baud_tick: MUST be synchronized to clk. byte_ready/next_state
    // are computed combinationally from baud_tick, but only actually
    // LATCHED into registers on posedge clk -- so baud_tick has to be
    // held high across a real posedge, not just pulsed for a few ns,
    // or the FSM can miss it entirely. One simulated "bit period" here
    // = 4 clk cycles (arbitrary, just needs to be a few cycles). ----
    localparam BIT_PERIOD_CLKS = 4;

    // Captured right at the moment baud_tick is valid, since byte_ready
    // is a narrow Mealy pulse that disappears again once baud_tick drops.
    reg        cap_ready;
    reg  [7:0] cap_data;

    task automatic send_bit;
        input bit_val;
        begin
            rx = bit_val;
            repeat (BIT_PERIOD_CLKS - 1) @(posedge clk);
            #1;                     // clear the race at that last edge
            baud_tick = 1;
            #1;                     // let combinational byte_ready settle
            cap_ready = byte_ready; // capture NOW -- valid only this instant
            cap_data  = rx_data;
            @(posedge clk); #1;     // the edge Block 1 actually uses
            baud_tick = 0;
        end
    endtask

    // Sends one full UART frame: start bit, 8 data bits (LSB first),
    // stop bit. stop_val lets us send a BAD stop bit to test framing error.
    task automatic send_byte;
        input [7:0] data;
        input       stop_val;
        integer     i;
        begin
            send_bit(1'b0);              // start bit
            for (i = 0; i < 8; i = i + 1)
                send_bit(data[i]);        // data bits, LSB first
            send_bit(stop_val);           // stop bit -- cap_ready/cap_data
                                           // end up holding the values from
                                           // exactly this call
        end
    endtask

    task automatic check_byte;
        input [7:0] expected_data;
        input       expect_ready;
        input [8*32-1:0] name;
        begin
            if (cap_ready !== expect_ready)
                $display("[%0t ns] FAIL: %0s -> byte_ready expected %0b, got %0b",
                          $time, name, expect_ready, cap_ready);
            else if (expect_ready && cap_data !== expected_data)
                $display("[%0t ns] FAIL: %0s -> rx_data expected 0x%h, got 0x%h",
                          $time, name, expected_data, cap_data);
            else
                $display("[%0t ns] PASS: %0s -> byte_ready=%0b rx_data=0x%h",
                          $time, name, cap_ready, cap_data);
        end
    endtask

    initial begin
        rst = 1; rx = 1; baud_tick = 0;
        @(posedge clk); #1;
        rst = 0;
        $display("[%0t ns] after reset: rx_data=0x%h (expect 0x00)", $time, rx_data);

        // ---- Scenario 1: valid frame, byte = 0x53 ('S') ----
        send_byte(8'h53, 1'b1);   // good stop bit
        check_byte(8'h53, 1'b1, "valid frame 0x53");

        rx = 1; repeat (BIT_PERIOD_CLKS) @(posedge clk);  // idle gap

        // ---- Scenario 2: another valid frame, byte = 0xA5 ----
        send_byte(8'hA5, 1'b1);
        check_byte(8'hA5, 1'b1, "valid frame 0xA5");

        rx = 1; repeat (BIT_PERIOD_CLKS) @(posedge clk);

        // ---- Scenario 3: framing error -- bad stop bit ----
        send_byte(8'h3C, 1'b0);   // BAD stop bit (should be 1)
        check_byte(8'h00, 1'b0, "framing error (bad stop bit)");

        $display("[%0t ns] Simulation finished", $time);
        $finish;
    end

endmodule
