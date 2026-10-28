`ifndef ARITHMETIC_MULTIPLIERS_VRTL_MULT_BAUGH_WOOLEY_SV
`define ARITHMETIC_MULTIPLIERS_VRTL_MULT_BAUGH_WOOLEY_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_baugh_wooley_mult_4x4 u_vrtl_baugh_wooley_mult_4x4 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_baugh_wooley_mult_4x4 (
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,
    output logic signed [7:0] product
);
  logic [3:0] p [4];

  always_comb begin
    // Standard Baugh-Wooley cross-term inversion
    p[0] = { ~(a[3] & b[0]),  (a[2] & b[0]),  (a[1] & b[0]),  (a[0] & b[0]) };
    p[1] = { ~(a[3] & b[1]),  (a[2] & b[1]),  (a[1] & b[1]),  (a[0] & b[1]) };
    p[2] = { ~(a[3] & b[2]),  (a[2] & b[2]),  (a[1] & b[2]),  (a[0] & b[2]) };
    p[3] = {  (a[3] & b[3]), ~(a[2] & b[3]), ~(a[1] & b[3]), ~(a[0] & b[3]) };

    // Accumulation with fixed bias 2^7 + 2^4 = 8'b1001_0000
    product = 8'b1001_0000 + 8'(p[0]) + (8'(p[1]) << 1) + (8'(p[2]) << 2) + (8'(p[3]) << 3);
  end
endmodule


// =============================================================================
// vrtl_baugh_wooley_mult_8x8 u_vrtl_baugh_wooley_mult_8x8 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_baugh_wooley_mult_8x8 (
    input  logic signed [7:0]  a,
    input  logic signed [7:0]  b,
    output logic signed [15:0] product
);
  assign product = a * b;
endmodule

`endif // ARITHMETIC_MULTIPLIERS_VRTL_MULT_BAUGH_WOOLEY_SV
