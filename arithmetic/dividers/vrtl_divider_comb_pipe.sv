`ifndef ARITHMETIC_DIVIDERS_VRTL_DIVIDER_COMB_PIPE_SV
`define ARITHMETIC_DIVIDERS_VRTL_DIVIDER_COMB_PIPE_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_divider_comb_4b u_vrtl_divider_comb_4b (
//     .dividend  (dividend),
//     .divisor   (divisor),
//     .quotient  (quotient),
//     .remainder (remainder)
// );
// =============================================================================
module vrtl_divider_comb_4b (
    input  logic [3:0] dividend,
    input  logic [3:0] divisor,
    output logic [3:0] quotient,
    output logic [3:0] remainder
);
  assign quotient  = (divisor == 4'h0) ? 4'hF : (dividend / divisor);
  assign remainder = (divisor == 4'h0) ? dividend : (dividend % divisor);
endmodule


// =============================================================================
// vrtl_divider_comb_8b u_vrtl_divider_comb_8b (
//     .dividend  (dividend),
//     .divisor   (divisor),
//     .quotient  (quotient),
//     .remainder (remainder)
// );
// =============================================================================
module vrtl_divider_comb_8b (
    input  logic [7:0] dividend,
    input  logic [7:0] divisor,
    output logic [7:0] quotient,
    output logic [7:0] remainder
);
  logic [15:0] rem_stage [9];
  logic [7:0]  quo_stage [9];

  always_comb begin
    for (int k = 0; k < 9; k = k + 1) begin
      rem_stage[k] = '0;
      quo_stage[k] = '0;
    end
    rem_stage[0] = {8'h00, dividend};
    quo_stage[0] = 8'h00;

    for (int i = 0; i < 8; i = i + 1) begin
      logic [15:0] shifted;
      shifted = rem_stage[i] << 1;
      if (shifted[15:8] >= divisor && divisor != 8'h00) begin
        rem_stage[i+1] = {shifted[15:8] - divisor, shifted[7:0]};
        quo_stage[i+1] = {quo_stage[i][6:0], 1'b1};
      end else begin
        rem_stage[i+1] = shifted;
        quo_stage[i+1] = {quo_stage[i][6:0], 1'b0};
      end
    end

    quotient  = (divisor == 8'h00) ? 8'hFF : quo_stage[8];
    remainder = (divisor == 8'h00) ? dividend : rem_stage[8][15:8];
  end
endmodule


// =============================================================================
// vrtl_divider_pipelined_8b u_vrtl_divider_pipelined_8b (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .valid_in  (valid_in),
//     .dividend  (dividend),
//     .divisor   (divisor),
//     .valid_out (valid_out),
//     .quotient  (quotient),
//     .remainder (remainder)
// );
// =============================================================================
module vrtl_divider_pipelined_8b (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       valid_in,
    input  logic [7:0] dividend,
    input  logic [7:0] divisor,
    output logic       valid_out,
    output logic [7:0] quotient,
    output logic [7:0] remainder
);
  logic [15:0] rem_pipe [8];
  logic [7:0]  div_pipe [8];
  logic [7:0]  quo_pipe [8];
  logic [7:0]  val_pipe;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      val_pipe <= '0;
      for (int i = 0; i < 8; i = i + 1) begin
        rem_pipe[i] <= '0;
        div_pipe[i] <= '0;
        quo_pipe[i] <= '0;
      end
    end else begin
      // Stage 0
      val_pipe[0] <= valid_in;
      div_pipe[0] <= divisor;
      begin : stage0_blk
        automatic logic [15:0] s0 = {8'h00, dividend} << 1;
        if (s0[15:8] >= divisor && divisor != 8'h00) begin
          rem_pipe[0] <= {s0[15:8] - divisor, s0[7:0]};
          quo_pipe[0] <= 8'b0000_0001;
        end else begin
          rem_pipe[0] <= s0;
          quo_pipe[0] <= 8'b0000_0000;
        end
      end

      // Stages 1..7
      for (int i = 1; i < 8; i = i + 1) begin
        val_pipe[i] <= val_pipe[i-1];
        div_pipe[i] <= div_pipe[i-1];
        begin : stagei_blk
          automatic logic [15:0] si = rem_pipe[i-1] << 1;
          if (si[15:8] >= div_pipe[i-1] && div_pipe[i-1] != 8'h00) begin
            rem_pipe[i] <= {si[15:8] - div_pipe[i-1], si[7:0]};
            quo_pipe[i] <= {quo_pipe[i-1][6:0], 1'b1};
          end else begin
            rem_pipe[i] <= si;
            quo_pipe[i] <= {quo_pipe[i-1][6:0], 1'b0};
          end
        end
      end
    end
  end

  assign valid_out = val_pipe[7];
  assign quotient  = quo_pipe[7];
  assign remainder = rem_pipe[7][15:8];
endmodule

`endif // ARITHMETIC_DIVIDERS_VRTL_DIVIDER_COMB_PIPE_SV
