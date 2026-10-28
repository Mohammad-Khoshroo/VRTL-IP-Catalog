`ifndef VRTL_COMPARATOR_SV
`define VRTL_COMPARATOR_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Non-Parametric Comparators & 74xx85 Cascading Comparator
// =============================================================================

/*
// Instance Example:
vrtl_comparator_1b u_vrtl_comparator_1b (
    .a  (a),
    .b  (b),
    .eq (eq)
);
*/
module vrtl_comparator_1b (
    input  logic a,
    input  logic b,
    output logic eq
);
  assign eq = (a ~^ b);
endmodule


/*
// Instance Example:
vrtl_comparator_4b u_vrtl_comparator_4b (
    .a  (a),
    .b  (b),
    .eq (eq),
    .gt (gt),
    .lt (lt)
);
*/
module vrtl_comparator_4b (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic       eq,
    output logic       gt,
    output logic       lt
);
  assign eq = (a == b);
  assign gt = (a > b);
  assign lt = (a < b);
endmodule


/*
// Instance Example:
vrtl_comparator_8b u_vrtl_comparator_8b (
    .a  (a),
    .b  (b),
    .eq (eq),
    .gt (gt),
    .lt (lt)
);
*/
module vrtl_comparator_8b (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic       eq,
    output logic       gt,
    output logic       lt
);
  assign eq = (a == b);
  assign gt = (a > b);
  assign lt = (a < b);
endmodule


/*
// Instance Example:
vrtl_comparator_16b u_vrtl_comparator_16b (
    .a  (a),
    .b  (b),
    .eq (eq),
    .gt (gt),
    .lt (lt)
);
*/
module vrtl_comparator_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    output logic        eq,
    output logic        gt,
    output logic        lt
);
  assign eq = (a == b);
  assign gt = (a > b);
  assign lt = (a < b);
endmodule


/*
// Instance Example:
vrtl_comparator_32b u_vrtl_comparator_32b (
    .a  (a),
    .b  (b),
    .eq (eq),
    .gt (gt),
    .lt (lt)
);
*/
module vrtl_comparator_32b (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic        eq,
    output logic        gt,
    output logic        lt
);
  assign eq = (a == b);
  assign gt = (a > b);
  assign lt = (a < b);
endmodule


/*
// Instance Example:
vrtl_comparator_4b_74xx85 u_vrtl_comparator_4b_74xx85 (
    .a     (a),
    .b     (b),
    .gt_in (gt_in),
    .lt_in (lt_in),
    .eq_in (eq_in),
    .gt_out(gt_out),
    .lt_out(lt_out),
    .eq_out(eq_out)
);
*/
module vrtl_comparator_4b_74xx85 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       gt_in,
    input  logic       lt_in,
    input  logic       eq_in,
    output logic       gt_out,
    output logic       lt_out,
    output logic       eq_out
);
  always_comb begin
    if (a > b) begin
      gt_out = 1'b1;
      lt_out = 1'b0;
      eq_out = 1'b0;
    end else if (a < b) begin
      gt_out = 1'b0;
      lt_out = 1'b1;
      eq_out = 1'b0;
    end else begin
      // Cascade from lower stages when local digits are equal
      gt_out = gt_in;
      lt_out = lt_in;
      eq_out = eq_in;
    end
  end
endmodule


// =============================================================================
// Parametric Comparators, Min/Max & Window Comparators
// =============================================================================

/*
// Instance Example:
vrtl_comparator #(
    .WIDTH(16),
    .SIGNED(0)
) u_vrtl_comparator (
    .a  (a),
    .b  (b),
    .eq (eq),
    .gt (gt),
    .lt (lt)
);
*/
module vrtl_comparator #(
    parameter int WIDTH  = 16,
    parameter bit SIGNED = 0
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic             eq,
    output logic             gt,
    output logic             lt
);
  always_comb begin
    if (SIGNED) begin
      eq = ($signed(a) == $signed(b));
      gt = ($signed(a) >  $signed(b));
      lt = ($signed(a) <  $signed(b));
    end else begin
      eq = (a == b);
      gt = (a > b);
      lt = (a < b);
    end
  end
endmodule


/*
// Instance Example:
vrtl_min_max_selector #(
    .WIDTH(16),
    .SIGNED(0)
) u_vrtl_min_max_selector (
    .a       (a),
    .b       (b),
    .min_val (min_val),
    .max_val (max_val)
);
*/
module vrtl_min_max_selector #(
    parameter int WIDTH  = 16,
    parameter bit SIGNED = 0
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] min_val,
    output logic [WIDTH-1:0] max_val
);
  wire a_gt_b = SIGNED ? ($signed(a) > $signed(b)) : (a > b);

  assign max_val = a_gt_b ? a : b;
  assign min_val = a_gt_b ? b : a;
endmodule


/*
// Instance Example:
vrtl_window_comparator #(
    .WIDTH(16),
    .SIGNED(0)
) u_vrtl_window_comparator (
    .x       (x),
    .val_lo  (val_lo),
    .val_hi  (val_hi),
    .in_range(in_range),
    .below_lo(below_lo),
    .above_hi(above_hi)
);
*/
module vrtl_window_comparator #(
    parameter int WIDTH  = 16,
    parameter bit SIGNED = 0
)(
    input  logic [WIDTH-1:0] x,
    input  logic [WIDTH-1:0] val_lo,
    input  logic [WIDTH-1:0] val_hi,
    output logic             in_range,
    output logic             below_lo,
    output logic             above_hi
);
  wire lt_lo = SIGNED ? ($signed(x) < $signed(val_lo)) : (x < val_lo);
  wire gt_hi = SIGNED ? ($signed(x) > $signed(val_hi)) : (x > val_hi);

  assign below_lo = lt_lo;
  assign above_hi = gt_hi;
  assign in_range = !lt_lo && !gt_hi;
endmodule


// =============================================================================
// Parity Generators
// =============================================================================

/*
// Instance Example:
vrtl_parity_gen_8b u_vrtl_parity_gen_8b (
    .data_in     (data_in),
    .even_parity (even_parity),
    .odd_parity  (odd_parity)
);
*/
module vrtl_parity_gen_8b (
    input  logic [7:0] data_in,
    output logic       even_parity,
    output logic       odd_parity
);
  assign even_parity = ^data_in;
  assign odd_parity  = ~even_parity;
endmodule


/*
// Instance Example:
vrtl_parity_gen #(
    .WIDTH(16)
) u_vrtl_parity_gen (
    .data_in     (data_in),
    .even_parity (even_parity),
    .odd_parity  (odd_parity)
);
*/
module vrtl_parity_gen #(
    parameter int WIDTH = 16
)(
    input  logic [WIDTH-1:0] data_in,
    output logic             even_parity,
    output logic             odd_parity
);
  assign even_parity = ^data_in;
  assign odd_parity  = ~even_parity;
endmodule

`endif // VRTL_COMPARATOR_SV
