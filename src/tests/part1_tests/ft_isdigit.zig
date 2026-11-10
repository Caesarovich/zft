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

const is_function_defined = function_list.hasFunction("ft_isdigit");

fn ft_isdigit(ch: c_int) c_int {
    if (comptime !is_function_defined) {
        return 0;
    } else {
        return c.ft_isdigit(ch);
    }
}

/// Test with clearly numeric characters
var test_digit_chars = TestCase{
    .name = "Numeric characters",
    .fn_ptr = &test_digit_chars_fn,
};

fn test_digit_chars_fn(_: std.mem.Allocator) TestCaseError!void {
    try assert.expect(ft_isdigit('0') != 0, "Expected '0' to be numeric");
    try assert.expect(ft_isdigit('1') != 0, "Expected '1' to be numeric");
    try assert.expect(ft_isdigit('2') != 0, "Expected '2' to be numeric");
    try assert.expect(ft_isdigit('3') != 0, "Expected '3' to be numeric");
    try assert.expect(ft_isdigit('4') != 0, "Expected '4' to be numeric");
    try assert.expect(ft_isdigit('5') != 0, "Expected '5' to be numeric");
    try assert.expect(ft_isdigit('6') != 0, "Expected '6' to be numeric");
    try assert.expect(ft_isdigit('7') != 0, "Expected '7' to be numeric");
    try assert.expect(ft_isdigit('8') != 0, "Expected '8' to be numeric");
    try assert.expect(ft_isdigit('9') != 0, "Expected '9' to be numeric");
}

/// Test with clearly non-numeric characters
var test_non_digit_chars = TestCase{
    .name = "Non-numeric characters",
    .fn_ptr = &test_non_digit_chars_fn,
};

fn test_non_digit_chars_fn(_: std.mem.Allocator) TestCaseError!void {
    // Test alphabetic characters
    try assert.expect(ft_isdigit('a') == 0, "Expected 'a' to be non-numeric");
    try assert.expect(ft_isdigit('Z') == 0, "Expected 'Z' to be non-numeric");
    try assert.expect(ft_isdigit('m') == 0, "Expected 'm' to be non-numeric");

    // Test special characters
    try assert.expect(ft_isdigit('!') == 0, "Expected '!' to be non-numeric");
    try assert.expect(ft_isdigit('@') == 0, "Expected '@' to be non-numeric");
    try assert.expect(ft_isdigit('#') == 0, "Expected '#' to be non-numeric");
    try assert.expect(ft_isdigit(' ') == 0, "Expected ' ' to be non-numeric");
    try assert.expect(ft_isdigit('\t') == 0, "Expected '\\t' to be non-numeric");
    try assert.expect(ft_isdigit('\n') == 0, "Expected '\\n' to be non-numeric");
}

// Test edge cases around numeric ranges
var test_edge_cases = TestCase{
    .name = "Edge cases around numeric ranges",
    .fn_ptr = &test_edge_cases_fn,
};

fn test_edge_cases_fn(_: std.mem.Allocator) TestCaseError!void {
    try assert.expect(ft_isdigit('/') == 0, "Expected '/' (char before '0') to be non-numeric");
    try assert.expect(ft_isdigit(':') == 0, "Expected ':' (char after '9') to be non-numeric");
}

// Comparison with standard isdigit
var test_comparison_with_standard = TestCase{
    .name = "Comparison with standard isdigit",
    .fn_ptr = &test_comparison_with_standard_fn,
};

fn test_comparison_with_standard_fn(_: std.mem.Allocator) TestCaseError!void {
    for (0..127) |ch| {
        const custom_result = ft_isdigit(@intCast(ch)) != 0;
        const standard_result = c.isdigit(@intCast(ch)) != 0;
        try assert.expect(custom_result == standard_result, "ft_isdigit and isdigit differ on a character");
    }
}

var test_cases = [_]*TestCase{
    &test_digit_chars,
    &test_non_digit_chars,
    &test_edge_cases,
    &test_comparison_with_standard,
};

pub var suite = TestSuite{
    .name = "ft_isdigit",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
