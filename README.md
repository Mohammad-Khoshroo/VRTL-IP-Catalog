# VRTL — Standard SystemVerilog RTL IP Catalog

A comprehensive, production-grade, synthesis-ready IP catalog of conventional digital RTL building blocks implemented in **SystemVerilog**. The catalog contains **263 verified RTL modules** spanning basic gates up to advanced arithmetic architectures, digital signal processing blocks, bus arbiters, clock domain crossing (CDC) synchronizers, and communication interfaces.

Every single module features:
* A ready-to-copy, commented-out instantiation template placed directly above its definition.
* Clean, concise code without conversational comments or fluff.
* Both parametric (generic) and non-parametric (standard fixed-width / industry-standard) variants.
* Non-overdosing simulation assertion checks guarded by ``` `ifndef SYNTHESIS ``` for zero FPGA/ASIC area overhead.
* 100% verified compilation with **QuestaSim 2024.1** (`0 errors, 0 warnings`).

---

## 1. Directory Structure

```text
VRTL/
├── vrtl_defines.svh     # Simulation assertion macros and verification helpers
├── vrtl_pkg.sv          # SystemVerilog utility package (math & bit manipulation)
├── vrtl_catalog.sv      # Master include header linking all 24 catalog files
├── vrtl_mux.sv          # Multiplexers (2:1, 4:1, 8:1, tree, crossbar, priority, one-hot)
├── vrtl_decoder.sv      # Decoders (1:2, 2:4, 3:8, 4:16, 74xx138, cascaded tree, BCD)
├── vrtl_encoder.sv      # Encoders (4:2, 8:3, priority 4:2, 8:3, 16:4, 74xx148, LOD)
├── vrtl_arithmetic.sv   # Adders/Subtractors (4b-32b), CLA-16, 74xx181 ALU, 12-op ALU
├── vrtl_adders.sv       # Advanced adders: CSA, Carry-Skip, CSLA, Kogge-Stone, Brent-Kung, BCD
├── vrtl_multipliers.sv  # Multipliers: Shift-Add, Array, Baugh-Wooley, Wallace, Dadda, Booth, Pipe
├── vrtl_dividers.sv     # Dividers: Restoring, Non-Restoring, Combinational, Pipelined, Sqrt, CLZ
├── vrtl_dsp.sv          # DSP: Saturating Add/Sub, Abs, MAC, Complex Mult, Peak, FIR, CORDIC
├── vrtl_comparator.sv   # Comparators (1b-32b, 74xx85), Min/Max, Window, Parity Generators
├── vrtl_shifter.sv      # Barrel shifters (8b-32b, logarithmic), Funnel Shifter, Rotators
├── vrtl_dff.sv          # Latches (SR, D), Flip-Flops (Sync/Async reset, En, Dual-edge, Scan), T-FF, JK-FF
├── vrtl_register.sv     # Shift registers (PISO, SIPO, SISO, Universal), Byte-En, RegFiles (2R1W, 3R2W)
├── vrtl_counter.sv      # Counters: Ripple, Binary Up/Down, Mod-N, Decade, Gray, Ring, Johnson
├── vrtl_synchronizer.sv # CDC: 2-Stage, 3-Stage, Reset Bridge, Handshake, Bus Sync, Mux Data Sync
├── vrtl_memory.sv       # RAMs (SP, DP, TDP, Byte-En, LUT-RAM) and ROMs (Sync, Combinational)
├── vrtl_fifo.sv         # Synchronous FIFOs (Fixed 16x8, Param, FWFT, 2-Depth Skid, Programmable)
├── vrtl_fifo_async.sv   # Dual-Clock Asynchronous FIFOs (Cummings Gray-Code, FWFT, Fixed 16x8)
├── vrtl_stream.sv       # Ready-Valid Slices (Skid, Forward, Backward), Fork, Mux, Demux, Join, Upsizer
├── vrtl_arbiter.sv      # Arbiters: Fixed Priority, Round-Robin, LRU Matrix, Weighted Round-Robin
├── vrtl_clock_util.sv   # Clock Gates (ICG), Glitch-Free Mux, Even/Odd/Frac Dividers, Enable Gen
├── vrtl_peripherals.sv  # Debouncer, PWM Gen, 7-Seg Display Controller, UART TX/RX, SPI Master/Slave, QDEC
├── vrtl_ecc_crc.sv      # Hamming (7,4), SECDED (8b, 32b), CRC-8, CRC-16-CCITT, CRC-32
├── vrtl_lfsr.sv         # LFSRs (4b-32b, Galois, Fibonacci), PRBS-7, PRBS-15, PRBS-31
├── vrtl_converters.sv   # Double-Dabble Binary<->BCD, Binary<->Gray, Thermometer<->Binary
└── README.md            # Technical documentation and module index
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

