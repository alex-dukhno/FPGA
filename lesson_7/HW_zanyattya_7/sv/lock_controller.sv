module lock_controller (
  input   logic       clk,
  input   logic       rst,
  input   logic [3:0] digit_in,
  output  logic       unlocked_led
);
  
  typedef enum logic [1:0] { 
    LOCKED,
    WAIT_D2,
    WAIT_D3,
    UNLOCKED
  } state_t;

  state_t state, next_state;

  localparam logic [3:0] CODE_1 = 4'd9;
  localparam logic [3:0] CODE_2 = 4'd3;
  localparam logic [3:0] CODE_3 = 4'd5;

  always_ff @(posedge clk or posedge rst) begin
    if (rst)
      state <= LOCKED;
    else
      state <= next_state;
  end

  always_comb begin
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

      default:
        next_state = UNLOCKED;
    endcase
  end

  always_comb begin
    if (state == UNLOCKED)
      unlocked_led = 1'b1;
    else
      unlocked_led = 1'b0;
  end

endmodule
