`ifndef SEQUENTIAL_COUNTERS_VRTL_COUNTERS_BINARY_SV
`define SEQUENTIAL_COUNTERS_VRTL_COUNTERS_BINARY_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_counter_async_ripple_4b u_vrtl_counter_async_ripple_4b (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .count (count)
// );
// =============================================================================
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


// =============================================================================
// vrtl_counter_4b_up u_vrtl_counter_4b_up (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .en        (en),
//     .carry_out (carry_out),
//     .count     (count)
// );
// =============================================================================
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


// =============================================================================
// vrtl_counter_8b_up u_vrtl_counter_8b_up (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .en        (en),
//     .carry_out (carry_out),
//     .count     (count)
// );
// =============================================================================
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


// =============================================================================
// vrtl_counter_up #(
//     .WIDTH (8),
//     .INIT  ('0)
// ) u_vrtl_counter_up (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .en        (en),
//     .carry_out (carry_out),
//     .count     (count)
// );
// =============================================================================
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


// =============================================================================
// vrtl_counter_down #(
//     .WIDTH (8),
//     .INIT  ('1)
// ) u_vrtl_counter_down (
//     .clk        (clk),
//     .rst_n      (rst_n),
//     .en         (en),
//     .borrow_out (borrow_out),
//     .count      (count)
// );
// =============================================================================
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


// =============================================================================
// vrtl_counter_up_down #(
//     .WIDTH (8),
//     .INIT  ('0)
// ) u_vrtl_counter_up_down (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .en      (en),
//     .up_down (up_down),
//     .count   (count)
// );
// =============================================================================
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


// =============================================================================
// vrtl_counter_load #(
//     .WIDTH (8),
//     .INIT  ('0)
// ) u_vrtl_counter_load (
//     .clk       (clk),
//     .rst_n     (rst_n),
//     .load      (load),
//     .en        (en),
//     .pload     (pload),
//     .carry_out (carry_out),
//     .count     (count)
// );
// =============================================================================
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


// =============================================================================
// vrtl_counter_prescaled #(
//     .PRESCALE_BITS (8),
//     .MAIN_BITS     (16)
// ) u_vrtl_counter_prescaled (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .en    (en),
//     .count (count)
// );
// =============================================================================
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

`endif // SEQUENTIAL_COUNTERS_VRTL_COUNTERS_BINARY_SV
