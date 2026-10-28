`ifndef INTERCONNECT_ARBITERS_VRTL_ARBITER_RR_SV
`define INTERCONNECT_ARBITERS_VRTL_ARBITER_RR_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_arbiter_round_robin_4 u_vrtl_arbiter_round_robin_4 (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .req   (req),
//     .grant (grant)
// );
// =============================================================================
module vrtl_arbiter_round_robin_4 (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [3:0] req,
    output logic [3:0] grant
);
  vrtl_arbiter_round_robin #(
      .CLIENTS(4)
  ) u_rra4 (
      .clk   (clk),
      .rst_n (rst_n),
      .req   (req),
      .grant (grant)
  );
endmodule


// =============================================================================
// vrtl_arbiter_round_robin_8 u_vrtl_arbiter_round_robin_8 (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .req   (req),
//     .grant (grant)
// );
// =============================================================================
module vrtl_arbiter_round_robin_8 (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [7:0] req,
    output logic [7:0] grant
);
  vrtl_arbiter_round_robin #(
      .CLIENTS(8)
  ) u_rra8 (
      .clk   (clk),
      .rst_n (rst_n),
      .req   (req),
      .grant (grant)
  );
endmodule


// =============================================================================
// vrtl_arbiter_round_robin #(
//     .CLIENTS (4)
// ) u_vrtl_arbiter_round_robin (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .req   (req),
//     .grant (grant)
// );
// =============================================================================
module vrtl_arbiter_round_robin #(
    parameter int CLIENTS = 4
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic [CLIENTS-1:0] req,
    output logic [CLIENTS-1:0] grant
);
  logic [CLIENTS-1:0] mask;
  logic [CLIENTS-1:0] masked_req;
  logic [CLIENTS-1:0] unmasked_grant;
  logic [CLIENTS-1:0] masked_grant;

  assign masked_req     = req & mask;
  assign unmasked_grant = req & (-req);
  assign masked_grant   = masked_req & (-masked_req);
  assign grant          = (|masked_req) ? masked_grant : unmasked_grant;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mask <= '1;
    end else if (|grant) begin
      mask <= ~(grant | (grant - 1'b1));
    end
  end
endmodule

`endif // INTERCONNECT_ARBITERS_VRTL_ARBITER_RR_SV
