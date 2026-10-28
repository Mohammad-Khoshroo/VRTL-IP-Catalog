`ifndef VRTL_COUNTER_SV
`define VRTL_COUNTER_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// Non-Parametric & Ripple Counters
// =============================================================================

/*
// Instance Example:
vrtl_counter_async_ripple_4b u_vrtl_counter_async_ripple_4b (
    .clk   (clk),
    .rst_n (rst_n),
    .count (count)
);
*/
module vrtl_counter_async_ripple_4b (
    input  logic       clk,
    input  logic       rst_n,
    output logic [3:0] count
);
  always_ff @(negedge clk or negedge rst_n) begin
    if (!rst_n) count[0] <= 1'b0;
    else        count[0] <= ~count[0];
  end

  always_ff @(negedge count[0] or negedge rst_n) begin
    if (!rst_n) count[1] <= 1'b0;
    else        count[1] <= ~count[1];
  end

  always_ff @(negedge count[1] or negedge rst_n) begin
    if (!rst_n) count[2] <= 1'b0;
    else        count[2] <= ~count[2];
  end

  always_ff @(negedge count[2] or negedge rst_n) begin
    if (!rst_n) count[3] <= 1'b0;
    else        count[3] <= ~count[3];
  end
endmodule


/*
// Instance Example:
vrtl_counter_4b_up u_vrtl_counter_4b_up (
    .clk       (clk),
    .rst_n     (rst_n),
    .en        (en),
    .carry_out (carry_out),
    .count     (count)
);
*/
module vrtl_counter_4b_up (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic       carry_out,
    output logic [3:0] count
);
  assign carry_out = (count == 4'hF) && en;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 4'h0;
    end else if (en) begin
      count <= count + 1'b1;
    end
  end
endmodule


/*
// Instance Example:
vrtl_counter_8b_up u_vrtl_counter_8b_up (
    .clk       (clk),
    .rst_n     (rst_n),
    .en        (en),
    .carry_out (carry_out),
    .count     (count)
);
*/
module vrtl_counter_8b_up (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic       carry_out,
    output logic [7:0] count
);
  assign carry_out = (count == 8'hFF) && en;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 8'h00;
    end else if (en) begin
      count <= count + 1'b1;
    end
  end
endmodule


/*
// Instance Example:
vrtl_decade_counter u_vrtl_decade_counter (
    .clk       (clk),
    .rst_n     (rst_n),
    .en        (en),
    .carry_out (carry_out),
    .count     (count)
);
*/
module vrtl_decade_counter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic       carry_out,
    output logic [3:0] count
);
  assign carry_out = (count == 4'd9) && en;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 4'd0;
    end else if (en) begin
      if (count == 4'd9) begin
        count <= 4'd0;
      end else begin
        count <= count + 1'b1;
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_counter_decade_2digit u_vrtl_counter_decade_2digit (
    .clk       (clk),
    .rst_n     (rst_n),
    .en        (en),
    .carry_out (carry_out),
    .count     (count)
);
*/
module vrtl_counter_decade_2digit (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       en,
    output logic       carry_out,
    output logic [7:0] count // {tens, units}
);
  wire c0;

  vrtl_decade_counter d0 (
      .clk       (clk),
      .rst_n     (rst_n),
      .en        (en),
      .carry_out (c0),
      .count     (count[3:0])
  );

  vrtl_decade_counter d1 (
      .clk       (clk),
      .rst_n     (rst_n),
      .en        (c0),
      .carry_out (carry_out),
      .count     (count[7:4])
  );
endmodule


/*
// Instance Example:
vrtl_counter_decade_4digit u_vrtl_counter_decade_4digit (
    .clk       (clk),
    .rst_n     (rst_n),
    .en        (en),
    .carry_out (carry_out),
    .count     (count)
);
*/
module vrtl_counter_decade_4digit (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        en,
    output logic        carry_out,
    output logic [15:0] count // 4 BCD digits
);
  wire c0, c1, c2;

  vrtl_decade_counter d0 (.clk(clk), .rst_n(rst_n), .en(en), .carry_out(c0), .count(count[3:0]));
  vrtl_decade_counter d1 (.clk(clk), .rst_n(rst_n), .en(c0), .carry_out(c1), .count(count[7:4]));
  vrtl_decade_counter d2 (.clk(clk), .rst_n(rst_n), .en(c1), .carry_out(c2), .count(count[11:8]));
  vrtl_decade_counter d3 (.clk(clk), .rst_n(rst_n), .en(c2), .carry_out(carry_out), .count(count[15:12]));
endmodule


// =============================================================================
// Parametric Counters (Up, Down, Up/Down, Modulo-N, Gray, Ring, Johnson)
// =============================================================================

/*
// Instance Example:
vrtl_counter_up #(
    .WIDTH(8),
    .INIT('0)
) u_vrtl_counter_up (
    .clk       (clk),
    .rst_n     (rst_n),
    .en        (en),
    .carry_out (carry_out),
    .count     (count)
);
*/
module vrtl_counter_up #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] INIT = '0
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic             carry_out,
    output logic [WIDTH-1:0] count
);
  assign carry_out = (&count) && en;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= INIT;
    end else if (en) begin
      count <= count + 1'b1;
    end
  end
endmodule


/*
// Instance Example:
vrtl_counter_down #(
    .WIDTH(8),
    .INIT('1)
) u_vrtl_counter_down (
    .clk        (clk),
    .rst_n      (rst_n),
    .en         (en),
    .borrow_out (borrow_out),
    .count      (count)
);
*/
module vrtl_counter_down #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] INIT = '1
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic             borrow_out,
    output logic [WIDTH-1:0] count
);
  assign borrow_out = (count == '0) && en;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= INIT;
    end else if (en) begin
      count <= count - 1'b1;
    end
  end
endmodule


/*
// Instance Example:
vrtl_counter_up_down #(
    .WIDTH(8),
    .INIT('0)
) u_vrtl_counter_up_down (
    .clk     (clk),
    .rst_n   (rst_n),
    .en      (en),
    .up_down (up_down),
    .count   (count)
);
*/
module vrtl_counter_up_down #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] INIT = '0
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic             up_down,
    output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= INIT;
    end else if (en) begin
      if (up_down) begin
        count <= count + 1'b1;
      end else begin
        count <= count - 1'b1;
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_counter_load #(
    .WIDTH(8),
    .INIT('0)
) u_vrtl_counter_load (
    .clk       (clk),
    .rst_n     (rst_n),
    .load      (load),
    .en        (en),
    .pload     (pload),
    .carry_out (carry_out),
    .count     (count)
);
*/
module vrtl_counter_load #(
    parameter int WIDTH = 8,
    parameter logic [WIDTH-1:0] INIT = '0
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             load,
    input  logic             en,
    input  logic [WIDTH-1:0] pload,
    output logic             carry_out,
    output logic [WIDTH-1:0] count
);
  assign carry_out = (&count) && en;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= INIT;
    end else if (load) begin
      count <= pload;
    end else if (en) begin
      count <= count + 1'b1;
    end
  end
endmodule


/*
// Instance Example:
vrtl_counter_mod_n #(
    .MOD_VALUE(100),
    .WIDTH(7)
) u_vrtl_counter_mod_n (
    .clk      (clk),
    .rst_n    (rst_n),
    .en       (en),
    .tick_out (tick_out),
    .count    (count)
);
*/
module vrtl_counter_mod_n #(
    parameter int MOD_VALUE = 100,
    parameter int WIDTH     = (MOD_VALUE > 1) ? $clog2(MOD_VALUE) : 1
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic             tick_out,
    output logic [WIDTH-1:0] count
);
  assign tick_out = (count == WIDTH'(MOD_VALUE - 1)) && en;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= '0;
    end else if (en) begin
      if (count == WIDTH'(MOD_VALUE - 1)) begin
        count <= '0;
      end else begin
        count <= count + 1'b1;
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_gray_counter #(
    .WIDTH(4)
) u_vrtl_gray_counter (
    .clk        (clk),
    .rst_n      (rst_n),
    .en         (en),
    .count_bin  (count_bin),
    .count_gray (count_gray)
);
*/
module vrtl_gray_counter #(
    parameter int WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic [WIDTH-1:0] count_bin,
    output logic [WIDTH-1:0] count_gray
);
  assign count_gray = count_bin ^ (count_bin >> 1);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count_bin <= '0;
    end else if (en) begin
      count_bin <= count_bin + 1'b1;
    end
  end
