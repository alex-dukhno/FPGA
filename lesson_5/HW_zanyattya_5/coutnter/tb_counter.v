`timescale 1ns/1ps

module tb_counter;

  reg   clk;
  reg   rst;
  reg   load;
  reg   [3:0] data_in;
  reg   en;
  reg   up_down;
  wire  [3:0] count;

  counter uut (
    .clk(clk),
    .rst(rst),
    .load(load),
    .data_in(data_in),
    .en(en),
    .up_down(up_down),
    .count(count)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  task automatic check_count(input [3:0] expected, input string name);
    begin
      if (count === expected)
        $display("[PASS] %s: count is %d", name, count);
      else
        $display("[FAIL] %s: Expected %d, but got %d", name, expected, count);
    end
  endtask

  initial begin
    `ifdef __ICARUS__
    $dumpfile("tb_counter.vcd");
    $dumpvars(0, tb_counter);
    `endif

    rst = 0; load = 0; data_in = 0; en = 0; up_down = 0;

    #10;

    rst = 1;
    @(posedge clk); #1;
    rst = 0;

    load = 1; data_in = 4'd10;
    @(posedge clk); #1;
    load = 0;
    check_count(4'd10, "Load value 10");

    en = 1; up_down = 1;

    repeat(3) begin
      @(posedge clk); #1;
    end
    check_count(4'd13, "Count up 3 ticks to 13");

    repeat(3) begin
      @(posedge clk); #1;
    end
    check_count(4'd0, "Count up overrflow (15 -> 0)");

    en = 0;
    repeat(2) begin
      @(posedge clk); #1;
    end
    check_count(4'd0, "Hold value with EN=0");

    en = 1;
    up_down = 0;
    @(posedge clk); #1;
    check_count(4'd15, "Count down underflow (0 -> 15)");

    load = 1; data_in = 4'd5; en = 1; up_down = 1;
    @(posedge clk); #1;
    check_count(4'd5, "Priority: Load overrides Enable");

    load = 1; data_in = 4'd8;
    @(posedge clk); #1;

    load = 0; en = 1; up_down = 0;
    @(posedge clk); #1;
    check_count(4'd7, "Bonus: Normal count down (8 -> 7)");

    $display("All tests complete!");
    $finish;
  end
endmodule
