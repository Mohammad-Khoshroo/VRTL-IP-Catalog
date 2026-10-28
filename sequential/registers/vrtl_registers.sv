`ifndef SEQUENTIAL_REGISTERS_VRTL_REGISTERS_SV
`define SEQUENTIAL_REGISTERS_VRTL_REGISTERS_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_reg_8b u_vrtl_reg_8b (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .en    (en),
//     .clr   (clr),
//     .d     (d),
//     .q     (q)
// );
// =============================================================================
module vrtl_reg_8b (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    input  logic       clr,
    input  logic [7:0] d,
    output logic [7:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 8'h00;
    end else if (clr) begin
      q <= 8'h00;
    end else if (en) begin
      q <= d;
    end
  end
endmodule


// =============================================================================
// vrtl_reg_16b u_vrtl_reg_16b (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .en    (en),
//     .clr   (clr),
//     .d     (d),
//     .q     (q)
// );
// =============================================================================
module vrtl_reg_16b (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic        clr,
    input  logic [15:0] d,
    output logic [15:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 16'h0000;
    end else if (clr) begin
      q <= 16'h0000;
    end else if (en) begin
      q <= d;
    end
  end
endmodule


// =============================================================================
// vrtl_reg_32b u_vrtl_reg_32b (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .en    (en),
//     .clr   (clr),
//     .d     (d),
//     .q     (q)
// );
// =============================================================================
module vrtl_reg_32b (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    input  logic        clr,
    input  logic [31:0] d,
    output logic [31:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= 32'h0000_0000;
    end else if (clr) begin
      q <= 32'h0000_0000;
    end else if (en) begin
      q <= d;
    end
  end
endmodule


// =============================================================================
// vrtl_reg #(
//     .WIDTH     (32),
//     .RESET_VAL ('0)
// ) u_vrtl_reg (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .en    (en),
//     .clr   (clr),
//     .d     (d),
//     .q     (q)
// );
// =============================================================================
module vrtl_reg #(
    parameter int WIDTH = 32,
    parameter logic [WIDTH-1:0] RESET_VAL = '0
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic             clr,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= RESET_VAL;
    end else if (clr) begin
      q <= RESET_VAL;
    end else if (en) begin
      q <= d;
    end
  end
endmodule


// =============================================================================
// vrtl_reg_byte_en #(
//     .NUM_BYTES  (4),
//     .BYTE_WIDTH (8)
// ) u_vrtl_reg_byte_en (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .byte_en (byte_en),
//     .d       (d),
//     .q       (q)
// );
// =============================================================================
module vrtl_reg_byte_en #(
    parameter int NUM_BYTES  = 4,
    parameter int BYTE_WIDTH = 8,
    localparam int TOTAL_W   = NUM_BYTES * BYTE_WIDTH
)(
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic [NUM_BYTES-1:0] byte_en,
    input  logic [TOTAL_W-1:0]   d,
    output logic [TOTAL_W-1:0]   q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      q <= '0;
    end else begin
      for (int i = 0; i < NUM_BYTES; i = i + 1) begin
        if (byte_en[i]) begin
          q[i*BYTE_WIDTH +: BYTE_WIDTH] <= d[i*BYTE_WIDTH +: BYTE_WIDTH];
        end
      end
    end
  end
endmodule


// =============================================================================
// vrtl_reg_shadow #(
//     .WIDTH (32)
// ) u_vrtl_reg_shadow (
//     .clk        (clk),
//     .rst_n      (rst_n),
//     .wr_en      (wr_en),
//     .d          (d),
//     .commit     (commit),
//     .active_out (active_out)
// );
// =============================================================================
module vrtl_reg_shadow #(
    parameter int WIDTH = 32
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             wr_en,
    input  logic [WIDTH-1:0] d,
    input  logic             commit,
    output logic [WIDTH-1:0] active_out
);
  logic [WIDTH-1:0] shadow_reg;
  logic [WIDTH-1:0] active_reg;

  assign active_out = active_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shadow_reg <= '0;
      active_reg <= '0;
    end else begin
      if (wr_en) begin
        shadow_reg <= d;
      end
      if (commit) begin
        active_reg <= wr_en ? d : shadow_reg;
      end
    end
  end
endmodule

`endif // SEQUENTIAL_REGISTERS_VRTL_REGISTERS_SV
