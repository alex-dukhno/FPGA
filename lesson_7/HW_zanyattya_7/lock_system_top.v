module lock_system_top (
  input   wire        clk,
  input   wire        rst,
  input   wire  [3:0] digit_in,
  output  wire        unlocked_led
);

  wire  [3:0] filtered_digit;

  debounce_filter u_debounce (
    .clk(clk),
    .rst(rst),
    .phys_btn(digit_in),
    .clean_digit(filtered_digit)
  );

  lock_controller u_lock (
    .clk(clk),
    .rst(rst),
    .digit_in(filtered_digit),
    .unlocked_led(unlocked_led)
  );

endmodule
