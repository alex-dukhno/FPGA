`timescale 1ns/1ps

module tb_lock_system;
  
  reg clk, rst;
  reg [3:0] digit_in;
  wire unlocked_led;

  lock_system_top uut (
    .clk(clk),
    .rst(rst),
    .digit_in(digit_in),
    .unlocked_led(unlocked_led)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  task automatic send_bouncy_digit(input [3:0] digit);
    begin
      digit_in = digit; #15;
      digit_in = 4'b0000; #15;

      digit_in = digit;
      #800;

      digit_in = 4'b0000;
      #600;
    end
  endtask

  initial begin
    `ifdef __ICARUS__
    $dumpfile("lock_system_waveform.vcd");
    $dumpvars(0, tb_lock_system);
    `endif

    rst = 1; digit_in = 4'b0;
    #15;
    rst = 0;
    #15;

    $display("--- Testing Lock Controller with Debouncer (Code: 9-3-5) ---");

    send_bouncy_digit(4'd9);
    send_bouncy_digit(4'd3);
    send_bouncy_digit(4'd5);

    if (unlocked_led == 1'b1)
      $display("[PASS] Lock successfully unlocked despite noisy buttons!");
    else 
      $display("[FAIL] Lock failed to unlock.");

    #20;
    $finish;
  end
endmodule
