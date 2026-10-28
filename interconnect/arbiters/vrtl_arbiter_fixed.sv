`ifndef INTERCONNECT_ARBITERS_VRTL_ARBITER_FIXED_SV
`define INTERCONNECT_ARBITERS_VRTL_ARBITER_FIXED_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_arbiter_fixed_4 u_vrtl_arbiter_fixed_4 (
//     .req   (req),
//     .grant (grant)
// );
// =============================================================================
module vrtl_arbiter_fixed_4 (
    input  logic [3:0] req,
    output logic [3:0] grant
);
  assign grant = req & (-req);
endmodule


// =============================================================================
// vrtl_arbiter_fixed_8 u_vrtl_arbiter_fixed_8 (
//     .req   (req),
//     .grant (grant)
// );
// =============================================================================
module vrtl_arbiter_fixed_8 (
    input  logic [7:0] req,
    output logic [7:0] grant
);
  assign grant = req & (-req);
endmodule


// =============================================================================
// vrtl_arbiter_fixed #(
//     .CLIENTS (4)
// ) u_vrtl_arbiter_fixed (
//     .req   (req),
//     .grant (grant)
// );
// =============================================================================
module vrtl_arbiter_fixed #(
    parameter int CLIENTS = 4
)(
    input  logic [CLIENTS-1:0] req,
    output logic [CLIENTS-1:0] grant
);
  assign grant = req & (-req);
endmodule

`endif // INTERCONNECT_ARBITERS_VRTL_ARBITER_FIXED_SV
