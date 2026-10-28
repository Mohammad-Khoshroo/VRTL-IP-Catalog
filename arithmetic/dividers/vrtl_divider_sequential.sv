`ifndef ARITHMETIC_DIVIDERS_VRTL_DIVIDER_SEQUENTIAL_SV
`define ARITHMETIC_DIVIDERS_VRTL_DIVIDER_SEQUENTIAL_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_divider_restoring #(
//     .WIDTH (32)
// ) u_vrtl_divider_restoring (
//     .clk         (clk),
//     .rst_n       (rst_n),
//     .start       (start),
//     .dividend    (dividend),
//     .divisor     (divisor),
//     .quotient    (quotient),
//     .remainder   (remainder),
//     .busy        (busy),
//     .done        (done),
//     .div_by_zero (div_by_zero)
// );
// =============================================================================
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


// =============================================================================
// vrtl_divider_non_restoring #(
//     .WIDTH (32)
// ) u_vrtl_divider_non_restoring (
//     .clk         (clk),
//     .rst_n       (rst_n),
//     .start       (start),
//     .dividend    (dividend),
//     .divisor     (divisor),
//     .quotient    (quotient),
//     .remainder   (remainder),
//     .busy        (busy),
//     .done        (done),
//     .div_by_zero (div_by_zero)
// );
// =============================================================================
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

`endif // ARITHMETIC_DIVIDERS_VRTL_DIVIDER_SEQUENTIAL_SV
