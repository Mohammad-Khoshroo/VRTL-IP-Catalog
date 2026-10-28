`ifndef VRTL_DSP_SV
`define VRTL_DSP_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// DSP Arithmetic & Signal Conditioning
// =============================================================================

/*
// Instance Example:
vrtl_saturating_adder #(
    .WIDTH(16),
    .SIGNED(1)
) u_vrtl_saturating_adder (
    .a      (a),
    .b      (b),
    .result (result),
    .sat_hi (sat_hi),
    .sat_lo (sat_lo)
);
*/
module vrtl_saturating_adder #(
    parameter int WIDTH  = 16,
    parameter bit SIGNED = 1
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] result,
    output logic             sat_hi,
    output logic             sat_lo
);
  localparam logic [WIDTH-1:0] MAX_POS = {1'b0, {(WIDTH-1){1'b1}}};
  localparam logic [WIDTH-1:0] MAX_NEG = {1'b1, {(WIDTH-1){1'b0}}};

  logic [WIDTH:0] ext_sum;
  assign ext_sum = {1'b0, a} + {1'b0, b};

  always_comb begin
    sat_hi = 1'b0;
    sat_lo = 1'b0;
    result = ext_sum[WIDTH-1:0];

    if (SIGNED) begin
      if (~a[WIDTH-1] & ~b[WIDTH-1] & ext_sum[WIDTH-1]) begin
        result = MAX_POS;
        sat_hi = 1'b1;
      end else if (a[WIDTH-1] & b[WIDTH-1] & ~ext_sum[WIDTH-1]) begin
        result = MAX_NEG;
        sat_lo = 1'b1;
      end
    end else begin
      if (ext_sum[WIDTH]) begin
        result = '1;
        sat_hi = 1'b1;
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_saturating_subtractor #(
    .WIDTH(16),
    .SIGNED(1)
) u_vrtl_saturating_subtractor (
    .a      (a),
    .b      (b),
    .result (result),
    .sat_hi (sat_hi),
    .sat_lo (sat_lo)
);
*/
module vrtl_saturating_subtractor #(
    parameter int WIDTH  = 16,
    parameter bit SIGNED = 1
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] result,
    output logic             sat_hi,
    output logic             sat_lo
);
  localparam logic [WIDTH-1:0] MAX_POS = {1'b0, {(WIDTH-1){1'b1}}};
  localparam logic [WIDTH-1:0] MAX_NEG = {1'b1, {(WIDTH-1){1'b0}}};

  logic [WIDTH:0] ext_diff;
  assign ext_diff = {1'b0, a} - {1'b0, b};

  always_comb begin
    sat_hi = 1'b0;
    sat_lo = 1'b0;
    result = ext_diff[WIDTH-1:0];

    if (SIGNED) begin
      if (~a[WIDTH-1] & b[WIDTH-1] & ext_diff[WIDTH-1]) begin
        result = MAX_POS;
        sat_hi = 1'b1;
      end else if (a[WIDTH-1] & ~b[WIDTH-1] & ~ext_diff[WIDTH-1]) begin
        result = MAX_NEG;
        sat_lo = 1'b1;
      end
    end else begin
      if (ext_diff[WIDTH]) begin
        result = '0;
        sat_lo = 1'b1;
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_dsp_abs #(
    .WIDTH(16)
) u_vrtl_dsp_abs (
    .in      (in),
    .abs_out (abs_out)
);
*/
module vrtl_dsp_abs #(
    parameter int WIDTH = 16
)(
    input  logic signed [WIDTH-1:0] in,
    output logic [WIDTH-1:0]        abs_out
);
  localparam logic signed [WIDTH-1:0] MOST_NEG = {1'b1, {(WIDTH-1){1'b0}}};
  localparam logic [WIDTH-1:0]        MAX_POS  = {1'b0, {(WIDTH-1){1'b1}}};

  always_comb begin
    if (in == MOST_NEG) begin
      abs_out = MAX_POS;
    end else if (in < 0) begin
      abs_out = -in;
    end else begin
      abs_out = in;
    end
  end
