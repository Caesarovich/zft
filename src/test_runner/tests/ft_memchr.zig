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

// ft_memchr
// Test with a character present in the memory block
var test_memchr_found = TestCase{
    .name = "Memchr character present",
    .fn_ptr = &test_memchr_found_fn,
};

fn test_memchr_found_fn(_: std.mem.Allocator) AssertError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j' };
    const target: u8 = 'e';
    const n: usize = buffer.len;

    const result = c.ft_memchr(&buffer, target, n);
    try assert.expect(result != null, "ft_memchr should find the character 'e'");
    if (result) |ptr| {
        try assert.expect(@as(*u8, @ptrCast(ptr)) == &buffer[4], "ft_memchr should return pointer to the first occurrence of 'e'");
    }
}

// Test with a character not present in the memory block
var test_memchr_not_found = TestCase{
    .name = "Memchr character not present",
    .fn_ptr = &test_memchr_not_found_fn,
};

fn test_memchr_not_found_fn(_: std.mem.Allocator) AssertError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j' };
    const target: u8 = 'z';
    const n: usize = buffer.len;

    const result = c.ft_memchr(&buffer, target, n);
    try assert.expect(result == null, "ft_memchr should not find the character 'z'");
}

// Test with n = 0 (should not search)
var test_memchr_n_zero = TestCase{
    .name = "Memchr with n = 0",
    .fn_ptr = &test_memchr_n_zero_fn,
};

fn test_memchr_n_zero_fn(_: std.mem.Allocator) AssertError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j' };
    const target: u8 = 'a';
    const n: usize = 0;

    const result = c.ft_memchr(&buffer, target, n);
    try assert.expect(result == null, "ft_memchr should not find any character when n = 0");
}
// Test with multiple occurrences of the character
var test_memchr_multiple_occurrences = TestCase{
    .name = "Memchr multiple occurrences",
    .fn_ptr = &test_memchr_multiple_occurrences_fn,
};

fn test_memchr_multiple_occurrences_fn(_: std.mem.Allocator) AssertError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 'a', 'e', 'f', 'a', 'h', 'i', 'j' };
    const target: u8 = 'a';
    const n: usize = buffer.len;

    const result = c.ft_memchr(&buffer, target, n);
    try assert.expect(result != null, "ft_memchr should find the character 'a'");

    if (result) |ptr| {
        try assert.expect(@as(*u8, @ptrCast(ptr)) == &buffer[0], "ft_memchr should return pointer to the first occurrence of 'a'");
    }
}

// Test with searching after string end
var test_memchr_beyond_string = TestCase{
    .name = "Memchr beyond string end",
    .fn_ptr = &test_memchr_beyond_string_fn,
};

fn test_memchr_beyond_string_fn(_: std.mem.Allocator) AssertError!void {
    const buffer: [15]u8 = [_]u8{ 'H', 'e', 'l', 'l', 'o', 0, 'W', 'o', 'r', 'l', 'd', '!', 0, 0, 0 };
    const target: u8 = 'W';
    const n: usize = 15;

    const result = c.ft_memchr(&buffer, target, n);
    try assert.expect(result != null, "ft_memchr should find the character 'W'");
    if (result) |ptr| {
        try assert.expect(@as(*u8, @ptrCast(ptr)) == &buffer[6], "ft_memchr should return pointer to the first occurrence of 'W'");
    }
}

// Test with null character search
var test_memchr_null_character = TestCase{
    .name = "Memchr null character search",
    .fn_ptr = &test_memchr_null_character_fn,
};

fn test_memchr_null_character_fn(_: std.mem.Allocator) AssertError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 0, 'e', 'f', 'g', 'h', 'i', 'j' };
    const target: u8 = 0;
    const n: usize = buffer.len;

    const result = c.ft_memchr(&buffer, target, n);
    try assert.expect(result != null, "ft_memchr should find the null character");

    if (result) |ptr| {
        try assert.expect(@as(*u8, @ptrCast(ptr)) == &buffer[3], "ft_memchr should return pointer to the first occurrence of null character");
    }
}

// Test with empty buffer
var test_memchr_empty_buffer = TestCase{
    .name = "Memchr empty buffer",
    .fn_ptr = &test_memchr_empty_buffer_fn,
};

fn test_memchr_empty_buffer_fn(_: std.mem.Allocator) AssertError!void {
    const buffer: [0]u8 = [_]u8{};
    const target: u8 = 'a';
    const n: usize = 0;

    const result = c.ft_memchr(&buffer, target, n);
    try assert.expect(result == null, "ft_memchr should not find any character in an empty buffer");
}

var test_cases = [_]*TestCase{
    &test_memchr_found,
    &test_memchr_not_found,
    &test_memchr_n_zero,
    &test_memchr_multiple_occurrences,
    &test_memchr_beyond_string,
    &test_memchr_null_character,
    &test_memchr_empty_buffer,
};

const is_function_defined = function_list.hasFunction("ft_memchr");

pub var suite = TestSuite{
    .name = "ft_memchr",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
