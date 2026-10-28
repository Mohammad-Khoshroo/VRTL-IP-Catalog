`ifndef INTERCONNECT_CROSSBAR_VRTL_CROSSBAR_SV
`define INTERCONNECT_CROSSBAR_VRTL_CROSSBAR_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_crossbar_2x2 #(
//     .WIDTH (8)
// ) u_vrtl_crossbar_2x2 (
//     .in0  (in0),
//     .in1  (in1),
//     .sel0 (sel0),
//     .sel1 (sel1),
//     .out0 (out0),
//     .out1 (out1)
// );
// =============================================================================
module vrtl_crossbar_2x2 #(
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic             sel0,
    input  logic             sel1,
    output logic [WIDTH-1:0] out0,
    output logic [WIDTH-1:0] out1
);
  assign out0 = sel0 ? in1 : in0;
  assign out1 = sel1 ? in1 : in0;
endmodule


// =============================================================================
// vrtl_crossbar_4x4 #(
//     .WIDTH (8)
// ) u_vrtl_crossbar_4x4 (
//     .in0  (in0),
//     .in1  (in1),
//     .in2  (in2),
//     .in3  (in3),
//     .sel0 (sel0),
//     .sel1 (sel1),
//     .sel2 (sel2),
//     .sel3 (sel3),
//     .out0 (out0),
//     .out1 (out1),
//     .out2 (out2),
//     .out3 (out3)
// );
// =============================================================================
module vrtl_crossbar_4x4 #(
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic [WIDTH-1:0] in2,
    input  logic [WIDTH-1:0] in3,
    input  logic [1:0]       sel0,
    input  logic [1:0]       sel1,
    input  logic [1:0]       sel2,
    input  logic [1:0]       sel3,
    output logic [WIDTH-1:0] out0,
    output logic [WIDTH-1:0] out1,
    output logic [WIDTH-1:0] out2,
    output logic [WIDTH-1:0] out3
);
  vrtl_mux4 #(.WIDTH(WIDTH)) m0 (.sel(sel0), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .out(out0));
  vrtl_mux4 #(.WIDTH(WIDTH)) m1 (.sel(sel1), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .out(out1));
  vrtl_mux4 #(.WIDTH(WIDTH)) m2 (.sel(sel2), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .out(out2));
  vrtl_mux4 #(.WIDTH(WIDTH)) m3 (.sel(sel3), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .out(out3));
endmodule

`endif // INTERCONNECT_CROSSBAR_VRTL_CROSSBAR_SV
