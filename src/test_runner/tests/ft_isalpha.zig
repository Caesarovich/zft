const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("ctype.h");
});

/// Test with clearly alphabetic characters
var test_alpha_chars = TestCase{
    .name = "Alphabetic characters",
    .fn_ptr = &test_alpha_chars_fn,
};

fn test_alpha_chars_fn(_: std.mem.Allocator) AssertError!void {
    // Test lowercase letters
    try assert.expect(c.ft_isalpha('a') != 0, "Expected 'a' to be alphabetic");
    try assert.expect(c.ft_isalpha('z') != 0, "Expected 'z' to be alphabetic");
    try assert.expect(c.ft_isalpha('m') != 0, "Expected 'm' to be alphabetic");

    // Test uppercase letters
    try assert.expect(c.ft_isalpha('A') != 0, "Expected 'A' to be alphabetic");
    try assert.expect(c.ft_isalpha('Z') != 0, "Expected 'Z' to be alphabetic");
    try assert.expect(c.ft_isalpha('M') != 0, "Expected 'M' to be alphabetic");
}

/// Test with clearly non-alphabetic characters
var test_non_alpha_chars = TestCase{
    .name = "Non-alphabetic characters",
    .fn_ptr = &test_non_alpha_chars_fn,
};

fn test_non_alpha_chars_fn(_: std.mem.Allocator) AssertError!void {
    // Test digits
    try assert.expect(c.ft_isalpha('0') == 0, "Expected '0' to be non-alphabetic");
    try assert.expect(c.ft_isalpha('9') == 0, "Expected '9' to be non-alphabetic");
    try assert.expect(c.ft_isalpha('5') == 0, "Expected '5' to be non-alphabetic");

    // Test special characters
    try assert.expect(c.ft_isalpha('!') == 0, "Expected '!' to be non-alphabetic");
    try assert.expect(c.ft_isalpha('@') == 0, "Expected '@' to be non-alphabetic");
    try assert.expect(c.ft_isalpha('#') == 0, "Expected '#' to be non-alphabetic");
    try assert.expect(c.ft_isalpha(' ') == 0, "Expected ' ' to be non-alphabetic");
    try assert.expect(c.ft_isalpha('\t') == 0, "Expected '\\t' to be non-alphabetic");
    try assert.expect(c.ft_isalpha('\n') == 0, "Expected '\\n' to be non-alphabetic");
}

/// Test edge cases around alphabetic ranges
var test_edge_cases = TestCase{
    .name = "Edge cases around alphabetic ranges",
    .fn_ptr = &test_edge_cases_fn,
};

fn test_edge_cases_fn(_: std.mem.Allocator) AssertError!void {
    // Characters just before 'A' (ASCII 65)
    try assert.expect(c.ft_isalpha('@') == 0, "Expected '@' (ASCII 64, before 'A') to be non-alphabetic");
    try assert.expect(c.ft_isalpha('?') == 0, "Expected '?' (ASCII 63, before 'A') to be non-alphabetic");

    // Characters just after 'Z' (ASCII 90)
    try assert.expect(c.ft_isalpha('[') == 0, "Expected '[' (ASCII 91, after 'Z') to be non-alphabetic");
    try assert.expect(c.ft_isalpha('\\') == 0, "Expected '\\' (ASCII 92, after 'Z') to be non-alphabetic");

    // Characters just before 'a' (ASCII 97)
    try assert.expect(c.ft_isalpha('`') == 0, "Expected '`' (ASCII 96, before 'a') to be non-alphabetic");
    try assert.expect(c.ft_isalpha('_') == 0, "Expected '_' (ASCII 95, before 'a') to be non-alphabetic");

    // Characters just after 'z' (ASCII 122)
    try assert.expect(c.ft_isalpha('{') == 0, "Expected '{' (ASCII 123, after 'z') to be non-alphabetic");
    try assert.expect(c.ft_isalpha('|') == 0, "Expected '|' (ASCII 124, after 'z') to be non-alphabetic");
}

/// Test with negative values and extended ASCII
var test_extended_range = TestCase{
    .name = "Extended range and negative values",
    .fn_ptr = &test_extended_range_fn,
};

fn test_extended_range_fn(_: std.mem.Allocator) AssertError!void {
    // Test negative values
    try assert.expect(c.ft_isalpha(-1) == 0, "Expected -1 to be non-alphabetic");
    try assert.expect(c.ft_isalpha(-42) == 0, "Expected -42 to be non-alphabetic");

    // Test values beyond ASCII range
    try assert.expect(c.ft_isalpha(128) == 0, "Expected 128 (beyond ASCII) to be non-alphabetic");
    try assert.expect(c.ft_isalpha(255) == 0, "Expected 255 (beyond ASCII) to be non-alphabetic");
}

/// Comprehensive test comparing ft_isalpha with standard library isalpha for all ASCII characters
var test_ascii_comparison = TestCase{
    .name = "ASCII comparison with standard library",
    .fn_ptr = &test_ascii_comparison_fn,
};

fn test_ascii_comparison_fn(_: std.mem.Allocator) AssertError!void {
    // Test all ASCII characters (0-127)
    var i: c_int = 0;
    while (i < 128) : (i += 1) {
        const ft_result = c.ft_isalpha(i);
        const std_result = c.isalpha(i);

        // Both should agree on whether the character is alphabetic or not
        // We check if both are zero or both are non-zero
        const ft_is_alpha = ft_result != 0;
        const std_is_alpha = std_result != 0;

        if (ft_is_alpha != std_is_alpha) {
            // Create a more detailed error message
            return assert.expect(false, "ft_isalpha and isalpha disagree on ASCII character");
        }
    }
}

/// Test with boundary values
var test_boundary_values = TestCase{
    .name = "Boundary values",
    .fn_ptr = &test_boundary_values_fn,
};

fn test_boundary_values_fn(_: std.mem.Allocator) AssertError!void {
    // Test zero
    try assert.expect(c.ft_isalpha(0) == 0, "Expected 0 (null character) to be non-alphabetic");

    // Test maximum and minimum int values (implementation dependent)
    try assert.expect(c.ft_isalpha(2147483647) == 0, "Expected INT_MAX to be non-alphabetic");
    try assert.expect(c.ft_isalpha(-2147483648) == 0, "Expected INT_MIN to be non-alphabetic");
}

var test_cases = [_]*TestCase{ &test_alpha_chars, &test_non_alpha_chars, &test_edge_cases, &test_extended_range, &test_ascii_comparison, &test_boundary_values };

const is_function_defined = function_list.hasFunction("ft_isalpha");

pub var suite = TestSuite{
    .name = "ft_isalpha",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
