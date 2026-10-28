`ifndef VRTL_STREAM_SV
`define VRTL_STREAM_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Ready-Valid Handshake Buffers & Register Slices
// =============================================================================

/*
// Instance Example:
vrtl_skid_buffer #(
    .DATA_WIDTH(32)
) u_vrtl_skid_buffer (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (s_valid),
    .s_ready (s_ready),
    .s_data  (s_data),
    .m_valid (m_valid),
    .m_ready (m_ready),
    .m_data  (m_data)
);
*/
module vrtl_skid_buffer #(
    parameter int DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Slave (Input) Stream
    input  logic                  s_valid,
    output logic                  s_ready,
    input  logic [DATA_WIDTH-1:0] s_data,

    // Master (Output) Stream
    output logic                  m_valid,
    input  logic                  m_ready,
    output logic [DATA_WIDTH-1:0] m_data
);
  logic [DATA_WIDTH-1:0] reg_data;
  logic [DATA_WIDTH-1:0] skid_data;
  logic reg_valid;
  logic skid_valid;

  assign s_ready = !skid_valid;
  assign m_valid = reg_valid;
  assign m_data  = reg_data;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg_valid  <= 1'b0;
      skid_valid <= 1'b0;
      reg_data   <= '0;
      skid_data  <= '0;
    end else begin
      if (s_ready) begin
        if (m_ready || !m_valid) begin
          reg_valid <= s_valid;
          reg_data  <= s_data;
        end else if (s_valid) begin
          skid_valid <= 1'b1;
          skid_data  <= s_data;
        end
      end else if (m_ready) begin
        skid_valid <= 1'b0;
        reg_valid  <= 1'b1;
        reg_data   <= skid_data;
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_reg_slice_forward #(
    .DATA_WIDTH(32)
) u_vrtl_reg_slice_forward (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (s_valid),
    .s_ready (s_ready),
    .s_data  (s_data),
    .m_valid (m_valid),
    .m_ready (m_ready),
    .m_data  (m_data)
);
*/
module vrtl_reg_slice_forward #(
    parameter int DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  s_valid,
    output logic                  s_ready,
    input  logic [DATA_WIDTH-1:0] s_data,

    output logic                  m_valid,
    input  logic                  m_ready,
    output logic [DATA_WIDTH-1:0] m_data
);
  assign s_ready = !m_valid || m_ready;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      m_valid <= 1'b0;
      m_data  <= '0;
    end else if (s_ready) begin
      m_valid <= s_valid;
      m_data  <= s_data;
    end
  end
endmodule


/*
// Instance Example:
vrtl_reg_slice_backward #(
    .DATA_WIDTH(32)
) u_vrtl_reg_slice_backward (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (s_valid),
    .s_ready (s_ready),
    .s_data  (s_data),
    .m_valid (m_valid),
    .m_ready (m_ready),
    .m_data  (m_data)
);
*/
module vrtl_reg_slice_backward #(
    parameter int DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  s_valid,
    output logic                  s_ready,
    input  logic [DATA_WIDTH-1:0] s_data,

    output logic                  m_valid,
    input  logic                  m_ready,
    output logic [DATA_WIDTH-1:0] m_data
);
  logic [DATA_WIDTH-1:0] buf_data;
  logic buf_valid;

  assign s_ready = !buf_valid;
  assign m_valid = s_valid || buf_valid;
  assign m_data  = buf_valid ? buf_data : s_data;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      buf_valid <= 1'b0;
      buf_data  <= '0;
    end else begin
      if (s_valid && !buf_valid && !m_ready) begin
        buf_valid <= 1'b1;
        buf_data  <= s_data;
      end else if (m_ready) begin
        buf_valid <= 1'b0;
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_stream_fork_1to2 #(
    .DATA_WIDTH(32)
) u_vrtl_stream_fork_1to2 (
    .clk       (clk),
    .rst_n     (rst_n),
    .s_valid   (s_valid),
    .s_ready   (s_ready),
    .s_data    (s_data),
    .m0_valid  (m0_valid),
    .m0_ready  (m0_ready),
    .m0_data   (m0_data),
    .m1_valid  (m1_valid),
    .m1_ready  (m1_ready),
    .m1_data   (m1_data)
);
*/
module vrtl_stream_fork_1to2 #(
    parameter int DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  s_valid,
    output logic                  s_ready,
    input  logic [DATA_WIDTH-1:0] s_data,

    output logic                  m0_valid,
    input  logic                  m0_ready,
    output logic [DATA_WIDTH-1:0] m0_data,

    output logic                  m1_valid,
    input  logic                  m1_ready,
    output logic [DATA_WIDTH-1:0] m1_data
);
  logic ack0, ack1;

  assign m0_data = s_data;
  assign m1_data = s_data;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ack0 <= 1'b0;
      ack1 <= 1'b0;
    end else begin
      if (s_valid && s_ready) begin
        ack0 <= 1'b0;
        ack1 <= 1'b0;
      end else begin
        if (m0_valid && m0_ready) ack0 <= 1'b1;
        if (m1_valid && m1_ready) ack1 <= 1'b1;
      end
    end
  end

  assign m0_valid = s_valid && !ack0;
  assign m1_valid = s_valid && !ack1;
  assign s_ready  = (ack0 || m0_ready) && (ack1 || m1_ready);
