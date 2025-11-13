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

const is_function_defined = function_list.hasFunction("ft_strlcat");

fn ft_strlcat(dest: [*c]u8, src: [*c]const u8, size: usize) usize {
    if (comptime !is_function_defined) {
        return 0;
    } else {
        return c.ft_strlcat(dest, src, size);
    }
}

// Test appending to an empty destination string
var test_append_to_empty_dest = TestCase{
    .name = "Append to empty destination",
    .fn_ptr = &test_append_to_empty_dest_fn,
};

fn test_append_to_empty_dest_fn(_: std.mem.Allocator) TestCaseError!void {
    var dest: [20]u8 = undefined;
    dest[0] = 0; // Null-terminate the empty string
    const src = "Hello";
    const result = ft_strlcat(&dest[0], src, dest.len);
    try assert.expect(result == 5, "Expected length to be 5");
    try assert.expect(std.mem.eql(u8, dest[0..5], src), "Expected destination to match source");
}

// Test appending when destination buffer is too small
var test_append_with_small_buffer = TestCase{
    .name = "Append with small buffer",
    .fn_ptr = &test_append_with_small_buffer_fn,
};

fn test_append_with_small_buffer_fn(_: std.mem.Allocator) TestCaseError!void {
    var dest: [10]u8 = undefined;
    @memcpy(dest[0..7], "Hello, ");
    dest[7] = 0; // Null-terminate
    const src = "World!";
    const result = ft_strlcat(&dest[0], src, dest.len);
    try assert.expect(result == 13, "Expected length to be 13");
    try assert.expect(std.mem.eql(u8, dest[0..9], "Hello, Wo"), "Expected destination to contain truncated source");
}

// Test appending an empty source string
var test_append_empty_source = TestCase{
    .name = "Append empty source",
    .fn_ptr = &test_append_empty_source_fn,
};

fn test_append_empty_source_fn(_: std.mem.Allocator) TestCaseError!void {
    var dest: [20]u8 = undefined;
    @memcpy(dest[0..5], "Hello");
    dest[5] = 0; // Null-terminate
    const src = "";
    const result = ft_strlcat(&dest[0], src, dest.len);
    try assert.expect(result == 5, "Expected length to be 5");
    try assert.expect(std.mem.eql(u8, dest[0..5], "Hello"), "Expected destination to remain unchanged");
}

// Test appending when there is no space in destination buffer
var test_append_no_space = TestCase{
    .name = "Append with no space",
    .fn_ptr = &test_append_no_space_fn,
};

fn test_append_no_space_fn(_: std.mem.Allocator) TestCaseError!void {
    var dest: [6]u8 = undefined;
    @memcpy(dest[0..5], "Hello");
    dest[5] = 0; // Null-terminate
    const src = "World!";
    const result = ft_strlcat(&dest[0], src, dest.len);
    try assert.expect(result == 11, "Expected length to be 11");
    try assert.expect(std.mem.eql(u8, dest[0..5], "Hello"), "Expected destination to remain unchanged");
}

// Test appending when destination buffer size is exactly enough
var test_append_exact_fit = TestCase{
    .name = "Append with exact fit",
    .fn_ptr = &test_append_exact_fit_fn,
};

fn test_append_exact_fit_fn(_: std.mem.Allocator) TestCaseError!void {
    var dest: [13]u8 = undefined;
    @memcpy(dest[0..7], "Hello, ");
    dest[7] = 0; // Null-terminate
    const src = "World!";
    const result = ft_strlcat(&dest[0], src, dest.len);
    try assert.expect(result == 13, "Expected length to be 13");
    try assert.expect(std.mem.eql(u8, dest[0..12], "Hello, World"), "Expected destination to match source exactly");
}

// Test when there is dest size is smaller than dest length
var test_append_with_dest_size_smaller = TestCase{
    .name = "Append with dest size smaller than dest length",
    .fn_ptr = &test_append_with_dest_size_smaller_fn,
};

fn test_append_with_dest_size_smaller_fn(_: std.mem.Allocator) TestCaseError!void {
    var dest: [10]u8 = undefined;
    @memcpy(dest[0..9], "ABCDEFGHI");
    dest[9] = 0; // Null-terminate
    const src = "12345";
    const result = ft_strlcat(&dest[0], src, 5); // dest size smaller than current dest length
    try assert.expect(result == 10, "Expected length to be 10"); // 9 + 5 = 14, but size is 5, so return 5 + 5 = 10
    try assert.expect(std.mem.eql(u8, dest[0..9], "ABCDEFGHI"), "Expected destination to remain unchanged");
}

// Test with garbage values in destination buffer
var test_append_with_garbage = TestCase{
    .name = "Append with garbage in destination",
    .fn_ptr = &test_append_with_garbage_fn,
};

fn test_append_with_garbage_fn(_: std.mem.Allocator) TestCaseError!void {
    var dest: [20]u8 = undefined;
    // Fill destination with garbage values
    for (&dest) |*byte| {
        byte.* = 0xFF;
    }
    dest[0] = 0; // Null-terminate to simulate empty string
    const src = "Data";
    const result = ft_strlcat(&dest[0], src, dest.len);
    try assert.expect(result == 4, "Expected length to be 4");
    try assert.expect(std.mem.eql(u8, dest[0..4], "Data"), "Expected destination to match source");
    try assert.expect(dest[4] == 0, "Expected null-termination after appended data");
    try assert.expect(dest[5] == 0xFF, "Expected garbage values to remain after null-termination");
}

var test_cases = [_]*TestCase{
    &test_append_to_empty_dest,
    &test_append_with_small_buffer,
    &test_append_empty_source,
    &test_append_no_space,
    &test_append_exact_fit,
    &test_append_with_dest_size_smaller,
    &test_append_with_garbage,
};

pub var suite = TestSuite{
    .name = "ft_strlcat",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
