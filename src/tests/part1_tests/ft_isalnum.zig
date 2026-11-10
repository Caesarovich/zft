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

const is_function_defined = function_list.hasFunction("ft_isalnum");

fn ft_isalnum(ch: c_int) c_int {
    if (comptime !is_function_defined) {
        return 0;
    } else {
        return c.ft_isalnum(ch);
    }
}

/// Test with clearly alpha-numeric characters
var test_alnum_chars = TestCase{
    .name = "Alpha-numeric characters",
    .fn_ptr = &test_alnum_chars_fn,
};

fn test_alnum_chars_fn(_: std.mem.Allocator) TestCaseError!void {
    // Test alphabetic characters
    try assert.expect(ft_isalnum('a') != 0, "Expected 'a' to be alphanumeric");
    try assert.expect(ft_isalnum('Z') != 0, "Expected 'Z' to be alphanumeric");
    try assert.expect(ft_isalnum('m') != 0, "Expected 'm' to be alphanumeric");

    // Test numeric characters
    try assert.expect(ft_isalnum('0') != 0, "Expected '0' to be alphanumeric");
    try assert.expect(ft_isalnum('5') != 0, "Expected '5' to be alphanumeric");
    try assert.expect(ft_isalnum('9') != 0, "Expected '9' to be alphanumeric");
}

/// Test with clearly non-alphanumeric characters
var test_non_alnum_chars = TestCase{
    .name = "Non-alphanumeric characters",
    .fn_ptr = &test_non_alnum_chars_fn,
};

fn test_non_alnum_chars_fn(_: std.mem.Allocator) TestCaseError!void {
    // Test special characters
    try assert.expect(ft_isalnum('!') == 0, "Expected '!' to be non-alphanumeric");
    try assert.expect(ft_isalnum('@') == 0, "Expected '@' to be non-alphanumeric");
    try assert.expect(ft_isalnum('#') == 0, "Expected '#' to be non-alphanumeric");
    try assert.expect(ft_isalnum(' ') == 0, "Expected ' ' to be non-alphanumeric");
    try assert.expect(ft_isalnum('\t') == 0, "Expected '\\t' to be non-alphanumeric");
    try assert.expect(ft_isalnum('\n') == 0, "Expected '\\n' to be non-alphanumeric");
}

// Test edge cases around alphanumeric ranges

var test_edge_cases = TestCase{
    .name = "Edge cases around alphanumeric ranges",
    .fn_ptr = &test_edge_cases_fn,
};

fn test_edge_cases_fn(_: std.mem.Allocator) TestCaseError!void {
    // Characters just before '0'
    try assert.expect(ft_isalnum('/') == 0, "Expected '/' (char before '0') to be non-alphanumeric");

    // Characters just after '9'
    try assert.expect(ft_isalnum(':') == 0, "Expected ':' (char after '9') to be non-alphanumeric");

    // Characters just before 'A'
    try assert.expect(ft_isalnum('@') == 0, "Expected '@' (char before 'A') to be non-alphanumeric");

    // Characters just after 'Z'
    try assert.expect(ft_isalnum('[') == 0, "Expected '[' (char after 'Z') to be non-alphanumeric");

    // Characters just before 'a'
    try assert.expect(ft_isalnum('`') == 0, "Expected '`' (char before 'a') to be non-alphanumeric");

    // Characters just after 'z'
    try assert.expect(ft_isalnum('{') == 0, "Expected '{' (char after 'z') to be non-alphanumeric");
}

// Comparison with standard isalnum
var test_comparison_with_standard = TestCase{
    .name = "Comparison with standard isalnum",
    .fn_ptr = &test_comparison_with_standard_fn,
};

fn test_comparison_with_standard_fn(_: std.mem.Allocator) TestCaseError!void {
    for (0..127) |ch| {
        const custom_result = ft_isalnum(@intCast(ch)) != 0;
        const standard_result = c.isalnum(@intCast(ch)) != 0;
        try assert.expect(custom_result == standard_result, "ft_isalnum and isalnum differ on a character");
    }
}

var test_cases = [_]*TestCase{
    &test_alnum_chars,
    &test_non_alnum_chars,
    &test_edge_cases,
    &test_comparison_with_standard,
};

pub var suite = TestSuite{
    .name = "ft_isalnum",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