endmodule


/*
// Instance Example:
vrtl_ring_counter #(
    .WIDTH(4)
) u_vrtl_ring_counter (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .count (count)
);
*/
module vrtl_ring_counter #(
    parameter int WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= {{WIDTH-1{1'b0}}, 1'b1};
    end else if (en) begin
      count <= {count[WIDTH-2:0], count[WIDTH-1]};
    end
  end
endmodule


/*
// Instance Example:
vrtl_ring_counter_self_correcting #(
    .WIDTH(4)
) u_vrtl_ring_counter_self_correcting (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .count (count)
);
*/
module vrtl_ring_counter_self_correcting #(
    parameter int WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic [WIDTH-1:0] count
);
  wire is_valid_onehot = (count != '0) && ((count & (count - 1'b1)) == '0);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= {{WIDTH-1{1'b0}}, 1'b1};
    end else if (en) begin
      if (!is_valid_onehot) begin
        count <= {{WIDTH-1{1'b0}}, 1'b1}; // Force valid state if corrupted
      end else begin
        count <= {count[WIDTH-2:0], count[WIDTH-1]};
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_johnson_counter #(
    .WIDTH(4)
) u_vrtl_johnson_counter (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .count (count)
);
*/
module vrtl_johnson_counter #(
    parameter int WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= '0;
    end else if (en) begin
      count <= {count[WIDTH-2:0], ~count[WIDTH-1]};
    end
  end
endmodule


/*
// Instance Example:
vrtl_johnson_counter_self_correcting #(
    .WIDTH(4)
) u_vrtl_johnson_counter_self_correcting (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .count (count)
);
*/
module vrtl_johnson_counter_self_correcting #(
    parameter int WIDTH = 4
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic [WIDTH-1:0] count
);
  // Self-correcting feedback: ~count[WIDTH-1] & ~(count[WIDTH-2] & ~count[0])
  wire feedback = ~count[WIDTH-1] && !(count[WIDTH-2] && !count[0]);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= '0;
    end else if (en) begin
      count <= {count[WIDTH-2:0], feedback};
    end
  end
endmodule


/*
// Instance Example:
vrtl_counter_prescaled #(
    .PRESCALE_BITS(8),
    .MAIN_BITS(16)
) u_vrtl_counter_prescaled (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .count (count)
);
*/
module vrtl_counter_prescaled #(
    parameter int PRESCALE_BITS = 8,
    parameter int MAIN_BITS     = 16
)(
    input  logic                                  clk,
    input  logic                                  rst_n,
    input  logic                                  en,
    output logic [PRESCALE_BITS+MAIN_BITS-1:0]    count
);
  logic [PRESCALE_BITS-1:0] prescaler;
  logic [MAIN_BITS-1:0]     main_cnt;

  assign count = {main_cnt, prescaler};
  wire prescaler_tick = (&prescaler) && en;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      prescaler <= '0;
      main_cnt  <= '0;
    end else if (en) begin
      prescaler <= prescaler + 1'b1;
      if (prescaler_tick) begin
        main_cnt <= main_cnt + 1'b1;
      end
    end
  end
endmodule

`endif // VRTL_COUNTER_SV
