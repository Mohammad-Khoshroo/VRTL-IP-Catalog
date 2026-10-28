`ifndef MEMORY_ROMS_VRTL_ROM_SV
`define MEMORY_ROMS_VRTL_ROM_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_rom_async_256x8 u_vrtl_rom_async_256x8 (
//     .addr (addr),
//     .dout (dout)
// );
// =============================================================================
module vrtl_rom_async_256x8 (
    input  logic [7:0] addr,
    output logic [7:0] dout
);
  logic [7:0] mem [256];

  assign dout = mem[addr];
endmodule


// =============================================================================
// vrtl_rom_sync #(
//     .DATA_WIDTH (32),
//     .ADDR_WIDTH (8),
//     .DEPTH      ((1 << ADDR_WIDTH)),
//     .INIT_FILE  ("")
// ) u_vrtl_rom_sync (
//     .clk  (clk),
//     .en   (en),
//     .addr (addr),
//     .dout (dout)
// );
// =============================================================================
module vrtl_rom_sync #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 8,
    parameter int DEPTH      = (1 << ADDR_WIDTH),
    parameter string INIT_FILE = ""
)(
    input  logic                  clk,
    input  logic                  en,
    input  logic [ADDR_WIDTH-1:0] addr,
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
      dout <= mem[addr];
    end
  end
endmodule


// =============================================================================
// vrtl_rom_async #(
//     .DATA_WIDTH (32),
//     .ADDR_WIDTH (8),
//     .DEPTH      ((1 << ADDR_WIDTH)),
//     .INIT_FILE  ("")
// ) u_vrtl_rom_async (
//     .addr (addr),
//     .dout (dout)
// );
// =============================================================================
module vrtl_rom_async #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 8,
    parameter int DEPTH      = (1 << ADDR_WIDTH),
    parameter string INIT_FILE = ""
)(
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] dout
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end
  end

  assign dout = mem[addr];
endmodule

`endif // MEMORY_ROMS_VRTL_ROM_SV
