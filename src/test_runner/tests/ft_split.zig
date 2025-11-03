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

// Helper function to count words in a split result
fn count_words(split_result: [*c][*c]u8) usize {
    var count: usize = 0;
    while (split_result[count] != null) {
        count += 1;
    }
    return count;
}

// Helper function to free split result
fn free_split_result(split_result: [*c][*c]u8) void {
    var i: usize = 0;
    while (split_result[i] != null) {
        c.free(split_result[i]);
        i += 1;
    }
    c.free(@ptrCast(split_result));
}

// Test normal string split
var test_split_normal = TestCase{
    .name = "Normal string split",
    .fn_ptr = &test_split_normal_fn,
};

fn test_split_normal_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_split("Hello,World,Test", ',');
    try assert.expect(result != null, "ft_split should return a valid pointer");
    if (result) |split| {
        try assert.expect(count_words(split) == 3, "Expected 3 words");
        try assert.expect(c.strcmp(split[0], "Hello") == 0, "Expected first word 'Hello'");
        try assert.expect(c.strcmp(split[1], "World") == 0, "Expected second word 'World'");
        try assert.expect(c.strcmp(split[2], "Test") == 0, "Expected third word 'Test'");
        try assert.expect(split[3] == null, "Expected null terminator");
        free_split_result(split);
    }
}

// Test split with consecutive delimiters
var test_split_consecutive_delims = TestCase{
    .name = "Consecutive delimiters",
    .fn_ptr = &test_split_consecutive_delims_fn,
};

fn test_split_consecutive_delims_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_split("Hello,,World", ',');
    try assert.expect(result != null, "ft_split should return a valid pointer");
    if (result) |split| {
        try assert.expect(count_words(split) == 2, "Expected 2 words with consecutive delimiters");
        try assert.expect(c.strcmp(split[0], "Hello") == 0, "Expected first word 'Hello'");
        try assert.expect(c.strcmp(split[1], "World") == 0, "Expected second word 'World'");
        try assert.expect(split[2] == null, "Expected null terminator");
        free_split_result(split);
    }
}

// Test split with leading and trailing delimiters
var test_split_leading_trailing = TestCase{
    .name = "Leading and trailing delimiters",
    .fn_ptr = &test_split_leading_trailing_fn,
};

fn test_split_leading_trailing_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_split(",Hello,World,", ',');
    try assert.expect(result != null, "ft_split should return a valid pointer");
    if (result) |split| {
        try assert.expect(count_words(split) == 2, "Expected 2 words with leading/trailing delimiters");
        try assert.expect(c.strcmp(split[0], "Hello") == 0, "Expected first word 'Hello'");
        try assert.expect(c.strcmp(split[1], "World") == 0, "Expected second word 'World'");
        try assert.expect(split[2] == null, "Expected null terminator");
        free_split_result(split);
    }
}

// Test split with no delimiters
var test_split_no_delims = TestCase{
    .name = "No delimiters",
    .fn_ptr = &test_split_no_delims_fn,
};

fn test_split_no_delims_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_split("HelloWorld", ',');
    try assert.expect(result != null, "ft_split should return a valid pointer");
    if (result) |split| {
        try assert.expect(count_words(split) == 1, "Expected 1 word with no delimiters");
        try assert.expect(c.strcmp(split[0], "HelloWorld") == 0, "Expected single word 'HelloWorld'");
        try assert.expect(split[1] == null, "Expected null terminator");
        free_split_result(split);
    }
}

// Test split with empty string
var test_split_empty_string = TestCase{
    .name = "Empty string",
    .fn_ptr = &test_split_empty_string_fn,
};

fn test_split_empty_string_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_split("", ',');
    try assert.expect(result != null, "ft_split should return a valid pointer");
    if (result) |split| {
        try assert.expect(count_words(split) == 0, "Expected 0 words for empty string");
        try assert.expect(split[0] == null, "Expected immediate null terminator");
        free_split_result(split);
    }
}

// Test split with only delimiters
var test_split_only_delims = TestCase{
    .name = "Only delimiters",
    .fn_ptr = &test_split_only_delims_fn,
};

fn test_split_only_delims_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_split(",,,", ',');
    try assert.expect(result != null, "ft_split should return a valid pointer");
    if (result) |split| {
        try assert.expect(count_words(split) == 0, "Expected 0 words for string with only delimiters");
        try assert.expect(split[0] == null, "Expected immediate null terminator");
        free_split_result(split);
    }
}
// Test split with space delimiter
var test_split_space = TestCase{
    .name = "Space delimiter",
    .fn_ptr = &test_split_space_fn,
};

fn test_split_space_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_split("The quick brown fox", ' ');
    try assert.expect(result != null, "ft_split should return a valid pointer");
    if (result) |split| {
        try assert.expect(count_words(split) == 4, "Expected 4 words");
        try assert.expect(c.strcmp(split[0], "The") == 0, "Expected first word 'The'");
        try assert.expect(c.strcmp(split[1], "quick") == 0, "Expected second word 'quick'");
        try assert.expect(c.strcmp(split[2], "brown") == 0, "Expected third word 'brown'");
        try assert.expect(c.strcmp(split[3], "fox") == 0, "Expected fourth word 'fox'");
        try assert.expect(split[4] == null, "Expected null terminator");
        free_split_result(split);
    }
}

// Test split with single character
var test_split_single_char = TestCase{
    .name = "Single character",
    .fn_ptr = &test_split_single_char_fn,
};

fn test_split_single_char_fn(_: std.mem.Allocator) AssertError!void {
    const result = c.ft_split("a", ',');
    try assert.expect(result != null, "ft_split should return a valid pointer");
    if (result) |split| {
        try assert.expect(count_words(split) == 1, "Expected 1 word");
        try assert.expect(c.strcmp(split[0], "a") == 0, "Expected single character 'a'");
        try assert.expect(split[1] == null, "Expected null terminator");
        free_split_result(split);
    }
}

const test_cases = [_]*TestCase{
    &test_split_normal,
    &test_split_consecutive_delims,
    &test_split_leading_trailing,
    &test_split_no_delims,
    &test_split_empty_string,
    &test_split_only_delims,
    &test_split_space,
    &test_split_single_char,
};

const is_function_defined = function_list.hasFunction("ft_split");

pub const suite = TestSuite{
    .name = "ft_split",
    .cases = if (is_function_defined) &test_cases else &.{},
    .result = if (is_function_defined) tests.tests.TestSuiteResult.success else tests.tests.TestSuiteResult.skipped,
};
