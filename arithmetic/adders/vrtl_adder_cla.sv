`ifndef ARITHMETIC_ADDERS_VRTL_ADDER_CLA_SV
`define ARITHMETIC_ADDERS_VRTL_ADDER_CLA_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_cla_16b u_vrtl_cla_16b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_cla_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  logic [15:0] p, g;
  logic [16:0] c;

  assign p = a ^ b;
  assign g = a & b;
  assign c[0] = cin;

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_cla
      assign c[i+1]  = g[i] | (p[i] & c[i]);
      assign sum[i]  = p[i] ^ c[i];
    end
  endgenerate

  assign cout = c[16];
endmodule

`endif // ARITHMETIC_ADDERS_VRTL_ADDER_CLA_SV
