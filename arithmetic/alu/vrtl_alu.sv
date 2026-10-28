`ifndef ARITHMETIC_ALU_VRTL_ALU_SV
`define ARITHMETIC_ALU_VRTL_ALU_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_alu #(
//     .WIDTH (32)
// ) u_vrtl_alu (
//     .op       (op),
//     .a        (a),
//     .b        (b),
//     .result   (result),
//     .zero     (zero),
//     .negative (negative),
//     .carry    (carry),
//     .overflow (overflow)
// );
// =============================================================================
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

`endif // ARITHMETIC_ALU_VRTL_ALU_SV
