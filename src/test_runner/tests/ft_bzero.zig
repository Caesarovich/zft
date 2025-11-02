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

// ft_bzero

// Test basic functionality of ft_bzero
var test_bzero_basic = TestCase{
    .name = "Basic bzero",
    .fn_ptr = &test_bzero_basic_fn,
};

fn test_bzero_basic_fn() AssertError!void {
    var buffer: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const n: usize = buffer.len;

    c.ft_bzero(&buffer, n);

    for (buffer) |byte| {
        try assert.expect(byte == 0, "Each byte should be zeroed out");
    }
}

// Test bzero with n = 0 (no operation)
var test_bzero_zero = TestCase{
    .name = "Bzero with n = 0",
    .fn_ptr = &test_bzero_zero_fn,
};

fn test_bzero_zero_fn() AssertError!void {
    var buffer: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const original_buffer = buffer;
    const n: usize = 0;

    c.ft_bzero(&buffer, n);

    for (0..10) |i| {
        try assert.expect(buffer[i] == original_buffer[i], "Buffer should remain unchanged when n = 0");
    }
}

// Test bzero on a large buffer
var test_bzero_large = TestCase{
    .name = "Large bzero",
    .fn_ptr = &test_bzero_large_fn,
};

fn test_bzero_large_fn() AssertError!void {
    const size: usize = 1024 * 1024; // 1 MB
    var buffer: [size]u8 = undefined;

    // Initialize buffer with non-zero values
    for (&buffer) |*byte| {
        byte.* = 0xFF;
    }

    c.ft_bzero(&buffer, size);

    for (buffer) |byte| {
        try assert.expect(byte == 0, "Each byte in large buffer should be zeroed out");
    }
}

// Test bzero on already zeroed buffer
var test_bzero_already_zeroed = TestCase{
    .name = "Bzero on already zeroed buffer",
    .fn_ptr = &test_bzero_already_zeroed_fn,
};

fn test_bzero_already_zeroed_fn() AssertError!void {
    var buffer: [10]u8 = [_]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    const n: usize = buffer.len;

    c.ft_bzero(&buffer, n);

    for (buffer) |byte| {
        try assert.expect(byte == 0, "Each byte should remain zeroed out");
    }
}

// Test bzero with partial length
var test_bzero_partial = TestCase{
    .name = "Partial bzero",
    .fn_ptr = &test_bzero_partial_fn,
};

fn test_bzero_partial_fn() AssertError!void {
    var buffer: [10]u8 = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const original_buffer = buffer;
    const n: usize = 5;

    c.ft_bzero(&buffer, n);

    for (0..10) |i| {
        if (i < n) {
            try assert.expect(buffer[i] == 0, "First n bytes should be zeroed out");
        } else {
            try assert.expect(buffer[i] == original_buffer[i], "Remaining bytes should remain unchanged");
        }
    }
}

const test_cases = [_]*TestCase{
    &test_bzero_basic,
    &test_bzero_zero,
    &test_bzero_large,
    &test_bzero_already_zeroed,
    &test_bzero_partial,
};

const is_function_defined = function_list.hasFunction("ft_bzero");

pub const suite = TestSuite{
    .name = "ft_bzero",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
