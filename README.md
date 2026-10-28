# VRTL — Standard SystemVerilog RTL IP Catalog

A production-grade, synthesis-ready IP catalog of conventional digital RTL building blocks implemented in **SystemVerilog**. The catalog is hierarchically organized into structured domain directories containing **63 specialized source files** and **263 verified RTL modules** spanning basic logic gates up to advanced arithmetic architectures, digital signal processing blocks, bus arbiters, clock domain crossing (CDC) synchronizers, and communication interfaces.

Every single module features:
* A ready-to-copy, commented-out instantiation template placed directly above its definition.
* Clean, concise code without conversational comments or fluff.
* Both parametric (generic) and non-parametric (standard fixed-width / industry-standard) variants.
* Non-overdosing simulation assertion checks guarded by ``` `ifndef SYNTHESIS ``` for zero FPGA/ASIC area overhead.
* 100% verified compilation with **QuestaSim 2024.1** (`0 errors, 0 warnings`).

---

## 1. Hierarchical Directory Structure

```text
VRTL/
├── vrtl_catalog.sv                      # Root forwarder header (redirects to include/vrtl_catalog.sv)
├── README.md                            # Comprehensive technical reference manual
│
├── include/                             # Shared Global Definitions & Package
│   ├── vrtl_defines.svh                 # Global assertion macros and verification helpers
│   ├── vrtl_pkg.sv                      # SystemVerilog utility package (math & bit manipulation)
│   └── vrtl_catalog.sv                  # Master include header linking all 63 catalog files
│
├── arithmetic/                          # Computational & Arithmetic Operators
│   ├── adders/                          # Addition & Subtraction Architectures
│   │   ├── vrtl_adder_ripple.sv         # Half/Full Adders, Ripple-Carry Adders (4b-32b), Subtractors
│   │   ├── vrtl_adder_cla.sv            # 16-bit Carry-Lookahead Adder (CLA)
│   │   ├── vrtl_adder_csa.sv            # Carry-Save Compressors (3:2, 4:2, 5:2) & CSAs
│   │   ├── vrtl_adder_carry_skip.sv     # 4-bit CBA Block, 16-bit and 32-bit Carry-Skip Adders
│   │   ├── vrtl_adder_carry_select.sv   # 4-bit CSLA Block, 16b/32b CSLA, Square-Root CSLA-16
│   │   ├── vrtl_adder_prefix.sv         # Parallel-Prefix: Kogge-Stone, Brent-Kung, Sklansky, Han-Carlson
│   │   └── vrtl_adder_bcd.sv            # 1-Digit and 4-Digit BCD Decimal Adders, Bit-Serial Adder
│   ├── multipliers/                     # Multiplication Architectures
│   │   ├── vrtl_mult_array.sv           # Combinational Array & Sequential Shift-Add Multipliers
│   │   ├── vrtl_mult_baugh_wooley.sv    # Signed Two's Complement Baugh-Wooley Multipliers (4x4, 8x8)
│   │   ├── vrtl_mult_tree.sv            # Multi-level Tree Multipliers: Wallace & Dadda (4x4, 8x8)
│   │   ├── vrtl_mult_booth.sv           # Radix-2 & Radix-4 Modified Booth Multipliers (8x8, 16x16)
│   │   └── vrtl_mult_pipelined.sv       # 3-Stage Pipelined Multiplier (8x8)
│   ├── dividers/                        # Division, Roots & Normalization
│   │   ├── vrtl_divider_sequential.sv   # Sequential Restoring & Non-Restoring Dividers
│   │   ├── vrtl_divider_comb_pipe.sv    # Combinational Array & 8-Stage Pipelined Dividers
│   │   └── vrtl_sqrt_clz.sv             # Sequential Integer Square Root & Count Leading Zeros
│   └── alu/                             # Arithmetic Logic Units
│       ├── vrtl_alu_74xx181.sv          # Classic 74xx181 4-bit Multifunction ALU
│       └── vrtl_alu.sv                  # 12-Operation Parameterized ALU with Status Flags
│
├── dsp/                                 # Digital Signal Processing Blocks
│   ├── vrtl_dsp_arithmetic.sv           # Saturating Add/Sub, Signed Absolute Value
│   ├── vrtl_dsp_mac.sv                  # Multiply-Accumulate (MAC) & Complex Multiplier
│   ├── vrtl_dsp_filters.sv              # Moving Average Boxcar Filter & 4-Tap Direct-Form FIR
│   └── vrtl_dsp_cordic.sv               # 16-Iteration CORDIC Vector Rotator & Peak Detector
│
├── memory/                              # Memories & Queues
│   ├── rams/                            # Random Access Memories
│   │   ├── vrtl_ram_single_port.sv      # Single-Port RAMs (Standard, Parametric, Byte-Enable)
│   │   ├── vrtl_ram_dual_port.sv        # Simple Dual-Port RAM & Distributed LUT-RAM
│   │   └── vrtl_ram_true_dual_port.sv   # True Dual-Port RAMs (Standard & Byte-Enable)
│   ├── roms/                            # Read-Only Memories
│   │   └── vrtl_rom.sv                  # Synchronous & Combinational ROMs with $readmemh
│   └── fifos/                           # First-In First-Out Queues
│       ├── vrtl_fifo_sync.sv            # Sync FIFOs (Fixed 16x8, 2-Depth Skid, Param, Prog, FWFT)
│       └── vrtl_fifo_async.sv           # Dual-Clock Async FIFOs (Cummings Gray-Code, Fixed, FWFT)
│
├── stream/                              # AXI-Stream / Ready-Valid Flow Control
│   ├── vrtl_stream_slices.sv            # 2-Register Skid Buffer, Forward & Backward Register Slices
│   ├── vrtl_stream_routing.sv           # Stream Fork (1:2), Mux (2:1), Demux (1:2), Join (2:1)
│   └── vrtl_stream_width.sv             # Stream Width Upsizer (Narrow->Wide) & Downsizer
│
├── interconnect/                        # On-Chip Interconnect & Arbitration
│   ├── arbiters/                        # Bus Arbiters
│   │   ├── vrtl_arbiter_fixed.sv        # Parallel Fixed-Priority Arbiters (4b, 8b, Param)
│   │   ├── vrtl_arbiter_rr.sv           # Rotating-Mask Fair Round-Robin Arbiters (4b, 8b, Param)
│   │   └── vrtl_arbiter_advanced.sv     # LRU Matrix Arbiter & Weighted Round-Robin (WRR)
│   └── crossbar/                        # Spatial Switches
│       └── vrtl_crossbar.sv             # Non-blocking 2x2 and 4x4 Crossbar Switches
│
├── cdc/                                 # Clock Domain Crossing (CDC) Synchronizers
│   ├── vrtl_cdc_bit.sv                  # 2-Stage & 3-Stage Flop Synchronizers, Reset Bridge
│   ├── vrtl_cdc_pulse_handshake.sv      # Toggle-based Pulse Synchronizer, 4-Phase Req/Ack Handshake
│   ├── vrtl_cdc_data.sv                 # Multi-bit Bus Synchronizer, Mux-Recirculation Data Sync
│   └── vrtl_edge_detect.sv              # Single-bit and N-bit Pos/Neg/Any Edge Detectors
│
├── clock/                               # Clock Utilities & Generation
│   ├── vrtl_clock_gates.sv              # Latch-based ICG Clock Gate, Glitch-Free Clock Mux
│   └── vrtl_clock_dividers.sv           # Div-by-2, Div-by-4, Even, Odd (50% Duty), Frac, Stretcher
│
├── logic/                               # Core Combinational Primitives
│   ├── mux/                             # Multiplexers
│   │   └── vrtl_mux.sv                  # 2:1, 4:1, 8:1, Tree, One-Hot, Priority, Fixed-width
│   ├── decoders/                        # Decoders
│   │   └── vrtl_decoders.sv             # 1:2, 2:4, 3:8, 4:16, 74xx138, Tree, 74xx42 BCD
│   ├── encoders/                        # Encoders
│   │   └── vrtl_encoders.sv             # Simple (4:2, 8:3), Priority (4:2, 8:3, 16:4, 74xx148), LOD
│   ├── comparators/                     # Comparators & Parity
│   │   └── vrtl_comparators.sv          # 1b-32b Comparators, 74xx85 Cascade, Min/Max, Window, Parity
│   └── shifters/                        # Shifters & Rotators
│       └── vrtl_shifters.sv             # Barrel Shifters (8b-32b, Logarithmic), Rotators, Funnel
│
├── sequential/                          # Core Sequential Primitives
│   ├── flip_flops/                      # Latches & Basic Storage
│   │   └── vrtl_flip_flops.sv           # SR/D Latches, DFF (Async/Sync/En/Scan/Dual-edge), T-FF, JK-FF
│   ├── registers/                       # Registers & Multi-port Register Files
│   │   ├── vrtl_registers.sv            # Fixed/Param Registers, Byte-Enable, Shadow Registers
│   │   ├── vrtl_shift_registers.sv      # PISO, SIPO, SISO, Universal Shift Registers
│   │   └── vrtl_reg_file.sv             # 2R1W and 3R2W Multiport Register Files
│   └── counters/                        # Synchronous & Asynchronous Counters
│       ├── vrtl_counters_binary.sv      # Ripple Counter, Binary Up/Down, Loadable, Prescaled
│       └── vrtl_counters_special.sv     # Decade BCD (1, 2, 4 digits), Mod-N, Gray, Ring, Johnson
│
├── peripherals/                         # Board IO & Communication Controllers
│   ├── comms/                           # Serial Communications
│   │   ├── vrtl_uart.sv                 # Complete 8N1 UART Transmitter and Receiver
│   │   └── vrtl_spi.sv                  # Full-duplex SPI Master (Modes 0-3) and SPI Slave
│   └── io/                              # Board Peripherals
│       ├── vrtl_debouncer.sv            # Push-button Glitch Filter Debouncer
│       ├── vrtl_pwm.sv                  # Pulse-Width Modulation (PWM) Generator
│       ├── vrtl_display_7seg.sv         # Hex-to-7Seg & Multiplexed Multi-digit Display Driver
│       └── vrtl_rotary_encoder.sv       # Quadrature Rotary Encoder Decoder (Phase A/B, CW/CCW)
│
├── security_ecc/                        # Reliability, Error Correction & Randomness
│   ├── ecc/                             # Error Correction Codes
│   │   └── vrtl_ecc_hamming.sv          # (7,4) Hamming, 8b/32b SECDED Codes
│   ├── crc/                             # Cyclic Redundancy Checks
│   │   └── vrtl_crc.sv                  # CRC-8 (SMBus), CRC-16-CCITT, Serial Param, IEEE CRC-32
│   └── prng/                            # Pseudo-Random Number Generators
│       └── vrtl_prng_lfsr.sv            # LFSRs (4b-32b, Galois/Fibonacci), PRBS-7, PRBS-15, PRBS-31
│
└── converters/                          # Code Converters
    ├── vrtl_converter_bcd.sv            # Double-Dabble Binary <-> BCD (2, 3, 4 digits, Param)
    ├── vrtl_converter_gray.sv           # Binary <-> Gray Code Converters (4b, 8b, Param)
    └── vrtl_converter_thermometer.sv    # Binary <-> Thermometer Code Converters (4b/15b)
