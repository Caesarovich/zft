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

const is_function_defined = function_list.hasFunction("ft_memcpy");

fn ft_memcpy(dest: [*]u8, src: [*]const u8, n: usize) [*]u8 {
    if (comptime !is_function_defined) {
        return dest;
    } else {
        return @ptrCast(c.ft_memcpy(dest, src, n));
    }
}

// Test basic functionality of ft_memcpy
var test_memcpy_basic = TestCase{
    .name = "Basic memcpy",
    .fn_ptr = &test_memcpy_basic_fn,
};

fn test_memcpy_basic_fn(_: std.mem.Allocator) TestCaseError!void {
    const src: [10]u8 = .{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var dest: [10]u8 = undefined;
    const n: usize = src.len;

    const result = ft_memcpy(&dest, &src, n);

    try assert.expect(std.mem.eql(u8, dest[0..n], src[0..n]), "Destination should match source after memcpy");
    try assert.expect(result == &dest, "ft_memcpy should return the original destination pointer");
}

// Test memcpy with n = 0 (no operation)

var test_memcpy_zero = TestCase{
    .name = "Memcpy with n = 0",
    .fn_ptr = &test_memcpy_zero_fn,
};

fn test_memcpy_zero_fn(_: std.mem.Allocator) TestCaseError!void {
    const src: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var dest: [10]u8 = [_]u8{ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
    const original_dest = dest;
    const n: usize = 0;

    const result = ft_memcpy(&dest, &src, n);

    try assert.expect(std.mem.eql(u8, dest[0..10], original_dest[0..10]), "Destination should remain unchanged when n = 0");
    try assert.expect(result == &dest, "ft_memcpy should return the original destination pointer");
}

// Test memcpy with large data

var test_memcpy_large = TestCase{
    .name = "Large memcpy",
    .fn_ptr = &test_memcpy_large_fn,
};

fn test_memcpy_large_fn(allocator: std.mem.Allocator) TestCaseError!void {
    const size: usize = 1024 * 1024; // 1 MB
    const src = try allocator.alloc(u8, size);
    const dest = try allocator.alloc(u8, size);

    // Initialize source with some data
    for (0..size) |i| {
        src[i] = @truncate(i);
    }

    const result = ft_memcpy(dest.ptr, src.ptr, size);

    try assert.expect(std.mem.eql(u8, dest, src), "Destination should match source after large memcpy");
    try assert.expect(result == dest.ptr, "ft_memcpy should return the original destination pointer");
}

// Test memcpy partial length
var test_memcpy_partial = TestCase{
    .name = "Partial memcpy",
    .fn_ptr = &test_memcpy_partial_fn,
};

fn test_memcpy_partial_fn(_: std.mem.Allocator) TestCaseError!void {
    var src: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var dest: [10]u8 = [_]u8{ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
    const n: usize = 5;

    const result = ft_memcpy(&dest, &src, n);

    try assert.expect(std.mem.eql(u8, dest[0..n], src[0..n]), "First n bytes of destination should match source after memcpy");
    try assert.expect(std.mem.eql(u8, dest[n..10], &[_]u8{ 16, 17, 18, 19, 20 }), "Bytes beyond n should remain unchanged in destination");
    try assert.expect(result == &dest, "ft_memcpy should return the original destination pointer");
}

var test_cases = [_]*TestCase{
    &test_memcpy_basic,
    &test_memcpy_zero,
    &test_memcpy_large,
    &test_memcpy_partial,
};

pub var suite = TestSuite{
    .name = "ft_memcpy",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