### Assertion Macros:
* `` `VRTL_ASSERT(NAME, COND, MSG) ``: Immediate assertion check.
* `` `VRTL_ASSERT_CLK(NAME, COND, CLK, RST_N, MSG) ``: Clocked concurrent assertion with active-low async reset disable.
* `` `VRTL_ASSERT_NEVER(NAME, COND, CLK, RST_N, MSG) ``: Asserts that an illegal condition never occurs (e.g., overflow/underflow).
* `` `VRTL_ASSERT_ONEHOT(NAME, SIG, CLK, RST_N, MSG) ``: Asserts one-hot exclusivity on a control bus.
* `` `VRTL_ASSERT_KNOWN(NAME, SIG, CLK, RST_N, MSG) ``: Detects illegal `'X` or `'Z` states during active clock cycles.

*(Guarded by `` `ifndef SYNTHESIS `` and completely stripped out during synthesis).*

---

## 3. Module Index

### 3.1 Multiplexers (`vrtl_mux.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_mux2` / `_mux4` / `_mux8` | Parametric | `WIDTH=8` | 2:1, 4:1, and 8:1 Parameterized Multiplexers |
| `vrtl_mux_n` | Parametric | `WIDTH=8`, `N_INPUTS=4` | General N-to-1 Multiplexer |
| `vrtl_mux_onehot` | Parametric | `WIDTH=8`, `N_INPUTS=4` | One-Hot Select Multiplexer |
| `vrtl_priority_mux` | Parametric | `WIDTH=8`, `N_INPUTS=4` | Priority-based Multiplexer |
| `vrtl_mux4_tree` / `_mux8_tree` | Parametric | `WIDTH=8` | Logarithmic Tree-Structured Multiplexers |
| `vrtl_crossbar_2x2` / `_4x4` | Parametric | `WIDTH=8` | Non-blocking $2\times 2$ and $4\times 4$ Crossbar Switches |
| `vrtl_mux2_1b` / `_4_1b` / `_8_1b` | Fixed | 1-bit | 1-bit Multiplexers (Logic-gate level) |
| `vrtl_mux2_8b` / `_4_8b` / `_8_8b` | Fixed | 8-bit | 8-bit Byte Multiplexers |
| `vrtl_mux2_32b` | Fixed | 32-bit | 32-bit Data-path Multiplexer |

### 3.2 Decoders (`vrtl_decoder.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_decoder` / `_decoder_low` | Parametric | `INPUT_WIDTH=3` | N-to-$2^N$ Active-High and Active-Low Decoders |
| `vrtl_decoder_1to2` / `_2to4` / `_3to8` / `_4to16` | Fixed | Active-High | Standard 1:2, 2:4, 3:8, and 4:16 Decoders |
| `vrtl_decoder_2to4_low` / `_3to8_low` | Fixed | Active-Low | Active-Low 2:4 and 3:8 Decoders |
| `vrtl_decoder_3to8_74xx138` | Fixed | 3:8 with 3 enables | Industry-standard 74xx138 Decoder |
| `vrtl_decoder_4to16_tree` | Fixed | 4:16 Cascaded Tree | 4:16 Hierarchical Decoder using five 2:4 decoders |
| `vrtl_bcd_to_decimal_decoder` | Fixed | 4-bit to 10-line | Standard 74xx42 BCD-to-Decimal Decoder |

### 3.3 Encoders (`vrtl_encoder.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_priority_encoder` | Parametric | `WIDTH=8`, `HIGHEST_FIRST=1` | Priority Encoder with selectable MSB/LSB priority |
| `vrtl_encoder` | Parametric | `WIDTH=8` | One-Hot to Binary Encoder with `valid` flag |
| `vrtl_leading_one_detector` | Parametric | `WIDTH=16` | Leading-One Detector (One-hot mask output) |
| `vrtl_priority_encoder_4to2` / `_8to3` / `_16to4` | Fixed | — | Standard 4:2, 8:3, and 16:4 Priority Encoders |
| `vrtl_priority_encoder_8to3_74xx148` | Fixed | Active-Low | Standard 74xx148 8:3 Priority Encoder |
| `vrtl_priority_encoder_16to4_cascaded` | Fixed | Cascaded 16:4 | Hierarchical 16:4 Priority Encoder |
| `vrtl_encoder_4to2` / `_8to3` | Fixed | Simple | 4:2 and 8:3 Simple Encoders |