endmodule


/*
// Instance Example:
vrtl_stream_mux_2to1 #(
    .DATA_WIDTH(32)
) u_vrtl_stream_mux_2to1 (
    .sel      (sel),
    .s0_valid (s0_valid),
    .s0_ready (s0_ready),
    .s0_data  (s0_data),
    .s1_valid (s1_valid),
    .s1_ready (s1_ready),
    .s1_data  (s1_data),
    .m_valid  (m_valid),
    .m_ready  (m_ready),
    .m_data   (m_data)
);
*/
module vrtl_stream_mux_2to1 #(
    parameter int DATA_WIDTH = 32
)(
    input  logic                  sel,

    input  logic                  s0_valid,
    output logic                  s0_ready,
    input  logic [DATA_WIDTH-1:0] s0_data,

    input  logic                  s1_valid,
    output logic                  s1_ready,
    input  logic [DATA_WIDTH-1:0] s1_data,

    output logic                  m_valid,
    input  logic                  m_ready,
    output logic [DATA_WIDTH-1:0] m_data
);
  assign m_valid  = sel ? s1_valid : s0_valid;
  assign m_data   = sel ? s1_data  : s0_data;
  assign s0_ready = !sel && m_ready;
  assign s1_ready =  sel && m_ready;
endmodule


/*
// Instance Example:
vrtl_stream_demux_1to2 #(
    .DATA_WIDTH(32)
) u_vrtl_stream_demux_1to2 (
    .sel      (sel),
    .s_valid  (s_valid),
    .s_ready  (s_ready),
    .s_data   (s_data),
    .m0_valid (m0_valid),
    .m0_ready (m0_ready),
    .m0_data  (m0_data),
    .m1_valid (m1_valid),
    .m1_ready (m1_ready),
    .m1_data  (m1_data)
);
*/
module vrtl_stream_demux_1to2 #(
    parameter int DATA_WIDTH = 32
)(
    input  logic                  sel,

    input  logic                  s_valid,
    output logic                  s_ready,
    input  logic [DATA_WIDTH-1:0] s_data,

    output logic                  m0_valid,
    input  logic                  m0_ready,
    output logic [DATA_WIDTH-1:0] m0_data,

    output logic                  m1_valid,
    input  logic                  m1_ready,
    output logic [DATA_WIDTH-1:0] m1_data
);
  assign m0_data  = s_data;
  assign m1_data  = s_data;
  assign m0_valid = !sel && s_valid;
  assign m1_valid =  sel && s_valid;
  assign s_ready  = sel ? m1_ready : m0_ready;
endmodule


/*
// Instance Example:
vrtl_stream_join_2to1 #(
    .DATA_A_WIDTH(16),
    .DATA_B_WIDTH(16)
) u_vrtl_stream_join_2to1 (
    .s_a_valid (s_a_valid),
    .s_a_ready (s_a_ready),
    .s_a_data  (s_a_data),
    .s_b_valid (s_b_valid),
    .s_b_ready (s_b_ready),
    .s_b_data  (s_b_data),
    .m_valid   (m_valid),
    .m_ready   (m_ready),
    .m_data    (m_data)
);
*/
module vrtl_stream_join_2to1 #(
    parameter int DATA_A_WIDTH = 16,
    parameter int DATA_B_WIDTH = 16
)(
    input  logic                    s_a_valid,
    output logic                    s_a_ready,
    input  logic [DATA_A_WIDTH-1:0] s_a_data,

    input  logic                    s_b_valid,
    output logic                    s_b_ready,
    input  logic [DATA_B_WIDTH-1:0] s_b_data,

    output logic                    m_valid,
    input  logic                    m_ready,
    output logic [DATA_A_WIDTH+DATA_B_WIDTH-1:0] m_data
);
  assign m_valid   = s_a_valid && s_b_valid;
  assign m_data    = {s_a_data, s_b_data};
  assign s_a_ready = s_b_valid && m_ready;
  assign s_b_ready = s_a_valid && m_ready;
endmodule


/*
// Instance Example:
vrtl_stream_width_upsizer #(
    .IN_WIDTH(8),
    .RATIO(4)
) u_vrtl_stream_width_upsizer (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (s_valid),
    .s_ready (s_ready),
    .s_data  (s_data),
    .m_valid (m_valid),
    .m_ready (m_ready),
    .m_data  (m_data)
);
*/
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


/*
// Instance Example:
vrtl_stream_width_downsizer #(
    .OUT_WIDTH(8),
    .RATIO(4)
) u_vrtl_stream_width_downsizer (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (s_valid),
    .s_ready (s_ready),
    .s_data  (s_data),
    .m_valid (m_valid),
    .m_ready (m_ready),
    .m_data  (m_data)
);
*/
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

`endif // VRTL_STREAM_SV
