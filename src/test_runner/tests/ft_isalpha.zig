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

// Comparison with standard isalpha
var test_comparison_with_standard = TestCase{
    .name = "Comparison with standard isalpha",
    .fn_ptr = &test_comparison_with_standard_fn,
};

fn test_comparison_with_standard_fn(_: std.mem.Allocator) AssertError!void {
    for (0..127) |ch| {
        const custom_result = c.ft_isalpha(@intCast(ch)) != 0;
        const standard_result = c.isalpha(@intCast(ch)) != 0;
        try assert.expect(custom_result == standard_result, "ft_isalpha and isalpha differ on a character");
    }
}

var test_cases = [_]*TestCase{
    &test_alpha_chars,
    &test_non_alpha_chars,
    &test_edge_cases,
    &test_comparison_with_standard,
};

const is_function_defined = function_list.hasFunction("ft_isalpha");

pub var suite = TestSuite{
    .name = "ft_isalpha",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
