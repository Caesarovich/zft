const std = @import("std");
const tests = @import("tests");

const TestCase = tests.tests.TestCase;
const TestSuite = tests.tests.TestSuite;

const assert = tests.assert;
const AssertError = assert.AssertError;

const function_list = @import("function_list");

const c = @cImport({
    @cInclude("libft.h");
    @cInclude("string.h");
});

// Test normal string join
var test_strjoin_normal = TestCase{
    .name = "Normal string join",
    .fn_ptr = &test_strjoin_normal_fn,
};

fn test_strjoin_normal_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_strjoin("Hello", " World");
    try assert.expect(result != null, "ft_strjoin should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "Hello World") == 0, "Expected joined string 'Hello World'");
        c.free(str);
    }
}

// Test join with empty first string
var test_strjoin_empty_first = TestCase{
    .name = "Empty first string",
    .fn_ptr = &test_strjoin_empty_first_fn,
};

fn test_strjoin_empty_first_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_strjoin("", "World");
    try assert.expect(result != null, "ft_strjoin should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "World") == 0, "Expected second string 'World'");
        c.free(str);
    }
}

// Test join with empty second string
var test_strjoin_empty_second = TestCase{
    .name = "Empty second string",
    .fn_ptr = &test_strjoin_empty_second_fn,
};

fn test_strjoin_empty_second_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_strjoin("Hello", "");
    try assert.expect(result != null, "ft_strjoin should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "Hello") == 0, "Expected first string 'Hello'");
        c.free(str);
    }
}

// Test join with both empty strings
var test_strjoin_both_empty = TestCase{
    .name = "Both strings empty",
    .fn_ptr = &test_strjoin_both_empty_fn,
};

fn test_strjoin_both_empty_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_strjoin("", "");
    try assert.expect(result != null, "ft_strjoin should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "") == 0, "Expected empty string");
        c.free(str);
    }
}

// Test join with null first string
var test_strjoin_null_first = TestCase{
    .name = "Null first string",
    .fn_ptr = &test_strjoin_null_first_fn,
};

fn test_strjoin_null_first_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_strjoin(null, "World");
    try assert.expect(result == null, "ft_strjoin should return null for null first string");
}

// Test join with null second string
var test_strjoin_null_second = TestCase{
    .name = "Null second string",
    .fn_ptr = &test_strjoin_null_second_fn,
};

fn test_strjoin_null_second_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_strjoin("Hello", null);
    try assert.expect(result == null, "ft_strjoin should return null for null second string");
}

// Test join with long strings
var test_strjoin_long_strings = TestCase{
    .name = "Long strings join",
    .fn_ptr = &test_strjoin_long_strings_fn,
};

fn test_strjoin_long_strings_fn(_: std.mem.Allocator) AssertError!void {
    const s1 = "The quick brown fox jumps over";
    const s2 = " the lazy dog";
    const expected = "The quick brown fox jumps over the lazy dog";

    const result = c.ft_strjoin(s1, s2);
    try assert.expect(result != null, "ft_strjoin should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, expected) == 0, "Expected properly joined long string");
        c.free(str);
    }
}

const test_cases = [_]*TestCase{
    &test_strjoin_normal,
    &test_strjoin_empty_first,
    &test_strjoin_empty_second,
    &test_strjoin_both_empty,
    &test_strjoin_null_first,
    &test_strjoin_null_second,
    &test_strjoin_long_strings,
};

const is_function_defined = function_list.hasFunction("ft_strjoin");

pub const suite = TestSuite{
    .name = "ft_strjoin",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
