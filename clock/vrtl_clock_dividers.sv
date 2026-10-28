`ifndef CLOCK_VRTL_CLOCK_DIVIDERS_SV
`define CLOCK_VRTL_CLOCK_DIVIDERS_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_clock_divider_by2 u_vrtl_clock_divider_by2 (
//     .clk_in  (clk_in),
//     .rst_n   (rst_n),
//     .clk_out (clk_out)
// );
// =============================================================================
module vrtl_clock_divider_by2 (
    input  logic clk_in,
    input  logic rst_n,
    output logic clk_out
);
  always_ff @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
      clk_out <= 1'b0;
    end else begin
      clk_out <= ~clk_out;
    end
  end
endmodule


// =============================================================================
// vrtl_clock_divider_by4 u_vrtl_clock_divider_by4 (
//     .clk_in  (clk_in),
//     .rst_n   (rst_n),
//     .clk_out (clk_out)
// );
// =============================================================================
module vrtl_clock_divider_by4 (
    input  logic clk_in,
    input  logic rst_n,
    output logic clk_out
);
  logic div2;

  always_ff @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
      div2    <= 1'b0;
      clk_out <= 1'b0;
    end else begin
      div2 <= ~div2;
      if (div2) begin
        clk_out <= ~clk_out;
      end
    end
  end
endmodule


// =============================================================================
// vrtl_clock_enable_gen #(
//     .PERIOD_CYCLES (100)
// ) u_vrtl_clock_enable_gen (
//     .clk    (clk),
//     .rst_n  (rst_n),
//     .clk_en (clk_en)
// );
// =============================================================================
module vrtl_clock_enable_gen #(
    parameter int PERIOD_CYCLES = 100,
    localparam int CNT_W = $clog2(PERIOD_CYCLES + 1)
)(
    input  logic clk,
    input  logic rst_n,
    output logic clk_en
);
  logic [CNT_W-1:0] cnt;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt    <= '0;
      clk_en <= 1'b0;
    end else begin
      if (cnt == CNT_W'(PERIOD_CYCLES - 1)) begin
        cnt    <= '0;
        clk_en <= 1'b1;
      end else begin
        cnt    <= cnt + 1'b1;
        clk_en <= 1'b0;
      end
    end
  end
endmodule


// =============================================================================
// vrtl_clock_divider_even #(
//     .DIV_BY (4)
// ) u_vrtl_clock_divider_even (
//     .clk_in  (clk_in),
//     .rst_n   (rst_n),
//     .clk_out (clk_out)
// );
// =============================================================================
module vrtl_clock_divider_even #(
    parameter int DIV_BY = 4,
    localparam int CNT_W = $clog2(DIV_BY / 2)
)(
    input  logic clk_in,
    input  logic rst_n,
    output logic clk_out
);
  logic [CNT_W-1:0] cnt;

  always_ff @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
      cnt     <= '0;
      clk_out <= 1'b0;
    end else begin
      if (cnt == CNT_W'((DIV_BY / 2) - 1)) begin
        cnt     <= '0;
        clk_out <= ~clk_out;
      end else begin
        cnt <= cnt + 1'b1;
      end
    end
  end
endmodule


// =============================================================================
// vrtl_clock_divider_odd #(
//     .DIV_BY (5)
// ) u_vrtl_clock_divider_odd (
//     .clk_in  (clk_in),
//     .rst_n   (rst_n),
//     .clk_out (clk_out)
// );
// =============================================================================
module vrtl_clock_divider_odd #(
    parameter int DIV_BY = 5,
    localparam int CNT_W = $clog2(DIV_BY)
)(
    input  logic clk_in,
    input  logic rst_n,
    output logic clk_out
);
  logic [CNT_W-1:0] pos_cnt;
  logic [CNT_W-1:0] neg_cnt;
  logic pos_clk;
  logic neg_clk;

  always_ff @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
      pos_cnt <= '0;
      pos_clk <= 1'b0;
    end else begin
      if (pos_cnt == CNT_W'(DIV_BY - 1)) begin
        pos_cnt <= '0;
      end else begin
        pos_cnt <= pos_cnt + 1'b1;
      end
      if (pos_cnt == CNT_W'((DIV_BY - 1) / 2)) begin
        pos_clk <= 1'b1;
      end else if (pos_cnt == '0) begin
        pos_clk <= 1'b0;
      end
    end
  end

  always_ff @(negedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
      neg_cnt <= '0;
      neg_clk <= 1'b0;
    end else begin
      if (neg_cnt == CNT_W'(DIV_BY - 1)) begin
        neg_cnt <= '0;
      end else begin
        neg_cnt <= neg_cnt + 1'b1;
      end
      if (neg_cnt == CNT_W'((DIV_BY - 1) / 2)) begin
        neg_clk <= 1'b1;
      end else if (neg_cnt == '0) begin
        neg_clk <= 1'b0;
      end
    end
  end

  assign clk_out = pos_clk | neg_clk;
endmodule


// =============================================================================
// vrtl_clock_divider_frac #(
//     .ACC_W (16)
// ) u_vrtl_clock_divider_frac (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .step     (step),
//     .pulse_en (pulse_en)
// );
// =============================================================================
module vrtl_clock_divider_frac #(
    parameter int ACC_W = 16
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [ACC_W-1:0] step,
    output logic             pulse_en
);
  logic [ACC_W:0] acc;

  assign pulse_en = acc[ACC_W];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      acc <= '0;
    end else begin
      acc <= {1'b0, acc[ACC_W-1:0]} + {1'b0, step};
    end
  end
endmodule


// =============================================================================
// vrtl_pulse_stretcher #(
//     .STRETCH_CYCLES (4)
// ) u_vrtl_pulse_stretcher (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .pulse_in  (pulse_in),
//     .pulse_out (pulse_out)
// );
// =============================================================================
module vrtl_pulse_stretcher #(
    parameter int STRETCH_CYCLES = 4,
    localparam int CNT_W = $clog2(STRETCH_CYCLES + 1)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic pulse_in,
    output logic pulse_out
);
  logic [CNT_W-1:0] cnt;

  assign pulse_out = (cnt > 0) || pulse_in;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= '0;
    end else begin
      if (pulse_in) begin
        cnt <= CNT_W'(STRETCH_CYCLES);
      end else if (cnt > 0) begin
        cnt <= cnt - 1'b1;
      end
    end
  end
endmodule

`endif // CLOCK_VRTL_CLOCK_DIVIDERS_SV
