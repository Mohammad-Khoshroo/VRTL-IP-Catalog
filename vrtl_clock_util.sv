`ifndef VRTL_CLOCK_UTIL_SV
`define VRTL_CLOCK_UTIL_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Non-Parametric Clock Dividers & Gates
// =============================================================================

/*
// Instance Example:
vrtl_clock_divider_by2 u_vrtl_clock_divider_by2 (
    .clk_in  (clk_in),
    .rst_n   (rst_n),
    .clk_out (clk_out)
);
*/
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


/*
// Instance Example:
vrtl_clock_divider_by4 u_vrtl_clock_divider_by4 (
    .clk_in  (clk_in),
    .rst_n   (rst_n),
    .clk_out (clk_out)
);
*/
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


/*
// Instance Example:
vrtl_clock_gate u_vrtl_clock_gate (
    .clk_in  (clk_in),
    .en      (en),
    .test_en (test_en),
    .clk_out (clk_out)
);
*/
module vrtl_clock_gate (
    input  logic clk_in,
    input  logic en,
    input  logic test_en,
    output logic clk_out
);
  logic en_latched;

  always_latch begin
    if (!clk_in) begin
      en_latched <= en | test_en;
    end
  end

  assign clk_out = clk_in & en_latched;
endmodule


/*
// Instance Example:
vrtl_glitch_free_clock_mux u_vrtl_glitch_free_clock_mux (
    .clk0    (clk0),
    .rst0_n  (rst0_n),
    .clk1    (clk1),
    .rst1_n  (rst1_n),
    .sel     (sel),
    .clk_out (clk_out)
);
*/
module vrtl_glitch_free_clock_mux (
    input  logic clk0,
    input  logic rst0_n,
    input  logic clk1,
    input  logic rst1_n,
    input  logic sel,
    output logic clk_out
);
  logic q0_meta, q0;
  logic q1_meta, q1;

  always_ff @(posedge clk0 or negedge rst0_n) begin
    if (!rst0_n) begin
      q0_meta <= 1'b0;
      q0      <= 1'b0;
    end else begin
      q0_meta <= ~sel & ~q1;
      q0      <= q0_meta;
    end
  end

  always_ff @(posedge clk1 or negedge rst1_n) begin
    if (!rst1_n) begin
      q1_meta <= 1'b0;
      q1      <= 1'b0;
    end else begin
      q1_meta <= sel & ~q0;
      q1      <= q1_meta;
    end
  end

  assign clk_out = (clk0 & q0) | (clk1 & q1);
endmodule


// =============================================================================
// Parametric Clock Dividers & Generators
// =============================================================================

/*
// Instance Example:
vrtl_clock_enable_gen #(
    .PERIOD_CYCLES(100)
) u_vrtl_clock_enable_gen (
    .clk     (clk),
    .rst_n   (rst_n),
    .clk_en  (clk_en)
);
*/
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


/*
// Instance Example:
vrtl_clock_divider_even #(
    .DIV_BY(4)
) u_vrtl_clock_divider_even (
    .clk_in  (clk_in),
    .rst_n   (rst_n),
    .clk_out (clk_out)
);
*/
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


/*
// Instance Example:
vrtl_clock_divider_odd #(
    .DIV_BY(5)
) u_vrtl_clock_divider_odd (
    .clk_in  (clk_in),
    .rst_n   (rst_n),
    .clk_out (clk_out)
);
*/
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


/*
// Instance Example:
vrtl_clock_divider_frac #(
    .ACC_W(16)
) u_vrtl_clock_divider_frac (
    .clk     (clk),
    .rst_n   (rst_n),
    .step    (step),
    .pulse_en(pulse_en)
);
*/
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


/*
// Instance Example:
vrtl_pulse_stretcher #(
    .STRETCH_CYCLES(4)
) u_vrtl_pulse_stretcher (
    .clk        (clk),
    .rst_n      (rst_n),
    .pulse_in   (pulse_in),
    .pulse_out  (pulse_out)
);
*/
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

`endif // VRTL_CLOCK_UTIL_SV
