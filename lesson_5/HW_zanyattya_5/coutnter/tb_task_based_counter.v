`timescale 1ns/1ps

module tb_task_based_counter;

  reg   clk, rst, load, en, up_down;
  reg   [3:0] data_in;
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

  initial clk = 0;
  always #5 clk = ~clk;

  task apply_reset;
    begin
      rst = 1;
      #10;
      rst = 0;
    end
  endtask

  task count_up;
    input integer cycles;
    begin
      load = 0;
      en = 1;
      up_down = 1;
      #(cycles * 10);
    end
  endtask;

  task count_down;
    input integer cycles;
    begin
      load = 0;
      en = 1;
      up_down = 0;
      #(cycles * 10);
    end
  endtask

  task load_target_value;
    input [3:0] val;
    begin
      data_in = val;
      load = 1;
      #10;
      load = 0;
    end
  endtask

  initial begin
    $dumpfile("tb_task_based_counter.vcd");
    $dumpvars(0, tb_task_based_counter);

    rst = 0; load = 0; en = 0;
     up_down = 0; data_in = 4'b0000;

    apply_reset();

    count_up(17);

    count_down(4);

    load_target_value(4'b1010);

    count_down(2);

    #10 $finish;
  end

endmodule
