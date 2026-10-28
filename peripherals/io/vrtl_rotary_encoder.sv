`ifndef PERIPHERALS_IO_VRTL_ROTARY_ENCODER_SV
`define PERIPHERALS_IO_VRTL_ROTARY_ENCODER_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_rotary_encoder_decoder u_vrtl_rotary_encoder_decoder (
//     .clk        (clk),
//     .rst_n      (rst_n),
//     .a_in       (a_in),
//     .b_in       (b_in),
//     .step_pulse (step_pulse),
//     .dir_cw     (dir_cw)
// );
// =============================================================================
module vrtl_rotary_encoder_decoder (
    input  logic clk,
    input  logic rst_n,
    input  logic a_in,
    input  logic b_in,
    output logic step_pulse,
    output logic dir_cw
);
  logic a_sync0, a_sync1;
  logic b_sync0, b_sync1;
  logic [1:0] state, prev_state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      a_sync0    <= 1'b0;
      a_sync1    <= 1'b0;
      b_sync0    <= 1'b0;
      b_sync1    <= 1'b0;
      state      <= 2'b00;
      prev_state <= 2'b00;
      step_pulse <= 1'b0;
      dir_cw     <= 1'b0;
    end else begin
      a_sync0 <= a_in;
      a_sync1 <= a_sync0;
      b_sync0 <= b_in;
      b_sync1 <= b_sync0;

      prev_state <= state;
      state      <= {a_sync1, b_sync1};

      step_pulse <= 1'b0;

      case ({prev_state, state})
        // Clockwise transitions: 00->01, 01->11, 11->10, 10->00
        4'b00_01, 4'b01_11, 4'b11_10, 4'b10_00: begin
          step_pulse <= 1'b1;
          dir_cw     <= 1'b1;
        end
        // Counter-clockwise transitions: 00->10, 10->11, 11->01, 01->00
        4'b00_10, 4'b10_11, 4'b11_01, 4'b01_00: begin
          step_pulse <= 1'b1;
          dir_cw     <= 1'b0;
        end
        default: ;
      endcase
    end
  end
endmodule

`endif // PERIPHERALS_IO_VRTL_ROTARY_ENCODER_SV
