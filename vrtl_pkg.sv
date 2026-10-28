`ifndef VRTL_PKG_SV
`define VRTL_PKG_SV

`include "vrtl_defines.svh"

// =============================================================================
// VRTL Package: Utility Functions
// =============================================================================

package vrtl_pkg;

  // Ceiling log base 2 (returns at least 1 for 0 and 1)
  function automatic integer clog2(input integer val);
    integer result;
    begin
      result = 0;
      val = val - 1;
      while (val > 0) begin
        result = result + 1;
        val = val >> 1;
      end
      clog2 = (result == 0) ? 1 : result;
    end
  endfunction

  // Checks whether a value is an exact power of 2
  function automatic logic is_pow2(input integer val);
    begin
      is_pow2 = (val > 0) && ((val & (val - 1)) == 0);
    end
  endfunction

  // Counts number of set bits (population count)
  function automatic integer count_ones(input logic [31:0] val);
    integer i, cnt;
    begin
      cnt = 0;
      for (i = 0; i < 32; i = i + 1) begin
        if (val[i]) cnt = cnt + 1;
      end
      count_ones = cnt;
    end
  endfunction

  // Checks if exactly one bit is active high
  function automatic logic is_onehot(input logic [31:0] val);
    begin
      is_onehot = (val != 0) && ((val & (val - 1)) == 0);
    end
  endfunction

  // Checks if at most one bit is active high (zero or one-hot)
  function automatic logic is_onehot0(input logic [31:0] val);
    begin
      is_onehot0 = (val & (val - 1)) == 0;
    end
  endfunction

  // Converts binary code to standard Gray code
  function automatic logic [31:0] bin2gray(input logic [31:0] bin);
    begin
      bin2gray = bin ^ (bin >> 1);
    end
  endfunction

  // Converts Gray code back to binary code
  function automatic logic [31:0] gray2bin(input logic [31:0] gray);
    integer i;
    logic [31:0] bin;
    begin
      bin = gray;
      for (i = 1; i < 32; i = i << 1) begin
        bin = bin ^ (bin >> i);
      end
      gray2bin = bin;
    end
  endfunction

  // Reverses bit order of an N-bit vector
  function automatic logic [31:0] reverse_bits(input logic [31:0] val, input integer width);
    integer i;
    logic [31:0] rev;
    begin
      rev = 32'b0;
      for (i = 0; i < width; i = i + 1) begin
        rev[i] = val[width - 1 - i];
      end
      reverse_bits = rev;
    end
  endfunction

  // Returns maximum of two integers
  function automatic integer max_val(input integer a, input integer b);
    begin
      max_val = (a > b) ? a : b;
    end
  endfunction

  // Returns minimum of two integers
  function automatic integer min_val(input integer a, input integer b);
    begin
      min_val = (a < b) ? a : b;
    end
  endfunction

endpackage : vrtl_pkg

`endif // VRTL_PKG_SV
