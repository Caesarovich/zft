const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("ctype.h");
});

/// Test with clearly printable characters
var test_printable_chars = TestCase{
    .name = "Printable characters",
    .fn_ptr = &test_printable_chars_fn,
};

fn test_printable_chars_fn() AssertError!void {
    // Test alphabetic characters
    try assert.expect(c.ft_isprint('a') != 0, "Expected 'a' to be printable");
    try assert.expect(c.ft_isprint('Z') != 0, "Expected 'Z' to be printable");

    // Test numeric characters
    try assert.expect(c.ft_isprint('0') != 0, "Expected '0' to be printable");
    try assert.expect(c.ft_isprint('9') != 0, "Expected '9' to be printable");

    // Test special characters
    try assert.expect(c.ft_isprint('!') != 0, "Expected '!' to be printable");
    try assert.expect(c.ft_isprint('@') != 0, "Expected '@' to be printable");
    try assert.expect(c.ft_isprint('#') != 0, "Expected '#' to be printable");
    try assert.expect(c.ft_isprint(' ') != 0, "Expected ' ' to be printable");
}

// Test space to be printable
var test_space_printable = TestCase{
    .name = "Space character printable",
    .fn_ptr = &test_space_printable_fn,
};

fn test_space_printable_fn() AssertError!void {
    try assert.expect(c.ft_isprint(' ') != 0, "Expected space character to be printable");
}

/// Test with clearly non-printable characters
var test_non_printable_chars = TestCase{
    .name = "Non-printable characters",
    .fn_ptr = &test_non_printable_chars_fn,
};

fn test_non_printable_chars_fn() AssertError!void {
    try assert.expect(c.ft_isprint('\n') == 0, "Expected '\\n' to be non-printable");
    try assert.expect(c.ft_isprint('\t') == 0, "Expected '\\t' to be non-printable");
    try assert.expect(c.ft_isprint('\r') == 0, "Expected '\\r' to be non-printable");
    try assert.expect(c.ft_isprint(0) == 0, "Expected 0 (null character) to be non-printable");
}

// Test comparison with standard isprint
var test_printable_comparison = TestCase{
    .name = "Comparison with standard isprint",
    .fn_ptr = &test_printable_comparison_fn,
};

fn test_printable_comparison_fn() AssertError!void {
    for (0..255) |i| {
        const custom_result = c.ft_isprint(@intCast(i)) != 0;
        const std_result = c.isprint(@intCast(i)) != 0;
        try assert.expect(custom_result == std_result, "ft_isprint and isprint differ on a character");
    }
}

const test_cases = [_]*TestCase{
    &test_printable_chars,
    &test_space_printable,
    &test_non_printable_chars,
    &test_printable_comparison,
};

pub const suite = TestSuite{
    .name = "ft_isprint",
    .cases = test_cases[0..],
};
