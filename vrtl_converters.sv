`ifndef VRTL_CONVERTERS_SV
`define VRTL_CONVERTERS_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Binary <-> BCD Data Converters
// =============================================================================

/*
// Instance Example:
vrtl_bin_to_bcd_8b u_vrtl_bin_to_bcd_8b (
    .bin (bin),
    .bcd (bcd)
);
*/
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


/*
// Instance Example:
vrtl_bin_to_bcd_16b u_vrtl_bin_to_bcd_16b (
    .bin (bin),
    .bcd (bcd)
);
*/
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


/*
// Instance Example:
vrtl_bin_to_bcd #(
    .BIN_W(8),
    .DIGITS(3)
) u_vrtl_bin_to_bcd (
    .bin (bin),
    .bcd (bcd)
);
*/
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


/*
// Instance Example:
vrtl_bcd_to_bin_8b u_vrtl_bcd_to_bin_8b (
    .bcd (bcd),
    .bin (bin)
);
*/
module vrtl_bcd_to_bin_8b (
    input  logic [7:0] bcd, // {tens, ones}
    output logic [7:0] bin
);
  assign bin = (bcd[7:4] * 4'd10) + bcd[3:0];
endmodule


/*
// Instance Example:
vrtl_bcd_to_bin_12b u_vrtl_bcd_to_bin_12b (
    .bcd (bcd),
    .bin (bin)
);
*/
module vrtl_bcd_to_bin_12b (
    input  logic [11:0] bcd, // {hundreds, tens, ones}
    output logic [9:0]  bin
);
  assign bin = (bcd[11:8] * 10'd100) + (bcd[7:4] * 10'd10) + bcd[3:0];
endmodule


/*
// Instance Example:
vrtl_bcd_to_bin_16b u_vrtl_bcd_to_bin_16b (
    .bcd (bcd),
    .bin (bin)
);
*/
module vrtl_bcd_to_bin_16b (
    input  logic [15:0] bcd, // {thousands, hundreds, tens, ones}
    output logic [13:0] bin
);
  assign bin = (bcd[15:12] * 14'd1000) + (bcd[11:8] * 14'd100) + (bcd[7:4] * 14'd10) + bcd[3:0];
endmodule


// =============================================================================
// Binary <-> Gray Code Converters
// =============================================================================

/*
// Instance Example:
vrtl_bin_to_gray_4b u_vrtl_bin_to_gray_4b (
    .bin  (bin),
    .gray (gray)
);
*/
module vrtl_bin_to_gray_4b (
    input  logic [3:0] bin,
    output logic [3:0] gray
);
  assign gray = bin ^ (bin >> 1);
endmodule


/*
// Instance Example:
vrtl_bin_to_gray_8b u_vrtl_bin_to_gray_8b (
    .bin  (bin),
    .gray (gray)
);
*/
module vrtl_bin_to_gray_8b (
    input  logic [7:0] bin,
    output logic [7:0] gray
);
  assign gray = bin ^ (bin >> 1);
endmodule


/*
// Instance Example:
vrtl_bin_to_gray #(
    .WIDTH(8)
) u_vrtl_bin_to_gray (
    .bin  (bin),
    .gray (gray)
);
*/
module vrtl_bin_to_gray #(
    parameter int WIDTH = 8
)(
    input  logic [WIDTH-1:0] bin,
    output logic [WIDTH-1:0] gray
);
  assign gray = bin ^ (bin >> 1);
endmodule


/*
// Instance Example:
vrtl_gray_to_bin_4b u_vrtl_gray_to_bin_4b (
    .gray (gray),
    .bin  (bin)
);
*/
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


/*
// Instance Example:
vrtl_gray_to_bin_8b u_vrtl_gray_to_bin_8b (
    .gray (gray),
    .bin  (bin)
);
*/
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


/*
// Instance Example:
vrtl_gray_to_bin #(
    .WIDTH(8)
) u_vrtl_gray_to_bin (
    .gray (gray),
    .bin  (bin)
);
*/
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


// =============================================================================
// Thermometer Code Converters
// =============================================================================

/*
// Instance Example:
vrtl_bin_to_thermometer_4b u_vrtl_bin_to_thermometer_4b (
    .bin   (bin),
    .therm (therm)
);
*/
module vrtl_bin_to_thermometer_4b (
    input  logic [3:0]  bin,
    output logic [14:0] therm
);
  always_comb begin
    for (int i = 0; i < 15; i = i + 1) begin
      therm[i] = (bin > 4'(i));
    end
  end
endmodule


/*
// Instance Example:
vrtl_thermometer_to_bin_15b u_vrtl_thermometer_to_bin_15b (
    .therm (therm),
    .bin   (bin)
);
*/
module vrtl_thermometer_to_bin_15b (
    input  logic [14:0] therm,
    output logic [3:0]  bin
);
  always_comb begin
    bin = '0;
    for (int i = 0; i < 15; i = i + 1) begin
      if (therm[i]) begin
        bin = bin + 1'b1;
      end
    end
  end
endmodule

`endif // VRTL_CONVERTERS_SV
