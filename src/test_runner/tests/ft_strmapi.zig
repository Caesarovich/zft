const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("string.h");
});

const is_function_defined = function_list.hasFunction("ft_strmapi");

fn ft_strmapi(s: [*c]const u8, f: ?*const fn (c_uint, u8) callconv(.c) u8) [*c]u8 {
    if (comptime !is_function_defined) {
        return null;
    } else {
        return c.ft_strmapi(s, f);
    }
}

// Test function to convert to uppercase
fn to_upper(index: c_uint, ch: u8) callconv(.c) u8 {
    _ = index; // unused parameter
    return if (ch >= 'a' and ch <= 'z') ch - 32 else ch;
}

// Test function to add index to character
fn add_index(index: c_uint, ch: u8) callconv(.c) u8 {
    return ch + @as(u8, @intCast(index));
}

// Test function that returns 'X' for all characters
fn replace_with_x(index: c_uint, ch: u8) callconv(.c) u8 {
    _ = index; // unused parameter
    _ = ch; // unused parameter
    return 'X';
}

// Test normal string mapping with uppercase function
var test_strmapi_uppercase = TestCase{
    .name = "Map to uppercase",
    .fn_ptr = &test_strmapi_uppercase_fn,
};

fn test_strmapi_uppercase_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_strmapi("hello", to_upper);
    try assert.expect(result != null, "ft_strmapi should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "HELLO") == 0, "Expected 'HELLO'");
        c.free(str);
    }
}

// Test string mapping with index addition
var test_strmapi_add_index = TestCase{
    .name = "Add index to characters",
    .fn_ptr = &test_strmapi_add_index_fn,
};

fn test_strmapi_add_index_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_strmapi("aaaa", add_index);
    try assert.expect(result != null, "ft_strmapi should return a valid pointer");
    if (result) |str| {
        try assert.expect(str[0] == 'a' + 0, "Expected first char to be 'a'");
        try assert.expect(str[1] == 'a' + 1, "Expected second char to be 'b'");
        try assert.expect(str[2] == 'a' + 2, "Expected third char to be 'c'");
        try assert.expect(str[3] == 'a' + 3, "Expected fourth char to be 'd'");
        try assert.expect(str[4] == 0, "Expected null terminator");
        c.free(str);
    }
}

// Test string mapping replacing all with same character
var test_strmapi_replace_all = TestCase{
    .name = "Replace all with same character",
    .fn_ptr = &test_strmapi_replace_all_fn,
};

fn test_strmapi_replace_all_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_strmapi("Hello", replace_with_x);
    try assert.expect(result != null, "ft_strmapi should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "XXXXX") == 0, "Expected 'XXXXX'");
        c.free(str);
    }
}

// Test with empty string
var test_strmapi_empty_string = TestCase{
    .name = "Empty string",
    .fn_ptr = &test_strmapi_empty_string_fn,
};

fn test_strmapi_empty_string_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_strmapi("", to_upper);
    try assert.expect(result != null, "ft_strmapi should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "") == 0, "Expected empty string");
        c.free(str);
    }
}

// Test with single character
var test_strmapi_single_char = TestCase{
    .name = "Single character",
    .fn_ptr = &test_strmapi_single_char_fn,
};

fn test_strmapi_single_char_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_strmapi("a", to_upper);
    try assert.expect(result != null, "ft_strmapi should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "A") == 0, "Expected 'A'");
        c.free(str);
    }
}

// Test with mixed case string
var test_strmapi_mixed_case = TestCase{
    .name = "Mixed case string",
    .fn_ptr = &test_strmapi_mixed_case_fn,
};

fn test_strmapi_mixed_case_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_strmapi("HeLLo", to_upper);
    try assert.expect(result != null, "ft_strmapi should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "HELLO") == 0, "Expected 'HELLO'");
        c.free(str);
    }
}

// Test with numbers and special characters
var test_strmapi_special_chars = TestCase{
    .name = "Numbers and special characters",
    .fn_ptr = &test_strmapi_special_chars_fn,
};

fn test_strmapi_special_chars_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_strmapi("hello123!", to_upper);
    try assert.expect(result != null, "ft_strmapi should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "HELLO123!") == 0, "Expected 'HELLO123!'");
        c.free(str);
    }
}

// Test with NULL string
var test_strmapi_null_string = TestCase{
    .name = "NULL string",
    .fn_ptr = &test_strmapi_null_string_fn,
};

fn test_strmapi_null_string_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_strmapi(null, to_upper);
    try assert.expect(result == null, "ft_strmapi should return null for null input string");
}

// Test with NULL function pointer
var test_strmapi_null_function = TestCase{
    .name = "NULL function pointer",
    .fn_ptr = &test_strmapi_null_function_fn,
};

fn test_strmapi_null_function_fn(_: std.mem.Allocator) AssertError!void {
    const result = ft_strmapi("hello", null);
    // strmapi should return a copy of the original string when function pointer is null
    try assert.expect(result != null, "ft_strmapi should return a valid pointer when function is null");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "hello") == 0, "Expected string to remain unchanged");
        c.free(str);
    }
}

var test_cases = [_]*TestCase{
    &test_strmapi_uppercase,
    &test_strmapi_add_index,
    &test_strmapi_replace_all,
    &test_strmapi_empty_string,
    &test_strmapi_single_char,
    &test_strmapi_mixed_case,
    &test_strmapi_special_chars,
    &test_strmapi_null_string,
    &test_strmapi_null_function,
};

pub var suite = TestSuite{
    .name = "ft_strmapi",
    .cases = &test_cases,
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
