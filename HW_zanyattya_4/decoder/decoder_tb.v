`timescale 1ns/1ps

module decoder_tb;

  reg   [1:0] in_4;
  wire  [3:0] out_4;

  reg   [2:0] in_8;
  wire  [7:0] out_8;

  decoder #(.WIDTH(4)) dec4 (
    .in(in_4),
    .out(out_4)
  );

  decoder #(.WIDTH(8)) dec8 (
    .in(in_8),
    .out(out_8)
  );

  initial begin
    $dumpfile("decoder_waveform.vcd");
    $dumpvars(0, decoder_tb);

    $display("--- Testing WIDTH 4 ---");
    for (integer i = 0; i < 4; i = i + 1) begin
      in_4 = i;
      #10;
      $display("Input: %0d (%b) -> Output: %b", in_4, in_4, out_4);
    end

    $display("\n --- Test WIDTH 8 ---");
    for (integer i = 0; i < 8; i = i + 1) begin
      in_8 = i;
      #10;
      $display("Input: %0d (%b) -> Output: %b", in_8, in_8, out_8);
    end

    #10 $finish;
  end

endmodule
