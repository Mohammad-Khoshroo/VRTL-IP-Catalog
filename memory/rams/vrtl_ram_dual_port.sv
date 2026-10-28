`ifndef MEMORY_RAMS_VRTL_RAM_DUAL_PORT_SV
`define MEMORY_RAMS_VRTL_RAM_DUAL_PORT_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_ram_dp_sync #(
//     .DATA_WIDTH (32),
//     .ADDR_WIDTH (8),
//     .DEPTH      ((1 << ADDR_WIDTH)),
//     .INIT_FILE  ("")
// ) u_vrtl_ram_dp_sync (
//     .clk     (clk),
//     .wr_en   (wr_en),
//     .wr_addr (wr_addr),
//     .wr_data (wr_data),
//     .rd_en   (rd_en),
//     .rd_addr (rd_addr),
//     .rd_data (rd_data)
// );
// =============================================================================
module vrtl_ram_dp_sync #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 8,
    parameter int DEPTH      = (1 << ADDR_WIDTH),
    parameter string INIT_FILE = ""
)(
    input  logic                  clk,
    input  logic                  wr_en,
    input  logic [ADDR_WIDTH-1:0] wr_addr,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic                  rd_en,
    input  logic [ADDR_WIDTH-1:0] rd_addr,
    output logic [DATA_WIDTH-1:0] rd_data
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end
  end

  always_ff @(posedge clk) begin
    if (wr_en) begin
      mem[wr_addr] <= wr_data;
    end
  end

  always_ff @(posedge clk) begin
    if (rd_en) begin
      rd_data <= mem[rd_addr];
    end
  end
endmodule


// =============================================================================
// vrtl_ram_async_read #(
//     .DATA_WIDTH (32),
//     .ADDR_WIDTH (6),
//     .DEPTH      ((1 << ADDR_WIDTH))
// ) u_vrtl_ram_async_read (
//     .clk     (clk),
//     .wr_en   (wr_en),
//     .wr_addr (wr_addr),
//     .wr_data (wr_data),
//     .rd_addr (rd_addr),
//     .rd_data (rd_data)
// );
// =============================================================================
module vrtl_ram_async_read #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 6,
    parameter int DEPTH      = (1 << ADDR_WIDTH)
)(
    input  logic                  clk,
    input  logic                  wr_en,
    input  logic [ADDR_WIDTH-1:0] wr_addr,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic [ADDR_WIDTH-1:0] rd_addr,
    output logic [DATA_WIDTH-1:0] rd_data
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  always_ff @(posedge clk) begin
    if (wr_en) begin
      mem[wr_addr] <= wr_data;
    end
  end

  assign rd_data = mem[rd_addr];
endmodule

`endif // MEMORY_RAMS_VRTL_RAM_DUAL_PORT_SV
