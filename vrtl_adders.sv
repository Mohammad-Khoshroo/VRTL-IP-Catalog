`ifndef VRTL_ADDERS_SV
`define VRTL_ADDERS_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Carry-Save Adders (CSA) & Compressors
// =============================================================================

/*
// Instance Example:
vrtl_csa_3to2 u_vrtl_csa_3to2 (
    .a     (a),
    .b     (b),
    .c     (c),
    .sum   (sum),
    .carry (carry)
);
*/
module vrtl_csa_3to2 (
    input  logic a,
    input  logic b,
    input  logic c,
    output logic sum,
    output logic carry
);
  assign sum   = a ^ b ^ c;
  assign carry = (a & b) | (b & c) | (a & c);
endmodule


/*
// Instance Example:
vrtl_csa_4to2 u_vrtl_csa_4to2 (
    .x0    (x0),
    .x1    (x1),
    .x2    (x2),
    .x3    (x3),
    .cin   (cin),
    .sum   (sum),
    .carry (carry),
    .cout  (cout)
);
*/
module vrtl_csa_4to2 (
    input  logic x0,
    input  logic x1,
    input  logic x2,
    input  logic x3,
    input  logic cin,
    output logic sum,
    output logic carry,
    output logic cout
);
  logic s_int;

  assign s_int = x0 ^ x1 ^ x2;
  assign cout  = (x0 & x1) | (x1 & x2) | (x0 & x2);
  assign sum   = s_int ^ x3 ^ cin;
  assign carry = (s_int & x3) | (x3 & cin) | (s_int & cin);
endmodule


/*
// Instance Example:
vrtl_csa_5to2 u_vrtl_csa_5to2 (
    .x0    (x0),
    .x1    (x1),
    .x2    (x2),
    .x3    (x3),
    .x4    (x4),
    .cin0  (cin0),
    .cin1  (cin1),
    .sum   (sum),
    .carry (carry),
    .cout0 (cout0),
    .cout1 (cout1)
);
*/
module vrtl_csa_5to2 (
    input  logic x0,
    input  logic x1,
    input  logic x2,
    input  logic x3,
    input  logic x4,
    input  logic cin0,
    input  logic cin1,
    output logic sum,
    output logic carry,
    output logic cout0,
    output logic cout1
);
  logic s1, c1, s2, c2;

  // Level 1: FA on x0, x1, x2
  assign s1    = x0 ^ x1 ^ x2;
  assign cout0 = (x0 & x1) | (x1 & x2) | (x0 & x2);

  // Level 2: FA on s1, x3, x4
  assign s2    = s1 ^ x3 ^ x4;
  assign cout1 = (s1 & x3) | (x3 & x4) | (s1 & x4);

  // Level 3: FA on s2, cin0, cin1
  assign sum   = s2 ^ cin0 ^ cin1;
  assign carry = (s2 & cin0) | (cin0 & cin1) | (s2 & cin1);
endmodule


/*
// Instance Example:
vrtl_csa_8b u_vrtl_csa_8b (
    .a     (a),
    .b     (b),
    .c     (c),
    .sum   (sum),
    .carry (carry)
);
*/
module vrtl_csa_8b (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [7:0] c,
    output logic [7:0] sum,
    output logic [7:0] carry
);
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : gen_csa
      assign sum[i]   = a[i] ^ b[i] ^ c[i];
      assign carry[i] = (a[i] & b[i]) | (b[i] & c[i]) | (a[i] & c[i]);
    end
  endgenerate
endmodule


/*
// Instance Example:
vrtl_csa_16b u_vrtl_csa_16b (
    .a     (a),
    .b     (b),
    .c     (c),
    .sum   (sum),
    .carry (carry)
);
*/
module vrtl_csa_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic [15:0] c,
    output logic [15:0] sum,
    output logic [15:0] carry
);
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_csa
      assign sum[i]   = a[i] ^ b[i] ^ c[i];
      assign carry[i] = (a[i] & b[i]) | (b[i] & c[i]) | (a[i] & c[i]);
    end
  endgenerate
endmodule


/*
// Instance Example:
vrtl_csa #(
    .WIDTH(32)
) u_vrtl_csa (
    .a     (a),
    .b     (b),
    .c     (c),
    .sum   (sum),
    .carry (carry)
);
*/
module vrtl_csa #(
    parameter int WIDTH = 32
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [WIDTH-1:0] c,
    output logic [WIDTH-1:0] sum,
    output logic [WIDTH-1:0] carry
);
  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : gen_csa
      assign sum[i]   = a[i] ^ b[i] ^ c[i];
      assign carry[i] = (a[i] & b[i]) | (b[i] & c[i]) | (a[i] & c[i]);
    end
  endgenerate
