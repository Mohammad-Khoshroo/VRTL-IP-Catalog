`ifndef ARITHMETIC_MULTIPLIERS_VRTL_MULT_PIPELINED_SV
`define ARITHMETIC_MULTIPLIERS_VRTL_MULT_PIPELINED_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_multiplier_pipelined_8x8 u_vrtl_multiplier_pipelined_8x8 (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_multiplier_pipelined_8x8 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] product
);
  logic [15:0] stage1_prod;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      stage1_prod <= '0;
      product     <= '0;
    end else begin
      stage1_prod <= a * b;
      product     <= stage1_prod;
    end
  end
endmodule

`endif // ARITHMETIC_MULTIPLIERS_VRTL_MULT_PIPELINED_SV
