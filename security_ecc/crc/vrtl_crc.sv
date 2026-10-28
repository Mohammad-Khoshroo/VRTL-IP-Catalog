`ifndef SECURITY_ECC_CRC_VRTL_CRC_SV
`define SECURITY_ECC_CRC_VRTL_CRC_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_crc8 u_vrtl_crc8 (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .init_en   (init_en),
//     .data_en   (data_en),
//     .data_byte (data_byte),
//     .crc_out   (crc_out)
// );
// =============================================================================
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


// =============================================================================
// vrtl_crc16_ccitt u_vrtl_crc16_ccitt (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .init_en   (init_en),
//     .data_en   (data_en),
//     .data_byte (data_byte),
//     .crc_out   (crc_out)
// );
// =============================================================================
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


// =============================================================================
// vrtl_crc #(
//     .CRC_W (16),
//     .POLY  (16'h1021),
//     .INIT  (16'hFFFF)
// ) u_vrtl_crc (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .init_en (init_en),
//     .data_en (data_en),
//     .bit_in  (bit_in),
//     .crc_out (crc_out)
// );
// =============================================================================
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


// =============================================================================
// vrtl_crc32 u_vrtl_crc32 (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .init_en   (init_en),
//     .data_en   (data_en),
//     .data_byte (data_byte),
//     .crc_out   (crc_out)
// );
// =============================================================================
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

`endif // SECURITY_ECC_CRC_VRTL_CRC_SV
