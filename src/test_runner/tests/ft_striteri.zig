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

// Global variable to track function calls
var g_striteri_calls: [10]u8 = undefined;
var g_call_count: usize = 0;

// Test function to convert to uppercase in place
fn to_upper_inplace(index: c_uint, ch: [*c]u8) callconv(.c) void {
    if (ch.* >= 'a' and ch.* <= 'z') {
        ch.* = ch.* - 32;
    }
    // Track the call for verification
    if (g_call_count < g_striteri_calls.len) {
        g_striteri_calls[g_call_count] = @as(u8, @intCast(index));
        g_call_count += 1;
    }
}

// Test function to add index to character in place
fn add_index_inplace(index: c_uint, ch: [*c]u8) callconv(.c) void {
    ch.* = ch.* + @as(u8, @intCast(index));
    // Track the call for verification
    if (g_call_count < g_striteri_calls.len) {
        g_striteri_calls[g_call_count] = @as(u8, @intCast(index));
        g_call_count += 1;
    }
}

// Test function that replaces character with 'X'
fn replace_with_x_inplace(index: c_uint, ch: [*c]u8) callconv(.c) void {
    ch.* = 'X';
    // Track the call for verification
    if (g_call_count < g_striteri_calls.len) {
        g_striteri_calls[g_call_count] = @as(u8, @intCast(index));
        g_call_count += 1;
    }
}

// Helper function to reset call tracking
fn reset_call_tracking() void {
    g_call_count = 0;
    for (0..g_striteri_calls.len) |i| {
        g_striteri_calls[i] = 0;
    }
}

// Test normal string iteration with uppercase function
var test_striteri_uppercase = TestCase{
    .name = "Iterate and convert to uppercase",
    .fn_ptr = &test_striteri_uppercase_fn,
};

fn test_striteri_uppercase_fn(_: std.mem.Allocator) AssertError!void {
    reset_call_tracking();
    var test_str = [_]u8{ 'h', 'e', 'l', 'l', 'o', 0 };

    c.ft_striteri(&test_str, to_upper_inplace);

    try assert.expect(c.strcmp(&test_str, "HELLO") == 0, "Expected string to be converted to 'HELLO'");
    try assert.expect(g_call_count == 5, "Expected function to be called 5 times");

    // Verify correct indices were passed
    try assert.expect(g_striteri_calls[0] == 0, "Expected first call with index 0");
    try assert.expect(g_striteri_calls[1] == 1, "Expected second call with index 1");
    try assert.expect(g_striteri_calls[2] == 2, "Expected third call with index 2");
    try assert.expect(g_striteri_calls[3] == 3, "Expected fourth call with index 3");
    try assert.expect(g_striteri_calls[4] == 4, "Expected fifth call with index 4");
}

// Test string iteration with index addition
var test_striteri_add_index = TestCase{
    .name = "Add index to characters",
    .fn_ptr = &test_striteri_add_index_fn,
};

fn test_striteri_add_index_fn(_: std.mem.Allocator) AssertError!void {
    reset_call_tracking();
    var test_str = [_]u8{ 'a', 'a', 'a', 'a', 0 };

    c.ft_striteri(&test_str, add_index_inplace);

    try assert.expect(test_str[0] == 'a' + 0, "Expected first char to be 'a'");
    try assert.expect(test_str[1] == 'a' + 1, "Expected second char to be 'b'");
    try assert.expect(test_str[2] == 'a' + 2, "Expected third char to be 'c'");
    try assert.expect(test_str[3] == 'a' + 3, "Expected fourth char to be 'd'");
    try assert.expect(test_str[4] == 0, "Expected null terminator");
    try assert.expect(g_call_count == 4, "Expected function to be called 4 times");
}

// Test string iteration replacing all with same character
var test_striteri_replace_all = TestCase{
    .name = "Replace all with same character",
    .fn_ptr = &test_striteri_replace_all_fn,
};

fn test_striteri_replace_all_fn(_: std.mem.Allocator) AssertError!void {
    reset_call_tracking();
    var test_str = [_]u8{ 'H', 'e', 'l', 'l', 'o', 0 };

    c.ft_striteri(&test_str, replace_with_x_inplace);

    try assert.expect(c.strcmp(&test_str, "XXXXX") == 0, "Expected 'XXXXX'");
    try assert.expect(g_call_count == 5, "Expected function to be called 5 times");
}

