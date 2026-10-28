`ifndef INTERCONNECT_ARBITERS_VRTL_ARBITER_ADVANCED_SV
`define INTERCONNECT_ARBITERS_VRTL_ARBITER_ADVANCED_SV

`include "../../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_arbiter_matrix_4 u_vrtl_arbiter_matrix_4 (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .req   (req),
//     .grant (grant)
// );
// =============================================================================
module vrtl_arbiter_matrix_4 (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [3:0] req,
    output logic [3:0] grant
);
  logic [3:0] matrix [4];

  always_comb begin
    for (int i = 0; i < 4; i = i + 1) begin
      grant[i] = req[i];
      for (int j = 0; j < 4; j = j + 1) begin
        if (i != j) begin
          grant[i] = grant[i] & (~req[j] | matrix[i][j]);
        end
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      matrix[0] <= 4'b0111;
      matrix[1] <= 4'b0011;
      matrix[2] <= 4'b0001;
      matrix[3] <= 4'b0000;
    end else if (|grant) begin
      for (int i = 0; i < 4; i = i + 1) begin
        if (grant[i]) begin
          matrix[i] <= 4'b0000;
          for (int j = 0; j < 4; j = j + 1) begin
            if (i != j) begin
              matrix[j][i] <= 1'b1;
            end
          end
        end
      end
    end
  end
endmodule


// =============================================================================
// vrtl_arbiter_wrr_4 u_vrtl_arbiter_wrr_4 (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .req     (req),
//     .weight0 (weight0),
//     .weight1 (weight1),
//     .weight2 (weight2),
//     .weight3 (weight3),
//     .grant   (grant)
// );
// =============================================================================
module vrtl_arbiter_wrr_4 (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [3:0] req,
    input  logic [3:0] weight0,
    input  logic [3:0] weight1,
    input  logic [3:0] weight2,
    input  logic [3:0] weight3,
    output logic [3:0] grant
);
  logic [3:0] credit [4];
  logic [3:0] eligible;

  always_comb begin
    for (int i = 0; i < 4; i = i + 1) begin
      eligible[i] = req[i] & (credit[i] > 4'd0);
    end
  end

  assign grant = (|eligible) ? (eligible & (-eligible)) : (req & (-req));

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      credit[0] <= weight0;
      credit[1] <= weight1;
      credit[2] <= weight2;
      credit[3] <= weight3;
    end else begin
      if (|eligible) begin
        for (int i = 0; i < 4; i = i + 1) begin
          if (grant[i] && credit[i] > 4'd0) begin
            credit[i] <= credit[i] - 1'b1;
          end
        end
      end else if (|req) begin
        credit[0] <= weight0;
        credit[1] <= weight1;
        credit[2] <= weight2;
        credit[3] <= weight3;
      end
    end
  end
endmodule

`endif // INTERCONNECT_ARBITERS_VRTL_ARBITER_ADVANCED_SV
