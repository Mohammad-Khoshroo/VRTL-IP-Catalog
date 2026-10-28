`ifndef CONVERTERS_VRTL_CONVERTER_GRAY_SV
`define CONVERTERS_VRTL_CONVERTER_GRAY_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_bin_to_gray_4b u_vrtl_bin_to_gray_4b (
//     .bin  (bin),
//     .gray (gray)
// );
// =============================================================================
module vrtl_bin_to_gray_4b (
    input  logic [3:0] bin,
    output logic [3:0] gray
);
  assign gray = bin ^ (bin >> 1);
endmodule


// =============================================================================
// vrtl_bin_to_gray_8b u_vrtl_bin_to_gray_8b (
//     .bin  (bin),
//     .gray (gray)
// );
// =============================================================================
module vrtl_bin_to_gray_8b (
    input  logic [7:0] bin,
    output logic [7:0] gray
);
  assign gray = bin ^ (bin >> 1);
endmodule


// =============================================================================
// vrtl_bin_to_gray #(
//     .WIDTH (8)
// ) u_vrtl_bin_to_gray (
//     .bin  (bin),
//     .gray (gray)
// );
// =============================================================================
module vrtl_bin_to_gray #(
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] bin,
    output logic [WIDTH-1:0] gray
);
  assign gray = bin ^ (bin >> 1);
endmodule


// =============================================================================
// vrtl_gray_to_bin_4b u_vrtl_gray_to_bin_4b (
//     .gray (gray),
//     .bin  (bin)
// );
// =============================================================================
module vrtl_gray_to_bin_4b (
    input  logic [3:0] gray,
    output logic [3:0] bin
);
  always_comb begin
    bin[3] = gray[3];
    bin[2] = bin[3] ^ gray[2];
    bin[1] = bin[2] ^ gray[1];
    bin[0] = bin[1] ^ gray[0];
  end
endmodule


// =============================================================================
// vrtl_gray_to_bin_8b u_vrtl_gray_to_bin_8b (
//     .gray (gray),
//     .bin  (bin)
// );
// =============================================================================
module vrtl_gray_to_bin_8b (
    input  logic [7:0] gray,
    output logic [7:0] bin
);
  always_comb begin
    bin[7] = gray[7];
    for (int i = 6; i >= 0; i = i - 1) begin
      bin[i] = bin[i+1] ^ gray[i];
    end
  end
endmodule


// =============================================================================
// vrtl_gray_to_bin #(
//     .WIDTH (8)
// ) u_vrtl_gray_to_bin (
//     .gray (gray),
//     .bin  (bin)
// );
// =============================================================================
module vrtl_gray_to_bin #(
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] gray,
    output logic [WIDTH-1:0] bin
);
  always_comb begin
    bin[WIDTH-1] = gray[WIDTH-1];
    for (int i = WIDTH-2; i >= 0; i = i - 1) begin
      bin[i] = bin[i+1] ^ gray[i];
    end
  end
endmodule

`endif // CONVERTERS_VRTL_CONVERTER_GRAY_SV
