`ifndef SEQUENTIAL_REGISTERS_VRTL_SHIFT_REGISTERS_SV
`define SEQUENTIAL_REGISTERS_VRTL_SHIFT_REGISTERS_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_shift_reg_piso_8b u_vrtl_shift_reg_piso_8b (
//     .clk        (clk),
//     .rst_n      (rst_n),
//     .load       (load),
//     .shift_en   (shift_en),
//     .d_in       (d_in),
//     .serial_out (serial_out)
// );
// =============================================================================
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


// =============================================================================
// vrtl_shift_reg_sipo_8b u_vrtl_shift_reg_sipo_8b (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .shift_en  (shift_en),
//     .serial_in (serial_in),
//     .d_out     (d_out)
// );
// =============================================================================
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
// vrtl_shift_reg_siso #(
//     .DEPTH (8)
// ) u_vrtl_shift_reg_siso (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .shift_en (shift_en),
//     .s_in     (s_in),
//     .s_out    (s_out)
// );
// =============================================================================
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
// vrtl_shift_reg_universal #(
//     .WIDTH (8)
// ) u_vrtl_shift_reg_universal (
//     .clk        (clk),
//     .rst_n      (rst_n),
//     .mode       (mode),
//     .s_in_left  (s_in_left),
//     .s_in_right (s_in_right),
//     .d_in       (d_in),
//     .d_out      (d_out)
// );
// =============================================================================
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

`endif // SEQUENTIAL_REGISTERS_VRTL_SHIFT_REGISTERS_SV