### 3.4 Basic Arithmetic & ALU (`vrtl_arithmetic.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_half_adder` / `vrtl_full_adder` | Fixed | 1-bit | Primitive Half Adder and Full Adder cells |
| `vrtl_adder_4b` / `_8b` / `_16b` / `_32b` | Fixed | 4b, 8b, 16b, 32b | Ripple-Carry Adders with Carry In/Out |
| `vrtl_subtractor_4b` / `_8b` / `_16b` | Fixed | 4b, 8b, 16b | Dedicated Subtractors with Borrow In/Out |
| `vrtl_cla_16b` | Fixed | 16-bit | 16-bit Carry-Lookahead Adder with Generate/Propagate |
| `vrtl_alu_74xx181` | Fixed | 4-bit | Classic 74xx181 4-bit Multifunction ALU |
| `vrtl_adder` / `vrtl_subtractor` | Parametric | `WIDTH=16` | Parameterized Adder / Subtractor with status flags |
| `vrtl_adder_subtractor` | Parametric | `WIDTH=16` | Combined Adder/Subtractor selectable via `sub` |
| `vrtl_multiplier` | Parametric | `WIDTH_A=8`, `WIDTH_B=8` | Behavioral Multiplier (Signed/Unsigned) |
| `vrtl_alu` | Parametric | `WIDTH=32` | 12-Operation ALU with Zero, Negative, Carry, and Overflow |

### 3.5 Advanced Adders (`vrtl_adders.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_csa_3to2` / `_4to2` / `_5to2` | Fixed | 1-bit | Carry-Save Adder slices (3:2, 4:2, 5:2 Compressors) |
| `vrtl_csa_8b` / `_16b` / `vrtl_csa` | Fixed / Param | 8b, 16b, Param | Multi-operand Carry-Save Adders |
| `vrtl_serial_adder` | Fixed | Bit-Serial | Bit-serial sequential adder with single DFF carry state |
| `vrtl_cba_block_4b` | Fixed | 4-bit | Carry-Bypass / Carry-Skip block with propagate gate |
| `vrtl_carry_skip_adder_16b` / `_32b` | Fixed | 16b / 32b | 16-bit and 32-bit Carry-Skip (Bypass) Adders |
| `vrtl_csla_block_4b` | Fixed | 4-bit | Carry-Select block with speculative Cin=0/Cin=1 |
| `vrtl_carry_select_adder_16b` / `_32b` | Fixed | 16b / 32b | Fixed-block Carry-Select Adders |
| `vrtl_carry_select_adder_sqrt_16b` | Fixed | 16b (2-3-4-7) | Variable-size Square-Root Carry-Select Adder |
| `vrtl_kogge_stone_adder_8b` / `_16b` | Fixed | 8b / 16b | Kogge-Stone Parallel-Prefix Adders (minimum logic depth) |
| `vrtl_brent_kung_adder_8b` / `_16b` | Fixed | 8b / 16b | Brent-Kung Parallel-Prefix Adders (area/routing optimized) |
| `vrtl_sklansky_adder_8b` | Fixed | 8-bit | Sklansky (Divide-and-Conquer) Parallel-Prefix Adder |
| `vrtl_han_carlson_adder_16b` | Fixed | 16-bit | Han-Carlson Hybrid Parallel-Prefix Adder |
| `vrtl_bcd_adder_1digit` / `_4digit` | Fixed | 1-digit / 4-digit | Decimal BCD Adders with +6 correction logic |

### 3.6 Multipliers (`vrtl_multipliers.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_multiplier_shift_add` | Parametric | `WIDTH=8` | Sequential Shift-and-Add Multiplier |
| `vrtl_array_multiplier_4x4` / `_8x8` | Fixed | 4x4 / 8x8 | Combinational Array Multipliers |
| `vrtl_array_multiplier` | Parametric | `WIDTH_A=8`, `WIDTH_B=8` | Parameterized Combinational Array Multiplier |
| `vrtl_baugh_wooley_mult_4x4` / `_8x8` | Fixed | 4x4 / 8x8 | Baugh-Wooley Signed Two's Complement Multipliers |
| `vrtl_wallace_tree_mult_4x4` / `_8x8` | Fixed | 4x4 / 8x8 | Wallace Tree Multipliers with multi-layer CSA reduction |
| `vrtl_dadda_mult_4x4` / `_8x8` | Fixed | 4x4 / 8x8 | Dadda Tree Multipliers (minimum compressor count) |
| `vrtl_booth_radix2_mult_8x8` | Fixed | 8x8 | Radix-2 Booth Multiplier |
| `vrtl_booth_radix4_mult_8x8` / `_16x16` | Fixed | 8x8 / 16x16 | Radix-4 Modified Booth Multipliers (50% fewer partial products) |
| `vrtl_multiplier_pipelined_8x8` | Fixed | 8x8 (3 Stages) | Fully pipelined high-throughput Multiplier |

