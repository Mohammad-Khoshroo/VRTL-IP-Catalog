`ifndef PERIPHERALS_IO_VRTL_DISPLAY_7SEG_SV
`define PERIPHERALS_IO_VRTL_DISPLAY_7SEG_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_hex_to_7seg u_vrtl_hex_to_7seg (
//     .hex (hex),
//     .seg (seg)
// );
// =============================================================================
module vrtl_hex_to_7seg (
    input  logic [3:0] hex,
    output logic [6:0] seg // {g, f, e, d, c, b, a} Active-low
);
  always_comb begin
    case (hex)
      4'h0: seg = 7'b100_0000;
      4'h1: seg = 7'b111_1001;
      4'h2: seg = 7'b010_0100;
      4'h3: seg = 7'b011_0000;
      4'h4: seg = 7'b001_1001;
      4'h5: seg = 7'b001_0010;
      4'h6: seg = 7'b000_0010;
      4'h7: seg = 7'b111_1000;
      4'h8: seg = 7'b000_0000;
      4'h9: seg = 7'b001_0000;
      4'hA: seg = 7'b000_1000;
      4'hB: seg = 7'b000_0011;
      4'hC: seg = 7'b100_0110;
      4'hD: seg = 7'b010_0001;
      4'hE: seg = 7'b000_0110;
      4'hF: seg = 7'b000_1110;
      default: seg = 7'b111_1111;
    endcase
  end
endmodule


// =============================================================================
// vrtl_seven_seg_controller #(
//     .DIGITS        (4),
//     .SCAN_INTERVAL (50_000)
// ) u_vrtl_seven_seg_controller (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .hex_in   (hex_in),
//     .dp_in    (dp_in),
//     .anodes   (anodes),
//     .cathodes (cathodes),
//     .dp_out   (dp_out)
// );
// =============================================================================
module vrtl_seven_seg_controller #(
    parameter int DIGITS        = 4,
    parameter int SCAN_INTERVAL = 50_000,
    localparam int DIGIT_W      = $clog2(DIGITS),
    localparam int CNT_W        = $clog2(SCAN_INTERVAL + 1)
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [4*DIGITS-1:0]     hex_in,
    input  logic [DIGITS-1:0]       dp_in,
    output logic [DIGITS-1:0]       anodes,   // Active-low
    output logic [6:0]              cathodes, // Active-low {g,f,e,d,c,b,a}
    output logic                    dp_out    // Active-low
);
  logic [CNT_W-1:0]   scan_cnt;
  logic [DIGIT_W-1:0] cur_digit;
  logic [3:0]         cur_hex;

  assign cur_hex = hex_in[cur_digit*4 +: 4];
  assign dp_out  = ~dp_in[cur_digit];

  vrtl_hex_to_7seg dec (
      .hex (cur_hex),
      .seg (cathodes)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      scan_cnt  <= '0;
      cur_digit <= '0;
      anodes    <= '1;
    end else begin
      if (scan_cnt >= CNT_W'(SCAN_INTERVAL - 1)) begin
        scan_cnt  <= '0;
        cur_digit <= (cur_digit == DIGIT_W'(DIGITS - 1)) ? '0 : cur_digit + 1'b1;
      end else begin
        scan_cnt <= scan_cnt + 1'b1;
      end

      anodes <= '1;
      anodes[cur_digit] <= 1'b0;
    end
  end
endmodule

`endif // PERIPHERALS_IO_VRTL_DISPLAY_7SEG_SV
