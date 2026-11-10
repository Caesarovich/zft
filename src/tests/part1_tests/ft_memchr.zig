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

const is_function_defined = function_list.hasFunction("ft_memchr");

const ft_memchr_wrapper = struct {
    fn call(s: ?*const anyopaque, ch: c_int, n: usize) ?*anyopaque {
        if (is_function_defined) {
            return c.ft_memchr(s, ch, n);
        } else {
            return null;
        }
    }
};

// ft_memchr
// Test with a character present in the memory block
var test_memchr_found = TestCase{
    .name = "Memchr character present",
    .fn_ptr = &test_memchr_found_fn,
};

fn test_memchr_found_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j' };
    const target: u8 = 'e';
    const n: usize = buffer.len;

    const result = ft_memchr_wrapper.call(&buffer, target, n);
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

fn test_memchr_not_found_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j' };
    const target: u8 = 'z';
    const n: usize = buffer.len;

    const result = ft_memchr_wrapper.call(&buffer, target, n);
    try assert.expect(result == null, "ft_memchr should not find the character 'z'");
}

// Test with n = 0 (should not search)
var test_memchr_n_zero = TestCase{
    .name = "Memchr with n = 0",
    .fn_ptr = &test_memchr_n_zero_fn,
};

fn test_memchr_n_zero_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j' };
    const target: u8 = 'a';
    const n: usize = 0;

    const result = ft_memchr_wrapper.call(&buffer, target, n);
    try assert.expect(result == null, "ft_memchr should not find any character when n = 0");
}
// Test with multiple occurrences of the character
var test_memchr_multiple_occurrences = TestCase{
    .name = "Memchr multiple occurrences",
    .fn_ptr = &test_memchr_multiple_occurrences_fn,
};

fn test_memchr_multiple_occurrences_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 'a', 'e', 'f', 'a', 'h', 'i', 'j' };
    const target: u8 = 'a';
    const n: usize = buffer.len;

    const result = ft_memchr_wrapper.call(&buffer, target, n);
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

fn test_memchr_beyond_string_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer: [15]u8 = [_]u8{ 'H', 'e', 'l', 'l', 'o', 0, 'W', 'o', 'r', 'l', 'd', '!', 0, 0, 0 };
    const target: u8 = 'W';
    const n: usize = 15;

    const result = ft_memchr_wrapper.call(&buffer, target, n);
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

fn test_memchr_null_character_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer: [10]u8 = [_]u8{ 'a', 'b', 'c', 0, 'e', 'f', 'g', 'h', 'i', 'j' };
    const target: u8 = 0;
    const n: usize = buffer.len;

    const result = ft_memchr_wrapper.call(&buffer, target, n);
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

fn test_memchr_empty_buffer_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer: [0]u8 = [_]u8{};
    const target: u8 = 'a';
    const n: usize = 0;

    const result = ft_memchr_wrapper.call(&buffer, target, n);
    try assert.expect(result == null, "ft_memchr should not find any character in an empty buffer");
}

// Test with character larger than 255
var test_memchr_large_character = TestCase{
    .name = "Memchr with character > 255",
    .fn_ptr = &test_memchr_large_character_fn,
};

fn test_memchr_large_character_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer: [5]u8 = [_]u8{ 0, 1, 2, 3, 4 };
    var target: c_int = 2 + 256; // 258 % 256 == 2
    const n: usize = buffer.len;

    const result = ft_memchr_wrapper.call(&buffer, target, n);
    try assert.expect(result != null, "ft_memchr should find the character 2");
    if (result) |ptr| {
        try assert.expect(@as(*u8, @ptrCast(ptr)) == &buffer[2], "ft_memchr should return pointer to the first occurrence of 2");
    }

    target = 300; // 300 % 256 == 44
    const result2 = ft_memchr_wrapper.call(&buffer, target, n);
    try assert.expect(result2 == null, "ft_memchr should not find the character 44");
}

// Test with negative character value
var test_memchr_negative_character = TestCase{
    .name = "Memchr with negative character",
    .fn_ptr = &test_memchr_negative_character_fn,
};

fn test_memchr_negative_character_fn(_: std.mem.Allocator) TestCaseError!void {
    const buffer: [5]u8 = [_]u8{ 0, 1, 2, 3, 4 };
    var target: c_int = -1;
    const n: usize = buffer.len;

    const result = ft_memchr_wrapper.call(&buffer, target, n);
    try assert.expect(result == null, "ft_memchr should not find the character -1");

    target = -256; // -256 % 256 == 0
    const result2 = ft_memchr_wrapper.call(&buffer, target, n);
    try assert.expect(result2 != null, "ft_memchr should find the character 0");
    if (result2) |ptr| {
        try assert.expect(@as(*u8, @ptrCast(ptr)) == &buffer[0], "ft_memchr should return pointer to the first occurrence of 0");
    }

    target = -253; // -253 % 256 == 3
    const result3 = ft_memchr_wrapper.call(&buffer, target, n);
    try assert.expect(result3 != null, "ft_memchr should find the character 3");
    if (result3) |ptr| {
        try assert.expect(@as(*u8, @ptrCast(ptr)) == &buffer[3], "ft_memchr should return pointer to the first occurrence of 3");
    }
}

var test_cases = [_]*TestCase{
    &test_memchr_found,
    &test_memchr_not_found,
    &test_memchr_n_zero,
    &test_memchr_multiple_occurrences,
    &test_memchr_beyond_string,
    &test_memchr_null_character,
    &test_memchr_large_character,
    &test_memchr_negative_character,
    &test_memchr_empty_buffer,
};

pub var suite = TestSuite{
    .name = "ft_memchr",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
