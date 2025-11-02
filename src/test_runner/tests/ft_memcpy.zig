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

// ft_memcpy

// Test basic functionality of ft_memcpy
var test_memcpy_basic = TestCase{
    .name = "Basic memcpy",
    .fn_ptr = &test_memcpy_basic_fn,
};

fn test_memcpy_basic_fn() AssertError!void {
    var src: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var dest: [10]u8 = undefined;
    const n: usize = src.len;

    const result: *[10]u8 = @ptrCast(c.ft_memcpy(&dest, &src, n));

    try assert.expect(std.mem.eql(u8, dest[0..n], src[0..n]), "Destination should match source after memcpy");
    try assert.expect(result == &dest, "ft_memcpy should return the original destination pointer");
}

// Test memcpy with n = 0 (no operation)

var test_memcpy_zero = TestCase{
    .name = "Memcpy with n = 0",
    .fn_ptr = &test_memcpy_zero_fn,
};

fn test_memcpy_zero_fn() AssertError!void {
    var src: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var dest: [10]u8 = [_]u8{ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
    const original_dest = dest;
    const n: usize = 0;

    const result: *[10]u8 = @ptrCast(c.ft_memcpy(&dest, &src, n));

    try assert.expect(std.mem.eql(u8, dest[0..10], original_dest[0..10]), "Destination should remain unchanged when n = 0");
    try assert.expect(result == &dest, "ft_memcpy should return the original destination pointer");
}

// Test memcpy with large data

var test_memcpy_large = TestCase{
    .name = "Large memcpy",
    .fn_ptr = &test_memcpy_large_fn,
};

fn test_memcpy_large_fn() AssertError!void {
    const size: usize = 1024 * 1024; // 1 MB
    var src: [size]u8 = undefined;
    var dest: [size]u8 = undefined;

    // Initialize source with some data
    for (0..size) |i| {
        src[i] = @truncate(i);
    }

    const result: *u8 = @ptrCast(c.ft_memcpy(&dest, &src, size));

    try assert.expect(std.mem.eql(u8, dest[0..size], src[0..size]), "Destination should match source after large memcpy");
    try assert.expect(result == &dest[0], "ft_memcpy should return the original destination pointer");
}

// Test memcpy partial length
var test_memcpy_partial = TestCase{
    .name = "Partial memcpy",
    .fn_ptr = &test_memcpy_partial_fn,
};

fn test_memcpy_partial_fn() AssertError!void {
    var src: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var dest: [10]u8 = [_]u8{ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
    const n: usize = 5;

    const result: *[10]u8 = @ptrCast(c.ft_memcpy(&dest, &src, n));

    try assert.expect(std.mem.eql(u8, dest[0..n], src[0..n]), "First n bytes of destination should match source after memcpy");
    try assert.expect(std.mem.eql(u8, dest[n..10], &[_]u8{ 16, 17, 18, 19, 20 }), "Bytes beyond n should remain unchanged in destination");
    try assert.expect(result == &dest, "ft_memcpy should return the original destination pointer");
}

const test_cases = [_]*TestCase{
    &test_memcpy_basic,
    &test_memcpy_zero,
    &test_memcpy_large,
    &test_memcpy_partial,
};

const is_function_defined = function_list.hasFunction("ft_memcpy");

pub const suite = TestSuite{
    .name = "ft_memcpy",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
