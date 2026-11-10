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

const is_function_defined = function_list.hasFunction("ft_strchr");

fn ft_strchr(str: [*c]const u8, ch: c_int) [*c]u8 {
    if (comptime !is_function_defined) {
        return null;
    } else {
        return c.ft_strchr(str, ch);
    }
}

// Test with character present in string
var test_char_present = TestCase{
    .name = "Character present in string",
    .fn_ptr = &test_char_present_fn,
};

fn test_char_present_fn(_: std.mem.Allocator) TestCaseError!void {
    const str = "Hello, World!";
    const ch: u8 = 'W';
    const result = ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find character 'W' in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[7]), "Expected pointer to point to 'W' in the string");
}

// Test with character not present in string
var test_char_not_present = TestCase{
    .name = "Character not present in string",
    .fn_ptr = &test_char_not_present_fn,
};

fn test_char_not_present_fn(_: std.mem.Allocator) TestCaseError!void {
    const str = "Hello, World!";
    const ch: u8 = 'x';
    const result = ft_strchr(str, ch);
    try assert.expect(result == null, "Expected not to find character 'x' in the string");
}

// Test with null terminator character
var test_null_terminator = TestCase{
    .name = "Null terminator character",
    .fn_ptr = &test_null_terminator_fn,
};

fn test_null_terminator_fn(_: std.mem.Allocator) TestCaseError!void {
    const str = "Hello, World!";
    const ch: u8 = 0; // Null terminator
    const result = ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find null terminator in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[13]), "Expected pointer to point to null terminator at end of string");
}

// Test with empty string
var test_empty_string = TestCase{
    .name = "Empty string",
    .fn_ptr = &test_empty_string_fn,
};

fn test_empty_string_fn(_: std.mem.Allocator) TestCaseError!void {
    const str = "";
    const ch: u8 = 'a';
    const result = ft_strchr(str, ch);
    try assert.expect(result == null, "Expected not to find any character in an empty string");
}

// Test with character at the beginning of the string
var test_char_at_beginning = TestCase{
    .name = "Character at beginning of string",
    .fn_ptr = &test_char_at_beginning_fn,
};

fn test_char_at_beginning_fn(_: std.mem.Allocator) TestCaseError!void {
    const str = "Hello, World!";
    const ch: u8 = 'H';
    const result = ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find character 'H' in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[0]), "Expected pointer to point to 'H' at beginning of string");
}

// Test with character at the end of the string
var test_char_at_end = TestCase{
    .name = "Character at end of string",
    .fn_ptr = &test_char_at_end_fn,
};

fn test_char_at_end_fn(_: std.mem.Allocator) TestCaseError!void {
    const str = "Hello, World!";
    const ch: u8 = '!';
    const result = ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find character '!' in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[12]), "Expected pointer to point to '!' at end of string");
}

// Test with multiple occurrences of character
var test_multiple_occurrences = TestCase{
    .name = "Multiple occurrences of character",
    .fn_ptr = &test_multiple_occurrences_fn,
};

fn test_multiple_occurrences_fn(_: std.mem.Allocator) TestCaseError!void {
    const str = "banana";
    const ch: u8 = 'a';
    const result = ft_strchr(str, ch);
    try assert.expect(result != null, "Expected to find character 'a' in the string");
    try assert.expect(@intFromPtr(result) == @intFromPtr(&str[1]), "Expected pointer to point to first 'a' in the string");
}

// Test with positive values larger than 127 (wrapped)
var test_strchr_positive_wrapped = TestCase{
    .name = "Strchr with positive values (wrapped)",
    .fn_ptr = &test_strchr_positive_wrapped_fn,
};

fn test_strchr_positive_wrapped_fn(_: std.mem.Allocator) TestCaseError!void {
    const str1 = "Hello";
    const result1 = ft_strchr(str1, 'e' + 256); // 'e' is 101, 101 + 256 = 357
    try assert.expect(result1 != null, "ft_strchr should find character 'e' when searching with 'e' + 256");
    try assert.expect(@intFromPtr(result1) == @intFromPtr(&str1[1]), "Expected pointer to 'e' in the string");

    const str2 = "World";
    const result2 = ft_strchr(str2, 'o' + 256); // 'o' is 111, 111 + 256 = 367
    try assert.expect(result2 != null, "ft_strchr should find character 'o' when searching with 'o' + 256");
    try assert.expect(@intFromPtr(result2) == @intFromPtr(&str2[1]), "Expected pointer to 'o' in the string");

    const str3 = "ZigLang";
    const result3 = ft_strchr(str3, 'L' + 256); // 'L' is 76, 76 + 256 = 332
    try assert.expect(result3 != null, "ft_strchr should find character 'L' when searching with 'L' + 256");
    try assert.expect(@intFromPtr(result3) == @intFromPtr(&str3[3]), "Expected pointer to 'L' in the string");
}

// Test with negative values (wrapped)
var test_strchr_negative_wrapped = TestCase{
    .name = "Strchr with negative values (wrapped)",
    .fn_ptr = &test_strchr_negative_wrapped_fn,
};

fn test_strchr_negative_wrapped_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer1 = "Hello";
    const result1 = ft_strchr(buffer1, 'e' - 256); // 'e' is 101, 101 - 256 = -155
    try assert.expect(result1 != null, "ft_strchr should find character 'e' when searching with 'e' - 256");
    try assert.expect(@intFromPtr(result1) == @intFromPtr(&buffer1[1]), "Expected pointer to 'e' in the string");

    const buffer2 = "World";
    const result2 = ft_strchr(buffer2, 'o' - 256); // 'o' is 111, 111 - 256 = -145
    try assert.expect(result2 != null, "ft_strchr should find character 'o' when searching with 'o' - 256");
    try assert.expect(@intFromPtr(result2) == @intFromPtr(&buffer2[1]), "Expected pointer to 'o' in the string");

    const buffer3 = "ZigLang";
    const result3 = ft_strchr(buffer3, 'L' - 256); // 'L' is 76, 76 - 256 = -180
    try assert.expect(result3 != null, "ft_strchr should find character 'L' when searching with 'L' - 256");
    try assert.expect(@intFromPtr(result3) == @intFromPtr(&buffer3[3]), "Expected pointer to 'L' in the string");
}

var test_cases = [_]*TestCase{
    &test_char_present,
    &test_char_not_present,
    &test_null_terminator,
    &test_empty_string,
    &test_char_at_beginning,
    &test_char_at_end,
    &test_multiple_occurrences,
    &test_strchr_positive_wrapped,
    &test_strchr_negative_wrapped,
};

pub var suite = TestSuite{
    .name = "ft_strchr",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
