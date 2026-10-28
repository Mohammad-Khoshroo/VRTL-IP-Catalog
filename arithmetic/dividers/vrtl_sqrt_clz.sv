`ifndef ARITHMETIC_DIVIDERS_VRTL_SQRT_CLZ_SV
`define ARITHMETIC_DIVIDERS_VRTL_SQRT_CLZ_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_sqrt_restoring #(
//     .WIDTH (32)
// ) u_vrtl_sqrt_restoring (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .start     (start),
//     .radicand  (radicand),
//     .root      (root),
//     .remainder (remainder),
//     .busy      (busy),
//     .done      (done)
// );
// =============================================================================
module vrtl_sqrt_restoring #(
    parameter int WIDTH = 32,
    localparam int ROOT_W = WIDTH / 2,
    localparam int CNT_W  = $clog2(ROOT_W + 1)
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic              start,
    input  logic [WIDTH-1:0]  radicand,
    output logic [ROOT_W-1:0] root,
    output logic [ROOT_W:0]   remainder,
    output logic              busy,
    output logic              done
);
  typedef enum logic [1:0] { IDLE, CALC, FINI } state_t;

  state_t state;
  logic [CNT_W-1:0]  cnt;
  logic [WIDTH-1:0]  d_reg;
  logic [ROOT_W-1:0] q_reg;
  logic [ROOT_W+1:0] r_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state     <= IDLE;
      cnt       <= '0;
      d_reg     <= '0;
      q_reg     <= '0;
      r_reg     <= '0;
      root      <= '0;
      remainder <= '0;
      busy      <= 1'b0;
      done      <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          done <= 1'b0;
          if (start) begin
            busy  <= 1'b1;
            d_reg <= radicand;
            q_reg <= '0;
            r_reg <= '0;
            cnt   <= CNT_W'(ROOT_W);
            state <= CALC;
          end
        end

        CALC: begin
          logic [ROOT_W+1:0] next_r;
          logic [ROOT_W+1:0] test_sub;

          next_r   = {r_reg[ROOT_W-1:0], d_reg[WIDTH-1 -: 2]};
          test_sub = next_r - {q_reg, 2'b01};

          if (!test_sub[ROOT_W+1]) begin
            r_reg <= test_sub;
            q_reg <= {q_reg[ROOT_W-2:0], 1'b1};
          end else begin
            r_reg <= next_r;
            q_reg <= {q_reg[ROOT_W-2:0], 1'b0};
          end

          d_reg <= d_reg << 2;
          cnt   <= cnt - 1'b1;
          if (cnt == 1) begin
            state <= FINI;
          end
        end

        FINI: begin
          busy      <= 1'b0;
          done      <= 1'b1;
          root      <= q_reg;
          remainder <= r_reg[ROOT_W:0];
          state     <= IDLE;
        end
      endcase
    end
  end
endmodule


// =============================================================================
// vrtl_clz_32b u_vrtl_clz_32b (
//     .in    (in),
//     .count (count),
//     .zero  (zero)
// );
// =============================================================================
module vrtl_clz_32b (
    input  logic [31:0] in,
    output logic [5:0]  count,
    output logic        zero
);
  assign zero = (in == '0);

  always_comb begin
    count = 6'd32;
    for (int i = 31; i >= 0; i = i - 1) begin
      if (in[i]) begin
        count = 6'(31 - i);
        break;
      end
    end
  end
endmodule


// =============================================================================
// vrtl_clz #(
//     .WIDTH (32)
// ) u_vrtl_clz (
//     .in    (in),
//     .count (count),
//     .zero  (zero)
// );
// =============================================================================
module vrtl_clz #(
    parameter int WIDTH = 32,
    localparam int CNT_W = $clog2(WIDTH) + 1
)(
    input  logic [WIDTH-1:0] in,
    output logic [CNT_W-1:0] count,
    output logic             zero
);
  assign zero = (in == '0);

  always_comb begin
    count = CNT_W'(WIDTH);
    for (int i = WIDTH - 1; i >= 0; i = i - 1) begin
      if (in[i]) begin
        count = CNT_W'(WIDTH - 1 - i);
        break;
      end
    end
  end
endmodule

`endif // ARITHMETIC_DIVIDERS_VRTL_SQRT_CLZ_SV
