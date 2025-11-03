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

// ft_strnstr

// Test when the substring is found within the first n characters
var test_substring_found = TestCase{
    .name = "Substring found within n characters",
    .fn_ptr = &test_substring_found_fn,
};

fn test_substring_found_fn(_: std.mem.Allocator) AssertError!void {
    const haystack = "Hello, world!";
    const needle = "world";
    const n: usize = 13;

    const result = c.ft_strnstr(haystack, needle, n);
    try assert.expect(result != null, "Expected to find substring 'world' in haystack");
    try assert.expect(result == &haystack[7], "Expected result to point to 'world!'");
}

// Test when the substring is not found within the first n characters
var test_substring_not_found = TestCase{
    .name = "Substring not found within n characters",
    .fn_ptr = &test_substring_not_found_fn,
};

fn test_substring_not_found_fn(_: std.mem.Allocator) AssertError!void {
    const haystack = "Hello, world!";
    const needle = "world";
    const n: usize = 5;

    const result = c.ft_strnstr(haystack, needle, n);
    try assert.expect(result == null, "Expected not to find substring 'world' in haystack within first 5 characters");
}

// Test when the needle is an empty string
var test_empty_needle = TestCase{
    .name = "Empty needle",
    .fn_ptr = &test_empty_needle_fn,
};

fn test_empty_needle_fn(_: std.mem.Allocator) AssertError!void {
    const haystack: [*c]const u8 = "Hello, world!";
    const needle = "";
    const n: usize = 13;

    const result = c.ft_strnstr(haystack, needle, n);
    try assert.expect(result == haystack, "Expected to return haystack when needle is empty");
}

// Test when n is zero
var test_n_zero = TestCase{
    .name = "n is zero",
    .fn_ptr = &test_n_zero_fn,
};

fn test_n_zero_fn(_: std.mem.Allocator) AssertError!void {
    const haystack = "Hello, world!";
    const needle = "Hello";
    const n: usize = 0;

    const result = c.ft_strnstr(haystack, needle, n);
    try assert.expect(result == null, "Expected not to find any substring when n is zero");
}

const test_cases = [_]*TestCase{
    &test_substring_found,
    &test_substring_not_found,
    &test_empty_needle,
    &test_n_zero,
};

const is_function_defined = function_list.hasFunction("ft_strnstr");

pub const suite = TestSuite{
    .name = "ft_strnstr",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
