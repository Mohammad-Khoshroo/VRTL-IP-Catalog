`ifndef VRTL_MEMORY_SV
`define VRTL_MEMORY_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// -----------------------------------------------------------------------------
// Non-Parametric Memories
// -----------------------------------------------------------------------------

/*
// Instance Example:
vrtl_ram_sp_256x8 u_vrtl_ram_sp_256x8 (
    .clk  (clk),
    .en   (en),
    .we   (we),
    .addr (addr),
    .din  (din),
    .dout (dout)
);
*/
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


/*
// Instance Example:
vrtl_rom_async_256x8 u_vrtl_rom_async_256x8 (
    .addr (addr),
    .dout (dout)
);
*/
module vrtl_rom_async_256x8 (
    input  logic [7:0] addr,
    output logic [7:0] dout
);
  logic [7:0] mem [256];

  assign dout = mem[addr];
endmodule


// -----------------------------------------------------------------------------
// Parametric Memories
// -----------------------------------------------------------------------------

/*
// Instance Example:
vrtl_ram_sp_sync #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8),
    .DEPTH(256),
    .INIT_FILE("")
) u_vrtl_ram_sp_sync (
    .clk  (clk),
    .en   (en),
    .we   (we),
    .addr (addr),
    .din  (din),
    .dout (dout)
);
*/
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


/*
// Instance Example:
vrtl_ram_sp_byte_en #(
    .BYTES(4),
    .ADDR_WIDTH(8),
    .DEPTH(256)
) u_vrtl_ram_sp_byte_en (
    .clk     (clk),
    .en      (en),
    .byte_en (byte_en),
    .addr    (addr),
    .din     (din),
    .dout    (dout)
);
*/
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


/*
// Instance Example:
vrtl_ram_dp_sync #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8),
    .DEPTH(256),
    .INIT_FILE("")
) u_vrtl_ram_dp_sync (
    .clk     (clk),
    .wr_en   (wr_en),
    .wr_addr (wr_addr),
    .wr_data (wr_data),
    .rd_en   (rd_en),
    .rd_addr (rd_addr),
    .rd_data (rd_data)
);
*/
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


/*
// Instance Example:
vrtl_ram_tdp_sync #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8),
    .DEPTH(256),
    .INIT_FILE("")
) u_vrtl_ram_tdp_sync (
    .clk_a   (clk_a),
    .en_a    (en_a),
    .we_a    (we_a),
    .addr_a  (addr_a),
    .din_a   (din_a),
    .dout_a  (dout_a),
    .clk_b   (clk_b),
    .en_b    (en_b),
    .we_b    (we_b),
    .addr_b  (addr_b),
    .din_b   (din_b),
    .dout_b  (dout_b)
);
*/
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


/*
// Instance Example:
vrtl_ram_tdp_byte_en #(
    .BYTES(4),
    .ADDR_WIDTH(8),
    .DEPTH(256)
) u_vrtl_ram_tdp_byte_en (
    .clk_a     (clk_a),
    .en_a      (en_a),
    .byte_en_a (byte_en_a),
    .addr_a    (addr_a),
    .din_a     (din_a),
    .dout_a    (dout_a),
    .clk_b     (clk_b),
    .en_b      (en_b),
    .byte_en_b (byte_en_b),
    .addr_b    (addr_b),
    .din_b     (din_b),
    .dout_b    (dout_b)
);
*/
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


/*
// Instance Example:
vrtl_ram_async_read #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(6),
    .DEPTH(64)
) u_vrtl_ram_async_read (
    .clk     (clk),
    .wr_en   (wr_en),
    .wr_addr (wr_addr),
    .wr_data (wr_data),
    .rd_addr (rd_addr),
    .rd_data (rd_data)
);
*/
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


/*
// Instance Example:
vrtl_rom_sync #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8),
    .DEPTH(256),
    .INIT_FILE("rom_data.mem")
) u_vrtl_rom_sync (
    .clk  (clk),
    .en   (en),
    .addr (addr),
    .dout (dout)
);
*/
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


/*
// Instance Example:
vrtl_rom_async #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8),
    .DEPTH(256),
    .INIT_FILE("rom_data.mem")
) u_vrtl_rom_async (
    .addr (addr),
    .dout (dout)
);
*/
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

`endif // VRTL_MEMORY_SV
