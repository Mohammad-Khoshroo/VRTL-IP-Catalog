`ifndef VRTL_DEFINES_SVH
`define VRTL_DEFINES_SVH

// =============================================================================
// VRTL Assertion & Checker Macros (Simulation Checked, Ignored in Synthesis)
// =============================================================================

`ifndef SYNTHESIS
  // Immediate assertion
  `define VRTL_ASSERT(NAME, COND, MSG) \
    NAME: assert (COND) else $error("[VRTL ASSERTION FAILED][%m] %s", MSG)

  // Clocked concurrent assertion with active-low async reset
  `define VRTL_ASSERT_CLK(NAME, COND, CLK, RST_N, MSG) \
    NAME: assert property (@(posedge CLK) disable iff (!RST_N) (COND)) \
      else $error("[VRTL CLK ASSERTION FAILED][%m] %s", MSG)

  // Property that must never become true
  `define VRTL_ASSERT_NEVER(NAME, COND, CLK, RST_N, MSG) \
    NAME: assert property (@(posedge CLK) disable iff (!RST_N) !(COND)) \
      else $error("[VRTL ASSERT NEVER FAILED][%m] %s", MSG)

  // Checks one-hot property on clock
  `define VRTL_ASSERT_ONEHOT(NAME, SIG, CLK, RST_N, MSG) \
    NAME: assert property (@(posedge CLK) disable iff (!RST_N) $onehot(SIG)) \
      else $error("[VRTL ONEHOT FAILED][%m] %s", MSG)

  // Checks that signal is known (no X or Z) on active clock
  `define VRTL_ASSERT_KNOWN(NAME, SIG, CLK, RST_N, MSG) \
    NAME: assert property (@(posedge CLK) disable iff (!RST_N) !$isunknown(SIG)) \
      else $error("[VRTL UNKNOWN 'X/'Z DETECTED][%m] %s", MSG)
`else
  `define VRTL_ASSERT(NAME, COND, MSG)
  `define VRTL_ASSERT_CLK(NAME, COND, CLK, RST_N, MSG)
  `define VRTL_ASSERT_NEVER(NAME, COND, CLK, RST_N, MSG)
  `define VRTL_ASSERT_ONEHOT(NAME, SIG, CLK, RST_N, MSG)
  `define VRTL_ASSERT_KNOWN(NAME, SIG, CLK, RST_N, MSG)
`endif

`endif // VRTL_DEFINES_SVH
