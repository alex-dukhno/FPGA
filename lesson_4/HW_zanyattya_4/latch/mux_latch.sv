module mux_latch (
    input   logic a, b,
    input   logic selected,
    output  logic out
);
    
    always_comb begin
        case (selected)
            1'b1: out = b;
        endcase
    end
endmodule
