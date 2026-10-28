`ifndef VRTL_FIFO_SV
`define VRTL_FIFO_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// -----------------------------------------------------------------------------
// Non-Parametric Synchronous FIFO
// -----------------------------------------------------------------------------

/*
// Instance Example:
vrtl_fifo_sync_16x8 u_vrtl_fifo_sync_16x8 (
    .clk          (clk),
    .rst_n        (rst_n),
    .wr_en        (wr_en),
    .wr_data      (wr_data),
    .rd_en        (rd_en),
    .rd_data      (rd_data),
    .full         (full),
    .empty        (empty),
    .almost_full  (almost_full),
    .almost_empty (almost_empty),
    .count        (count)
);
*/
module vrtl_fifo_sync_16x8 (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       wr_en,
    input  logic [7:0] wr_data,
    input  logic       rd_en,
    output logic [7:0] rd_data,
    output logic       full,
    output logic       empty,
    output logic       almost_full,
    output logic       almost_empty,
    output logic [4:0] count
);
  vrtl_fifo_sync #(
      .DATA_WIDTH(8),
      .DEPTH(16),
      .ALMOST_FULL_THRESH(14),
      .ALMOST_EMPTY_THRESH(2)
  ) u_fifo (
      .clk          (clk),
      .rst_n        (rst_n),
      .wr_en        (wr_en),
      .wr_data      (wr_data),
      .rd_en        (rd_en),
      .rd_data      (rd_data),
      .full         (full),
      .empty        (empty),
      .almost_full  (almost_full),
      .almost_empty (almost_empty),
      .count        (count)
  );
endmodule


