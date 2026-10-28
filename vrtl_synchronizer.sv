`ifndef VRTL_SYNCHRONIZER_SV
`define VRTL_SYNCHRONIZER_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// -----------------------------------------------------------------------------
// Non-Parametric Synchronizers & Edge Detectors
// -----------------------------------------------------------------------------

/*
// Instance Example:
vrtl_edge_detect u_vrtl_edge_detect (
    .clk      (clk),
    .rst_n    (rst_n),
    .sig_in   (sig_in),
    .pos_edge (pos_edge),
    .neg_edge (neg_edge),
    .any_edge (any_edge)
);
*/
module vrtl_edge_detect (
    input  logic clk,
    input  logic rst_n,
    input  logic sig_in,
    output logic pos_edge,
    output logic neg_edge,
    output logic any_edge
);
  logic sig_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sig_d <= 1'b0;
    end else begin
      sig_d <= sig_in;
    end
  end

  assign pos_edge = sig_in & ~sig_d;
  assign neg_edge = ~sig_in & sig_d;
  assign any_edge = sig_in ^ sig_d;
endmodule


/*
// Instance Example:
vrtl_sync_2stage u_vrtl_sync_2stage (
    .clk      (clk),
    .rst_n    (rst_n),
    .async_in (async_in),
    .sync_out (sync_out)
);
*/
module vrtl_sync_2stage (
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic sync_out
);
  (* ASYNC_REG = "TRUE" *) logic stage1, stage2;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      stage1 <= 1'b0;
      stage2 <= 1'b0;
    end else begin
      stage1 <= async_in;
      stage2 <= stage1;
    end
  end

  assign sync_out = stage2;
endmodule


/*
// Instance Example:
vrtl_sync_3stage u_vrtl_sync_3stage (
    .clk      (clk),
    .rst_n    (rst_n),
    .async_in (async_in),
    .sync_out (sync_out)
);
*/
module vrtl_sync_3stage (
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic sync_out
);
  (* ASYNC_REG = "TRUE" *) logic stage1, stage2, stage3;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      stage1 <= 1'b0;
      stage2 <= 1'b0;
      stage3 <= 1'b0;
    end else begin
      stage1 <= async_in;
      stage2 <= stage1;
      stage3 <= stage2;
    end
  end

  assign sync_out = stage3;
endmodule


/*
// Instance Example:
vrtl_reset_sync u_vrtl_reset_sync (
    .clk         (clk),
    .async_rst_n (async_rst_n),
    .sync_rst_n  (sync_rst_n)
);
*/
module vrtl_reset_sync (
    input  logic clk,
    input  logic async_rst_n,
    output logic sync_rst_n
);
  (* ASYNC_REG = "TRUE" *) logic stage1, stage2;

  always_ff @(posedge clk or negedge async_rst_n) begin
    if (!async_rst_n) begin
      stage1 <= 1'b0;
      stage2 <= 1'b0;
    end else begin
      stage1 <= 1'b1;
      stage2 <= stage1;
    end
  end

  assign sync_rst_n = stage2;
endmodule


/*
// Instance Example:
vrtl_sync_handshake u_vrtl_sync_handshake (
    .clk_src   (clk_src),
    .rst_src_n (rst_src_n),
    .req_src   (req_src),
    .ack_src   (ack_src),
    .clk_dst   (clk_dst),
    .rst_dst_n (rst_dst_n),
    .req_dst   (req_dst),
    .ack_dst   (ack_dst)
);
*/
module vrtl_sync_handshake (
    input  logic clk_src,
    input  logic rst_src_n,
    input  logic req_src,
    output logic ack_src,

    input  logic clk_dst,
    input  logic rst_dst_n,
    output logic req_dst,
    input  logic ack_dst
);
  (* ASYNC_REG = "TRUE" *) logic req_d1, req_d2;
  (* ASYNC_REG = "TRUE" *) logic ack_s1, ack_s2;

  always_ff @(posedge clk_dst or negedge rst_dst_n) begin
    if (!rst_dst_n) begin
      req_d1 <= 1'b0;
      req_d2 <= 1'b0;
    end else begin
      req_d1 <= req_src;
      req_d2 <= req_d1;
    end
  end

  assign req_dst = req_d2;

  always_ff @(posedge clk_src or negedge rst_src_n) begin
    if (!rst_src_n) begin
      ack_s1 <= 1'b0;
      ack_s2 <= 1'b0;
    end else begin
      ack_s1 <= ack_dst;
      ack_s2 <= ack_s1;
    end
  end

  assign ack_src = ack_s2;
endmodule


// -----------------------------------------------------------------------------
// Parametric Synchronizers & Edge Detectors
// -----------------------------------------------------------------------------

