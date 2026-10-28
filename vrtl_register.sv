`ifndef VRTL_REGISTER_SV
`define VRTL_REGISTER_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Non-Parametric Registers (8-bit, 16-bit, 32-bit, Shift Registers)
// =============================================================================

/*
// Instance Example:
vrtl_reg_8b u_vrtl_reg_8b (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .clr   (clr),
    .d     (d),
    .q     (q)
);
*/
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


/*
// Instance Example:
vrtl_reg_16b u_vrtl_reg_16b (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .clr   (clr),
    .d     (d),
    .q     (q)
);
*/
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


/*
// Instance Example:
vrtl_reg_32b u_vrtl_reg_32b (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .clr   (clr),
    .d     (d),
    .q     (q)
);
*/
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


/*
// Instance Example:
vrtl_shift_reg_piso_8b u_vrtl_shift_reg_piso_8b (
    .clk        (clk),
    .rst_n      (rst_n),
    .load       (load),
    .shift_en   (shift_en),
    .d_in       (d_in),
    .serial_out (serial_out)
);
*/
module vrtl_shift_reg_piso_8b (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       load,
    input  logic       shift_en,
    input  logic [7:0] d_in,
    output logic       serial_out
);
  logic [7:0] sreg;
  assign serial_out = sreg[0];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sreg <= 8'h00;
    end else if (load) begin
      sreg <= d_in;
    end else if (shift_en) begin
      sreg <= {1'b0, sreg[7:1]};
    end
  end
endmodule


/*
// Instance Example:
vrtl_shift_reg_sipo_8b u_vrtl_shift_reg_sipo_8b (
    .clk       (clk),
    .rst_n     (rst_n),
    .shift_en  (shift_en),
    .serial_in (serial_in),
    .d_out     (d_out)
);
*/
module vrtl_shift_reg_sipo_8b (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       shift_en,
    input  logic       serial_in,
    output logic [7:0] d_out
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      d_out <= 8'h00;
    end else if (shift_en) begin
      d_out <= {d_out[6:0], serial_in};
    end
  end
endmodule


// =============================================================================
// Parametric Registers, Byte-Enable & Shadow Buffers
// =============================================================================

/*
// Instance Example:
vrtl_reg #(
    .WIDTH(32),
    .RESET_VAL('0)
) u_vrtl_reg (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .clr   (clr),
    .d     (d),
    .q     (q)
);
*/
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


/*
// Instance Example:
vrtl_reg_byte_en #(
    .NUM_BYTES(4),
    .BYTE_WIDTH(8)
) u_vrtl_reg_byte_en (
    .clk     (clk),
    .rst_n   (rst_n),
    .byte_en (byte_en),
    .d       (d),
    .q       (q)
);
*/
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


/*
// Instance Example:
vrtl_reg_shadow #(
    .WIDTH(32)
) u_vrtl_reg_shadow (
    .clk       (clk),
    .rst_n     (rst_n),
    .wr_en     (wr_en),
    .d         (d),
    .commit    (commit),
    .active_out(active_out)
);
*/
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


/*
// Instance Example:
vrtl_shift_reg_universal #(
    .WIDTH(8)
) u_vrtl_shift_reg_universal (
    .clk         (clk),
    .rst_n       (rst_n),
    .mode        (mode),
    .s_in_left   (s_in_left),
    .s_in_right  (s_in_right),
    .d_in        (d_in),
    .d_out       (d_out)
);
*/
module vrtl_shift_reg_universal #(
    parameter int WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [1:0]       mode,
    input  logic             s_in_left,
    input  logic             s_in_right,
    input  logic [WIDTH-1:0] d_in,
    output logic [WIDTH-1:0] d_out
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      d_out <= '0;
    end else begin
      case (mode)
        2'b00: d_out <= d_out;
        2'b01: d_out <= {s_in_left, d_out[WIDTH-1:1]};
        2'b10: d_out <= {d_out[WIDTH-2:0], s_in_right};
        2'b11: d_out <= d_in;
      endcase
    end
  end
endmodule


/*
// Instance Example:
vrtl_shift_reg_siso #(
    .DEPTH(8)
) u_vrtl_shift_reg_siso (
    .clk       (clk),
    .rst_n     (rst_n),
    .shift_en  (shift_en),
    .s_in      (s_in),
    .s_out     (s_out)
);
*/
module vrtl_shift_reg_siso #(
    parameter int DEPTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic shift_en,
    input  logic s_in,
    output logic s_out
);
  logic [DEPTH-1:0] shift_reg;
  assign s_out = shift_reg[DEPTH-1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      shift_reg <= '0;
    end else if (shift_en) begin
      shift_reg <= {shift_reg[DEPTH-2:0], s_in};
    end
  end
endmodule


// =============================================================================
// Register Files (2R1W & 3R2W Multi-Ported)
// =============================================================================

/*
// Instance Example:
vrtl_reg_file #(
    .DATA_WIDTH(32),
    .DEPTH(32),
    .ZERO_REG0(1)
) u_vrtl_reg_file (
    .clk        (clk),
    .rst_n      (rst_n),
    .wr_en      (wr_en),
    .wr_addr    (wr_addr),
    .wr_data    (wr_data),
    .rd_addr0   (rd_addr0),
    .rd_data0   (rd_data0),
    .rd_addr1   (rd_addr1),
    .rd_data1   (rd_data1)
);
*/
module vrtl_reg_file #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 32,
    parameter bit ZERO_REG0  = 1,
    localparam int ADDR_W    = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic [ADDR_W-1:0]     wr_addr,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic [ADDR_W-1:0]     rd_addr0,
    output logic [DATA_WIDTH-1:0] rd_data0,
    input  logic [ADDR_W-1:0]     rd_addr1,
    output logic [DATA_WIDTH-1:0] rd_data1
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < DEPTH; i = i + 1) begin
        mem[i] <= '0;
      end
    end else if (wr_en) begin
      if (!(ZERO_REG0 && wr_addr == '0)) begin
        mem[wr_addr] <= wr_data;
      end
    end
  end

  always_comb begin
    rd_data0 = (ZERO_REG0 && rd_addr0 == '0) ? '0 : mem[rd_addr0];
    rd_data1 = (ZERO_REG0 && rd_addr1 == '0) ? '0 : mem[rd_addr1];
  end
endmodule


/*
// Instance Example:
vrtl_reg_file_3r2w #(
    .DATA_WIDTH(32),
    .DEPTH(32),
    .ZERO_REG0(1)
) u_vrtl_reg_file_3r2w (
    .clk        (clk),
    .rst_n      (rst_n),
    .wr_en0     (wr_en0),
    .wr_addr0   (wr_addr0),
    .wr_data0   (wr_data0),
    .wr_en1     (wr_en1),
    .wr_addr1   (wr_addr1),
    .wr_data1   (wr_data1),
    .rd_addr0   (rd_addr0),
    .rd_data0   (rd_data0),
    .rd_addr1   (rd_addr1),
    .rd_data1   (rd_data1),
    .rd_addr2   (rd_addr2),
    .rd_data2   (rd_data2)
);
*/
module vrtl_reg_file_3r2w #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 32,
    parameter bit ZERO_REG0  = 1,
    localparam int ADDR_W    = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Write Port 0
    input  logic                  wr_en0,
    input  logic [ADDR_W-1:0]     wr_addr0,
    input  logic [DATA_WIDTH-1:0] wr_data0,

    // Write Port 1
    input  logic                  wr_en1,
    input  logic [ADDR_W-1:0]     wr_addr1,
    input  logic [DATA_WIDTH-1:0] wr_data1,

    // Read Port 0
    input  logic [ADDR_W-1:0]     rd_addr0,
    output logic [DATA_WIDTH-1:0] rd_data0,

    // Read Port 1
    input  logic [ADDR_W-1:0]     rd_addr1,
    output logic [DATA_WIDTH-1:0] rd_data1,

    // Read Port 2
    input  logic [ADDR_W-1:0]     rd_addr2,
    output logic [DATA_WIDTH-1:0] rd_data2
);
  logic [DATA_WIDTH-1:0] mem [DEPTH];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (int i = 0; i < DEPTH; i = i + 1) begin
        mem[i] <= '0;
      end
    end else begin
      if (wr_en0 && !(ZERO_REG0 && wr_addr0 == '0)) begin
        mem[wr_addr0] <= wr_data0;
      end
      if (wr_en1 && !(ZERO_REG0 && wr_addr1 == '0)) begin
        mem[wr_addr1] <= wr_data1;
      end
    end
  end

  always_comb begin
    rd_data0 = (ZERO_REG0 && rd_addr0 == '0) ? '0 : mem[rd_addr0];
    rd_data1 = (ZERO_REG0 && rd_addr1 == '0) ? '0 : mem[rd_addr1];
    rd_data2 = (ZERO_REG0 && rd_addr2 == '0) ? '0 : mem[rd_addr2];
  end
endmodule

`endif // VRTL_REGISTER_SV
