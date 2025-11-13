const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;

const TestCaseError = tests.tests.TestCaseError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("ctype.h");
});

const is_function_defined = function_list.hasFunction("ft_memset");

fn ft_memset(s: [*]u8, char: c_int, n: usize) [*]u8 {
    if (comptime !is_function_defined) {
        return s;
    } else {
        return @ptrCast(c.ft_memset(s, char, n));
    }
}

// Test setting a block of memory to a specific value
var test_memset_basic = TestCase{
    .name = "Basic memset",
    .fn_ptr = &test_memset_basic_fn,
};

fn test_memset_basic_fn(_: std.mem.Allocator) AssertError!void {
    var buffer: [10]u8 = undefined;
    const value: u8 = 0xAB;
    const n: usize = buffer.len;

    const result = ft_memset(&buffer, value, n);
    try assert.expect(result == &buffer, "ft_memset should return the original pointer");

    for (buffer) |byte| {
        try assert.expect(byte == value, "Each byte should be set to 0xAB");
    }
}

// Test setting zero bytes (n = 0)
var test_memset_zero = TestCase{
    .name = "Memset with n = 0",
    .fn_ptr = &test_memset_zero_fn,
};

fn test_memset_zero_fn(_: std.mem.Allocator) AssertError!void {
    var buffer: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const original_buffer = buffer;
    const value: u8 = 0xFF;
    const n: usize = 0;

    const result = ft_memset(&buffer, value, n);
    try assert.expect(result == &buffer, "ft_memset should return the original pointer");

    for (0..10) |i| {
        try assert.expect(buffer[i] == original_buffer[i], "Buffer should remain unchanged when n = 0");
    }
}

// Test setting a large block of memory
var test_memset_large = TestCase{
    .name = "Large memset",
    .fn_ptr = &test_memset_large_fn,
};

fn test_memset_large_fn(allocator: std.mem.Allocator) TestCaseError!void {
    const large_size: usize = 1024 * 1024; // 1 MB
    const buffer = try allocator.alloc(u8, large_size);
    const value: u8 = 0x7F;

    const result = ft_memset(buffer.ptr, value, large_size);

    try assert.expect(result == buffer.ptr, "ft_memset should return the original pointer");

    for (buffer) |byte| {
        try assert.expect(byte == value, "Each byte should be set to 0x7F");
    }
}

// Test not overwriting beyond n bytes
var test_memset_partial = TestCase{
    .name = "Partial memset",
    .fn_ptr = &test_memset_partial_fn,
};

fn test_memset_partial_fn(_: std.mem.Allocator) AssertError!void {
    var buffer: [10]u8 = [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    const value: u8 = 0x5A;
    const n: usize = 5;

    const result = ft_memset(&buffer, value, n);
    try assert.expect(result == &buffer, "ft_memset should return the original pointer");

    for (0..n) |i| {
        try assert.expect(buffer[i] == value, "First n bytes should be set to 0x5A");
    }
    for (n..buffer.len) |i| {
        try assert.expect(buffer[i] == 0, "Bytes beyond n should remain unchanged");
    }
}

var test_cases = [_]*TestCase{
    &test_memset_basic,
    &test_memset_zero,
    &test_memset_large,
    &test_memset_partial,
};

pub var suite = TestSuite{
    .name = "ft_memset",
    .cases = &test_cases,
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