/*
// Instance Example:
vrtl_edge_detect_n #(
    .WIDTH(8)
) u_vrtl_edge_detect_n (
    .clk      (clk),
    .rst_n    (rst_n),
    .sig_in   (sig_in),
    .pos_edge (pos_edge),
    .neg_edge (neg_edge),
    .any_edge (any_edge)
);
*/
module vrtl_edge_detect_n #(
    parameter int WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] sig_in,
    output logic [WIDTH-1:0] pos_edge,
    output logic [WIDTH-1:0] neg_edge,
    output logic [WIDTH-1:0] any_edge
);
  logic [WIDTH-1:0] sig_d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sig_d <= '0;
    end else begin
      sig_d <= sig_in;
    end
  end

  assign pos_edge = sig_in & ~sig_d;
  assign neg_edge = ~sig_in & sig_d;
  assign any_edge = sig_in ^ sig_d;
endmodule


/*
// Instance Example:
vrtl_sync_bus #(
    .WIDTH(8),
    .STAGES(2)
) u_vrtl_sync_bus (
    .clk      (clk),
    .rst_n    (rst_n),
    .async_in (async_in),
    .sync_out (sync_out)
);
*/
module vrtl_sync_bus #(
    parameter int WIDTH  = 8,
    parameter int STAGES = 2
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] async_in,
    output logic [WIDTH-1:0] sync_out
);
  (* ASYNC_REG = "TRUE" *) logic [WIDTH-1:0] sync_regs [STAGES];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < STAGES; i = i + 1) begin
        sync_regs[i] <= '0;
      end
    end else begin
      sync_regs[0] <= async_in;
      for (int i = 1; i < STAGES; i = i + 1) begin
        sync_regs[i] <= sync_regs[i-1];
      end
    end
  end

  assign sync_out = sync_regs[STAGES-1];
endmodule


/*
// Instance Example:
vrtl_pulse_sync u_vrtl_pulse_sync (
    .clk_src   (clk_src),
    .rst_src_n (rst_src_n),
    .pulse_src (pulse_src),
    .clk_dst   (clk_dst),
    .rst_dst_n (rst_dst_n),
    .pulse_dst (pulse_dst)
);
*/
module vrtl_pulse_sync (
    input  logic clk_src,
    input  logic rst_src_n,
    input  logic pulse_src,
    input  logic clk_dst,
    input  logic rst_dst_n,
    output logic pulse_dst
);
  logic toggle_src;
  (* ASYNC_REG = "TRUE" *) logic sync_d1, sync_d2, sync_d3;

  always_ff @(posedge clk_src or negedge rst_src_n) begin
    if (!rst_src_n) begin
      toggle_src <= 1'b0;
    end else if (pulse_src) begin
      toggle_src <= ~toggle_src;
    end
  end

  always_ff @(posedge clk_dst or negedge rst_dst_n) begin
    if (!rst_dst_n) begin
      sync_d1 <= 1'b0;
      sync_d2 <= 1'b0;
      sync_d3 <= 1'b0;
    end else begin
      sync_d1 <= toggle_src;
      sync_d2 <= sync_d1;
      sync_d3 <= sync_d2;
    end
  end

  assign pulse_dst = sync_d2 ^ sync_d3;
endmodule


/*
// Instance Example:
vrtl_sync_mux_data #(
    .WIDTH(32)
) u_vrtl_sync_mux_data (
    .src_clk   (src_clk),
    .src_rst_n (src_rst_n),
    .src_data  (src_data),
    .src_valid (src_valid),
    .src_ready (src_ready),
    .dst_clk   (dst_clk),
    .dst_rst_n (dst_rst_n),
    .dst_data  (dst_data),
    .dst_valid (dst_valid)
);
*/
module vrtl_sync_mux_data #(
    parameter int WIDTH = 32
)(
    input  logic             src_clk,
    input  logic             src_rst_n,
    input  logic [WIDTH-1:0] src_data,
    input  logic             src_valid,
    output logic             src_ready,

    input  logic             dst_clk,
    input  logic             dst_rst_n,
    output logic [WIDTH-1:0] dst_data,
    output logic             dst_valid
);
  logic [WIDTH-1:0] data_hold;
  logic src_toggle;
  (* ASYNC_REG = "TRUE" *) logic dst_sync1, dst_sync2, dst_sync3;
  (* ASYNC_REG = "TRUE" *) logic src_ack1, src_ack2;

  always_ff @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
      src_toggle <= 1'b0;
      data_hold  <= '0;
      src_ack1   <= 1'b0;
      src_ack2   <= 1'b0;
    end else begin
      src_ack1 <= dst_sync2;
      src_ack2 <= src_ack1;
      if (src_valid && (src_toggle == src_ack2)) begin
        data_hold  <= src_data;
        src_toggle <= ~src_toggle;
      end
    end
  end

  assign src_ready = (src_toggle == src_ack2);

  always_ff @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_rst_n) begin
      dst_sync1 <= 1'b0;
      dst_sync2 <= 1'b0;
      dst_sync3 <= 1'b0;
      dst_data  <= '0;
      dst_valid <= 1'b0;
    end else begin
      dst_sync1 <= src_toggle;
      dst_sync2 <= dst_sync1;
      dst_sync3 <= dst_sync2;
      dst_valid <= dst_sync2 ^ dst_sync3;
      if (dst_sync2 ^ dst_sync3) begin
        dst_data <= data_hold;
      end
    end
  end
endmodule

`endif // VRTL_SYNCHRONIZER_SV