```

---

## 2. Package & Assertions (`vrtl_pkg.sv` & `vrtl_defines.svh`)

### Utility Package Functions (`vrtl_pkg::*`):
* `clog2(val)`: Returns $\lceil \log_2(\text{val}) \rceil$ (minimum 1) for address/selector bit-width calculations.
* `is_pow2(val)`: Returns `1` if `val` is a power of 2.
* `count_ones(val)`: Population count (number of active bits).
* `is_onehot(val)`: Returns `1` if exactly one bit is high.
* `is_onehot0(val)`: Returns `1` if at most one bit is high (zero or one-hot).
* `bin2gray(bin)`: Converts binary code to standard Gray code.
* `gray2bin(gray)`: Converts Gray code back to binary code.
* `reverse_bits(val, width)`: Reverses the bit ordering of an N-bit vector.
* `max_val(a, b)` / `min_val(a, b)`: Returns maximum or minimum of two integers.

### Assertion Macros (`vrtl_defines.svh`):
* `` `VRTL_ASSERT(NAME, COND, MSG) ``: Immediate assertion check.
* `` `VRTL_ASSERT_CLK(NAME, COND, CLK, RST_N, MSG) ``: Clocked concurrent assertion with active-low async reset disable.
* `` `VRTL_ASSERT_NEVER(NAME, COND, CLK, RST_N, MSG) ``: Asserts that an illegal condition never occurs (e.g., FIFO overflow/underflow).
* `` `VRTL_ASSERT_ONEHOT(NAME, SIG, CLK, RST_N, MSG) ``: Asserts one-hot exclusivity on a control bus.
* `` `VRTL_ASSERT_KNOWN(NAME, SIG, CLK, RST_N, MSG) ``: Detects illegal `'X` or `'Z` states during active clock cycles.

