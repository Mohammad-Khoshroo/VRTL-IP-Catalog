`ifndef CLOCK_VRTL_CLOCK_GATES_SV
`define CLOCK_VRTL_CLOCK_GATES_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_clock_gate u_vrtl_clock_gate (
//     .clk_in  (clk_in),
//     .en      (en),
//     .test_en (test_en),
//     .clk_out (clk_out)
// );
// =============================================================================
module vrtl_clock_gate (
    input  logic clk_in,
    input  logic en,
    input  logic test_en,
    output logic clk_out
);
  logic en_latched;

  always_latch begin
    if (!clk_in) begin
      en_latched <= en | test_en;
    end
  end

  assign clk_out = clk_in & en_latched;
endmodule


// =============================================================================
// vrtl_glitch_free_clock_mux u_vrtl_glitch_free_clock_mux (
//     .clk0    (clk0),
//     .rst0_n  (rst0_n),
//     .clk1    (clk1),
//     .rst1_n  (rst1_n),
//     .sel     (sel),
//     .clk_out (clk_out)
// );
// =============================================================================
module vrtl_glitch_free_clock_mux (
    input  logic clk0,
    input  logic rst0_n,
    input  logic clk1,
    input  logic rst1_n,
    input  logic sel,
    output logic clk_out
);
  logic q0_meta, q0;
  logic q1_meta, q1;

  always_ff @(posedge clk0 or negedge rst0_n) begin
    if (!rst0_n) begin
      q0_meta <= 1'b0;
      q0      <= 1'b0;
    end else begin
      q0_meta <= ~sel & ~q1;
      q0      <= q0_meta;
    end
  end

  always_ff @(posedge clk1 or negedge rst1_n) begin
    if (!rst1_n) begin
      q1_meta <= 1'b0;
      q1      <= 1'b0;
    end else begin
      q1_meta <= sel & ~q0;
      q1      <= q1_meta;
    end
  end

  assign clk_out = (clk0 & q0) | (clk1 & q1);
endmodule

`endif // CLOCK_VRTL_CLOCK_GATES_SV
