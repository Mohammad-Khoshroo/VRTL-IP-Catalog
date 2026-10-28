`ifndef ARITHMETIC_ADDERS_VRTL_ADDER_RIPPLE_SV
`define ARITHMETIC_ADDERS_VRTL_ADDER_RIPPLE_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_half_adder u_vrtl_half_adder (
//     .a    (a),
//     .b    (b),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_half_adder (
    input  logic a,
    input  logic b,
    output logic sum,
    output logic cout
);
  assign sum  = a ^ b;
  assign cout = a & b;
endmodule


// =============================================================================
// vrtl_full_adder u_vrtl_full_adder (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
  assign sum  = a ^ b ^ cin;
  assign cout = (a & b) | (cin & (a ^ b));
endmodule


// =============================================================================
// vrtl_adder_4b u_vrtl_adder_4b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_adder_4b (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);
  wire [4:0] c;
  assign c[0] = cin;
  assign cout = c[4];

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : gen_fa
      vrtl_full_adder fa (
          .a    (a[i]),
          .b    (b[i]),
          .cin  (c[i]),
          .sum  (sum[i]),
          .cout (c[i+1])
      );
    end
  endgenerate
endmodule


// =============================================================================
// vrtl_adder_8b u_vrtl_adder_8b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_adder_8b (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       cin,
    output logic [7:0] sum,
    output logic       cout
);
  assign {cout, sum} = a + b + cin;
endmodule


// =============================================================================
// vrtl_adder_16b u_vrtl_adder_16b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_adder_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  assign {cout, sum} = a + b + cin;
endmodule


// =============================================================================
// vrtl_adder_32b u_vrtl_adder_32b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_adder_32b (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        cin,
    output logic [31:0] sum,
    output logic        cout
);
  assign {cout, sum} = a + b + cin;
endmodule


// =============================================================================
// vrtl_subtractor_4b u_vrtl_subtractor_4b (
//     .a    (a),
//     .b    (b),
//     .bin  (bin),
//     .diff (diff),
//     .bout (bout)
// );
// =============================================================================
module vrtl_subtractor_4b (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       bin,
    output logic [3:0] diff,
    output logic       bout
);
  assign {bout, diff} = a - b - bin;
endmodule


// =============================================================================
// vrtl_subtractor_8b u_vrtl_subtractor_8b (
//     .a    (a),
//     .b    (b),
//     .bin  (bin),
//     .diff (diff),
//     .bout (bout)
// );
// =============================================================================
module vrtl_subtractor_8b (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       bin,
    output logic [7:0] diff,
    output logic       bout
);
  assign {bout, diff} = a - b - bin;
endmodule


// =============================================================================
// vrtl_subtractor_16b u_vrtl_subtractor_16b (
//     .a    (a),
//     .b    (b),
//     .bin  (bin),
//     .diff (diff),
//     .bout (bout)
// );
// =============================================================================
module vrtl_subtractor_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        bin,
    output logic [15:0] diff,
    output logic        bout
);
  assign {bout, diff} = a - b - bin;
endmodule


// =============================================================================
// vrtl_adder #(
//     .WIDTH (16)
// ) u_vrtl_adder (
//     .a        (a),
//     .b        (b),
//     .cin      (cin),
//     .sum      (sum),
//     .cout     (cout),
//     .overflow (overflow)
// );
// =============================================================================
module vrtl_adder #(
    parameter int WIDTH = 16
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             cin,
    output logic [WIDTH-1:0] sum,
    output logic             cout,
    output logic             overflow
);
  assign {cout, sum} = a + b + cin;
  assign overflow    = (a[WIDTH-1] == b[WIDTH-1]) && (sum[WIDTH-1] != a[WIDTH-1]);
endmodule


// =============================================================================
// vrtl_subtractor #(
//     .WIDTH (16)
// ) u_vrtl_subtractor (
//     .a    (a),
//     .b    (b),
//     .bin  (bin),
//     .diff (diff),
//     .bout (bout)
// );
// =============================================================================
module vrtl_subtractor #(
    parameter int WIDTH = 16
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             bin,
    output logic [WIDTH-1:0] diff,
    output logic             bout
);
  assign {bout, diff} = a - b - bin;
endmodule


// =============================================================================
// vrtl_adder_subtractor #(
//     .WIDTH (16)
// ) u_vrtl_adder_subtractor (
//     .sub       (sub),
//     .a         (a),
//     .b         (b),
//     .result    (result),
//     .carry_out (carry_out),
//     .overflow  (overflow)
// );
// =============================================================================
module vrtl_adder_subtractor #(
    parameter int WIDTH = 16
)(
    input  logic             sub,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] result,
    output logic             carry_out,
    output logic             overflow
);
  logic [WIDTH-1:0] b_inv;
  assign b_inv = sub ? ~b : b;
  assign {carry_out, result} = a + b_inv + sub;
  assign overflow = (a[WIDTH-1] == b_inv[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);
endmodule

`endif // ARITHMETIC_ADDERS_VRTL_ADDER_RIPPLE_SV
