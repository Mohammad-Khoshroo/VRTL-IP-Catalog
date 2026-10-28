`ifndef VRTL_DIVIDERS_SV
`define VRTL_DIVIDERS_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Sequential Dividers (Restoring & Non-Restoring)
// =============================================================================

/*
// Instance Example:
vrtl_divider_restoring #(
    .WIDTH(32)
) u_vrtl_divider_restoring (
    .clk         (clk),
    .rst_n       (rst_n),
    .start       (start),
    .dividend    (dividend),
    .divisor     (divisor),
    .quotient    (quotient),
    .remainder   (remainder),
    .busy        (busy),
    .done        (done),
    .div_by_zero (div_by_zero)
);
*/
module vrtl_divider_restoring #(
    parameter int WIDTH = 32,
    localparam int CNT_W = $clog2(WIDTH + 1)
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             start,
    input  logic [WIDTH-1:0] dividend,
    input  logic [WIDTH-1:0] divisor,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic             busy,
    output logic             done,
    output logic             div_by_zero
);
  typedef enum logic [1:0] { IDLE, CALC, FINI } state_t;

  state_t state;
  logic [CNT_W-1:0] cnt;
  logic [WIDTH-1:0] b_reg;
  logic [2*WIDTH:0] acc;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state       <= IDLE;
      cnt         <= '0;
      b_reg       <= '0;
      acc         <= '0;
      quotient    <= '0;
      remainder   <= '0;
      busy        <= 1'b0;
      done        <= 1'b0;
      div_by_zero <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          done <= 1'b0;
          if (start) begin
            if (divisor == '0) begin
              div_by_zero <= 1'b1;
              quotient    <= '1;
              remainder   <= dividend;
              done        <= 1'b1;
            end else begin
              div_by_zero <= 1'b0;
              busy        <= 1'b1;
              b_reg       <= divisor;
              acc         <= { {WIDTH{1'b0}}, dividend, 1'b0 };
              cnt         <= CNT_W'(WIDTH);
              state       <= CALC;
            end
          end
        end

        CALC: begin
          logic [WIDTH:0] sub_res;
          logic [2*WIDTH:0] shifted_acc;
          shifted_acc = acc << 1;

          sub_res = {1'b0, shifted_acc[2*WIDTH:WIDTH+1]} - {1'b0, b_reg};
          if (!sub_res[WIDTH]) begin
            acc <= {sub_res[WIDTH-1:0], shifted_acc[WIDTH:1], 1'b1};
          end else begin
            acc <= {shifted_acc[2*WIDTH:WIDTH+1], shifted_acc[WIDTH:1], 1'b0};
          end

          cnt <= cnt - 1'b1;
          if (cnt == 1) begin
            state <= FINI;
          end
        end

        FINI: begin
          busy      <= 1'b0;
          done      <= 1'b1;
          quotient  <= acc[WIDTH-1:0];
          remainder <= acc[2*WIDTH-1:WIDTH];
          state     <= IDLE;
        end
      endcase
    end
  end
endmodule


/*
// Instance Example:
vrtl_divider_non_restoring #(
    .WIDTH(32)
) u_vrtl_divider_non_restoring (
    .clk         (clk),
    .rst_n       (rst_n),
    .start       (start),
    .dividend    (dividend),
    .divisor     (divisor),
    .quotient    (quotient),
    .remainder   (remainder),
    .busy        (busy),
    .done        (done),
    .div_by_zero (div_by_zero)
);
*/
module vrtl_divider_non_restoring #(
    parameter int WIDTH = 32,
    localparam int CNT_W = $clog2(WIDTH + 1)
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             start,
    input  logic [WIDTH-1:0] dividend,
    input  logic [WIDTH-1:0] divisor,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic             busy,
    output logic             done,
    output logic             div_by_zero
);
  typedef enum logic [1:0] { IDLE, CALC, FINI } state_t;

  state_t state;
  logic [CNT_W-1:0] cnt;
  logic [WIDTH-1:0] m_reg;
  logic [WIDTH:0]   rem_reg;
  logic [WIDTH-1:0] quo_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state       <= IDLE;
      cnt         <= '0;
      m_reg       <= '0;
      rem_reg     <= '0;
      quo_reg     <= '0;
      quotient    <= '0;
      remainder   <= '0;
      busy        <= 1'b0;
      done        <= 1'b0;
      div_by_zero <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          done <= 1'b0;
          if (start) begin
            if (divisor == '0) begin
              div_by_zero <= 1'b1;
              quotient    <= '1;
              remainder   <= dividend;
              done        <= 1'b1;
            end else begin
              div_by_zero <= 1'b0;
              busy        <= 1'b1;
              m_reg       <= divisor;
              rem_reg     <= '0;
              quo_reg     <= dividend;
              cnt         <= CNT_W'(WIDTH);
              state       <= CALC;
            end
          end
        end

        CALC: begin
          logic [WIDTH:0] next_rem;
          logic sign_r;
          sign_r = rem_reg[WIDTH];

          if (!sign_r) begin
            next_rem = {rem_reg[WIDTH-1:0], quo_reg[WIDTH-1]} - {1'b0, m_reg};
          end else begin
            next_rem = {rem_reg[WIDTH-1:0], quo_reg[WIDTH-1]} + {1'b0, m_reg};
          end

          rem_reg <= next_rem;
          quo_reg <= {quo_reg[WIDTH-2:0], ~next_rem[WIDTH]};

          cnt <= cnt - 1'b1;
          if (cnt == 1) begin
            state <= FINI;
          end
        end

        FINI: begin
          busy      <= 1'b0;
          done      <= 1'b1;
          quotient  <= quo_reg;
          remainder <= rem_reg[WIDTH] ? (rem_reg[WIDTH-1:0] + m_reg) : rem_reg[WIDTH-1:0];
          state     <= IDLE;
        end
      endcase
    end
  end
endmodule


// =============================================================================
// Combinational Dividers (4-bit & 8-bit)
// =============================================================================

/*
// Instance Example:
vrtl_divider_comb_4b u_vrtl_divider_comb_4b (
    .dividend  (dividend),
    .divisor   (divisor),
    .quotient  (quotient),
    .remainder (remainder)
);
*/
module vrtl_divider_comb_4b (
    input  logic [3:0] dividend,
    input  logic [3:0] divisor,
    output logic [3:0] quotient,
    output logic [3:0] remainder
);
  assign quotient  = (divisor == 4'h0) ? 4'hF : (dividend / divisor);
  assign remainder = (divisor == 4'h0) ? dividend : (dividend % divisor);
endmodule


/*
// Instance Example:
vrtl_divider_comb_8b u_vrtl_divider_comb_8b (
    .dividend  (dividend),
    .divisor   (divisor),
    .quotient  (quotient),
    .remainder (remainder)
);
*/
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
// Pipelined High-Throughput Divider
// =============================================================================

/*
// Instance Example:
vrtl_divider_pipelined_8b u_vrtl_divider_pipelined_8b (
    .clk       (clk),
    .rst_n     (rst_n),
    .valid_in  (valid_in),
    .dividend  (dividend),
    .divisor   (divisor),
    .valid_out (valid_out),
    .quotient  (quotient),
    .remainder (remainder)
);
*/
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


// =============================================================================
// Integer Square Root (Restoring & Non-Restoring)
// =============================================================================

/*
// Instance Example:
vrtl_sqrt_restoring #(
    .WIDTH(32)
) u_vrtl_sqrt_restoring (
    .clk       (clk),
    .rst_n     (rst_n),
    .start     (start),
    .radicand  (radicand),
    .root      (root),
    .remainder (remainder),
    .busy      (busy),
    .done      (done)
);
*/
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
// Count Leading Zeros (CLZ / Priority Normalizer)
// =============================================================================

/*
// Instance Example:
vrtl_clz_32b u_vrtl_clz_32b (
    .in    (in),
    .count (count),
    .zero  (zero)
);
*/
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


/*
// Instance Example:
vrtl_clz #(
    .WIDTH(32)
) u_vrtl_clz (
    .in    (in),
    .count (count),
    .zero  (zero)
);
*/
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

`endif // VRTL_DIVIDERS_SV
