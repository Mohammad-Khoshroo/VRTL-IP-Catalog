`ifndef STREAM_VRTL_STREAM_WIDTH_SV
`define STREAM_VRTL_STREAM_WIDTH_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_stream_width_upsizer #(
//     .IN_WIDTH (8),
//     .RATIO    (4)
// ) u_vrtl_stream_width_upsizer (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .s_valid (s_valid),
//     .s_ready (s_ready),
//     .s_data  (s_data),
//     .m_valid (m_valid),
//     .m_ready (m_ready),
//     .m_data  (m_data)
// );
// =============================================================================
module vrtl_stream_width_upsizer #(
    parameter int IN_WIDTH = 8,
    parameter int RATIO    = 4,
    localparam int CNT_W   = (RATIO > 1) ? $clog2(RATIO) : 1
)(
    input  logic                      clk,
    input  logic                      rst_n,

    input  logic                      s_valid,
    output logic                      s_ready,
    input  logic [IN_WIDTH-1:0]       s_data,

    output logic                      m_valid,
    input  logic                      m_ready,
    output logic [IN_WIDTH*RATIO-1:0] m_data
);
  logic [IN_WIDTH*RATIO-1:0] shift_reg;
  logic [CNT_W-1:0] cnt;
  logic out_valid;

  assign s_ready = !out_valid || m_ready;
  assign m_valid = out_valid;
  assign m_data  = shift_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg <= '0;
      cnt       <= '0;
      out_valid <= 1'b0;
    end else begin
      if (m_valid && m_ready) begin
        out_valid <= 1'b0;
      end

      if (s_valid && s_ready) begin
        shift_reg[cnt*IN_WIDTH +: IN_WIDTH] <= s_data;
        if (cnt == CNT_W'(RATIO - 1)) begin
          cnt       <= '0;
          out_valid <= 1'b1;
        end else begin
          cnt <= cnt + 1'b1;
        end
      end
    end
  end
endmodule


// =============================================================================
// vrtl_stream_width_downsizer #(
//     .OUT_WIDTH (8),
//     .RATIO     (4)
// ) u_vrtl_stream_width_downsizer (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .s_valid (s_valid),
//     .s_ready (s_ready),
//     .s_data  (s_data),
//     .m_valid (m_valid),
//     .m_ready (m_ready),
//     .m_data  (m_data)
// );
// =============================================================================
module vrtl_stream_width_downsizer #(
    parameter int OUT_WIDTH = 8,
    parameter int RATIO     = 4,
    localparam int CNT_W    = (RATIO > 1) ? $clog2(RATIO) : 1
)(
    input  logic                       clk,
    input  logic                       rst_n,

    input  logic                       s_valid,
    output logic                       s_ready,
    input  logic [OUT_WIDTH*RATIO-1:0] s_data,

    output logic                       m_valid,
    input  logic                       m_ready,
    output logic [OUT_WIDTH-1:0]       m_data
);
  logic [OUT_WIDTH*RATIO-1:0] hold_reg;
  logic [CNT_W-1:0] cnt;
  logic active;

  assign s_ready = !active;
  assign m_valid = active;
  assign m_data  = hold_reg[cnt*OUT_WIDTH +: OUT_WIDTH];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      hold_reg <= '0;
      cnt      <= '0;
      active   <= 1'b0;
    end else begin
      if (!active) begin
        if (s_valid) begin
          hold_reg <= s_data;
          cnt      <= '0;
          active   <= 1'b1;
        end
      end else begin
        if (m_ready) begin
          if (cnt == CNT_W'(RATIO - 1)) begin
            cnt    <= '0;
            active <= 1'b0;
          end else begin
            cnt <= cnt + 1'b1;
          end
        end
      end
    end
  end
endmodule

`endif // STREAM_VRTL_STREAM_WIDTH_SV