### 3.7 Dividers, Square Root & CLZ (`vrtl_dividers.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_divider_restoring` | Parametric | `WIDTH=32` | Sequential Restoring Divider with busy/done/div_by_zero |
| `vrtl_divider_non_restoring` | Parametric | `WIDTH=32` | Sequential Non-Restoring Divider |
| `vrtl_divider_comb_4b` / `_comb_8b` | Fixed | 4b / 8b | Combinational Array Dividers |
| `vrtl_divider_pipelined_8b` | Fixed | 8-bit (8 Stages) | Pipelined Divider with 1 result per clock cycle |
| `vrtl_sqrt_restoring` | Parametric | `WIDTH=32` | Sequential Integer Square Root ($\lfloor \sqrt{x} \rfloor$ & remainder) |
| `vrtl_clz_32b` / `vrtl_clz` | Fixed / Param | `WIDTH=32` | Count Leading Zeros for floating-point normalization |

### 3.8 DSP & Signal Conditioning (`vrtl_dsp.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_saturating_adder` | Parametric | `WIDTH=16`, `SIGNED=1` | Signed/Unsigned Adder with saturation clipping |
| `vrtl_saturating_subtractor` | Parametric | `WIDTH=16`, `SIGNED=1` | Signed/Unsigned Subtractor with saturation clipping |
| `vrtl_dsp_abs` | Parametric | `WIDTH=16` | Signed absolute value calculator with overflow saturation |
| `vrtl_mac` | Parametric | `A_WIDTH=16`, `ACC_WIDTH=40` | Multiply-Accumulate unit with synchronous clear/enable |
| `vrtl_complex_mult` | Parametric | `WIDTH=16` | Complex Multiplier: $(a+jb)(c+jd) = (ac-bd) + j(ad+bc)$ |
| `vrtl_peak_detector` | Parametric | `WIDTH=16`, `SIGNED=1` | Dynamic min/max peak tracker with clear control |
| `vrtl_moving_average_filter` | Parametric | `DATA_WIDTH=16`, `WINDOW=8`| Power-of-2 moving window boxcar averaging filter |
| `vrtl_fir_filter_4tap` | Parametric | `DATA_W=16`, `COEFF_W=16` | 4-Tap Direct-Form FIR filter with signed coefficients |
| `vrtl_cordic_rotator` | Parametric | `WIDTH=16`, `ITERATIONS=16`| Iterative CORDIC core for vector rotation (sin/cos/angle) |

### 3.9 Comparators & Parity (`vrtl_comparator.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_comparator_1b` / `_4b` / `_8b` / `_16b` / `_32b` | Fixed | 1b to 32b | Unsigned Magnitude Comparators (`eq`, `gt`, `lt`) |
| `vrtl_comparator_4b_74xx85` | Fixed | 4-bit with cascade | Industry-standard 74xx85 Cascadable Magnitude Comparator |
| `vrtl_comparator` | Parametric | `WIDTH=16`, `SIGNED=0` | Signed/Unsigned Parameterized Comparator |
| `vrtl_min_max_selector` | Parametric | `WIDTH=16`, `SIGNED=1` | Combinational Min/Max Value Selector |
| `vrtl_window_comparator` | Parametric | `WIDTH=16` | Window / Range Comparator (`in_window = lo <= in <= hi`) |
| `vrtl_parity_gen_8b` / `vrtl_parity_gen` | Fixed / Param | `WIDTH=16` | Even and Odd Parity Generator / Checker |

### 3.10 Shifters & Rotators (`vrtl_shifter.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_barrel_shifter_8b` / `_16b` / `_32b` | Fixed | 8b, 16b, 32b | Logical and Arithmetic Barrel Shifter |
| `vrtl_rotator_8b` / `vrtl_rotator` | Fixed / Param | `WIDTH=32` | Cyclic Data Rotator (Left/Right) |
| `vrtl_barrel_shifter` | Parametric | `WIDTH=32` | Parameterized Barrel Shifter |
| `vrtl_barrel_shifter_logarithmic` | Parametric | `WIDTH=32` | $\log_2(W)$-stage Logarithmic Barrel Shifter |
| `vrtl_funnel_shifter` | Parametric | `WIDTH=32` | Double-word Funnel Shifter |

