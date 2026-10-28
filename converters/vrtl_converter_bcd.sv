`ifndef CONVERTERS_VRTL_CONVERTER_BCD_SV
`define CONVERTERS_VRTL_CONVERTER_BCD_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_bin_to_bcd_8b u_vrtl_bin_to_bcd_8b (
//     .bin (bin),
//     .bcd (bcd)
// );
// =============================================================================
module vrtl_bin_to_bcd_8b (
    input  logic [7:0]  bin,
    output logic [11:0] bcd // {hundreds, tens, ones}
);
  always_comb begin
    bcd = '0;
    for (int i = 7; i >= 0; i = i - 1) begin
      if (bcd[3:0] >= 5)  bcd[3:0]  = bcd[3:0] + 4'd3;
      if (bcd[7:4] >= 5)  bcd[7:4]  = bcd[7:4] + 4'd3;
      if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 4'd3;

      bcd = {bcd[10:0], bin[i]};
    end
  end
endmodule


// =============================================================================
// vrtl_bin_to_bcd_16b u_vrtl_bin_to_bcd_16b (
//     .bin (bin),
//     .bcd (bcd)
// );
// =============================================================================
module vrtl_bin_to_bcd_16b (
    input  logic [15:0] bin,
    output logic [19:0] bcd // 5 digits {ten_thousands, thousands, hundreds, tens, ones}
);
  always_comb begin
    bcd = '0;
    for (int i = 15; i >= 0; i = i - 1) begin
      for (int d = 0; d < 5; d = d + 1) begin
        if (bcd[d*4 +: 4] >= 5) begin
          bcd[d*4 +: 4] = bcd[d*4 +: 4] + 4'd3;
        end
      end
      bcd = {bcd[18:0], bin[i]};
    end
  end
endmodule


// =============================================================================
// vrtl_bin_to_bcd #(
//     .BIN_W  (8),
//     .DIGITS (3)
// ) u_vrtl_bin_to_bcd (
//     .bin (bin),
//     .bcd (bcd)
// );
// =============================================================================
module vrtl_bin_to_bcd #(
    parameter int BIN_W  = 8,
    parameter int DIGITS = 3
)(
    input  logic [BIN_W-1:0]    bin,
    output logic [DIGITS*4-1:0] bcd
);
  always_comb begin
    bcd = '0;
    for (int i = BIN_W - 1; i >= 0; i = i - 1) begin
      for (int d = 0; d < DIGITS; d = d + 1) begin
        if (bcd[d*4 +: 4] >= 5) begin
          bcd[d*4 +: 4] = bcd[d*4 +: 4] + 4'd3;
        end
      end
      bcd = {bcd[DIGITS*4-2:0], bin[i]};
    end
  end
endmodule


// =============================================================================
// vrtl_bcd_to_bin_8b u_vrtl_bcd_to_bin_8b (
//     .bcd (bcd),
//     .bin (bin)
// );
// =============================================================================
module vrtl_bcd_to_bin_8b (
    input  logic [7:0] bcd, // {tens, ones}
    output logic [7:0] bin
);
  assign bin = (bcd[7:4] * 4'd10) + bcd[3:0];
endmodule


// =============================================================================
// vrtl_bcd_to_bin_12b u_vrtl_bcd_to_bin_12b (
//     .bcd (bcd),
//     .bin (bin)
// );
// =============================================================================
module vrtl_bcd_to_bin_12b (
    input  logic [11:0] bcd, // {hundreds, tens, ones}
    output logic [9:0]  bin
);
  assign bin = (bcd[11:8] * 10'd100) + (bcd[7:4] * 10'd10) + bcd[3:0];
endmodule


// =============================================================================
// vrtl_bcd_to_bin_16b u_vrtl_bcd_to_bin_16b (
//     .bcd (bcd),
//     .bin (bin)
// );
// =============================================================================
module vrtl_bcd_to_bin_16b (
    input  logic [15:0] bcd, // {thousands, hundreds, tens, ones}
    output logic [13:0] bin
);
  assign bin = (bcd[15:12] * 14'd1000) + (bcd[11:8] * 14'd100) + (bcd[7:4] * 14'd10) + bcd[3:0];
endmodule

`endif // CONVERTERS_VRTL_CONVERTER_BCD_SV
