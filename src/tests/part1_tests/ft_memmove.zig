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

const is_function_defined = function_list.hasFunction("ft_memmove");

fn ft_memmove(dest: [*]u8, src: [*]const u8, n: usize) [*]u8 {
    if (comptime !is_function_defined) {
        return dest;
    } else {
        return @ptrCast(c.ft_memmove(dest, src, n));
    }
}

// Test basic functionality of ft_memmove
var test_memmove_basic = TestCase{
    .name = "Basic memmove",
    .fn_ptr = &test_memmove_basic_fn,
};

fn test_memmove_basic_fn(_: std.mem.Allocator) TestCaseError!void {
    var buffer: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var dest: [10]u8 = undefined;
    const n: usize = 10;

    const result = ft_memmove(&dest, &buffer, n);
    try assert.expect(std.mem.eql(u8, dest[0..n], buffer[0..n]), "Destination should match source after memmove");
    try assert.expect(result == &dest, "ft_memmove should return the original destination pointer");
}

// Test memmove with overlapping regions (src before dest)
var test_memmove_overlap_src_before_dest = TestCase{
    .name = "Memmove with overlap (src before dest)",
    .fn_ptr = &test_memmove_overlap_src_before_dest_fn,
};

fn test_memmove_overlap_src_before_dest_fn(_: std.mem.Allocator) TestCaseError!void {
    var buffer: [15]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
    const n: usize = 10;

    const result = ft_memmove(@ptrCast(&buffer[5]), @ptrCast(&buffer[0]), n);

    try assert.expect(std.mem.eql(u8, buffer[5..15], &[_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }), "Overlapping memmove failed (src before dest)");
    try assert.expect(result == @as([*]u8, @ptrCast(&buffer[5])), "ft_memmove should return the original destination pointer");
}

// Test memmove with overlapping regions (dest before src)
var test_memmove_overlap_dest_before_src = TestCase{
    .name = "Memmove with overlap (dest before src)",
    .fn_ptr = &test_memmove_overlap_dest_before_src_fn,
};

fn test_memmove_overlap_dest_before_src_fn(_: std.mem.Allocator) TestCaseError!void {
    var buffer: [15]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
    const n: usize = 10;

    const result = ft_memmove(&buffer, @ptrCast(&buffer[5]), n);
    try assert.expect(std.mem.eql(u8, buffer[0..10], &[_]u8{ 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }), "Overlapping memmove failed (dest before src)");
    try assert.expect(result == &buffer, "ft_memmove should return the original destination pointer");
}

// Test memmove with n = 0 (no operation)
var test_memmove_zero = TestCase{
    .name = "Memmove with n = 0",
    .fn_ptr = &test_memmove_zero_fn,
};

fn test_memmove_zero_fn(_: std.mem.Allocator) TestCaseError!void {
    var buffer: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var dest: [10]u8 = [_]u8{ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
    const original_dest = dest;
    const n: usize = 0;

    const result = ft_memmove(&dest, &buffer, n);
    try assert.expect(std.mem.eql(u8, dest[0..10], original_dest[0..10]), "Destination should remain unchanged when n = 0");
    try assert.expect(result == &dest, "ft_memmove should return the original destination pointer");
}

// Test memmove with large data
var test_memmove_large = TestCase{
    .name = "Large memmove",
    .fn_ptr = &test_memmove_large_fn,
};

fn test_memmove_large_fn(allocator: std.mem.Allocator) TestCaseError!void {
    const size: usize = 1024 * 1024; // 1 MB
    var buffer = try allocator.alloc(u8, size);
    const dest = try allocator.alloc(u8, size);

    // Initialize source with some data
    for (0..size) |i| {
        buffer[i] = @truncate(i);
    }

    const result = ft_memmove(dest.ptr, buffer.ptr, size);
    try assert.expect(std.mem.eql(u8, dest, buffer), "Destination should match source after large memmove");
    try assert.expect(result == dest.ptr, "ft_memmove should return the original destination pointer");
}

var test_cases = [_]*TestCase{
    &test_memmove_basic,
    &test_memmove_overlap_src_before_dest,
    &test_memmove_overlap_dest_before_src,
    &test_memmove_zero,
    &test_memmove_large,
};

pub var suite = TestSuite{
    .name = "ft_memmove",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
