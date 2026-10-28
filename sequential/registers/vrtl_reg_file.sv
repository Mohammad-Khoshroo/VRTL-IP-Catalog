`ifndef SEQUENTIAL_REGISTERS_VRTL_REG_FILE_SV
`define SEQUENTIAL_REGISTERS_VRTL_REG_FILE_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_reg_file #(
//     .DATA_WIDTH (32),
//     .DEPTH      (32),
//     .ZERO_REG0  (1)
// ) u_vrtl_reg_file (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .wr_en    (wr_en),
//     .wr_addr  (wr_addr),
//     .wr_data  (wr_data),
//     .rd_addr0 (rd_addr0),
//     .rd_data0 (rd_data0),
//     .rd_addr1 (rd_addr1),
//     .rd_data1 (rd_data1)
// );
// =============================================================================
module vrtl_reg_file #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 32,
    parameter bit ZERO_REG0  = 1,
    localparam int ADDR_W    = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic [ADDR_W-1:0]     wr_addr,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic [ADDR_W-1:0]     rd_addr0,
    output logic [DATA_WIDTH-1:0] rd_data0,
    input  logic [ADDR_W-1:0]     rd_addr1,
    output logic [DATA_WIDTH-1:0] rd_data1
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < DEPTH; i = i + 1) begin
        mem[i] <= '0;
      end
    end else if (wr_en) begin
      if (!(ZERO_REG0 && wr_addr == '0)) begin
        mem[wr_addr] <= wr_data;
      end
    end
  end

  always_comb begin
    rd_data0 = (ZERO_REG0 && rd_addr0 == '0) ? '0 : mem[rd_addr0];
    rd_data1 = (ZERO_REG0 && rd_addr1 == '0) ? '0 : mem[rd_addr1];
  end
endmodule


// =============================================================================
// vrtl_reg_file_3r2w #(
//     .DATA_WIDTH (32),
//     .DEPTH      (32),
//     .ZERO_REG0  (1)
// ) u_vrtl_reg_file_3r2w (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .wr_en0   (wr_en0),
//     .wr_addr0 (wr_addr0),
//     .wr_data0 (wr_data0),
//     .wr_en1   (wr_en1),
//     .wr_addr1 (wr_addr1),
//     .wr_data1 (wr_data1),
//     .rd_addr0 (rd_addr0),
//     .rd_data0 (rd_data0),
//     .rd_addr1 (rd_addr1),
//     .rd_data1 (rd_data1),
//     .rd_addr2 (rd_addr2),
//     .rd_data2 (rd_data2)
// );
// =============================================================================
module vrtl_reg_file_3r2w #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 32,
    parameter bit ZERO_REG0  = 1,
    localparam int ADDR_W    = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Write Port 0
    input  logic                  wr_en0,
    input  logic [ADDR_W-1:0]     wr_addr0,
    input  logic [DATA_WIDTH-1:0] wr_data0,

    // Write Port 1
    input  logic                  wr_en1,
    input  logic [ADDR_W-1:0]     wr_addr1,
    input  logic [DATA_WIDTH-1:0] wr_data1,

    // Read Port 0
    input  logic [ADDR_W-1:0]     rd_addr0,
    output logic [DATA_WIDTH-1:0] rd_data0,

    // Read Port 1
    input  logic [ADDR_W-1:0]     rd_addr1,
    output logic [DATA_WIDTH-1:0] rd_data1,

    // Read Port 2
    input  logic [ADDR_W-1:0]     rd_addr2,
    output logic [DATA_WIDTH-1:0] rd_data2
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < DEPTH; i = i + 1) begin
        mem[i] <= '0;
      end
    end else begin
      if (wr_en0 && !(ZERO_REG0 && wr_addr0 == '0)) begin
        mem[wr_addr0] <= wr_data0;
      end
      if (wr_en1 && !(ZERO_REG0 && wr_addr1 == '0)) begin
        mem[wr_addr1] <= wr_data1;
      end
    end
  end

  always_comb begin
    rd_data0 = (ZERO_REG0 && rd_addr0 == '0) ? '0 : mem[rd_addr0];
    rd_data1 = (ZERO_REG0 && rd_addr1 == '0) ? '0 : mem[rd_addr1];
    rd_data2 = (ZERO_REG0 && rd_addr2 == '0) ? '0 : mem[rd_addr2];
  end
endmodule

`endif // SEQUENTIAL_REGISTERS_VRTL_REG_FILE_SV
