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

// ft_calloc

// Test allocation of zero-initialized memory
var test_calloc_basic = TestCase{
    .name = "Basic calloc allocation",
    .fn_ptr = &test_calloc_basic_fn,
};

fn test_calloc_basic_fn(_: std.mem.Allocator) AssertError!void {
    const num_elements: usize = 5;
    const element_size: usize = @sizeOf(u8);

    const ptr: ?*[5]u8 = @ptrCast(c.ft_calloc(num_elements, element_size));

    if (ptr) |p| {
        for (0..num_elements) |i| {
            try assert.expect(p[i] == 0, "Allocated memory should be zero-initialized");
        }

        std.heap.c_allocator.free(p);
    } else {
        try assert.expect(false, "ft_calloc returned null pointer");
    }
}

// Test allocation with large size
var test_calloc_large = TestCase{
    .name = "Large calloc allocation",
    .fn_ptr = &test_calloc_large_fn,
};

fn test_calloc_large_fn(_: std.mem.Allocator) AssertError!void {
    const num_elements: usize = 1_000_000;
    const element_size: usize = @sizeOf(u8);

    const ptr: ?*[num_elements]u8 = @ptrCast(c.ft_calloc(num_elements, element_size));

    if (ptr) |p| {
        for (0..num_elements) |i| {
            try assert.expect(p[i] == 0, "Allocated memory should be zero-initialized");
        }

        std.heap.c_allocator.free(p);
    } else {
        try assert.expect(false, "ft_calloc returned null pointer");
    }
}

// Test with different element sizes
var test_calloc_different_sizes = TestCase{
    .name = "Calloc with different element sizes",
    .fn_ptr = &test_calloc_different_sizes_fn,
};

fn test_calloc_different_sizes_fn(_: std.mem.Allocator) AssertError!void {
    const num_elements: usize = 100_000;
    const element_size: usize = @sizeOf(u32);

    const ptr: ?*[num_elements * element_size]u8 = @ptrCast(c.ft_calloc(num_elements, element_size));

    if (ptr) |p| {
        for (0..(num_elements * element_size)) |i| {
            try assert.expect(p[i] == 0, "Allocated memory should be zero-initialized");
        }

        std.heap.c_allocator.free(p);
        return;
    } else {
        try assert.expect(false, "ft_calloc returned null pointer");
    }
}

const test_cases = [_]*TestCase{
    &test_calloc_basic,
    &test_calloc_large,
    &test_calloc_different_sizes,
};

const is_function_defined = function_list.hasFunction("ft_calloc");

pub const suite = TestSuite{
    .name = "ft_calloc",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
