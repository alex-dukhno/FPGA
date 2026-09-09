module counter (
  input   wire        clk,
  input   wire        rst,
  input   wire        load,
  input   wire  [3:0] data_in,
  input   wire        en,
  input   wire        up_down,
  output  reg   [3:0] count
);
  always @(posedge clk or posedge rst) begin
    if (rst === 1'b1) begin
      count <= 4'b0000;
    end

    else if (load === 1'b1) begin
      count <= data_in;
    end

    else if (en === 1'b1) begin
      if (up_down === 1'b1) begin
        count <= count + 1'b1;
      end

      else
        count <= count - 1'b1;
    end
  end
endmodule
