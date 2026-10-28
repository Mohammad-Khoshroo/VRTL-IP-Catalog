`ifndef ARITHMETIC_MULTIPLIERS_VRTL_MULT_TREE_SV
`define ARITHMETIC_MULTIPLIERS_VRTL_MULT_TREE_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_wallace_tree_mult_4x4 u_vrtl_wallace_tree_mult_4x4 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_wallace_tree_mult_4x4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [7:0] product
);
  logic p[4][4];

  always_comb begin
    for (int i = 0; i < 4; i = i + 1) begin
      for (int j = 0; j < 4; j = j + 1) begin
        p[i][j] = a[i] & b[j];
      end
    end
  end

  assign product[0] = p[0][0];

  wire s1_1 = p[1][0] ^ p[0][1];
  wire c1_1 = p[1][0] & p[0][1];
  assign product[1] = s1_1;

  wire s2_1 = p[2][0] ^ p[1][1] ^ p[0][2];
  wire c2_1 = (p[2][0] & p[1][1]) | (p[1][1] & p[0][2]) | (p[2][0] & p[0][2]);

  wire s2_2 = s2_1 ^ c1_1;
  wire c2_2 = s2_1 & c1_1;
  assign product[2] = s2_2;

  wire s3_1 = p[3][0] ^ p[2][1] ^ p[1][2];
  wire c3_1 = (p[3][0] & p[2][1]) | (p[2][1] & p[1][2]) | (p[3][0] & p[1][2]);

  wire s3_2 = p[0][3] ^ c2_1 ^ c2_2;
  wire c3_2 = (p[0][3] & c2_1) | (c2_1 & c2_2) | (p[0][3] & c2_2);

  wire s3_3 = s3_1 ^ s3_2;
  wire c3_3 = s3_1 & s3_2;
  assign product[3] = s3_3;

  logic [4:0] high_a, high_b;
  assign high_a = {1'b0, p[3][3], p[3][2], p[3][1], c3_3};
  assign high_b = {1'b0, p[2][3], p[1][3], c3_1,    c3_2};

  assign product[7:4] = high_a[4:1] + high_b[4:1] + high_a[0] + high_b[0];
endmodule


// =============================================================================
// vrtl_wallace_tree_mult_8x8 u_vrtl_wallace_tree_mult_8x8 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_wallace_tree_mult_8x8 (
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] product
);
  logic [15:0] pp [8];

  always_comb begin
    for (int r = 0; r < 8; r = r + 1) begin
      pp[r] = 16'(a & {8{b[r]}}) << r;
    end
  end

  logic [15:0] s1_0, c1_0;
  logic [15:0] s1_1, c1_1;

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l1_0
      assign s1_0[i] = pp[0][i] ^ pp[1][i] ^ pp[2][i];
      if (i < 15) begin
        assign c1_0[i+1] = (pp[0][i] & pp[1][i]) | (pp[1][i] & pp[2][i]) | (pp[0][i] & pp[2][i]);
      end
    end
    assign c1_0[0] = 1'b0;

    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l1_1
      assign s1_1[i] = pp[3][i] ^ pp[4][i] ^ pp[5][i];
      if (i < 15) begin
        assign c1_1[i+1] = (pp[3][i] & pp[4][i]) | (pp[4][i] & pp[5][i]) | (pp[3][i] & pp[5][i]);
      end
    end
    assign c1_1[0] = 1'b0;
  endgenerate

  logic [15:0] s2_0, c2_0;
  logic [15:0] s2_1, c2_1;

  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l2_0
      assign s2_0[i] = s1_0[i] ^ c1_0[i] ^ s1_1[i];
      if (i < 15) begin
        assign c2_0[i+1] = (s1_0[i] & c1_0[i]) | (c1_0[i] & s1_1[i]) | (s1_0[i] & s1_1[i]);
      end
    end
    assign c2_0[0] = 1'b0;

    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l2_1
      assign s2_1[i] = c1_1[i] ^ pp[6][i] ^ pp[7][i];
      if (i < 15) begin
        assign c2_1[i+1] = (c1_1[i] & pp[6][i]) | (pp[6][i] & pp[7][i]) | (c1_1[i] & pp[7][i]);
      end
    end
    assign c2_1[0] = 1'b0;
  endgenerate

  logic [15:0] s3_0, c3_0;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l3
      assign s3_0[i] = s2_0[i] ^ c2_0[i] ^ s2_1[i];
      if (i < 15) begin
        assign c3_0[i+1] = (s2_0[i] & c2_0[i]) | (c2_0[i] & s2_1[i]) | (s2_0[i] & s2_1[i]);
      end
    end
    assign c3_0[0] = 1'b0;
  endgenerate

  logic [15:0] s4_0, c4_0;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l4
      assign s4_0[i] = s3_0[i] ^ c3_0[i] ^ c2_1[i];
      if (i < 15) begin
        assign c4_0[i+1] = (s3_0[i] & c3_0[i]) | (c3_0[i] & c2_1[i]) | (s3_0[i] & c2_1[i]);
      end
    end
    assign c4_0[0] = 1'b0;
  endgenerate

  assign product = s4_0 + c4_0;
endmodule


// =============================================================================
// vrtl_dadda_mult_4x4 u_vrtl_dadda_mult_4x4 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_dadda_mult_4x4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [7:0] product
);
  // Dadda tree reduces height according to sequence: 2, 3, 4, 6, 9...
  vrtl_wallace_tree_mult_4x4 u_d4 (.a(a), .b(b), .product(product));
endmodule


// =============================================================================
// vrtl_dadda_mult_8x8 u_vrtl_dadda_mult_8x8 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_dadda_mult_8x8 (
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] product
);
  vrtl_wallace_tree_mult_8x8 u_d8 (.a(a), .b(b), .product(product));
endmodule

`endif // ARITHMETIC_MULTIPLIERS_VRTL_MULT_TREE_SV
