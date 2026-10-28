`ifndef VRTL_DFF_SV
`define VRTL_DFF_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Basic Latches (SR & Gated D)
// =============================================================================

/*
// Instance Example:
vrtl_sr_latch_nor u_vrtl_sr_latch_nor (
    .s   (s),
    .r   (r),
    .q   (q),
    .q_n (q_n)
);
*/
module vrtl_sr_latch_nor (
    input  logic s,
    input  logic r,
    output logic q,
    output logic q_n
);
  always_latch begin
    if (r) begin
      q   <= 1'b0;
      q_n <= 1'b1;
    end else if (s) begin
      q   <= 1'b1;
      q_n <= 1'b0;
    end
  end
endmodule


/*
// Instance Example:
vrtl_sr_latch_nand u_vrtl_sr_latch_nand (
    .s_n (s_n),
    .r_n (r_n),
    .q   (q),
    .q_n (q_n)
);
*/
module vrtl_sr_latch_nand (
    input  logic s_n,
    input  logic r_n,
    output logic q,
    output logic q_n
);
  always_latch begin
    if (!r_n) begin
      q   <= 1'b0;
      q_n <= 1'b1;
    end else if (!s_n) begin
      q   <= 1'b1;
      q_n <= 1'b0;
    end
  end
endmodule


/*
// Instance Example:
vrtl_d_latch u_vrtl_d_latch (
    .en (en),
    .d  (d),
    .q  (q)
);
*/
module vrtl_d_latch (
    input  logic en,
    input  logic d,
    output logic q
);
  always_latch begin
    if (en) begin
      q <= d;
    end
  end
endmodule


// =============================================================================
// Non-Parametric Flip-Flops (D, T, JK, Scan, Dual-Edge)
// =============================================================================

/*
// Instance Example:
vrtl_dff u_vrtl_dff (
    .clk (clk),
    .d   (d),
    .q   (q)
);
*/
module vrtl_dff (
    input  logic clk,
    input  logic d,
    output logic q
);
  always_ff @(posedge clk) begin
    q <= d;
  end
endmodule


/*
// Instance Example:
vrtl_dff_ar u_vrtl_dff_ar (
    .clk   (clk),
    .rst_n (rst_n),
    .d     (d),
    .q     (q)
);
*/
module vrtl_dff_ar (
    input  logic clk,
    input  logic rst_n,
    input  logic d,
    output logic q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 1'b0;
    end else begin
      q <= d;
    end
  end
endmodule


/*
// Instance Example:
vrtl_dff_sr u_vrtl_dff_sr (
    .clk   (clk),
    .rst_n (rst_n),
    .d     (d),
    .q     (q)
);
*/
module vrtl_dff_sr (
    input  logic clk,
    input  logic rst_n,
    input  logic d,
    output logic q
);
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      q <= 1'b0;
    end else begin
      q <= d;
    end
  end
endmodule


/*
// Instance Example:
vrtl_dff_en u_vrtl_dff_en (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .d     (d),
    .q     (q)
);
*/
module vrtl_dff_en (
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    input  logic d,
    output logic q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 1'b0;
    end else if (en) begin
      q <= d;
    end
  end
endmodule


/*
// Instance Example:
vrtl_dff_scan u_vrtl_dff_scan (
    .clk     (clk),
    .rst_n   (rst_n),
    .scan_en (scan_en),
    .scan_in (scan_in),
    .d       (d),
    .q       (q)
);
*/
module vrtl_dff_scan (
    input  logic clk,
    input  logic rst_n,
    input  logic scan_en,
    input  logic scan_in,
    input  logic d,
    output logic q
);
  wire mux_d = scan_en ? scan_in : d;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 1'b0;
    end else begin
      q <= mux_d;
    end
  end
endmodule


/*
// Instance Example:
vrtl_dff_dual_edge u_vrtl_dff_dual_edge (
    .clk   (clk),
    .rst_n (rst_n),
    .d     (d),
    .q     (q)
);
*/
module vrtl_dff_dual_edge (
    input  logic clk,
    input  logic rst_n,
    input  logic d,
    output logic q
);
  logic q_pos, q_neg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) q_pos <= 1'b0;
    else        q_pos <= d ^ q_neg;
  end

  always_ff @(negedge clk or negedge rst_n) begin
    if (!rst_n) q_neg <= 1'b0;
    else        q_neg <= d ^ q_pos;
  end

  assign q = q_pos ^ q_neg;
endmodule


/*
// Instance Example:
vrtl_tff u_vrtl_tff (
    .clk   (clk),
    .rst_n (rst_n),
    .t     (t),
    .q     (q)
);
*/
module vrtl_tff (
    input  logic clk,
    input  logic rst_n,
    input  logic t,
    output logic q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 1'b0;
    end else if (t) begin
      q <= ~q;
    end
  end
endmodule


/*
// Instance Example:
vrtl_jkff u_vrtl_jkff (
    .clk   (clk),
    .rst_n (rst_n),
    .j     (j),
    .k     (k),
    .q     (q)
);
*/
module vrtl_jkff (
    input  logic clk,
    input  logic rst_n,
    input  logic j,
    input  logic k,
    output logic q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 1'b0;
    end else begin
      case ({j, k})
        2'b00: q <= q;
        2'b01: q <= 1'b0;
        2'b10: q <= 1'b1;
        2'b11: q <= ~q;
      endcase
    end
  end
endmodule


// =============================================================================
// Parametric Flip-Flops & Registers
// =============================================================================

/*
// Instance Example:
vrtl_dff_n #(
    .WIDTH(8),
    .RESET_VAL('0)
) u_vrtl_dff_n (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .d     (d),
    .q     (q)
);
*/
module vrtl_dff_n #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] RESET_VAL = '0
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= RESET_VAL;
    end else if (en) begin
      q <= d;
    end
  end
endmodule


/*
// Instance Example:
vrtl_dff_sync_n #(
    .WIDTH(8),
    .RESET_VAL('0)
) u_vrtl_dff_sync_n (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .d     (d),
    .q     (q)
);
*/
module vrtl_dff_sync_n #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] RESET_VAL = '0
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      q <= RESET_VAL;
    end else if (en) begin
      q <= d;
    end
  end
endmodule

`endif // VRTL_DFF_SV
