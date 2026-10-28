`ifndef VRTL_ARITHMETIC_SV
`define VRTL_ARITHMETIC_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Non-Parametric Ripple Adders & Subtractors
// =============================================================================

/*
// Instance Example:
vrtl_half_adder u_vrtl_half_adder (
    .a    (a),
    .b    (b),
    .sum  (sum),
    .cout (cout)
);
*/
module vrtl_half_adder (
    input  logic a,
    input  logic b,
    output logic sum,
    output logic cout
);
  assign sum  = a ^ b;
  assign cout = a & b;
endmodule


/*
// Instance Example:
vrtl_full_adder u_vrtl_full_adder (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
module vrtl_full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
  assign sum  = a ^ b ^ cin;
  assign cout = (a & b) | (cin & (a ^ b));
endmodule


/*
// Instance Example:
vrtl_adder_4b u_vrtl_adder_4b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
module vrtl_adder_4b (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);
  wire [4:0] c;
  assign c[0] = cin;
  assign cout = c[4];

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : gen_fa
      vrtl_full_adder fa (
          .a    (a[i]),
          .b    (b[i]),
          .cin  (c[i]),
          .sum  (sum[i]),
          .cout (c[i+1])
      );
    end
  endgenerate
endmodule


/*
// Instance Example:
vrtl_adder_8b u_vrtl_adder_8b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
module vrtl_adder_8b (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       cin,
    output logic [7:0] sum,
    output logic       cout
);
  assign {cout, sum} = a + b + cin;
endmodule


/*
// Instance Example:
vrtl_adder_16b u_vrtl_adder_16b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
module vrtl_adder_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  assign {cout, sum} = a + b + cin;
endmodule


/*
// Instance Example:
vrtl_adder_32b u_vrtl_adder_32b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
module vrtl_adder_32b (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        cin,
    output logic [31:0] sum,
    output logic        cout
);
  assign {cout, sum} = a + b + cin;
endmodule


/*
// Instance Example:
vrtl_subtractor_4b u_vrtl_subtractor_4b (
    .a    (a),
    .b    (b),
    .bin  (bin),
    .diff (diff),
    .bout (bout)
);
*/
module vrtl_subtractor_4b (
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       bin,
    output logic [3:0] diff,
    output logic       bout
);
  assign {bout, diff} = a - b - bin;
endmodule


/*
// Instance Example:
vrtl_subtractor_8b u_vrtl_subtractor_8b (
    .a    (a),
    .b    (b),
    .bin  (bin),
    .diff (diff),
    .bout (bout)
);
*/
module vrtl_subtractor_8b (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       bin,
    output logic [7:0] diff,
    output logic       bout
);
  assign {bout, diff} = a - b - bin;
endmodule


/*
// Instance Example:
vrtl_subtractor_16b u_vrtl_subtractor_16b (
    .a    (a),
    .b    (b),
    .bin  (bin),
    .diff (diff),
    .bout (bout)
);
*/
module vrtl_subtractor_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        bin,
    output logic [15:0] diff,
    output logic        bout
);
  assign {bout, diff} = a - b - bin;
endmodule


/*
// Instance Example:
vrtl_cla_16b u_vrtl_cla_16b (
    .a    (a),
    .b    (b),
    .cin  (cin),
    .sum  (sum),
    .cout (cout)
);
*/
module vrtl_cla_16b (
    input  logic [15:0] a,
    input  logic [15:0] b,
    input  logic        cin,
    output logic [15:0] sum,
    output logic        cout
);
  logic [15:0] p, g;
  logic [16:0] c;

  assign p = a ^ b;
  assign g = a & b;
  assign c[0] = cin;

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_cla
      assign c[i+1]  = g[i] | (p[i] & c[i]);
      assign sum[i]  = p[i] ^ c[i];
    end
  endgenerate

  assign cout = c[16];
endmodule


// =============================================================================
// Classic 74xx181 4-bit ALU
// =============================================================================

/*
// Instance Example:
vrtl_alu_74xx181 u_vrtl_alu_74xx181 (
    .s    (s),
    .a    (a),
    .b    (b),
    .m    (m),
    .cn_n (cn_n),
    .f    (f),
    .cn4_n(cn4_n),
    .p    (p),
    .g    (g),
    .a_eq_b(a_eq_b)
);
*/
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


// =============================================================================
// Parametric Arithmetic & ALU
// =============================================================================

/*
// Instance Example:
vrtl_adder #(
    .WIDTH(16)
) u_vrtl_adder (
    .a        (a),
    .b        (b),
    .cin      (cin),
    .sum      (sum),
    .cout     (cout),
    .overflow (overflow)
);
*/
module vrtl_adder #(
    parameter int WIDTH = 16
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             cin,
    output logic [WIDTH-1:0] sum,
    output logic             cout,
    output logic             overflow
);
  assign {cout, sum} = a + b + cin;
  assign overflow    = (a[WIDTH-1] == b[WIDTH-1]) && (sum[WIDTH-1] != a[WIDTH-1]);
endmodule


