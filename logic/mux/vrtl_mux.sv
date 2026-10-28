`ifndef LOGIC_MUX_VRTL_MUX_SV
`define LOGIC_MUX_VRTL_MUX_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_mux2_1b u_vrtl_mux2_1b (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .out (out)
// );
// =============================================================================
module vrtl_mux2_1b (
    input  logic sel,
    input  logic in0,
    input  logic in1,
    output logic out
);
  assign out = sel ? in1 : in0;
endmodule


// =============================================================================
// vrtl_mux4_1b u_vrtl_mux4_1b (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .in2 (in2),
//     .in3 (in3),
//     .out (out)
// );
// =============================================================================
module vrtl_mux4_1b (
    input  logic [1:0] sel,
    input  logic       in0,
    input  logic       in1,
    input  logic       in2,
    input  logic       in3,
    output logic       out
);
  always_comb begin
    case (sel)
      2'b00:   out = in0;
      2'b01:   out = in1;
      2'b10:   out = in2;
      default: out = in3;
    endcase
  end
endmodule


// =============================================================================
// vrtl_mux8_1b u_vrtl_mux8_1b (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .in2 (in2),
//     .in3 (in3),
//     .in4 (in4),
//     .in5 (in5),
//     .in6 (in6),
//     .in7 (in7),
//     .out (out)
// );
// =============================================================================
module vrtl_mux8_1b (
    input  logic [2:0] sel,
    input  logic       in0,
    input  logic       in1,
    input  logic       in2,
    input  logic       in3,
    input  logic       in4,
    input  logic       in5,
    input  logic       in6,
    input  logic       in7,
    output logic       out
);
  always_comb begin
    case (sel)
      3'b000:  out = in0;
      3'b001:  out = in1;
      3'b010:  out = in2;
      3'b011:  out = in3;
      3'b100:  out = in4;
      3'b101:  out = in5;
      3'b110:  out = in6;
      default: out = in7;
    endcase
  end
endmodule


// =============================================================================
// vrtl_mux2_8b u_vrtl_mux2_8b (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .out (out)
// );
// =============================================================================
module vrtl_mux2_8b (
    input  logic       sel,
    input  logic [7:0] in0,
    input  logic [7:0] in1,
    output logic [7:0] out
);
  assign out = sel ? in1 : in0;
endmodule


// =============================================================================
// vrtl_mux4_8b u_vrtl_mux4_8b (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .in2 (in2),
//     .in3 (in3),
//     .out (out)
// );
// =============================================================================
module vrtl_mux4_8b (
    input  logic [1:0] sel,
    input  logic [7:0] in0,
    input  logic [7:0] in1,
    input  logic [7:0] in2,
    input  logic [7:0] in3,
    output logic [7:0] out
);
  always_comb begin
    case (sel)
      2'b00:   out = in0;
      2'b01:   out = in1;
      2'b10:   out = in2;
      default: out = in3;
    endcase
  end
endmodule


// =============================================================================
// vrtl_mux8_8b u_vrtl_mux8_8b (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .in2 (in2),
//     .in3 (in3),
//     .in4 (in4),
//     .in5 (in5),
//     .in6 (in6),
//     .in7 (in7),
//     .out (out)
// );
// =============================================================================
module vrtl_mux8_8b (
    input  logic [2:0] sel,
    input  logic [7:0] in0,
    input  logic [7:0] in1,
    input  logic [7:0] in2,
    input  logic [7:0] in3,
    input  logic [7:0] in4,
    input  logic [7:0] in5,
    input  logic [7:0] in6,
    input  logic [7:0] in7,
    output logic [7:0] out
);
  always_comb begin
    case (sel)
      3'b000:  out = in0;
      3'b001:  out = in1;
      3'b010:  out = in2;
      3'b011:  out = in3;
      3'b100:  out = in4;
      3'b101:  out = in5;
      3'b110:  out = in6;
      default: out = in7;
    endcase
  end
endmodule


// =============================================================================
// vrtl_mux2_32b u_vrtl_mux2_32b (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .out (out)
// );
// =============================================================================
module vrtl_mux2_32b (
    input  logic        sel,
    input  logic [31:0] in0,
    input  logic [31:0] in1,
    output logic [31:0] out
);
  assign out = sel ? in1 : in0;
endmodule


// =============================================================================
// vrtl_mux2 #(
//     .WIDTH (8)
// ) u_vrtl_mux2 (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .out (out)
// );
// =============================================================================
module vrtl_mux2 #(
    parameter int WIDTH = 8
)(
    input  logic             sel,
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    output logic [WIDTH-1:0] out
);
  assign out = sel ? in1 : in0;
endmodule


// =============================================================================
// vrtl_mux4 #(
//     .WIDTH (8)
// ) u_vrtl_mux4 (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .in2 (in2),
//     .in3 (in3),
//     .out (out)
// );
// =============================================================================
module vrtl_mux4 #(
    parameter int WIDTH = 8
)(
    input  logic [1:0]       sel,
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic [WIDTH-1:0] in2,
    input  logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out
);
  always_comb begin
    case (sel)
      2'b00:   out = in0;
      2'b01:   out = in1;
      2'b10:   out = in2;
      default: out = in3;
    endcase
  end
endmodule


