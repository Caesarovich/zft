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

// Test with character present in string
var test_char_present = TestCase{
    .name = "Character present in string",
    .fn_ptr = &test_char_present_fn,
};

fn test_char_present_fn() AssertError!void {
    const str = "Hello, World!";
    const ch: u8 = 'W';
    const result = c.ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find character 'W' in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[7]), "Expected pointer to point to 'W' in the string");
}

// Test with character not present in string
var test_char_not_present = TestCase{
    .name = "Character not present in string",
    .fn_ptr = &test_char_not_present_fn,
};

fn test_char_not_present_fn() AssertError!void {
    const str = "Hello, World!";
    const ch: u8 = 'x';
    const result = c.ft_strchr(str, ch);
    try assert.expect(result == null, "Expected not to find character 'x' in the string");
}

// Test with null terminator character
var test_null_terminator = TestCase{
    .name = "Null terminator character",
    .fn_ptr = &test_null_terminator_fn,
};

fn test_null_terminator_fn() AssertError!void {
    const str = "Hello, World!";
    const ch: u8 = 0; // Null terminator
    const result = c.ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find null terminator in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[13]), "Expected pointer to point to null terminator at end of string");
}

// Test with empty string
var test_empty_string = TestCase{
    .name = "Empty string",
    .fn_ptr = &test_empty_string_fn,
};

fn test_empty_string_fn() AssertError!void {
    const str = "";
    const ch: u8 = 'a';
    const result = c.ft_strchr(str, ch);
    try assert.expect(result == null, "Expected not to find any character in an empty string");
}

// Test with character at the beginning of the string
var test_char_at_beginning = TestCase{
    .name = "Character at beginning of string",
    .fn_ptr = &test_char_at_beginning_fn,
};

fn test_char_at_beginning_fn() AssertError!void {
    const str = "Hello, World!";
    const ch: u8 = 'H';
    const result = c.ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find character 'H' in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[0]), "Expected pointer to point to 'H' at beginning of string");
}

// Test with character at the end of the string
var test_char_at_end = TestCase{
    .name = "Character at end of string",
    .fn_ptr = &test_char_at_end_fn,
};

fn test_char_at_end_fn() AssertError!void {
    const str = "Hello, World!";
    const ch: u8 = '!';
    const result = c.ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find character '!' in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[12]), "Expected pointer to point to '!' at end of string");
}

// Test with multiple occurrences of character
var test_multiple_occurrences = TestCase{
    .name = "Multiple occurrences of character",
    .fn_ptr = &test_multiple_occurrences_fn,
};

fn test_multiple_occurrences_fn() AssertError!void {
    const str = "banana";
    const ch: u8 = 'a';
    const result = c.ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find character 'a' in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[1]), "Expected pointer to point to first 'a' in the string");
}
const test_cases = [_]*TestCase{
    &test_char_present,
    &test_char_not_present,
    &test_null_terminator,
    &test_empty_string,
    &test_char_at_beginning,
    &test_char_at_end,
    &test_multiple_occurrences,
};

const is_function_defined = function_list.hasFunction("ft_strchr");

pub const suite = TestSuite{
    .name = "ft_strchr",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
