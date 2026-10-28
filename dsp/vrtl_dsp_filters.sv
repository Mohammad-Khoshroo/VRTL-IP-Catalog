`ifndef DSP_VRTL_DSP_FILTERS_SV
`define DSP_VRTL_DSP_FILTERS_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_moving_average_filter #(
//     .DATA_WIDTH  (16),
//     .WINDOW_SIZE (8)
// ) u_vrtl_moving_average_filter (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .valid_in  (valid_in),
//     .data_in   (data_in),
//     .valid_out (valid_out),
//     .data_out  (data_out)
// );
// =============================================================================
module vrtl_moving_average_filter #(
    parameter int DATA_WIDTH  = 16,
    parameter int WINDOW_SIZE = 8,
    localparam int WIN_BITS   = $clog2(WINDOW_SIZE),
    localparam int ACC_WIDTH  = DATA_WIDTH + WIN_BITS
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  valid_in,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic                  valid_out,
    output logic [DATA_WIDTH-1:0] data_out
);
  logic [DATA_WIDTH-1:0] shift_ram [WINDOW_SIZE];
  logic [ACC_WIDTH-1:0]  acc;
  logic [WIN_BITS-1:0]   wr_ptr;
  logic [WIN_BITS:0]     sample_cnt;

  assign data_out  = acc[WIN_BITS +: DATA_WIDTH];
  assign valid_out = (sample_cnt >= (WIN_BITS+1)'(WINDOW_SIZE));

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc        <= '0;
      wr_ptr     <= '0;
      sample_cnt <= '0;
      for (int i = 0; i < WINDOW_SIZE; i = i + 1) begin
        shift_ram[i] <= '0;
      end
    end else if (valid_in) begin
      acc               <= acc - shift_ram[wr_ptr] + data_in;
      shift_ram[wr_ptr] <= data_in;
      wr_ptr            <= (wr_ptr == WIN_BITS'(WINDOW_SIZE - 1)) ? '0 : wr_ptr + 1'b1;
      if (sample_cnt < (WIN_BITS+1)'(WINDOW_SIZE)) begin
        sample_cnt <= sample_cnt + 1'b1;
      end
    end
  end
endmodule


// =============================================================================
// vrtl_fir_filter_4tap #(
//     .DATA_WIDTH  (16),
//     .COEFF_WIDTH (16),
//     .C0          (16'sd100),
//     .C1          (16'sd200),
//     .C2          (16'sd200),
//     .C3          (16'sd100)
// ) u_vrtl_fir_filter_4tap (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .valid_in  (valid_in),
//     .data_in   (data_in),
//     .valid_out (valid_out),
//     .data_out  (data_out)
// );
// =============================================================================
module vrtl_fir_filter_4tap #(
    parameter int DATA_WIDTH = 16,
    parameter int COEFF_WIDTH = 16,
    parameter logic signed [COEFF_WIDTH-1:0] C0 = 16'sd100,
    parameter logic signed [COEFF_WIDTH-1:0] C1 = 16'sd200,
    parameter logic signed [COEFF_WIDTH-1:0] C2 = 16'sd200,
    parameter logic signed [COEFF_WIDTH-1:0] C3 = 16'sd100,
    localparam int PROD_W = DATA_WIDTH + COEFF_WIDTH,
    localparam int OUT_W  = PROD_W + 2
)(
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         valid_in,
    input  logic signed [DATA_WIDTH-1:0] data_in,
    output logic                         valid_out,
    output logic signed [OUT_W-1:0]      data_out
);
  logic signed [DATA_WIDTH-1:0] d0, d1, d2, d3;
  logic v0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      d0        <= '0;
      d1        <= '0;
      d2        <= '0;
      d3        <= '0;
      data_out  <= '0;
      v0        <= 1'b0;
      valid_out <= 1'b0;
    end else begin
      v0        <= valid_in;
      valid_out <= v0;
      if (valid_in) begin
        d0 <= data_in;
        d1 <= d0;
        d2 <= d1;
        d3 <= d2;
      end
      if (v0) begin
        data_out <= (d0 * C0) + (d1 * C1) + (d2 * C2) + (d3 * C3);
      end
    end
  end
endmodule

`endif // DSP_VRTL_DSP_FILTERS_SV
