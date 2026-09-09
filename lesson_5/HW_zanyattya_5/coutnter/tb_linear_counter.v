`timescale 1ns/1ps

module tb_linear_counter;

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

    initial begin
      
      $dumpfile("tb_linear_counter.vcd");
      $dumpvars(0, tb_linear_counter);

      rst = 0; load = 0; en = 0; up_down = 1; data_in = 4'b0000;

      #2 rst = 1;
      #5 rst = 0;

      en = 1;
      up_down = 1;
      #170

      up_down = 0;
      #40;

      data_in = 4'b1010;
      load = 1;
      #10;
      load = 0;

      #20;

      $finish;
    end

endmodule
