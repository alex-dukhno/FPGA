// counter_b.v
// Counts in clock domain B, incrementing once for every SAFELY
// SYNCHRONIZED tick received from domain A (tick_a_synced). This is
// the "receiving side" -- it never sees clk_a or tick_a directly,
// only the already-synchronized version.

module counter_b #(
    parameter WIDTH = 8
) (
    input  wire             clk_b,
    input  wire             rst,
    input  wire             tick_a_toggle_synced,   // already safe, from cdc_sync
    output reg  [WIDTH-1:0] count_b
);

    reg toggle_prev;   // detect a CHANGE (edge), not a level

    always @(posedge clk_b or posedge rst) begin
        if (rst) begin
            count_b     <= {WIDTH{1'b0}};
            toggle_prev <= 1'b0;
        end else begin
            toggle_prev <= tick_a_toggle_synced;
            if (tick_a_toggle_synced != toggle_prev)
                count_b <= count_b + 1'b1;
        end
    end

endmodule
