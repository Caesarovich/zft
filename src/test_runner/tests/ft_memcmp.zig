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

// ft_memcmp

// Test equal memory blocks
var test_memcmp_equal = TestCase{
    .name = "Equal memory blocks",
    .fn_ptr = &test_memcmp_equal_fn,
};

fn test_memcmp_equal_fn(_: std.mem.Allocator) AssertError!void {
    const buffer1: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const buffer2: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const n: usize = buffer1.len;

    const result = c.ft_memcmp(&buffer1, &buffer2, n);
    try assert.expect(result == 0, "ft_memcmp should return 0 for equal memory blocks");
}

// Test different memory blocks
var test_memcmp_different = TestCase{
    .name = "Different memory blocks",
    .fn_ptr = &test_memcmp_different_fn,
};

fn test_memcmp_different_fn(_: std.mem.Allocator) AssertError!void {
    const buffer1: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const buffer2: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 0, 7, 8, 9, 10 };
    const n: usize = buffer1.len;

    const result = c.ft_memcmp(&buffer1, &buffer2, n);
    try assert.expect(result != 0, "ft_memcmp should return non-zero for different memory blocks");
}

// Test with first block less than second
var test_memcmp_first_less = TestCase{
    .name = "First block less than second",
    .fn_ptr = &test_memcmp_first_less_fn,
};

fn test_memcmp_first_less_fn(_: std.mem.Allocator) AssertError!void {
    const buffer1: [5]u8 = [_]u8{ 1, 2, 3, 4, 5 };
    const buffer2: [5]u8 = [_]u8{ 1, 2, 3, 4, 6 };
    const n: usize = buffer1.len;

    const result = c.ft_memcmp(&buffer1, &buffer2, n);
    try assert.expect(result < 0, "ft_memcmp should return negative when first block is less than second");
}

// Test with first block greater than second
var test_memcmp_first_greater = TestCase{
    .name = "First block greater than second",
    .fn_ptr = &test_memcmp_first_greater_fn,
};

fn test_memcmp_first_greater_fn(_: std.mem.Allocator) AssertError!void {
    const buffer1: [5]u8 = [_]u8{ 1, 2, 3, 4, 7 };
    const buffer2: [5]u8 = [_]u8{ 1, 2, 3, 4, 6 };
    const n: usize = buffer1.len;

    const result = c.ft_memcmp(&buffer1, &buffer2, n);
    try assert.expect(result > 0, "ft_memcmp should return positive when first block is greater than second");
}

// Test with n = 0 (should return 0)
var test_memcmp_n_zero = TestCase{
    .name = "Memcmp with n = 0",
    .fn_ptr = &test_memcmp_n_zero_fn,
};

fn test_memcmp_n_zero_fn(_: std.mem.Allocator) AssertError!void {
    const buffer1: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const buffer2: [10]u8 = [_]u8{ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 };
    const n: usize = 0;

    const result = c.ft_memcmp(&buffer1, &buffer2, n);
    try assert.expect(result == 0, "ft_memcmp should return 0 when n = 0");
}

// Test with n less than the size of the buffers
var test_memcmp_partial = TestCase{
    .name = "Partial memcmp",
    .fn_ptr = &test_memcmp_partial_fn,
};

fn test_memcmp_partial_fn(_: std.mem.Allocator) AssertError!void {
    const buffer1: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const buffer2: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 0, 7, 8, 9, 10 };
    const n: usize = 5;

    const result = c.ft_memcmp(&buffer1, &buffer2, n);
    try assert.expect(result == 0, "ft_memcmp should return 0 for equal first n bytes");
    const result_diff = c.ft_memcmp(&buffer1, &buffer2, n + 1);
    try assert.expect(result_diff != 0, "ft_memcmp should return non-zero when differing byte is included");
}

// Test with positive values bigger than 127 (wrap modulo 256)
var test_memcmp_positive_wrapped = TestCase{
    .name = "Memcmp with positive values (wrapped)",
    .fn_ptr = &test_memcmp_positive_wrapped_fn,
};

fn test_memcmp_positive_wrapped_fn(_: std.mem.Allocator) AssertError!void {
    // 128 -> -128
    const buffer1: [5]u8 = [_]u8{ 128, 1, 2, 3, 4 };
    const buffer2: [5]i8 = [_]i8{ -128, 1, 2, 3, 4 };
    const n: usize = buffer1.len;

    const result = c.ft_memcmp(&buffer1, &buffer2, n);
    try assert.expect(result == 0, "ft_memcmp should treat 128 as -128 when cast to i8");

    // 192 -> -64
    const buffer3: [5]u8 = [_]u8{ 192, 1, 2, 3, 4 };
    const buffer4: [5]i8 = [_]i8{ -64, 1, 2, 3, 4 };
    const result2 = c.ft_memcmp(&buffer3, &buffer4, n);
    try assert.expect(result2 == 0, "ft_memcmp should treat 192 as -64 when cast to i8");

    // 255 -> -1
    const buffer5: [5]u8 = [_]u8{ 255, 0, 0, 0, 0 };
    const buffer6: [5]i8 = [_]i8{ -1, 0, 0, 0, 0 };
    const result3 = c.ft_memcmp(&buffer5, &buffer6, n);
    try assert.expect(result3 == 0, "ft_memcmp should treat 255 as -1 when cast to i8");
}

// Test with negative values (wrap modulo 256)
var test_memcmp_negative_wrapped = TestCase{
    .name = "Memcmp with negative values (wrapped)",
    .fn_ptr = &test_memcmp_negative_wrapped_fn,
};

fn test_memcmp_negative_wrapped_fn(_: std.mem.Allocator) AssertError!void {
    // -128  -> 128
    const buffer1: [5]i8 = [_]i8{ -128, 1, 2, 3, 4 };
    const buffer2: [5]u8 = [_]u8{ 128, 1, 2, 3, 4 };
    const n: usize = buffer1.len;

    const result = c.ft_memcmp(&buffer1, &buffer2, n);
    try assert.expect(result == 0, "ft_memcmp should treat -128 as 128 when cast to u8");

    // -64 -> 192
    const buffer3: [5]i8 = [_]i8{ -64, 1, 2, 3, 4 };
    const buffer4: [5]u8 = [_]u8{ 192, 1, 2, 3, 4 };
    const result2 = c.ft_memcmp(&buffer3, &buffer4, n);
    try assert.expect(result2 == 0, "ft_memcmp should treat -64 as 192 when cast to u8");

    // -1 -> 255
    const buffer5: [5]i8 = [_]i8{ -1, 0, 0, 0, 0 };
    const buffer6: [5]u8 = [_]u8{ 255, 0, 0, 0, 0 };
    const result3 = c.ft_memcmp(&buffer5, &buffer6, n);
    try assert.expect(result3 == 0, "ft_memcmp should treat -1 as 255 when cast to u8");
}

var test_cases = [_]*TestCase{
    &test_memcmp_equal,
    &test_memcmp_different,
    &test_memcmp_first_less,
    &test_memcmp_first_greater,
    &test_memcmp_n_zero,
    &test_memcmp_partial,
    &test_memcmp_positive_wrapped,
    &test_memcmp_negative_wrapped,
};

const is_function_defined = function_list.hasFunction("ft_memcmp");

pub var suite = TestSuite{
    .name = "ft_memcmp",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