### 3.11 Flip-Flops & Latches (`vrtl_dff.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_sr_latch_nor` / `_nand` | Fixed | 1-bit | Basic NOR- and NAND-based SR Latches |
| `vrtl_d_latch` | Fixed | 1-bit | Transparent Level-Sensitive D-Latch |
| `vrtl_dff` / `_ar` / `_sr` / `_en` | Fixed | 1-bit | Basic DFF, Async Reset, Sync Reset, Clock Enable |
| `vrtl_dff_scan` | Fixed | 1-bit | DFF with Scan-chain test multiplexer |
| `vrtl_dff_dual_edge` | Fixed | 1-bit | Dual-Edge Triggered Flip-Flop |
| `vrtl_tff` / `vrtl_jkff` | Fixed | 1-bit | Toggle Flip-Flop and JK Flip-Flop |
| `vrtl_dff_n` / `vrtl_dff_sync_n` | Parametric | `WIDTH=8` | N-bit Register with Async / Sync Reset |

### 3.12 Registers & Register Files (`vrtl_register.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_reg_8b` / `_16b` / `_32b` | Fixed | 8b, 16b, 32b | Fixed-width Registers with Enable and Sync Clear |
| `vrtl_reg` | Parametric | `WIDTH=32` | Parameterized Register with Enable and Sync Clear |
| `vrtl_reg_byte_en` | Parametric | `BYTES=4` | Register with individual Byte-Write Enables |
| `vrtl_reg_shadow` | Parametric | `WIDTH=32` | Shadow Register (Active and Shadow buffer swapping) |
| `vrtl_shift_reg_piso_8b` / `_sipo_8b` | Fixed | 8-bit | Parallel-In Serial-Out and Serial-In Parallel-Out registers |
| `vrtl_shift_reg_siso` | Parametric | `DEPTH=8` | Parameterized Serial-In Serial-Out delay line |
| `vrtl_shift_reg_universal` | Parametric | `WIDTH=8` | Universal Shift Register (Hold, Shift-R, Shift-L, Load) |
| `vrtl_reg_file` | Parametric | `DATA_W=32`, `DEPTH=32` | 2-Read 1-Write Register File (with hardwired zero $R0$) |
| `vrtl_reg_file_3r2w` | Parametric | `DATA_W=32`, `DEPTH=32` | Multi-port 3-Read 2-Write Register File |

### 3.13 Counters (`vrtl_counter.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_counter_async_ripple_4b` | Fixed | 4-bit | Asynchronous Ripple Counter |
| `vrtl_counter_4b_up` / `_8b_up` | Fixed | 4b / 8b | Synchronous Binary Up Counters |
| `vrtl_decade_counter` | Fixed | 4-bit | Single-digit BCD Decade Counter (0-9) |
| `vrtl_counter_decade_2digit` / `_4digit` | Fixed | 2-digit / 4-digit | Cascaded Multi-Digit BCD Decade Counters |
| `vrtl_counter_up` / `_down` / `_up_down`| Parametric | `WIDTH=8` | Synchronous Up, Down, and Up/Down Counters |
| `vrtl_counter_load` | Parametric | `WIDTH=8` | Synchronous Counter with Parallel Load |
| `vrtl_counter_mod_n` | Parametric | `MOD_VALUE=100` | Modulo-N Counter with periodic tick pulse |
| `vrtl_gray_counter` | Parametric | `WIDTH=4` | Glitch-free Gray Code Counter |
| `vrtl_ring_counter` / `_self_correcting`| Parametric | `WIDTH=4` | Basic and Self-Correcting Ring Counters |
| `vrtl_johnson_counter` / `_self_correcting`| Parametric | `WIDTH=4` | Basic and Self-Correcting Johnson Counters |
| `vrtl_counter_prescaled` | Parametric | `PRESCALE=100`, `CNT_W=8`| Prescaled Counter with configurable clock divider tick |

### 3.14 Synchronizers & CDC (`vrtl_synchronizer.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_edge_detect` / `_n` | Fixed / Param | `WIDTH=8` | Positive, Negative, and Any-edge detector |
| `vrtl_sync_2stage` / `_3stage` | Fixed | 1-bit | 2-Stage and 3-Stage CDC Synchronizers (`ASYNC_REG="TRUE"`) |
| `vrtl_reset_sync` | Fixed | — | Asynchronous assert, synchronous deassert reset bridge |
| `vrtl_sync_handshake` | Fixed | 4-Phase | Request-Acknowledge CDC Handshake Synchronizer |
| `vrtl_sync_bus` | Parametric | `WIDTH=8`, `STAGES=2` | Multi-stage multi-bit Synchronizer |
| `vrtl_pulse_sync` | Parametric | — | Cross-clock-domain toggle-handshake pulse synchronizer |
| `vrtl_sync_mux_data` | Parametric | `WIDTH=32` | Mux-recirculation CDC Data Bus Synchronizer |

