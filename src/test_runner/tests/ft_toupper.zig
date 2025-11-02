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

/// Test with lowercase letters
var test_lowercase_chars = TestCase{
    .name = "Lowercase letters",
    .fn_ptr = &test_lowercase_chars_fn,
};

fn test_lowercase_chars_fn() AssertError!void {
    try assert.expect(c.ft_toupper('a') == 'A', "Expected 'a' to convert to 'A'");
    try assert.expect(c.ft_toupper('m') == 'M', "Expected 'm' to convert to 'M'");
    try assert.expect(c.ft_toupper('z') == 'Z', "Expected 'z' to convert to 'Z'");
}

/// Test with uppercase letters (should remain unchanged)
var test_uppercase_chars = TestCase{
    .name = "Uppercase letters",
    .fn_ptr = &test_uppercase_chars_fn,
};

fn test_uppercase_chars_fn() AssertError!void {
    try assert.expect(c.ft_toupper('A') == 'A', "Expected 'A' to remain 'A'");
    try assert.expect(c.ft_toupper('M') == 'M', "Expected 'M' to remain 'M'");
    try assert.expect(c.ft_toupper('Z') == 'Z', "Expected 'Z' to remain 'Z'");
}

/// Test with non-alphabetic characters (should remain unchanged)
var test_non_alpha_chars = TestCase{
    .name = "Non-alphabetic characters",
    .fn_ptr = &test_non_alpha_chars_fn,
};

fn test_non_alpha_chars_fn() AssertError!void {
    try assert.expect(c.ft_toupper('0') == '0', "Expected '0' to remain '0'");
    try assert.expect(c.ft_toupper('9') == '9', "Expected '9' to remain '9'");
    try assert.expect(c.ft_toupper('!') == '!', "Expected '!' to remain '!'");
    try assert.expect(c.ft_toupper('@') == '@', "Expected '@' to remain '@'");
    try assert.expect(c.ft_toupper(' ') == ' ', "Expected ' ' to remain ' '");
}

// Test edge cases around alphabetic ranges
var test_edge_cases = TestCase{
    .name = "Edge cases around alphabetic ranges",
    .fn_ptr = &test_edge_cases_fn,
};

fn test_edge_cases_fn() AssertError!void {
    // Characters just before 'a'
    try assert.expect(c.ft_toupper('`') == '`', "Expected '`' (char before 'a') to remain '`'");
    // Characters just after 'z'
    try assert.expect(c.ft_toupper('{') == '{', "Expected '{' (char after 'z') to remain '{'");
    // Characters just before 'A'
    try assert.expect(c.ft_toupper('@') == '@', "Expected '@' (char before 'A') to remain '@'");
    // Characters just after 'Z'
    try assert.expect(c.ft_toupper('[') == '[', "Expected '[' (char after 'Z') to remain '['");
}

// Test with standard library comparison
var test_standard_comparison = TestCase{
    .name = "Comparison with standard toupper",
    .fn_ptr = &test_standard_comparison_fn,
};

fn test_standard_comparison_fn() AssertError!void {
    for (0..255) |i| {
        const custom_result = c.ft_toupper(@intCast(i));
        const std_result = c.toupper(@intCast(i));
        try assert.expect(custom_result == std_result, "ft_toupper and toupper differ on a character");
    }
}

const test_cases = [_]*TestCase{
    &test_lowercase_chars,
    &test_uppercase_chars,
    &test_non_alpha_chars,
    &test_edge_cases,
    &test_standard_comparison,
};

const is_function_defined = function_list.hasFunction("ft_toupper");

pub const suite = TestSuite{
    .name = "ft_toupper",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
