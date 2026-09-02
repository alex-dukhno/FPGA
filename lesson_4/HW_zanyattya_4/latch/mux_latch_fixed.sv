module mux_latch (
    input   logic a, b,
    input   logic selected,
    output  logic out
);
    
    always_comb begin
        case (selected)
            1'b1: out = b;
            0'b1: out = a;
            default: y = 1'b0;
        endcase
    end
endmodule