### 3.15 Memories & BRAMs (`vrtl_memory.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_ram_sp_256x8` | Fixed | 256x8 | 256x8 Synchronous Single-Port RAM |
| `vrtl_rom_async_256x8` | Fixed | 256x8 | 256x8 Combinational Asynchronous ROM |
| `vrtl_ram_sp_sync` | Parametric | `DATA_W=32`, `ADDR_W=8` | BRAM-inferrable Synchronous Single-Port RAM |
| `vrtl_ram_sp_byte_en` | Parametric | `BYTES=4`, `ADDR_W=8` | Single-Port RAM with Byte-Write Enables |
| `vrtl_ram_dp_sync` | Parametric | `DATA_W=32`, `ADDR_W=8` | Simple Dual-Port RAM (Port A: Write, Port B: Read) |
| `vrtl_ram_tdp_sync` | Parametric | `DATA_W=32`, `ADDR_W=8` | True Dual-Port RAM (Port A: R/W, Port B: R/W) |
| `vrtl_ram_tdp_byte_en` | Parametric | `BYTES=4`, `ADDR_W=8` | True Dual-Port RAM with Byte-Write Enables |
| `vrtl_ram_async_read` | Parametric | `DATA_W=32`, `ADDR_W=6` | Distributed LUT-RAM (Sync write, Combinational read) |
| `vrtl_rom_sync` | Parametric | `DATA_W=32`, `ADDR_W=8` | Synchronous ROM with `$readmemh` initialization |
| `vrtl_rom_async` | Parametric | `DATA_W=32`, `ADDR_W=8` | Combinational ROM with `$readmemh` initialization |

### 3.16 FIFOs (`vrtl_fifo.sv`, `vrtl_fifo_async.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_fifo_sync_16x8` | Fixed | 16 entries $\times$ 8b | Non-parametric Synchronous FIFO |
| `vrtl_fifo_reg_2depth` | Parametric | `DATA_WIDTH=32` | 2-Depth Register / Skid FIFO (0 BRAM, zero latency) |
| `vrtl_fifo_sync` | Parametric | `DATA_W=32`, `DEPTH=16` | Synchronous FIFO with almost full/empty thresholds and count |
| `vrtl_fifo_sync_prog` | Parametric | `DATA_W=32`, `DEPTH=16` | Synchronous FIFO with runtime programmable thresholds |
| `vrtl_fifo_sync_fwft` | Parametric | `DATA_W=32`, `DEPTH=16` | First-Word Fall-Through (FWFT) synchronous FIFO wrapper |
| `vrtl_fifo_async_16x8` | Fixed | 16 entries $\times$ 8b | Non-parametric Dual-Clock Asynchronous FIFO |
| `vrtl_fifo_async` | Parametric | `DATA_W=32`, `DEPTH=16` | Dual-clock FIFO using Cummings Gray-code pointers |
| `vrtl_fifo_async_fwft` | Parametric | `DATA_W=32`, `DEPTH=16` | Dual-clock FIFO with First-Word Fall-Through (FWFT) mode |

### 3.17 Stream Pipelines & Register Slices (`vrtl_stream.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_skid_buffer` | Parametric | `DATA_WIDTH=32` | 2-Register Skid Buffer (breaks ready/valid combinational paths) |
| `vrtl_reg_slice_forward` | Parametric | `DATA_WIDTH=32` | Forward Register Slice (registers `valid` and `data`) |
| `vrtl_reg_slice_backward` | Parametric | `DATA_WIDTH=32` | Backward Register Slice (registers `ready`) |
| `vrtl_stream_fork_1to2` | Parametric | `DATA_WIDTH=32` | Synchronized Stream Fork (1 input to 2 independent outputs) |
| `vrtl_stream_mux_2to1` | Parametric | `DATA_WIDTH=32` | Stream Multiplexer (2 inputs to 1 output) |
| `vrtl_stream_demux_1to2` | Parametric | `DATA_WIDTH=32` | Stream Demultiplexer (1 input routed to 1 of 2 outputs) |
| `vrtl_stream_join_2to1` | Parametric | `DATA_A_W=16`, `DATA_B_W=16`| Stream Joiner (merges 2 independent streams with handshake) |
| `vrtl_stream_width_upsizer` | Parametric | `IN_W=8`, `RATIO=4` | Stream Width Upsizer (packs $R$ narrow words into 1 wide word) |
| `vrtl_stream_width_downsizer` | Parametric | `OUT_W=8`, `RATIO=4` | Stream Width Downsizer (unpacks 1 wide word into $R$ narrow words) |

