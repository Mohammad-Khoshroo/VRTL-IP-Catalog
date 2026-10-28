`ifndef ARITHMETIC_MULTIPLIERS_VRTL_MULT_BOOTH_SV
`define ARITHMETIC_MULTIPLIERS_VRTL_MULT_BOOTH_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_booth_radix2_mult_8x8 u_vrtl_booth_radix2_mult_8x8 (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .start   (start),
//     .a       (a),
//     .b       (b),
//     .product (product),
//     .busy    (busy),
//     .done    (done)
// );
// =============================================================================
module vrtl_booth_radix2_mult_8x8 (
    input  logic              clk,
    input  logic              rst_n,
    input  logic              start,
    input  logic signed [7:0] a,
    input  logic signed [7:0] b,
    output logic signed [15:0]product,
    output logic              busy,
    output logic              done
);
  typedef enum logic [1:0] { IDLE, CALC, FINI } state_t;
  state_t state;
  logic [3:0] cnt;
  logic signed [7:0] m_reg;
  logic signed [16:0] acc; // {A (8-bit), Q (8-bit), Q_-1 (1-bit)}

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state   <= IDLE;
      cnt     <= '0;
      m_reg   <= '0;
      acc     <= '0;
      product <= '0;
      busy    <= 1'b0;
      done    <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          done <= 1'b0;
          if (start) begin
            m_reg <= a;
            acc   <= {8'h00, b, 1'b0};
            cnt   <= 4'd8;
            busy  <= 1'b1;
            state <= CALC;
          end
        end

        CALC: begin
          logic signed [7:0] next_hi;
          case (acc[1:0])
            2'b01:   next_hi = acc[16:9] + m_reg;
            2'b10:   next_hi = acc[16:9] - m_reg;
            default: next_hi = acc[16:9];
          endcase

          // Arithmetic Shift Right
          acc <= {next_hi[7], next_hi, acc[8:1]};
          cnt <= cnt - 1'b1;
          if (cnt == 1) state <= FINI;
        end

        FINI: begin
          busy    <= 1'b0;
          done    <= 1'b1;
          product <= acc[16:1];
          state   <= IDLE;
        end
      endcase
    end
  end
endmodule


// =============================================================================
// vrtl_booth_radix4_mult_8x8 u_vrtl_booth_radix4_mult_8x8 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_booth_radix4_mult_8x8 (
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] product
);
  logic signed [8:0]  a_ext;
  logic signed [15:0] pp [4];
  logic [8:0] b_pad;

  assign a_ext = {a[7], a};
  assign b_pad = {b, 1'b0};

  always_comb begin
    for (int i = 0; i < 4; i = i + 1) begin
      case (b_pad[2*i +: 3])
        3'b000, 3'b111: pp[i] = '0;
        3'b001, 3'b010: pp[i] = 16'(a_ext) << (2 * i);
        3'b011:         pp[i] = 16'(a_ext <<< 1) << (2 * i);
        3'b100:         pp[i] = -16'(a_ext <<< 1) << (2 * i);
        3'b101, 3'b110: pp[i] = -16'(a_ext) << (2 * i);
      endcase
    end
  end

  assign product = pp[0] + pp[1] + pp[2] + pp[3];
endmodule


// =============================================================================
// vrtl_booth_radix4_mult_16x16 u_vrtl_booth_radix4_mult_16x16 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_booth_radix4_mult_16x16 (
    input  logic [15:0] a,
    input  logic [15:0] b,
    output logic [31:0] product
);
  logic signed [16:0] a_ext;
  logic signed [31:0] pp [8];
  logic [16:0] b_pad;

  assign a_ext = {a[15], a};
  assign b_pad = {b, 1'b0};

  always_comb begin
    for (int i = 0; i < 8; i = i + 1) begin
      case (b_pad[2*i +: 3])
        3'b000, 3'b111: pp[i] = '0;
        3'b001, 3'b010: pp[i] = 32'(a_ext) << (2 * i);
        3'b011:         pp[i] = 32'(a_ext <<< 1) << (2 * i);
        3'b100:         pp[i] = -32'(a_ext <<< 1) << (2 * i);
        3'b101, 3'b110: pp[i] = -32'(a_ext) << (2 * i);
      endcase
    end
  end

  assign product = pp[0] + pp[1] + pp[2] + pp[3] + pp[4] + pp[5] + pp[6] + pp[7];
endmodule

`endif // ARITHMETIC_MULTIPLIERS_VRTL_MULT_BOOTH_SV
