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

// Test copying a normal string into a sufficiently large buffer
var test_normal_copy = TestCase{
    .name = "Normal string copy",
    .fn_ptr = &test_normal_copy_fn,
};

fn test_normal_copy_fn(_: std.mem.Allocator) AssertError!void {
    var dest: [20]u8 = undefined;
    const src = "Hello, World!";
    const result = c.ft_strlcpy(&dest[0], src, dest.len);
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
    const result = c.ft_strlcpy(&dest[0], src, dest.len);
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
    const result = c.ft_strlcpy(&dest[0], src, dest.len);
    try assert.expect(result == 0, "Expected length to be 0");
    try assert.expect(dest[0] == 0, "Expected destination to be null-terminated");
}

var test_cases = [_]*TestCase{ &test_normal_copy, &test_truncated_copy, &test_empty_string_copy };

const is_function_defined = function_list.hasFunction("ft_strlcpy");

pub var suite = TestSuite{
    .name = "ft_strlcpy",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
