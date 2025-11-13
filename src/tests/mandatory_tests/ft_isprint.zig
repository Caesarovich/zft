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

const is_function_defined = function_list.hasFunction("ft_isprint");

fn ft_isprint(ch: c_int) c_int {
    if (comptime !is_function_defined) {
        return 0;
    } else {
        return c.ft_isprint(ch);
    }
}

/// Test with clearly printable characters
var test_printable_chars = TestCase{
    .name = "Printable characters",
    .fn_ptr = &test_printable_chars_fn,
};

fn test_printable_chars_fn(_: std.mem.Allocator) TestCaseError!void {
    // Test alphabetic characters
    try assert.expect(ft_isprint('a') != 0, "Expected 'a' to be printable");
    try assert.expect(ft_isprint('Z') != 0, "Expected 'Z' to be printable");

    // Test numeric characters
    try assert.expect(ft_isprint('0') != 0, "Expected '0' to be printable");
    try assert.expect(ft_isprint('9') != 0, "Expected '9' to be printable");

    // Test special characters
    try assert.expect(ft_isprint('!') != 0, "Expected '!' to be printable");
    try assert.expect(ft_isprint('@') != 0, "Expected '@' to be printable");
    try assert.expect(ft_isprint('#') != 0, "Expected '#' to be printable");
    try assert.expect(ft_isprint(' ') != 0, "Expected ' ' to be printable");
}

// Test space to be printable
var test_space_printable = TestCase{
    .name = "Space character printable",
    .fn_ptr = &test_space_printable_fn,
};

fn test_space_printable_fn(_: std.mem.Allocator) TestCaseError!void {
    try assert.expect(ft_isprint(' ') != 0, "Expected space character to be printable");
}

/// Test with clearly non-printable characters
var test_non_printable_chars = TestCase{
    .name = "Non-printable characters",
    .fn_ptr = &test_non_printable_chars_fn,
};

fn test_non_printable_chars_fn(_: std.mem.Allocator) TestCaseError!void {
    try assert.expect(ft_isprint('\n') == 0, "Expected '\\n' to be non-printable");
    try assert.expect(ft_isprint('\t') == 0, "Expected '\\t' to be non-printable");
    try assert.expect(ft_isprint('\r') == 0, "Expected '\\r' to be non-printable");
    try assert.expect(ft_isprint(0) == 0, "Expected 0 (null character) to be non-printable");
}

// Test comparison with standard isprint
var test_printable_comparison = TestCase{
    .name = "Comparison with standard isprint",
    .fn_ptr = &test_printable_comparison_fn,
};

fn test_printable_comparison_fn(_: std.mem.Allocator) TestCaseError!void {
    for (0..255) |i| {
        const custom_result = ft_isprint(@intCast(i)) != 0;
        const std_result = c.isprint(@intCast(i)) != 0;
        try assert.expect(custom_result == std_result, "ft_isprint and isprint differ on a character");
    }
}

var test_cases = [_]*TestCase{
    &test_printable_chars,
    &test_space_printable,
    &test_non_printable_chars,
    &test_printable_comparison,
};

pub var suite = TestSuite{
    .name = "ft_isprint",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
