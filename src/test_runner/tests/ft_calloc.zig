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

const is_function_defined = function_list.hasFunction("ft_calloc");

fn ft_calloc(count: usize, size: usize) ?*anyopaque {
    if (comptime is_function_defined) {
        return c.ft_calloc(count, size);
    } else {
        return null;
    }
}

// ft_calloc

// Test allocation of zero-initialized memory
var test_calloc_basic = TestCase{
    .name = "Basic calloc allocation",
    .fn_ptr = &test_calloc_basic_fn,
};

fn test_calloc_basic_fn(_: std.mem.Allocator) AssertError!void {
    const num_elements: usize = 5;
    const element_size: usize = @sizeOf(u8);

    const ptr: ?*[5]u8 = @ptrCast(ft_calloc(num_elements, element_size));

    if (ptr) |p| {
        for (0..num_elements) |i| {
            try assert.expect(p[i] == 0, "Allocated memory should be zero-initialized");
        }

        c.free(p);
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

    const ptr: ?*[num_elements]u8 = @ptrCast(ft_calloc(num_elements, element_size));

    if (ptr) |p| {
        for (0..num_elements) |i| {
            try assert.expect(p[i] == 0, "Allocated memory should be zero-initialized");
        }

        c.free(p);
    } else {
        try assert.expect(false, "ft_calloc returned null pointer");
    }
}

// Test with garbage values (ensuring zero-initialization)
// This test might return a false positive depending on malloc's behavior
var test_calloc_garbage = TestCase{
    .name = "Calloc with garbage values",
    .fn_ptr = &test_calloc_garbage_fn,
};

fn test_calloc_garbage_fn(_: std.mem.Allocator) TestCaseError!void {
    // Fill heap with garbage values
    const garbage_size: usize = 1024 * 1024; // 1 MB
    const garbage_ptr = try std.heap.c_allocator.alloc(u8, garbage_size);

    for (0..garbage_size) |i| {
        garbage_ptr[i] = 0xFF; // Fill with non-zero garbage
    }
    // Release memory, expecting it to be reused by ft_calloc
    std.heap.c_allocator.free(garbage_ptr);

    const num_elements: usize = 100_000; // 100 KB
    const element_size: usize = @sizeOf(u8);
    const ptr: ?*[num_elements]u8 = @ptrCast(ft_calloc(num_elements, element_size));
    if (ptr) |p| {
        for (0..num_elements) |i| {
            try assert.expect(p[i] == 0, "Allocated memory should be zero-initialized");
        }
        c.free(p);
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

    const ptr: ?*[num_elements * element_size]u8 = @ptrCast(ft_calloc(num_elements, element_size));

    if (ptr) |p| {
        for (0..(num_elements * element_size)) |i| {
            try assert.expect(p[i] == 0, "Allocated memory should be zero-initialized");
        }

        c.free(p);
        return;
    } else {
        try assert.expect(false, "ft_calloc returned null pointer");
    }
}

// Test with multiplication overflow
var test_calloc_overflow = TestCase{
    .name = "Calloc with multiplication overflow",
    .fn_ptr = &test_calloc_overflow_fn,
};

fn test_calloc_overflow_fn(_: std.mem.Allocator) AssertError!void {
    // Exact overflow case (overflows to zero)
    var num_elements: usize = std.math.maxInt(usize) / 2 + 1;
    const element_size: usize = 2;

    var ptr: ?*u8 = @ptrCast(ft_calloc(num_elements, element_size));

    try assert.expect(ptr == null, "ft_calloc should return null pointer on overflow");

    // Non-exact overflow case (overflows to 2)
    num_elements = std.math.maxInt(usize) / 2 + 2;

    ptr = @ptrCast(ft_calloc(num_elements, element_size));

    try assert.expect(ptr == null, "ft_calloc should return null pointer on overflow");
}

// Test with zero elements
var test_calloc_zero_elements = TestCase{
    .name = "Calloc with zero elements",
    .fn_ptr = &test_calloc_zero_elements_fn,
};

fn test_calloc_zero_elements_fn(_: std.mem.Allocator) AssertError!void {
    const num_elements: usize = 0;
    const element_size: usize = @sizeOf(u8);

    const ptr: ?*[num_elements * element_size]u8 = @ptrCast(ft_calloc(num_elements, element_size));

    try assert.expect(ptr != null, "ft_calloc should return a non-null pointer when allocating zero elements");

    c.free(ptr);
}

// Test with zero size
var test_calloc_zero_size = TestCase{
    .name = "Calloc with zero size",
    .fn_ptr = &test_calloc_zero_size_fn,
};

fn test_calloc_zero_size_fn(_: std.mem.Allocator) AssertError!void {
    const num_elements: usize = 5;
    const element_size: usize = 0;

    const ptr: ?*[num_elements * element_size]u8 = @ptrCast(ft_calloc(num_elements, element_size));

    try assert.expect(ptr != null, "ft_calloc should return a non-null pointer when allocating with zero size");

    c.free(ptr);
}

var test_cases = [_]*TestCase{
    &test_calloc_basic,
    &test_calloc_large,
    &test_calloc_different_sizes,
    &test_calloc_garbage,
    &test_calloc_overflow,
    &test_calloc_zero_elements,
    &test_calloc_zero_size,
};

pub var suite = TestSuite{
    .name = "ft_calloc",
    .cases = &test_cases,
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
