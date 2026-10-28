`ifndef LOGIC_ENCODERS_VRTL_ENCODERS_SV
`define LOGIC_ENCODERS_VRTL_ENCODERS_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_encoder_4to2 u_vrtl_encoder_4to2 (
//     .in    (in),
//     .out   (out),
//     .valid (valid)
// );
// =============================================================================
module vrtl_encoder_4to2 (
    input  logic [3:0] in,
    output logic [1:0] out,
    output logic       valid
);
  always_comb begin
    valid = |in;
    case (in)
      4'b0001: out = 2'b00;
      4'b0010: out = 2'b01;
      4'b0100: out = 2'b10;
      4'b1000: out = 2'b11;
      default: out = 2'b00;
    endcase
  end
endmodule


// =============================================================================
// vrtl_encoder_8to3 u_vrtl_encoder_8to3 (
//     .in    (in),
//     .out   (out),
//     .valid (valid)
// );
// =============================================================================
module vrtl_encoder_8to3 (
    input  logic [7:0] in,
    output logic [2:0] out,
    output logic       valid
);
  always_comb begin
    valid = |in;
    case (in)
      8'b0000_0001: out = 3'b000;
      8'b0000_0010: out = 3'b001;
      8'b0000_0100: out = 3'b010;
      8'b0000_1000: out = 3'b011;
      8'b0001_0000: out = 3'b100;
      8'b0010_0000: out = 3'b101;
      8'b0100_0000: out = 3'b110;
      8'b1000_0000: out = 3'b111;
      default:      out = 3'b000;
    endcase
  end
endmodule


// =============================================================================
// vrtl_priority_encoder_4to2 u_vrtl_priority_encoder_4to2 (
//     .in    (in),
//     .out   (out),
//     .valid (valid)
// );
// =============================================================================
module vrtl_priority_encoder_4to2 (
    input  logic [3:0] in,
    output logic [1:0] out,
    output logic       valid
);
  always_comb begin
    valid = |in;
    casez (in)
      4'b1???: out = 2'b11;
      4'b01??: out = 2'b10;
      4'b001?: out = 2'b01;
      default: out = 2'b00;
    endcase
  end
endmodule


// =============================================================================
// vrtl_priority_encoder_8to3 u_vrtl_priority_encoder_8to3 (
//     .in    (in),
//     .out   (out),
//     .valid (valid)
// );
// =============================================================================
module vrtl_priority_encoder_8to3 (
    input  logic [7:0] in,
    output logic [2:0] out,
    output logic       valid
);
  always_comb begin
    valid = |in;
    casez (in)
      8'b1???????: out = 3'b111;
      8'b01??????: out = 3'b110;
      8'b001?????: out = 3'b101;
      8'b0001????: out = 3'b100;
      8'b00001???: out = 3'b011;
      8'b000001??: out = 3'b010;
      8'b0000001?: out = 3'b001;
      default:     out = 3'b000;
    endcase
  end
endmodule


// =============================================================================
// vrtl_priority_encoder_8to3_74xx148 u_vrtl_priority_encoder_8to3_74xx148 (
//     .ei_n (ei_n),
//     .in_n (in_n),
//     .a_n  (a_n),
//     .gs_n (gs_n),
//     .eo_n (eo_n)
// );
// =============================================================================
module vrtl_priority_encoder_8to3_74xx148 (
    input  logic       ei_n, // Active-low enable input
    input  logic [7:0] in_n, // Active-low priority inputs (7 has highest priority)
    output logic [2:0] a_n,  // Active-low address outputs
    output logic       gs_n, // Active-low group select (asserted when any input active)
    output logic       eo_n  // Active-low enable output (for cascading)
);
  always_comb begin
    a_n  = 3'b111;
    gs_n = 1'b1;
    eo_n = 1'b1;

    if (!ei_n) begin
      if (in_n != 8'hFF) begin
        gs_n = 1'b0;
        eo_n = 1'b1;
        casez (in_n)
          8'b0???????: a_n = ~3'd7;
          8'b10??????: a_n = ~3'd6;
          8'b110?????: a_n = ~3'd5;
          8'b1110????: a_n = ~3'd4;
          8'b11110???: a_n = ~3'd3;
          8'b111110??: a_n = ~3'd2;
          8'b1111110?: a_n = ~3'd1;
          default:     a_n = ~3'd0;
        endcase
      end else begin
        gs_n = 1'b1;
        eo_n = 1'b0; // Propagate enable to next chip
      end
    end
  end
endmodule


// =============================================================================
// vrtl_priority_encoder_16to4 u_vrtl_priority_encoder_16to4 (
//     .in    (in),
//     .out   (out),
//     .valid (valid)
// );
// =============================================================================
module vrtl_priority_encoder_16to4 (
    input  logic [15:0] in,
    output logic [3:0]  out,
    output logic        valid
);
  always_comb begin
    valid = |in;
    out   = '0;
    for (int i = 0; i < 16; i = i + 1) begin
      if (in[i]) out = 4'(i);
    end
  end
endmodule


// =============================================================================
// vrtl_priority_encoder_16to4_cascaded u_vrtl_priority_encoder_16to4_cascaded (
//     .in    (in),
//     .out   (out),
//     .valid (valid)
// );
// =============================================================================
module vrtl_priority_encoder_16to4_cascaded (
    input  logic [15:0] in,
    output logic [3:0]  out,
    output logic        valid
);
  wire [2:0] a_hi_n, a_lo_n;
  wire gs_hi_n, gs_lo_n;
  wire eo_hi_n, eo_lo_n;

  // High 8 inputs have priority over low 8
  vrtl_priority_encoder_8to3_74xx148 enc_hi (
      .ei_n (1'b0),
      .in_n (~in[15:8]),
      .a_n  (a_hi_n),
      .gs_n (gs_hi_n),
      .eo_n (eo_hi_n)
  );

  vrtl_priority_encoder_8to3_74xx148 enc_lo (
      .ei_n (eo_hi_n),
      .in_n (~in[7:0]),
      .a_n  (a_lo_n),
      .gs_n (gs_lo_n),
      .eo_n (eo_lo_n)
  );

  assign valid  = ~gs_hi_n | ~gs_lo_n;
  assign out[3] = ~gs_hi_n;
  assign out[2:0] = ~gs_hi_n ? ~a_hi_n : ~a_lo_n;
endmodule


// =============================================================================
// vrtl_leading_one_detector #(
//     .WIDTH (32)
// ) u_vrtl_leading_one_detector (
//     .in      (in),
//     .one_hot (one_hot),
//     .valid   (valid)
// );
// =============================================================================
module vrtl_leading_one_detector #(
    parameter int WIDTH = 32
)(
    input  logic [WIDTH-1:0] in,
    output logic [WIDTH-1:0] one_hot,
    output logic             valid
);
  assign valid = |in;
  assign one_hot = in & ~(in - 1'b1);
endmodule


// =============================================================================
// vrtl_priority_encoder #(
//     .WIDTH         (8),
//     .HIGHEST_FIRST (1)
// ) u_vrtl_priority_encoder (
//     .in    (in),
//     .out   (out),
//     .valid (valid)
// );
// =============================================================================
module vrtl_priority_encoder #(
    parameter int WIDTH         = 8,
    parameter bit HIGHEST_FIRST = 1,
    localparam int OUT_WIDTH    = (WIDTH > 1) ? $clog2(WIDTH) : 1
)(
    input  logic [WIDTH-1:0]     in,
    output logic [OUT_WIDTH-1:0] out,
    output logic                 valid
);
  integer i;
  always_comb begin
    valid = |in;
    out   = '0;
    if (HIGHEST_FIRST) begin
      for (i = 0; i < WIDTH; i = i + 1) begin
        if (in[i]) begin
          out = OUT_WIDTH'(i);
        end
      end
    end else begin
      for (i = WIDTH - 1; i >= 0; i = i - 1) begin
        if (in[i]) begin
          out = OUT_WIDTH'(i);
        end
      end
    end
  end
endmodule


// =============================================================================
// vrtl_encoder #(
//     .WIDTH (8)
// ) u_vrtl_encoder (
//     .in    (in),
//     .out   (out),
//     .valid (valid)
// );
// =============================================================================
module vrtl_encoder #(
    parameter int WIDTH      = 8,
    localparam int OUT_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1
)(
    input  logic [WIDTH-1:0]     in,
    output logic [OUT_WIDTH-1:0] out,
    output logic                 valid
);
  integer i;
  always_comb begin
    valid = |in;
    out   = '0;
    for (i = 0; i < WIDTH; i = i + 1) begin
      if (in[i]) begin
        out = out | OUT_WIDTH'(i);
      end
    end
  end
endmodule

`endif // LOGIC_ENCODERS_VRTL_ENCODERS_SV
