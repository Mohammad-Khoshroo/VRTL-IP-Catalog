`ifndef STREAM_VRTL_STREAM_SLICES_SV
`define STREAM_VRTL_STREAM_SLICES_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_skid_buffer #(
//     .DATA_WIDTH (32)
// ) u_vrtl_skid_buffer (
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


// =============================================================================
// vrtl_reg_slice_forward #(
//     .DATA_WIDTH (32)
// ) u_vrtl_reg_slice_forward (
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


// =============================================================================
// vrtl_reg_slice_backward #(
//     .DATA_WIDTH (32)
// ) u_vrtl_reg_slice_backward (
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

`endif // STREAM_VRTL_STREAM_SLICES_SV
