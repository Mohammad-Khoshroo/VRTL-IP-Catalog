`ifndef ARITHMETIC_ADDERS_VRTL_ADDER_CARRY_SKIP_SV
`define ARITHMETIC_ADDERS_VRTL_ADDER_CARRY_SKIP_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_cba_block_4b u_vrtl_cba_block_4b (
//     .a         (a),
//     .b         (b),
//     .cin       (cin),
//     .sum       (sum),
//     .cout      (cout),
//     .propagate (propagate)
// );
// =============================================================================
module vrtl_cba_block_4b (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout,
    output logic       propagate
);
  logic [3:0] p;
  logic [4:0] c;

  assign p = a ^ b;
  assign c[0] = cin;

  assign c[1] = (a[0] & b[0]) | (p[0] & c[0]);
  assign c[2] = (a[1] & b[1]) | (p[1] & c[1]);
  assign c[3] = (a[2] & b[2]) | (p[2] & c[2]);
  assign c[4] = (a[3] & b[3]) | (p[3] & c[3]);

  assign sum = p ^ c[3:0];
  assign propagate = &p;
  assign cout = propagate ? cin : c[4];
endmodule


// =============================================================================
// vrtl_carry_skip_adder_16b u_vrtl_carry_skip_adder_16b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_carry_skip_adder_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  wire [4:0] c;
  assign c[0] = cin;
  assign cout = c[4];

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : gen_skip_blocks
      vrtl_cba_block_4b blk (
          .a         (a[i*4 +: 4]),
          .b         (b[i*4 +: 4]),
          .cin       (c[i]),
          .sum       (sum[i*4 +: 4]),
          .cout      (c[i+1]),
          .propagate ()
      );
    end
  endgenerate
endmodule


// =============================================================================
// vrtl_carry_skip_adder_32b u_vrtl_carry_skip_adder_32b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_carry_skip_adder_32b (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        cin,
    output logic [31:0] sum,
    output logic        cout
);
  wire [8:0] c;
  assign c[0] = cin;
  assign cout = c[8];

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_skip_blocks
      vrtl_cba_block_4b blk (
          .a         (a[i*4 +: 4]),
          .b         (b[i*4 +: 4]),
          .cin       (c[i]),
          .sum       (sum[i*4 +: 4]),
          .cout      (c[i+1]),
          .propagate ()
      );
    end
  endgenerate
endmodule

`endif // ARITHMETIC_ADDERS_VRTL_ADDER_CARRY_SKIP_SV
