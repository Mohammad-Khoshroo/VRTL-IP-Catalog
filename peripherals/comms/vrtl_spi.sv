`ifndef PERIPHERALS_COMMS_VRTL_SPI_SV
`define PERIPHERALS_COMMS_VRTL_SPI_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_spi_master #(
//     .DATA_WIDTH (8),
//     .CLK_DIV    (4),
//     .CPOL       (0),
//     .CPHA       (0)
// ) u_vrtl_spi_master (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .start   (start),
//     .tx_data (tx_data),
//     .rx_data (rx_data),
//     .busy    (busy),
//     .done    (done),
//     .sclk    (sclk),
//     .mosi    (mosi),
//     .miso    (miso),
//     .cs_n    (cs_n)
// );
// =============================================================================
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


// =============================================================================
// vrtl_spi_slave #(
//     .DATA_WIDTH (8)
// ) u_vrtl_spi_slave (
//     .clk      (clk),
//     .rst_n    (rst_n),
//     .sclk     (sclk),
//     .cs_n     (cs_n),
//     .mosi     (mosi),
//     .miso     (miso),
//     .tx_data  (tx_data),
//     .rx_data  (rx_data),
//     .rx_valid (rx_valid)
// );
// =============================================================================
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

`endif // PERIPHERALS_COMMS_VRTL_SPI_SV
