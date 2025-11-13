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

const is_function_defined = function_list.hasFunction("ft_strtrim");

fn ft_strtrim(s1: [*c]const u8, set: [*c]const u8) [*c]u8 {
    if (comptime !is_function_defined) {
        return null;
    } else {
        return c.ft_strtrim(s1, set);
    }
}

// Test normal string trim
var test_strtrim_normal = TestCase{
    .name = "Normal string trim",
    .fn_ptr = &test_strtrim_normal_fn,
};

fn test_strtrim_normal_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim("   Hello World   ", " ");
    try assert.expect(result != null, "ft_strtrim should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "Hello World") == 0, "Expected trimmed string 'Hello World'");
        c.free(str);
    }
}

// Test trim with multiple characters
var test_strtrim_multiple_chars = TestCase{
    .name = "Trim multiple characters",
    .fn_ptr = &test_strtrim_multiple_chars_fn,
};

fn test_strtrim_multiple_chars_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim(".,!Hello World!,.", ".,!");
    try assert.expect(result != null, "ft_strtrim should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "Hello World") == 0, "Expected trimmed string 'Hello World'");
        c.free(str);
    }
}

// Test trim with nothing to trim
var test_strtrim_nothing = TestCase{
    .name = "Nothing to trim",
    .fn_ptr = &test_strtrim_nothing_fn,
};

fn test_strtrim_nothing_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim("Hello World", " ");
    try assert.expect(result != null, "ft_strtrim should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "Hello World") == 0, "Expected unchanged string 'Hello World'");
        c.free(str);
    }
}

// Test trim entire string
var test_strtrim_entire = TestCase{
    .name = "Trim entire string",
    .fn_ptr = &test_strtrim_entire_fn,
};

fn test_strtrim_entire_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim("   ", " ");
    try assert.expect(result != null, "ft_strtrim should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "") == 0, "Expected empty string when entire string is trimmed");
        c.free(str);
    }
}

// Test trim with empty set
var test_strtrim_empty_set = TestCase{
    .name = "Trim with empty set",
    .fn_ptr = &test_strtrim_empty_set_fn,
};

fn test_strtrim_empty_set_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim("  Hello World  ", "");
    try assert.expect(result != null, "ft_strtrim should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "  Hello World  ") == 0, "Expected unchanged string with empty set");
        c.free(str);
    }
}

// Test trim with empty string
var test_strtrim_empty_string = TestCase{
    .name = "Trim empty string",
    .fn_ptr = &test_strtrim_empty_string_fn,
};

fn test_strtrim_empty_string_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim("", " ");
    try assert.expect(result != null, "ft_strtrim should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "") == 0, "Expected empty string");
        c.free(str);
    }
}

// Test trim from beginning only
var test_strtrim_beginning_only = TestCase{
    .name = "Trim from beginning only",
    .fn_ptr = &test_strtrim_beginning_only_fn,
};

fn test_strtrim_beginning_only_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim("   Hello World", " ");
    try assert.expect(result != null, "ft_strtrim should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "Hello World") == 0, "Expected string trimmed from beginning");
        c.free(str);
    }
}

// Test trim from end only
var test_strtrim_end_only = TestCase{
    .name = "Trim from end only",
    .fn_ptr = &test_strtrim_end_only_fn,
};

fn test_strtrim_end_only_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim("Hello World   ", " ");
    try assert.expect(result != null, "ft_strtrim should return a valid pointer");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "Hello World") == 0, "Expected string trimmed from end");
        c.free(str);
    }
}

// Test string is null
var test_strtrim_null_string = TestCase{
    .name = "Null string input",
    .fn_ptr = &test_strtrim_null_string_fn,
};

fn test_strtrim_null_string_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim(null, " ");
    try assert.expect(result == null, "ft_strtrim should return null for null string input");
}

// Test set is null
var test_strtrim_null_set = TestCase{
    .name = "Null set input",
    .fn_ptr = &test_strtrim_null_set_fn,
};

fn test_strtrim_null_set_fn(_: std.mem.Allocator) TestCaseError!void {
    const result = ft_strtrim("   Hello World   ", null);
    try assert.expect(result != null, "ft_strtrim should return a valid pointer when set is null");
    if (result) |str| {
        try assert.expect(c.strcmp(str, "   Hello World   ") == 0, "Expected unchanged string when set is null");
        c.free(str);
    }
}

var test_cases = [_]*TestCase{
    &test_strtrim_normal,
    &test_strtrim_multiple_chars,
    &test_strtrim_nothing,
    &test_strtrim_entire,
    &test_strtrim_empty_set,
    &test_strtrim_empty_string,
    &test_strtrim_beginning_only,
    &test_strtrim_end_only,
    &test_strtrim_null_string,
    &test_strtrim_null_set,
};

pub var suite = TestSuite{
    .name = "ft_strtrim",
    .cases = &test_cases,
    .result = if (is_function_defined) TestFramework.tests.TestSuiteResult.success else TestFramework.tests.TestSuiteResult.skipped,
};
