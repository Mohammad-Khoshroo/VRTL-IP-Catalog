`ifndef VRTL_MULTIPLIERS_SV
`define VRTL_MULTIPLIERS_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Sequential Shift-and-Add Multiplier (Minimal Area)
// =============================================================================

/*
// Instance Example:
vrtl_multiplier_shift_add #(
    .WIDTH(8)
) u_vrtl_multiplier_shift_add (
    .clk     (clk),
    .rst_n   (rst_n),
    .start   (start),
    .a       (a),
    .b       (b),
    .product (product),
    .busy    (busy),
    .done    (done)
);
*/
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
// Array Multipliers (Unsigned Braun & Signed Baugh-Wooley)
// =============================================================================

/*
// Instance Example:
vrtl_array_multiplier_4x4 u_vrtl_array_multiplier_4x4 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
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


/*
// Instance Example:
vrtl_array_multiplier_8x8 u_vrtl_array_multiplier_8x8 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
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


/*
// Instance Example:
vrtl_array_multiplier #(
    .WIDTH_A(8),
    .WIDTH_B(8)
) u_vrtl_array_multiplier (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
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


/*
// Instance Example:
vrtl_baugh_wooley_mult_4x4 u_vrtl_baugh_wooley_mult_4x4 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
module vrtl_baugh_wooley_mult_4x4 (
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,
    output logic signed [7:0] product
);
  logic [3:0] p [4];

  always_comb begin
    // Standard Baugh-Wooley cross-term inversion
    p[0] = { ~(a[3] & b[0]),  (a[2] & b[0]),  (a[1] & b[0]),  (a[0] & b[0]) };
    p[1] = { ~(a[3] & b[1]),  (a[2] & b[1]),  (a[1] & b[1]),  (a[0] & b[1]) };
    p[2] = { ~(a[3] & b[2]),  (a[2] & b[2]),  (a[1] & b[2]),  (a[0] & b[2]) };
    p[3] = {  (a[3] & b[3]), ~(a[2] & b[3]), ~(a[1] & b[3]), ~(a[0] & b[3]) };

    // Accumulation with fixed bias 2^7 + 2^4 = 8'b1001_0000
    product = 8'b1001_0000 + 8'(p[0]) + (8'(p[1]) << 1) + (8'(p[2]) << 2) + (8'(p[3]) << 3);
  end
endmodule


/*
// Instance Example:
vrtl_baugh_wooley_mult_8x8 u_vrtl_baugh_wooley_mult_8x8 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
module vrtl_baugh_wooley_mult_8x8 (
    input  logic signed [7:0]  a,
    input  logic signed [7:0]  b,
    output logic signed [15:0] product
);
  assign product = a * b;
endmodule


// =============================================================================
// Wallace & Dadda Tree Multipliers
// =============================================================================

/*
// Instance Example:
vrtl_wallace_tree_mult_4x4 u_vrtl_wallace_tree_mult_4x4 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
module vrtl_wallace_tree_mult_4x4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [7:0] product
);
  logic p[4][4];

  always_comb begin
    for (int i = 0; i < 4; i = i + 1) begin
      for (int j = 0; j < 4; j = j + 1) begin
        p[i][j] = a[i] & b[j];
      end
    end
  end

  assign product[0] = p[0][0];

  wire s1_1 = p[1][0] ^ p[0][1];
  wire c1_1 = p[1][0] & p[0][1];
  assign product[1] = s1_1;

  wire s2_1 = p[2][0] ^ p[1][1] ^ p[0][2];
  wire c2_1 = (p[2][0] & p[1][1]) | (p[1][1] & p[0][2]) | (p[2][0] & p[0][2]);

  wire s2_2 = s2_1 ^ c1_1;
  wire c2_2 = s2_1 & c1_1;
  assign product[2] = s2_2;

  wire s3_1 = p[3][0] ^ p[2][1] ^ p[1][2];
  wire c3_1 = (p[3][0] & p[2][1]) | (p[2][1] & p[1][2]) | (p[3][0] & p[1][2]);

  wire s3_2 = p[0][3] ^ c2_1 ^ c2_2;
  wire c3_2 = (p[0][3] & c2_1) | (c2_1 & c2_2) | (p[0][3] & c2_2);

  wire s3_3 = s3_1 ^ s3_2;
  wire c3_3 = s3_1 & s3_2;
  assign product[3] = s3_3;

  logic [4:0] high_a, high_b;
  assign high_a = {1'b0, p[3][3], p[3][2], p[3][1], c3_3};
  assign high_b = {1'b0, p[2][3], p[1][3], c3_1,    c3_2};

  assign product[7:4] = high_a[4:1] + high_b[4:1] + high_a[0] + high_b[0];
endmodule


/*
// Instance Example:
vrtl_wallace_tree_mult_8x8 u_vrtl_wallace_tree_mult_8x8 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
module vrtl_wallace_tree_mult_8x8 (
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] product
);
  logic [15:0] pp [8];

  always_comb begin
    for (int r = 0; r < 8; r = r + 1) begin
      pp[r] = 16'(a & {8{b[r]}}) << r;
    end
  end

  logic [15:0] s1_0, c1_0;
  logic [15:0] s1_1, c1_1;

  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l1_0
      assign s1_0[i] = pp[0][i] ^ pp[1][i] ^ pp[2][i];
      if (i < 15) begin
        assign c1_0[i+1] = (pp[0][i] & pp[1][i]) | (pp[1][i] & pp[2][i]) | (pp[0][i] & pp[2][i]);
      end
    end
    assign c1_0[0] = 1'b0;

    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l1_1
      assign s1_1[i] = pp[3][i] ^ pp[4][i] ^ pp[5][i];
      if (i < 15) begin
        assign c1_1[i+1] = (pp[3][i] & pp[4][i]) | (pp[4][i] & pp[5][i]) | (pp[3][i] & pp[5][i]);
      end
    end
    assign c1_1[0] = 1'b0;
  endgenerate

  logic [15:0] s2_0, c2_0;
  logic [15:0] s2_1, c2_1;

  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l2_0
      assign s2_0[i] = s1_0[i] ^ c1_0[i] ^ s1_1[i];
      if (i < 15) begin
        assign c2_0[i+1] = (s1_0[i] & c1_0[i]) | (c1_0[i] & s1_1[i]) | (s1_0[i] & s1_1[i]);
      end
    end
    assign c2_0[0] = 1'b0;

    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l2_1
      assign s2_1[i] = c1_1[i] ^ pp[6][i] ^ pp[7][i];
      if (i < 15) begin
        assign c2_1[i+1] = (c1_1[i] & pp[6][i]) | (pp[6][i] & pp[7][i]) | (c1_1[i] & pp[7][i]);
      end
    end
    assign c2_1[0] = 1'b0;
  endgenerate

  logic [15:0] s3_0, c3_0;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l3
      assign s3_0[i] = s2_0[i] ^ c2_0[i] ^ s2_1[i];
      if (i < 15) begin
        assign c3_0[i+1] = (s2_0[i] & c2_0[i]) | (c2_0[i] & s2_1[i]) | (s2_0[i] & s2_1[i]);
      end
    end
    assign c3_0[0] = 1'b0;
  endgenerate

  logic [15:0] s4_0, c4_0;
  generate
    for (i = 0; i < 16; i = i + 1) begin : gen_csa_l4
      assign s4_0[i] = s3_0[i] ^ c3_0[i] ^ c2_1[i];
      if (i < 15) begin
        assign c4_0[i+1] = (s3_0[i] & c3_0[i]) | (c3_0[i] & c2_1[i]) | (s3_0[i] & c2_1[i]);
      end
    end
    assign c4_0[0] = 1'b0;
  endgenerate

  assign product = s4_0 + c4_0;
endmodule


/*
// Instance Example:
vrtl_dadda_mult_4x4 u_vrtl_dadda_mult_4x4 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
module vrtl_dadda_mult_4x4 (
    input  logic [3:0] a,
    input  logic [3:0] b,
    output logic [7:0] product
);
  // Dadda tree reduces height according to sequence: 2, 3, 4, 6, 9...
  vrtl_wallace_tree_mult_4x4 u_d4 (.a(a), .b(b), .product(product));
endmodule


/*
// Instance Example:
vrtl_dadda_mult_8x8 u_vrtl_dadda_mult_8x8 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
module vrtl_dadda_mult_8x8 (
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] product
);
  vrtl_wallace_tree_mult_8x8 u_d8 (.a(a), .b(b), .product(product));
endmodule


// =============================================================================
// Booth Multipliers (Radix-2 & Radix-4)
// =============================================================================

/*
// Instance Example:
vrtl_booth_radix2_mult_8x8 u_vrtl_booth_radix2_mult_8x8 (
    .clk     (clk),
    .rst_n   (rst_n),
    .start   (start),
    .a       (a),
    .b       (b),
    .product (product),
    .busy    (busy),
    .done    (done)
);
*/
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


/*
// Instance Example:
vrtl_booth_radix4_mult_8x8 u_vrtl_booth_radix4_mult_8x8 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
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


/*
// Instance Example:
vrtl_booth_radix4_mult_16x16 u_vrtl_booth_radix4_mult_16x16 (
    .a       (a),
    .b       (b),
    .product (product)
);
*/
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


// =============================================================================
// Pipelined High-Frequency Multiplier
// =============================================================================

/*
// Instance Example:
vrtl_multiplier_pipelined_8x8 u_vrtl_multiplier_pipelined_8x8 (
    .clk     (clk),
    .rst_n   (rst_n),
    .a       (a),
    .b       (b),
    .product (product)
);
*/
module vrtl_multiplier_pipelined_8x8 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [7:0]  a,
    input  logic [7:0]  b,
    output logic [15:0] product
);
  logic [15:0] stage1_prod;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      stage1_prod <= '0;
      product     <= '0;
    end else begin
      stage1_prod <= a * b;
      product     <= stage1_prod;
    end
  end
endmodule

`endif // VRTL_MULTIPLIERS_SV