### 3.18 Bus Arbiters (`vrtl_arbiter.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_arbiter_fixed_4` / `_8` | Fixed | 4 clients / 8 clients | Parallel Fixed-Priority Arbiters |
| `vrtl_arbiter_fixed` | Parametric | `CLIENTS=4` | Parameterized High-Speed Fixed-Priority Arbiter |
| `vrtl_arbiter_round_robin_4` / `_8` | Fixed | 4 clients / 8 clients | Dedicated 4- and 8-client Round-Robin Arbiters |
| `vrtl_arbiter_round_robin` | Parametric | `CLIENTS=4` | Starvation-free fair Round-Robin Arbiter with rotating mask |
| `vrtl_arbiter_matrix_4` | Fixed | 4 clients | LRU Matrix Arbiter using triangular priority state matrix |
| `vrtl_arbiter_wrr_4` | Fixed | 4 clients | Weighted Round-Robin (WRR) Arbiter with credit weights |

### 3.19 Clock Utilities (`vrtl_clock_util.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_clock_divider_by2` / `_by4` | Fixed | — | Dedicated Divide-by-2 and Divide-by-4 circuits |
| `vrtl_clock_gate` | Fixed | — | Standard latch-based Integrated Clock Gating (ICG) cell |
| `vrtl_glitch_free_clock_mux` | Fixed | — | Glitch-free clock switcher between 2 asynchronous clocks |
| `vrtl_clock_enable_gen` | Parametric | `PERIOD_CYCLES=100` | Synchronous Clock Enable generator (avoids ripple clocks) |
| `vrtl_clock_divider_even` | Parametric | `DIV_BY=4` | Even integer clock divider with 50% duty cycle |
| `vrtl_clock_divider_odd` | Parametric | `DIV_BY=5` | Odd integer clock divider with 50% duty cycle (dual edge) |
| `vrtl_clock_divider_frac` | Parametric | `ACC_W=16` | Fractional Clock Divider / Phase Accumulator |
| `vrtl_pulse_stretcher` | Parametric | `STRETCH_CYCLES=4` | Stretches a single-cycle pulse into $N$ clock cycles |

### 3.20 Peripherals & Board IO (`vrtl_peripherals.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_debouncer` | Parametric | `DEBOUNCE_CYCLES=100000`| Push-button debouncer with glitch filter counter |
| `vrtl_pwm_gen` | Parametric | `WIDTH=8` | Pulse-Width Modulation (PWM) generator |
| `vrtl_hex_to_7seg` | Fixed | 4-bit | 4-bit hexadecimal to 7-segment display decoder (active-low) |
| `vrtl_seven_seg_controller` | Parametric | `DIGITS=4`, `INTERVAL=50000`| Multi-digit time-multiplexed 7-segment display driver |
| `vrtl_uart_tx` | Parametric | `CLKS_PER_BIT=868` | UART Transmitter (8 data bits, 1 stop bit, busy/done) |
| `vrtl_uart_rx` | Parametric | `CLKS_PER_BIT=868` | UART Receiver with midpoint sampling and error check |
| `vrtl_spi_master` | Parametric | `DATA_W=8`, `CPOL=0`, `CPHA=0`| Full-duplex SPI Master controller (Modes 0, 1, 2, 3) |
| `vrtl_spi_slave` | Parametric | `DATA_W=8` | Standard SPI Slave interface with shift register |
| `vrtl_rotary_encoder_decoder` | Fixed | Phase A & Phase B | Quadrature Rotary Encoder Decoder (step pulse & direction) |

### 3.21 Error Detection & Correction (`vrtl_ecc_crc.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_hamming_enc_4b` / `_dec_4b` | Fixed | (7,4) Code | Classic (7,4) Hamming Single Error Correcting code |
| `vrtl_hamming_enc_8b` / `_dec_8b` | Fixed | (13,8) SECDED | 8-bit Single Error Correction, Double Error Detection |
| `vrtl_hamming_enc_32b` / `_dec_32b`| Fixed | (39,32) SECDED | 32-bit Single Error Correction, Double Error Detection |
| `vrtl_crc8` | Fixed | 8-bit (SMBus `0x07`)| Byte-wide parallel CRC-8 Generator |
| `vrtl_crc16_ccitt` | Fixed | 16-bit (`0x1021`) | Byte-wide parallel CRC-16-CCITT Generator |
| `vrtl_crc` | Parametric | `CRC_W=16`, `POLY=16'h1021` | Parameterized polynomial serial bit-by-bit CRC Generator |
| `vrtl_crc32` | Fixed | 32-bit (`0x04C11DB7`)| Standard IEEE 802.3 Ethernet byte-parallel CRC-32 Generator |

