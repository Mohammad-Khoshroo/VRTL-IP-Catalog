`ifndef ARITHMETIC_MULTIPLIERS_VRTL_MULT_ARRAY_SV
`define ARITHMETIC_MULTIPLIERS_VRTL_MULT_ARRAY_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_multiplier_shift_add #(
//     .WIDTH (8)
// ) u_vrtl_multiplier_shift_add (
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
module vrtl_multiplier_shift_add #(
    parameter int WIDTH = 8,
    localparam int CNT_W = $clog2(WIDTH + 1)
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   start,
    input  logic [WIDTH-1:0]       a,
    input  logic [WIDTH-1:0]       b,
    output logic [2*WIDTH-1:0]     product,
    output logic                   busy,
    output logic                   done
);
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    CALC = 2'b01,
    FINI = 2'b10
  } state_t;

  state_t state;
  logic [CNT_W-1:0]   cnt;
  logic [2*WIDTH-1:0] multiplicand;
  logic [WIDTH-1:0]   multiplier;
  logic [2*WIDTH-1:0] accum;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state        <= IDLE;
      cnt          <= '0;
      multiplicand <= '0;
      multiplier   <= '0;
      accum        <= '0;
      product      <= '0;
      busy         <= 1'b0;
      done         <= 1'b0;
    end else begin
      case (state)
        IDLE: begin
          done <= 1'b0;
          if (start) begin
            multiplicand <= {{WIDTH{1'b0}}, a};
            multiplier   <= b;
            accum        <= '0;
            cnt          <= CNT_W'(WIDTH);
            busy         <= 1'b1;
            state        <= CALC;
          end
        end

        CALC: begin
          if (multiplier[0]) begin
            accum <= accum + multiplicand;
          end
          multiplicand <= multiplicand << 1;
          multiplier   <= multiplier >> 1;
          cnt          <= cnt - 1'b1;

          if (cnt == 1) begin
            state <= FINI;
          end
        end

        FINI: begin
          busy    <= 1'b0;
          done    <= 1'b1;
          product <= accum;
          state   <= IDLE;
        end
      endcase
    end
  end
endmodule


// =============================================================================
// vrtl_array_multiplier_4x4 u_vrtl_array_multiplier_4x4 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_array_multiplier_4x4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [7:0] product
);
  logic [3:0] pp [4];

  always_comb begin
    for (int r = 0; r < 4; r = r + 1) begin
      pp[r] = a & {4{b[r]}};
    end
  end

  wire [4:0] sum1 = {1'b0, pp[0][3:1]} + pp[1];
  wire [4:0] sum2 = {1'b0, sum1[4:1]} + pp[2];
  wire [4:0] sum3 = {1'b0, sum2[4:1]} + pp[3];

  assign product[0]   = pp[0][0];
  assign product[1]   = sum1[0];
  assign product[2]   = sum2[0];
  assign product[7:3] = sum3;
endmodule


// =============================================================================
// vrtl_array_multiplier_8x8 u_vrtl_array_multiplier_8x8 (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_array_multiplier_8x8 (
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] product
);
  logic [15:0] accum;

  always_comb begin
    accum = '0;
    for (int i = 0; i < 8; i = i + 1) begin
      if (b[i]) begin
        accum = accum + (16'(a) << i);
      end
    end
  end

  assign product = accum;
endmodule


// =============================================================================
// vrtl_array_multiplier #(
//     .WIDTH_A (8),
//     .WIDTH_B (8)
// ) u_vrtl_array_multiplier (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_array_multiplier #(
    parameter int WIDTH_A = 8,
    parameter int WIDTH_B = 8
)(
    input  logic [WIDTH_A-1:0]           a,
    input  logic [WIDTH_B-1:0]           b,
    output logic [WIDTH_A+WIDTH_B-1:0]   product
);
  logic [WIDTH_A+WIDTH_B-1:0] accum;

  always_comb begin
    accum = '0;
    for (int i = 0; i < WIDTH_B; i = i + 1) begin
      if (b[i]) begin
        accum = accum + ({ {(WIDTH_B){1'b0}}, a } << i);
      end
    end
  end

  assign product = accum;
endmodule


// =============================================================================
// vrtl_multiplier #(
//     .WIDTH_A (8),
//     .WIDTH_B (8),
//     .SIGNED  (0)
// ) u_vrtl_multiplier (
//     .a       (a),
//     .b       (b),
//     .product (product)
// );
// =============================================================================
module vrtl_multiplier #(
    parameter int WIDTH_A = 8,
    parameter int WIDTH_B = 8,
    parameter bit SIGNED  = 0
)(
    input  logic [WIDTH_A-1:0]             a,
    input  logic [WIDTH_B-1:0]             b,
    output logic [WIDTH_A+WIDTH_B-1:0]     product
);
  always_comb begin
    if (SIGNED) begin
      product = $signed(a) * $signed(b);
    end else begin
      product = a * b;
    end
  end
endmodule

`endif // ARITHMETIC_MULTIPLIERS_VRTL_MULT_ARRAY_SV
