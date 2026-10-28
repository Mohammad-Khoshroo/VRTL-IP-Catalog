`ifndef CDC_VRTL_CDC_BIT_SV
`define CDC_VRTL_CDC_BIT_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_sync_2stage u_vrtl_sync_2stage (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .async_in (async_in),
//     .sync_out (sync_out)
// );
// =============================================================================
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


// =============================================================================
// vrtl_sync_3stage u_vrtl_sync_3stage (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .async_in (async_in),
//     .sync_out (sync_out)
// );
// =============================================================================
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


// =============================================================================
// vrtl_reset_sync u_vrtl_reset_sync (
//     .clk         (clk),
//     .async_rst_n (async_rst_n),
//     .sync_rst_n  (sync_rst_n)
// );
// =============================================================================
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

`endif // CDC_VRTL_CDC_BIT_SV