/*
// Instance Example:
vrtl_subtractor #(
    .WIDTH(16)
) u_vrtl_subtractor (
    .a    (a),
    .b    (b),
    .bin  (bin),
    .diff (diff),
    .bout (bout)
);
*/
module vrtl_subtractor #(
    parameter int WIDTH = 16
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             bin,
    output logic [WIDTH-1:0] diff,
    output logic             bout
);
  assign {bout, diff} = a - b - bin;
endmodule


/*
// Instance Example:
vrtl_adder_subtractor #(
    .WIDTH(16)
) u_vrtl_adder_subtractor (
    .sub      (sub),
    .a        (a),
    .b        (b),
    .result   (result),
    .carry_out(carry_out),
    .overflow (overflow)
);
*/
module vrtl_adder_subtractor #(
    parameter int WIDTH = 16
)(
    input  logic             sub,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] result,
    output logic             carry_out,
    output logic             overflow
);
  logic [WIDTH-1:0] b_inv;
  assign b_inv = sub ? ~b : b;
  assign {carry_out, result} = a + b_inv + sub;
  assign overflow = (a[WIDTH-1] == b_inv[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);
endmodule


/*
// Instance Example:
vrtl_multiplier #(
    .WIDTH_A(8),
    .WIDTH_B(8),
    .SIGNED(0)
) u_vrtl_multiplier (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
module vrtl_multiplier #(
    parameter int WIDTH_A = 8,
    parameter int WIDTH_B = 8,
    parameter bit SIGNED  = 0
)(
    input  logic [WIDTH_A-1:0]             a,
    input  logic [WIDTH_B-1:0]             b,
    output logic [WIDTH_A+WIDTH_B-1:0]     product
);
  always_comb begin
    if (SIGNED) begin
      product = $signed(a) * $signed(b);
    end else begin
      product = a * b;
    end
  end
endmodule


/*
// Instance Example:
vrtl_alu #(
    .WIDTH(32)
) u_vrtl_alu (
    .op       (op),
    .a        (a),
    .b        (b),
    .result   (result),
    .zero     (zero),
    .negative (negative),
    .carry    (carry),
    .overflow (overflow)
);
*/
module vrtl_alu #(
    parameter int WIDTH = 32
)(
    input  logic [3:0]       op,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] result,
    output logic             zero,
    output logic             negative,
    output logic             carry,
    output logic             overflow
);
  localparam [3:0] OP_ADD  = 4'b0000;
  localparam [3:0] OP_SUB  = 4'b0001;
  localparam [3:0] OP_AND  = 4'b0010;
  localparam [3:0] OP_OR   = 4'b0011;
  localparam [3:0] OP_XOR  = 4'b0100;
  localparam [3:0] OP_NOR  = 4'b0101;
  localparam [3:0] OP_NOT  = 4'b0110;
  localparam [3:0] OP_SLL  = 4'b0111;
  localparam [3:0] OP_SRL  = 4'b1000;
  localparam [3:0] OP_SRA  = 4'b1001;
  localparam [3:0] OP_SLT  = 4'b1010;
  localparam [3:0] OP_SLTU = 4'b1011;

  logic [WIDTH:0] ext_res;

  always_comb begin
    ext_res  = '0;
    carry    = 1'b0;
    overflow = 1'b0;

    case (op)
      OP_ADD: begin
        ext_res  = {1'b0, a} + {1'b0, b};
        carry    = ext_res[WIDTH];
        overflow = (a[WIDTH-1] == b[WIDTH-1]) && (ext_res[WIDTH-1] != a[WIDTH-1]);
      end
      OP_SUB: begin
        ext_res  = {1'b0, a} - {1'b0, b};
        carry    = ext_res[WIDTH];
        overflow = (a[WIDTH-1] != b[WIDTH-1]) && (ext_res[WIDTH-1] != a[WIDTH-1]);
      end
      OP_AND:  ext_res = {1'b0, a & b};
      OP_OR:   ext_res = {1'b0, a | b};
      OP_XOR:  ext_res = {1'b0, a ^ b};
      OP_NOR:  ext_res = {1'b0, ~(a | b)};
      OP_NOT:  ext_res = {1'b0, ~a};
      OP_SLL:  ext_res = {1'b0, a << b[$clog2(WIDTH)-1:0]};
      OP_SRL:  ext_res = {1'b0, a >> b[$clog2(WIDTH)-1:0]};
      OP_SRA: begin
        logic [WIDTH-1:0] sra_res;
        sra_res  = $signed(a) >>> b[$clog2(WIDTH)-1:0];
        ext_res  = {1'b0, sra_res};
      end
      OP_SLT:  ext_res = {1'b0, {{(WIDTH-1){1'b0}}, ($signed(a) < $signed(b))}};
      OP_SLTU: ext_res = {1'b0, {{(WIDTH-1){1'b0}}, (a < b)}};
      default: ext_res = '0;
    endcase
  end

  assign result   = ext_res[WIDTH-1:0];
  assign zero     = (result == '0);
  assign negative = result[WIDTH-1];
endmodule

`endif // VRTL_ARITHMETIC_SV