endmodule


// =============================================================================
// Bit-Serial Adder (Minimal Area Sequential Model)
// =============================================================================

/*
// Instance Example:
vrtl_serial_adder u_vrtl_serial_adder (
    .clk    (clk),
    .rst_n  (rst_n),
    .start  (start),
    .a_bit  (a_bit),
    .b_bit  (b_bit),
    .sum_bit(sum_bit)
);
*/
module vrtl_serial_adder (
    input  logic clk,
    input  logic rst_n,
    input  logic start,   // Clears carry flop at word boundary
    input  logic a_bit,
    input  logic b_bit,
    output logic sum_bit
);
  logic carry_q;
  wire next_carry = (a_bit & b_bit) | (carry_q & (a_bit ^ b_bit));

  assign sum_bit = a_bit ^ b_bit ^ carry_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      carry_q <= 1'b0;
    end else if (start) begin
      carry_q <= (a_bit & b_bit);
    end else begin
      carry_q <= next_carry;
    end
  end
endmodule


// =============================================================================
// Carry-Skip (Carry-Bypass) Adders
// =============================================================================

/*
// Instance Example:
vrtl_cba_block_4b u_vrtl_cba_block_4b (
    .a         (a),
    .b         (b),
    .cin       (cin),
    .sum       (sum),
    .cout      (cout),
    .propagate (propagate)
);
*/
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


/*
// Instance Example:
vrtl_carry_skip_adder_16b u_vrtl_carry_skip_adder_16b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


/*
// Instance Example:
vrtl_carry_skip_adder_32b u_vrtl_carry_skip_adder_32b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


// =============================================================================
// Carry-Select Adders (CSLA - Linear & Square-Root)
// =============================================================================

/*
// Instance Example:
vrtl_csla_block_4b u_vrtl_csla_block_4b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


/*
// Instance Example:
vrtl_carry_select_adder_16b u_vrtl_carry_select_adder_16b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


/*
// Instance Example:
vrtl_carry_select_adder_32b u_vrtl_carry_select_adder_32b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


/*
// Instance Example:
vrtl_carry_select_adder_sqrt_16b u_vrtl_carry_select_adder_sqrt_16b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


// =============================================================================
// Parallel Prefix Adders (Kogge-Stone, Brent-Kung, Sklansky, Han-Carlson)
// =============================================================================

/*
// Instance Example:
vrtl_kogge_stone_adder_8b u_vrtl_kogge_stone_adder_8b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


/*
// Instance Example:
vrtl_kogge_stone_adder_16b u_vrtl_kogge_stone_adder_16b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


/*
// Instance Example:
vrtl_brent_kung_adder_8b u_vrtl_brent_kung_adder_8b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


/*
// Instance Example:
vrtl_brent_kung_adder_16b u_vrtl_brent_kung_adder_16b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


/*
// Instance Example:
vrtl_sklansky_adder_8b u_vrtl_sklansky_adder_8b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


/*
// Instance Example:
vrtl_han_carlson_adder_16b u_vrtl_han_carlson_adder_16b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
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


// =============================================================================
// BCD Decimal Adders
// =============================================================================

/*
// Instance Example:
vrtl_bcd_adder_1digit u_vrtl_bcd_adder_1digit (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
module vrtl_bcd_adder_1digit (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);
  logic [4:0] binary_sum;

  always_comb begin
    binary_sum = a + b + cin;
    if (binary_sum > 5'd9) begin
      sum  = binary_sum[3:0] + 4'd6;
      cout = 1'b1;
    end else begin
      sum  = binary_sum[3:0];
      cout = 1'b0;
    end
  end
endmodule


/*
// Instance Example:
vrtl_bcd_adder_4digit u_vrtl_bcd_adder_4digit (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
module vrtl_bcd_adder_4digit (
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
    for (i = 0; i < 4; i = i + 1) begin : gen_bcd
      vrtl_bcd_adder_1digit bcd_digit (
          .a    (a[i*4 +: 4]),
          .b    (b[i*4 +: 4]),
          .cin  (c[i]),
          .sum  (sum[i*4 +: 4]),
          .cout (c[i+1])
      );
    end
  endgenerate
endmodule

`endif // VRTL_ADDERS_SV