endmodule


/*
// Instance Example:
vrtl_mac #(
    .A_WIDTH(16),
    .B_WIDTH(16),
    .ACC_WIDTH(40)
) u_vrtl_mac (
    .clk     (clk),
    .rst_n   (rst_n),
    .clr     (clr),
    .en      (en),
    .a       (a),
    .b       (b),
    .acc_out (acc_out)
);
*/
module vrtl_mac #(
    parameter int A_WIDTH   = 16,
    parameter int B_WIDTH   = 16,
    parameter int ACC_WIDTH = 40
)(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        clr,
    input  logic                        en,
    input  logic signed [A_WIDTH-1:0]   a,
    input  logic signed [B_WIDTH-1:0]   b,
    output logic signed [ACC_WIDTH-1:0] acc_out
);
  logic signed [A_WIDTH+B_WIDTH-1:0] prod;
  logic signed [ACC_WIDTH-1:0] acc;

  assign prod    = a * b;
  assign acc_out = acc;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= '0;
    end else if (clr) begin
      acc <= '0;
    end else if (en) begin
      acc <= acc + ACC_WIDTH'(prod);
    end
  end
endmodule


/*
// Instance Example:
vrtl_complex_mult #(
    .WIDTH(16)
) u_vrtl_complex_mult (
    .ar (ar),
    .ai (ai),
    .br (br),
    .bi (bi),
    .pr (pr),
    .pi (pi)
);
*/
module vrtl_complex_mult #(
    parameter int WIDTH = 16
)(
    input  logic signed [WIDTH-1:0]   ar,
    input  logic signed [WIDTH-1:0]   ai,
    input  logic signed [WIDTH-1:0]   br,
    input  logic signed [WIDTH-1:0]   bi,
    output logic signed [2*WIDTH-1:0] pr,
    output logic signed [2*WIDTH-1:0] pi
);
  assign pr = (ar * br) - (ai * bi);
  assign pi = (ar * bi) + (ai * br);
endmodule


/*
// Instance Example:
vrtl_peak_detector #(
    .WIDTH(16),
    .SIGNED(1)
) u_vrtl_peak_detector (
    .clk       (clk),
    .rst_n     (rst_n),
    .clr       (clr),
    .valid_in  (valid_in),
    .sample_in (sample_in),
    .peak_max  (peak_max),
    .peak_min  (peak_min)
);
*/
module vrtl_peak_detector #(
    parameter int WIDTH  = 16,
    parameter bit SIGNED = 1
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             clr,
    input  logic             valid_in,
    input  logic [WIDTH-1:0] sample_in,
    output logic [WIDTH-1:0] peak_max,
    output logic [WIDTH-1:0] peak_min
);
  localparam logic [WIDTH-1:0] INIT_MIN = SIGNED ? {1'b0, {(WIDTH-1){1'b1}}} : '1;
  localparam logic [WIDTH-1:0] INIT_MAX = SIGNED ? {1'b1, {(WIDTH-1){1'b0}}} : '0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      peak_max <= INIT_MAX;
      peak_min <= INIT_MIN;
    end else if (clr) begin
      peak_max <= INIT_MAX;
      peak_min <= INIT_MIN;
    end else if (valid_in) begin
      if (SIGNED) begin
        if ($signed(sample_in) > $signed(peak_max)) peak_max <= sample_in;
        if ($signed(sample_in) < $signed(peak_min)) peak_min <= sample_in;
      end else begin
        if (sample_in > peak_max) peak_max <= sample_in;
        if (sample_in < peak_min) peak_min <= sample_in;
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_moving_average_filter #(
    .DATA_WIDTH(16),
    .WINDOW_SIZE(8)
) u_vrtl_moving_average_filter (
    .clk       (clk),
    .rst_n     (rst_n),
    .valid_in  (valid_in),
    .data_in   (data_in),
    .valid_out (valid_out),
    .data_out  (data_out)
);
*/
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


