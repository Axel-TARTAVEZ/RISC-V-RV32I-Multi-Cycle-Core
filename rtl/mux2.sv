module mux2 #(
    parameter int BW = 32
)(
    input logic [BW-1:0] in_a,
    input logic [BW-1:0] in_b,
    input logic sel,
    output logic [BW-1:0] out
);

always_comb begin
    if (sel) begin
        out = in_b; 
    end else begin
        out = in_a;
    end
end
endmodule