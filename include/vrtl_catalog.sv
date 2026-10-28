`ifndef VRTL_CATALOG_SV
`define VRTL_CATALOG_SV

// =============================================================================
// VRTL - Standard RTL IP Catalog
// Master Include Header
// =============================================================================

`include "vrtl_defines.svh"
`include "vrtl_pkg.sv"


// ARITHMETIC
`include "../arithmetic/adders/vrtl_adder_ripple.sv"
`include "../arithmetic/adders/vrtl_adder_cla.sv"
`include "../arithmetic/adders/vrtl_adder_csa.sv"
`include "../arithmetic/adders/vrtl_adder_carry_skip.sv"
`include "../arithmetic/adders/vrtl_adder_carry_select.sv"
`include "../arithmetic/adders/vrtl_adder_prefix.sv"
`include "../arithmetic/adders/vrtl_adder_bcd.sv"
`include "../arithmetic/multipliers/vrtl_mult_array.sv"
`include "../arithmetic/multipliers/vrtl_mult_baugh_wooley.sv"
`include "../arithmetic/multipliers/vrtl_mult_tree.sv"
`include "../arithmetic/multipliers/vrtl_mult_booth.sv"
`include "../arithmetic/multipliers/vrtl_mult_pipelined.sv"
`include "../arithmetic/dividers/vrtl_divider_sequential.sv"
`include "../arithmetic/dividers/vrtl_divider_comb_pipe.sv"
`include "../arithmetic/dividers/vrtl_sqrt_clz.sv"
`include "../arithmetic/alu/vrtl_alu_74xx181.sv"
`include "../arithmetic/alu/vrtl_alu.sv"

// DSP
`include "../dsp/vrtl_dsp_arithmetic.sv"
`include "../dsp/vrtl_dsp_mac.sv"
`include "../dsp/vrtl_dsp_filters.sv"
`include "../dsp/vrtl_dsp_cordic.sv"

// MEMORY
`include "../memory/rams/vrtl_ram_single_port.sv"
`include "../memory/rams/vrtl_ram_dual_port.sv"
`include "../memory/rams/vrtl_ram_true_dual_port.sv"
`include "../memory/roms/vrtl_rom.sv"
`include "../memory/fifos/vrtl_fifo_sync.sv"
`include "../memory/fifos/vrtl_fifo_async.sv"

// STREAM
`include "../stream/vrtl_stream_slices.sv"
`include "../stream/vrtl_stream_routing.sv"
`include "../stream/vrtl_stream_width.sv"

// INTERCONNECT
`include "../interconnect/arbiters/vrtl_arbiter_fixed.sv"
`include "../interconnect/arbiters/vrtl_arbiter_rr.sv"
`include "../interconnect/arbiters/vrtl_arbiter_advanced.sv"
`include "../interconnect/crossbar/vrtl_crossbar.sv"

// CDC
`include "../cdc/vrtl_cdc_bit.sv"
`include "../cdc/vrtl_cdc_pulse_handshake.sv"
`include "../cdc/vrtl_cdc_data.sv"
`include "../cdc/vrtl_edge_detect.sv"

// CLOCK
`include "../clock/vrtl_clock_gates.sv"
`include "../clock/vrtl_clock_dividers.sv"

// LOGIC
`include "../logic/mux/vrtl_mux.sv"
`include "../logic/decoders/vrtl_decoders.sv"
`include "../logic/encoders/vrtl_encoders.sv"
`include "../logic/comparators/vrtl_comparators.sv"
`include "../logic/shifters/vrtl_shifters.sv"

// SEQUENTIAL
`include "../sequential/flip_flops/vrtl_flip_flops.sv"
`include "../sequential/registers/vrtl_registers.sv"
`include "../sequential/registers/vrtl_shift_registers.sv"
`include "../sequential/registers/vrtl_reg_file.sv"
`include "../sequential/counters/vrtl_counters_binary.sv"
`include "../sequential/counters/vrtl_counters_special.sv"

// PERIPHERALS
`include "../peripherals/comms/vrtl_uart.sv"
`include "../peripherals/comms/vrtl_spi.sv"
`include "../peripherals/io/vrtl_debouncer.sv"
`include "../peripherals/io/vrtl_pwm.sv"
`include "../peripherals/io/vrtl_display_7seg.sv"
`include "../peripherals/io/vrtl_rotary_encoder.sv"

// SECURITY_ECC
`include "../security_ecc/ecc/vrtl_ecc_hamming.sv"
`include "../security_ecc/crc/vrtl_crc.sv"
`include "../security_ecc/prng/vrtl_prng_lfsr.sv"

// CONVERTERS
`include "../converters/vrtl_converter_bcd.sv"
`include "../converters/vrtl_converter_gray.sv"
`include "../converters/vrtl_converter_thermometer.sv"

`endif // VRTL_CATALOG_SV