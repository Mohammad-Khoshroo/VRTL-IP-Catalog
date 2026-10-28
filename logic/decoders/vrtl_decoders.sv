`ifndef LOGIC_DECODERS_VRTL_DECODERS_SV
`define LOGIC_DECODERS_VRTL_DECODERS_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_decoder_1to2 u_vrtl_decoder_1to2 (
//     .en  (en),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_decoder_1to2 (
    input  logic       en,
    input  logic       in,
    output logic [1:0] out
);
  always_comb begin
    out = 2'b00;
    if (en) begin
      out[in] = 1'b1;
    end
  end
endmodule


// =============================================================================
// vrtl_decoder_2to4 u_vrtl_decoder_2to4 (
//     .en  (en),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_decoder_2to4 (
    input  logic       en,
    input  logic [1:0] in,
    output logic [3:0] out
);
  always_comb begin
    out = 4'b0000;
    if (en) begin
      out[in] = 1'b1;
    end
  end
endmodule


// =============================================================================
// vrtl_decoder_3to8 u_vrtl_decoder_3to8 (
//     .en  (en),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_decoder_3to8 (
    input  logic       en,
    input  logic [2:0] in,
    output logic [7:0] out
);
  always_comb begin
    out = 8'b0000_0000;
    if (en) begin
      out[in] = 1'b1;
    end
  end
endmodule


// =============================================================================
// vrtl_decoder_4to16 u_vrtl_decoder_4to16 (
//     .en  (en),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_decoder_4to16 (
    input  logic        en,
    input  logic [3:0]  in,
    output logic [15:0] out
);
  always_comb begin
    out = 16'h0000;
    if (en) begin
      out[in] = 1'b1;
    end
  end
endmodule


// =============================================================================
// vrtl_decoder_2to4_low u_vrtl_decoder_2to4_low (
//     .en  (en),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_decoder_2to4_low (
    input  logic       en,
    input  logic [1:0] in,
    output logic [3:0] out
);
  always_comb begin
    out = 4'b1111;
    if (en) begin
      out[in] = 1'b0;
    end
  end
endmodule


// =============================================================================
// vrtl_decoder_3to8_low u_vrtl_decoder_3to8_low (
//     .en  (en),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_decoder_3to8_low (
    input  logic       en,
    input  logic [2:0] in,
    output logic [7:0] out
);
  always_comb begin
    out = 8'b1111_1111;
    if (en) begin
      out[in] = 1'b0;
    end
  end
endmodule


// =============================================================================
// vrtl_decoder_3to8_74xx138 u_vrtl_decoder_3to8_74xx138 (
//     .g1    (g1),
//     .g2a_n (g2a_n),
//     .g2b_n (g2b_n),
//     .in    (in),
//     .y_n   (y_n)
// );
// =============================================================================
module vrtl_decoder_3to8_74xx138 (
    input  logic       g1,    // Active-high enable
    input  logic       g2a_n, // Active-low enable
    input  logic       g2b_n, // Active-low enable
    input  logic [2:0] in,    // Select lines {C, B, A}
    output logic [7:0] y_n    // Active-low outputs
);
  wire en = g1 & ~g2a_n & ~g2b_n;

  always_comb begin
    y_n = 8'hFF;
    if (en) begin
      y_n[in] = 1'b0;
    end
  end
endmodule


// =============================================================================
// vrtl_decoder_4to16_tree u_vrtl_decoder_4to16_tree (
//     .en  (en),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_decoder_4to16_tree (
    input  logic        en,
    input  logic [3:0]  in,
    output logic [15:0] out
);
  wire en_lo = en & ~in[3];
  wire en_hi = en & in[3];

  vrtl_decoder_3to8 dec_lo (.en(en_lo), .in(in[2:0]), .out(out[7:0]));
  vrtl_decoder_3to8 dec_hi (.en(en_hi), .in(in[2:0]), .out(out[15:8]));
endmodule


// =============================================================================
// vrtl_bcd_to_decimal_decoder u_vrtl_bcd_to_decimal_decoder (
//     .bcd   (bcd),
//     .out_n (out_n)
// );
// =============================================================================
module vrtl_bcd_to_decimal_decoder (
    input  logic [3:0] bcd,
    output logic [9:0] out_n // Active-low decimal lines 0-9
);
  always_comb begin
    out_n = 10'b11_1111_1111;
    if (bcd < 4'd10) begin
      out_n[bcd] = 1'b0;
    end
  end
endmodule


// =============================================================================
// vrtl_decoder #(
//     .INPUT_WIDTH (3)
// ) u_vrtl_decoder (
//     .en  (en),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_decoder #(
    parameter int INPUT_WIDTH = 3,
    localparam int OUT_WIDTH  = (1 << INPUT_WIDTH)
)(
    input  logic                   en,
    input  logic [INPUT_WIDTH-1:0] in,
    output logic [OUT_WIDTH-1:0]   out
);
  always_comb begin
    out = '0;
    if (en) begin
      out[in] = 1'b1;
    end
  end
endmodule


// =============================================================================
// vrtl_decoder_low #(
//     .INPUT_WIDTH (3)
// ) u_vrtl_decoder_low (
//     .en  (en),
//     .in  (in),
//     .out (out)
// );
// =============================================================================
module vrtl_decoder_low #(
    parameter int INPUT_WIDTH = 3,
    localparam int OUT_WIDTH  = (1 << INPUT_WIDTH)
)(
    input  logic                   en,
    input  logic [INPUT_WIDTH-1:0] in,
    output logic [OUT_WIDTH-1:0]   out
);
  always_comb begin
    out = '1;
    if (en) begin
      out[in] = 1'b0;
    end
  end
endmodule

`endif // LOGIC_DECODERS_VRTL_DECODERS_SV
