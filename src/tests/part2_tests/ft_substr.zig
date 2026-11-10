const std = @import("std");

const TestFramework = @import("test-framework");
const assert = TestFramework.assert;
const TestCase = TestFramework.tests.TestCase;
const TestSuite = TestFramework.tests.TestSuite;
const TestCaseError = TestFramework.tests.TestCaseError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("string.h");
});

const is_function_defined = function_list.hasFunction("ft_substr");

fn ft_substr(s: [*c]const u8, start: c_uint, len: usize) [*c]u8 {
    if (comptime !is_function_defined) {
        return null;
    } else {
        return c.ft_substr(s, start, len);
    }
}

// Test normal substring extraction
var test_substr_normal = TestCase{
    .name = "Normal substring extraction",
    .fn_ptr = &test_substr_normal_fn,
};

fn test_substr_normal_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_substr("Hello World", 6, 5);
    try assert.expect(result != null, "ft_substr should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "World") == 0, "Expected substring 'World'");
        c.free(str);
    }
}

// Test substring from beginning
var test_substr_from_start = TestCase{
    .name = "Substring from start",
    .fn_ptr = &test_substr_from_start_fn,
};

fn test_substr_from_start_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_substr("Hello", 0, 3);
    try assert.expect(result != null, "ft_substr should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "Hel") == 0, "Expected substring 'Hel'");
        c.free(str);
    }
}

// Test substring with start beyond string length
var test_substr_start_beyond = TestCase{
    .name = "Start beyond string length",
    .fn_ptr = &test_substr_start_beyond_fn,
};

fn test_substr_start_beyond_fn(_: std.mem.Allocator) TestCaseError!void {
    var result = ft_substr("Hello", 10, 5);
    try assert.expect(result != null, "ft_substr should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "") == 0, "Expected empty string when start is beyond length");
        c.free(str);
    }

    // With really large start index
    result = ft_substr("Hello", 42_000_000, 5);
    try assert.expect(result != null, "ft_substr should return a valid pointer for large start index");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "") == 0, "Expected empty string when start is beyond length");
        c.free(str);
    }
}

// Test substring with length longer than remaining string
var test_substr_len_beyond = TestCase{
    .name = "Length beyond remaining string",
    .speculative = true,
    .fn_ptr = &test_substr_len_beyond_fn,
};

fn test_substr_len_beyond_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_substr("Hello", 2, 10);
    try assert.expect(result != null, "ft_substr should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "llo") == 0, "Expected remaining substring 'llo'");
        c.free(str);
    }
}

// Test with zero length
var test_substr_zero_len = TestCase{
    .name = "Zero length substring",
    .fn_ptr = &test_substr_zero_len_fn,
};

fn test_substr_zero_len_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_substr("Hello", 2, 0);
    try assert.expect(result != null, "ft_substr should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "") == 0, "Expected empty string with zero length");
        c.free(str);
    }
}

// Test with empty source string
var test_substr_empty_src = TestCase{
    .name = "Empty source string",
    .fn_ptr = &test_substr_empty_src_fn,
};

fn test_substr_empty_src_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_substr("", 0, 5);
    try assert.expect(result != null, "ft_substr should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "") == 0, "Expected empty string from empty source");
        c.free(str);
    }
}

// Test with null source string
var test_substr_null_src = TestCase{
    .name = "Null source string",
    .speculative = true,
    .fn_ptr = &test_substr_null_src_fn,
};

fn test_substr_null_src_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_substr(null, 0, 5);
    try assert.expect(result == null, "ft_substr should return null for null source");
}

var test_cases = [_]*TestCase{
    &test_substr_normal,
    &test_substr_from_start,
    &test_substr_start_beyond,
    &test_substr_len_beyond,
    &test_substr_zero_len,
    &test_substr_empty_src,
    &test_substr_null_src,
};

pub var suite = TestSuite{
    .name = "ft_substr",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
