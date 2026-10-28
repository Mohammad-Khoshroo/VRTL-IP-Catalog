`ifndef DSP_VRTL_DSP_CORDIC_SV
`define DSP_VRTL_DSP_CORDIC_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_cordic_rotator #(
//     .WIDTH      (16),
//     .ITERATIONS (16)
// ) u_vrtl_cordic_rotator (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .start (start),
//     .x_in  (x_in),
//     .y_in  (y_in),
//     .z_in  (z_in),
//     .x_out (x_out),
//     .y_out (y_out),
//     .z_out (z_out),
//     .busy  (busy),
//     .done  (done)
// );
// =============================================================================
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


// =============================================================================
// vrtl_peak_detector #(
//     .WIDTH  (16),
//     .SIGNED (1)
// ) u_vrtl_peak_detector (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .clr       (clr),
//     .valid_in  (valid_in),
//     .sample_in (sample_in),
//     .peak_max  (peak_max),
//     .peak_min  (peak_min)
// );
// =============================================================================
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

`endif // DSP_VRTL_DSP_CORDIC_SV
