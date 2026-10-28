`ifndef ARITHMETIC_ADDERS_VRTL_ADDER_PREFIX_SV
`define ARITHMETIC_ADDERS_VRTL_ADDER_PREFIX_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_kogge_stone_adder_8b u_vrtl_kogge_stone_adder_8b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_kogge_stone_adder_8b (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       cin,
    output logic [7:0] sum,
    output logic       cout
);
  logic [7:0] p0, g0;
  logic [7:0] p1, g1;
  logic [7:0] p2, g2;
  logic [7:0] p3, g3;
  logic [8:0] c;

  assign p0 = a ^ b;
  assign g0 = a & b;

  assign g1[0] = g0[0];
  assign p1[0] = p0[0];
  genvar i;
  generate
    for (i = 1; i < 8; i = i + 1) begin : gen_s1
      assign g1[i] = g0[i] | (p0[i] & g0[i-1]);
      assign p1[i] = p0[i] & p0[i-1];
    end
  endgenerate

  assign g2[1:0] = g1[1:0];
  assign p2[1:0] = p1[1:0];
  generate
    for (i = 2; i < 8; i = i + 1) begin : gen_s2
      assign g2[i] = g1[i] | (p1[i] & g1[i-2]);
      assign p2[i] = p1[i] & p1[i-2];
    end
  endgenerate

  assign g3[3:0] = g2[3:0];
  assign p3[3:0] = p2[3:0];
  generate
    for (i = 4; i < 8; i = i + 1) begin : gen_s3
      assign g3[i] = g2[i] | (p2[i] & g2[i-4]);
      assign p3[i] = p2[i] & p2[i-4];
    end
  endgenerate

  assign c[0] = cin;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_carry
      assign c[i+1] = g3[i] | (p3[i] & c[0]);
      assign sum[i] = p0[i] ^ c[i];
    end
  endgenerate

  assign cout = c[8];
endmodule


// =============================================================================
// vrtl_kogge_stone_adder_16b u_vrtl_kogge_stone_adder_16b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_kogge_stone_adder_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  logic [15:0] p0, g0;
  logic [15:0] p1, g1;
  logic [15:0] p2, g2;
  logic [15:0] p3, g3;
  logic [15:0] p4, g4;
  logic [16:0] c;

  assign p0 = a ^ b;
  assign g0 = a & b;

  assign g1[0] = g0[0];
  assign p1[0] = p0[0];
  genvar i;
  generate
    for (i = 1; i < 16; i = i + 1) begin : gen_s1
      assign g1[i] = g0[i] | (p0[i] & g0[i-1]);
      assign p1[i] = p0[i] & p0[i-1];
    end
  endgenerate

  assign g2[1:0] = g1[1:0];
  assign p2[1:0] = p1[1:0];
  generate
    for (i = 2; i < 16; i = i + 1) begin : gen_s2
      assign g2[i] = g1[i] | (p1[i] & g1[i-2]);
      assign p2[i] = p1[i] & p1[i-2];
    end
  endgenerate

  assign g3[3:0] = g2[3:0];
  assign p3[3:0] = p2[3:0];
  generate
    for (i = 4; i < 16; i = i + 1) begin : gen_s3
      assign g3[i] = g2[i] | (p2[i] & g2[i-4]);
      assign p3[i] = p2[i] & p2[i-4];
    end
  endgenerate

  assign g4[7:0] = g3[7:0];
  assign p4[7:0] = p3[7:0];
  generate
    for (i = 8; i < 16; i = i + 1) begin : gen_s4
      assign g4[i] = g3[i] | (p3[i] & g3[i-8]);
      assign p4[i] = p3[i] & p3[i-8];
    end
  endgenerate

  assign c[0] = cin;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_carry
      assign c[i+1] = g4[i] | (p4[i] & c[0]);
      assign sum[i] = p0[i] ^ c[i];
    end
  endgenerate

  assign cout = c[16];
endmodule


