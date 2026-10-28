`ifndef VRTL_LFSR_SV
`define VRTL_LFSR_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Non-Parametric LFSR & PRBS Generators
// =============================================================================

/*
// Instance Example:
vrtl_lfsr_4b u_vrtl_lfsr_4b (
    .clk      (clk),
    .rst_n    (rst_n),
    .en       (en),
    .data_out (data_out)
);
*/
module vrtl_lfsr_4b (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic [3:0] data_out
);
  logic [3:0] lfsr;
  wire fb = lfsr[3] ^ lfsr[2]; // x^4 + x^3 + 1

  assign data_out = lfsr;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lfsr <= 4'h1;
    end else if (en) begin
      lfsr <= {lfsr[2:0], fb};
    end
  end
endmodule


/*
// Instance Example:
vrtl_lfsr_8b u_vrtl_lfsr_8b (
    .clk      (clk),
    .rst_n    (rst_n),
    .en       (en),
    .data_out (data_out)
);
*/
module vrtl_lfsr_8b (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic [7:0] data_out
);
  vrtl_lfsr_galois #(
      .WIDTH(8),
      .POLY(8'hB8),
      .SEED(8'hA5)
  ) u_lfsr8 (
      .clk      (clk),
      .rst_n    (rst_n),
      .en       (en),
      .load     (1'b0),
      .pload    (8'h00),
      .data_out (data_out)
  );
endmodule


/*
// Instance Example:
vrtl_lfsr_16b u_vrtl_lfsr_16b (
    .clk      (clk),
    .rst_n    (rst_n),
    .en       (en),
    .data_out (data_out)
);
*/
module vrtl_lfsr_16b (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    output logic [15:0] data_out
);
  vrtl_lfsr_galois #(
      .WIDTH(16),
      .POLY(16'hA300),
      .SEED(16'hACE1)
  ) u_lfsr16 (
      .clk      (clk),
      .rst_n    (rst_n),
      .en       (en),
      .load     (1'b0),
      .pload    (16'h0000),
      .data_out (data_out)
  );
endmodule


/*
// Instance Example:
vrtl_lfsr_32b u_vrtl_lfsr_32b (
    .clk      (clk),
    .rst_n    (rst_n),
    .en       (en),
    .data_out (data_out)
);
*/
module vrtl_lfsr_32b (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    output logic [31:0] data_out
);
  vrtl_lfsr_galois #(
      .WIDTH(32),
      .POLY(32'h8020_0003),
      .SEED(32'hCAFE_BABE)
  ) u_lfsr32 (
      .clk      (clk),
      .rst_n    (rst_n),
      .en       (en),
      .load     (1'b0),
      .pload    (32'h0000_0000),
      .data_out (data_out)
  );
endmodule


/*
// Instance Example:
vrtl_prbs7 u_vrtl_prbs7 (
    .clk     (clk),
    .rst_n   (rst_n),
    .en      (en),
    .bit_out (bit_out)
);
*/
module vrtl_prbs7 (
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    output logic bit_out
);
  logic [6:0] lfsr;
  wire fb = lfsr[6] ^ lfsr[5]; // x^7 + x^6 + 1

  assign bit_out = fb;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lfsr <= 7'h7F;
    end else if (en) begin
      lfsr <= {lfsr[5:0], fb};
    end
  end
endmodule


/*
// Instance Example:
vrtl_prbs15 u_vrtl_prbs15 (
    .clk     (clk),
    .rst_n   (rst_n),
    .en      (en),
    .bit_out (bit_out)
);
*/
module vrtl_prbs15 (
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    output logic bit_out
);
  logic [14:0] lfsr;
  wire fb = lfsr[14] ^ lfsr[13]; // x^15 + x^14 + 1

  assign bit_out = fb;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lfsr <= 15'h7FFF;
    end else if (en) begin
      lfsr <= {lfsr[13:0], fb};
    end
  end
endmodule


/*
// Instance Example:
vrtl_prbs31 u_vrtl_prbs31 (
    .clk     (clk),
    .rst_n   (rst_n),
    .en      (en),
    .bit_out (bit_out)
);
*/
module vrtl_prbs31 (
    input  logic clk,
    input  logic rst_n,
    input  logic en,
    output logic bit_out
);
  logic [30:0] lfsr;
  wire fb = lfsr[30] ^ lfsr[27]; // x^31 + x^28 + 1

  assign bit_out = fb;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lfsr <= 31'h7FFF_FFFF;
    end else if (en) begin
      lfsr <= {lfsr[29:0], fb};
    end
  end
endmodule


// =============================================================================
// Parametric Linear Feedback Shift Registers
// =============================================================================

/*
// Instance Example:
vrtl_lfsr_fibonacci #(
    .WIDTH(8),
    .TAPS(8'hB8),
    .SEED(8'h01)
) u_vrtl_lfsr_fibonacci (
    .clk      (clk),
    .rst_n    (rst_n),
    .en       (en),
    .load     (load),
    .pload    (pload),
    .data_out (data_out)
);
*/
module vrtl_lfsr_fibonacci #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] TAPS = 8'hB8,
    parameter logic [WIDTH-1:0] SEED = 8'h01
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic             load,
    input  logic [WIDTH-1:0] pload,
    output logic [WIDTH-1:0] data_out
);
  logic [WIDTH-1:0] lfsr;
  wire fb = ^(lfsr & TAPS);

  assign data_out = lfsr;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lfsr <= SEED;
    end else if (load) begin
      lfsr <= pload;
    end else if (en) begin
      lfsr <= {lfsr[WIDTH-2:0], fb};
    end
  end
endmodule


/*
// Instance Example:
vrtl_lfsr_galois #(
    .WIDTH(8),
    .POLY(8'hB8),
    .SEED(8'h01)
) u_vrtl_lfsr_galois (
    .clk      (clk),
    .rst_n    (rst_n),
    .en       (en),
    .load     (load),
    .pload    (pload),
    .data_out (data_out)
);
*/
module vrtl_lfsr_galois #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] POLY = 8'hB8,
    parameter logic [WIDTH-1:0] SEED = 8'h01
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic             load,
    input  logic [WIDTH-1:0] pload,
    output logic [WIDTH-1:0] data_out
);
  logic [WIDTH-1:0] lfsr;
  wire fb = lfsr[WIDTH-1];

  assign data_out = lfsr;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      lfsr <= SEED;
    end else if (load) begin
      lfsr <= pload;
    end else if (en) begin
      lfsr <= {lfsr[WIDTH-2:0], 1'b0} ^ (fb ? POLY : '0);
    end
  end
endmodule

`endif // VRTL_LFSR_SV
