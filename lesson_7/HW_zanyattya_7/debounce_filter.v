module debounce_filter (
  input wire        clk,
  input wire        rst,
  input wire  [3:0] phys_btn,
  output  reg [3:0] clean_digit
);

  reg [9:0] counter;
  reg [3:0] stable_val;
  reg [3:0] prev_clean;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter    <= 0;
      stable_val <= 0;
      prev_clean <= 0;
      clean_digit<= 0;
    end else begin
      if (phys_btn == stable_val) begin
        counter <= 0;
      end else begin
        if (counter < 10'd50) begin
          counter <= counter + 1;
        end else begin
          counter    <= 0;
          stable_val <= phys_btn;
        end
      end

      prev_clean <= stable_val;
      if ((stable_val != 4'b0000) && (prev_clean == 4'b0000)) begin
        clean_digit <= stable_val;
      end else begin
        clean_digit <= 4'b0000;
      end
    end
  end
endmodule