// Test with empty string
var test_striteri_empty_string = TestCase{
    .name = "Empty string",
    .fn_ptr = &test_striteri_empty_string_fn,
};

fn test_striteri_empty_string_fn(_: std.mem.Allocator) AssertError!void {
    reset_call_tracking();
    var test_str = [_]u8{0};

    c.ft_striteri(&test_str, to_upper_inplace);

    try assert.expect(c.strcmp(&test_str, "") == 0, "Expected empty string to remain empty");
    try assert.expect(g_call_count == 0, "Expected function to not be called for empty string");
}

// Test with single character
var test_striteri_single_char = TestCase{
    .name = "Single character",
    .fn_ptr = &test_striteri_single_char_fn,
};

fn test_striteri_single_char_fn(_: std.mem.Allocator) AssertError!void {
    reset_call_tracking();
    var test_str = [_]u8{ 'a', 0 };

    c.ft_striteri(&test_str, to_upper_inplace);

    try assert.expect(c.strcmp(&test_str, "A") == 0, "Expected 'A'");
    try assert.expect(g_call_count == 1, "Expected function to be called once");
    try assert.expect(g_striteri_calls[0] == 0, "Expected call with index 0");
}

// Test with mixed case string
var test_striteri_mixed_case = TestCase{
    .name = "Mixed case string",
    .fn_ptr = &test_striteri_mixed_case_fn,
};

fn test_striteri_mixed_case_fn(_: std.mem.Allocator) AssertError!void {
    reset_call_tracking();
    var test_str = [_]u8{ 'H', 'e', 'L', 'L', 'o', 0 };

    c.ft_striteri(&test_str, to_upper_inplace);

    try assert.expect(c.strcmp(&test_str, "HELLO") == 0, "Expected 'HELLO'");
    try assert.expect(g_call_count == 5, "Expected function to be called 5 times");
}

// Test with numbers and special characters
var test_striteri_special_chars = TestCase{
    .name = "Numbers and special characters",
    .fn_ptr = &test_striteri_special_chars_fn,
};

fn test_striteri_special_chars_fn(_: std.mem.Allocator) AssertError!void {
    reset_call_tracking();
    var test_str = [_]u8{ 'h', 'e', 'l', 'l', 'o', '1', '2', '3', '!', 0 };

    c.ft_striteri(&test_str, to_upper_inplace);

    try assert.expect(c.strcmp(&test_str, "HELLO123!") == 0, "Expected 'HELLO123!'");
    try assert.expect(g_call_count == 9, "Expected function to be called 9 times");
}

// Test with NULL string
var test_striteri_null_string = TestCase{
    .name = "NULL string",
    .fn_ptr = &test_striteri_null_string_fn,
};

fn test_striteri_null_string_fn(_: std.mem.Allocator) AssertError!void {
    reset_call_tracking();
    const str_ptr: [*c]u8 = null;

    // Expect no crash or undefined behavior
    c.ft_striteri(str_ptr, to_upper_inplace);

    try assert.expect(g_call_count == 0, "Expected function to not be called for NULL string");
}

// Test with NULL function pointer
var test_striteri_null_function = TestCase{
    .name = "NULL function pointer",
    .fn_ptr = &test_striteri_null_function_fn,
};

fn test_striteri_null_function_fn(_: std.mem.Allocator) AssertError!void {
    reset_call_tracking();
    var test_str = [_]u8{ 'h', 'e', 'l', 'l', 'o', 0 };

    // Expect no crash or undefined behavior
    c.ft_striteri(&test_str, null);

    try assert.expect(c.strcmp(&test_str, "hello") == 0, "Expected string to remain unchanged");
    try assert.expect(g_call_count == 0, "Expected function to not be called for NULL function pointer");
}

var test_cases = [_]*TestCase{
    &test_striteri_uppercase,
    &test_striteri_add_index,
    &test_striteri_replace_all,
    &test_striteri_empty_string,
    &test_striteri_single_char,
    &test_striteri_mixed_case,
    &test_striteri_special_chars,
    &test_striteri_null_string,
    &test_striteri_null_function,
};

const is_function_defined = function_list.hasFunction("ft_striteri");

pub var suite = TestSuite{
    .name = "ft_striteri",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
