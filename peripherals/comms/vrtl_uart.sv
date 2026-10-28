`ifndef PERIPHERALS_COMMS_VRTL_UART_SV
`define PERIPHERALS_COMMS_VRTL_UART_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_uart_tx #(
//     .CLKS_PER_BIT (868)
// ) u_vrtl_uart_tx (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .tx_start (tx_start),
//     .tx_data  (tx_data),
//     .tx       (tx),
//     .tx_busy  (tx_busy),
//     .tx_done  (tx_done)
// );
// =============================================================================
module vrtl_uart_tx #(
    parameter int CLKS_PER_BIT = 868,
    localparam int CNT_W       = $clog2(CLKS_PER_BIT + 1)
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_busy,
    output logic       tx_done
);
  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    STOP  = 2'b11
  } state_t;

  state_t state;
  logic [CNT_W-1:0] clk_cnt;
  logic [2:0]       bit_idx;
  logic [7:0]       data_reg;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state    <= IDLE;
      tx       <= 1'b1;
      tx_busy  <= 1'b0;
      tx_done  <= 1'b0;
      clk_cnt  <= '0;
      bit_idx  <= '0;
      data_reg <= '0;
    end else begin
      tx_done <= 1'b0;

      case (state)
        IDLE: begin
          tx      <= 1'b1;
          tx_busy <= 1'b0;
          clk_cnt <= '0;
          bit_idx <= '0;
          if (tx_start) begin
            data_reg <= tx_data;
            tx_busy  <= 1'b1;
            state    <= START;
          end
        end

        START: begin
          tx <= 1'b0;
          if (clk_cnt < CNT_W'(CLKS_PER_BIT - 1)) begin
            clk_cnt <= clk_cnt + 1'b1;
          end else begin
            clk_cnt <= '0;
            state   <= DATA;
          end
        end

        DATA: begin
          tx <= data_reg[bit_idx];
          if (clk_cnt < CNT_W'(CLKS_PER_BIT - 1)) begin
            clk_cnt <= clk_cnt + 1'b1;
          end else begin
            clk_cnt <= '0;
            if (bit_idx < 3'd7) begin
              bit_idx <= bit_idx + 1'b1;
            end else begin
              bit_idx <= '0;
              state   <= STOP;
            end
          end
        end

        STOP: begin
          tx <= 1'b1;
          if (clk_cnt < CNT_W'(CLKS_PER_BIT - 1)) begin
            clk_cnt <= clk_cnt + 1'b1;
          end else begin
            clk_cnt <= '0;
            tx_done <= 1'b1;
            state   <= IDLE;
          end
        end
      endcase
    end
  end
endmodule


// =============================================================================
// vrtl_uart_rx #(
//     .CLKS_PER_BIT (868)
// ) u_vrtl_uart_rx (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .rx       (rx),
//     .rx_data  (rx_data),
//     .rx_valid (rx_valid),
//     .rx_error (rx_error)
// );
// =============================================================================
module vrtl_uart_rx #(
    parameter int CLKS_PER_BIT = 868,
    localparam int CNT_W       = $clog2(CLKS_PER_BIT + 1)
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       rx_error
);
  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    STOP  = 2'b11
  } state_t;

  state_t state;
  logic [CNT_W-1:0] clk_cnt;
  logic [2:0]       bit_idx;
  logic [7:0]       rx_shift;
  logic             rx_sync0, rx_sync1;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rx_sync0 <= 1'b1;
      rx_sync1 <= 1'b1;
    end else begin
      rx_sync0 <= rx;
      rx_sync1 <= rx_sync0;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state    <= IDLE;
      clk_cnt  <= '0;
      bit_idx  <= '0;
      rx_shift <= '0;
      rx_data  <= '0;
      rx_valid <= 1'b0;
      rx_error <= 1'b0;
    end else begin
      rx_valid <= 1'b0;
      rx_error <= 1'b0;

      case (state)
        IDLE: begin
          clk_cnt <= '0;
          bit_idx <= '0;
          if (!rx_sync1) begin
            state <= START;
          end
        end

        START: begin
          if (clk_cnt == CNT_W'(CLKS_PER_BIT / 2)) begin
            if (!rx_sync1) begin
              clk_cnt <= '0;
              state   <= DATA;
            end else begin
              state <= IDLE;
            end
          end else begin
            clk_cnt <= clk_cnt + 1'b1;
          end
        end

        DATA: begin
          if (clk_cnt < CNT_W'(CLKS_PER_BIT - 1)) begin
            clk_cnt <= clk_cnt + 1'b1;
          end else begin
            clk_cnt           <= '0;
            rx_shift[bit_idx] <= rx_sync1;
            if (bit_idx < 3'd7) begin
              bit_idx <= bit_idx + 1'b1;
            end else begin
              bit_idx <= '0;
              state   <= STOP;
            end
          end
        end

        STOP: begin
          if (clk_cnt < CNT_W'(CLKS_PER_BIT - 1)) begin
            clk_cnt <= clk_cnt + 1'b1;
          end else begin
            clk_cnt <= '0;
            if (rx_sync1) begin
              rx_data  <= rx_shift;
              rx_valid <= 1'b1;
            end else begin
              rx_error <= 1'b1;
            end
            state <= IDLE;
          end
        end
      endcase
    end
  end
endmodule

`endif // PERIPHERALS_COMMS_VRTL_UART_SV
