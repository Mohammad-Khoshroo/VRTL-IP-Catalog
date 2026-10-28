`ifndef PERIPHERALS_IO_VRTL_DEBOUNCER_SV
`define PERIPHERALS_IO_VRTL_DEBOUNCER_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_debouncer #(
//     .DEBOUNCE_CYCLES (100_000)
// ) u_vrtl_debouncer (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .noisy_in  (noisy_in),
//     .clean_out (clean_out)
// );
// =============================================================================
module vrtl_debouncer #(
    parameter int DEBOUNCE_CYCLES = 100_000,
    localparam int CNT_W = $clog2(DEBOUNCE_CYCLES + 1)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic noisy_in,
    output logic clean_out
);
  logic [CNT_W-1:0] cnt;
  logic sync0, sync1;
  logic state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sync0     <= 1'b0;
      sync1     <= 1'b0;
      state     <= 1'b0;
      cnt       <= '0;
      clean_out <= 1'b0;
    end else begin
      sync0 <= noisy_in;
      sync1 <= sync0;

      if (sync1 != state) begin
        state <= sync1;
        cnt   <= '0;
      end else if (cnt < CNT_W'(DEBOUNCE_CYCLES)) begin
        cnt <= cnt + 1'b1;
      end else begin
        clean_out <= state;
      end
    end
  end
endmodule

`endif // PERIPHERALS_IO_VRTL_DEBOUNCER_SV
