`ifndef VRTL_FIFO_ASYNC_SV
`define VRTL_FIFO_ASYNC_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Dual-Clock Asynchronous FIFO (Cummings Architecture)
// =============================================================================

/*
// Instance Example:
vrtl_fifo_async_16x8 u_vrtl_fifo_async_16x8 (
    .wr_clk   (wr_clk),
    .wr_rst_n (wr_rst_n),
    .wr_en    (wr_en),
    .wr_data  (wr_data),
    .full     (full),
    .rd_clk   (rd_clk),
    .rd_rst_n (rd_rst_n),
    .rd_en    (rd_en),
    .rd_data  (rd_data),
    .empty    (empty)
);
*/
module vrtl_fifo_async_16x8 (
    input  logic       wr_clk,
    input  logic       wr_rst_n,
    input  logic       wr_en,
    input  logic [7:0] wr_data,
    output logic       full,

    input  logic       rd_clk,
    input  logic       rd_rst_n,
    input  logic       rd_en,
    output logic [7:0] rd_data,
    output logic       empty
);
  vrtl_fifo_async #(
      .DATA_WIDTH(8),
      .DEPTH(16)
  ) u_async_fifo (
      .wr_clk   (wr_clk),
      .wr_rst_n (wr_rst_n),
      .wr_en    (wr_en),
      .wr_data  (wr_data),
      .full     (full),
      .rd_clk   (rd_clk),
      .rd_rst_n (rd_rst_n),
      .rd_en    (rd_en),
      .rd_data  (rd_data),
      .empty    (empty)
  );
endmodule


/*
// Instance Example:
vrtl_fifo_async #(
    .DATA_WIDTH(32),
    .DEPTH(16)
) u_vrtl_fifo_async (
    .wr_clk    (wr_clk),
    .wr_rst_n  (wr_rst_n),
    .wr_en     (wr_en),
    .wr_data   (wr_data),
    .full      (full),
    .rd_clk    (rd_clk),
    .rd_rst_n  (rd_rst_n),
    .rd_en     (rd_en),
    .rd_data   (rd_data),
    .empty     (empty)
);
*/
module vrtl_fifo_async #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16,
    localparam int ADDR_W    = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    // Write Domain
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  full,

    // Read Domain
    input  logic                  rd_clk,
    input  logic                  rd_rst_n,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  empty
);
  // Memory Array
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  // Pointers (width = ADDR_W + 1 for wrap-around detection)
  logic [ADDR_W:0] wr_bin, wr_gray;
  logic [ADDR_W:0] rd_bin, rd_gray;

  // Cross-domain synchronizers
  (* ASYNC_REG = "TRUE" *) logic [ADDR_W:0] rd_gray_sync1, rd_gray_sync2;
  (* ASYNC_REG = "TRUE" *) logic [ADDR_W:0] wr_gray_sync1, wr_gray_sync2;

  // Memory write
  always_ff @(posedge wr_clk) begin
    if (wr_en && !full) begin
      mem[wr_bin[ADDR_W-1:0]] <= wr_data;
    end
  end

  // Write pointer logic & Gray conversion
  always_ff @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
      wr_bin  <= '0;
      wr_gray <= '0;
    end else if (wr_en && !full) begin
      wr_bin  <= wr_bin + 1'b1;
      wr_gray <= (wr_bin + 1'b1) ^ ((wr_bin + 1'b1) >> 1);
    end
  end

  // Synchronize read pointer into write clock domain
  always_ff @(posedge wr_clk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
      rd_gray_sync1 <= '0;
      rd_gray_sync2 <= '0;
    end else begin
      rd_gray_sync1 <= rd_gray;
      rd_gray_sync2 <= rd_gray_sync1;
    end
  end

  // Full condition: MSB & 2nd MSB different, remaining bits match
  assign full = (wr_gray == {~rd_gray_sync2[ADDR_W:ADDR_W-1], rd_gray_sync2[ADDR_W-2:0]});

  // Memory read
  always_ff @(posedge rd_clk) begin
    if (rd_en && !empty) begin
      rd_data <= mem[rd_bin[ADDR_W-1:0]];
    end
  end

  // Read pointer logic & Gray conversion
  always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
      rd_bin  <= '0;
      rd_gray <= '0;
    end else if (rd_en && !empty) begin
      rd_bin  <= rd_bin + 1'b1;
      rd_gray <= (rd_bin + 1'b1) ^ ((rd_bin + 1'b1) >> 1);
    end
  end

  // Synchronize write pointer into read clock domain
  always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
      wr_gray_sync1 <= '0;
      wr_gray_sync2 <= '0;
    end else begin
      wr_gray_sync1 <= wr_gray;
      wr_gray_sync2 <= wr_gray_sync1;
    end
  end

  // Empty condition: write and read Gray pointers are completely equal
  assign empty = (rd_gray == wr_gray_sync2);

  `VRTL_ASSERT_NEVER(a_async_overflow,  (wr_en && full),  wr_clk, wr_rst_n, "Async FIFO write overflow");
  `VRTL_ASSERT_NEVER(a_async_underflow, (rd_en && empty), rd_clk, rd_rst_n, "Async FIFO read underflow");

endmodule


/*
// Instance Example:
vrtl_fifo_async_fwft #(
    .DATA_WIDTH(32),
    .DEPTH(16)
) u_vrtl_fifo_async_fwft (
    .wr_clk   (wr_clk),
    .wr_rst_n (wr_rst_n),
    .wr_en    (wr_en),
    .wr_data  (wr_data),
    .full     (full),
    .rd_clk   (rd_clk),
    .rd_rst_n (rd_rst_n),
    .rd_en    (rd_en),
    .rd_data  (rd_data),
    .empty    (empty)
);
*/
module vrtl_fifo_async_fwft #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16
)(
    input  logic                  wr_clk,
    input  logic                  wr_rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  full,

    input  logic                  rd_clk,
    input  logic                  rd_rst_n,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  empty
);
  logic [DATA_WIDTH-1:0] inner_dout;
  logic inner_empty, inner_rd_en;
  logic valid;

  vrtl_fifo_async #(
      .DATA_WIDTH(DATA_WIDTH),
      .DEPTH(DEPTH)
  ) u_async_fifo (
      .wr_clk   (wr_clk),
      .wr_rst_n (wr_rst_n),
      .wr_en    (wr_en),
      .wr_data  (wr_data),
      .full     (full),
      .rd_clk   (rd_clk),
      .rd_rst_n (rd_rst_n),
      .rd_en    (inner_rd_en),
      .rd_data  (inner_dout),
      .empty    (inner_empty)
  );

  assign empty       = !valid;
  assign inner_rd_en = !inner_empty && (!valid || rd_en);

  always_ff @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
      valid   <= 1'b0;
      rd_data <= '0;
    end else begin
      if (inner_rd_en) begin
        valid   <= 1'b1;
        rd_data <= inner_dout;
      end else if (rd_en) begin
        valid   <= 1'b0;
      end
    end
  end
endmodule

`endif // VRTL_FIFO_ASYNC_SV
