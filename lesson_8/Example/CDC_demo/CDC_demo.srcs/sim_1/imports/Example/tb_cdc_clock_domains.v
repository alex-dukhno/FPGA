// tb_cdc_clock_domains.v
// Testbench with GENUINELY different, coprime clock periods --
// GCD(10,33)=1, so the relative phase between clk_a and clk_b edges
// actually drifts through many different positions (full pattern
// repeats only every LCM(10,33)=330ns) instead of being frozen at
// one fixed relationship, which is what happens if you pick periods
// that are simple multiples of each other (e.g. 10ns and 30ns --
// GCD=10, the relationship never changes after the first cycle).
//
// Local quick check (Icarus Verilog):
//     iverilog -o sim counter_a.v counter_b.v cdc_sync.v cdc_clock_domains_top.v tb_cdc_clock_domains.v
//     vvp sim

module tb_cdc_clock_domains;

    reg  clk_a, clk_b, rst;
    wire [3:0] count_a_out;
    wire [7:0] count_b_out;

    cdc_clock_domains_top #(.WIDTH_A(4), .WIDTH_B(8)) dut (
        .clk_a(clk_a), .clk_b(clk_b), .rst(rst),
        .count_a_out(count_a_out), .count_b_out(count_b_out)
    );

    // ---- Domain A: 100 MHz (10 ns period) ----
    initial clk_a = 0;
    always #5 clk_a = ~clk_a;

    // ---- Domain B: ~30.3 MHz (33 ns period) -- COPRIME with 10ns ----
    initial clk_b = 0;
    always #16.5 clk_b = ~clk_b;

    integer i;
    reg [7:0] expected;

    initial begin
        rst = 1;
        repeat (3) @(posedge clk_a);
        rst = 0;
        expected = 8'd0;

        $display("[%0t ns] reset released, watching count_b track counter_a wraps...", $time);

        // counter_a (4-bit) wraps every 16 clk_a cycles = 160ns.
        // Wait for several wraps and check count_b tracks correctly,
        // allowing sync settle margin each time.
        for (i = 0; i < 6; i = i + 1) begin
            @(dut.tick_a_toggle);            // wait for the REAL next wrap event directly
            repeat (3) @(posedge clk_b); #1; // let the 2-FF sync settle
            expected = expected + 1'b1;
            if (count_b_out !== expected)
                $display("[%0t ns] FAIL: wrap %0d -> count_b expected %0d, got %0d",
                          $time, i, expected, count_b_out);
            else
                $display("[%0t ns] PASS: wrap %0d -> count_b=%0d", $time, i, count_b_out);
        end

        $display("[%0t ns] Simulation finished", $time);
        $finish;
    end

endmodule
