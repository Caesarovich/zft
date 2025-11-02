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

/// Test with uppercase letters
var test_uppercase_chars = TestCase{
    .name = "Uppercase letters",
    .fn_ptr = &test_uppercase_chars_fn,
};

fn test_uppercase_chars_fn() AssertError!void {
    try assert.expect(c.ft_tolower('A') == 'a', "Expected 'A' to convert to 'a'");
    try assert.expect(c.ft_tolower('M') == 'm', "Expected 'M' to convert to 'm'");
    try assert.expect(c.ft_tolower('Z') == 'z', "Expected 'Z' to convert to 'z'");
}

/// Test with lowercase letters (should remain unchanged)
var test_lowercase_chars = TestCase{
    .name = "Lowercase letters",
    .fn_ptr = &test_lowercase_chars_fn,
};

fn test_lowercase_chars_fn() AssertError!void {
    try assert.expect(c.ft_tolower('a') == 'a', "Expected 'a' to remain 'a'");
    try assert.expect(c.ft_tolower('m') == 'm', "Expected 'm' to remain 'm'");
    try assert.expect(c.ft_tolower('z') == 'z', "Expected 'z' to remain 'z'");
}

/// Test with non-alphabetic characters (should remain unchanged)
var test_non_alpha_chars = TestCase{
    .name = "Non-alphabetic characters",
    .fn_ptr = &test_non_alpha_chars_fn,
};

fn test_non_alpha_chars_fn() AssertError!void {
    try assert.expect(c.ft_tolower('0') == '0', "Expected '0' to remain '0'");
    try assert.expect(c.ft_tolower('9') == '9', "Expected '9' to remain '9'");
    try assert.expect(c.ft_tolower('!') == '!', "Expected '!' to remain '!'");
    try assert.expect(c.ft_tolower('@') == '@', "Expected '@' to remain '@'");
    try assert.expect(c.ft_tolower(' ') == ' ', "Expected ' ' to remain ' '");
}

// Test edge cases around alphabetic ranges
var test_edge_cases = TestCase{
    .name = "Edge cases around alphabetic ranges",
    .fn_ptr = &test_edge_cases_fn,
};

fn test_edge_cases_fn() AssertError!void {
    // Characters just before 'A'
    try assert.expect(c.ft_tolower('@') == '@', "Expected '@' (char before 'A') to remain unchanged");
    try assert.expect(c.ft_tolower('`') == '`', "Expected '`' (char before 'a') to remain unchanged");

    // Characters just after 'Z'
    try assert.expect(c.ft_tolower('[') == '[', "Expected '[' (char after 'Z') to remain unchanged");
    try assert.expect(c.ft_tolower('{') == '{', "Expected '{' (char after 'z') to remain unchanged");
}

// Test with standard library for comparison
var test_standard_comparison = TestCase{
    .name = "Comparison with standard tolower",
    .fn_ptr = &test_standard_comparison_fn,
};

fn test_standard_comparison_fn() AssertError!void {
    for (0..255) |i| {
        const custom_result = c.ft_tolower(@intCast(i));
        const std_result = c.tolower(@intCast(i));
        try assert.expect(custom_result == std_result, "ft_tolower and tolower differ on a character");
    }
}

const test_cases = [_]*TestCase{
    &test_uppercase_chars,
    &test_lowercase_chars,
    &test_non_alpha_chars,
    &test_edge_cases,
    &test_standard_comparison,
};

const is_function_defined = function_list.hasFunction("ft_tolower");

pub const suite = TestSuite{
    .name = "ft_tolower",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
