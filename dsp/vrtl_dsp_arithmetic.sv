`ifndef DSP_VRTL_DSP_ARITHMETIC_SV
`define DSP_VRTL_DSP_ARITHMETIC_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_saturating_adder #(
//     .WIDTH  (16),
//     .SIGNED (1)
// ) u_vrtl_saturating_adder (
//     .a      (a),
//     .b      (b),
//     .result (result),
//     .sat_hi (sat_hi),
//     .sat_lo (sat_lo)
// );
// =============================================================================
module vrtl_saturating_adder #(
    parameter int WIDTH  = 16,
    parameter bit SIGNED = 1
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] result,
    output logic             sat_hi,
    output logic             sat_lo
);
  localparam logic [WIDTH-1:0] MAX_POS = {1'b0, {(WIDTH-1){1'b1}}};
  localparam logic [WIDTH-1:0] MAX_NEG = {1'b1, {(WIDTH-1){1'b0}}};

  logic [WIDTH:0] ext_sum;
  assign ext_sum = {1'b0, a} + {1'b0, b};

  always_comb begin
    sat_hi = 1'b0;
    sat_lo = 1'b0;
    result = ext_sum[WIDTH-1:0];

    if (SIGNED) begin
      if (~a[WIDTH-1] & ~b[WIDTH-1] & ext_sum[WIDTH-1]) begin
        result = MAX_POS;
        sat_hi = 1'b1;
      end else if (a[WIDTH-1] & b[WIDTH-1] & ~ext_sum[WIDTH-1]) begin
        result = MAX_NEG;
        sat_lo = 1'b1;
      end
    end else begin
      if (ext_sum[WIDTH]) begin
        result = '1;
        sat_hi = 1'b1;
      end
    end
  end
endmodule


// =============================================================================
// vrtl_saturating_subtractor #(
//     .WIDTH  (16),
//     .SIGNED (1)
// ) u_vrtl_saturating_subtractor (
//     .a      (a),
//     .b      (b),
//     .result (result),
//     .sat_hi (sat_hi),
//     .sat_lo (sat_lo)
// );
// =============================================================================
module vrtl_saturating_subtractor #(
    parameter int WIDTH  = 16,
    parameter bit SIGNED = 1
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] result,
    output logic             sat_hi,
    output logic             sat_lo
);
  localparam logic [WIDTH-1:0] MAX_POS = {1'b0, {(WIDTH-1){1'b1}}};
  localparam logic [WIDTH-1:0] MAX_NEG = {1'b1, {(WIDTH-1){1'b0}}};

  logic [WIDTH:0] ext_diff;
  assign ext_diff = {1'b0, a} - {1'b0, b};

  always_comb begin
    sat_hi = 1'b0;
    sat_lo = 1'b0;
    result = ext_diff[WIDTH-1:0];

    if (SIGNED) begin
      if (~a[WIDTH-1] & b[WIDTH-1] & ext_diff[WIDTH-1]) begin
        result = MAX_POS;
        sat_hi = 1'b1;
      end else if (a[WIDTH-1] & ~b[WIDTH-1] & ~ext_diff[WIDTH-1]) begin
        result = MAX_NEG;
        sat_lo = 1'b1;
      end
    end else begin
      if (ext_diff[WIDTH]) begin
        result = '0;
        sat_lo = 1'b1;
      end
    end
  end
endmodule


// =============================================================================
// vrtl_dsp_abs #(
//     .WIDTH (16)
// ) u_vrtl_dsp_abs (
//     .in      (in),
//     .abs_out (abs_out)
// );
// =============================================================================
module vrtl_dsp_abs #(
    parameter int WIDTH = 16
)(
    input  logic signed [WIDTH-1:0] in,
    output logic [WIDTH-1:0]        abs_out
);
  localparam logic signed [WIDTH-1:0] MOST_NEG = {1'b1, {(WIDTH-1){1'b0}}};
  localparam logic [WIDTH-1:0]        MAX_POS  = {1'b0, {(WIDTH-1){1'b1}}};

  always_comb begin
    if (in == MOST_NEG) begin
      abs_out = MAX_POS;
    end else if (in < 0) begin
      abs_out = -in;
    end else begin
      abs_out = in;
    end
  end
endmodule

`endif // DSP_VRTL_DSP_ARITHMETIC_SV