*(All assertions are guarded by `` `ifndef SYNTHESIS `` and completely stripped out during synthesis, ensuring zero FPGA/ASIC resource overhead).*

---

## 3. Detailed Directory & Module Index

### 3.1 Arithmetic Domain (`VRTL/arithmetic/`)

#### A. Adders (`arithmetic/adders/`)
* **`vrtl_adder_ripple.sv`**: Primitive Half Adder, Full Adder, Ripple-Carry Adders (4b, 8b, 16b, 32b), dedicated Subtractors (4b, 8b, 16b), and parameterized Adder, Subtractor, and unified Adder/Subtractor.
* **`vrtl_adder_cla.sv`**: 16-bit Carry-Lookahead Adder (CLA) with generate/propagate logic.
* **`vrtl_adder_csa.sv`**: Carry-Save Adders including 3:2, 4:2, and 5:2 compressor slices, 8b and 16b multi-operand CSAs, and parameterized CSA.
* **`vrtl_adder_carry_skip.sv`**: 4-bit Carry-Bypass Block (`vrtl_cba_block_4b`), 16-bit and 32-bit Carry-Skip (Bypass) Adders.
* **`vrtl_adder_carry_select.sv`**: 4-bit Dual-Speculative CSLA block, 16-bit and 32-bit Carry-Select Adders, and variable-block Square-Root Carry-Select Adder (`vrtl_carry_select_adder_sqrt_16b`).
* **`vrtl_adder_prefix.sv`**: Parallel-Prefix Adders including Kogge-Stone (8b, 16b), Brent-Kung (8b, 16b), Sklansky (8b), and Han-Carlson (16b).
* **`vrtl_adder_bcd.sv`**: 1-digit and 4-digit Decimal BCD Adders with +6 correction, and sequential Bit-Serial Adder.

#### B. Multipliers (`arithmetic/multipliers/`)
* **`vrtl_mult_array.sv`**: Sequential Shift-and-Add Multiplier, Combinational Array Multipliers (4x4, 8x8, parametric), and behavioral multiplier.
* **`vrtl_mult_baugh_wooley.sv`**: Signed Two's Complement Baugh-Wooley Multipliers (4x4, 8x8).
* **`vrtl_mult_tree.sv`**: Multi-level Tree Multipliers: Wallace Tree (4x4, 8x8) and Dadda Tree (4x4, 8x8).
* **`vrtl_mult_booth.sv`**: Radix-2 Booth Multiplier (8x8) and Radix-4 Modified Booth Multipliers (8x8, 16x16 with 50% partial product reduction).
* **`vrtl_mult_pipelined.sv`**: 3-Stage Pipelined Multiplier (`vrtl_multiplier_pipelined_8x8`).

#### C. Dividers (`arithmetic/dividers/`)
* **`vrtl_divider_sequential.sv`**: Parameterized Sequential Restoring and Non-Restoring Dividers.
* **`vrtl_divider_comb_pipe.sv`**: Combinational Array Dividers (4b, 8b) and 8-Stage Fully Pipelined Divider (`vrtl_divider_pipelined_8b`).
* **`vrtl_sqrt_clz.sv`**: Sequential Integer Square Root (`vrtl_sqrt_restoring`), 32-bit CLZ, and Parameterized Count Leading Zeros.

#### D. ALU (`arithmetic/alu/`)
* **`vrtl_alu_74xx181.sv`**: Classic 74xx181 4-bit Multifunction ALU.
* **`vrtl_alu.sv`**: Parameterized 12-Operation ALU with Zero, Negative, Carry, and Overflow flags.

---

### 3.2 DSP Domain (`VRTL/dsp/`)
* **`vrtl_dsp_arithmetic.sv`**: Signed/Unsigned Saturating Adder, Saturating Subtractor, and Signed Absolute Value with saturation (`vrtl_dsp_abs`).
* **`vrtl_dsp_mac.sv`**: Multiply-Accumulate unit (`vrtl_mac`) with sync clear/enable, and Complex Multiplier (`vrtl_complex_mult`).
* **`vrtl_dsp_filters.sv`**: Moving Average Boxcar Filter and 4-Tap Direct-Form FIR Filter (`vrtl_fir_filter_4tap`).
* **`vrtl_dsp_cordic.sv`**: 16-Iteration CORDIC Vector Rotator and Dynamic Peak Detector (`vrtl_peak_detector`).

---

### 3.3 Memory & Storage Domain (`VRTL/memory/`)
* **`memory/rams/vrtl_ram_single_port.sv`**: 256x8 SP-RAM, Parameterized SP-RAM, and SP-RAM with individual Byte-Write Enables.
* **`memory/rams/vrtl_ram_dual_port.sv`**: Simple Dual-Port RAM (Port A: Write, Port B: Read) and Distributed LUT-RAM (`vrtl_ram_async_read`).
* **`memory/rams/vrtl_ram_true_dual_port.sv`**: True Dual-Port RAMs (2 independent R/W ports) in standard and Byte-Enable configurations.
* **`memory/roms/vrtl_rom.sv`**: Combinational and Synchronous ROMs with `$readmemh` hexadecimal memory file loading.
* **`memory/fifos/vrtl_fifo_sync.sv`**: Fixed 16x8 Sync FIFO, 2-Depth Register/Skid FIFO, Parameterized Sync FIFO with almost flags, Runtime Programmable Threshold FIFO, and FWFT mode wrapper.
* **`memory/fifos/vrtl_fifo_async.sv`**: Fixed 16x8 Async FIFO, Cummings Gray-Code Pointer Dual-Clock FIFO, and FWFT Async FIFO.

---

### 3.4 Stream & Interconnect (`VRTL/stream/` & `VRTL/interconnect/`)
* **`stream/vrtl_stream_slices.sv`**: 2-Register Skid Buffer (breaks ready/valid combinational delay), Forward Register Slice, and Backward Register Slice.
* **`stream/vrtl_stream_routing.sv`**: Stream Fork (1:2), Stream Mux (2:1), Stream Demux (1:2), and Stream Join (2:1).
* **`stream/vrtl_stream_width.sv`**: Stream Width Upsizer (packs narrow words) and Stream Width Downsizer (unpacks wide words).
* **`interconnect/arbiters/vrtl_arbiter_fixed.sv`**: Parallel Fixed-Priority Arbiters (4 clients, 8 clients, parametric).
* **`interconnect/arbiters/vrtl_arbiter_rr.sv`**: Rotating-Mask Fair Round-Robin Arbiters (4 clients, 8 clients, parametric).
* **`interconnect/arbiters/vrtl_arbiter_advanced.sv`**: LRU Matrix Arbiter (`vrtl_arbiter_matrix_4`) and Weighted Round-Robin Arbiter (`vrtl_arbiter_wrr_4`).
* **`interconnect/crossbar/vrtl_crossbar.sv`**: Non-blocking $2\times 2$ and $4\times 4$ Spatial Crossbar Switches.

---

### 3.5 Clock & CDC Domain (`VRTL/cdc/` & `VRTL/clock/`)
* **`cdc/vrtl_cdc_bit.sv`**: 2-Stage and 3-Stage Flop Synchronizers (`ASYNC_REG="TRUE"`), and Asynchronous Reset Bridge (`vrtl_reset_sync`).
* **`cdc/vrtl_cdc_pulse_handshake.sv`**: Cross-clock Toggle Pulse Synchronizer and 4-Phase Request-Acknowledge Handshake Synchronizer.
* **`cdc/vrtl_cdc_data.sv`**: Multi-bit Bus Synchronizer and Mux-Recirculation Data Bus Synchronizer (`vrtl_sync_mux_data`).
* **`cdc/vrtl_edge_detect.sv`**: Single-bit and Parameterized N-bit Pos/Neg/Any Edge Detectors.
* **`clock/vrtl_clock_gates.sv`**: Latch-based Integrated Clock Gating (ICG) cell and Glitch-Free Clock Switcher.
* **`clock/vrtl_clock_dividers.sv`**: Div-by-2, Div-by-4, Clock Enable Generator, Even Divider, Odd Divider (50% duty), Fractional Phase Accumulator, and Pulse Stretcher.

---

### 3.6 Combinational Logic Domain (`VRTL/logic/`)
* **`logic/mux/vrtl_mux.sv`**: 1-bit, 8-bit, 32-bit fixed muxes; 2:1, 4:1, 8:1 parametric; N:1 mux; One-Hot mux; Priority mux; Tree muxes.
* **`logic/decoders/vrtl_decoders.sv`**: 1:2, 2:4, 3:8, 4:16 (Active-High & Low); 74xx138 industrial decoder; 4:16 cascaded tree; 74xx42 BCD decoder; parametric decoders.
* **`logic/encoders/vrtl_encoders.sv`**: 4:2, 8:3 simple encoders; 4:2, 8:3, 16:4 priority encoders; 74xx148 priority encoder; 16:4 cascaded priority encoder; leading-one detector; parametric priority encoder.
* **`logic/comparators/vrtl_comparators.sv`**: 1b-32b magnitude comparators; 74xx85 cascadable comparator; signed/unsigned comparator; min/max selector; window comparator; parity generators.
* **`logic/shifters/vrtl_shifters.sv`**: 8b, 16b, 32b barrel shifters; cyclic rotators; parametric barrel shifter; logarithmic barrel shifter; funnel shifter.

---

### 3.7 Sequential Logic Domain (`VRTL/sequential/`)
* **`sequential/flip_flops/vrtl_flip_flops.sv`**: NOR/NAND SR latches; D-latch; DFF (basic, async reset, sync reset, clock enable, scan-chain testable, dual-edge); T-FF; JK-FF; N-bit DFFs.
* **`sequential/registers/vrtl_registers.sv`**: 8b, 16b, 32b fixed registers; parametric register with enable and sync clear; byte-enable register; shadow ping-pong register.
* **`sequential/registers/vrtl_shift_registers.sv`**: PISO 8-bit, SIPO 8-bit, SISO parametric delay line, Universal Shift Register.
* **`sequential/registers/vrtl_reg_file.sv`**: 2-Read 1-Write and 3-Read 2-Write Multiport Register Files.
* **`sequential/counters/vrtl_counters_binary.sv`**: 4-bit Ripple counter; 4b/8b/Parametric Binary Up counters; Up/Down counter; Loadable counter; Prescaled counter.
* **`sequential/counters/vrtl_counters_special.sv`**: Decade BCD counters (1, 2, 4 digits); Mod-N pulse counter; Gray code counter; Ring counters (basic & self-correcting); Johnson counters (basic & self-correcting).

---

### 3.8 Peripherals Domain (`VRTL/peripherals/`)
* **`peripherals/comms/vrtl_uart.sv`**: Complete 8N1 UART Transmitter and Receiver with midpoint sampling and framing error detection.
* **`peripherals/comms/vrtl_spi.sv`**: Full-duplex SPI Master (Modes 0, 1, 2, 3) and SPI Slave interface.
* **`peripherals/io/vrtl_debouncer.sv`**: Glitch-filtering push-button debouncer counter.
* **`peripherals/io/vrtl_pwm.sv`**: Parameterized PWM Generator.
* **`peripherals/io/vrtl_display_7seg.sv`**: Hex-to-7Seg decoder and Multi-digit Time-Multiplexed 7-Segment Display Controller.
* **`peripherals/io/vrtl_rotary_encoder.sv`**: Quadrature Rotary Encoder Decoder (Phase A/B, Step pulse, CW/CCW).

---

### 3.9 Security, Reliability & Codes Domain (`VRTL/security_ecc/`)
* **`security_ecc/ecc/vrtl_ecc_hamming.sv`**: Classic (7,4) Hamming code encoder/decoder; 8-bit SECDED (8b to 13b); 32-bit SECDED (32b to 39b).
* **`security_ecc/crc/vrtl_crc.sv`**: CRC-8 (SMBus `0x07`), CRC-16-CCITT (`0x1021`), Serial Parameterized CRC, and IEEE 802.3 Ethernet CRC-32 (`0x04C11DB7`).
* **`security_ecc/prng/vrtl_prng_lfsr.sv`**: 4b, 8b, 16b, 32b maximal-length LFSRs; PRBS-7, PRBS-15, PRBS-31 telecom patterns; Fibonacci and Galois parametric LFSRs.

---

### 3.10 Data Converters Domain (`VRTL/converters/`)
* **`converters/vrtl_converter_bcd.sv`**: Binary to BCD (8b, 16b, Parametric Double-Dabble) and BCD to Binary (2-digit 8b, 3-digit 12b, 4-digit 16b).
* **`converters/vrtl_converter_gray.sv`**: Binary to Gray and Gray to Binary converters (4b, 8b, Parametric).
* **`converters/vrtl_converter_thermometer.sv`**: Binary to Thermometer (4b to 15b) and Thermometer to Binary (15b to 4b).

---

## 4. Usage & Instantiation Templates

Every single module contains a copy-ready, commented-out instantiation template with single-line comments (`// `) placed directly above its definition, delimited by separator lines:

### 4.1 Kogge-Stone Parallel-Prefix Adder:
```verilog
// =============================================================================
// vrtl_kogge_stone_adder_16b u_vrtl_kogge_stone_adder_16b (
//     .a    (a),
//     .b    (b),
//     .cin  (cin),
//     .sum  (sum),
//     .cout (cout)
// );
// =============================================================================
```

### 4.2 Stream Skid Buffer:
```verilog
// =============================================================================
// vrtl_skid_buffer #(
//     .DATA_WIDTH (32)
// ) u_vrtl_skid_buffer (
//     .clk     (clk),
//     .rst_n   (rst_n),
//     .s_valid (s_valid),
//     .s_ready (s_ready),
//     .s_data  (s_data),
//     .m_valid (m_valid),
//     .m_ready (m_ready),
//     .m_data  (m_data)
// );
// =============================================================================
```

### 4.3 Dual-Clock Asynchronous FIFO:
```verilog
// =============================================================================
// vrtl_fifo_async #(
//     .DATA_WIDTH (32),
//     .DEPTH      (16)
// ) u_vrtl_fifo_async (
//     .wr_clk   (wr_clk),
//     .wr_rst_n (wr_rst_n),
//     .wr_en    (wr_en),
//     .wr_data  (wr_data),
//     .full     (full),
//     .rd_clk   (rd_clk),
//     .rd_rst_n (rd_rst_n),
//     .rd_en    (rd_en),
//     .rd_data  (rd_data),
//     .empty    (empty)
// );
// =============================================================================
```

### 4.4 Matrix LRU Arbiter (4-client):
```verilog
// =============================================================================
// vrtl_arbiter_matrix_4 u_vrtl_arbiter_matrix_4 (
//     .clk   (clk),
//     .rst_n (rst_n),
//     .req   (req),
//     .grant (grant)
// );
// =============================================================================
```

---

## 5. Integrating VRTL into Your Project

### Option A: Master Header Include
Include the entire catalog in a single statement from root or from `include/`:
```verilog
`include "VRTL/vrtl_catalog.sv"
// or directly:
`include "VRTL/include/vrtl_catalog.sv"
```

### Option B: Modular File Compilation
Add `+incdir+VRTL/include` to your EDA tool flags and reference the definitions:
```verilog
`include "vrtl_defines.svh"
import vrtl_pkg::*;
```
Or include directly with relative pathing (works with zero compiler flags):
```verilog
`include "VRTL/include/vrtl_defines.svh"
import vrtl_pkg::*;
```

---

## 6. Verification Status

The entire catalog has been compiled and validated using **QuestaSim vlog 2024.1** with the SystemVerilog switch enabled:
* **Total Hierarchical Files:** `63`
* **Total Compiled Modules:** `263`
* **Compiler Errors:** `0`
* **Compiler Warnings:** `0`