/*
// Instance Example:
vrtl_fir_filter_4tap #(
    .DATA_WIDTH(16),
    .COEFF_WIDTH(16),
    .C0(16'sd100),
    .C1(16'sd200),
    .C2(16'sd200),
    .C3(16'sd100)
) u_vrtl_fir_filter_4tap (
    .clk       (clk),
    .rst_n     (rst_n),
    .valid_in  (valid_in),
    .data_in   (data_in),
    .valid_out (valid_out),
    .data_out  (data_out)
);
*/
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


/*
// Instance Example:
vrtl_cordic_rotator #(
    .WIDTH(16),
    .ITERATIONS(16)
) u_vrtl_cordic_rotator (
    .clk      (clk),
    .rst_n    (rst_n),
    .start    (start),
    .x_in     (x_in),
    .y_in     (y_in),
    .z_in     (z_in),
    .x_out    (x_out),
    .y_out    (y_out),
    .z_out    (z_out),
    .busy     (busy),
    .done     (done)
);
*/
module vrtl_cordic_rotator #(
    parameter int WIDTH      = 16,
    parameter int ITERATIONS = 16,
    localparam int CNT_W     = $clog2(ITERATIONS + 1)
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    start,
    input  logic signed [WIDTH-1:0] x_in,
    input  logic signed [WIDTH-1:0] y_in,
    input  logic signed [WIDTH-1:0] z_in,
    output logic signed [WIDTH-1:0] x_out,
    output logic signed [WIDTH-1:0] y_out,
    output logic signed [WIDTH-1:0] z_out,
    output logic                    busy,
    output logic                    done
);
  logic signed [15:0] atan_table [16];
  initial begin
    atan_table[0]  = 16'd6434;
    atan_table[1]  = 16'd3799;
    atan_table[2]  = 16'd2007;
    atan_table[3]  = 16'd1019;
    atan_table[4]  = 16'd511;
    atan_table[5]  = 16'd256;
    atan_table[6]  = 16'd128;
    atan_table[7]  = 16'd64;
    atan_table[8]  = 16'd32;
    atan_table[9]  = 16'd16;
    atan_table[10] = 16'd8;
    atan_table[11] = 16'd4;
    atan_table[12] = 16'd2;
    atan_table[13] = 16'd1;
    atan_table[14] = 16'd0;
    atan_table[15] = 16'd0;
  end

  typedef enum logic [1:0] {
    IDLE = 2'b00,
    CALC = 2'b01,
    FINI = 2'b10
  } state_t;

  state_t state;
  logic [CNT_W-1:0] iter;
  logic signed [WIDTH-1:0] x_reg, y_reg, z_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      iter  <= '0;
      x_reg <= '0;
      y_reg <= '0;
      z_reg <= '0;
      x_out <= '0;
      y_out <= '0;
      z_out <= '0;
      busy  <= 1'b0;
      done  <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          done <= 1'b0;
          if (start) begin
            x_reg <= x_in;
            y_reg <= y_in;
            z_reg <= z_in;
            iter  <= '0;
            busy  <= 1'b1;
            state <= CALC;
          end
        end

        CALC: begin
          logic d;
          logic signed [WIDTH-1:0] x_shift, y_shift;

          d = z_reg[WIDTH-1];
          x_shift = x_reg >>> iter;
          y_shift = y_reg >>> iter;

          if (!d) begin
            x_reg <= x_reg - y_shift;
            y_reg <= y_reg + x_shift;
            z_reg <= z_reg - atan_table[iter];
          end else begin
            x_reg <= x_reg + y_shift;
            y_reg <= y_reg - x_shift;
            z_reg <= z_reg + atan_table[iter];
          end

          iter <= iter + 1'b1;
          if (iter == CNT_W'(ITERATIONS - 1)) begin
            state <= FINI;
          end
        end

        FINI: begin
          busy  <= 1'b0;
          done  <= 1'b1;
          x_out <= x_reg;
          y_out <= y_reg;
          z_out <= z_reg;
          state <= IDLE;
        end
      endcase
    end
  end
endmodule

`endif // VRTL_DSP_SV
