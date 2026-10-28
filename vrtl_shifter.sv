`ifndef VRTL_SHIFTER_SV
`define VRTL_SHIFTER_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Non-Parametric Shifters & Rotators (8-bit, 16-bit, 32-bit)
// =============================================================================

/*
// Instance Example:
vrtl_barrel_shifter_8b u_vrtl_barrel_shifter_8b (
    .data_in   (data_in),
    .shift_amt (shift_amt),
    .dir       (dir),
    .arith     (arith),
    .data_out  (data_out)
);
*/
module vrtl_barrel_shifter_8b (
    input  logic [7:0] data_in,
    input  logic [2:0] shift_amt,
    input  logic       dir,
    input  logic       arith,
    output logic [7:0] data_out
);
  always_comb begin
    if (dir) begin
      data_out = arith ? 8'($signed(data_in) >>> shift_amt) : (data_in >> shift_amt);
    end else begin
      data_out = data_in << shift_amt;
    end
  end
endmodule


/*
// Instance Example:
vrtl_barrel_shifter_16b u_vrtl_barrel_shifter_16b (
    .data_in   (data_in),
    .shift_amt (shift_amt),
    .dir       (dir),
    .arith     (arith),
    .data_out  (data_out)
);
*/
module vrtl_barrel_shifter_16b (
    input  logic [15:0] data_in,
    input  logic [3:0]  shift_amt,
    input  logic        dir,
    input  logic        arith,
    output logic [15:0] data_out
);
  always_comb begin
    if (dir) begin
      data_out = arith ? 16'($signed(data_in) >>> shift_amt) : (data_in >> shift_amt);
    end else begin
      data_out = data_in << shift_amt;
    end
  end
endmodule


/*
// Instance Example:
vrtl_barrel_shifter_32b u_vrtl_barrel_shifter_32b (
    .data_in   (data_in),
    .shift_amt (shift_amt),
    .dir       (dir),
    .arith     (arith),
    .data_out  (data_out)
);
*/
module vrtl_barrel_shifter_32b (
    input  logic [31:0] data_in,
    input  logic [4:0]  shift_amt,
    input  logic        dir,
    input  logic        arith,
    output logic [31:0] data_out
);
  always_comb begin
    if (dir) begin
      data_out = arith ? 32'($signed(data_in) >>> shift_amt) : (data_in >> shift_amt);
    end else begin
      data_out = data_in << shift_amt;
    end
  end
endmodule


/*
// Instance Example:
vrtl_rotator_8b u_vrtl_rotator_8b (
    .data_in  (data_in),
    .rot_amt  (rot_amt),
    .dir      (dir),
    .data_out (data_out)
);
*/
module vrtl_rotator_8b (
    input  logic [7:0] data_in,
    input  logic [2:0] rot_amt,
    input  logic       dir,
    output logic [7:0] data_out
);
  logic [15:0] double_data;
  always_comb begin
    double_data = {data_in, data_in};
    if (dir) begin
      data_out = double_data[rot_amt +: 8];
    end else begin
      data_out = double_data[8 - rot_amt +: 8];
    end
  end
endmodule


// =============================================================================
// Parametric Barrel Shifter, Logarithmic Shifter & Funnel Shifter
// =============================================================================

/*
// Instance Example:
vrtl_barrel_shifter #(
    .WIDTH(32)
) u_vrtl_barrel_shifter (
    .data_in   (data_in),
    .shift_amt (shift_amt),
    .dir       (dir),
    .arith     (arith),
    .data_out  (data_out)
);
*/
module vrtl_barrel_shifter #(
    parameter int WIDTH     = 32,
    localparam int SHIFT_W  = (WIDTH > 1) ? $clog2(WIDTH) : 1
)(
    input  logic [WIDTH-1:0]   data_in,
    input  logic [SHIFT_W-1:0] shift_amt,
    input  logic               dir,
    input  logic               arith,
    output logic [WIDTH-1:0]   data_out
);
  always_comb begin
    if (dir) begin
      if (arith) begin
        data_out = $signed(data_in) >>> shift_amt;
      end else begin
        data_out = data_in >> shift_amt;
      end
    end else begin
      data_out = data_in << shift_amt;
    end
  end
endmodule


/*
// Instance Example:
vrtl_barrel_shifter_logarithmic #(
    .WIDTH(16)
) u_vrtl_barrel_shifter_logarithmic (
    .data_in   (data_in),
    .shift_amt (shift_amt),
    .dir       (dir),
    .data_out  (data_out)
);
*/
module vrtl_barrel_shifter_logarithmic #(
    parameter int WIDTH    = 16,
    localparam int STAGES  = $clog2(WIDTH)
)(
    input  logic [WIDTH-1:0]  data_in,
    input  logic [STAGES-1:0] shift_amt,
    input  logic              dir, // 0 = Left, 1 = Right
    output logic [WIDTH-1:0]  data_out
);
  logic [WIDTH-1:0] stage_data [STAGES+1];

  always_comb begin
    stage_data[0] = data_in;

    for (int s = 0; s < STAGES; s = s + 1) begin
      int shift_step;
      shift_step = (1 << s);
      if (shift_amt[s]) begin
        if (dir) begin
          stage_data[s+1] = stage_data[s] >> shift_step;
        end else begin
          stage_data[s+1] = stage_data[s] << shift_step;
        end
      end else begin
        stage_data[s+1] = stage_data[s];
      end
    end

    data_out = stage_data[STAGES];
  end
endmodule


/*
// Instance Example:
vrtl_funnel_shifter #(
    .WIDTH(32)
) u_vrtl_funnel_shifter (
    .a      (a),
    .b      (b),
    .offset (offset),
    .result (result)
);
*/
module vrtl_funnel_shifter #(
    parameter int WIDTH   = 32,
    localparam int OFF_W  = $clog2(WIDTH)
)(
    input  logic [WIDTH-1:0] a,      // Most significant word
    input  logic [WIDTH-1:0] b,      // Least significant word
    input  logic [OFF_W-1:0] offset, // Shift amount
    output logic [WIDTH-1:0] result
);
  wire [2*WIDTH-1:0] funnel = {a, b};
  assign result = funnel[offset +: WIDTH];
endmodule


/*
// Instance Example:
vrtl_rotator #(
    .WIDTH(32)
) u_vrtl_rotator (
    .data_in  (data_in),
    .rot_amt  (rot_amt),
    .dir      (dir),
    .data_out (data_out)
);
*/
module vrtl_rotator #(
    parameter int WIDTH    = 32,
    localparam int ROT_W   = (WIDTH > 1) ? $clog2(WIDTH) : 1
)(
    input  logic [WIDTH-1:0] data_in,
    input  logic [ROT_W-1:0] rot_amt,
    input  logic             dir,
    output logic [WIDTH-1:0] data_out
);
  logic [2*WIDTH-1:0] double_data;
  always_comb begin
    double_data = {data_in, data_in};
    if (dir) begin
      data_out = double_data[rot_amt +: WIDTH];
    end else begin
      data_out = double_data[WIDTH - rot_amt +: WIDTH];
    end
  end
endmodule

`endif // VRTL_SHIFTER_SV
