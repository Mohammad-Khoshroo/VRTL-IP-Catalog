`ifndef DSP_VRTL_DSP_MAC_SV
`define DSP_VRTL_DSP_MAC_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_mac #(
//     .A_WIDTH   (16),
//     .B_WIDTH   (16),
//     .ACC_WIDTH (40)
// ) u_vrtl_mac (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .clr     (clr),
//     .en      (en),
//     .a       (a),
//     .b       (b),
//     .acc_out (acc_out)
// );
// =============================================================================
module vrtl_mac #(
    parameter int A_WIDTH   = 16,
    parameter int B_WIDTH   = 16,
    parameter int ACC_WIDTH = 40
)(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        clr,
    input  logic                        en,
    input  logic signed [A_WIDTH-1:0]   a,
    input  logic signed [B_WIDTH-1:0]   b,
    output logic signed [ACC_WIDTH-1:0] acc_out
);
  logic signed [A_WIDTH+B_WIDTH-1:0] prod;
  logic signed [ACC_WIDTH-1:0] acc;

  assign prod    = a * b;
  assign acc_out = acc;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= '0;
    end else if (clr) begin
      acc <= '0;
    end else if (en) begin
      acc <= acc + ACC_WIDTH'(prod);
    end
  end
endmodule


// =============================================================================
// vrtl_complex_mult #(
//     .WIDTH (16)
// ) u_vrtl_complex_mult (
//     .ar (ar),
//     .ai (ai),
//     .br (br),
//     .bi (bi),
//     .pr (pr),
//     .pi (pi)
// );
// =============================================================================
module vrtl_complex_mult #(
    parameter int WIDTH = 16
)(
    input  logic signed [WIDTH-1:0]   ar,
    input  logic signed [WIDTH-1:0]   ai,
    input  logic signed [WIDTH-1:0]   br,
    input  logic signed [WIDTH-1:0]   bi,
    output logic signed [2*WIDTH-1:0] pr,
    output logic signed [2*WIDTH-1:0] pi
);
  assign pr = (ar * br) - (ai * bi);
  assign pi = (ar * bi) + (ai * br);
endmodule

`endif // DSP_VRTL_DSP_MAC_SV
