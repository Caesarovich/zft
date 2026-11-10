const std = @import("std");

const TestFramework = @import("test-framework");
const assert = TestFramework.assert;
const TestCase = TestFramework.tests.TestCase;
const TestSuite = TestFramework.tests.TestSuite;
const TestCaseError = TestFramework.tests.TestCaseError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("ctype.h");
});

const is_function_defined = function_list.hasFunction("ft_isascii");

fn ft_isascii(ch: c_int) c_int {
    if (comptime !is_function_defined) {
        return 0;
    } else {
        return c.ft_isascii(ch);
    }
}

/// Test with clearly ascii characters
var test_ascii_chars = TestCase{
    .name = "ASCII characters",
    .fn_ptr = &test_ascii_chars_fn,
};

fn test_ascii_chars_fn(_: std.mem.Allocator) TestCaseError!void {
    try assert.expect(ft_isascii(0) != 0, "Expected 0 to be ASCII");
    try assert.expect(ft_isascii(65) != 0, "Expected 65 ('A') to be ASCII");
    try assert.expect(ft_isascii(127) != 0, "Expected 127 to be ASCII");
}

/// Test with clearly non-ascii characters
var test_non_ascii_chars = TestCase{
    .name = "Non-ASCII characters",
    .fn_ptr = &test_non_ascii_chars_fn,
};

fn test_non_ascii_chars_fn(_: std.mem.Allocator) TestCaseError!void {
    try assert.expect(ft_isascii(128) == 0, "Expected 128 to be non-ASCII");
    try assert.expect(ft_isascii(255) == 0, "Expected 255 to be non-ASCII");
    try assert.expect(ft_isascii(-1) == 0, "Expected -1 to be non-ASCII");
}

// Test comparison with standard isascii
var test_ascii_comparison = TestCase{
    .name = "Comparison with standard isascii",
    .fn_ptr = &test_ascii_comparison_fn,
};

fn test_ascii_comparison_fn(_: std.mem.Allocator) TestCaseError!void {
    for (0..255) |i| {
        const custom_result = ft_isascii(@intCast(i));
        const std_result = c.isascii(@intCast(i));
        try assert.expect(custom_result == std_result, "ft_isascii and isascii differ on a character");
    }
}

var test_cases = [_]*TestCase{
    &test_ascii_chars,
    &test_non_ascii_chars,
    &test_ascii_comparison,
};

pub var suite = TestSuite{
    .name = "ft_isascii",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
