// cdc_clock_domains_top.v
// Clean CDC demonstration: two INDEPENDENT clock domains (clk_a,
// clk_b -- both real external inputs, no PS, no board-specific
// pins), a counter running in each, and a single-bit "tick" crossing
// from A to B through the already-verified cdc_sync.v (2-FF, part 4
// of the lecture). Built specifically to synthesize and explore in
// Vivado: Report Clock Networks (see the two separate clock trees),
// Report Clock Interaction (see the A->B crossing flagged and
// resolved by set_false_path in cdc_clock_domains_top.xdc).
//
// Generic ports -- not tied to any specific board's pin numbers.

module cdc_clock_domains_top #(
    parameter WIDTH_A = 4,
    parameter WIDTH_B = 8
) (
    input  wire                clk_a,
    input  wire                clk_b,
    input  wire                rst,
    output wire [WIDTH_A-1:0]  count_a_out,   // domain A's own counter, for observation
    output wire [WIDTH_B-1:0]  count_b_out    // domain B's counter, driven by the CDC tick
);

    wire tick_a_toggle;
    wire tick_a_toggle_synced;

    counter_a #(.WIDTH(WIDTH_A)) u_counter_a (
        .clk_a(clk_a), .rst(rst),
        .count_a(count_a_out), .tick_a_toggle(tick_a_toggle)
    );

    cdc_sync u_sync (
        .clk_b(clk_b), .enable_a(tick_a_toggle), .enable_b(tick_a_toggle_synced)
    );

    counter_b #(.WIDTH(WIDTH_B)) u_counter_b (
        .clk_b(clk_b), .rst(rst),
        .tick_a_toggle_synced(tick_a_toggle_synced), .count_b(count_b_out)
    );

endmodule
