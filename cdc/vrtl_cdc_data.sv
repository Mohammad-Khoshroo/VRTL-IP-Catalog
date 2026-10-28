`ifndef CDC_VRTL_CDC_DATA_SV
`define CDC_VRTL_CDC_DATA_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_sync_bus #(
//     .WIDTH  (8),
//     .STAGES (2)
// ) u_vrtl_sync_bus (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .async_in (async_in),
//     .sync_out (sync_out)
// );
// =============================================================================
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


// =============================================================================
// vrtl_sync_mux_data #(
//     .WIDTH (32)
// ) u_vrtl_sync_mux_data (
//     .src_clk   (src_clk),
//     .src_rst_n (src_rst_n),
//     .src_data  (src_data),
//     .src_valid (src_valid),
//     .src_ready (src_ready),
//     .dst_clk   (dst_clk),
//     .dst_rst_n (dst_rst_n),
//     .dst_data  (dst_data),
//     .dst_valid (dst_valid)
// );
// =============================================================================
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

`endif // CDC_VRTL_CDC_DATA_SV