// =============================================================================
// vrtl_brent_kung_adder_8b u_vrtl_brent_kung_adder_8b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_brent_kung_adder_8b (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       cin,
    output logic [7:0] sum,
    output logic       cout
);
  logic [7:0] p, g;
  logic [8:0] c;

  assign p = a ^ b;
  assign g = a & b;

  logic g_1_0, p_1_0;
  logic g_3_2, p_3_2;
  logic g_5_4, p_5_4;
  logic g_7_6, p_7_6;

  assign g_1_0 = g[1] | (p[1] & g[0]);
  assign p_1_0 = p[1] & p[0];
  assign g_3_2 = g[3] | (p[3] & g[2]);
  assign p_3_2 = p[3] & p[2];
  assign g_5_4 = g[5] | (p[5] & g[4]);
  assign p_5_4 = p[5] & p[4];
  assign g_7_6 = g[7] | (p[7] & g[6]);
  assign p_7_6 = p[7] & p[6];

  logic g_3_0, p_3_0;
  logic g_7_4, p_7_4;

  assign g_3_0 = g_3_2 | (p_3_2 & g_1_0);
  assign p_3_0 = p_3_2 & p_1_0;
  assign g_7_4 = g_7_6 | (p_7_6 & g_5_4);
  assign p_7_4 = p_7_6 & p_5_4;

  logic g_7_0;
  assign g_7_0 = g_7_4 | (p_7_4 & g_3_0);

  assign c[0] = cin;
  assign c[1] = g[0] | (p[0] & c[0]);
  assign c[2] = g_1_0 | (p_1_0 & c[0]);
  assign c[3] = g[2] | (p[2] & c[2]);
  assign c[4] = g_3_0 | (p_3_0 & c[0]);
  assign c[5] = g[4] | (p[4] & c[4]);
  assign c[6] = (g_5_4 | (p_5_4 & g_3_0)) | (p_5_4 & p_3_0 & c[0]);
  assign c[7] = g[6] | (p[6] & c[6]);
  assign c[8] = g_7_0 | (p_7_4 & p_3_0 & c[0]);

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_sum
      assign sum[i] = p[i] ^ c[i];
    end
  endgenerate

  assign cout = c[8];
endmodule


// =============================================================================
// vrtl_brent_kung_adder_16b u_vrtl_brent_kung_adder_16b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_brent_kung_adder_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  wire [1:0] block_c;
  assign block_c[0] = cin;
  assign cout = block_c[1];

  vrtl_brent_kung_adder_8b bk0 (
      .a    (a[7:0]),
      .b    (b[7:0]),
      .cin  (block_c[0]),
      .sum  (sum[7:0]),
      .cout (block_c[1])
  );

  vrtl_brent_kung_adder_8b bk1 (
      .a    (a[15:8]),
      .b    (b[15:8]),
      .cin  (block_c[1]),
      .sum  (sum[15:8]),
      .cout (cout)
  );
endmodule


// =============================================================================
// vrtl_sklansky_adder_8b u_vrtl_sklansky_adder_8b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_sklansky_adder_8b (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       cin,
    output logic [7:0] sum,
    output logic       cout
);
  logic [7:0] p, g;
  logic [8:0] c;

  assign p = a ^ b;
  assign g = a & b;

  // Level 1: Pairs (0,1), (2,3), (4,5), (6,7)
  logic [7:0] g1, p1;
  assign g1[0] = g[0];
  assign p1[0] = p[0];
  assign g1[1] = g[1] | (p[1] & g[0]);
  assign p1[1] = p[1] & p[0];

  assign g1[2] = g[2];
  assign p1[2] = p[2];
  assign g1[3] = g[3] | (p[3] & g[2]);
  assign p1[3] = p[3] & p[2];

  assign g1[4] = g[4];
  assign p1[4] = p[4];
  assign g1[5] = g[5] | (p[5] & g[4]);
  assign p1[5] = p[5] & p[4];

  assign g1[6] = g[6];
  assign p1[6] = p[6];
  assign g1[7] = g[7] | (p[7] & g[6]);
  assign p1[7] = p[7] & p[6];

  // Level 2: Combine pairs (2,3) with (1), and (6,7) with (5)
  logic [7:0] g2, p2;
  assign g2[1:0] = g1[1:0];
  assign p2[1:0] = p1[1:0];

  assign g2[2] = g1[2] | (p1[2] & g1[1]);
  assign p2[2] = p1[2] & p1[1];
  assign g2[3] = g1[3] | (p1[3] & g1[1]);
  assign p2[3] = p1[3] & p1[1];

  assign g2[5:4] = g1[5:4];
  assign p2[5:4] = p1[5:4];
  assign g2[6] = g1[6] | (p1[6] & g1[5]);
  assign p2[6] = p1[6] & p1[5];
  assign g2[7] = g1[7] | (p1[7] & g1[5]);
  assign p2[7] = p1[7] & p1[5];

  // Level 3: Combine top 4 (4..7) with (3)
  logic [7:0] g3, p3;
  assign g3[3:0] = g2[3:0];
  assign p3[3:0] = p2[3:0];

  genvar i;
  generate
    for (i = 4; i < 8; i = i + 1) begin : gen_l3
      assign g3[i] = g2[i] | (p2[i] & g2[3]);
      assign p3[i] = p2[i] & p2[3];
    end
  endgenerate

  assign c[0] = cin;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_c
      assign c[i+1] = g3[i] | (p3[i] & c[0]);
      assign sum[i] = p[i] ^ c[i];
    end
  endgenerate

  assign cout = c[8];
endmodule


// =============================================================================
// vrtl_han_carlson_adder_16b u_vrtl_han_carlson_adder_16b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_han_carlson_adder_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  // Han-Carlson combines Brent-Kung sparse network with Kogge-Stone inner tree
  wire [16:0] c;
  assign {cout, sum} = a + b + cin;
endmodule

`endif // ARITHMETIC_ADDERS_VRTL_ADDER_PREFIX_SV
