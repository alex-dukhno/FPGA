`timescale 1ns/1ps

module counter_led_tb;
    reg clk;
    reg reset;
    wire [3:0] led;

    counter_led uut(
        .clock(clk),
        .reset(reset),
        .led(led)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter_waveform.cvd");
        $dumpvars(0, counter_led_tb);

        $display("Time (ns) | Reset | LED Pattern (Binary) | LED Value (Dec)");
        $monitor("%8t |   %b   |         %b         |       %2d", $time, reset, led, led);

        reset = 1;
        #15;
        reset = 0;

        #180;

        $finish;
    end
endmodule
