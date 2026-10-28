`ifndef MEMORY_RAMS_VRTL_RAM_SINGLE_PORT_SV
`define MEMORY_RAMS_VRTL_RAM_SINGLE_PORT_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_ram_sp_256x8 u_vrtl_ram_sp_256x8 (
//     .clk  (clk),
//     .en   (en),
//     .we   (we),
//     .addr (addr),
//     .din  (din),
//     .dout (dout)
// );
// =============================================================================
module vrtl_ram_sp_256x8 (
    input  logic       clk,
    input  logic       en,
    input  logic       we,
    input  logic [7:0] addr,
    input  logic [7:0] din,
    output logic [7:0] dout
);
  logic [7:0] mem [256];

  always_ff @(posedge clk) begin
    if (en) begin
      if (we) begin
        mem[addr] <= din;
      end
      dout <= mem[addr];
    end
  end
endmodule


// =============================================================================
// vrtl_ram_sp_sync #(
//     .DATA_WIDTH (32),
//     .ADDR_WIDTH (8),
//     .DEPTH      ((1 << ADDR_WIDTH)),
//     .INIT_FILE  ("")
// ) u_vrtl_ram_sp_sync (
//     .clk  (clk),
//     .en   (en),
//     .we   (we),
//     .addr (addr),
//     .din  (din),
//     .dout (dout)
// );
// =============================================================================
module vrtl_ram_sp_sync #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 8,
    parameter int DEPTH      = (1 << ADDR_WIDTH),
    parameter string INIT_FILE = ""
)(
    input  logic                  clk,
    input  logic                  en,
    input  logic                  we,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end
  end

  always_ff @(posedge clk) begin
    if (en) begin
      if (we) begin
        mem[addr] <= din;
      end
      dout <= mem[addr];
    end
  end
endmodule


// =============================================================================
// vrtl_ram_sp_byte_en #(
//     .BYTES      (4),
//     .ADDR_WIDTH (8),
//     .DEPTH      ((1 << ADDR_WIDTH))
// ) u_vrtl_ram_sp_byte_en (
//     .clk     (clk),
//     .en      (en),
//     .byte_en (byte_en),
//     .addr    (addr),
//     .din     (din),
//     .dout    (dout)
// );
// =============================================================================
module vrtl_ram_sp_byte_en #(
    parameter int BYTES      = 4,
    parameter int ADDR_WIDTH = 8,
    parameter int DEPTH      = (1 << ADDR_WIDTH)
)(
    input  logic                  clk,
    input  logic                  en,
    input  logic [BYTES-1:0]      byte_en,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [BYTES*8-1:0]    din,
    output logic [BYTES*8-1:0]    dout
);
  logic [7:0] mem [DEPTH][BYTES];

  always_ff @(posedge clk) begin
    if (en) begin
      for (int i = 0; i < BYTES; i = i + 1) begin
        if (byte_en[i]) begin
          mem[addr][i] <= din[i*8 +: 8];
        end
        dout[i*8 +: 8] <= mem[addr][i];
      end
    end
  end
endmodule

`endif // MEMORY_RAMS_VRTL_RAM_SINGLE_PORT_SV