// =============================================================================
// vrtl_mux8 #(
//     .WIDTH (8)
// ) u_vrtl_mux8 (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .in2 (in2),
//     .in3 (in3),
//     .in4 (in4),
//     .in5 (in5),
//     .in6 (in6),
//     .in7 (in7),
//     .out (out)
// );
// =============================================================================
module vrtl_mux8 #(
    parameter int WIDTH = 8
)(
    input  logic [2:0]       sel,
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic [WIDTH-1:0] in2,
    input  logic [WIDTH-1:0] in3,
    input  logic [WIDTH-1:0] in4,
    input  logic [WIDTH-1:0] in5,
    input  logic [WIDTH-1:0] in6,
    input  logic [WIDTH-1:0] in7,
    output logic [WIDTH-1:0] out
);
  always_comb begin
    case (sel)
      3'b000:  out = in0;
      3'b001:  out = in1;
      3'b010:  out = in2;
      3'b011:  out = in3;
      3'b100:  out = in4;
      3'b101:  out = in5;
      3'b110:  out = in6;
      default: out = in7;
    endcase
  end
endmodule


// =============================================================================
// vrtl_mux_n #(
//     .WIDTH    (8),
//     .N_INPUTS (4)
// ) u_vrtl_mux_n (
//     .sel (sel),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_mux_n #(
    parameter int WIDTH    = 8,
    parameter int N_INPUTS = 4,
    localparam int SEL_W   = (N_INPUTS > 1) ? $clog2(N_INPUTS) : 1
)(
    input  logic [SEL_W-1:0]          sel,
    input  logic [N_INPUTS*WIDTH-1:0] in,
    output logic [WIDTH-1:0]          out
);
  assign out = in[sel * WIDTH +: WIDTH];
endmodule


// =============================================================================
// vrtl_mux_onehot #(
//     .WIDTH    (8),
//     .N_INPUTS (4)
// ) u_vrtl_mux_onehot (
//     .sel_onehot (sel_onehot),
//     .in         (in),
//     .out        (out)
// );
// =============================================================================
module vrtl_mux_onehot #(
    parameter int WIDTH    = 8,
    parameter int N_INPUTS = 4
)(
    input  logic [N_INPUTS-1:0]       sel_onehot,
    input  logic [N_INPUTS*WIDTH-1:0] in,
    output logic [WIDTH-1:0]          out
);
  integer i;
  always_comb begin
    out = '0;
    for (i = 0; i < N_INPUTS; i = i + 1) begin
      if (sel_onehot[i]) begin
        out = out | in[i * WIDTH +: WIDTH];
      end
    end
  end
endmodule


// =============================================================================
// vrtl_priority_mux #(
//     .WIDTH    (8),
//     .N_INPUTS (4)
// ) u_vrtl_priority_mux (
//     .req (req),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_priority_mux #(
    parameter int WIDTH    = 8,
    parameter int N_INPUTS = 4
)(
    input  logic [N_INPUTS-1:0]       req,
    input  logic [N_INPUTS*WIDTH-1:0] in,
    output logic [WIDTH-1:0]          out
);
  integer i;
  always_comb begin
    out = in[0 +: WIDTH];
    for (i = N_INPUTS - 1; i >= 0; i = i - 1) begin
      if (req[i]) begin
        out = in[i * WIDTH +: WIDTH];
      end
    end
  end
endmodule


// =============================================================================
// vrtl_mux4_tree #(
//     .WIDTH (8)
// ) u_vrtl_mux4_tree (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .in2 (in2),
//     .in3 (in3),
//     .out (out)
// );
// =============================================================================
module vrtl_mux4_tree #(
    parameter int WIDTH = 8
)(
    input  logic [1:0]       sel,
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic [WIDTH-1:0] in2,
    input  logic [WIDTH-1:0] in3,
    output logic [WIDTH-1:0] out
);
  logic [WIDTH-1:0] stage0_0, stage0_1;

  vrtl_mux2 #(.WIDTH(WIDTH)) m0 (.sel(sel[0]), .in0(in0), .in1(in1), .out(stage0_0));
  vrtl_mux2 #(.WIDTH(WIDTH)) m1 (.sel(sel[0]), .in0(in2), .in1(in3), .out(stage0_1));
  vrtl_mux2 #(.WIDTH(WIDTH)) m2 (.sel(sel[1]), .in0(stage0_0), .in1(stage0_1), .out(out));
endmodule


// =============================================================================
// vrtl_mux8_tree #(
//     .WIDTH (8)
// ) u_vrtl_mux8_tree (
//     .sel (sel),
//     .in0 (in0),
//     .in1 (in1),
//     .in2 (in2),
//     .in3 (in3),
//     .in4 (in4),
//     .in5 (in5),
//     .in6 (in6),
//     .in7 (in7),
//     .out (out)
// );
// =============================================================================
module vrtl_mux8_tree #(
    parameter int WIDTH = 8
)(
    input  logic [2:0]       sel,
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic [WIDTH-1:0] in2,
    input  logic [WIDTH-1:0] in3,
    input  logic [WIDTH-1:0] in4,
    input  logic [WIDTH-1:0] in5,
    input  logic [WIDTH-1:0] in6,
    input  logic [WIDTH-1:0] in7,
    output logic [WIDTH-1:0] out
);
  logic [WIDTH-1:0] m4_0_out, m4_1_out;

  vrtl_mux4_tree #(.WIDTH(WIDTH)) m4_0 (
      .sel(sel[1:0]),
      .in0(in0), .in1(in1), .in2(in2), .in3(in3),
      .out(m4_0_out)
  );

  vrtl_mux4_tree #(.WIDTH(WIDTH)) m4_1 (
      .sel(sel[1:0]),
      .in0(in4), .in1(in5), .in2(in6), .in3(in7),
      .out(m4_1_out)
  );

  vrtl_mux2 #(.WIDTH(WIDTH)) m_final (
      .sel(sel[2]),
      .in0(m4_0_out),
      .in1(m4_1_out),
      .out(out)
  );
endmodule

`endif // LOGIC_MUX_VRTL_MUX_SV
