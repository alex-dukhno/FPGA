module lock_controller (
  input wire        clk,
  input wire        rst,
  input wire  [3:0] digit_in,
  output  reg       unlocked_led
);

  localparam LOCKED   = 2'b00;
  localparam WAIT_D2  = 2'b01;
  localparam WAIT_D3  = 2'b10;
  localparam UNLOCKED = 2'b11;

  localparam CODE_1 = 4'd9;
  localparam CODE_2 = 4'd3;
  localparam CODE_3 = 4'd5;

  reg [1:0] state, next_state;

  always @(posedge clk or posedge rst) begin
    if (rst)
      state <= LOCKED;
    else
      state <= next_state;
  end

  always @(*) begin
    next_state = state;

    case (state)
      LOCKED: begin
        if (digit_in == CODE_1)
          next_state = WAIT_D2;
        else if (digit_in != 4'b0000)
          next_state = LOCKED;
      end

      WAIT_D2: begin
        if (digit_in == CODE_2)
          next_state = WAIT_D3;
        else if (digit_in != 4'b0000)
          next_state = LOCKED;
      end

      WAIT_D3: begin
        if (digit_in == CODE_3)
          next_state = UNLOCKED;
        else if (digit_in != 4'b0000)
          next_state = LOCKED;
      end

      UNLOCKED: begin
        next_state = UNLOCKED;
      end
    endcase
  end

  always @(*) begin
    if (state == UNLOCKED)
      unlocked_led = 1'b1;
    else
      unlocked_led = 1'b0;
  end
endmodule
