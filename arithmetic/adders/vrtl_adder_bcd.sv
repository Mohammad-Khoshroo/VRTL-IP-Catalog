`ifndef ARITHMETIC_ADDERS_VRTL_ADDER_BCD_SV
`define ARITHMETIC_ADDERS_VRTL_ADDER_BCD_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_bcd_adder_1digit u_vrtl_bcd_adder_1digit (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_bcd_adder_1digit (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);
  logic [4:0] binary_sum;

  always_comb begin
    binary_sum = a + b + cin;
    if (binary_sum > 5'd9) begin
      sum  = binary_sum[3:0] + 4'd6;
      cout = 1'b1;
    end else begin
      sum  = binary_sum[3:0];
      cout = 1'b0;
    end
  end
endmodule


// =============================================================================
// vrtl_bcd_adder_4digit u_vrtl_bcd_adder_4digit (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
module vrtl_bcd_adder_4digit (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  wire [4:0] c;
  assign c[0] = cin;
  assign cout = c[4];

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : gen_bcd
      vrtl_bcd_adder_1digit bcd_digit (
          .a    (a[i*4 +: 4]),
          .b    (b[i*4 +: 4]),
          .cin  (c[i]),
          .sum  (sum[i*4 +: 4]),
          .cout (c[i+1])
      );
    end
  endgenerate
endmodule


// =============================================================================
// vrtl_serial_adder u_vrtl_serial_adder (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .start   (start),
//     .a_bit   (a_bit),
//     .b_bit   (b_bit),
//     .sum_bit (sum_bit)
// );
// =============================================================================
module vrtl_serial_adder (
    input  logic clk,
    input  logic rst_n,
    input  logic start,   // Clears carry flop at word boundary
    input  logic a_bit,
    input  logic b_bit,
    output logic sum_bit
);
  logic carry_q;
  wire next_carry = (a_bit & b_bit) | (carry_q & (a_bit ^ b_bit));

  assign sum_bit = a_bit ^ b_bit ^ carry_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      carry_q <= 1'b0;
    end else if (start) begin
      carry_q <= (a_bit & b_bit);
    end else begin
      carry_q <= next_carry;
    end
  end
endmodule

`endif // ARITHMETIC_ADDERS_VRTL_ADDER_BCD_SV
