module counter_led (
    input   wire clock,
    input   wire reset,
    output  reg  [3:0] led
);

    always @(posedge clock or posedge reset) begin
        if (reset)
            led <= 4'b0000;
        else
            led <= led + 1'b1;
    end
endmodule
