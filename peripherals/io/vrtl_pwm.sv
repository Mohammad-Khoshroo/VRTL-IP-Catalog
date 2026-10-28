`ifndef PERIPHERALS_IO_VRTL_PWM_SV
`define PERIPHERALS_IO_VRTL_PWM_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_pwm_gen #(
//     .WIDTH (8)
// ) u_vrtl_pwm_gen (
//     .clk        (clk),
//     .rst_n      (rst_n),
//     .duty_cycle (duty_cycle),
//     .pwm_out    (pwm_out)
// );
// =============================================================================
module vrtl_pwm_gen #(
    parameter int WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] duty_cycle,
    output logic             pwm_out
);
  logic [WIDTH-1:0] cnt;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt     <= '0;
      pwm_out <= 1'b0;
    end else begin
      cnt     <= cnt + 1'b1;
      pwm_out <= (cnt < duty_cycle);
    end
  end
endmodule

`endif // PERIPHERALS_IO_VRTL_PWM_SV
