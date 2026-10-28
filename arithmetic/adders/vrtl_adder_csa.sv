`ifndef ARITHMETIC_ADDERS_VRTL_ADDER_CSA_SV
`define ARITHMETIC_ADDERS_VRTL_ADDER_CSA_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_csa_3to2 u_vrtl_csa_3to2 (
//     .a     (a),
//     .b     (b),
//     .c     (c),
//     .sum   (sum),
//     .carry (carry)
// );
// =============================================================================
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


// =============================================================================
// vrtl_csa_4to2 u_vrtl_csa_4to2 (
//     .x0    (x0),
//     .x1    (x1),
//     .x2    (x2),
//     .x3    (x3),
//     .cin   (cin),
//     .sum   (sum),
//     .carry (carry),
//     .cout  (cout)
// );
// =============================================================================
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


// =============================================================================
// vrtl_csa_5to2 u_vrtl_csa_5to2 (
//     .x0    (x0),
//     .x1    (x1),
//     .x2    (x2),
//     .x3    (x3),
//     .x4    (x4),
//     .cin0  (cin0),
//     .cin1  (cin1),
//     .sum   (sum),
//     .carry (carry),
//     .cout0 (cout0),
//     .cout1 (cout1)
// );
// =============================================================================
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


// =============================================================================
// vrtl_csa_8b u_vrtl_csa_8b (
//     .a     (a),
//     .b     (b),
//     .c     (c),
//     .sum   (sum),
//     .carry (carry)
// );
// =============================================================================
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


// =============================================================================
// vrtl_csa_16b u_vrtl_csa_16b (
//     .a     (a),
//     .b     (b),
//     .c     (c),
//     .sum   (sum),
//     .carry (carry)
// );
// =============================================================================
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


// =============================================================================
// vrtl_csa #(
//     .WIDTH (32)
// ) u_vrtl_csa (
//     .a     (a),
//     .b     (b),
//     .c     (c),
//     .sum   (sum),
//     .carry (carry)
// );
// =============================================================================
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

`endif // ARITHMETIC_ADDERS_VRTL_ADDER_CSA_SV
