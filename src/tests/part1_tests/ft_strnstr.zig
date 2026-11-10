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

const is_function_defined = function_list.hasFunction("ft_strnstr");

fn ft_strnstr(haystack: [*c]const u8, needle: [*c]const u8, n: usize) [*c]u8 {
    if (comptime !is_function_defined) {
        return null;
    } else {
        return c.ft_strnstr(haystack, needle, n);
    }
}

// Test when the substring is found within the first n characters
var test_substring_found = TestCase{
    .name = "Substring found within n characters",
    .fn_ptr = &test_substring_found_fn,
};

fn test_substring_found_fn(_: std.mem.Allocator) TestCaseError!void {
    const haystack = "Hello, world!";
    const needle = "world";
    const n: usize = 13;

    const result = ft_strnstr(haystack, needle, n);
    try assert.expect(result != null, "Expected to find substring 'world' in haystack");
    try assert.expect(result == &haystack[7], "Expected result to point to 'world!'");
}

// Test when the substring is not found within the first n characters
var test_substring_not_found = TestCase{
    .name = "Substring not found within n characters",
    .fn_ptr = &test_substring_not_found_fn,
};

fn test_substring_not_found_fn(_: std.mem.Allocator) TestCaseError!void {
    const haystack = "Hello, world!";
    const needle = "world";
    const n: usize = 5;

    const result = ft_strnstr(haystack, needle, n);
    try assert.expect(result == null, "Expected not to find substring 'world' in haystack within first 5 characters");
}

// Test when the needle is an empty string
var test_empty_needle = TestCase{
    .name = "Empty needle",
    .fn_ptr = &test_empty_needle_fn,
};

fn test_empty_needle_fn(_: std.mem.Allocator) TestCaseError!void {
    const haystack: [*c]const u8 = "Hello, world!";
    const needle = "";
    const n: usize = 13;

    const result = ft_strnstr(haystack, needle, n);
    try assert.expect(result == haystack, "Expected to return haystack when needle is empty");
}

// Test when n is zero
var test_n_zero = TestCase{
    .name = "n is zero",
    .fn_ptr = &test_n_zero_fn,
};

fn test_n_zero_fn(_: std.mem.Allocator) TestCaseError!void {
    const haystack = "Hello, world!";
    const needle = "Hello";
    const n: usize = 0;

    const result = ft_strnstr(haystack, needle, n);
    try assert.expect(result == null, "Expected not to find any substring when n is zero");
}

// Test when needle is longer than haystack
var test_needle_longer_than_haystack = TestCase{
    .name = "Needle longer than haystack",
    .fn_ptr = &test_needle_longer_than_haystack_fn,
};

fn test_needle_longer_than_haystack_fn(_: std.mem.Allocator) TestCaseError!void {
    const haystack = "Hello";
    const needle = "Hello, world!";
    const n: usize = 5;

    const result = ft_strnstr(haystack, needle, n);
    try assert.expect(result == null, "Expected not to find needle longer than haystack");
}

// Test when needle is at the very end of haystack within n characters
var test_needle_at_end_within_n = TestCase{
    .name = "Needle at end within n characters",
    .fn_ptr = &test_needle_at_end_within_n_fn,
};

fn test_needle_at_end_within_n_fn(_: std.mem.Allocator) TestCaseError!void {
    const haystack = "Hello, world!";
    const needle = "world!";
    const n: usize = 13;

    const result = ft_strnstr(haystack, needle, n);
    try assert.expect(result != null, "Expected to find needle at the end of haystack within n characters");
    try assert.expect(result == &haystack[7], "Expected result to point to 'world!'");
}

// Test when needle is at the very end of haystack but exceeds n characters
var test_needle_at_end_exceeds_n = TestCase{
    .name = "Needle at end exceeds n characters",
    .fn_ptr = &test_needle_at_end_exceeds_n_fn,
};

fn test_needle_at_end_exceeds_n_fn(_: std.mem.Allocator) TestCaseError!void {
    const haystack = "Hello, world!";
    const needle = "world!";
    const n: usize = 10;

    const result = ft_strnstr(haystack, needle, n);
    try assert.expect(result == null, "Expected not to find needle at the end of haystack when it exceeds n characters");
}

var test_cases = [_]*TestCase{
    &test_substring_found,
    &test_substring_not_found,
    &test_empty_needle,
    &test_n_zero,
    &test_needle_longer_than_haystack,
    &test_needle_at_end_within_n,
    &test_needle_at_end_exceeds_n,
};

pub var suite = TestSuite{
    .name = "ft_strnstr",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