### 3.22 PRNG & LFSR (`vrtl_lfsr.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_lfsr_4b` | Fixed | 4-bit | Minimal 4-bit LFSR ($x^4 + x^3 + 1$, period 15) |
| `vrtl_lfsr_8b` / `_16b` / `_32b` | Fixed | 8b, 16b, 32b | Maximal-length Galois PRNG generators |
| `vrtl_prbs7` | Fixed | 7-bit ($x^7+x^6+1$) | Telecom PRBS-7 generator (ITU-T O.150) |
| `vrtl_prbs15` | Fixed | 15-bit ($x^{15}+x^{14}+1$) | Telecom PRBS-15 generator |
| `vrtl_prbs31` | Fixed | 31-bit ($x^{31}+x^{28}+1$) | Telecom PRBS-31 generator |
| `vrtl_lfsr_fibonacci` | Parametric | `WIDTH=8`, `TAPS=8'hB8` | Parameterized Fibonacci LFSR PRNG |
| `vrtl_lfsr_galois` | Parametric | `WIDTH=8`, `POLY=8'hB8` | Parameterized Galois LFSR PRNG |

### 3.23 Data Converters (`vrtl_converters.sv`)
| Module Name | Type | Width / Parameters | Description |
| :--- | :--- | :--- | :--- |
| `vrtl_bin_to_bcd_8b` / `_16b` | Fixed | 8b / 16b to BCD | Binary to BCD via Double-Dabble algorithm |
| `vrtl_bin_to_bcd` | Parametric | `BIN_W=8`, `DIGITS=3` | Parameterized Binary to BCD Converter |
| `vrtl_bcd_to_bin_8b` / `_12b` / `_16b`| Fixed | 2, 3, and 4 digits | BCD to Binary converters |
| `vrtl_bin_to_gray_4b` / `_8b` / `vrtl_bin_to_gray`| Fixed / Param | `WIDTH=8` | Binary to Gray Code Converters |
| `vrtl_gray_to_bin_4b` / `_8b` / `vrtl_gray_to_bin`| Fixed / Param | `WIDTH=8` | Gray Code to Binary Converters |
| `vrtl_bin_to_thermometer_4b` | Fixed | 4b to 15b | Binary to Thermometer Code Converter |
| `vrtl_thermometer_to_bin_15b` | Fixed | 15b to 4b | Thermometer Code to Binary Converter |

---

## 4. Usage & Instantiation Examples

Every module includes a ready-to-copy, commented-out instantiation template placed directly above its definition in the source file.

### 4.1 Multiply-Accumulate (MAC Unit):
```verilog
vrtl_mac #(
    .A_WIDTH(16),
    .B_WIDTH(16),
    .ACC_WIDTH(40)
) u_dsp_mac (
    .clk     (clk),
    .rst_n   (rst_n),
    .clr     (mac_clear),
    .en      (mac_enable),
    .a       (sample_a),
    .b       (sample_b),
    .acc_out (accumulated_result)
);
```

### 4.2 Stream Skid Buffer:
```verilog
vrtl_skid_buffer #(
    .DATA_WIDTH(32)
) u_skid_buf (
    .clk     (clk),
    .rst_n   (rst_n),
    .s_valid (s_axis_valid),
    .s_ready (s_axis_ready),
    .s_data  (s_axis_data),
    .m_valid (m_axis_valid),
    .m_ready (m_axis_ready),
    .m_data  (m_axis_data)
);
```

### 4.3 Dual-Clock Asynchronous FIFO:
```verilog
vrtl_fifo_async #(
    .DATA_WIDTH(32),
    .DEPTH(16)
) u_async_fifo (
    .wr_clk    (tx_clk),
    .wr_rst_n  (tx_rst_n),
    .wr_en     (tx_wr_en),
    .wr_data   (tx_data),
    .full      (tx_full),
    .rd_clk    (rx_clk),
    .rd_rst_n  (rx_rst_n),
    .rd_en     (rx_rd_en),
    .rd_data   (rx_data),
    .empty     (rx_empty)
);
```

### 4.4 Matrix LRU Arbiter (4-client):
```verilog
vrtl_arbiter_matrix_4 u_lru_arbiter (
    .clk   (clk),
    .rst_n (rst_n),
    .req   (bus_requests),
    .grant (bus_grants)
);
```

---

## 5. Integrating VRTL into Your Project

### Option A: Master Header Include
Include the entire catalog in a single statement:
```verilog
`include "vrtl_catalog.sv"
```

### Option B: Modular File Compilation
Add the necessary source files directly to your simulation/synthesis filelist:
```verilog
`include "vrtl_defines.svh"
import vrtl_pkg::*;
```

---

## 6. Verification Status

The entire catalog has been compiled and validated using **QuestaSim vlog 2024.1** with the SystemVerilog switch:
* **Total Modules:** `263`
* **Errors:** `0`
* **Warnings:** `0`
