`ifndef ARITHMETIC_ADDERS_VRTL_ADDER_CARRY_SELECT_SV
`define ARITHMETIC_ADDERS_VRTL_ADDER_CARRY_SELECT_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_csla_block_4b u_vrtl_csla_block_4b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_csla_block_4b (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);
  logic [4:0] sum0_ext, sum1_ext;

  assign sum0_ext = a + b + 1'b0;
  assign sum1_ext = a + b + 1'b1;

  assign sum  = cin ? sum1_ext[3:0] : sum0_ext[3:0];
  assign cout = cin ? sum1_ext[4]   : sum0_ext[4];
endmodule


// =============================================================================
// vrtl_carry_select_adder_16b u_vrtl_carry_select_adder_16b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_carry_select_adder_16b (
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
    for (i = 0; i < 4; i = i + 1) begin : gen_csla_blocks
      vrtl_csla_block_4b blk (
          .a    (a[i*4 +: 4]),
          .b    (b[i*4 +: 4]),
          .cin  (c[i]),
          .sum  (sum[i*4 +: 4]),
          .cout (c[i+1])
      );
    end
  endgenerate
endmodule


// =============================================================================
// vrtl_carry_select_adder_32b u_vrtl_carry_select_adder_32b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_carry_select_adder_32b (
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
    for (i = 0; i < 8; i = i + 1) begin : gen_csla_blocks
      vrtl_csla_block_4b blk (
          .a    (a[i*4 +: 4]),
          .b    (b[i*4 +: 4]),
          .cin  (c[i]),
          .sum  (sum[i*4 +: 4]),
          .cout (c[i+1])
      );
    end
  endgenerate
endmodule


// =============================================================================
// vrtl_carry_select_adder_sqrt_16b u_vrtl_carry_select_adder_sqrt_16b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_carry_select_adder_sqrt_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  // Group partitions: 2, 2, 3, 4, 5 = 16 bits
  logic c1, c2, c3, c4;

  // Block 0: 2-bit ripple
  assign {c1, sum[1:0]} = a[1:0] + b[1:0] + cin;

  // Block 1: 2-bit carry select
  logic [2:0] s1_0, s1_1;
  assign s1_0 = a[3:2] + b[3:2] + 1'b0;
  assign s1_1 = a[3:2] + b[3:2] + 1'b1;
  assign sum[3:2] = c1 ? s1_1[1:0] : s1_0[1:0];
  assign c2       = c1 ? s1_1[2]   : s1_0[2];

  // Block 2: 3-bit carry select
  logic [3:0] s2_0, s2_1;
  assign s2_0 = a[6:4] + b[6:4] + 1'b0;
  assign s2_1 = a[6:4] + b[6:4] + 1'b1;
  assign sum[6:4] = c2 ? s2_1[2:0] : s2_0[2:0];
  assign c3       = c2 ? s2_1[3]   : s2_0[3];

  // Block 3: 4-bit carry select
  logic [4:0] s3_0, s3_1;
  assign s3_0 = a[10:7] + b[10:7] + 1'b0;
  assign s3_1 = a[10:7] + b[10:7] + 1'b1;
  assign sum[10:7] = c3 ? s3_1[3:0] : s3_0[3:0];
  assign c4        = c3 ? s3_1[4]   : s3_0[4];

  // Block 4: 5-bit carry select
  logic [5:0] s4_0, s4_1;
  assign s4_0 = a[15:11] + b[15:11] + 1'b0;
  assign s4_1 = a[15:11] + b[15:11] + 1'b1;
  assign sum[15:11] = c4 ? s4_1[4:0] : s4_0[4:0];
  assign cout       = c4 ? s4_1[5]   : s4_0[5];
endmodule

`endif // ARITHMETIC_ADDERS_VRTL_ADDER_CARRY_SELECT_SV
