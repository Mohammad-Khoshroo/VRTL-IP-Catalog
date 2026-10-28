`ifndef CDC_VRTL_EDGE_DETECT_SV
`define CDC_VRTL_EDGE_DETECT_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_edge_detect u_vrtl_edge_detect (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .sig_in   (sig_in),
//     .pos_edge (pos_edge),
//     .neg_edge (neg_edge),
//     .any_edge (any_edge)
// );
// =============================================================================
module vrtl_edge_detect (
    input  logic clk,
    input  logic rst_n,
    input  logic sig_in,
    output logic pos_edge,
    output logic neg_edge,
    output logic any_edge
);
  logic sig_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sig_d <= 1'b0;
    end else begin
      sig_d <= sig_in;
    end
  end

  assign pos_edge = sig_in & ~sig_d;
  assign neg_edge = ~sig_in & sig_d;
  assign any_edge = sig_in ^ sig_d;
endmodule


// =============================================================================
// vrtl_edge_detect_n #(
//     .WIDTH (8)
// ) u_vrtl_edge_detect_n (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .sig_in   (sig_in),
//     .pos_edge (pos_edge),
//     .neg_edge (neg_edge),
//     .any_edge (any_edge)
// );
// =============================================================================
module vrtl_edge_detect_n #(
    parameter int WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] sig_in,
    output logic [WIDTH-1:0] pos_edge,
    output logic [WIDTH-1:0] neg_edge,
    output logic [WIDTH-1:0] any_edge
);
  logic [WIDTH-1:0] sig_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sig_d <= '0;
    end else begin
      sig_d <= sig_in;
    end
  end

  assign pos_edge = sig_in & ~sig_d;
  assign neg_edge = ~sig_in & sig_d;
  assign any_edge = sig_in ^ sig_d;
endmodule

`endif // CDC_VRTL_EDGE_DETECT_SV
