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

const is_function_defined = function_list.hasFunction("ft_strlcpy");

fn ft_strlcpy(dest: [*c]u8, src: [*c]const u8, size: usize) usize {
    if (comptime !is_function_defined) {
        return 0;
    } else {
        return c.ft_strlcpy(dest, src, size);
    }
}

// Test copying a normal string into a sufficiently large buffer
var test_normal_copy = TestCase{
    .name = "Normal string copy",
    .fn_ptr = &test_normal_copy_fn,
};

fn test_normal_copy_fn(_: std.mem.Allocator) AssertError!void {
    var dest: [20]u8 = undefined;
    const src = "Hello, World!";
    const result = ft_strlcpy(&dest[0], src, dest.len);
    try assert.expect(result == 13, "Expected length to be 13");
    try assert.expect(std.mem.eql(u8, dest[0..13], src), "Expected destination to match source");
}

// Test copying with size smaller than source length
var test_truncated_copy = TestCase{
    .name = "Truncated string copy",
    .fn_ptr = &test_truncated_copy_fn,
};

fn test_truncated_copy_fn(_: std.mem.Allocator) AssertError!void {
    var dest: [10]u8 = undefined;
    const src = "Hello, World!";
    const result = ft_strlcpy(&dest[0], src, dest.len);
    try assert.expect(result == 13, "Expected length to be 13");
    try assert.expect(std.mem.eql(u8, dest[0..9], "Hello, Wo"), "Expected destination to contain truncated source");
}

// Test copying an empty string
var test_empty_string_copy = TestCase{
    .name = "Empty string copy",
    .fn_ptr = &test_empty_string_copy_fn,
};

fn test_empty_string_copy_fn(_: std.mem.Allocator) AssertError!void {
    var dest: [10]u8 = undefined;
    const src = "";
    const result = ft_strlcpy(&dest[0], src, dest.len);
    try assert.expect(result == 0, "Expected length to be 0");
    try assert.expect(dest[0] == 0, "Expected destination to be null-terminated");
}

// Test copying with size zero
var test_copy_size_zero = TestCase{
    .name = "Copy with size zero",
    .fn_ptr = &test_copy_size_zero_fn,
};

fn test_copy_size_zero_fn(_: std.mem.Allocator) AssertError!void {
    var dest = "TEST";
    const src = "Hello";
    const result = ft_strlcpy(@constCast(&dest[0]), src, 0);
    try assert.expect(result == 5, "Expected length to be 5");
    try assert.expect(std.mem.eql(u8, dest[0..4], "TEST"), "Expected destination to remain unchanged");
}

// Test copying when destination buffer is smaller than current dest length
var test_copy_with_dest_size_smaller = TestCase{
    .name = "Copy with destination size smaller than current dest length",
    .fn_ptr = &test_copy_with_dest_size_smaller_fn,
};

fn test_copy_with_dest_size_smaller_fn(_: std.mem.Allocator) AssertError!void {
    var dest: [10]u8 = undefined;
    @memcpy(dest[0..9], "ABCDEFGHI");
    dest[9] = 0; // Null-terminate
    const src = "12345";
    const result = ft_strlcpy(&dest[0], src, 4); // dest size smaller than current dest length
    try assert.expect(result == 5, "Expected length to be 5");
    const expected: [10]u8 = .{ '1', '2', '3', 0, 'E', 'F', 'G', 'H', 'I', 0 };
    try assert.expect(std.mem.eql(u8, &dest, &expected), "Expected destination to contain truncated source followed by unchanged characters");
}

// Test with size larger than source length
var test_copy_with_size_larger = TestCase{
    .name = "Copy with size larger than source length",
    .fn_ptr = &test_copy_with_size_larger_fn,
};

fn test_copy_with_size_larger_fn(_: std.mem.Allocator) AssertError!void {
    var dest: [20]u8 = undefined;
    for (&dest) |*b| {
        b.* = 'A';
    }
    const src = "ZigLang";
    const result = ft_strlcpy(&dest[0], src, dest.len);
    try assert.expect(result == 7, "Expected length to be 7");
    try assert.expect(std.mem.eql(u8, dest[0..7], src), "Expected destination to match source");
    try assert.expect(dest[7] == 0, "Expected destination to be null-terminated after source string");
    try assert.expect(std.mem.eql(u8, dest[8..20], "AAAAAAAAAAAA"), "Expected remaining bytes to be unchanged");
}

var test_cases = [_]*TestCase{
    &test_normal_copy,
    &test_truncated_copy,
    &test_empty_string_copy,
    &test_copy_size_zero,
    &test_copy_with_dest_size_smaller,
    &test_copy_with_size_larger,
};

pub var suite = TestSuite{
    .name = "ft_strlcpy",
    .cases = &test_cases,
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
