`ifndef VRTL_PERIPHERALS_SV
`define VRTL_PERIPHERALS_SV

`include "vrtl_defines.svh"
import vrtl_pkg::*;

// =============================================================================
// IO Peripherals & Board Controllers
// =============================================================================

/*
// Instance Example:
vrtl_debouncer #(
    .DEBOUNCE_CYCLES(100_000)
) u_vrtl_debouncer (
    .clk       (clk),
    .rst_n     (rst_n),
    .noisy_in  (noisy_in),
    .clean_out (clean_out)
);
*/
module vrtl_debouncer #(
    parameter int DEBOUNCE_CYCLES = 100_000,
    localparam int CNT_W = $clog2(DEBOUNCE_CYCLES + 1)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic noisy_in,
    output logic clean_out
);
  logic [CNT_W-1:0] cnt;
  logic sync0, sync1;
  logic state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sync0     <= 1'b0;
      sync1     <= 1'b0;
      state     <= 1'b0;
      cnt       <= '0;
      clean_out <= 1'b0;
    end else begin
      sync0 <= noisy_in;
      sync1 <= sync0;

      if (sync1 != state) begin
        state <= sync1;
        cnt   <= '0;
      end else if (cnt < CNT_W'(DEBOUNCE_CYCLES)) begin
        cnt <= cnt + 1'b1;
      end else begin
        clean_out <= state;
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_pwm_gen #(
    .WIDTH(8)
) u_vrtl_pwm_gen (
    .clk        (clk),
    .rst_n      (rst_n),
    .duty_cycle (duty_cycle),
    .pwm_out    (pwm_out)
);
*/
module vrtl_pwm_gen #(
    parameter int WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] duty_cycle,
    output logic             pwm_out
);
  logic [WIDTH-1:0] cnt;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt     <= '0;
      pwm_out <= 1'b0;
    end else begin
      cnt     <= cnt + 1'b1;
      pwm_out <= (cnt < duty_cycle);
    end
  end
endmodule


/*
// Instance Example:
vrtl_hex_to_7seg u_vrtl_hex_to_7seg (
    .hex (hex),
    .seg (seg)
);
*/
module vrtl_hex_to_7seg (
    input  logic [3:0] hex,
    output logic [6:0] seg // {g, f, e, d, c, b, a} Active-low
);
  always_comb begin
    case (hex)
      4'h0: seg = 7'b100_0000;
      4'h1: seg = 7'b111_1001;
      4'h2: seg = 7'b010_0100;
      4'h3: seg = 7'b011_0000;
      4'h4: seg = 7'b001_1001;
      4'h5: seg = 7'b001_0010;
      4'h6: seg = 7'b000_0010;
      4'h7: seg = 7'b111_1000;
      4'h8: seg = 7'b000_0000;
      4'h9: seg = 7'b001_0000;
      4'hA: seg = 7'b000_1000;
      4'hB: seg = 7'b000_0011;
      4'hC: seg = 7'b100_0110;
      4'hD: seg = 7'b010_0001;
      4'hE: seg = 7'b000_0110;
      4'hF: seg = 7'b000_1110;
      default: seg = 7'b111_1111;
    endcase
  end
endmodule


/*
// Instance Example:
vrtl_seven_seg_controller #(
    .DIGITS(4),
    .SCAN_INTERVAL(50_000)
) u_vrtl_seven_seg_controller (
    .clk     (clk),
    .rst_n   (rst_n),
    .hex_in  (hex_in),
    .dp_in   (dp_in),
    .anodes  (anodes),
    .cathodes(cathodes),
    .dp_out  (dp_out)
);
*/
module vrtl_seven_seg_controller #(
    parameter int DIGITS        = 4,
    parameter int SCAN_INTERVAL = 50_000,
    localparam int DIGIT_W      = $clog2(DIGITS),
    localparam int CNT_W        = $clog2(SCAN_INTERVAL + 1)
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic [4*DIGITS-1:0]     hex_in,
    input  logic [DIGITS-1:0]       dp_in,
    output logic [DIGITS-1:0]       anodes,   // Active-low
    output logic [6:0]              cathodes, // Active-low {g,f,e,d,c,b,a}
    output logic                    dp_out    // Active-low
);
  logic [CNT_W-1:0]   scan_cnt;
  logic [DIGIT_W-1:0] cur_digit;
  logic [3:0]         cur_hex;

  assign cur_hex = hex_in[cur_digit*4 +: 4];
  assign dp_out  = ~dp_in[cur_digit];

  vrtl_hex_to_7seg dec (
      .hex (cur_hex),
      .seg (cathodes)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      scan_cnt  <= '0;
      cur_digit <= '0;
      anodes    <= '1;
    end else begin
      if (scan_cnt >= CNT_W'(SCAN_INTERVAL - 1)) begin
        scan_cnt  <= '0;
        cur_digit <= (cur_digit == DIGIT_W'(DIGITS - 1)) ? '0 : cur_digit + 1'b1;
      end else begin
        scan_cnt <= scan_cnt + 1'b1;
      end

      anodes <= '1;
      anodes[cur_digit] <= 1'b0;
    end
  end
endmodule


/*
// Instance Example:
vrtl_uart_tx #(
    .CLKS_PER_BIT(868)
) u_vrtl_uart_tx (
    .clk      (clk),
    .rst_n    (rst_n),
    .tx_start (tx_start),
    .tx_data  (tx_data),
    .tx       (tx),
    .tx_busy  (tx_busy),
    .tx_done  (tx_done)
);
*/
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


/*
// Instance Example:
vrtl_uart_rx #(
    .CLKS_PER_BIT(868)
) u_vrtl_uart_rx (
    .clk      (clk),
    .rst_n    (rst_n),
    .rx       (rx),
    .rx_data  (rx_data),
    .rx_valid (rx_valid),
    .rx_error (rx_error)
);
*/
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


/*
// Instance Example:
vrtl_spi_master #(
    .DATA_WIDTH(8),
    .CLK_DIV(4),
    .CPOL(0),
    .CPHA(0)
) u_vrtl_spi_master (
    .clk     (clk),
    .rst_n   (rst_n),
    .start   (start),
    .tx_data (tx_data),
    .rx_data (rx_data),
    .busy    (busy),
    .done    (done),
    .sclk    (sclk),
    .mosi    (mosi),
    .miso    (miso),
    .cs_n    (cs_n)
);
*/
module vrtl_spi_master #(
    parameter int DATA_WIDTH = 8,
    parameter int CLK_DIV    = 4,
    parameter bit CPOL       = 0,
    parameter bit CPHA       = 0,
    localparam int CNT_W     = $clog2(CLK_DIV + 1),
    localparam int BIT_W     = $clog2(DATA_WIDTH + 1)
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  start,
    input  logic [DATA_WIDTH-1:0] tx_data,
    output logic [DATA_WIDTH-1:0] rx_data,
    output logic                  busy,
    output logic                  done,

    output logic                  sclk,
    output logic                  mosi,
    input  logic                  miso,
    output logic                  cs_n
);
  typedef enum logic [1:0] {
    SPI_IDLE = 2'b00,
    SPI_XFER = 2'b01,
    SPI_DONE = 2'b10
  } spi_state_t;

  spi_state_t state;
  logic [CNT_W-1:0] clk_cnt;
  logic [BIT_W-1:0] bit_cnt;
  logic [DATA_WIDTH-1:0] tx_shift;
  logic [DATA_WIDTH-1:0] rx_shift;
  logic sclk_reg;

  assign sclk = sclk_reg;
  assign mosi = tx_shift[DATA_WIDTH-1];
  assign cs_n = (state == SPI_IDLE);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state    <= SPI_IDLE;
      clk_cnt  <= '0;
      bit_cnt  <= '0;
      tx_shift <= '0;
      rx_shift <= '0;
      rx_data  <= '0;
      busy     <= 1'b0;
      done     <= 1'b0;
      sclk_reg <= CPOL;
    end else begin
      done <= 1'b0;

      case (state)
        SPI_IDLE: begin
          sclk_reg <= CPOL;
          busy     <= 1'b0;
          clk_cnt  <= '0;
          bit_cnt  <= '0;
          if (start) begin
            tx_shift <= tx_data;
            busy     <= 1'b1;
            state    <= SPI_XFER;
          end
        end

        SPI_XFER: begin
          if (clk_cnt < CNT_W'(CLK_DIV - 1)) begin
            clk_cnt <= clk_cnt + 1'b1;
          end else begin
            clk_cnt  <= '0;
            sclk_reg <= ~sclk_reg;

            // Sample / Shift on clock edges
            if (sclk_reg == CPOL) begin
              // Leading edge
              if (CPHA == 0) begin
                rx_shift <= {rx_shift[DATA_WIDTH-2:0], miso};
              end else begin
                tx_shift <= {tx_shift[DATA_WIDTH-2:0], 1'b0};
              end
            end else begin
              // Trailing edge
              if (CPHA == 0) begin
                tx_shift <= {tx_shift[DATA_WIDTH-2:0], 1'b0};
              end else begin
                rx_shift <= {rx_shift[DATA_WIDTH-2:0], miso};
              end

              if (bit_cnt == BIT_W'(DATA_WIDTH - 1)) begin
                state <= SPI_DONE;
              end else begin
                bit_cnt <= bit_cnt + 1'b1;
              end
            end
          end
        end

        SPI_DONE: begin
          rx_data  <= rx_shift;
          done     <= 1'b1;
          busy     <= 1'b0;
          sclk_reg <= CPOL;
          state    <= SPI_IDLE;
        end
      endcase
    end
  end
endmodule


/*
// Instance Example:
vrtl_spi_slave #(
    .DATA_WIDTH(8)
) u_vrtl_spi_slave (
    .clk      (clk),
    .rst_n    (rst_n),
    .sclk     (sclk),
    .cs_n     (cs_n),
    .mosi     (mosi),
    .miso     (miso),
    .tx_data  (tx_data),
    .rx_data  (rx_data),
    .rx_valid (rx_valid)
);
*/
module vrtl_spi_slave #(
    parameter int DATA_WIDTH = 8,
    localparam int BIT_W     = $clog2(DATA_WIDTH + 1)
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  sclk,
    input  logic                  cs_n,
    input  logic                  mosi,
    output logic                  miso,
    input  logic [DATA_WIDTH-1:0] tx_data,
    output logic [DATA_WIDTH-1:0] rx_data,
    output logic                  rx_valid
);
  logic sclk_d1, sclk_d2;
  logic cs_n_d1, cs_n_d2;
  logic mosi_d1, mosi_d2;
  logic [DATA_WIDTH-1:0] tx_shift;
  logic [DATA_WIDTH-1:0] rx_shift;
  logic [BIT_W-1:0] bit_cnt;

  assign miso = tx_shift[DATA_WIDTH-1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sclk_d1  <= 1'b0;
      sclk_d2  <= 1'b0;
      cs_n_d1  <= 1'b1;
      cs_n_d2  <= 1'b1;
      mosi_d1  <= 1'b0;
      mosi_d2  <= 1'b0;
      tx_shift <= '0;
      rx_shift <= '0;
      rx_data  <= '0;
      rx_valid <= 1'b0;
      bit_cnt  <= '0;
    end else begin
      sclk_d1 <= sclk;
      sclk_d2 <= sclk_d1;
      cs_n_d1 <= cs_n;
      cs_n_d2 <= cs_n_d1;
      mosi_d1 <= mosi;
      mosi_d2 <= mosi_d1;

      rx_valid <= 1'b0;

      if (cs_n_d2) begin
        bit_cnt  <= '0;
        tx_shift <= tx_data;
      end else begin
        // Rising edge of SCLK -> sample MOSI
        if (sclk_d1 && !sclk_d2) begin
          rx_shift <= {rx_shift[DATA_WIDTH-2:0], mosi_d2};
          if (bit_cnt == BIT_W'(DATA_WIDTH - 1)) begin
            rx_data  <= {rx_shift[DATA_WIDTH-2:0], mosi_d2};
            rx_valid <= 1'b1;
            bit_cnt  <= '0;
          end else begin
            bit_cnt <= bit_cnt + 1'b1;
          end
        end
        // Falling edge of SCLK -> shift MISO
        if (!sclk_d1 && sclk_d2) begin
          tx_shift <= {tx_shift[DATA_WIDTH-2:0], 1'b0};
        end
      end
    end
  end
endmodule


/*
// Instance Example:
vrtl_rotary_encoder_decoder u_vrtl_rotary_encoder_decoder (
    .clk        (clk),
    .rst_n      (rst_n),
    .a_in       (a_in),
    .b_in       (b_in),
    .step_pulse (step_pulse),
    .dir_cw     (dir_cw)
);
*/
module vrtl_rotary_encoder_decoder (
    input  logic clk,
    input  logic rst_n,
    input  logic a_in,
    input  logic b_in,
    output logic step_pulse,
    output logic dir_cw
);
  logic a_sync0, a_sync1;
  logic b_sync0, b_sync1;
  logic [1:0] state, prev_state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      a_sync0    <= 1'b0;
      a_sync1    <= 1'b0;
      b_sync0    <= 1'b0;
      b_sync1    <= 1'b0;
      state      <= 2'b00;
      prev_state <= 2'b00;
      step_pulse <= 1'b0;
      dir_cw     <= 1'b0;
    end else begin
      a_sync0 <= a_in;
      a_sync1 <= a_sync0;
      b_sync0 <= b_in;
      b_sync1 <= b_sync0;

      prev_state <= state;
      state      <= {a_sync1, b_sync1};

      step_pulse <= 1'b0;

      case ({prev_state, state})
        // Clockwise transitions: 00->01, 01->11, 11->10, 10->00
        4'b00_01, 4'b01_11, 4'b11_10, 4'b10_00: begin
          step_pulse <= 1'b1;
          dir_cw     <= 1'b1;
        end
        // Counter-clockwise transitions: 00->10, 10->11, 11->01, 01->00
        4'b00_10, 4'b10_11, 4'b11_01, 4'b01_00: begin
          step_pulse <= 1'b1;
          dir_cw     <= 1'b0;
        end
        default: ;
      endcase
    end
  end
endmodule

`endif // VRTL_PERIPHERALS_SV
