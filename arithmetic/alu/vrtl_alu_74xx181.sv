`ifndef ARITHMETIC_ALU_VRTL_ALU_74XX181_SV
`define ARITHMETIC_ALU_VRTL_ALU_74XX181_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_alu_74xx181 u_vrtl_alu_74xx181 (
//     .s      (s),
//     .a      (a),
//     .b      (b),
//     .m      (m),
//     .cn_n   (cn_n),
//     .f      (f),
//     .cn4_n  (cn4_n),
//     .p      (p),
//     .g      (g),
//     .a_eq_b (a_eq_b)
// );
// =============================================================================
module vrtl_alu_74xx181 (
    input  logic [3:0] s,
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       m,    // 1 = Logic mode, 0 = Arithmetic mode
    input  logic       cn_n, // Active-low carry in
    output logic [3:0] f,
    output logic       cn4_n,// Active-low carry out
    output logic       p,    // Propagate output
    output logic       g,    // Generate output
    output logic       a_eq_b
);
  logic [4:0] arith_res;
  wire cin = ~cn_n;

  always_comb begin
    arith_res = '0;
    f         = '0;

    if (m) begin
      // Logic Modes
      case (s)
        4'h0: f = ~a;
        4'h1: f = ~(a | b);
        4'h2: f = ~a & b;
        4'h3: f = 4'b0000;
        4'h4: f = ~(a & b);
        4'h5: f = ~b;
        4'h6: f = a ^ b;
        4'h7: f = a & ~b;
        4'h8: f = ~a | b;
        4'h9: f = ~(a ^ b);
        4'hA: f = b;
        4'hB: f = a & b;
        4'hC: f = 4'b1111;
        4'hD: f = a | ~b;
        4'hE: f = a | b;
        4'hF: f = a;
      endcase
      cn4_n = 1'b1;
    end else begin
      // Arithmetic Modes
      case (s)
        4'h0: arith_res = a + cin;
        4'h1: arith_res = (a | b) + cin;
        4'h2: arith_res = (a | ~b) + cin;
        4'h3: arith_res = 5'h1F + cin; // -1 + cin
        4'h4: arith_res = a + (a & ~b) + cin;
        4'h5: arith_res = (a | b) + (a & ~b) + cin;
        4'h6: arith_res = a - b - 1'b1 + cin;
        4'h7: arith_res = (a & ~b) - 1'b1 + cin;
        4'h8: arith_res = a + (a & b) + cin;
        4'h9: arith_res = a + b + cin;
        4'hA: arith_res = (a | ~b) + (a & b) + cin;
        4'hB: arith_res = (a & b) - 1'b1 + cin;
        4'hC: arith_res = a + a + cin;
        4'hD: arith_res = (a | b) + a + cin;
        4'hE: arith_res = (a | ~b) + a + cin;
        4'hF: arith_res = a - 1'b1 + cin;
      endcase
      f     = arith_res[3:0];
      cn4_n = ~arith_res[4];
    end
  end

  assign a_eq_b = (f == 4'b1111);
  assign p      = &((a | b) & s);
  assign g      = (a & b) | (a & ~s);
endmodule

`endif // ARITHMETIC_ALU_VRTL_ALU_74XX181_SV