/*
// Instance Example:
vrtl_fifo_reg_2depth #(
    .DATA_WIDTH(32)
) u_vrtl_fifo_reg_2depth (
    .clk     (clk),
    .rst_n   (rst_n),
    .wr_en   (wr_en),
    .wr_data (wr_data),
    .rd_en   (rd_en),
    .rd_data (rd_data),
    .full    (full),
    .empty   (empty)
);
*/
module vrtl_fifo_reg_2depth #(
    parameter int DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  full,
    output logic                  empty
);
  logic [DATA_WIDTH-1:0] reg0, reg1;
  logic [1:0] count;

  assign empty   = (count == 2'd0);
  assign full    = (count == 2'd2);
  assign rd_data = reg0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg0  <= '0;
      reg1  <= '0;
      count <= 2'd0;
    end else begin
      case ({wr_en && !full, rd_en && !empty})
        2'b10: begin // Write only
          if (count == 2'd0) begin
            reg0 <= wr_data;
          end else begin
            reg1 <= wr_data;
          end
          count <= count + 1'b1;
        end
        2'b01: begin // Read only
          reg0  <= reg1;
          count <= count - 1'b1;
        end
        2'b11: begin // Simultaneous read and write
          if (count == 2'd1) begin
            reg0 <= wr_data;
          end else begin
            reg0 <= reg1;
            reg1 <= wr_data;
          end
        end
        default: ;
      endcase
    end
  end
endmodule


// -----------------------------------------------------------------------------
// Parametric Synchronous FIFO
// -----------------------------------------------------------------------------

/*
// Instance Example:
vrtl_fifo_sync #(
    .DATA_WIDTH(32),
    .DEPTH(16),
    .ALMOST_FULL_THRESH(14),
    .ALMOST_EMPTY_THRESH(2)
) u_vrtl_fifo_sync (
    .clk          (clk),
    .rst_n        (rst_n),
    .wr_en        (wr_en),
    .wr_data      (wr_data),
    .rd_en        (rd_en),
    .rd_data      (rd_data),
    .full         (full),
    .empty        (empty),
    .almost_full  (almost_full),
    .almost_empty (almost_empty),
    .count        (count)
);
*/
module vrtl_fifo_sync #(
    parameter int DATA_WIDTH          = 32,
    parameter int DEPTH               = 16,
    parameter int ALMOST_FULL_THRESH  = DEPTH - 2,
    parameter int ALMOST_EMPTY_THRESH = 2,
    localparam int ADDR_W             = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  full,
    output logic                  empty,
    output logic                  almost_full,
    output logic                  almost_empty,
    output logic [ADDR_W:0]       count
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];
  logic [ADDR_W-1:0] wr_ptr;
  logic [ADDR_W-1:0] rd_ptr;

  assign empty        = (count == '0);
  assign full         = (count == (ADDR_W+1)'(DEPTH));
  assign almost_empty = (count <= (ADDR_W+1)'(ALMOST_EMPTY_THRESH));
  assign almost_full  = (count >= (ADDR_W+1)'(ALMOST_FULL_THRESH));

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr  <= '0;
      rd_ptr  <= '0;
      count   <= '0;
      rd_data <= '0;
    end else begin
      case ({wr_en && !full, rd_en && !empty})
        2'b10: begin
          mem[wr_ptr] <= wr_data;
          wr_ptr      <= (wr_ptr == ADDR_W'(DEPTH - 1)) ? '0 : wr_ptr + 1'b1;
          count       <= count + 1'b1;
        end
        2'b01: begin
          rd_data <= mem[rd_ptr];
          rd_ptr  <= (rd_ptr == ADDR_W'(DEPTH - 1)) ? '0 : rd_ptr + 1'b1;
          count   <= count - 1'b1;
        end
        2'b11: begin
          mem[wr_ptr] <= wr_data;
          wr_ptr      <= (wr_ptr == ADDR_W'(DEPTH - 1)) ? '0 : wr_ptr + 1'b1;
          rd_data     <= mem[rd_ptr];
          rd_ptr      <= (rd_ptr == ADDR_W'(DEPTH - 1)) ? '0 : rd_ptr + 1'b1;
        end
        default: ;
      endcase
    end
  end

  `VRTL_ASSERT_NEVER(a_no_overflow,  (wr_en && full),  clk, rst_n, "FIFO write overflow attempted");
  `VRTL_ASSERT_NEVER(a_no_underflow, (rd_en && empty), clk, rst_n, "FIFO read underflow attempted");

endmodule


/*
// Instance Example:
vrtl_fifo_sync_prog #(
    .DATA_WIDTH(32),
    .DEPTH(16)
) u_vrtl_fifo_sync_prog (
    .clk              (clk),
    .rst_n            (rst_n),
    .wr_en            (wr_en),
    .wr_data          (wr_data),
    .rd_en            (rd_en),
    .rd_data          (rd_data),
    .prog_full_thresh (prog_full_thresh),
    .prog_empty_thresh(prog_empty_thresh),
    .full             (full),
    .empty            (empty),
    .almost_full      (almost_full),
    .almost_empty     (almost_empty),
    .count            (count)
);
*/
module vrtl_fifo_sync_prog #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16,
    localparam int ADDR_W    = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    input  logic [ADDR_W:0]       prog_full_thresh,
    input  logic [ADDR_W:0]       prog_empty_thresh,
    output logic                  full,
    output logic                  empty,
    output logic                  almost_full,
    output logic                  almost_empty,
    output logic [ADDR_W:0]       count
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];
  logic [ADDR_W-1:0] wr_ptr;
  logic [ADDR_W-1:0] rd_ptr;

  assign empty        = (count == '0);
  assign full         = (count == (ADDR_W+1)'(DEPTH));
  assign almost_empty = (count <= prog_empty_thresh);
  assign almost_full  = (count >= prog_full_thresh);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr  <= '0;
      rd_ptr  <= '0;
      count   <= '0;
      rd_data <= '0;
    end else begin
      case ({wr_en && !full, rd_en && !empty})
        2'b10: begin
          mem[wr_ptr] <= wr_data;
          wr_ptr      <= (wr_ptr == ADDR_W'(DEPTH - 1)) ? '0 : wr_ptr + 1'b1;
          count       <= count + 1'b1;
        end
        2'b01: begin
          rd_data <= mem[rd_ptr];
          rd_ptr  <= (rd_ptr == ADDR_W'(DEPTH - 1)) ? '0 : rd_ptr + 1'b1;
          count   <= count - 1'b1;
        end
        2'b11: begin
          mem[wr_ptr] <= wr_data;
          wr_ptr      <= (wr_ptr == ADDR_W'(DEPTH - 1)) ? '0 : wr_ptr + 1'b1;
          rd_data     <= mem[rd_ptr];
          rd_ptr      <= (rd_ptr == ADDR_W'(DEPTH - 1)) ? '0 : rd_ptr + 1'b1;
        end
        default: ;
      endcase
    end
  end

  `VRTL_ASSERT_NEVER(a_prog_overflow,  (wr_en && full),  clk, rst_n, "FIFO write overflow attempted");
  `VRTL_ASSERT_NEVER(a_prog_underflow, (rd_en && empty), clk, rst_n, "FIFO read underflow attempted");

endmodule


/*
// Instance Example:
vrtl_fifo_sync_fwft #(
    .DATA_WIDTH(32),
    .DEPTH(16)
) u_vrtl_fifo_sync_fwft (
    .clk     (clk),
    .rst_n   (rst_n),
    .wr_en   (wr_en),
    .wr_data (wr_data),
    .rd_en   (rd_en),
    .rd_data (rd_data),
    .full    (full),
    .empty   (empty)
);
*/
module vrtl_fifo_sync_fwft #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 16,
    localparam int ADDR_W    = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  full,
    output logic                  empty
);
  logic [DATA_WIDTH-1:0] fifo_rd_data;
  logic fifo_empty, fifo_rd_en;
  logic valid;

  vrtl_fifo_sync #(
      .DATA_WIDTH(DATA_WIDTH),
      .DEPTH(DEPTH)
  ) u_inner_fifo (
      .clk          (clk),
      .rst_n        (rst_n),
      .wr_en        (wr_en),
      .wr_data      (wr_data),
      .rd_en        (fifo_rd_en),
      .rd_data      (fifo_rd_data),
      .full         (full),
      .empty        (fifo_empty),
      .almost_full  (),
      .almost_empty (),
      .count        ()
  );

  assign empty      = !valid;
  assign fifo_rd_en = !fifo_empty && (!valid || rd_en);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid   <= 1'b0;
      rd_data <= '0;
    end else begin
      if (fifo_rd_en) begin
        valid   <= 1'b1;
        rd_data <= fifo_rd_data;
      end else if (rd_en) begin
        valid   <= 1'b0;
      end
    end
  end
endmodule

`endif // VRTL_FIFO_SV
