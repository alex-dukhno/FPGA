// cdc_sync.v
// Two-flip-flop synchronizer for a single-bit signal crossing from
// clock domain A into clock domain B. Matches the lecture exactly:
// both stages clocked ONLY by clk_b, nothing between the two stages.

module cdc_sync (
    input  wire clk_b,      // clock of the RECEIVING domain
    input  wire enable_a,   // signal from domain A (asynchronous here)
    output reg  enable_b    // safe signal in domain B
);

    reg sync_stage1;

    always @(posedge clk_b) begin
        sync_stage1 <= enable_a;
        enable_b    <= sync_stage1;
    end
    // Nothing else here -- no combinational logic between the two
    // stages, per the lecture's critical rule.

endmodule
