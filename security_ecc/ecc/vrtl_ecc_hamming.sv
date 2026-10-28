`ifndef SECURITY_ECC_ECC_VRTL_ECC_HAMMING_SV
`define SECURITY_ECC_ECC_VRTL_ECC_HAMMING_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_hamming_enc_4b u_vrtl_hamming_enc_4b (
//     .data_in  (data_in),
//     .code_out (code_out)
// );
// =============================================================================
module vrtl_hamming_enc_4b (
    input  logic [3:0] data_in,
    output logic [6:0] code_out // [6:0] = {d3, d2, d1, p4, d0, p2, p1}
);
  logic p1, p2, p4;

  assign p1 = data_in[0] ^ data_in[1] ^ data_in[3];
  assign p2 = data_in[0] ^ data_in[2] ^ data_in[3];
  assign p4 = data_in[1] ^ data_in[2] ^ data_in[3];

  assign code_out = {data_in[3:1], p4, data_in[0], p2, p1};
endmodule


// =============================================================================
// vrtl_hamming_dec_4b u_vrtl_hamming_dec_4b (
//     .code_in  (code_in),
//     .data_out (data_out),
//     .err      (err)
// );
// =============================================================================
module vrtl_hamming_dec_4b (
    input  logic [6:0] code_in,
    output logic [3:0] data_out,
    output logic       err
);
  logic [2:0] syn;
  logic [6:0] corrected;

  assign syn[0] = code_in[0] ^ code_in[2] ^ code_in[4] ^ code_in[6];
  assign syn[1] = code_in[1] ^ code_in[2] ^ code_in[5] ^ code_in[6];
  assign syn[2] = code_in[3] ^ code_in[4] ^ code_in[5] ^ code_in[6];

  always_comb begin
    corrected = code_in;
    if (syn != 3'b000) begin
      corrected[syn - 1] = ~corrected[syn - 1];
    end
  end

  assign data_out = {corrected[6:4], corrected[2]};
  assign err      = (syn != 3'b000);
endmodule


// =============================================================================
// vrtl_hamming_enc_8b u_vrtl_hamming_enc_8b (
//     .data_in  (data_in),
//     .code_out (code_out)
// );
// =============================================================================
module vrtl_hamming_enc_8b (
    input  logic [7:0]  data_in,
    output logic [12:0] code_out
);
  logic p1, p2, p4, p8, p_all;

  assign p1 = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[6];
  assign p2 = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6];
  assign p4 = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7];
  assign p8 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

  wire [11:0] code_12 = {data_in[7:4], p8, data_in[3:1], p4, data_in[0], p2, p1};
  assign p_all = ^code_12;
  assign code_out = {p_all, code_12};
endmodule


// =============================================================================
// vrtl_hamming_dec_8b u_vrtl_hamming_dec_8b (
//     .code_in    (code_in),
//     .data_out   (data_out),
//     .single_err (single_err),
//     .double_err (double_err)
// );
// =============================================================================
module vrtl_hamming_dec_8b (
    input  logic [12:0] code_in,
    output logic [7:0]  data_out,
    output logic        single_err,
    output logic        double_err
);
  logic [3:0] syn;
  logic p_all_calc;
  logic [11:0] corrected_code;

  assign syn[0] = code_in[0] ^ code_in[2] ^ code_in[4] ^ code_in[6] ^ code_in[8] ^ code_in[10];
  assign syn[1] = code_in[1] ^ code_in[2] ^ code_in[5] ^ code_in[6] ^ code_in[9] ^ code_in[10];
  assign syn[2] = code_in[3] ^ code_in[4] ^ code_in[5] ^ code_in[6] ^ code_in[11];
  assign syn[3] = code_in[7] ^ code_in[8] ^ code_in[9] ^ code_in[10] ^ code_in[11];

  assign p_all_calc = ^code_in;

  always_comb begin
    corrected_code = code_in[11:0];
    if (syn != 4'b0000 && syn <= 4'd12) begin
      corrected_code[syn - 1] = ~corrected_code[syn - 1];
    end
  end

  assign data_out = {corrected_code[11:8], corrected_code[6:4], corrected_code[2]};
  assign single_err = p_all_calc && (syn != 4'b0000);
  assign double_err = !p_all_calc && (syn != 4'b0000);
endmodule


// =============================================================================
// vrtl_hamming_enc_32b u_vrtl_hamming_enc_32b (
//     .data_in  (data_in),
//     .code_out (code_out)
// );
// =============================================================================
module vrtl_hamming_enc_32b (
    input  logic [31:0] data_in,
    output logic [38:0] code_out
);
  logic [5:0] p;
  logic p_all;
  logic [37:0] code_raw;

  always_comb begin
    p[0] = data_in[0]^data_in[1]^data_in[3]^data_in[4]^data_in[6]^data_in[8]^data_in[10]^data_in[11]^data_in[13]^data_in[15]^data_in[17]^data_in[19]^data_in[21]^data_in[23]^data_in[25]^data_in[26]^data_in[28]^data_in[30];
    p[1] = data_in[0]^data_in[2]^data_in[3]^data_in[5]^data_in[6]^data_in[9]^data_in[10]^data_in[12]^data_in[13]^data_in[16]^data_in[17]^data_in[20]^data_in[21]^data_in[24]^data_in[25]^data_in[27]^data_in[28]^data_in[31];
    p[2] = data_in[1]^data_in[2]^data_in[3]^data_in[7]^data_in[8]^data_in[9]^data_in[10]^data_in[14]^data_in[15]^data_in[16]^data_in[17]^data_in[22]^data_in[23]^data_in[24]^data_in[25]^data_in[29]^data_in[30]^data_in[31];
    p[3] = data_in[4]^data_in[5]^data_in[6]^data_in[7]^data_in[8]^data_in[9]^data_in[10]^data_in[18]^data_in[19]^data_in[20]^data_in[21]^data_in[22]^data_in[23]^data_in[24]^data_in[25];
    p[4] = data_in[11]^data_in[12]^data_in[13]^data_in[14]^data_in[15]^data_in[16]^data_in[17]^data_in[18]^data_in[19]^data_in[20]^data_in[21]^data_in[22]^data_in[23]^data_in[24]^data_in[25];
    p[5] = data_in[26]^data_in[27]^data_in[28]^data_in[29]^data_in[30]^data_in[31];

    code_raw = {data_in[31:26], p[5], data_in[25:11], p[4], data_in[10:4], p[3], data_in[3:1], p[2], data_in[0], p[1], p[0]};
    p_all = ^code_raw;
    code_out = {p_all, code_raw};
  end
endmodule


// =============================================================================
// vrtl_hamming_dec_32b u_vrtl_hamming_dec_32b (
//     .code_in    (code_in),
//     .data_out   (data_out),
//     .single_err (single_err),
//     .double_err (double_err)
// );
// =============================================================================
module vrtl_hamming_dec_32b (
    input  logic [38:0] code_in,
    output logic [31:0] data_out,
    output logic        single_err,
    output logic        double_err
);
  logic [5:0] syn;
  logic p_all_calc;
  logic [37:0] corrected;

  always_comb begin
    syn = '0;
    for (int i = 0; i < 38; i = i + 1) begin
      if (code_in[i]) begin
        syn = syn ^ 6'(i + 1);
      end
    end

    p_all_calc = ^code_in;
    corrected  = code_in[37:0];

    if (syn != 6'd0 && syn <= 6'd38) begin
      corrected[syn - 1] = ~corrected[syn - 1];
    end

    data_out = {corrected[37:32], corrected[30:16], corrected[14:8], corrected[6:4], corrected[2]};
    single_err = p_all_calc && (syn != 6'd0);
    double_err = !p_all_calc && (syn != 6'd0);
  end
endmodule

`endif // SECURITY_ECC_ECC_VRTL_ECC_HAMMING_SV
