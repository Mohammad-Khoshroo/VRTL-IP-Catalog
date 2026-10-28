`ifndef MEMORY_RAMS_VRTL_RAM_TRUE_DUAL_PORT_SV
`define MEMORY_RAMS_VRTL_RAM_TRUE_DUAL_PORT_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_ram_tdp_sync #(
//     .DATA_WIDTH (32),
//     .ADDR_WIDTH (8),
//     .DEPTH      ((1 << ADDR_WIDTH)),
//     .INIT_FILE  ("")
// ) u_vrtl_ram_tdp_sync (
//     .clk_a  (clk_a),
//     .en_a   (en_a),
//     .we_a   (we_a),
//     .addr_a (addr_a),
//     .din_a  (din_a),
//     .dout_a (dout_a),
//     .clk_b  (clk_b),
//     .en_b   (en_b),
//     .we_b   (we_b),
//     .addr_b (addr_b),
//     .din_b  (din_b),
//     .dout_b (dout_b)
// );
// =============================================================================
module vrtl_ram_tdp_sync #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 8,
    parameter int DEPTH      = (1 << ADDR_WIDTH),
    parameter string INIT_FILE = ""
)(
    input  logic                  clk_a,
    input  logic                  en_a,
    input  logic                  we_a,
    input  logic [ADDR_WIDTH-1:0] addr_a,
    input  logic [DATA_WIDTH-1:0] din_a,
    output logic [DATA_WIDTH-1:0] dout_a,
    input  logic                  clk_b,
    input  logic                  en_b,
    input  logic                  we_b,
    input  logic [ADDR_WIDTH-1:0] addr_b,
    input  logic [DATA_WIDTH-1:0] din_b,
    output logic [DATA_WIDTH-1:0] dout_b
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end
  end

  always_ff @(posedge clk_a) begin
    if (en_a) begin
      if (we_a) begin
        mem[addr_a] <= din_a;
      end
      dout_a <= mem[addr_a];
    end
  end

  always_ff @(posedge clk_b) begin
    if (en_b) begin
      if (we_b) begin
        mem[addr_b] <= din_b;
      end
      dout_b <= mem[addr_b];
    end
  end
endmodule


// =============================================================================
// vrtl_ram_tdp_byte_en #(
//     .BYTES      (4),
//     .ADDR_WIDTH (8),
//     .DEPTH      ((1 << ADDR_WIDTH))
// ) u_vrtl_ram_tdp_byte_en (
//     .clk_a     (clk_a),
//     .en_a      (en_a),
//     .byte_en_a (byte_en_a),
//     .addr_a    (addr_a),
//     .din_a     (din_a),
//     .dout_a    (dout_a),
//     .clk_b     (clk_b),
//     .en_b      (en_b),
//     .byte_en_b (byte_en_b),
//     .addr_b    (addr_b),
//     .din_b     (din_b),
//     .dout_b    (dout_b)
// );
// =============================================================================
module vrtl_ram_tdp_byte_en #(
    parameter int BYTES      = 4,
    parameter int ADDR_WIDTH = 8,
    parameter int DEPTH      = (1 << ADDR_WIDTH)
)(
    input  logic                  clk_a,
    input  logic                  en_a,
    input  logic [BYTES-1:0]      byte_en_a,
    input  logic [ADDR_WIDTH-1:0] addr_a,
    input  logic [BYTES*8-1:0]    din_a,
    output logic [BYTES*8-1:0]    dout_a,
    input  logic                  clk_b,
    input  logic                  en_b,
    input  logic [BYTES-1:0]      byte_en_b,
    input  logic [ADDR_WIDTH-1:0] addr_b,
    input  logic [BYTES*8-1:0]    din_b,
    output logic [BYTES*8-1:0]    dout_b
);
  logic [7:0] mem [DEPTH][BYTES];

  always_ff @(posedge clk_a) begin
    if (en_a) begin
      for (int i = 0; i < BYTES; i = i + 1) begin
        if (byte_en_a[i]) begin
          mem[addr_a][i] <= din_a[i*8 +: 8];
        end
        dout_a[i*8 +: 8] <= mem[addr_a][i];
      end
    end
  end

  always_ff @(posedge clk_b) begin
    if (en_b) begin
      for (int i = 0; i < BYTES; i = i + 1) begin
        if (byte_en_b[i]) begin
          mem[addr_b][i] <= din_b[i*8 +: 8];
        end
        dout_b[i*8 +: 8] <= mem[addr_b][i];
      end
    end
  end
endmodule

`endif // MEMORY_RAMS_VRTL_RAM_TRUE_DUAL_PORT_SV
