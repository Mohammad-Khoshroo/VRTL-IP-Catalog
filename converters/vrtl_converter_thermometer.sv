`ifndef CONVERTERS_VRTL_CONVERTER_THERMOMETER_SV
`define CONVERTERS_VRTL_CONVERTER_THERMOMETER_SV

`include "../include/vrtl_defines.svh"
import vrtl_pkg::*;


// =============================================================================
// vrtl_bin_to_thermometer_4b u_vrtl_bin_to_thermometer_4b (
//     .bin   (bin),
//     .therm (therm)
// );
// =============================================================================
module vrtl_bin_to_thermometer_4b (
    input  logic [3:0]  bin,
    output logic [14:0] therm
);
  always_comb begin
    for (int i = 0; i < 15; i = i + 1) begin
      therm[i] = (bin > 4'(i));
    end
  end
endmodule


// =============================================================================
// vrtl_thermometer_to_bin_15b u_vrtl_thermometer_to_bin_15b (
//     .therm (therm),
//     .bin   (bin)
// );
// =============================================================================
module vrtl_thermometer_to_bin_15b (
    input  logic [14:0] therm,
    output logic [3:0]  bin
);
  always_comb begin
    bin = '0;
    for (int i = 0; i < 15; i = i + 1) begin
      if (therm[i]) begin
        bin = bin + 1'b1;
      end
    end
  end
endmodule

`endif // CONVERTERS_VRTL_CONVERTER_THERMOMETER_SV
