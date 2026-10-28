`ifndef STREAM_VRTL_STREAM_ROUTING_SV
`define STREAM_VRTL_STREAM_ROUTING_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_stream_fork_1to2 #(
//     .DATA_WIDTH (32)
// ) u_vrtl_stream_fork_1to2 (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .s_valid  (s_valid),
//     .s_ready  (s_ready),
//     .s_data   (s_data),
//     .m0_valid (m0_valid),
//     .m0_ready (m0_ready),
//     .m0_data  (m0_data),
//     .m1_valid (m1_valid),
//     .m1_ready (m1_ready),
//     .m1_data  (m1_data)
// );
// =============================================================================
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


// =============================================================================
// vrtl_stream_mux_2to1 #(
//     .DATA_WIDTH (32)
// ) u_vrtl_stream_mux_2to1 (
//     .sel      (sel),
//     .s0_valid (s0_valid),
//     .s0_ready (s0_ready),
//     .s0_data  (s0_data),
//     .s1_valid (s1_valid),
//     .s1_ready (s1_ready),
//     .s1_data  (s1_data),
//     .m_valid  (m_valid),
//     .m_ready  (m_ready),
//     .m_data   (m_data)
// );
// =============================================================================
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


// =============================================================================
// vrtl_stream_demux_1to2 #(
//     .DATA_WIDTH (32)
// ) u_vrtl_stream_demux_1to2 (
//     .sel      (sel),
//     .s_valid  (s_valid),
//     .s_ready  (s_ready),
//     .s_data   (s_data),
//     .m0_valid (m0_valid),
//     .m0_ready (m0_ready),
//     .m0_data  (m0_data),
//     .m1_valid (m1_valid),
//     .m1_ready (m1_ready),
//     .m1_data  (m1_data)
// );
// =============================================================================
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


// =============================================================================
// vrtl_stream_join_2to1 #(
//     .DATA_A_WIDTH (16),
//     .DATA_B_WIDTH (16)
// ) u_vrtl_stream_join_2to1 (
//     .s_a_valid (s_a_valid),
//     .s_a_ready (s_a_ready),
//     .s_a_data  (s_a_data),
//     .s_b_valid (s_b_valid),
//     .s_b_ready (s_b_ready),
//     .s_b_data  (s_b_data),
//     .m_valid   (m_valid),
//     .m_ready   (m_ready),
//     .m_data    (m_data)
// );
// =============================================================================
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

`endif // STREAM_VRTL_STREAM_ROUTING_SV
