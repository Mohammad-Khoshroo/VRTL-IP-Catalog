`ifndef VRTL_ECC_CRC_SV
`define VRTL_ECC_CRC_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Hamming Code SEC / SECDED
// =============================================================================

/*
// Instance Example:
vrtl_hamming_enc_4b u_vrtl_hamming_enc_4b (
    .data_in  (data_in),
    .code_out (code_out)
);
*/
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


/*
// Instance Example:
vrtl_hamming_dec_4b u_vrtl_hamming_dec_4b (
    .code_in  (code_in),
    .data_out (data_out),
    .err      (err)
);
*/
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


/*
// Instance Example:
vrtl_hamming_enc_8b u_vrtl_hamming_enc_8b (
    .data_in  (data_in),
    .code_out (code_out)
);
*/
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


/*
// Instance Example:
vrtl_hamming_dec_8b u_vrtl_hamming_dec_8b (
    .code_in    (code_in),
    .data_out   (data_out),
    .single_err (single_err),
    .double_err (double_err)
);
*/
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


/*
// Instance Example:
vrtl_hamming_enc_32b u_vrtl_hamming_enc_32b (
    .data_in  (data_in),
    .code_out (code_out)
);
*/
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


/*
// Instance Example:
vrtl_hamming_dec_32b u_vrtl_hamming_dec_32b (
    .code_in    (code_in),
    .data_out   (data_out),
    .single_err (single_err),
    .double_err (double_err)
);
*/
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


// =============================================================================
// Cyclic Redundancy Check (CRC)
// =============================================================================

/*
// Instance Example:
vrtl_crc8 u_vrtl_crc8 (
    .clk       (clk),
    .rst_n     (rst_n),
    .init_en   (init_en),
    .data_en   (data_en),
    .data_byte (data_byte),
    .crc_out   (crc_out)
);
*/
module vrtl_crc8 (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       init_en,
    input  logic       data_en,
    input  logic [7:0] data_byte,
    output logic [7:0] crc_out
);
  logic [7:0] crc_reg;
  logic [7:0] next_crc;

  always_comb begin
    next_crc = crc_reg ^ data_byte;
    for (int i = 0; i < 8; i = i + 1) begin
      if (next_crc[7]) begin
        next_crc = (next_crc << 1) ^ 8'h07;
      end else begin
        next_crc = next_crc << 1;
      end
    end
  end

  assign crc_out = crc_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      crc_reg <= 8'h00;
    end else if (init_en) begin
      crc_reg <= 8'h00;
    end else if (data_en) begin
      crc_reg <= next_crc;
    end
  end
endmodule


/*
// Instance Example:
vrtl_crc16_ccitt u_vrtl_crc16_ccitt (
    .clk       (clk),
    .rst_n     (rst_n),
    .init_en   (init_en),
    .data_en   (data_en),
    .data_byte (data_byte),
    .crc_out   (crc_out)
);
*/
module vrtl_crc16_ccitt (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        init_en,
    input  logic        data_en,
    input  logic [7:0]  data_byte,
    output logic [15:0] crc_out
);
  logic [15:0] crc_reg;
  logic [15:0] next_crc;

  always_comb begin
    next_crc = crc_reg ^ {data_byte, 8'h00};
    for (int i = 0; i < 8; i = i + 1) begin
      if (next_crc[15]) begin
        next_crc = (next_crc << 1) ^ 16'h1021;
      end else begin
        next_crc = next_crc << 1;
      end
    end
  end

  assign crc_out = crc_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      crc_reg <= 16'hFFFF;
    end else if (init_en) begin
      crc_reg <= 16'hFFFF;
    end else if (data_en) begin
      crc_reg <= next_crc;
    end
  end
endmodule


/*
// Instance Example:
vrtl_crc #(
    .CRC_W(16),
    .POLY(16'h1021),
    .INIT(16'hFFFF)
) u_vrtl_crc (
    .clk     (clk),
    .rst_n   (rst_n),
    .init_en (init_en),
    .data_en (data_en),
    .bit_in  (bit_in),
    .crc_out (crc_out)
);
*/
module vrtl_crc #(
    parameter int CRC_W = 16,
    parameter logic [CRC_W-1:0] POLY = 16'h1021,
    parameter logic [CRC_W-1:0] INIT = 16'hFFFF
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             init_en,
    input  logic             data_en,
    input  logic             bit_in,
    output logic [CRC_W-1:0] crc_out
);
  logic [CRC_W-1:0] crc_reg;
  wire fb = bit_in ^ crc_reg[CRC_W-1];

  assign crc_out = crc_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      crc_reg <= INIT;
    end else if (init_en) begin
      crc_reg <= INIT;
    end else if (data_en) begin
      crc_reg <= {crc_reg[CRC_W-2:0], 1'b0} ^ (fb ? POLY : '0);
    end
  end
endmodule


/*
// Instance Example:
vrtl_crc32 u_vrtl_crc32 (
    .clk       (clk),
    .rst_n     (rst_n),
    .init_en   (init_en),
    .data_en   (data_en),
    .data_byte (data_byte),
    .crc_out   (crc_out)
);
*/
module vrtl_crc32 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        init_en,
    input  logic        data_en,
    input  logic [7:0]  data_byte,
    output logic [31:0] crc_out
);
  logic [31:0] crc_reg;
  logic [31:0] next_crc;

  always_comb begin
    next_crc = crc_reg;
    for (int i = 0; i < 8; i = i + 1) begin
      if (data_byte[i] ^ next_crc[31]) begin
        next_crc = (next_crc << 1) ^ 32'h04C1_1DB7;
      end else begin
        next_crc = next_crc << 1;
      end
    end
  end

  assign crc_out = ~crc_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      crc_reg <= 32'hFFFF_FFFF;
    end else if (init_en) begin
      crc_reg <= 32'hFFFF_FFFF;
    end else if (data_en) begin
      crc_reg <= next_crc;
    end
  end
endmodule

`endif // VRTL_ECC_CRC_SV
