`ifndef CDC_VRTL_CDC_PULSE_HANDSHAKE_SV
`define CDC_VRTL_CDC_PULSE_HANDSHAKE_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_pulse_sync u_vrtl_pulse_sync (
//     .clk_src   (clk_src),
//     .rst_src_n (rst_src_n),
//     .pulse_src (pulse_src),
//     .clk_dst   (clk_dst),
//     .rst_dst_n (rst_dst_n),
//     .pulse_dst (pulse_dst)
// );
// =============================================================================
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


// =============================================================================
// vrtl_sync_handshake u_vrtl_sync_handshake (
//     .clk_src   (clk_src),
//     .rst_src_n (rst_src_n),
//     .req_src   (req_src),
//     .ack_src   (ack_src),
//     .clk_dst   (clk_dst),
//     .rst_dst_n (rst_dst_n),
//     .req_dst   (req_dst),
//     .ack_dst   (ack_dst)
// );
// =============================================================================
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

`endif // CDC_VRTL_CDC_PULSE_HANDSHAKE_SV
