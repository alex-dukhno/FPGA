// counter_a.v
// Free-running counter in clock domain A. Outputs both the raw count
// (for domain-A-local use, e.g. observing in the Wave window) and a
// single-cycle "tick" pulse every time it wraps around -- this pulse
// is the signal that will cross into domain B.

module counter_a #(
    parameter WIDTH = 4
) (
    input  wire             clk_a,
    input  wire             rst,
    output reg  [WIDTH-1:0] count_a,
    output reg              tick_a_toggle   // TOGGLES (not a pulse) on wrap
);

    // A single-cycle PULSE from the faster domain risks being missed
    // entirely by a slower receiving clock's sampling -- a TOGGLE
    // instead holds its new state until the NEXT wrap, guaranteed to
    // stay stable across at least one full clk_b period, so the
    // synchronizer can never miss it. The receiver (counter_b.v)
    // detects the toggle by comparing consecutive synchronized values.
    always @(posedge clk_a or posedge rst) begin
        if (rst) begin
            count_a      <= {WIDTH{1'b0}};
            tick_a_toggle <= 1'b0;
        end else begin
            count_a <= count_a + 1'b1;
            if (count_a == {WIDTH{1'b1}})
                tick_a_toggle <= ~tick_a_toggle;
        end
    end

endmodule
